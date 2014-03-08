From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v7 net-next 0/3] filter: add Extended BPF interpreter and converter, seccomp
Date: Sat,  8 Mar 2014 15:15:27 -0800
Message-ID: <1394320530-3508-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

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
 include/linux/filter.h              |   16 +-
 include/linux/netdevice.h           |    1 +
 include/linux/seccomp.h             |    1 -
 include/uapi/linux/filter.h         |   33 +-
 kernel/seccomp.c                    |  118 +++--
 net/core/filter.c                   |  806 ++++++++++++++++++++++++++++++++++-
 net/core/sysctl_net_core.c          |    7 +
 13 files changed, 1077 insertions(+), 101 deletions(-)

-- 
1.7.9.5
