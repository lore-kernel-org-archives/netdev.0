From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [GIT PULL 00/15] perf/core improvements and fixes
Date: Mon, 13 Feb 2017 22:13:45 -0300
Message-ID: <20170214011400.13352-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Alexei Starovoitov <ast@fb.com>,
        Clark Williams <williams@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsahern@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jiri Olsa <jolsa@kernel.org>, Joe Perches <joe@perches.com>,
        Joe Stringer <joe@ovn.org>,
        =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Namhyung Kim <namhyung@kernel.org>, netdev@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Taeung Song <treeze.taeung@gmail.com>,
        Wang Nan <wangnan0@huawei.com>,
        Wang YanQing <udknight@gmail.com>,
        linux-perf-users@vger.kernel.org,
        Arnaldo Carvalho de Melo <a
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

	Please consider pulling,

- Arnaldo

Test results at the end of this message, as usual.

The following changes since commit f2029b1e47b607619d1dd2cb0bbb77f64ec6b7c2:

  perf/x86/intel: Add Kaby Lake support (2017-02-11 21:28:23 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-4.11-20170213

for you to fetch changes up to a734fb5d60067a73dd7099a58756847c07f9cd68:

  samples/bpf: Reset global variables (2017-02-13 17:22:53 -0300)

----------------------------------------------------------------
perf/core improvements and fixes:

New feature:

- Introduce the 'delta-abs' 'perf diff' compute method, that orders the
  histogram entries by the absolute value of the percentage delta for a
  function in two perf.data files, i.e. the functions that changed the
  most (increase or decrease in samples) comes first (Namhyung Kim)

User visible:

- Improve message about tweaking the kernel.perf_event_paranoid setting,
  telling how to make the change permanent by editing /etc/sysctl.conf
  (Ingo Molnar)

Infrastructure:

- Introduce linux/compiler-gcc.h as a counterpart to the kernel's,
  initially containing the definition of __fallthrough, more to
  come (__maybe_unused, etc) (Arnaldo Carvalho de Melo)

- Fixes for problems uncovered by building tools/perf with clang, such
  as always true tests of arrays against NULL and variables that sometimes
  were used without being initialized (Arnaldo Carvalho de Melo, Steven Rostedt)

- Before loading a new ELF, clear global variables set by the
  samples/bpf loader (Mickaël Salaün)

- Ignore already processed ELF sections in the samples/bpf
  loader (Mickaël Salaün)

- Fix compile error in the scripting code with some perl5
  versions (Wang YanQing)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

----------------------------------------------------------------
Arnaldo Carvalho de Melo (6):
      tools include: Introduce linux/compiler-gcc.h
      tools lib traceevent plugin function: Initialize 'index' variable
      perf evsel: Inform how to make a sysctl setting permanent
      perf symbols: No need to check if sym->name is NULL
      perf tests record: No need to test an array against NULL
      perf symbols: dso->name is an array, no need to check it against NULL

Mickaël Salaün (3):
      samples/bpf: Add missing header
      samples/bpf: Ignore already processed ELF sections
      samples/bpf: Reset global variables

Namhyung Kim (4):
      perf diff: Add 'delta-abs' compute method
      perf diff: Add diff.order config option
      perf diff: Add diff.compute config option
      perf diff: Change default setting to "delta-abs"

Steven Rostedt (VMware) (1):
      tools lib traceevent: Initialize lenght on OLD_RING_BUFFER_TYPE_TIME_STAMP

Wang YanQing (1):
      perf scripting perl: Fix compile error with some perl5 versions

 samples/bpf/bpf_load.c                             |  7 ++
 samples/bpf/tracex5_kern.c                         |  1 +
 tools/include/linux/compiler-gcc.h                 | 14 ++++
 tools/include/linux/compiler.h                     | 10 +--
 tools/lib/traceevent/kbuffer-parse.c               |  1 +
 tools/lib/traceevent/plugin_function.c             |  2 +-
 tools/perf/Documentation/perf-config.txt           | 12 ++++
 tools/perf/Documentation/perf-diff.txt             | 15 ++++-
 tools/perf/MANIFEST                                |  1 +
 tools/perf/builtin-diff.c                          | 78 ++++++++++++++++++++--
 tools/perf/builtin-kmem.c                          |  4 +-
 tools/perf/builtin-record.c                        |  2 +-
 tools/perf/builtin-sched.c                         |  2 +-
 tools/perf/builtin-stat.c                          |  2 +-
 tools/perf/builtin-top.c                           |  2 +-
 tools/perf/tests/perf-record.c                     |  2 +-
 tools/perf/util/evsel.c                            |  4 +-
 tools/perf/util/evsel_fprintf.c                    |  1 -
 tools/perf/util/machine.c                          |  2 +-
 tools/perf/util/map.c                              |  4 +-
 tools/perf/util/scripting-engines/Build            |  2 +-
 .../perf/util/scripting-engines/trace-event-perl.c |  4 +-
 tools/perf/util/symbol_fprintf.c                   |  2 +-
 23 files changed, 145 insertions(+), 29 deletions(-)
 create mode 100644 tools/include/linux/compiler-gcc.h

Test results:

The first ones are container (docker) based builds of tools/perf with and
without libelf support, objtool where it is supported and samples/bpf/, ditto.

Several are cross builds, the ones with -x-ARCH, and the android one, and those
may not have all the features built, due to lack of multi-arch devel packages,
available and being used so far on just a few, like
debian:experimental-x-{arm64,mipsel}.

The 'perf test' one will perform a variety of tests exercising
tools/perf/util/, tools/lib/{bpf,traceevent,etc}, as well as run perf commands
with a variety of command line event specifications to then intercept the
sys_perf_event syscall to check that the perf_event_attr fields are set up as
expected, among a variety of other unit tests.

Then there is the 'make -C tools/perf build-test' ones, that build tools/perf/
with a variety of feature sets, exercising the build with an incomplete set of
features as well as with a complete one. It is planned to have it run on each
of the containers mentioned above, using some container orchestration
infrastructure. Get in contact if interested in helping having this in place.

  # time dm
   1 alpine:3.4: Ok
   2 android-ndk:r12b-arm: Ok
   3 archlinux:latest: Ok
   4 centos:5: Ok
   5 centos:6: Ok
   6 centos:7: Ok
   7 debian:7: Ok
   8 debian:8: Ok
   9 debian:experimental: Ok
  10 debian:experimental-x-arm64: Ok
  11 debian:experimental-x-mips: Ok
  12 debian:experimental-x-mips64: Ok
  13 debian:experimental-x-mipsel: Ok
  14 fedora:20: Ok
  15 fedora:21: Ok
  16 fedora:22: Ok
  17 fedora:23: Ok
  18 fedora:24: Ok
  19 fedora:24-x-ARC-uClibc: Ok
  20 fedora:25: Ok
  21 fedora:rawhide: Ok
  22 mageia:5: Ok
  23 opensuse:13.2: Ok
  24 opensuse:42.1: Ok
  25 opensuse:tumbleweed: Ok
  26 ubuntu:12.04.5: Ok
  27 ubuntu:14.04.4-x-linaro-arm64: Ok
  28 ubuntu:15.10: Ok
  29 ubuntu:16.04: Ok
  30 ubuntu:16.04-x-arm: Ok
  31 ubuntu:16.04-x-arm64: Ok
  32 ubuntu:16.04-x-powerpc: Ok
  33 ubuntu:16.04-x-powerpc64: Ok
  34 ubuntu:16.04-x-powerpc64el: Ok
  35 ubuntu:16.04-x-s390: Ok
  36 ubuntu:16.10: Ok
  #

  # uname -a
  Linux jouet 4.9.8-201.fc25.x86_64 #1 SMP Tue Feb 7 11:28:07 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
  # perf test
   1: vmlinux symtab matches kallsyms            : Ok
   2: Detect openat syscall event                : Ok
   3: Detect openat syscall event on all cpus    : Ok
   4: Read samples using the mmap interface      : Ok
   5: Parse event definition strings             : Ok
   6: PERF_RECORD_* events & perf_sample fields  : Ok
   7: Parse perf pmu format                      : Ok
   8: DSO data read                              : Ok
   9: DSO data cache                             : Ok
  10: DSO data reopen                            : Ok
  11: Roundtrip evsel->name                      : Ok
  12: Parse sched tracepoints fields             : Ok
  13: syscalls:sys_enter_openat event fields     : Ok
  14: Setup struct perf_event_attr               : Ok
  15: Match and link multiple hists              : Ok
  16: 'import perf' in python                    : Ok
  17: Breakpoint overflow signal handler         : Ok
  18: Breakpoint overflow sampling               : Ok
  19: Number of exit events of a simple workload : Ok
  20: Software clock events period values        : Ok
  21: Object code reading                        : Ok
  22: Sample parsing                             : Ok
  23: Use a dummy software event to keep tracking: Ok
  24: Parse with no sample_id_all bit set        : Ok
  25: Filter hist entries                        : Ok
  26: Lookup mmap thread                         : Ok
  27: Share thread mg                            : Ok
  28: Sort output of hist entries                : Ok
  29: Cumulate child hist entries                : Ok
  30: Track with sched_switch                    : Ok
  31: Filter fds with revents mask in a fdarray  : Ok
  32: Add fd to a fdarray, making it autogrow    : Ok
  33: kmod_path__parse                           : Ok
  34: Thread map                                 : Ok
  35: LLVM search and compile                    :
  35.1: Basic BPF llvm compile                    : Ok
  35.2: kbuild searching                          : Ok
  35.3: Compile source for BPF prologue generation: Ok
  35.4: Compile source for BPF relocation         : Ok
  36: Session topology                           : Ok
  37: BPF filter                                 :
  37.1: Basic BPF filtering                      : Ok
  37.2: BPF pinning                              : Ok
  37.3: BPF prologue generation                  : Ok
  37.4: BPF relocation checker                   : Ok
  38: Synthesize thread map                      : Ok
  39: Remove thread map                          : Ok
  40: Synthesize cpu map                         : Ok
  41: Synthesize stat config                     : Ok
  42: Synthesize stat                            : Ok
  43: Synthesize stat round                      : Ok
  44: Synthesize attr update                     : Ok
  45: Event times                                : Ok
  46: Read backward ring buffer                  : Ok
  47: Print cpu map                              : Ok
  48: Probe SDT events                           : Ok
  49: is_printable_array                         : Ok
  50: Print bitmap                               : Ok
  51: perf hooks                                 : Ok
  52: builtin clang support                      : Skip (not compiled in)
  53: unit_number__scnprintf                     : Ok
  54: x86 rdpmc                                  : Ok
  55: Convert perf time to TSC                   : Ok
  56: DWARF unwind                               : Ok
  57: x86 instruction decoder - new instructions : Ok
  58: Intel cqm nmi context read                 : Skip
  #

  $ make -C tools/perf build-test
  make: Entering directory '/home/acme/git/linux/tools/perf'
  - tarpkg: ./tests/perf-targz-src-pkg .
                make_install_O: make install
           make_no_libunwind_O: make NO_LIBUNWIND=1
                make_no_newt_O: make NO_NEWT=1
               make_no_slang_O: make NO_SLANG=1
                 make_static_O: make LDFLAGS=-static
           make_no_backtrace_O: make NO_BACKTRACE=1
           make_no_libbionic_O: make NO_LIBBIONIC=1
              make_clean_all_O: make clean all
       make_util_pmu_bison_o_O: make util/pmu-bison.o
             make_no_libnuma_O: make NO_LIBNUMA=1
                   make_tags_O: make tags
                  make_no_ui_O: make NO_NEWT=1 NO_SLANG=1 NO_GTK2=1
  make_no_libdw_dwarf_unwind_O: make NO_LIBDW_DWARF_UNWIND=1
                make_minimal_O: make NO_LIBPERL=1 NO_LIBPYTHON=1 NO_NEWT=1 NO_GTK2=1 NO_DEMANGLE=1 NO_LIBELF=1 NO_LIBUNWIND=1 NO_BACKTRACE=1 NO_LIBNUMA=1 NO_LIBAUDIT=1 NO_LIBBIONIC=1 NO_LIBDW_DWARF_UNWIND=1 NO_AUXTRACE=1 NO_LIBBPF=1 NO_LIBCRYPTO=1 NO_SDT=1 NO_JVMTI=1
                 make_perf_o_O: make perf.o
   make_install_prefix_slash_O: make install prefix=/tmp/krava/
           make_no_libpython_O: make NO_LIBPYTHON=1
                make_no_gtk2_O: make NO_GTK2=1
            make_no_libaudit_O: make NO_LIBAUDIT=1
                   make_help_O: make help
        make_with_babeltrace_O: make LIBBABELTRACE=1
         make_install_prefix_O: make install prefix=/tmp/krava
                  make_debug_O: make DEBUG=1
              make_no_libbpf_O: make NO_LIBBPF=1
             make_util_map_o_O: make util/map.o
         make_with_clangllvm_O: make LIBCLANGLLVM=1
             make_no_libperl_O: make NO_LIBPERL=1
             make_no_scripts_O: make NO_LIBPYTHON=1 NO_LIBPERL=1
                    make_doc_O: make doc
              make_no_libelf_O: make NO_LIBELF=1
            make_no_auxtrace_O: make NO_AUXTRACE=1
            make_install_bin_O: make install-bin
            make_no_demangle_O: make NO_DEMANGLE=1
                   make_pure_O: make
  OK
  make: Leaving directory '/home/acme/git/linux/tools/perf'
  $
