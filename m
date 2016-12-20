From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [GIT PULL 00/29] perf/core improvements and fixes
Date: Tue, 20 Dec 2016 14:03:29 -0300
Message-ID: <20161220170358.4350-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Alexei Starovoitov <ast@fb.com>,
        Andi Kleen <andi@firstfloor.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Riyder <chris.ryder@arm.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsahern@gmail.com>,
        Davidlohr Bueso <dbueso@suse.de>, Jiri Olsa <jolsa@redhat.com>,
        Joe Stringer <joe@ovn.org>, Kan Liang <kan.liang@intel.com>,
        Kim Phillips <kim.phillips@arm.com>,
        Kyle McMartin <kyle@redhat.com>, linuxppc-dev@lists.ozlabs.org,
        Markus Trippelsdorf <markus@trippelsdorf.de>,
        Masami Hiramatsu <mhiramat@kernel.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Minchan Ki
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

        Please consider pulling, I had most of this queued before your first
pull req to Linus for 4.10, most are fixes, with 'perf sched timehist --idle'
as a followup new feature to the 'perf sched timehist' command introduced in
this window.
	
	One other thing that delayed this was the samples/bpf/ switch to
tools/lib/bpf/ that involved fixing up merge clashes with net.git and also
to properly test it, after more rounds than antecipated, but all seems ok
now and would be good to get this merge issues past us ASAP.

- Arnaldo

Test results at the end of this message, as usual.

The following changes since commit e7aa8c2eb11ba69b1b69099c3c7bd6be3087b0ba:

  Merge tag 'docs-4.10' of git://git.lwn.net/linux (2016-12-12 21:58:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-20161220

for you to fetch changes up to 9899694a7f67714216665b87318eb367e2c5c901:

  samples/bpf: Move open_raw_sock to separate header (2016-12-20 12:00:40 -0300)

----------------------------------------------------------------
perf/core improvements and fixes:

New features:

- Introduce 'perf sched timehist --idle', to analyse processes
  going to/from idle state (Namhyung Kim)

Fixes:

- Allow 'perf record -u user' to continue when facing races with threads
  going away after having scanned them via /proc (Jiri Olsa)

- Fix 'perf mem' --all-user/--all-kernel options (Jiri Olsa)

- Support jumps with multiple arguments (Ravi Bangoria)

- Fix jumps to before the function where they are located (Ravi
Bangoria)

- Fix lock-pi help string (Davidlohr Bueso)

- Fix build of 'perf trace' in odd systems such as a RHEL PPC one (Jiri Olsa)

- Do not overwrite valid build id in 'perf diff' (Kan Liang)

- Don't throw error for zero length symbols, allowing the use of the TUI
  in PowerPC, where such symbols became more common recently (Ravi Bangoria)

Infrastructure:

- Switch of samples/bpf/ to use tools/lib/bpf, removing libbpf
  duplication (Joe Stringer)

- Move headers check into bash script (Jiri Olsa)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

----------------------------------------------------------------
Arnaldo Carvalho de Melo (3):
      perf tools: Remove some needless __maybe_unused
      samples/bpf: Make perf_event_read() static
      samples/bpf: Be consistent with bpf_load_program bpf_insn parameter

Davidlohr Bueso (1):
      perf bench futex: Fix lock-pi help string

Jiri Olsa (7):
      perf tools: Move headers check into bash script
      perf mem: Fix --all-user/--all-kernel options
      perf evsel: Use variable instead of repeating lengthy FD macro
      perf thread_map: Add thread_map__remove function
      perf evsel: Allow to ignore missing pid
      perf record: Force ignore_missing_thread for uid option
      perf trace: Check if MAP_32BIT is defined (again)

Joe Stringer (8):
      tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
      tools lib bpf: use __u32 from linux/types.h
      tools lib bpf: Add flags to bpf_create_map()
      samples/bpf: Make samples more libbpf-centric
      samples/bpf: Switch over to libbpf
      tools lib bpf: Add bpf_prog_{attach,detach}
      samples/bpf: Remove perf_event_open() declaration
      samples/bpf: Move open_raw_sock to separate header

Kan Liang (1):
      perf diff: Do not overwrite valid build id

Namhyung Kim (6):
      perf sched timehist: Split is_idle_sample()
      perf sched timehist: Introduce struct idle_time_data
      perf sched timehist: Save callchain when entering idle
      perf sched timehist: Skip non-idle events when necessary
      perf sched timehist: Add -I/--idle-hist option
      perf sched timehist: Show callchains for idle stat

