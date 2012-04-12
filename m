From: Will Drewry <wad@chromium.org>
Subject: [PATCH v18 06/15] asm/syscall.h: add syscall_get_arch
Date: Thu, 12 Apr 2012 16:47:55 -0500
Message-ID: <1334267284-19166-6-git-send-email-wad@chromium.org>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
Cc: linux-man@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	jmorris@namei.org, Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1334267284-19166-1-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a stub for a function that will return the AUDIT_ARCH_* value
appropriate to the supplied task based on the system call convention.

For audit's use, the value can generally be hard-coded at the
audit-site.  However, for other functionality not inlined into syscall
entry/exit, this makes that information available.  seccomp_filter is
the first planned consumer and, as such, the comment indicates a tie to
CONFIG_HAVE_ARCH_SECCOMP_FILTER.

Suggested-by: Roland McGrath <mcgrathr@chromium.org>
Signed-off-by: Will Drewry <wad@chromium.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Acked-by: Eric Paris <eparis@redhat.com>

v18: comment and change reword and rebase.
v14: rebase/nochanges
v13: rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
v12: rebase on to linux-next
v11: fixed improper return type
v10: introduced
---
 include/asm-generic/syscall.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/syscall.h b/include/asm-generic/syscall.h
index 5c122ae..5b09392 100644
--- a/include/asm-generic/syscall.h
+++ b/include/asm-generic/syscall.h
@@ -142,4 +142,18 @@ void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 			   unsigned int i, unsigned int n,
 			   const unsigned long *args);
 
+/**
+ * syscall_get_arch - return the AUDIT_ARCH for the current system call
+ * @task:	task of interest, must be in system call entry tracing
+ * @regs:	task_pt_regs() of @task
+ *
+ * Returns the AUDIT_ARCH_* based on the system call convention in use.
+ *
+ * It's only valid to call this when @task is stopped on entry to a system
+ * call, due to %TIF_SYSCALL_TRACE, %TIF_SYSCALL_AUDIT, or %TIF_SECCOMP.
+ *
+ * Architectures which permit CONFIG_HAVE_ARCH_SECCOMP_FILTER must
+ * provide an implementation of this.
+ */
+int syscall_get_arch(struct task_struct *task, struct pt_regs *regs);
 #endif	/* _ASM_SYSCALL_H */
-- 
1.7.5.4
