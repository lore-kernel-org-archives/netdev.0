From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT PULL 00/29] perf/core improvements and fixes
Date: Tue, 20 Dec 2016 20:15:20 +0100
Message-ID: <20161220191520.GA16888@gmail.com>
References: <20161220170358.4350-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kim Phillips <kim.phillips@arm.com>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>, Andi Kleen <andi@firstfloor.org>,
 Paul Mackerras <paulus@samba.org>, Jiri Olsa <jolsa@redhat.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Alexei Starovoitov <ast@fb.com>,
 Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>,
 Peter Zijlstra <peterz@infradead.org>,
 "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>,
 Markus Trippelsdorf <markus@trippelsdorf.de>,
 Taeung Song <treeze.taeung@gmail.com>, Wang Nan <wangnan0@huawei.com>,
 Joe Stringer <joe@ovn.org>, Nicholas Piggin <npiggin@gmail.com>,
 Arnaldo Carvalho de Melo <acme@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
 Kyle McMartin <kyle@redhat.com>, Kan Liang <kan.liang@intel.com>,
 Chris Riyder <chris.ryder@arm.com>, linux-kernel@vger.kernel.org,
 Davidlohr Bueso <dbueso@suse.de>, Masami
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20161220170358.4350-1-acme@kernel.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org


* Arnaldo Carvalho de Melo <acme@kernel.org> wrote:

