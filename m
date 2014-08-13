From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 04/26] bpf: enable bpf syscall on x64
Date: Wed, 13 Aug 2014 00:57:15 -0700
Message-ID: <1407916658-8731-5-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

done as separate commit to ease conflict resolution

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/syscalls/syscall_64.tbl  |    1 +
 include/linux/syscalls.h          |    3 ++-
 include/uapi/asm-generic/unistd.h |    4 +++-
 kernel/sys_ni.c                   |    3 +++
 4 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 252c804bb1aa..1416e32f20f1 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -325,6 +325,7 @@
 316	common	renameat2		sys_renameat2
 317	common	seccomp			sys_seccomp
 318	common	getrandom		sys_getrandom
+319	common	bpf			sys_bpf
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 701daff5d899..cc2e197e0875 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -870,5 +870,6 @@ asmlinkage long sys_seccomp(unsigned int op, unsigned int flags,
 			    const char __user *uargs);
 asmlinkage long sys_getrandom(char __user *buf, size_t count,
 			      unsigned int flags);
-
+asmlinkage long sys_bpf(int cmd, unsigned long arg2, unsigned long arg3,
+			unsigned long arg4, unsigned long arg5);
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index f1afd607f043..3b625b281804 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -703,9 +703,11 @@ __SYSCALL(__NR_renameat2, sys_renameat2)
 __SYSCALL(__NR_seccomp, sys_seccomp)
 #define __NR_getrandom 278
 __SYSCALL(__NR_getrandom, sys_getrandom)
+#define __NR_bpf 279
+__SYSCALL(__NR_bpf, sys_bpf)
 
 #undef __NR_syscalls
-#define __NR_syscalls 279
+#define __NR_syscalls 280
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 2904a2105914..d67ab4e618f7 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -216,3 +216,6 @@ cond_syscall(sys_kcmp);
 
 /* operate on Secure Computing state */
 cond_syscall(sys_seccomp);
+
+/* access BPF programs and maps */
+cond_syscall(sys_bpf);
-- 
1.7.9.5
