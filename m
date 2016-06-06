From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH] tree-wide: replace config_enabled() with IS_ENABLED()
Date: Mon,  6 Jun 2016 21:20:56 +0900
Message-ID: <1465215656-20569-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org,
 =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
 David Daney <david.daney@cavium.com>, Peter Zijlstra <peterz@infradead.org>,
 linux-pci@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Alexei Starovoitov <ast@kernel.org>, dri-devel@lists.freedesktop.org,
 "Dmitry V. Levin" <ldv@altlinux.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kalle Valo <kvalo@qca.qualcomm.com>, Viresh Kumar <viresh.kumar@linaro.org>,
 "H. Peter Anvin" <hpa@zytor.com>, Huacai Chen <chenhc@lemote.com>,
 Andrea Gelmini <andrea.gelmini@gelma.net>,
 Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>,
 Sumit Semwal <sumit.semwal@linaro.org>, Jason Cooper <jason@lakedaemon.net>,
 "Maciej W. Rozycki" <macro@imgtec.com>, Huaitong Han <huaitong.han@intel.com>,
 Denys Vlasenko <dvlasenk@redhat.com>,
 "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
 Daniel Borkmann
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The use of config_enabled() against config options is ambiguous.
In practical terms, config_enabled() is equivalent to IS_BUILTIN(),
but the author might have used it for the meaning of IS_ENABLED().
Using IS_ENABLED(), IS_BUILTIN(), IS_MODULE() etc. makes the
intention clearer.

This commit replaces config_enabled() with IS_ENABLED() where
possible.  This commit is only touching bool config options.

I noticed two cases where config_enabled() is used against a tristate
option:

 - config_enabled(CONFIG_HWMON)
  [ drivers/net/wireless/ath/ath10k/thermal.c ]

 - config_enabled(CONFIG_BACKLIGHT_CLASS_DEVICE)
  [ drivers/gpu/drm/gma500/opregion.c ]

I did not touch them because they should be converted to IS_BUILTIN()
in order to keep the logic, but I was not sure it was the authors'
intention.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 arch/mips/include/asm/mips-cm.h                  |  2 +-
 arch/mips/include/asm/pgtable.h                  | 16 +++++------
 arch/mips/include/asm/seccomp.h                  |  4 +--
 arch/mips/include/asm/signal.h                   |  4 +--
 arch/mips/include/asm/syscall.h                  |  2 +-
 arch/mips/include/asm/uaccess.h                  |  2 +-
 arch/mips/jz4740/setup.c                         |  2 +-
 arch/mips/kernel/cpu-bugs64.c                    |  6 ++---
 arch/mips/kernel/elf.c                           |  4 +--
 arch/mips/kernel/mips-cm.c                       |  2 +-
 arch/mips/kernel/mips-r2-to-r6-emul.c            | 34 ++++++++++++------------
 arch/mips/kernel/pm-cps.c                        |  4 +--
 arch/mips/kernel/signal.c                        | 10 +++----
 arch/mips/kernel/smp-cps.c                       |  4 +--
 arch/mips/kernel/unaligned.c                     | 10 +++----
 arch/mips/math-emu/cp1emu.c                      |  6 ++---
 arch/mips/mm/tlbex.c                             | 10 +++----
 arch/mips/mti-malta/malta-dtshim.c               |  4 +--
 arch/mips/mti-malta/malta-memory.c               |  2 +-
 arch/mips/mti-malta/malta-setup.c                |  2 +-
 arch/mips/net/bpf_jit.c                          |  4 +--
 arch/x86/include/asm/elf.h                       |  4 +--
 arch/x86/include/asm/fpu/internal.h              | 16 +++++------
 arch/x86/include/asm/mmu_context.h               |  2 +-
 arch/x86/kernel/apic/apic.c                      |  2 +-
 arch/x86/kernel/apic/vector.c                    |  2 +-
 arch/x86/kernel/fpu/signal.c                     | 12 ++++-----
 arch/x86/kernel/signal.c                         | 14 +++++-----
 drivers/firmware/broadcom/bcm47xx_sprom.c        |  2 +-
 drivers/irqchip/irq-mips-gic.c                   |  2 +-
 drivers/mtd/bcm47xxpart.c                        |  2 +-
 drivers/net/wireless/ath/ath10k/debug.c          | 12 ++++-----
 drivers/net/wireless/ath/ath10k/mac.c            | 10 +++----
 drivers/net/wireless/ath/ath10k/wmi.c            |  2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c       |  2 +-
 drivers/net/wireless/ath/ath9k/common-spectral.c |  6 ++---
 drivers/net/wireless/ath/ath9k/init.c            |  2 +-
 drivers/net/wireless/ath/ath9k/main.c            | 12 ++++-----
 drivers/net/wireless/ath/ath9k/recv.c            |  2 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c  |  2 +-
 drivers/net/wireless/ath/regd.c                  |  4 +--
 drivers/pci/ecam.c                               |  2 +-
 drivers/tty/serial/ar933x_uart.c                 |  4 +--
 include/linux/fence.h                            |  2 +-
 include/linux/ww_mutex.h                         |  4 +--
 kernel/ptrace.c                                  |  4 +--
 kernel/seccomp.c                                 |  6 ++---
 net/wireless/chan.c                              |  2 +-
 48 files changed, 135 insertions(+), 135 deletions(-)

diff --git a/arch/mips/include/asm/mips-cm.h b/arch/mips/include/asm/mips-cm.h
index 9411a4c..58e7874 100644
--- a/arch/mips/include/asm/mips-cm.h
+++ b/arch/mips/include/asm/mips-cm.h
@@ -462,7 +462,7 @@ static inline unsigned int mips_cm_max_vp_width(void)
 	if (mips_cm_revision() >= CM_REV_CM3)
 		return read_gcr_sys_config2() & CM_GCR_SYS_CONFIG2_MAXVPW_MSK;
 
-	if (config_enabled(CONFIG_SMP))
+	if (IS_ENABLED(CONFIG_SMP))
 		return smp_num_siblings;
 
 	return 1;
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index a6b611f..ec5c730 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -159,7 +159,7 @@ static inline void set_pte(pte_t *ptep, pte_t pte)
 		 * it better already be global)
 		 */
 		if (pte_none(*buddy)) {
-			if (!config_enabled(CONFIG_XPA))
+			if (!IS_ENABLED(CONFIG_XPA))
 				buddy->pte_low |= _PAGE_GLOBAL;
 			buddy->pte_high |= _PAGE_GLOBAL;
 		}
@@ -172,7 +172,7 @@ static inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *pt
 
 	htw_stop();
 	/* Preserve global status for the pair */