Ravi Bangoria (3):
      perf annotate: Support jump instruction with target as second operand
      perf annotate: Fix jump target outside of function address range
      perf annotate: Don't throw error for zero length symbols

 samples/bpf/Makefile                              |  70 +--
 samples/bpf/README.rst                            |   4 +-
 samples/bpf/bpf_load.c                            |  21 +-
 samples/bpf/bpf_load.h                            |   3 +
 samples/bpf/fds_example.c                         |  13 +-
 samples/bpf/lathist_user.c                        |   2 +-
 samples/bpf/libbpf.c                              | 176 -------
 samples/bpf/libbpf.h                              |  28 +-
 samples/bpf/lwt_len_hist_user.c                   |   6 +-
 samples/bpf/offwaketime_user.c                    |   8 +-
 samples/bpf/sampleip_user.c                       |   7 +-
 samples/bpf/sock_example.c                        |  14 +-
 samples/bpf/sock_example.h                        |  35 ++
 samples/bpf/sockex1_user.c                        |   7 +-
 samples/bpf/sockex2_user.c                        |   5 +-
 samples/bpf/sockex3_user.c                        |   5 +-
 samples/bpf/spintest_user.c                       |   8 +-
 samples/bpf/tc_l2_redirect_user.c                 |   4 +-
 samples/bpf/test_cgrp2_array_pin.c                |   4 +-
 samples/bpf/test_cgrp2_attach.c                   |  12 +-
 samples/bpf/test_cgrp2_attach2.c                  |   8 +-
 samples/bpf/test_cgrp2_sock.c                     |   7 +-
 samples/bpf/test_current_task_under_cgroup_user.c |   8 +-
 samples/bpf/test_lru_dist.c                       |  32 +-
 samples/bpf/test_probe_write_user_user.c          |   2 +-
 samples/bpf/trace_event_user.c                    |  23 +-
 samples/bpf/trace_output_user.c                   |   7 +-
 samples/bpf/tracex2_user.c                        |  10 +-
 samples/bpf/tracex3_user.c                        |   4 +-
 samples/bpf/tracex4_user.c                        |   4 +-
 samples/bpf/tracex6_user.c                        |   5 +-
 samples/bpf/xdp1_user.c                           |   2 +-
 samples/bpf/xdp_tx_iptunnel_user.c                |   6 +-
 tools/include/uapi/linux/bpf.h                    | 593 +++++++++++++---------
 tools/lib/bpf/bpf.c                               |  30 +-
 tools/lib/bpf/bpf.h                               |   9 +-
 tools/lib/bpf/libbpf.c                            |   3 +-
 tools/perf/Documentation/perf-sched.txt           |   4 +
 tools/perf/Makefile.perf                          |  94 +---
 tools/perf/bench/futex-lock-pi.c                  |   2 +-
 tools/perf/builtin-c2c.c                          |  13 +-
 tools/perf/builtin-mem.c                          |   4 +-
 tools/perf/builtin-record.c                       |   3 +
 tools/perf/builtin-report.c                       |   2 +-
 tools/perf/builtin-sched.c                        | 261 ++++++++--
 tools/perf/builtin-stat.c                         |   6 +-
 tools/perf/check-headers.sh                       |  59 +++
 tools/perf/perf.h                                 |   1 +
 tools/perf/tests/builtin-test.c                   |   4 +
 tools/perf/tests/tests.h                          |   1 +
 tools/perf/tests/thread-map.c                     |  44 ++
 tools/perf/trace/beauty/mmap.c                    |   2 +
 tools/perf/ui/browsers/annotate.c                 |   5 +-
 tools/perf/util/annotate.c                        |  23 +-
 tools/perf/util/annotate.h                        |   5 +-
 tools/perf/util/evsel.c                           |  61 ++-
 tools/perf/util/evsel.h                           |   1 +
 tools/perf/util/symbol.c                          |   3 +-
 tools/perf/util/thread_map.c                      |  22 +
 tools/perf/util/thread_map.h                      |   1 +
 60 files changed, 1075 insertions(+), 731 deletions(-)
 delete mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/sock_example.h
 create mode 100755 tools/perf/check-headers.sh

  [root@jouet ~]# uname -a
  Linux jouet 4.9.0+ #1 SMP Mon Dec 19 15:44:52 BRT 2016 x86_64 x86_64 x86_64 GNU/Linux
  [root@jouet ~]# perf test
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
  37.2: BPF prologue generation                  : Ok
  37.3: BPF relocation checker                   : Ok
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
  53: x86 rdpmc                                  : Ok
  54: Convert perf time to TSC                   : Ok
  55: DWARF unwind                               : Ok
  56: x86 instruction decoder - new instructions : Ok
  57: Intel cqm nmi context read                 : Skip
  [root@jouet ~]# 

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
  10 debian:experimental-x-mips64: Ok
  11 fedora:20: Ok
  12 fedora:21: Ok
  13 fedora:22: Ok
  14 fedora:23: Ok
  15 fedora:24: Ok
  16 fedora:24-x-ARC-uClibc: Ok
  17 fedora:25: Ok
  18 fedora:rawhide: Ok
  19 mageia:5: Ok
  20 opensuse:13.2: Ok
  21 opensuse:42.1: Ok
  22 opensuse:tumbleweed: Ok
  23 ubuntu:12.04.5: Ok
  24 ubuntu:14.04.4-x-linaro-arm64: Ok
  25 ubuntu:16.04: Ok
  26 ubuntu:16.04-x-arm: Ok
  27 ubuntu:16.04-x-arm64: Ok
  28 ubuntu:16.04-x-powerpc: Ok
  29 ubuntu:16.04-x-powerpc64: Ok
  30 ubuntu:16.04-x-powerpc64el: Ok
  31 ubuntu:16.04-x-s390: Ok
  32 ubuntu:16.10: Ok
  #

  $ make -C tools/perf build-test
  make: Entering directory `/home/acme/git/linux/tools/perf'
  - tarpkg: ./tests/perf-targz-src-pkg .
                make_minimal_O: cd . && make NO_LIBPERL=1 NO_LIBPYTHON=1 NO_NEWT=1 NO_GTK2=1 NO_DEMANGLE=1 NO_LIBELF=1 NO_LIBUNWIND=1 NO_BACKTRACE=1 NO_LIBNUMA=1 NO_LIBAUDIT=1 NO_LIBBIONIC=1 NO_LIBDW_DWARF_UNWIND=1 NO_AUXTRACE=1 NO_LIBBPF=1 NO_LIBCRYPTO=1 NO_SDT=1 NO_JVMTI=1
              make_clean_all_O: cd . && make clean all
            make_no_demangle_O: cd . && make NO_DEMANGLE=1
            make_no_auxtrace_O: cd . && make NO_AUXTRACE=1
         make_with_clangllvm_O: cd . && make LIBCLANGLLVM=1
                 make_static_O: cd . && make LDFLAGS=-static
                 make_cscope_O: cd . && make cscope
                  make_no_ui_O: cd . && make NO_NEWT=1 NO_SLANG=1 NO_GTK2=1
   make_install_prefix_slash_O: cd . && make install prefix=/tmp/krava/
       make_util_pmu_bison_o_O: cd . && make util/pmu-bison.o
        make_with_babeltrace_O: cd . && make LIBBABELTRACE=1
             make_no_libnuma_O: cd . && make NO_LIBNUMA=1
                make_no_gtk2_O: cd . && make NO_GTK2=1
           make_no_libbionic_O: cd . && make NO_LIBBIONIC=1
                  make_debug_O: cd . && make DEBUG=1
                   make_tags_O: cd . && make tags
             make_no_libperl_O: cd . && make NO_LIBPERL=1
               make_no_slang_O: cd . && make NO_SLANG=1
             make_util_map_o_O: cd . && make util/map.o
           make_no_backtrace_O: cd . && make NO_BACKTRACE=1
                    make_doc_O: cd . && make doc
         make_install_prefix_O: cd . && make install prefix=/tmp/krava
             make_no_scripts_O: cd . && make NO_LIBPYTHON=1 NO_LIBPERL=1
                 make_perf_o_O: cd . && make perf.o
            make_install_bin_O: cd . && make install-bin
              make_no_libbpf_O: cd . && make NO_LIBBPF=1
           make_no_libunwind_O: cd . && make NO_LIBUNWIND=1
                   make_help_O: cd . && make help
            make_no_libaudit_O: cd . && make NO_LIBAUDIT=1
              make_no_libelf_O: cd . && make NO_LIBELF=1
           make_no_libpython_O: cd . && make NO_LIBPYTHON=1
  make_no_libdw_dwarf_unwind_O: cd . && make NO_LIBDW_DWARF_UNWIND=1
                make_no_newt_O: cd . && make NO_NEWT=1
                   make_pure_O: cd . && make
                make_install_O: cd . && make install
  OK
  make: Leaving directory `/home/acme/git/linux/tools/perf'
  $
