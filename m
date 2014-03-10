From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v8 net-next 0/3] filter: add Extended BPF interpreter and converter, seccomp
Date: Sun,  9 Mar 2014 23:04:01 -0700
Message-ID: <1394431444-6987-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

V1 patches:
http://thread.gmane.org/gmane.linux.kernel/1605783
V2 patches:
http://thread.gmane.org/gmane.linux.kernel/1642325
V3 patches:
http://thread.gmane.org/gmane.linux.kernel/1656538

V4 summary:
- addressed Daniel comments
- RFC for seccomp with extended BPF
- added extended BPF design doc

V5 summary:
- fixed commit one-liner, removed empty line
- added Hagen's ack

V6 summary:
- unrolled loop in populate_seccomp_data() to help gcc on arm
- removed empty line at the end of the file
- removed redundant (u32) cast in JSET
- fixed BPF_RVAL instead of BPF_SRC for BPF_RET in sk_convert_filter()
- updated commit log
- added Daniel's Reviewed-by
- added Kees's Reviewed-by

V7 summary:
1/3:
- addressed Dave's feedback regarding typecasting:
  added 'jited' flag to sk_filter and union for bpf_func/bpf_func_ext
- added a comment to sk_run_filter_ext() about ctx<->skb relation
- removed CPU specific code from sk_run_filter() and sk_run_filter_ext()
  because of that revised arm32 cache-hit bpf micro-bench numbers slightly
  slower, but seccomp and cache-miss arm32 numbers stayed the same
2/3 and 3/3: no changes

V8 summary:
1/3:
- fixed sk_get_filter() issue caught by Daniel:
  need to save old filter, so it can be returned via sk_get_filter()
  count memory out of socket optmem budget
- addressed Eric's feedback:
  removed 'notrace'
  replaced integer registers constants and stack size with #define
- retested with my own bpf/ebpf testuite, seccomp and Pavel's
  so_get_filter test from crtools/test/zdtm/live/static/
- trimmed cc list, since it looks too big
2/3 and 3/3: no changes

x86_64, i386 and arm32 look clean.

Thanks!

Alexei Starovoitov (3):
  filter: add Extended BPF interpreter and converter
  seccomp: convert seccomp to use extended BPF
  doc: filter: add Extended BPF documentation

 Documentation/networking/filter.txt |  181 ++++++++
 arch/arm/net/bpf_jit_32.c           |    3 +-
 arch/powerpc/net/bpf_jit_comp.c     |    3 +-
 arch/s390/net/bpf_jit_comp.c        |    3 +-
 arch/sparc/net/bpf_jit_comp.c       |    3 +-
 arch/x86/net/bpf_jit_comp.c         |    3 +-
 include/linux/filter.h              |   43 +-
 include/linux/netdevice.h           |    1 +
 include/linux/seccomp.h             |    1 -
 include/net/sock.h                  |    4 +-
 include/uapi/linux/filter.h         |   33 +-
 kernel/seccomp.c                    |  118 +++--
 net/core/filter.c                   |  855 ++++++++++++++++++++++++++++++++++-
 net/core/sysctl_net_core.c          |    7 +
 14 files changed, 1148 insertions(+), 110 deletions(-)

-- 
1.7.9.5