-	if (config_enabled(CONFIG_XPA)) {
+	if (IS_ENABLED(CONFIG_XPA)) {
 		if (ptep_buddy(ptep)->pte_high & _PAGE_GLOBAL)
 			null.pte_high = _PAGE_GLOBAL;
 	} else {
@@ -319,7 +319,7 @@ static inline int pte_young(pte_t pte)	{ return pte.pte_low & _PAGE_ACCESSED; }
 static inline pte_t pte_wrprotect(pte_t pte)
 {
 	pte.pte_low  &= ~_PAGE_WRITE;
-	if (!config_enabled(CONFIG_XPA))
+	if (!IS_ENABLED(CONFIG_XPA))
 		pte.pte_low &= ~_PAGE_SILENT_WRITE;
 	pte.pte_high &= ~_PAGE_SILENT_WRITE;
 	return pte;
@@ -328,7 +328,7 @@ static inline pte_t pte_wrprotect(pte_t pte)
 static inline pte_t pte_mkclean(pte_t pte)
 {
 	pte.pte_low  &= ~_PAGE_MODIFIED;
-	if (!config_enabled(CONFIG_XPA))
+	if (!IS_ENABLED(CONFIG_XPA))
 		pte.pte_low &= ~_PAGE_SILENT_WRITE;
 	pte.pte_high &= ~_PAGE_SILENT_WRITE;
 	return pte;
@@ -337,7 +337,7 @@ static inline pte_t pte_mkclean(pte_t pte)
 static inline pte_t pte_mkold(pte_t pte)
 {
 	pte.pte_low  &= ~_PAGE_ACCESSED;
-	if (!config_enabled(CONFIG_XPA))
+	if (!IS_ENABLED(CONFIG_XPA))
 		pte.pte_low &= ~_PAGE_SILENT_READ;
 	pte.pte_high &= ~_PAGE_SILENT_READ;
 	return pte;
@@ -347,7 +347,7 @@ static inline pte_t pte_mkwrite(pte_t pte)
 {
 	pte.pte_low |= _PAGE_WRITE;
 	if (pte.pte_low & _PAGE_MODIFIED) {
-		if (!config_enabled(CONFIG_XPA))
+		if (!IS_ENABLED(CONFIG_XPA))
 			pte.pte_low |= _PAGE_SILENT_WRITE;
 		pte.pte_high |= _PAGE_SILENT_WRITE;
 	}
@@ -358,7 +358,7 @@ static inline pte_t pte_mkdirty(pte_t pte)
 {
 	pte.pte_low |= _PAGE_MODIFIED;
 	if (pte.pte_low & _PAGE_WRITE) {
-		if (!config_enabled(CONFIG_XPA))
+		if (!IS_ENABLED(CONFIG_XPA))
 			pte.pte_low |= _PAGE_SILENT_WRITE;
 		pte.pte_high |= _PAGE_SILENT_WRITE;
 	}
@@ -369,7 +369,7 @@ static inline pte_t pte_mkyoung(pte_t pte)
 {
 	pte.pte_low |= _PAGE_ACCESSED;
 	if (!(pte.pte_low & _PAGE_NO_READ)) {
-		if (!config_enabled(CONFIG_XPA))
+		if (!IS_ENABLED(CONFIG_XPA))
 			pte.pte_low |= _PAGE_SILENT_READ;
 		pte.pte_high |= _PAGE_SILENT_READ;
 	}
diff --git a/arch/mips/include/asm/seccomp.h b/arch/mips/include/asm/seccomp.h
index 684fb3a..d886d6f 100644
--- a/arch/mips/include/asm/seccomp.h
+++ b/arch/mips/include/asm/seccomp.h
@@ -16,10 +16,10 @@ static inline const int *get_compat_mode1_syscalls(void)
 		0, /* null terminated */
 	};
 
-	if (config_enabled(CONFIG_MIPS32_O32) && test_thread_flag(TIF_32BIT_REGS))
+	if (IS_ENABLED(CONFIG_MIPS32_O32) && test_thread_flag(TIF_32BIT_REGS))
 		return syscalls_O32;
 
-	if (config_enabled(CONFIG_MIPS32_N32))
+	if (IS_ENABLED(CONFIG_MIPS32_N32))
 		return syscalls_N32;
 
 	BUG();
diff --git a/arch/mips/include/asm/signal.h b/arch/mips/include/asm/signal.h
index 2292373..82eae15 100644
--- a/arch/mips/include/asm/signal.h
+++ b/arch/mips/include/asm/signal.h
@@ -19,8 +19,8 @@ extern struct mips_abi mips_abi_32;
 		((ka)->sa.sa_flags & SA_SIGINFO))
 #else
 #define sig_uses_siginfo(ka, abi)                               \
-	(config_enabled(CONFIG_64BIT) ? 1 :                     \
-		(config_enabled(CONFIG_TRAD_SIGNALS) ?          \
+	(IS_ENABLED(CONFIG_64BIT) ? 1 :                     \
+		(IS_ENABLED(CONFIG_TRAD_SIGNALS) ?          \
 			((ka)->sa.sa_flags & SA_SIGINFO) : 1) )
 #endif
 
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index 47bc45a..d878825 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -99,7 +99,7 @@ static inline void syscall_get_arguments(struct task_struct *task,
 {
 	int ret;
 	/* O32 ABI syscall() - Either 64-bit with O32 or 32-bit */
-	if ((config_enabled(CONFIG_32BIT) ||
+	if ((IS_ENABLED(CONFIG_32BIT) ||
 	    test_tsk_thread_flag(task, TIF_32BIT_REGS)) &&
 	    (regs->regs[2] == __NR_syscall))
 		i++;
diff --git a/arch/mips/include/asm/uaccess.h b/arch/mips/include/asm/uaccess.h
index 7f109d4..11b965f 100644
--- a/arch/mips/include/asm/uaccess.h
+++ b/arch/mips/include/asm/uaccess.h
@@ -88,7 +88,7 @@ extern u64 __ua_limit;
  */
 static inline bool eva_kernel_access(void)
 {
-	if (!config_enabled(CONFIG_EVA))
+	if (!IS_ENABLED(CONFIG_EVA))
 		return false;
 
 	return segment_eq(get_fs(), get_ds());
diff --git a/arch/mips/jz4740/setup.c b/arch/mips/jz4740/setup.c
index 510fc0d..e53f90b 100644
--- a/arch/mips/jz4740/setup.c
+++ b/arch/mips/jz4740/setup.c
@@ -83,7 +83,7 @@ arch_initcall(populate_machine);
 
 const char *get_system_type(void)
 {
-	if (config_enabled(CONFIG_MACH_JZ4780))
+	if (IS_ENABLED(CONFIG_MACH_JZ4780))
 		return "JZ4780";
 
 	return "JZ4740";
diff --git a/arch/mips/kernel/cpu-bugs64.c b/arch/mips/kernel/cpu-bugs64.c
index 6392dbe..a378e44 100644
--- a/arch/mips/kernel/cpu-bugs64.c
+++ b/arch/mips/kernel/cpu-bugs64.c
@@ -244,7 +244,7 @@ static inline void check_daddi(void)
 	panic(bug64hit, !DADDI_WAR ? daddiwar : nowar);
 }
 
-int daddiu_bug	= config_enabled(CONFIG_CPU_MIPSR6) ? 0 : -1;
+int daddiu_bug	= IS_ENABLED(CONFIG_CPU_MIPSR6) ? 0 : -1;
 
 static inline void check_daddiu(void)
 {
@@ -314,7 +314,7 @@ static inline void check_daddiu(void)
 
 void __init check_bugs64_early(void)
 {
-	if (!config_enabled(CONFIG_CPU_MIPSR6)) {
+	if (!IS_ENABLED(CONFIG_CPU_MIPSR6)) {
 		check_mult_sh();
 		check_daddiu();
 	}
@@ -322,6 +322,6 @@ void __init check_bugs64_early(void)
 
 void __init check_bugs64(void)
 {
-	if (!config_enabled(CONFIG_CPU_MIPSR6))
+	if (!IS_ENABLED(CONFIG_CPU_MIPSR6))
 		check_daddi();
 }
diff --git a/arch/mips/kernel/elf.c b/arch/mips/kernel/elf.c
index 891f5ee..e6eb7f1 100644
--- a/arch/mips/kernel/elf.c
+++ b/arch/mips/kernel/elf.c
@@ -179,7 +179,7 @@ int arch_check_elf(void *_ehdr, bool has_interpreter, void *_interp_ehdr,
 			return -ELIBBAD;
 	}
 
-	if (!config_enabled(CONFIG_MIPS_O32_FP64_SUPPORT))
+	if (!IS_ENABLED(CONFIG_MIPS_O32_FP64_SUPPORT))
 		return 0;
 
 	fp_abi = state->fp_abi;
@@ -285,7 +285,7 @@ void mips_set_personality_fp(struct arch_elf_state *state)
 	 * not be worried about N32/N64 binaries.
 	 */
 
-	if (!config_enabled(CONFIG_MIPS_O32_FP64_SUPPORT))
+	if (!IS_ENABLED(CONFIG_MIPS_O32_FP64_SUPPORT))
 		return;
 
 	switch (state->overall_fp_mode) {
diff --git a/arch/mips/kernel/mips-cm.c b/arch/mips/kernel/mips-cm.c
index 760217b..659e6d3 100644
--- a/arch/mips/kernel/mips-cm.c
+++ b/arch/mips/kernel/mips-cm.c
@@ -251,7 +251,7 @@ int mips_cm_probe(void)
 	mips_cm_probe_l2sync();
 
 	/* determine register width for this CM */
-	mips_cm_is64 = config_enabled(CONFIG_64BIT) && (mips_cm_revision() >= CM_REV_CM3);
+	mips_cm_is64 = IS_ENABLED(CONFIG_64BIT) && (mips_cm_revision() >= CM_REV_CM3);
 
 	for_each_possible_cpu(cpu)
 		spin_lock_init(&per_cpu(cm_core_lock, cpu));
diff --git a/arch/mips/kernel/mips-r2-to-r6-emul.c b/arch/mips/kernel/mips-r2-to-r6-emul.c
index 7ff2a55..43fbadc 100644
--- a/arch/mips/kernel/mips-r2-to-r6-emul.c
+++ b/arch/mips/kernel/mips-r2-to-r6-emul.c
@@ -84,7 +84,7 @@ static inline int mipsr6_emul(struct pt_regs *regs, u32 ir)
 				(s32)MIPSInst_SIMM(ir);
 		return 0;
 	case daddiu_op:
-		if (config_enabled(CONFIG_32BIT))
+		if (IS_ENABLED(CONFIG_32BIT))
 			break;
 
 		if (MIPSInst_RT(ir))
@@ -143,7 +143,7 @@ static inline int mipsr6_emul(struct pt_regs *regs, u32 ir)
 					      (u32)regs->regs[MIPSInst_RT(ir)]);
 			return 0;
 		case dsll_op:
-			if (config_enabled(CONFIG_32BIT) || MIPSInst_RS(ir))
+			if (IS_ENABLED(CONFIG_32BIT) || MIPSInst_RS(ir))
 				break;
 
 			if (MIPSInst_RD(ir))
@@ -152,7 +152,7 @@ static inline int mipsr6_emul(struct pt_regs *regs, u32 ir)
 						MIPSInst_FD(ir));
 			return 0;
 		case dsrl_op:
-			if (config_enabled(CONFIG_32BIT) || MIPSInst_RS(ir))
+			if (IS_ENABLED(CONFIG_32BIT) || MIPSInst_RS(ir))
 				break;
 
 			if (MIPSInst_RD(ir))
@@ -161,7 +161,7 @@ static inline int mipsr6_emul(struct pt_regs *regs, u32 ir)
 						MIPSInst_FD(ir));
 			return 0;
 		case daddu_op:
-			if (config_enabled(CONFIG_32BIT) || MIPSInst_FD(ir))
+			if (IS_ENABLED(CONFIG_32BIT) || MIPSInst_FD(ir))
 				break;
 
 			if (MIPSInst_RD(ir))
@@ -170,7 +170,7 @@ static inline int mipsr6_emul(struct pt_regs *regs, u32 ir)
 					(u64)regs->regs[MIPSInst_RT(ir)];
 			return 0;
 		case dsubu_op:
-			if (config_enabled(CONFIG_32BIT) || MIPSInst_FD(ir))
+			if (IS_ENABLED(CONFIG_32BIT) || MIPSInst_FD(ir))
 				break;
 
 			if (MIPSInst_RD(ir))
@@ -498,7 +498,7 @@ static int dmult_func(struct pt_regs *regs, u32 ir)
 	s64 res;
 	s64 rt, rs;
 
-	if (config_enabled(CONFIG_32BIT))
+	if (IS_ENABLED(CONFIG_32BIT))
 		return SIGILL;
 
 	rt = regs->regs[MIPSInst_RT(ir)];
@@ -530,7 +530,7 @@ static int dmultu_func(struct pt_regs *regs, u32 ir)
 	u64 res;
 	u64 rt, rs;
 
-	if (config_enabled(CONFIG_32BIT))
+	if (IS_ENABLED(CONFIG_32BIT))
 		return SIGILL;
 
 	rt = regs->regs[MIPSInst_RT(ir)];
@@ -561,7 +561,7 @@ static int ddiv_func(struct pt_regs *regs, u32 ir)
 {
 	s64 rt, rs;
 
-	if (config_enabled(CONFIG_32BIT))
+	if (IS_ENABLED(CONFIG_32BIT))
 		return SIGILL;
 
 	rt = regs->regs[MIPSInst_RT(ir)];
@@ -586,7 +586,7 @@ static int ddivu_func(struct pt_regs *regs, u32 ir)
 {
 	u64 rt, rs;
 
-	if (config_enabled(CONFIG_32BIT))
+	if (IS_ENABLED(CONFIG_32BIT))
 		return SIGILL;
 
 	rt = regs->regs[MIPSInst_RT(ir)];
@@ -825,7 +825,7 @@ static int dclz_func(struct pt_regs *regs, u32 ir)
 	u64 res;
 	u64 rs;
 
-	if (config_enabled(CONFIG_32BIT))
+	if (IS_ENABLED(CONFIG_32BIT))
 		return SIGILL;
 
 	if (!MIPSInst_RD(ir))
@@ -852,7 +852,7 @@ static int dclo_func(struct pt_regs *regs, u32 ir)
 	u64 res;
 	u64 rs;
 
-	if (config_enabled(CONFIG_32BIT))
+	if (IS_ENABLED(CONFIG_32BIT))
 		return SIGILL;
 
 	if (!MIPSInst_RD(ir))
@@ -1484,7 +1484,7 @@ fpu_emul:
 		break;
 
 	case ldl_op:
-		if (config_enabled(CONFIG_32BIT)) {
+		if (IS_ENABLED(CONFIG_32BIT)) {
 		    err = SIGILL;
 		    break;
 		}
@@ -1603,7 +1603,7 @@ fpu_emul:
 		break;
 
 	case ldr_op:
-		if (config_enabled(CONFIG_32BIT)) {
+		if (IS_ENABLED(CONFIG_32BIT)) {
 		    err = SIGILL;
 		    break;
 		}
@@ -1722,7 +1722,7 @@ fpu_emul:
 		break;
 
 	case sdl_op:
-		if (config_enabled(CONFIG_32BIT)) {
+		if (IS_ENABLED(CONFIG_32BIT)) {
 		    err = SIGILL;
 		    break;
 		}
@@ -1840,7 +1840,7 @@ fpu_emul:
 		break;
 
 	case sdr_op:
-		if (config_enabled(CONFIG_32BIT)) {
+		if (IS_ENABLED(CONFIG_32BIT)) {
 		    err = SIGILL;
 		    break;
 		}
@@ -2072,7 +2072,7 @@ fpu_emul:
 		break;
 
 	case lld_op:
-		if (config_enabled(CONFIG_32BIT)) {
+		if (IS_ENABLED(CONFIG_32BIT)) {
 		    err = SIGILL;
 		    break;
 		}
@@ -2133,7 +2133,7 @@ fpu_emul:
 		break;
 
 	case scd_op:
-		if (config_enabled(CONFIG_32BIT)) {
+		if (IS_ENABLED(CONFIG_32BIT)) {
 		    err = SIGILL;
 		    break;
 		}
diff --git a/arch/mips/kernel/pm-cps.c b/arch/mips/kernel/pm-cps.c
index adda3ff..5b31a94 100644
--- a/arch/mips/kernel/pm-cps.c
+++ b/arch/mips/kernel/pm-cps.c
@@ -148,7 +148,7 @@ int cps_pm_enter_state(enum cps_pm_state state)
 	}
 
 	/* Setup the VPE to run mips_cps_pm_restore when started again */
-	if (config_enabled(CONFIG_CPU_PM) && state == CPS_PM_POWER_GATED) {
+	if (IS_ENABLED(CONFIG_CPU_PM) && state == CPS_PM_POWER_GATED) {
 		/* Power gating relies upon CPS SMP */
 		if (!mips_cps_smp_in_use())
 			return -EINVAL;
@@ -387,7 +387,7 @@ static void * __init cps_gen_entry_code(unsigned cpu, enum cps_pm_state state)
 	memset(labels, 0, sizeof(labels));
 	memset(relocs, 0, sizeof(relocs));
 
-	if (config_enabled(CONFIG_CPU_PM) && state == CPS_PM_POWER_GATED) {
+	if (IS_ENABLED(CONFIG_CPU_PM) && state == CPS_PM_POWER_GATED) {
 		/* Power gating relies upon CPS SMP */
 		if (!mips_cps_smp_in_use())
 			goto out_err;
diff --git a/arch/mips/kernel/signal.c b/arch/mips/kernel/signal.c
index ae42314..1975cd2 100644
--- a/arch/mips/kernel/signal.c
+++ b/arch/mips/kernel/signal.c
@@ -165,7 +165,7 @@ static int save_msa_extcontext(void __user *buf)
 		 * should already have been done when handling scalar FP
 		 * context.
 		 */
-		BUG_ON(config_enabled(CONFIG_EVA));
+		BUG_ON(IS_ENABLED(CONFIG_EVA));
 
 		err = __put_user(read_msa_csr(), &msa->csr);
 		err |= _save_msa_all_upper(&msa->wr);
@@ -195,7 +195,7 @@ static int restore_msa_extcontext(void __user *buf, unsigned int size)
 	unsigned int csr;
 	int i, err;
 
-	if (!config_enabled(CONFIG_CPU_HAS_MSA))
+	if (!IS_ENABLED(CONFIG_CPU_HAS_MSA))
 		return SIGSYS;
 
 	if (size != sizeof(*msa))
@@ -215,7 +215,7 @@ static int restore_msa_extcontext(void __user *buf, unsigned int size)
 		 * scalar FP context, so FPU & MSA should have already been
 		 * disabled whilst handling scalar FP context.
 		 */
-		BUG_ON(config_enabled(CONFIG_EVA));
+		BUG_ON(IS_ENABLED(CONFIG_EVA));
 
 		write_msa_csr(csr);
 		err |= _restore_msa_all_upper(&msa->wr);
@@ -315,7 +315,7 @@ int protected_save_fp_context(void __user *sc)
 	 * EVA does not have userland equivalents of ldc1 or sdc1, so
 	 * save to the kernel FP context & copy that to userland below.
 	 */
-	if (config_enabled(CONFIG_EVA))
+	if (IS_ENABLED(CONFIG_EVA))
 		lose_fpu(1);
 
 	while (1) {
@@ -378,7 +378,7 @@ int protected_restore_fp_context(void __user *sc)
 	 * disable the FPU here such that the code below simply copies to
 	 * the kernel FP context.
 	 */
-	if (config_enabled(CONFIG_EVA))
+	if (IS_ENABLED(CONFIG_EVA))
 		lose_fpu(0);
 
 	while (1) {
diff --git a/arch/mips/kernel/smp-cps.c b/arch/mips/kernel/smp-cps.c
index 4ed36f2..05b3201 100644
--- a/arch/mips/kernel/smp-cps.c
+++ b/arch/mips/kernel/smp-cps.c
@@ -46,8 +46,8 @@ static unsigned core_vpe_count(unsigned core)
 	if (threads_disabled)
 		return 1;
 
-	if ((!config_enabled(CONFIG_MIPS_MT_SMP) || !cpu_has_mipsmt)
-		&& (!config_enabled(CONFIG_CPU_MIPSR6) || !cpu_has_vp))
+	if ((!IS_ENABLED(CONFIG_MIPS_MT_SMP) || !cpu_has_mipsmt)
+		&& (!IS_ENABLED(CONFIG_CPU_MIPSR6) || !cpu_has_vp))
 		return 1;
 
 	mips_cm_lock_other(core, 0);
diff --git a/arch/mips/kernel/unaligned.c b/arch/mips/kernel/unaligned.c
index 28b3af7..f1c308d 100644
--- a/arch/mips/kernel/unaligned.c
+++ b/arch/mips/kernel/unaligned.c
@@ -1025,7 +1025,7 @@ static void emulate_load_store_insn(struct pt_regs *regs,
 		if (!access_ok(VERIFY_READ, addr, 2))
 			goto sigbus;
 
-		if (config_enabled(CONFIG_EVA)) {
+		if (IS_ENABLED(CONFIG_EVA)) {
 			if (segment_eq(get_fs(), get_ds()))
 				LoadHW(addr, value, res);
 			else
@@ -1044,7 +1044,7 @@ static void emulate_load_store_insn(struct pt_regs *regs,
 		if (!access_ok(VERIFY_READ, addr, 4))
 			goto sigbus;
 
-		if (config_enabled(CONFIG_EVA)) {
+		if (IS_ENABLED(CONFIG_EVA)) {
 			if (segment_eq(get_fs(), get_ds()))
 				LoadW(addr, value, res);
 			else
@@ -1063,7 +1063,7 @@ static void emulate_load_store_insn(struct pt_regs *regs,
 		if (!access_ok(VERIFY_READ, addr, 2))
 			goto sigbus;
 
-		if (config_enabled(CONFIG_EVA)) {
+		if (IS_ENABLED(CONFIG_EVA)) {
 			if (segment_eq(get_fs(), get_ds()))
 				LoadHWU(addr, value, res);
 			else
@@ -1131,7 +1131,7 @@ static void emulate_load_store_insn(struct pt_regs *regs,
 		compute_return_epc(regs);
 		value = regs->regs[insn.i_format.rt];
 
-		if (config_enabled(CONFIG_EVA)) {
+		if (IS_ENABLED(CONFIG_EVA)) {
 			if (segment_eq(get_fs(), get_ds()))
 				StoreHW(addr, value, res);
 			else
@@ -1151,7 +1151,7 @@ static void emulate_load_store_insn(struct pt_regs *regs,
 		compute_return_epc(regs);
 		value = regs->regs[insn.i_format.rt];
 
-		if (config_enabled(CONFIG_EVA)) {
+		if (IS_ENABLED(CONFIG_EVA)) {
 			if (segment_eq(get_fs(), get_ds()))
 				StoreW(addr, value, res);
 			else
diff --git a/arch/mips/math-emu/cp1emu.c b/arch/mips/math-emu/cp1emu.c
index d96e912..5dd3c59 100644
--- a/arch/mips/math-emu/cp1emu.c
+++ b/arch/mips/math-emu/cp1emu.c
@@ -784,10 +784,10 @@ static int isBranchInstr(struct pt_regs *regs, struct mm_decoded_insn dec_insn,
  */
 static inline int cop1_64bit(struct pt_regs *xcp)
 {
-	if (config_enabled(CONFIG_64BIT) && !config_enabled(CONFIG_MIPS32_O32))
+	if (IS_ENABLED(CONFIG_64BIT) && !IS_ENABLED(CONFIG_MIPS32_O32))
 		return 1;
-	else if (config_enabled(CONFIG_32BIT) &&
-		 !config_enabled(CONFIG_MIPS_O32_FP64_SUPPORT))
+	else if (IS_ENABLED(CONFIG_32BIT) &&
+		 !IS_ENABLED(CONFIG_MIPS_O32_FP64_SUPPORT))
 		return 0;
 
 	return !test_thread_flag(TIF_32BIT_FPREGS);
diff --git a/arch/mips/mm/tlbex.c b/arch/mips/mm/tlbex.c
index 4004b65..ff49b29 100644
--- a/arch/mips/mm/tlbex.c
+++ b/arch/mips/mm/tlbex.c
@@ -1025,7 +1025,7 @@ static void build_update_entries(u32 **p, unsigned int tmp, unsigned int ptep)
 	pte_off_odd += offsetof(pte_t, pte_high);
 #endif
 
-	if (config_enabled(CONFIG_XPA)) {
+	if (IS_ENABLED(CONFIG_XPA)) {
 		uasm_i_lw(p, tmp, pte_off_even, ptep); /* even pte */
 		UASM_i_ROTR(p, tmp, tmp, ilog2(_PAGE_GLOBAL));
 		UASM_i_MTC0(p, tmp, C0_ENTRYLO0);
@@ -1643,7 +1643,7 @@ iPTE_SW(u32 **p, struct uasm_reloc **r, unsigned int pte, unsigned int ptr,
 	unsigned int hwmode = mode & (_PAGE_VALID | _PAGE_DIRTY);
 	unsigned int swmode = mode & ~hwmode;
 
-	if (config_enabled(CONFIG_XPA) && !cpu_has_64bits) {
+	if (IS_ENABLED(CONFIG_XPA) && !cpu_has_64bits) {
 		uasm_i_lui(p, scratch, swmode >> 16);
 		uasm_i_or(p, pte, pte, scratch);
 		BUG_ON(swmode & 0xffff);
@@ -2432,7 +2432,7 @@ static void config_htw_params(void)
 		pwsize |= ilog2(PTRS_PER_PMD) << MIPS_PWSIZE_MDW_SHIFT;
 
 	/* Set pointer size to size of directory pointers */
-	if (config_enabled(CONFIG_64BIT))
+	if (IS_ENABLED(CONFIG_64BIT))
 		pwsize |= MIPS_PWSIZE_PS_MASK;
 	/* PTEs may be multiple pointers long (e.g. with XPA) */
 	pwsize |= ((PTE_T_LOG2 - PGD_T_LOG2) << MIPS_PWSIZE_PTEW_SHIFT)
@@ -2448,7 +2448,7 @@ static void config_htw_params(void)
 	 * the pwctl fields.
 	 */
 	config = 1 << MIPS_PWCTL_PWEN_SHIFT;
-	if (config_enabled(CONFIG_64BIT))
+	if (IS_ENABLED(CONFIG_64BIT))
 		config |= MIPS_PWCTL_XU_MASK;
 	write_c0_pwctl(config);
 	pr_info("Hardware Page Table Walker enabled\n");
@@ -2522,7 +2522,7 @@ void build_tlb_refill_handler(void)
 	 */
 	static int run_once = 0;
 
-	if (config_enabled(CONFIG_XPA) && !cpu_has_rixi)
+	if (IS_ENABLED(CONFIG_XPA) && !cpu_has_rixi)
 		panic("Kernels supporting XPA currently require CPUs with RIXI");
 
 	output_pgtable_bits_defines();
diff --git a/arch/mips/mti-malta/malta-dtshim.c b/arch/mips/mti-malta/malta-dtshim.c
index f7133ef..151f488 100644
--- a/arch/mips/mti-malta/malta-dtshim.c
+++ b/arch/mips/mti-malta/malta-dtshim.c
@@ -31,7 +31,7 @@ static unsigned __init gen_fdt_mem_array(__be32 *mem_array, unsigned long size)
 
 	entries = 1;
 	mem_array[0] = cpu_to_be32(PHYS_OFFSET);
-	if (config_enabled(CONFIG_EVA)) {
+	if (IS_ENABLED(CONFIG_EVA)) {
 		/*
 		 * The current Malta EVA configuration is "special" in that it
 		 * always makes use of addresses in the upper half of the 32 bit
@@ -82,7 +82,7 @@ static void __init append_memory(void *fdt, int root_off)
 		physical_memsize = 32 << 20;
 	}
 
-	if (config_enabled(CONFIG_CPU_BIG_ENDIAN)) {
+	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)) {
 		/*
 		 * SOC-it swaps, or perhaps doesn't swap, when DMA'ing
 		 * the last word of physical memory.
diff --git a/arch/mips/mti-malta/malta-memory.c b/arch/mips/mti-malta/malta-memory.c
index d5f8dae..a475567 100644
--- a/arch/mips/mti-malta/malta-memory.c
+++ b/arch/mips/mti-malta/malta-memory.c
@@ -32,7 +32,7 @@ static void free_init_pages_eva_malta(void *begin, void *end)
 
 void __init fw_meminit(void)
 {
-	bool eva = config_enabled(CONFIG_EVA);
+	bool eva = IS_ENABLED(CONFIG_EVA);
 
 	free_init_pages_eva = eva ? free_init_pages_eva_malta : NULL;
 }
diff --git a/arch/mips/mti-malta/malta-setup.c b/arch/mips/mti-malta/malta-setup.c
index 33d5ff5..ec5b216 100644
--- a/arch/mips/mti-malta/malta-setup.c
+++ b/arch/mips/mti-malta/malta-setup.c
@@ -261,7 +261,7 @@ void __init plat_mem_setup(void)
 	fdt = malta_dt_shim(fdt);
 	__dt_setup_arch(fdt);
 
-	if (config_enabled(CONFIG_EVA))
+	if (IS_ENABLED(CONFIG_EVA))
 		/* EVA has already been configured in mach-malta/kernel-init.h */
 		pr_info("Enhanced Virtual Addressing (EVA) activated\n");
 
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 1a8c960..d1b7bd0 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -426,7 +426,7 @@ static inline void emit_load_ptr(unsigned int dst, unsigned int src,
 static inline void emit_load_func(unsigned int reg, ptr imm,
 				  struct jit_ctx *ctx)
 {
-	if (config_enabled(CONFIG_64BIT)) {
+	if (IS_ENABLED(CONFIG_64BIT)) {
 		/* At this point imm is always 64-bit */
 		emit_load_imm(r_tmp, (u64)imm >> 32, ctx);
 		emit_dsll(r_tmp_imm, r_tmp, 16, ctx); /* left shift by 16 */
@@ -516,7 +516,7 @@ static inline void emit_jr(unsigned int reg, struct jit_ctx *ctx)
 static inline u16 align_sp(unsigned int num)
 {
 	/* Double word alignment for 32-bit, quadword for 64-bit */
-	unsigned int align = config_enabled(CONFIG_64BIT) ? 16 : 8;
+	unsigned int align = IS_ENABLED(CONFIG_64BIT) ? 16 : 8;
 	num = (num + (align - 1)) & -align;
 	return num;
 }
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index fea7724..e7f155c 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -344,8 +344,8 @@ extern int compat_arch_setup_additional_pages(struct linux_binprm *bprm,
  */
 static inline int mmap_is_ia32(void)
 {
-	return config_enabled(CONFIG_X86_32) ||
-	       (config_enabled(CONFIG_COMPAT) &&
+	return IS_ENABLED(CONFIG_X86_32) ||
+	       (IS_ENABLED(CONFIG_COMPAT) &&
 		test_thread_flag(TIF_ADDR32));
 }
 
diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index 31ac8e6..a9ef2b6 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -136,9 +136,9 @@ static inline int copy_fregs_to_user(struct fregs_state __user *fx)
 
 static inline int copy_fxregs_to_user(struct fxregs_state __user *fx)
 {
-	if (config_enabled(CONFIG_X86_32))
+	if (IS_ENABLED(CONFIG_X86_32))
 		return user_insn(fxsave %[fx], [fx] "=m" (*fx), "m" (*fx));
-	else if (config_enabled(CONFIG_AS_FXSAVEQ))
+	else if (IS_ENABLED(CONFIG_AS_FXSAVEQ))
 		return user_insn(fxsaveq %[fx], [fx] "=m" (*fx), "m" (*fx));
 
 	/* See comment in copy_fxregs_to_kernel() below. */
@@ -149,10 +149,10 @@ static inline void copy_kernel_to_fxregs(struct fxregs_state *fx)
 {
 	int err;
 
-	if (config_enabled(CONFIG_X86_32)) {
+	if (IS_ENABLED(CONFIG_X86_32)) {
 		err = check_insn(fxrstor %[fx], "=m" (*fx), [fx] "m" (*fx));
 	} else {
-		if (config_enabled(CONFIG_AS_FXSAVEQ)) {
+		if (IS_ENABLED(CONFIG_AS_FXSAVEQ)) {
 			err = check_insn(fxrstorq %[fx], "=m" (*fx), [fx] "m" (*fx));
 		} else {
 			/* See comment in copy_fxregs_to_kernel() below. */
@@ -165,9 +165,9 @@ static inline void copy_kernel_to_fxregs(struct fxregs_state *fx)
 
 static inline int copy_user_to_fxregs(struct fxregs_state __user *fx)
 {
-	if (config_enabled(CONFIG_X86_32))
+	if (IS_ENABLED(CONFIG_X86_32))
 		return user_insn(fxrstor %[fx], "=m" (*fx), [fx] "m" (*fx));
-	else if (config_enabled(CONFIG_AS_FXSAVEQ))
+	else if (IS_ENABLED(CONFIG_AS_FXSAVEQ))
 		return user_insn(fxrstorq %[fx], "=m" (*fx), [fx] "m" (*fx));
 
 	/* See comment in copy_fxregs_to_kernel() below. */
@@ -189,9 +189,9 @@ static inline int copy_user_to_fregs(struct fregs_state __user *fx)
 
 static inline void copy_fxregs_to_kernel(struct fpu *fpu)
 {
-	if (config_enabled(CONFIG_X86_32))
+	if (IS_ENABLED(CONFIG_X86_32))
 		asm volatile( "fxsave %[fx]" : [fx] "=m" (fpu->state.fxsave));
-	else if (config_enabled(CONFIG_AS_FXSAVEQ))
+	else if (IS_ENABLED(CONFIG_AS_FXSAVEQ))
 		asm volatile("fxsaveq %[fx]" : [fx] "=m" (fpu->state.fxsave));
 	else {
 		/* Using "rex64; fxsave %0" is broken because, if the memory
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 39634819..d8abfcf 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -155,7 +155,7 @@ static inline void arch_exit_mmap(struct mm_struct *mm)
 #ifdef CONFIG_X86_64
 static inline bool is_64bit_mm(struct mm_struct *mm)
 {
-	return	!config_enabled(CONFIG_IA32_EMULATION) ||
+	return	!IS_ENABLED(CONFIG_IA32_EMULATION) ||
 		!(mm->context.ia32_compat == TIF_IA32);
 }
 #else
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index 60078a6..529e165 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -145,7 +145,7 @@ static int force_enable_local_apic __initdata;
  */
 static int __init parse_lapic(char *arg)
 {
-	if (config_enabled(CONFIG_X86_32) && !arg)
+	if (IS_ENABLED(CONFIG_X86_32) && !arg)
 		force_enable_local_apic = 1;
 	else if (arg && !strncmp(arg, "notscdeadline", 13))
 		setup_clear_cpu_cap(X86_FEATURE_TSC_DEADLINE_TIMER);
diff --git a/arch/x86/kernel/apic/vector.c b/arch/x86/kernel/apic/vector.c
index a5e400a..6066d94 100644
--- a/arch/x86/kernel/apic/vector.c
+++ b/arch/x86/kernel/apic/vector.c
@@ -523,7 +523,7 @@ static int apic_set_affinity(struct irq_data *irq_data,
 	struct apic_chip_data *data = irq_data->chip_data;
 	int err, irq = irq_data->irq;
 
-	if (!config_enabled(CONFIG_SMP))
+	if (!IS_ENABLED(CONFIG_SMP))
 		return -EPERM;
 
 	if (!cpumask_intersects(dest, cpu_online_mask))
diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 31c6a60..466b801 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -156,8 +156,8 @@ int copy_fpstate_to_sigframe(void __user *buf, void __user *buf_fx, int size)
 	struct task_struct *tsk = current;
 	int ia32_fxstate = (buf != buf_fx);
 
-	ia32_fxstate &= (config_enabled(CONFIG_X86_32) ||
-			 config_enabled(CONFIG_IA32_EMULATION));
+	ia32_fxstate &= (IS_ENABLED(CONFIG_X86_32) ||
+			 IS_ENABLED(CONFIG_IA32_EMULATION));
 
 	if (!access_ok(VERIFY_WRITE, buf, size))
 		return -EACCES;
@@ -254,8 +254,8 @@ static int __fpu__restore_sig(void __user *buf, void __user *buf_fx, int size)
 	u64 xfeatures = 0;
 	int fx_only = 0;
 
-	ia32_fxstate &= (config_enabled(CONFIG_X86_32) ||
-			 config_enabled(CONFIG_IA32_EMULATION));
+	ia32_fxstate &= (IS_ENABLED(CONFIG_X86_32) ||
+			 IS_ENABLED(CONFIG_IA32_EMULATION));
 
 	if (!buf) {
 		fpu__clear(fpu);
@@ -392,8 +392,8 @@ void fpu__init_prepare_fx_sw_frame(void)
 	fx_sw_reserved.xfeatures = xfeatures_mask;
 	fx_sw_reserved.xstate_size = xstate_size;
 
-	if (config_enabled(CONFIG_IA32_EMULATION) ||
-	    config_enabled(CONFIG_X86_32)) {
+	if (IS_ENABLED(CONFIG_IA32_EMULATION) ||
+	    IS_ENABLED(CONFIG_X86_32)) {
 		int fsave_header_size = sizeof(struct fregs_state);
 
 		fx_sw_reserved_ia32 = fx_sw_reserved;
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 22cc2f9..99f285b 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -146,7 +146,7 @@ static int restore_sigcontext(struct pt_regs *regs,
 		buf = (void __user *)buf_val;
 	} get_user_catch(err);
 
-	err |= fpu__restore_sig(buf, config_enabled(CONFIG_X86_32));
+	err |= fpu__restore_sig(buf, IS_ENABLED(CONFIG_X86_32));
 
 	force_iret();
 
@@ -245,14 +245,14 @@ get_sigframe(struct k_sigaction *ka, struct pt_regs *regs, size_t frame_size,
 	struct fpu *fpu = &current->thread.fpu;
 
 	/* redzone */
-	if (config_enabled(CONFIG_X86_64))
+	if (IS_ENABLED(CONFIG_X86_64))
 		sp -= 128;
 
 	/* This is the X/Open sanctioned signal stack switching.  */
 	if (ka->sa.sa_flags & SA_ONSTACK) {
 		if (sas_ss_flags(sp) == 0)
 			sp = current->sas_ss_sp + current->sas_ss_size;
-	} else if (config_enabled(CONFIG_X86_32) &&
+	} else if (IS_ENABLED(CONFIG_X86_32) &&
 		   !onsigstack &&
 		   (regs->ss & 0xffff) != __USER_DS &&
 		   !(ka->sa.sa_flags & SA_RESTORER) &&
@@ -262,7 +262,7 @@ get_sigframe(struct k_sigaction *ka, struct pt_regs *regs, size_t frame_size,
 	}
 
 	if (fpu->fpstate_active) {
-		sp = fpu__alloc_mathframe(sp, config_enabled(CONFIG_X86_32),
+		sp = fpu__alloc_mathframe(sp, IS_ENABLED(CONFIG_X86_32),
 					  &buf_fx, &math_size);
 		*fpstate = (void __user *)sp;
 	}
@@ -662,18 +662,18 @@ badframe:
 
 static inline int is_ia32_compat_frame(void)
 {
-	return config_enabled(CONFIG_IA32_EMULATION) &&
+	return IS_ENABLED(CONFIG_IA32_EMULATION) &&
 	       test_thread_flag(TIF_IA32);
 }
 
 static inline int is_ia32_frame(void)
 {
-	return config_enabled(CONFIG_X86_32) || is_ia32_compat_frame();
+	return IS_ENABLED(CONFIG_X86_32) || is_ia32_compat_frame();
 }
 
 static inline int is_x32_frame(void)
 {
-	return config_enabled(CONFIG_X86_X32_ABI) && test_thread_flag(TIF_X32);
+	return IS_ENABLED(CONFIG_X86_X32_ABI) && test_thread_flag(TIF_X32);
 }
 
 static int
diff --git a/drivers/firmware/broadcom/bcm47xx_sprom.c b/drivers/firmware/broadcom/bcm47xx_sprom.c
index b6eb875..62aa3cf 100644
--- a/drivers/firmware/broadcom/bcm47xx_sprom.c
+++ b/drivers/firmware/broadcom/bcm47xx_sprom.c
@@ -669,7 +669,7 @@ static int bcm47xx_get_sprom_bcma(struct bcma_bus *bus, struct ssb_sprom *out)
 	case BCMA_HOSTTYPE_PCI:
 		memset(out, 0, sizeof(struct ssb_sprom));
 		/* On BCM47XX all PCI buses share the same domain */
-		if (config_enabled(CONFIG_BCM47XX))
+		if (IS_ENABLED(CONFIG_BCM47XX))
 			snprintf(buf, sizeof(buf), "pci/%u/%u/",
 				 bus->host_pci->bus->number + 1,
 				 PCI_SLOT(bus->host_pci->devfn));
diff --git a/drivers/irqchip/irq-mips-gic.c b/drivers/irqchip/irq-mips-gic.c
index 3b5e10a..986f766 100644
--- a/drivers/irqchip/irq-mips-gic.c
+++ b/drivers/irqchip/irq-mips-gic.c
@@ -359,7 +359,7 @@ static void gic_handle_shared_int(bool chained)
 		pending_reg += gic_reg_step;
 		intrmask_reg += gic_reg_step;
 
-		if (!config_enabled(CONFIG_64BIT) || mips_cm_is64)
+		if (!IS_ENABLED(CONFIG_64BIT) || mips_cm_is64)
 			continue;
 
 		pending[i] |= (u64)gic_read(pending_reg) << 32;
diff --git a/drivers/mtd/bcm47xxpart.c b/drivers/mtd/bcm47xxpart.c
index 845dd27..3779475 100644
--- a/drivers/mtd/bcm47xxpart.c
+++ b/drivers/mtd/bcm47xxpart.c
@@ -122,7 +122,7 @@ static int bcm47xxpart_parse(struct mtd_info *master,
 	for (offset = 0; offset <= master->size - blocksize;
 	     offset += blocksize) {
 		/* Nothing more in higher memory on BCM47XX (MIPS) */
-		if (config_enabled(CONFIG_BCM47XX) && offset >= 0x2000000)
+		if (IS_ENABLED(CONFIG_BCM47XX) && offset >= 0x2000000)
 			break;
 
 		if (curr_part >= BCM47XXPART_MAX_PARTS) {
diff --git a/drivers/net/wireless/ath/ath10k/debug.c b/drivers/net/wireless/ath/ath10k/debug.c
index e251155..0a8a421 100644
--- a/drivers/net/wireless/ath/ath10k/debug.c
+++ b/drivers/net/wireless/ath/ath10k/debug.c
@@ -139,11 +139,11 @@ void ath10k_debug_print_hwfw_info(struct ath10k *ar)
 		    ar->id.subsystem_vendor, ar->id.subsystem_device);
 
 	ath10k_info(ar, "kconfig debug %d debugfs %d tracing %d dfs %d testmode %d\n",
-		    config_enabled(CONFIG_ATH10K_DEBUG),
-		    config_enabled(CONFIG_ATH10K_DEBUGFS),
-		    config_enabled(CONFIG_ATH10K_TRACING),
-		    config_enabled(CONFIG_ATH10K_DFS_CERTIFIED),
-		    config_enabled(CONFIG_NL80211_TESTMODE));
+		    IS_ENABLED(CONFIG_ATH10K_DEBUG),
+		    IS_ENABLED(CONFIG_ATH10K_DEBUGFS),
+		    IS_ENABLED(CONFIG_ATH10K_TRACING),
+		    IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED),
+		    IS_ENABLED(CONFIG_NL80211_TESTMODE));
 
 	firmware = ar->normal_mode_fw.fw_file.firmware;
 	if (firmware)
@@ -2397,7 +2397,7 @@ int ath10k_debug_register(struct ath10k *ar)
 	debugfs_create_file("nf_cal_period", S_IRUSR | S_IWUSR,
 			    ar->debug.debugfs_phy, ar, &fops_nf_cal_period);
 
-	if (config_enabled(CONFIG_ATH10K_DFS_CERTIFIED)) {
+	if (IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED)) {
 		debugfs_create_file("dfs_simulate_radar", S_IWUSR,
 				    ar->debug.debugfs_phy, ar,
 				    &fops_simulate_radar);
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 6dd1d26..181159d 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -2993,7 +2993,7 @@ static void ath10k_regd_update(struct ath10k *ar)
 
 	regpair = ar->ath_common.regulatory.regpair;
 
-	if (config_enabled(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector) {
+	if (IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector) {
 		nl_dfs_reg = ar->dfs_detector->region;
 		wmi_dfs_reg = ath10k_mac_get_dfs_region(nl_dfs_reg);
 	} else {
@@ -3022,7 +3022,7 @@ static void ath10k_reg_notifier(struct wiphy *wiphy,
 
 	ath_reg_notifier_apply(wiphy, request, &ar->ath_common.regulatory);
 
-	if (config_enabled(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector) {
+	if (IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector) {
 		ath10k_dbg(ar, ATH10K_DBG_REGULATORY, "dfs region 0x%x\n",
 			   request->dfs_region);
 		result = ar->dfs_detector->set_dfs_domain(ar->dfs_detector,
@@ -7860,7 +7860,7 @@ int ath10k_mac_register(struct ath10k *ar)
 	if (!test_bit(ATH10K_FLAG_RAW_MODE, &ar->dev_flags))
 		ar->hw->netdev_features = NETIF_F_HW_CSUM;
 
-	if (config_enabled(CONFIG_ATH10K_DFS_CERTIFIED)) {
+	if (IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED)) {
 		/* Init ath dfs pattern detector */
 		ar->ath_common.debug_mask = ATH_DBG_DFS;
 		ar->dfs_detector = dfs_pattern_detector_init(&ar->ath_common,
@@ -7899,7 +7899,7 @@ err_unregister:
 	ieee80211_unregister_hw(ar->hw);
 
 err_dfs_detector_exit:
-	if (config_enabled(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector)
+	if (IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector)
 		ar->dfs_detector->exit(ar->dfs_detector);
 
 err_free:
@@ -7914,7 +7914,7 @@ void ath10k_mac_unregister(struct ath10k *ar)
 {
 	ieee80211_unregister_hw(ar->hw);
 
-	if (config_enabled(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector)
+	if (IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED) && ar->dfs_detector)
 		ar->dfs_detector->exit(ar->dfs_detector);
 
 	kfree(ar->mac.sbands[NL80211_BAND_2GHZ].channels);
diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index 2c30032..2978044 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -3671,7 +3671,7 @@ void ath10k_wmi_event_dfs(struct ath10k *ar,
 		   phyerr->tsf_timestamp, tsf, buf_len);
 
 	/* Skip event if DFS disabled */
-	if (!config_enabled(CONFIG_ATH10K_DFS_CERTIFIED))
+	if (!IS_ENABLED(CONFIG_ATH10K_DFS_CERTIFIED))
 		return;
 
 	ATH10K_DFS_STAT_INC(ar, pulses_total);
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 4e11ba0..f6b5390 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -3870,7 +3870,7 @@ int ath6kl_cfg80211_init(struct ath6kl *ar)
 					  BIT(NL80211_IFTYPE_P2P_CLIENT);
 	}
 
-	if (config_enabled(CONFIG_ATH6KL_REGDOMAIN) &&
+	if (IS_ENABLED(CONFIG_ATH6KL_REGDOMAIN) &&
 	    test_bit(ATH6KL_FW_CAPABILITY_REGDOMAIN, ar->fw_capabilities)) {
 		wiphy->reg_notifier = ath6kl_cfg80211_reg_notify;
 		ar->wiphy->features |= NL80211_FEATURE_CELL_BASE_REG_HINTS;
diff --git a/drivers/net/wireless/ath/ath9k/common-spectral.c b/drivers/net/wireless/ath/ath9k/common-spectral.c
index a876271..e2512d5 100644
--- a/drivers/net/wireless/ath/ath9k/common-spectral.c
+++ b/drivers/net/wireless/ath/ath9k/common-spectral.c
@@ -731,7 +731,7 @@ void ath9k_cmn_spectral_scan_trigger(struct ath_common *common,
 	struct ath_hw *ah = spec_priv->ah;
 	u32 rxfilter;
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return;
 
 	if (!ath9k_hw_ops(ah)->spectral_scan_trigger) {
@@ -806,7 +806,7 @@ static ssize_t write_file_spec_scan_ctl(struct file *file,
 	char buf[32];
 	ssize_t len;
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return -EOPNOTSUPP;
 
 	len = min(count, sizeof(buf) - 1);
@@ -1072,7 +1072,7 @@ static struct rchan_callbacks rfs_spec_scan_cb = {
 
 void ath9k_cmn_spectral_deinit_debug(struct ath_spec_scan_priv *spec_priv)
 {
-	if (config_enabled(CONFIG_ATH9K_DEBUGFS)) {
+	if (IS_ENABLED(CONFIG_ATH9K_DEBUGFS)) {
 		relay_close(spec_priv->rfs_chan_spec_scan);
 		spec_priv->rfs_chan_spec_scan = NULL;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 2ee8624..486d526 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -839,7 +839,7 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *hw)
 			       NL80211_FEATURE_AP_MODE_CHAN_WIDTH_CHANGE |
 			       NL80211_FEATURE_P2P_GO_CTWIN;
 
-	if (!config_enabled(CONFIG_ATH9K_TX99)) {
+	if (!IS_ENABLED(CONFIG_ATH9K_TX99)) {
 		hw->wiphy->interface_modes =
 			BIT(NL80211_IFTYPE_P2P_GO) |
 			BIT(NL80211_IFTYPE_P2P_CLIENT) |
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 8b63988..fccef70 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1239,7 +1239,7 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 
 	mutex_lock(&sc->mutex);
 
-	if (config_enabled(CONFIG_ATH9K_TX99)) {
+	if (IS_ENABLED(CONFIG_ATH9K_TX99)) {
 		if (sc->cur_chan->nvifs >= 1) {
 			mutex_unlock(&sc->mutex);
 			return -EOPNOTSUPP;
@@ -1289,7 +1289,7 @@ static int ath9k_change_interface(struct ieee80211_hw *hw,
 
 	mutex_lock(&sc->mutex);
 
-	if (config_enabled(CONFIG_ATH9K_TX99)) {
+	if (IS_ENABLED(CONFIG_ATH9K_TX99)) {
 		mutex_unlock(&sc->mutex);
 		return -EOPNOTSUPP;
 	}
@@ -1349,7 +1349,7 @@ static void ath9k_enable_ps(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return;
 
 	sc->ps_enabled = true;
@@ -1368,7 +1368,7 @@ static void ath9k_disable_ps(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return;
 
 	sc->ps_enabled = false;
@@ -1926,7 +1926,7 @@ static int ath9k_get_survey(struct ieee80211_hw *hw, int idx,
 	struct ieee80211_channel *chan;
 	int pos;
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return -EOPNOTSUPP;
 
 	spin_lock_bh(&common->cc_lock);
@@ -1976,7 +1976,7 @@ static void ath9k_set_coverage_class(struct ieee80211_hw *hw,
 	struct ath_softc *sc = hw->priv;
 	struct ath_hw *ah = sc->sc_ah;
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return;
 
 	mutex_lock(&sc->mutex);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 32160fc..6697342 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -377,7 +377,7 @@ u32 ath_calcrxfilter(struct ath_softc *sc)
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	u32 rfilt;
 
-	if (config_enabled(CONFIG_ATH9K_TX99))
+	if (IS_ENABLED(CONFIG_ATH9K_TX99))
 		return 0;
 
 	rfilt = ATH9K_RX_FILTER_UCAST | ATH9K_RX_FILTER_BCAST
diff --git a/drivers/net/wireless/ath/dfs_pattern_detector.c b/drivers/net/wireless/ath/dfs_pattern_detector.c
index 2303ef9..2f8136d 100644
--- a/drivers/net/wireless/ath/dfs_pattern_detector.c
+++ b/drivers/net/wireless/ath/dfs_pattern_detector.c
@@ -352,7 +352,7 @@ dfs_pattern_detector_init(struct ath_common *common,
 {
 	struct dfs_pattern_detector *dpd;
 
-	if (!config_enabled(CONFIG_CFG80211_CERTIFICATION_ONUS))
+	if (!IS_ENABLED(CONFIG_CFG80211_CERTIFICATION_ONUS))
 		return NULL;
 
 	dpd = kmalloc(sizeof(*dpd), GFP_KERNEL);
diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/regd.c
index 7e15ed9..f850603 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -116,7 +116,7 @@ static const struct ieee80211_regdomain ath_world_regdom_67_68_6A_6C = {
 
 static bool dynamic_country_user_possible(struct ath_regulatory *reg)
 {
-	if (config_enabled(CONFIG_ATH_REG_DYNAMIC_USER_CERT_TESTING))
+	if (IS_ENABLED(CONFIG_ATH_REG_DYNAMIC_USER_CERT_TESTING))
 		return true;
 
 	switch (reg->country_code) {
@@ -188,7 +188,7 @@ static bool dynamic_country_user_possible(struct ath_regulatory *reg)
 
 static bool ath_reg_dyn_country_user_allow(struct ath_regulatory *reg)
 {
-	if (!config_enabled(CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS))
+	if (!IS_ENABLED(CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS))
 		return false;
 	if (!dynamic_country_user_possible(reg))
 		return false;
diff --git a/drivers/pci/ecam.c b/drivers/pci/ecam.c
index f9832ad..8bd3a08 100644
--- a/drivers/pci/ecam.c
+++ b/drivers/pci/ecam.c
@@ -28,7 +28,7 @@
  * since we have enough virtual address range available.  On 32-bit, we
  * ioremap the config space for each bus individually.
  */
-static const bool per_bus_mapping = !config_enabled(CONFIG_64BIT);
+static const bool per_bus_mapping = !IS_ENABLED(CONFIG_64BIT);
 
 /*
  * Create a PCI config space window
diff --git a/drivers/tty/serial/ar933x_uart.c b/drivers/tty/serial/ar933x_uart.c
index 1519d2c..73137f4 100644
--- a/drivers/tty/serial/ar933x_uart.c
+++ b/drivers/tty/serial/ar933x_uart.c
@@ -54,7 +54,7 @@ struct ar933x_uart_port {
 
 static inline bool ar933x_uart_console_enabled(void)
 {
-	return config_enabled(CONFIG_SERIAL_AR933X_CONSOLE);
+	return IS_ENABLED(CONFIG_SERIAL_AR933X_CONSOLE);
 }
 
 static inline unsigned int ar933x_uart_read(struct ar933x_uart_port *up,
@@ -636,7 +636,7 @@ static int ar933x_uart_probe(struct platform_device *pdev)
 	int ret;
 
 	np = pdev->dev.of_node;
-	if (config_enabled(CONFIG_OF) && np) {
+	if (IS_ENABLED(CONFIG_OF) && np) {
 		id = of_alias_get_id(np, "serial");
 		if (id < 0) {
 			dev_err(&pdev->dev, "unable to get alias id, err=%d\n",
diff --git a/include/linux/fence.h b/include/linux/fence.h
index 2056e9f..c00346d 100644
--- a/include/linux/fence.h
+++ b/include/linux/fence.h
@@ -359,7 +359,7 @@ unsigned fence_context_alloc(unsigned num);
 #define FENCE_TRACE(f, fmt, args...) \
 	do {								\
 		struct fence *__ff = (f);				\
-		if (config_enabled(CONFIG_FENCE_TRACE))			\
+		if (IS_ENABLED(CONFIG_FENCE_TRACE))			\
 			pr_info("f %u#%u: " fmt,			\
 				__ff->context, __ff->seqno, ##args);	\
 	} while (0)
diff --git a/include/linux/ww_mutex.h b/include/linux/ww_mutex.h
index 760399a..2bb5deb 100644
--- a/include/linux/ww_mutex.h
+++ b/include/linux/ww_mutex.h
@@ -173,14 +173,14 @@ static inline void ww_acquire_fini(struct ww_acquire_ctx *ctx)
 	mutex_release(&ctx->dep_map, 0, _THIS_IP_);
 
 	DEBUG_LOCKS_WARN_ON(ctx->acquired);
-	if (!config_enabled(CONFIG_PROVE_LOCKING))
+	if (!IS_ENABLED(CONFIG_PROVE_LOCKING))
 		/*
 		 * lockdep will normally handle this,
 		 * but fail without anyway
 		 */
 		ctx->done_acquire = 1;
 
-	if (!config_enabled(CONFIG_DEBUG_LOCK_ALLOC))
+	if (!IS_ENABLED(CONFIG_DEBUG_LOCK_ALLOC))
 		/* ensure ww_acquire_fini will still fail if called twice */
 		ctx->acquired = ~0U;
 #endif
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index d49bfa1..1d3b766 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -585,8 +585,8 @@ static int ptrace_setoptions(struct task_struct *child, unsigned long data)
 		return -EINVAL;
 
 	if (unlikely(data & PTRACE_O_SUSPEND_SECCOMP)) {
-		if (!config_enabled(CONFIG_CHECKPOINT_RESTORE) ||
-		    !config_enabled(CONFIG_SECCOMP))
+		if (!IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) ||
+		    !IS_ENABLED(CONFIG_SECCOMP))
 			return -EINVAL;
 
 		if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 7002796..eaf2458 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -347,7 +347,7 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *sfilter;
 	int ret;
-	const bool save_orig = config_enabled(CONFIG_CHECKPOINT_RESTORE);
+	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
@@ -542,7 +542,7 @@ void secure_computing_strict(int this_syscall)
 {
 	int mode = current->seccomp.mode;
 
-	if (config_enabled(CONFIG_CHECKPOINT_RESTORE) &&
+	if (IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) &&
 	    unlikely(current->ptrace & PT_SUSPEND_SECCOMP))
 		return;
 
@@ -647,7 +647,7 @@ u32 seccomp_phase1(struct seccomp_data *sd)
 	int this_syscall = sd ? sd->nr :
 		syscall_get_nr(current, task_pt_regs(current));
 
-	if (config_enabled(CONFIG_CHECKPOINT_RESTORE) &&
+	if (IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) &&
 	    unlikely(current->ptrace & PT_SUSPEND_SECCOMP))
 		return SECCOMP_PHASE1_OK;
 
diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index da49c0b..b0e11b6 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -715,7 +715,7 @@ static bool cfg80211_ir_permissive_chan(struct wiphy *wiphy,
 
 	ASSERT_RTNL();
 
-	if (!config_enabled(CONFIG_CFG80211_REG_RELAX_NO_IR) ||
+	if (!IS_ENABLED(CONFIG_CFG80211_REG_RELAX_NO_IR) ||
 	    !(wiphy->regulatory_flags & REGULATORY_ENABLE_RELAX_NO_IR))
 		return false;
 
-- 
1.9.1


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