> Hi Ingo,
> 
>         Please consider pulling, I had most of this queued before your first
> pull req to Linus for 4.10, most are fixes, with 'perf sched timehist --idle'
> as a followup new feature to the 'perf sched timehist' command introduced in
> this window.
> 	
> 	One other thing that delayed this was the samples/bpf/ switch to
> tools/lib/bpf/ that involved fixing up merge clashes with net.git and also
> to properly test it, after more rounds than antecipated, but all seems ok
> now and would be good to get this merge issues past us ASAP.
> 
> - Arnaldo
> 
> Test results at the end of this message, as usual.
> 
> The following changes since commit e7aa8c2eb11ba69b1b69099c3c7bd6be3087b0ba:
> 
>   Merge tag 'docs-4.10' of git://git.lwn.net/linux (2016-12-12 21:58:13 -0800)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-20161220
> 
> for you to fetch changes up to 9899694a7f67714216665b87318eb367e2c5c901:
> 
>   samples/bpf: Move open_raw_sock to separate header (2016-12-20 12:00:40 -0300)
> 
> ----------------------------------------------------------------
> perf/core improvements and fixes:
> 
> New features:
> 
> - Introduce 'perf sched timehist --idle', to analyse processes
>   going to/from idle state (Namhyung Kim)
> 
> Fixes:
> 
> - Allow 'perf record -u user' to continue when facing races with threads
>   going away after having scanned them via /proc (Jiri Olsa)
> 
> - Fix 'perf mem' --all-user/--all-kernel options (Jiri Olsa)
> 
> - Support jumps with multiple arguments (Ravi Bangoria)
> 
> - Fix jumps to before the function where they are located (Ravi
> Bangoria)
> 
> - Fix lock-pi help string (Davidlohr Bueso)
> 
> - Fix build of 'perf trace' in odd systems such as a RHEL PPC one (Jiri Olsa)
> 
> - Do not overwrite valid build id in 'perf diff' (Kan Liang)
> 
> - Don't throw error for zero length symbols, allowing the use of the TUI
>   in PowerPC, where such symbols became more common recently (Ravi Bangoria)
> 
> Infrastructure:
> 
> - Switch of samples/bpf/ to use tools/lib/bpf, removing libbpf
>   duplication (Joe Stringer)
> 
> - Move headers check into bash script (Jiri Olsa)
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> ----------------------------------------------------------------
> Arnaldo Carvalho de Melo (3):
>       perf tools: Remove some needless __maybe_unused
>       samples/bpf: Make perf_event_read() static
>       samples/bpf: Be consistent with bpf_load_program bpf_insn parameter
> 
> Davidlohr Bueso (1):
>       perf bench futex: Fix lock-pi help string
> 
> Jiri Olsa (7):
>       perf tools: Move headers check into bash script
>       perf mem: Fix --all-user/--all-kernel options
>       perf evsel: Use variable instead of repeating lengthy FD macro
>       perf thread_map: Add thread_map__remove function
>       perf evsel: Allow to ignore missing pid
>       perf record: Force ignore_missing_thread for uid option
>       perf trace: Check if MAP_32BIT is defined (again)
> 
> Joe Stringer (8):
>       tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
>       tools lib bpf: use __u32 from linux/types.h
>       tools lib bpf: Add flags to bpf_create_map()
>       samples/bpf: Make samples more libbpf-centric
>       samples/bpf: Switch over to libbpf
>       tools lib bpf: Add bpf_prog_{attach,detach}
>       samples/bpf: Remove perf_event_open() declaration
>       samples/bpf: Move open_raw_sock to separate header
> 
> Kan Liang (1):
>       perf diff: Do not overwrite valid build id
> 
> Namhyung Kim (6):
>       perf sched timehist: Split is_idle_sample()
>       perf sched timehist: Introduce struct idle_time_data
>       perf sched timehist: Save callchain when entering idle
>       perf sched timehist: Skip non-idle events when necessary
>       perf sched timehist: Add -I/--idle-hist option
>       perf sched timehist: Show callchains for idle stat
> 
> Ravi Bangoria (3):
>       perf annotate: Support jump instruction with target as second operand
>       perf annotate: Fix jump target outside of function address range
>       perf annotate: Don't throw error for zero length symbols
> 
>  samples/bpf/Makefile                              |  70 +--
>  samples/bpf/README.rst                            |   4 +-
>  samples/bpf/bpf_load.c                            |  21 +-
>  samples/bpf/bpf_load.h                            |   3 +
>  samples/bpf/fds_example.c                         |  13 +-
>  samples/bpf/lathist_user.c                        |   2 +-
>  samples/bpf/libbpf.c                              | 176 -------
>  samples/bpf/libbpf.h                              |  28 +-
>  samples/bpf/lwt_len_hist_user.c                   |   6 +-
>  samples/bpf/offwaketime_user.c                    |   8 +-
>  samples/bpf/sampleip_user.c                       |   7 +-
>  samples/bpf/sock_example.c                        |  14 +-
>  samples/bpf/sock_example.h                        |  35 ++
>  samples/bpf/sockex1_user.c                        |   7 +-
>  samples/bpf/sockex2_user.c                        |   5 +-
>  samples/bpf/sockex3_user.c                        |   5 +-
>  samples/bpf/spintest_user.c                       |   8 +-
>  samples/bpf/tc_l2_redirect_user.c                 |   4 +-
>  samples/bpf/test_cgrp2_array_pin.c                |   4 +-
>  samples/bpf/test_cgrp2_attach.c                   |  12 +-
>  samples/bpf/test_cgrp2_attach2.c                  |   8 +-
>  samples/bpf/test_cgrp2_sock.c                     |   7 +-
>  samples/bpf/test_current_task_under_cgroup_user.c |   8 +-
>  samples/bpf/test_lru_dist.c                       |  32 +-
>  samples/bpf/test_probe_write_user_user.c          |   2 +-
>  samples/bpf/trace_event_user.c                    |  23 +-
>  samples/bpf/trace_output_user.c                   |   7 +-
>  samples/bpf/tracex2_user.c                        |  10 +-
>  samples/bpf/tracex3_user.c                        |   4 +-
>  samples/bpf/tracex4_user.c                        |   4 +-
>  samples/bpf/tracex6_user.c                        |   5 +-
>  samples/bpf/xdp1_user.c                           |   2 +-
>  samples/bpf/xdp_tx_iptunnel_user.c                |   6 +-
>  tools/include/uapi/linux/bpf.h                    | 593 +++++++++++++---------
>  tools/lib/bpf/bpf.c                               |  30 +-
>  tools/lib/bpf/bpf.h                               |   9 +-
>  tools/lib/bpf/libbpf.c                            |   3 +-
>  tools/perf/Documentation/perf-sched.txt           |   4 +
>  tools/perf/Makefile.perf                          |  94 +---
>  tools/perf/bench/futex-lock-pi.c                  |   2 +-
>  tools/perf/builtin-c2c.c                          |  13 +-
>  tools/perf/builtin-mem.c                          |   4 +-
>  tools/perf/builtin-record.c                       |   3 +
>  tools/perf/builtin-report.c                       |   2 +-
>  tools/perf/builtin-sched.c                        | 261 ++++++++--
>  tools/perf/builtin-stat.c                         |   6 +-
>  tools/perf/check-headers.sh                       |  59 +++
>  tools/perf/perf.h                                 |   1 +
>  tools/perf/tests/builtin-test.c                   |   4 +
>  tools/perf/tests/tests.h                          |   1 +
>  tools/perf/tests/thread-map.c                     |  44 ++
>  tools/perf/trace/beauty/mmap.c                    |   2 +
>  tools/perf/ui/browsers/annotate.c                 |   5 +-
>  tools/perf/util/annotate.c                        |  23 +-
>  tools/perf/util/annotate.h                        |   5 +-
>  tools/perf/util/evsel.c                           |  61 ++-
>  tools/perf/util/evsel.h                           |   1 +
>  tools/perf/util/symbol.c                          |   3 +-
>  tools/perf/util/thread_map.c                      |  22 +
>  tools/perf/util/thread_map.h                      |   1 +
>  60 files changed, 1075 insertions(+), 731 deletions(-)
>  delete mode 100644 samples/bpf/libbpf.c
>  create mode 100644 samples/bpf/sock_example.h
>  create mode 100755 tools/perf/check-headers.sh

Pulled, thanks a lot Arnaldo!

	Ingo
