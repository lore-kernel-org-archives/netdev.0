From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 1/8] powerpc: replace CONFIG_8xx by CONFIG_PPC_8xx
Date: Thu, 12 Mar 2015 16:23:39 +0100 (CET)
Message-ID: <20150312152339.9058A1A241C@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-mtd@lists.infradead.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	scottwood@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two config options exist to define powerpc MPC8xx:
* CONFIG_PPC_8xx
* CONFIG_8xx
In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
communication co-processor

arch/powerpc/platforms/Kconfig.cputype has contained the following
comment about CONFIG_8xx item for some years:
"# this is temp to handle compat with arch=ppc"

It looks like not many places still have that old CONFIG_8xx used,
so it is likely to be a good time to get rid of it completely ?

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
 arch/powerpc/Kconfig                      | 10 +++++-----
 arch/powerpc/Makefile                     |  2 +-
 arch/powerpc/boot/Makefile                |  4 ++--
 arch/powerpc/boot/util.S                  |  6 +++---
 arch/powerpc/include/asm/cache.h          |  2 +-
 arch/powerpc/include/asm/cputable.h       |  4 ++--
 arch/powerpc/include/asm/fs_pd.h          |  2 +-
 arch/powerpc/include/asm/pgtable-ppc32.h  |  2 +-
 arch/powerpc/include/asm/ppc_asm.h        |  4 ++--
 arch/powerpc/include/asm/reg.h            | 10 +++++-----
 arch/powerpc/include/asm/timex.h          |  4 ++--
 arch/powerpc/kernel/Makefile              |  2 +-
 arch/powerpc/kernel/cputable.c            |  4 ++--
 arch/powerpc/kernel/irq.c                 |  2 +-
 arch/powerpc/kernel/kgdb.c                |  4 ++--
 arch/powerpc/kernel/misc_32.S             |  4 ++--
 arch/powerpc/kernel/traps.c               |  6 +++---
 arch/powerpc/kernel/vdso32/gettimeofday.S |  2 +-
 arch/powerpc/mm/fault.c                   |  4 ++--
 arch/powerpc/mm/init_32.c                 |  4 ++--
 arch/powerpc/mm/mem.c                     |  2 +-
 arch/powerpc/mm/mmu_decl.h                | 12 ++++++------
 arch/powerpc/mm/tlb_nohash_low.S          |  2 +-
 arch/powerpc/platforms/8xx/Kconfig        |  3 +--
 arch/powerpc/platforms/Kconfig.cputype    |  2 +-
 arch/powerpc/sysdev/Makefile              |  2 +-
 arch/powerpc/sysdev/fsl_soc.c             |  3 ++-
 arch/powerpc/sysdev/fsl_soc.h             |  3 ++-
 arch/powerpc/xmon/xmon.c                  |  2 +-
 29 files changed, 57 insertions(+), 56 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9b780e0..0ed5b4e 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -327,7 +327,7 @@ config HUGETLB_PAGE_SIZE_VARIABLE
 
 config MATH_EMULATION
 	bool "Math emulation"
-	depends on 4xx || 8xx || PPC_MPC832x || BOOKE
+	depends on 4xx || PPC_8xx || PPC_MPC832x || BOOKE
 	---help---
 	  Some PowerPC chips designed for embedded applications do not have
 	  a floating-point unit and therefore do not implement the
@@ -797,9 +797,9 @@ config PPC_PCI_CHOICE
 
 config PCI
 	bool "PCI support" if PPC_PCI_CHOICE
-	default y if !40x && !CPM2 && !8xx && !PPC_83xx \
+	default y if !40x && !CPM2 && !PPC_8xx && !PPC_83xx \
 		&& !PPC_85xx && !PPC_86xx && !GAMECUBE_COMMON
-	default PCI_QSPAN if !4xx && !CPM2 && 8xx
+	default PCI_QSPAN if !4xx && !CPM2 && PPC_8xx
 	select GENERIC_PCI_IOMAP
 	help
 	  Find out whether your system includes a PCI bus. PCI is the name of
