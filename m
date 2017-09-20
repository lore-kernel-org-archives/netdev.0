From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 29/31] arm: Implement thread_struct whitelist for hardened usercopy
Date: Wed, 20 Sep 2017 13:45:35 -0700
Message-ID: <1505940337-79069-30-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
	Russell King <linux@armlinux.org.uk>,
	Ingo Molnar <mingo@kernel.org>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-mm@kvack.org,
	kernel-hardening@lists.openwall.com,
	David Windsor <dave@nullcore.net>
To: linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

ARM does not carry FPU state in the thread structure, so it can declare
no usercopy whitelist at all.

Cc: Russell King <linux@armlinux.org.uk>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: linux-arm-kernel@lists.infradead.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/Kconfig                 | 1 +
 arch/arm/include/asm/processor.h | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 7888c9803eb0..4f1ab6c6b8c0 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -48,6 +48,7 @@ config ARM
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32 && MMU
 	select HAVE_ARCH_MMAP_RND_BITS if MMU
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
+	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARM_SMCCC if CPU_V7
 	select HAVE_EBPF_JIT if !CPU_ENDIAN_BE32
diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
index c3d5fc124a05..d6dc45c92ee5 100644
--- a/arch/arm/include/asm/processor.h
+++ b/arch/arm/include/asm/processor.h
@@ -45,6 +45,13 @@ struct thread_struct {
 	struct debug_info	debug;
 };
 
+/* Nothing needs to be usercopy-whitelisted from thread_struct. */
+static inline void arch_thread_struct_whitelist(unsigned long *offset,
+						unsigned long *size)
+{
+	*offset = *size = 0;
+}
+
 #define INIT_THREAD  {	}
 
 #ifdef CONFIG_MMU
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
