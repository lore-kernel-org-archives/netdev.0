From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT PULL 00/15] perf/core improvements and fixes
Date: Tue, 14 Feb 2017 07:31:53 +0100
Message-ID: <20170214063153.GA3837@gmail.com>
References: <20170214011400.13352-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        Adrian Hunter <adrian.hunter@intel.com>,
        Alexei Starovoitov <ast@fb.com>,
        Clark Williams <williams@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsahern@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jiri Olsa <jolsa@kernel.org>, Joe Perches <joe@perches.com>,
        Joe Stringer <joe@ovn.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Namhyung Kim <namhyung@kernel.org>, netdev@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Taeung Song <treeze.taeung@gmail.com>,
        Wang Nan <wangnan0@huawei.com>,
        Wang YanQing <udknight@gmail.com>,
        linux-perf-users@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-perf-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214011400.13352-1-acme@kernel.org>
Sender: linux-perf-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Arnaldo Carvalho de Melo <acme@kernel.org> wrote:

> Hi Ingo,
> 
> 	Please consider pulling,
> 
> - Arnaldo
> 
> Test results at the end of this message, as usual.
> 
> The following changes since commit f2029b1e47b607619d1dd2cb0bbb77f64ec6b7c2:
> 
>   perf/x86/intel: Add Kaby Lake support (2017-02-11 21:28:23 +0100)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-4.11-20170213
> 
> for you to fetch changes up to a734fb5d60067a73dd7099a58756847c07f9cd68:
> 
>   samples/bpf: Reset global variables (2017-02-13 17:22:53 -0300)
> 
> ----------------------------------------------------------------
> perf/core improvements and fixes:
> 
> New feature:
> 
> - Introduce the 'delta-abs' 'perf diff' compute method, that orders the
>   histogram entries by the absolute value of the percentage delta for a
>   function in two perf.data files, i.e. the functions that changed the
>   most (increase or decrease in samples) comes first (Namhyung Kim)
> 
> User visible:
> 
> - Improve message about tweaking the kernel.perf_event_paranoid setting,
>   telling how to make the change permanent by editing /etc/sysctl.conf
>   (Ingo Molnar)
> 
> Infrastructure:
> 
> - Introduce linux/compiler-gcc.h as a counterpart to the kernel's,
>   initially containing the definition of __fallthrough, more to
>   come (__maybe_unused, etc) (Arnaldo Carvalho de Melo)
> 
> - Fixes for problems uncovered by building tools/perf with clang, such
>   as always true tests of arrays against NULL and variables that sometimes
>   were used without being initialized (Arnaldo Carvalho de Melo, Steven Rostedt)
> 
> - Before loading a new ELF, clear global variables set by the
>   samples/bpf loader (Mickaël Salaün)
> 
> - Ignore already processed ELF sections in the samples/bpf
>   loader (Mickaël Salaün)
> 
> - Fix compile error in the scripting code with some perl5
>   versions (Wang YanQing)
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> ----------------------------------------------------------------
> Arnaldo Carvalho de Melo (6):
>       tools include: Introduce linux/compiler-gcc.h
>       tools lib traceevent plugin function: Initialize 'index' variable
>       perf evsel: Inform how to make a sysctl setting permanent
>       perf symbols: No need to check if sym->name is NULL
>       perf tests record: No need to test an array against NULL
>       perf symbols: dso->name is an array, no need to check it against NULL
> 
> Mickaël Salaün (3):
>       samples/bpf: Add missing header
>       samples/bpf: Ignore already processed ELF sections
>       samples/bpf: Reset global variables
> 
> Namhyung Kim (4):
>       perf diff: Add 'delta-abs' compute method
>       perf diff: Add diff.order config option
>       perf diff: Add diff.compute config option
>       perf diff: Change default setting to "delta-abs"
> 
> Steven Rostedt (VMware) (1):
>       tools lib traceevent: Initialize lenght on OLD_RING_BUFFER_TYPE_TIME_STAMP
> 
> Wang YanQing (1):
>       perf scripting perl: Fix compile error with some perl5 versions
> 
>  samples/bpf/bpf_load.c                             |  7 ++
>  samples/bpf/tracex5_kern.c                         |  1 +
>  tools/include/linux/compiler-gcc.h                 | 14 ++++
>  tools/include/linux/compiler.h                     | 10 +--
>  tools/lib/traceevent/kbuffer-parse.c               |  1 +
>  tools/lib/traceevent/plugin_function.c             |  2 +-
>  tools/perf/Documentation/perf-config.txt           | 12 ++++
>  tools/perf/Documentation/perf-diff.txt             | 15 ++++-
>  tools/perf/MANIFEST                                |  1 +
>  tools/perf/builtin-diff.c                          | 78 ++++++++++++++++++++--
>  tools/perf/builtin-kmem.c                          |  4 +-
>  tools/perf/builtin-record.c                        |  2 +-
>  tools/perf/builtin-sched.c                         |  2 +-
>  tools/perf/builtin-stat.c                          |  2 +-
>  tools/perf/builtin-top.c                           |  2 +-
>  tools/perf/tests/perf-record.c                     |  2 +-
>  tools/perf/util/evsel.c                            |  4 +-
>  tools/perf/util/evsel_fprintf.c                    |  1 -
>  tools/perf/util/machine.c                          |  2 +-
>  tools/perf/util/map.c                              |  4 +-
>  tools/perf/util/scripting-engines/Build            |  2 +-
>  .../perf/util/scripting-engines/trace-event-perl.c |  4 +-
>  tools/perf/util/symbol_fprintf.c                   |  2 +-
>  23 files changed, 145 insertions(+), 29 deletions(-)
>  create mode 100644 tools/include/linux/compiler-gcc.h

Pulled, thanks a lot Arnaldo!

	Ingo