@@ -815,7 +815,7 @@ config PCI_SYSCALL
 
 config PCI_QSPAN
 	bool "QSpan PCI"
-	depends on !4xx && !CPM2 && 8xx
+	depends on !4xx && !CPM2 && PPC_8xx
 	select PPC_I8259
 	help
 	  Say Y here if you have a system based on a Motorola 8xx-series
@@ -1033,7 +1033,7 @@ config CONSISTENT_SIZE
 
 config PIN_TLB
 	bool "Pinned Kernel TLBs (860 ONLY)"
-	depends on ADVANCED_OPTIONS && 8xx
+	depends on ADVANCED_OPTIONS && PPC_8xx
 endmenu
 
 if PPC64
diff --git a/arch/powerpc/Makefile b/arch/powerpc/Makefile
index fc502e0..bd6bd46 100644
--- a/arch/powerpc/Makefile
+++ b/arch/powerpc/Makefile
@@ -211,7 +211,7 @@ KBUILD_AFLAGS += $(cpu-as-y)
 KBUILD_CFLAGS += $(cpu-as-y)
 
 head-y				:= arch/powerpc/kernel/head_$(CONFIG_WORD_SIZE).o
-head-$(CONFIG_8xx)		:= arch/powerpc/kernel/head_8xx.o
+head-$(CONFIG_PPC_8xx)		:= arch/powerpc/kernel/head_8xx.o
 head-$(CONFIG_40x)		:= arch/powerpc/kernel/head_40x.o
 head-$(CONFIG_44x)		:= arch/powerpc/kernel/head_44x.o
 head-$(CONFIG_FSL_BOOKE)	:= arch/powerpc/kernel/head_fsl_booke.o
diff --git a/arch/powerpc/boot/Makefile b/arch/powerpc/boot/Makefile
index 8a5bc1c..99c2276 100644
--- a/arch/powerpc/boot/Makefile
+++ b/arch/powerpc/boot/Makefile
@@ -78,7 +78,7 @@ src-wlib-y := string.S crt0.S crtsavres.S stdio.c main.c \
 		uartlite.c mpc52xx-psc.c
 src-wlib-$(CONFIG_40x) += 4xx.c planetcore.c
 src-wlib-$(CONFIG_44x) += 4xx.c ebony.c bamboo.c
-src-wlib-$(CONFIG_8xx) += mpc8xx.c planetcore.c fsl-soc.c
+src-wlib-$(CONFIG_PPC_8xx) += mpc8xx.c planetcore.c fsl-soc.c
 src-wlib-$(CONFIG_PPC_82xx) += pq2.c fsl-soc.c planetcore.c
 src-wlib-$(CONFIG_EMBEDDED6xx) += mv64x60.c mv64x60_i2c.c ugecon.c fsl-soc.c
 
@@ -95,7 +95,7 @@ src-plat-$(CONFIG_44x) += treeboot-ebony.c cuboot-ebony.c treeboot-bamboo.c \
 				treeboot-iss4xx.c treeboot-currituck.c \
 				treeboot-akebono.c \
 				simpleboot.c fixed-head.S virtex.c
-src-plat-$(CONFIG_8xx) += cuboot-8xx.c fixed-head.S ep88xc.c redboot-8xx.c
+src-plat-$(CONFIG_PPC_8xx) += cuboot-8xx.c fixed-head.S ep88xc.c redboot-8xx.c
 src-plat-$(CONFIG_PPC_MPC52xx) += cuboot-52xx.c
 src-plat-$(CONFIG_PPC_82xx) += cuboot-pq2.c fixed-head.S ep8248e.c cuboot-824x.c
 src-plat-$(CONFIG_PPC_83xx) += cuboot-83xx.c fixed-head.S redboot-83xx.c
