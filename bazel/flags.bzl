"""Compiler and linker flags shared across the sonic-swss-common build."""

# CXXFLAGS that we need for Bazel specifically. Not present in the Makefile
CXXFLAGS_COMMON_BAZEL = [
    # TODO(bazel-ready): rules_distroless introduces a bunch of include directories that don't exist
    # so we need to disable that warning or else -Werror will fail the build.
    "-Wno-missing-include-dirs",
]

# CFLAGS_COMMON from configure.ac, which is used both for C and C++
CXXFLAGS_COMMON_MAKEFILE = [
    "-ansi",
    "-fPIC",
    "-std=c++14",
    "-Wall",
    "-Wcast-align",
    "-Wcast-qual",
    "-Wconversion",
    "-Wdisabled-optimization",
    "-Werror",
    "-Wextra",
    "-Wfloat-equal",
    "-Wformat=2",
    "-Wformat-nonliteral",
    "-Wformat-security",
    "-Wformat-y2k",
    "-Wimport",
    "-Winit-self",
    "-Winvalid-pch",
    "-Wlong-long",
    "-Wmissing-field-initializers",
    "-Wmissing-format-attribute",
    "-Wmissing-include-dirs",
    "-Wmissing-noreturn",
    "-Wno-aggregate-return",
    "-Wno-padded",
    "-Wno-switch-enum",
    "-Wno-unused-parameter",
    "-Wpacked",
    "-Wpointer-arith",
    "-Wredundant-decls",
    "-Wshadow",
    "-Wstack-protector",
    "-Wstrict-aliasing=3",
    "-Wswitch",
    "-Wswitch-default",
    "-Wunreachable-code",
    "-Wunused",
    "-Wvariadic-macros",
    "-Wno-write-strings",
    "-Wno-missing-format-attribute",
    "-Wno-long-long",
    "-fstack-protector-strong",
]

CXXFLAGS_COMMON = CXXFLAGS_COMMON_MAKEFILE + CXXFLAGS_COMMON_BAZEL

DBGFLAGS = select({
    "@sonic_build_infra//:debug_enabled": [
        "-ggdb",
        "-gdwarf-5",
    ],
    "//conditions:default": ["-g"],
})

# libbsd-dev ships /usr/lib/<multiarch>/libbsd.so as a GNU ld script whose GROUP()
# names libbsd.so.0.<soversion> by absolute path.
# That path does not exist inside the sandbox.
# rules_distroless papers over this with a --remap-inputs linkopt,
# but hardcodes bookworm's soversion (0.11.7)
# Point trixie's soversion at the file the libbsd0 package actually ships.
#
# TODO BL: drop this once rules_distroless stops treating ld scripts as shared libs.
# buildifier: disable=external-path
LIBBSD_LD_SCRIPT_REMAP = select({
    "@platforms//cpu:x86_64": [
        "-Wl,--remap-inputs=/usr/lib/x86_64-linux-gnu/libbsd.so.0.12.2=" +
        "$(BINDIR)/external/rules_distroless++apt+trixie_libbsd0-amd64_0.12.2-2/usr/lib/x86_64-linux-gnu/libbsd.so.0.12.2",
    ],
    "@platforms//cpu:arm64": [
        "-Wl,--remap-inputs=/usr/lib/aarch64-linux-gnu/libbsd.so.0.12.2=" +
        "$(BINDIR)/external/rules_distroless++apt+trixie_libbsd0-arm64_0.12.2-2/usr/lib/aarch64-linux-gnu/libbsd.so.0.12.2",
    ],
})
