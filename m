From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v6 net-next 4/6] bpf: enable bpf syscall on x64 and i386
Date: Mon, 25 Aug 2014 18:00:56 -0700
Message-ID: <1409014858-1410-5-git-send-email-ast@plumgrid.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

done as separate commit to ease conflict resolution

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/syscalls/syscall_32.tbl  |    1 +
 arch/x86/syscalls/syscall_64.tbl  |    1 +
 include/linux/syscalls.h          |    3 ++-
 include/uapi/asm-generic/unistd.h |    4 +++-
 kernel/sys_ni.c                   |    3 +++
 5 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index 028b78168d85..9fe1b5d002f0 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -363,3 +363,4 @@
 354	i386	seccomp			sys_seccomp
 355	i386	getrandom		sys_getrandom
 356	i386	memfd_create		sys_memfd_create
+357	i386	bpf			sys_bpf
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 35dd922727b9..281150b539a2 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -327,6 +327,7 @@
 318	common	getrandom		sys_getrandom
 319	common	memfd_create		sys_memfd_create
 320	common	kexec_file_load		sys_kexec_file_load
+321	common	bpf			sys_bpf
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0f86d85a9ce4..61bc112b9fa5 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -875,5 +875,6 @@ asmlinkage long sys_seccomp(unsigned int op, unsigned int flags,
 			    const char __user *uargs);
 asmlinkage long sys_getrandom(char __user *buf, size_t count,
 			      unsigned int flags);
-
+asmlinkage long sys_bpf(int cmd, unsigned long arg2, unsigned long arg3,
+			unsigned long arg4, unsigned long arg5);
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 11d11bc5c78f..22749c134117 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -705,9 +705,11 @@ __SYSCALL(__NR_seccomp, sys_seccomp)
 __SYSCALL(__NR_getrandom, sys_getrandom)
 #define __NR_memfd_create 279
 __SYSCALL(__NR_memfd_create, sys_memfd_create)
+#define __NR_bpf 280
+__SYSCALL(__NR_bpf, sys_bpf)
 
 #undef __NR_syscalls
-#define __NR_syscalls 280
+#define __NR_syscalls 281
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 391d4ddb6f4b..b4b5083f5f5e 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -218,3 +218,6 @@ cond_syscall(sys_kcmp);
 
 /* operate on Secure Computing state */
 cond_syscall(sys_seccomp);
+
+/* access BPF programs and maps */
+cond_syscall(sys_bpf);
-- 
1.7.9.5