diff --git a/arch/powerpc/boot/util.S b/arch/powerpc/boot/util.S
index 243b849..7be8f29 100644
--- a/arch/powerpc/boot/util.S
+++ b/arch/powerpc/boot/util.S
@@ -71,7 +71,7 @@ udelay:
 	add	r4,r4,r5
 	addi	r4,r4,-1
 	divw	r4,r4,r5	/* BUS ticks */
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 1:	mftbu	r5
 	mftb	r6
 	mftbu	r7
@@ -84,7 +84,7 @@ udelay:
 	bne	1b		/* Get [synced] base time */
 	addc	r9,r6,r4	/* Compute end time */
 	addze	r8,r5
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 2:	mftbu	r5
 #else
 2:	mfspr	r5, SPRN_TBRU
@@ -92,7 +92,7 @@ udelay:
 	cmpw	0,r5,r8
 	blt	2b
 	bgt	3f
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 	mftb	r6
 #else
 	mfspr	r6, SPRN_TBRL
diff --git a/arch/powerpc/include/asm/cache.h b/arch/powerpc/include/asm/cache.h
index 34a05a1..36a8bc0 100644
--- a/arch/powerpc/include/asm/cache.h
+++ b/arch/powerpc/include/asm/cache.h
@@ -6,7 +6,7 @@
 #include <asm/reg.h>
 
 /* bytes per L1 cache line */
-#if defined(CONFIG_8xx) || defined(CONFIG_403GCX)
+#if defined(CONFIG_PPC_8xx) || defined(CONFIG_403GCX)
 #define L1_CACHE_SHIFT		4
 #define MAX_COPY_PREFETCH	1
 #elif defined(CONFIG_PPC_E500MC)
