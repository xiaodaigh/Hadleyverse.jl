module Dply

export combine

include("Across.jl") # defines the Across type

using DataFrames

import DataFrames: combine

"""
    A function to get input col names from Across.innames
"""
function get_input_cols(df, across_innames::Where)
    names(df)[across_innames.fn.(eachcol(df))]
end

function get_input_cols(df::GroupedDataFrame, across_innames::Where)
    names(df)[across_innames.fn.(eachcol(parent(df)))]
end

function get_input_cols(df, across_innames)
    filter(across_innames, names(df))
end

function DataFrames.transform(df::AbstractDataFrame, da::Across)
    input_cols = get_input_cols(df, da.innames)

    if isnothing(da.outnames)
        pairs = [col => fn for col in input_cols, fn in da.fn]
        return transform(df,  pairs...)
    else
        outcols = [
            replace(
                replace(da.outnames, "{col}" => col),
                    "{fn}" => string(fn)
                )
            for col in input_cols, fn in keys(da.fn)]

        in_fn_out_iterator = zip(Iterators.product(input_cols, da.fn), outcols)

        pairs = [col => fn => outcol for ((col, fn), outcol) in in_fn_out_iterator]

        return transform(df,  pairs...)
    end
end

function DataFrames.combine(df, da::Across)
    input_cols = get_input_cols(df, da.innames)

    if isnothing(da.outnames)
        pairs = [col => fn for col in input_cols, fn in da.fn]
        return combine(df,  pairs...)
    else
        outcols = [
            replace(
                replace(da.outnames, "{col}" => col),
                    "{fn}" => string(fn)
                )
            for col in input_cols, fn in keys(da.fn)]

        in_fn_out_iterator = zip(Iterators.product(input_cols, da.fn), outcols)

        pairs = [col => fn => outcol for ((col, fn), outcol) in in_fn_out_iterator]

        return combine(df,  pairs...)
    end
end


end
