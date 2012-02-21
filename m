From: Will Drewry <wad@chromium.org>
Subject: [PATCH v11 03/11] asm/syscall.h: add syscall_get_arch
Date: Tue, 21 Feb 2012 13:01:58 -0600
Message-ID: <1329850918-4899-1-git-send-email-wad@chromium.org>
References: <CAB=4xhp6y7Pq7mTF228TdyA-_z2j5z1yEnFrNQrFr7M9BZQ1Fg@mail.gmail.com>
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAB=4xhp6y7Pq7mTF228TdyA-_z2j5z1yEnFrNQrFr7M9BZQ1Fg@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a stub for a function that will return the AUDIT_ARCH_*
value appropriate to the supplied task based on the system
call convention.

For audit's use, the value can generally be hard-coded at the
audit-site.  However, for other functionality not inlined into
syscall entry/exit, this makes that information available.
seccomp_filter is the first planned consumer and, as such,
the comment indicates a tie to HAVE_ARCH_SECCOMP_FILTER.  That
is probably an unneeded detail.

Suggested-by: Roland McGrath <mcgrathr@chromium.org>
Signed-off-by: Will Drewry <wad@chromium.org>

v11: fixed improper return type
v10: introduced
---
 include/asm-generic/syscall.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/syscall.h b/include/asm-generic/syscall.h
index 5c122ae..a2c13dc 100644
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
+ * Note, at present this function is only required with
+ * CONFIG_HAVE_ARCH_SECCOMP_FILTER.
+ */
+int syscall_get_arch(struct task_struct *task, struct pt_regs *regs);
 #endif	/* _ASM_SYSCALL_H */
-- 
1.7.5.4