diff --git a/arch/powerpc/include/asm/cputable.h b/arch/powerpc/include/asm/cputable.h
index 5cf5a6d..f7905be 100644
--- a/arch/powerpc/include/asm/cputable.h
+++ b/arch/powerpc/include/asm/cputable.h
@@ -474,7 +474,7 @@ enum {
 #else
 	    CPU_FTRS_GENERIC_32 |
 #endif
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 	    CPU_FTRS_8XX |
 #endif
 #ifdef CONFIG_40x
@@ -525,7 +525,7 @@ enum {
 #else
 	    CPU_FTRS_GENERIC_32 &
 #endif
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 	    CPU_FTRS_8XX &
 #endif
 #ifdef CONFIG_40x
diff --git a/arch/powerpc/include/asm/fs_pd.h b/arch/powerpc/include/asm/fs_pd.h
index f79d6c7..8def56e 100644
--- a/arch/powerpc/include/asm/fs_pd.h
+++ b/arch/powerpc/include/asm/fs_pd.h
@@ -26,7 +26,7 @@
 #define cpm2_unmap(addr) do {} while(0)
 #endif
 
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 #include <asm/8xx_immap.h>
 
 extern immap_t __iomem *mpc8xx_immr;
diff --git a/arch/powerpc/include/asm/pgtable-ppc32.h b/arch/powerpc/include/asm/pgtable-ppc32.h
index 64b52b1..022e008 100644
--- a/arch/powerpc/include/asm/pgtable-ppc32.h
+++ b/arch/powerpc/include/asm/pgtable-ppc32.h
@@ -113,7 +113,7 @@ extern int icache_44x_need_flush;
 #include <asm/pte-book3e.h>
 #elif defined(CONFIG_FSL_BOOKE)
 #include <asm/pte-fsl-booke.h>
-#elif defined(CONFIG_8xx)
+#elif defined(CONFIG_PPC_8xx)
 #include <asm/pte-8xx.h>
 #else /* CONFIG_6xx */
 #include <asm/pte-hash32.h>
diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
index 7e46125..c680989 100644
--- a/arch/powerpc/include/asm/ppc_asm.h
+++ b/arch/powerpc/include/asm/ppc_asm.h
@@ -389,7 +389,7 @@ BEGIN_FTR_SECTION_NESTED(96);		\
 	cmpwi dest,0;			\
 	beq-  90b;			\
 END_FTR_SECTION_NESTED(CPU_FTR_CELL_TB_BUG, CPU_FTR_CELL_TB_BUG, 96)
-#elif defined(CONFIG_8xx)
+#elif defined(CONFIG_PPC_8xx)
 #define MFTB(dest)			mftb dest
 #else
 #define MFTB(dest)			mfspr dest, SPRN_TBRL
@@ -440,7 +440,7 @@ END_FTR_SECTION_NESTED(CPU_FTR_HAS_PPR,CPU_FTR_HAS_PPR,945)
  * and they must be used.
  */
 
-#if !defined(CONFIG_4xx) && !defined(CONFIG_8xx)
+#if !defined(CONFIG_4xx) && !defined(CONFIG_PPC_8xx)
 #define tlbia					\
 	li	r4,1024;			\
 	mtctr	r4;				\
diff --git a/arch/powerpc/include/asm/reg.h b/arch/powerpc/include/asm/reg.h
index 1c874fb..6277c35 100644
--- a/arch/powerpc/include/asm/reg.h
+++ b/arch/powerpc/include/asm/reg.h
@@ -22,9 +22,9 @@
 #include <asm/reg_fsl_emb.h>
 #endif
 
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 #include <asm/reg_8xx.h>
-#endif /* CONFIG_8xx */
+#endif /* CONFIG_PPC_8xx */
 
 #define MSR_SF_LG	63              /* Enable 64 bit mode */
 #define MSR_ISF_LG	61              /* Interrupt 64b mode valid on 630 */
@@ -126,7 +126,7 @@
 #define MSR_KERNEL	(MSR_ | MSR_64BIT)
 #define MSR_USER32	(MSR_ | MSR_PR | MSR_EE)
 #define MSR_USER64	(MSR_USER32 | MSR_64BIT)
-#elif defined(CONFIG_PPC_BOOK3S_32) || defined(CONFIG_8xx)
+#elif defined(CONFIG_PPC_BOOK3S_32) || defined(CONFIG_PPC_8xx)
 /* Default MSR for kernel mode. */
 #define MSR_KERNEL	(MSR_ME|MSR_RI|MSR_IR|MSR_DR)
 #define MSR_USER	(MSR_KERNEL|MSR_PR|MSR_EE)
@@ -1058,7 +1058,7 @@
 #endif
 #endif
 
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 #define SPRN_SPRG_SCRATCH0	SPRN_SPRG0
 #define SPRN_SPRG_SCRATCH1	SPRN_SPRG1
 #define SPRN_SPRG_SCRATCH2	SPRN_SPRG2
@@ -1243,7 +1243,7 @@ static inline unsigned long mfvtb (void)
 
 #else /* __powerpc64__ */
 
-#if defined(CONFIG_8xx)
+#if defined(CONFIG_PPC_8xx)
 #define mftbl()		({unsigned long rval;	\
 			asm volatile("mftbl %0" : "=r" (rval)); rval;})
 #define mftbu()		({unsigned long rval;	\
diff --git a/arch/powerpc/include/asm/timex.h b/arch/powerpc/include/asm/timex.h
index 2cf846e..0fc017f 100644
--- a/arch/powerpc/include/asm/timex.h
+++ b/arch/powerpc/include/asm/timex.h
@@ -29,7 +29,7 @@ static inline cycles_t get_cycles(void)
 	ret = 0;
 
 	__asm__ __volatile__(
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 		"97:	mftb %0\n"
 #else
 		"97:	mfspr %0, %2\n"
@@ -45,7 +45,7 @@ static inline cycles_t get_cycles(void)
 		"	.long 0\n"
 		"	.long 0\n"
 		".previous"
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 		: "=r" (ret) : "i" (CPU_FTR_601));
 #else
 		: "=r" (ret) : "i" (CPU_FTR_601), "i" (SPRN_TBRL));
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 502cf69..c6032fc 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -84,7 +84,7 @@ extra-y				:= head_$(CONFIG_WORD_SIZE).o
 extra-$(CONFIG_40x)		:= head_40x.o
 extra-$(CONFIG_44x)		:= head_44x.o
 extra-$(CONFIG_FSL_BOOKE)	:= head_fsl_booke.o
