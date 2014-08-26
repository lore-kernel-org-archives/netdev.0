From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v6 net-next 0/6] introduce BPF syscall
Date: Mon, 25 Aug 2014 18:00:52 -0700
Message-ID: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

splitting big set of patches into smaller sets:

1st(this) set - introduces uapi/linux/bpf.h and BPF syscall for maps only
2nd set will extend BPF syscall with programs and verifier
3rd set will use eBPF in tracing, add samples and verifier tests
4th set will have llvm and C examples

Tested on x64 and i386.
BPF syscall with maps only is usable, but not very useful until the rest comes
Build/boot tested on arm and sparc.
They got new warning 'syscall bpf not implemented'

V5->V6:
- fixed few checkpatch warnings.
  Few lines are still over 80 char, but fixing them will reduce readability
- rebased

V5 thread:
https://lkml.org/lkml/2014/8/24/107

All patches:
git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

Alexei Starovoitov (6):
  net: filter: add "load 64-bit immediate" eBPF instruction
  net: filter: split filter.h and expose eBPF to user space
  bpf: introduce syscall(BPF, ...) and BPF maps
  bpf: enable bpf syscall on x64 and i386
  bpf: add lookup/update/delete/iterate methods to BPF maps
  bpf: add hashtable type of BPF maps

 Documentation/networking/filter.txt |   79 +++++++-
 arch/x86/net/bpf_jit_comp.c         |   17 ++
 arch/x86/syscalls/syscall_32.tbl    |    1 +
 arch/x86/syscalls/syscall_64.tbl    |    1 +
 include/linux/bpf.h                 |   50 +++++
 include/linux/filter.h              |  294 +--------------------------
 include/linux/syscalls.h            |    3 +-
 include/uapi/asm-generic/unistd.h   |    4 +-
 include/uapi/linux/Kbuild           |    1 +
 include/uapi/linux/bpf.h            |  371 ++++++++++++++++++++++++++++++++++
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/core.c                   |    5 +
 kernel/bpf/hashtab.c                |  373 +++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c                |  354 +++++++++++++++++++++++++++++++++
 kernel/sys_ni.c                     |    3 +
 lib/test_bpf.c                      |   21 ++
 16 files changed, 1282 insertions(+), 297 deletions(-)
 create mode 100644 include/linux/bpf.h
 create mode 100644 include/uapi/linux/bpf.h
 create mode 100644 kernel/bpf/hashtab.c
 create mode 100644 kernel/bpf/syscall.c

-- 
1.7.9.5
