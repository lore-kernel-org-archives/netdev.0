From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the limits tree with the net and
 fsnotify trees
Date: Fri, 4 Dec 2009 18:30:11 +1100
Message-ID: <20091204183011.e92d36cd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Paris <eparis@redhat.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753060AbZLDHaJ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

Today's linux-next merge of the limits tree got a conflicts in
arch/x86/ia32/ia32entry.S, arch/x86/include/asm/unistd_32.h,
arch/x86/include/asm/unistd_64.h and arch/x86/kernel/syscall_table_32.S
between commit d1aa01854fcc8d9a18b5f8c6157598e4d424b9bf ("net: Introduce
recvmmsg socket syscall") from the net tree, commits
983683d94706c7fe7cd8dfd5758785aeaa39fc99 ("fanotify: fanotify_init
syscall declaration") and 38e1455e9d4d7da01fd0668d901b5559172c543e
("fanotify: sys_fanotify_mark declartion") from the fsnotify and commits
28afb4bdc052fe881f73599c1d86670d26888054 ("x86: add ia32 compat prlimit
syscalls") and 41257e5a12e196e1b7859d1a36094c05c6fcdcec ("unistd: add
__NR_[get|set]prlimit syscall numbers") from the limits tree.

Just overlapping additions.  I fixed it up (see below - this involved
renumbering tow of the syscalls) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/x86/ia32/ia32entry.S
index da89ae1,c61ced2..0000000
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@@ -841,7 -841,6 +841,9 @@@ ia32_sys_call_table
  	.quad compat_sys_pwritev
  	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
  	.quad sys_perf_event_open
 +	.quad compat_sys_recvmmsg
 +	.quad sys_fanotify_init
 +	.quad sys32_fanotify_mark
+ 	.quad compat_sys_getprlimit
+ 	.quad compat_sys_setprlimit
  ia32_syscall_end:
diff --cc arch/x86/include/asm/unistd_32.h
index cf70e9e,06dbb34..0000000
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@@ -342,13 -342,12 +342,15 @@@
  #define __NR_pwritev		334
  #define __NR_rt_tgsigqueueinfo	335
  #define __NR_perf_event_open	336
 -#define __NR_getprlimit		337
 -#define __NR_setprlimit		338
 +#define __NR_recvmmsg		337
 +#define __NR_fanotify_init	338
 +#define __NR_fanotify_mark	339
++#define __NR_getprlimit		340
++#define __NR_setprlimit		341
  
  #ifdef __KERNEL__
  
- #define NR_syscalls 340
 -#define NR_syscalls 339
++#define NR_syscalls 342
  
  #define __ARCH_WANT_IPC_PARSE_VERSION
  #define __ARCH_WANT_OLD_READDIR
diff --cc arch/x86/include/asm/unistd_64.h
index 7fbd20f,48ea56c..0000000
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@@ -661,12 -661,10 +661,16 @@@ __SYSCALL(__NR_pwritev, sys_pwritev
  __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
  #define __NR_perf_event_open			298
  __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 -#define __NR_getprlimit				299
 +#define __NR_recvmmsg				299
 +__SYSCALL(__NR_recvmmsg, sys_recvmmsg)
 +#define __NR_fanotify_init			300
 +__SYSCALL(__NR_fanotify_init, sys_fanotify_init)
 +#define __NR_fanotify_mark			301
 +__SYSCALL(__NR_fanotify_mark, sys_fanotify_mark)
++#define __NR_getprlimit				302
+ __SYSCALL(__NR_getprlimit, sys_getprlimit)
 -#define __NR_setprlimit				300
++#define __NR_setprlimit				303
+ __SYSCALL(__NR_setprlimit, sys_setprlimit)
  
  #ifndef __NO_STUBS
  #define __ARCH_WANT_OLD_READDIR
diff --cc arch/x86/kernel/syscall_table_32.S
index ca486c7,2dd45cd..0000000
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@@ -336,6 -336,5 +336,8 @@@ ENTRY(sys_call_table
  	.long sys_pwritev
  	.long sys_rt_tgsigqueueinfo	/* 335 */
  	.long sys_perf_event_open
 +	.long sys_recvmmsg
 +	.long sys_fanotify_init
 +	.long sys_fanotify_mark
+ 	.long sys_getprlimit
+ 	.long sys_setprlimit