-extra-$(CONFIG_8xx)		:= head_8xx.o
+extra-$(CONFIG_PPC_8xx)		:= head_8xx.o
 extra-y				+= vmlinux.lds
 
 obj-$(CONFIG_RELOCATABLE_PPC32)	+= reloc_32.o
diff --git a/arch/powerpc/kernel/cputable.c b/arch/powerpc/kernel/cputable.c
index f337666..598f9f8 100644
--- a/arch/powerpc/kernel/cputable.c
+++ b/arch/powerpc/kernel/cputable.c
@@ -1169,7 +1169,7 @@ static struct cpu_spec __initdata cpu_specs[] = {
 		.platform		= "ppc603",
 	},
 #endif /* CONFIG_PPC_BOOK3S_32 */
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 	{	/* 8xx */
 		.pvr_mask		= 0xffff0000,
 		.pvr_value		= 0x00500000,
@@ -1183,7 +1183,7 @@ static struct cpu_spec __initdata cpu_specs[] = {
 		.dcache_bsize		= 16,
 		.platform		= "ppc823",
 	},
-#endif /* CONFIG_8xx */
+#endif /* CONFIG_PPC_8xx */
 #ifdef CONFIG_40x
 	{	/* 403GC */
 		.pvr_mask		= 0xffffff00,
diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index 4509603..ebdba2e 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -24,7 +24,7 @@
  * mask register (of which only 16 are defined), hence the weird shifting
  * and complement of the cached_irq_mask.  I want to be able to stuff
  * this right into the SIU SMASK register.
- * Many of the prep/chrp functions are conditional compiled on CONFIG_8xx
+ * Many of the prep/chrp functions are conditional compiled on CONFIG_PPC_8xx
  * to reduce code space and undefined function references.
  */
 
diff --git a/arch/powerpc/kernel/kgdb.c b/arch/powerpc/kernel/kgdb.c
index e77c3cc..f4bc715 100644
--- a/arch/powerpc/kernel/kgdb.c
+++ b/arch/powerpc/kernel/kgdb.c
@@ -67,9 +67,9 @@ static struct hard_trap_info
 #endif
 #else /* ! (defined(CONFIG_40x) || defined(CONFIG_BOOKE)) */
 	{ 0x0d00, 0x05 /* SIGTRAP */ },		/* single-step */
-#if defined(CONFIG_8xx)
+#if defined(CONFIG_PPC_8xx)
 	{ 0x1000, 0x04 /* SIGILL */  },		/* software emulation */
-#else /* ! CONFIG_8xx */
+#else /* ! CONFIG_PPC_8xx */
 	{ 0x0f00, 0x04 /* SIGILL */  },		/* performance monitor */
 	{ 0x0f20, 0x08 /* SIGFPE */  },		/* altivec unavailable */
 	{ 0x1300, 0x05 /* SIGTRAP */ }, 	/* instruction address break */
diff --git a/arch/powerpc/kernel/misc_32.S b/arch/powerpc/kernel/misc_32.S
index 7c6bb4b..ba84868 100644
--- a/arch/powerpc/kernel/misc_32.S
+++ b/arch/powerpc/kernel/misc_32.S
@@ -297,7 +297,7 @@ _GLOBAL(real_writeb)
  * This is a no-op on the 601.
  */
 _GLOBAL(flush_instruction_cache)
-#if defined(CONFIG_8xx)
+#if defined(CONFIG_PPC_8xx)
 	isync
 	lis	r5, IDC_INVALL@h
 	mtspr	SPRN_IC_CST, r5
@@ -334,7 +334,7 @@ END_FTR_SECTION_IFSET(CPU_FTR_UNIFIED_ID_CACHE)
 	mfspr	r3,SPRN_HID0
 	ori	r3,r3,HID0_ICFI
 	mtspr	SPRN_HID0,r3
-#endif /* CONFIG_8xx/4xx */
+#endif /* CONFIG_PPC_8xx/CONFIG_4xx */
 	isync
 	blr
 
diff --git a/arch/powerpc/kernel/traps.c b/arch/powerpc/kernel/traps.c
index 19e4744..d2f1146 100644
--- a/arch/powerpc/kernel/traps.c
+++ b/arch/powerpc/kernel/traps.c
@@ -716,7 +716,7 @@ void machine_check_exception(struct pt_regs *regs)
 	if (recover > 0)
 		goto bail;
 
-#if defined(CONFIG_8xx) && defined(CONFIG_PCI)
+#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PCI)
 	/* the qspan pci read routines can cause machine checks -- Cort
 	 *
 	 * yuck !!! that totally needs to go away ! There are better ways
@@ -1524,7 +1524,7 @@ void performance_monitor_exception(struct pt_regs *regs)
 	perf_irq(regs);
 }
 
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 void SoftwareEmulation(struct pt_regs *regs)
 {
 	CHECK_FULL_REGS(regs);
@@ -1540,7 +1540,7 @@ void SoftwareEmulation(struct pt_regs *regs)
 
 	_exception(SIGILL, regs, ILL_ILLOPC, regs->nip);
 }
-#endif /* CONFIG_8xx */
+#endif /* CONFIG_PPC_8xx */
 
 #ifdef CONFIG_PPC_ADV_DEBUG_REGS
 static void handle_debug(struct pt_regs *regs, unsigned long debug_status)
diff --git a/arch/powerpc/kernel/vdso32/gettimeofday.S b/arch/powerpc/kernel/vdso32/gettimeofday.S
index 6b2b696..4bc65b4 100644
--- a/arch/powerpc/kernel/vdso32/gettimeofday.S
+++ b/arch/powerpc/kernel/vdso32/gettimeofday.S
@@ -232,7 +232,7 @@ __do_get_tspec:
 	lwz	r6,(CFG_TB_ORIG_STAMP+4)(r9)
 
 	/* Get a stable TB value */
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 2:	mftbu	r3
 	mftbl	r4
 	mftbu	r0
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index b396868..5bc2728 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -378,7 +378,7 @@ good_area:
 		   address matching DABR, eciwx, etc. */
 		goto bad_area;
 #endif /* CONFIG_6xx */
-#if defined(CONFIG_8xx)
+#if defined(CONFIG_PPC_8xx)
         /* The MPC8xx seems to always set 0x80000000, which is
          * "undefined".  Of those that can be set, this is the only
          * one which seems bad.
@@ -386,7 +386,7 @@ good_area:
 	if (error_code & 0x10000000)
                 /* Guarded storage error. */
 		goto bad_area;
-#endif /* CONFIG_8xx */
+#endif /* CONFIG_PPC_8xx */
 
 	if (is_exec) {
 		/*
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index a10be66..c64ac35 100644
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -194,7 +194,7 @@ void __init MMU_init(void)
 	memblock_set_current_limit(lowmem_end_addr);
 }
 
-#ifdef CONFIG_8xx /* No 8xx specific .c file to put that in ... */
+#ifdef CONFIG_PPC_8xx /* No 8xx specific .c file to put that in ... */
 void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 				phys_addr_t first_memblock_size)
 {
@@ -211,4 +211,4 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 	memblock_set_current_limit(min_t(u64, first_memblock_size, 0x00800000));
 #endif
 }
-#endif /* CONFIG_8xx */
+#endif /* CONFIG_PPC_8xx */
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index b7285a5..43b2e02 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -423,7 +423,7 @@ void flush_dcache_icache_page(struct page *page)
 		__flush_dcache_icache(start);
 		kunmap_atomic(start);
 	}
-#elif defined(CONFIG_8xx) || defined(CONFIG_PPC64)
+#elif defined(CONFIG_PPC_8xx) || defined(CONFIG_PPC64)
 	/* On 8xx there is no need to kmap since highmem is not supported */
 	__flush_dcache_icache(page_address(page)); 
 #else
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index 78c45f3..4669340 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -27,7 +27,7 @@
 /*
  * On 40x and 8xx, we directly inline tlbia and tlbivax
  */
-#if defined(CONFIG_40x) || defined(CONFIG_8xx)
+#if defined(CONFIG_40x) || defined(CONFIG_PPC_8xx)
 static inline void _tlbil_all(void)
 {
 	asm volatile ("sync; tlbia; isync" : : : "memory");
@@ -38,7 +38,7 @@ static inline void _tlbil_pid(unsigned int pid)
 }
 #define _tlbil_pid_noind(pid)	_tlbil_pid(pid)
 
-#else /* CONFIG_40x || CONFIG_8xx */
+#else /* CONFIG_40x || CONFIG_PPC_8xx */
 extern void _tlbil_all(void);
 extern void _tlbil_pid(unsigned int pid);
 #ifdef CONFIG_PPC_BOOK3E
@@ -46,12 +46,12 @@ extern void _tlbil_pid_noind(unsigned int pid);
 #else
 #define _tlbil_pid_noind(pid)	_tlbil_pid(pid)
 #endif
-#endif /* !(CONFIG_40x || CONFIG_8xx) */
+#endif /* !(CONFIG_40x || CONFIG_PPC_8xx) */
 
 /*
  * On 8xx, we directly inline tlbie, on others, it's extern
  */
-#ifdef CONFIG_8xx
+#ifdef CONFIG_PPC_8xx
 static inline void _tlbil_va(unsigned long address, unsigned int pid,
 			     unsigned int tsize, unsigned int ind)
 {
@@ -67,7 +67,7 @@ static inline void _tlbil_va(unsigned long address, unsigned int pid,
 {
 	__tlbil_va(address, pid);
 }
-#endif /* CONFIG_8xx */
+#endif /* CONFIG_PPC_8xx */
 
 #if defined(CONFIG_PPC_BOOK3E) || defined(CONFIG_PPC_47x)
 extern void _tlbivax_bcast(unsigned long address, unsigned int pid,
@@ -132,7 +132,7 @@ extern void wii_memory_fixups(void);
 /* ...and now those things that may be slightly different between processor
  * architectures.  -- Dan
  */
-#if defined(CONFIG_8xx)
+#if defined(CONFIG_PPC_8xx)
 #define MMU_init_hw()		do { } while(0)
 #define mmu_mapin_ram(top)	(0UL)
 
diff --git a/arch/powerpc/mm/tlb_nohash_low.S b/arch/powerpc/mm/tlb_nohash_low.S
index 43ff3c7..c282e56 100644
--- a/arch/powerpc/mm/tlb_nohash_low.S
+++ b/arch/powerpc/mm/tlb_nohash_low.S
@@ -60,7 +60,7 @@ _GLOBAL(__tlbil_va)
 	isync
 1:	blr
 
-#elif defined(CONFIG_8xx)
+#elif defined(CONFIG_PPC_8xx)
 
 /*
  * Nothing to do for 8xx, everything is inline
diff --git a/arch/powerpc/platforms/8xx/Kconfig b/arch/powerpc/platforms/8xx/Kconfig
index 1572504..8e01da6 100644
--- a/arch/powerpc/platforms/8xx/Kconfig
+++ b/arch/powerpc/platforms/8xx/Kconfig
@@ -5,7 +5,6 @@ config CPM1
 choice
 	prompt "8xx Machine Type"
 	depends on PPC_8xx
-	depends on 8xx
 	default MPC885ADS
 
 config MPC8XXFADS
@@ -92,7 +91,7 @@ endmenu
 #
 
 menu "MPC8xx CPM Options"
-	depends on 8xx
+	depends on PPC_8xx
 
 # This doesn't really belong here, but it is convenient to ask
 # 8xx specific questions.
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 76483e3..6d481ff 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -391,7 +391,7 @@ config NR_CPUS
 
 config NOT_COHERENT_CACHE
 	bool
-	depends on 4xx || 8xx || E200 || PPC_MPC512x || GAMECUBE_COMMON
+	depends on 4xx || PPC_8xx || E200 || PPC_MPC512x || GAMECUBE_COMMON
 	default n if PPC_47x
 	default y
 
diff --git a/arch/powerpc/sysdev/Makefile b/arch/powerpc/sysdev/Makefile
index f7cb2a1..8c70ee1 100644
--- a/arch/powerpc/sysdev/Makefile
+++ b/arch/powerpc/sysdev/Makefile
@@ -54,7 +54,7 @@ obj-$(CONFIG_CPM)		+= cpm_common.o
 obj-$(CONFIG_CPM2)		+= cpm2.o cpm2_pic.o
 obj-$(CONFIG_QUICC_ENGINE)	+= cpm_common.o
 obj-$(CONFIG_PPC_DCR)		+= dcr.o
-obj-$(CONFIG_8xx)		+= mpc8xx_pic.o cpm1.o
+obj-$(CONFIG_PPC_8xx)		+= mpc8xx_pic.o cpm1.o
 obj-$(CONFIG_UCODE_PATCH)	+= micropatch.o
 
 obj-$(CONFIG_PPC_MPC512x)	+= mpc5xxx_clocks.o
diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 99269c0..88f969b 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -103,7 +103,8 @@ u32 fsl_get_sys_freq(void)
 }
 EXPORT_SYMBOL(fsl_get_sys_freq);
 
-#if defined(CONFIG_CPM2) || defined(CONFIG_QUICC_ENGINE) || defined(CONFIG_8xx)
+#if defined(CONFIG_CPM2) || defined(CONFIG_QUICC_ENGINE) \
+    || defined(CONFIG_PPC_8xx)
 
 static u32 brgfreq = -1;
 
diff --git a/arch/powerpc/sysdev/fsl_soc.h b/arch/powerpc/sysdev/fsl_soc.h
index 4c5a19e..6aa94aa 100644
--- a/arch/powerpc/sysdev/fsl_soc.h
+++ b/arch/powerpc/sysdev/fsl_soc.h
@@ -7,7 +7,8 @@
 struct spi_device;
 
 extern phys_addr_t get_immrbase(void);
-#if defined(CONFIG_CPM2) || defined(CONFIG_QUICC_ENGINE) || defined(CONFIG_8xx)
+#if defined(CONFIG_CPM2) || defined(CONFIG_QUICC_ENGINE) \
+    || defined(CONFIG_PPC_8xx)
 extern u32 get_brgfreq(void);
 extern u32 get_baudrate(void);
 #else
diff --git a/arch/powerpc/xmon/xmon.c b/arch/powerpc/xmon/xmon.c
index e599259..b5197b3 100644
--- a/arch/powerpc/xmon/xmon.c
+++ b/arch/powerpc/xmon/xmon.c
@@ -1181,7 +1181,7 @@ bpt_cmds(void)
 
 	cmd = inchar();
 	switch (cmd) {
-#ifndef CONFIG_8xx
+#ifndef CONFIG_PPC_8xx
 	case 'd':	/* bd - hardware data breakpoint */
 		mode = 7;
 		cmd = inchar();
-- 
2.1.0
