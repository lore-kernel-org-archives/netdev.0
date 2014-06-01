From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/2] split BPF out of core networking
Date: Sat, 31 May 2014 18:42:19 -0700
Message-ID: <1401586941-4274-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set splits BPF out of core networking into generic component

patch #1 splits filter.c into two logical pieces: generic BPF core and socket
filters. It only moves functions around. No real changes.

patch #2 adds hidden CONFIG_BPF that seccomp/tracing can select

the split was proposed in the previous thread:
http://article.gmane.org/gmane.linux.network/316050

The main value of the patch is not a NET separation, but rather logical boundary
between generic BPF core and socket filtering. All socket specific code stays in
net/core/filter.c and net/bpf/core.c is for generic BPF infrastructure (both
classic and internal).

Note that CONFIG_BPF_JIT is still under NET, so NET-less configs cannot use
BPF JITs yet. This can be cleaned up in the future. Also it seems to makes sense
to split up filter.h into generic and socket specific as well to cleanup the
boundary further.

The patches are on top of Daniel's cleanup to minimize conflicts:
http://patchwork.ozlabs.org/patch/353700/
http://patchwork.ozlabs.org/patch/353699/

Unfortunately they conflict with Chema's patches which in turn conflict
with Daniel's. But since Daniel got in the queue first, I've rebased mine
on top of Daniel's.

Tested with several NET and NET-less configs on arm and x86

Alexei Starovoitov (2):
  net: filter: split filter.c into two files
  net: filter: split BPF out of core networking

 arch/Kconfig           |    3 +-
 include/linux/filter.h |    2 +
 net/Kconfig            |    4 +
 net/Makefile           |    1 +
 net/bpf/Makefile       |    5 +
 net/bpf/core.c         | 1063 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c      | 1023 +---------------------------------------------
 7 files changed, 1079 insertions(+), 1022 deletions(-)
 create mode 100644 net/bpf/Makefile
 create mode 100644 net/bpf/core.c

-- 
1.7.9.5
