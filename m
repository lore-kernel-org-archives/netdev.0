From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/4] Revert "powerpc/fsl: Move fsl_guts.h out of arch/powerpc"
Date: Mon, 30 May 2016 15:18:43 +0200
Message-ID: <5513501.AmZs7h1vI2@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com> <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Scott Wood <oss@buserror.net>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All users of this driver are PowerPC specific and the header file
has no business in the global include/linux/ hierarchy, so move
it back before anyone starts using it on ARM.

This reverts commit 948486544713492f00ac8a9572909101ea892cb0.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
This part of the series is not required for the eSDHC quirk,
but it restores the asm/fsl_guts.h header so it doesn't accidentally
get abused for this in the future. I found two drivers outside of
arch/powerpc that already accessed the registers directly, but the
functions look fairly contained, and can be easily hidden in an
#ifdef CONFIG_PPC

diff --git a/include/linux/fsl/guts.h b/arch/powerpc/include/asm/fsl_guts.h
similarity index 99%
rename from include/linux/fsl/guts.h
rename to arch/powerpc/include/asm/fsl_guts.h
index 649e9171a9b3..a67413c52701 100644
--- a/include/linux/fsl/guts.h
+++ b/arch/powerpc/include/asm/fsl_guts.h
@@ -12,10 +12,9 @@
  * option) any later version.
  */
 
-#ifndef __FSL_GUTS_H__
-#define __FSL_GUTS_H__
-
-#include <linux/types.h>
+#ifndef __ASM_POWERPC_FSL_GUTS_H__
+#define __ASM_POWERPC_FSL_GUTS_H__
+#ifdef __KERNEL__
 
 /**
  * Global Utility Registers.
@@ -295,3 +294,4 @@ struct ccsr_rcpm_v2 {
 };
 
 #endif
+#endif
diff --git a/arch/powerpc/platforms/85xx/mpc85xx_mds.c b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
index f61cbe235581..00f052e9f2a2 100644
--- a/arch/powerpc/platforms/85xx/mpc85xx_mds.c
+++ b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
@@ -34,7 +34,6 @@
 #include <linux/of_device.h>
 #include <linux/phy.h>
 #include <linux/memblock.h>
-#include <linux/fsl/guts.h>
 
 #include <linux/atomic.h>
 #include <asm/time.h>
@@ -52,6 +51,7 @@
 #include <soc/fsl/qe/qe_ic.h>
 #include <asm/mpic.h>
 #include <asm/swiotlb.h>
+#include <asm/fsl_guts.h>
 #include "smp.h"
 
 #include "mpc85xx.h"
diff --git a/arch/powerpc/platforms/85xx/mpc85xx_pm_ops.c b/arch/powerpc/platforms/85xx/mpc85xx_pm_ops.c
index f05325f0cc03..a812c0511252 100644
--- a/arch/powerpc/platforms/85xx/mpc85xx_pm_ops.c
+++ b/arch/powerpc/platforms/85xx/mpc85xx_pm_ops.c
@@ -14,8 +14,8 @@
 #include <linux/kernel.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
-#include <linux/fsl/guts.h>
 
+#include <asm/fsl_guts.h>
 #include <asm/io.h>
 #include <asm/fsl_pm.h>
 
diff --git a/arch/powerpc/platforms/85xx/mpc85xx_rdb.c b/arch/powerpc/platforms/85xx/mpc85xx_rdb.c
index 3f4dad133338..453ddda00fce 100644
--- a/arch/powerpc/platforms/85xx/mpc85xx_rdb.c
+++ b/arch/powerpc/platforms/85xx/mpc85xx_rdb.c
@@ -17,7 +17,6 @@
 #include <linux/seq_file.h>
 #include <linux/interrupt.h>
 #include <linux/of_platform.h>
-#include <linux/fsl/guts.h>
 
 #include <asm/time.h>
 #include <asm/machdep.h>
@@ -28,6 +27,7 @@
 #include <asm/mpic.h>
 #include <soc/fsl/qe/qe.h>
 #include <soc/fsl/qe/qe_ic.h>
+#include <asm/fsl_guts.h>
 
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
diff --git a/arch/powerpc/platforms/85xx/p1022_ds.c b/arch/powerpc/platforms/85xx/p1022_ds.c
index 371df822e88e..6ac986d3f8a3 100644
--- a/arch/powerpc/platforms/85xx/p1022_ds.c
+++ b/arch/powerpc/platforms/85xx/p1022_ds.c
@@ -16,7 +16,6 @@
  * kind, whether express or implied.
  */
 
-#include <linux/fsl/guts.h>
 #include <linux/pci.h>
 #include <linux/of_platform.h>
 #include <asm/div64.h>
@@ -26,6 +25,7 @@
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 #include <asm/udbg.h>
+#include <asm/fsl_guts.h>
 #include <asm/fsl_lbc.h>
 #include "smp.h"
 
diff --git a/arch/powerpc/platforms/85xx/p1022_rdk.c b/arch/powerpc/platforms/85xx/p1022_rdk.c
index 5087becaa8bc..680232d6ba48 100644
--- a/arch/powerpc/platforms/85xx/p1022_rdk.c
+++ b/arch/powerpc/platforms/85xx/p1022_rdk.c
@@ -12,7 +12,6 @@
  * kind, whether express or implied.
  */
 
-#include <linux/fsl/guts.h>
 #include <linux/pci.h>
 #include <linux/of_platform.h>
 #include <asm/div64.h>
@@ -22,6 +21,7 @@
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 #include <asm/udbg.h>
+#include <asm/fsl_guts.h>
 #include "smp.h"
 
 #include "mpc85xx.h"
diff --git a/arch/powerpc/platforms/85xx/smp.c b/arch/powerpc/platforms/85xx/smp.c
index fe9f19e5e935..6bd3a292e790 100644
--- a/arch/powerpc/platforms/85xx/smp.c
+++ b/arch/powerpc/platforms/85xx/smp.c
@@ -18,7 +18,6 @@
 #include <linux/kexec.h>
 #include <linux/highmem.h>
 #include <linux/cpu.h>
-#include <linux/fsl/guts.h>
 
 #include <asm/machdep.h>
 #include <asm/pgtable.h>
@@ -26,6 +25,7 @@
 #include <asm/mpic.h>
 #include <asm/cacheflush.h>
 #include <asm/dbell.h>
+#include <asm/fsl_guts.h>
 #include <asm/code-patching.h>
 #include <asm/cputhreads.h>
 #include <asm/fsl_pm.h>
diff --git a/arch/powerpc/platforms/85xx/twr_p102x.c b/arch/powerpc/platforms/85xx/twr_p102x.c
index 71bc255b4324..2cac45f72d24 100644
--- a/arch/powerpc/platforms/85xx/twr_p102x.c
+++ b/arch/powerpc/platforms/85xx/twr_p102x.c
@@ -15,7 +15,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/errno.h>
-#include <linux/fsl/guts.h>
 #include <linux/pci.h>
 #include <linux/of_platform.h>
 
@@ -24,6 +23,7 @@
 #include <asm/mpic.h>
 #include <soc/fsl/qe/qe.h>
 #include <soc/fsl/qe/qe_ic.h>
+#include <asm/fsl_guts.h>
 
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
diff --git a/arch/powerpc/platforms/86xx/mpc8610_hpcd.c b/arch/powerpc/platforms/86xx/mpc8610_hpcd.c
index 957473e5c8e5..761c81476957 100644
--- a/arch/powerpc/platforms/86xx/mpc8610_hpcd.c
+++ b/arch/powerpc/platforms/86xx/mpc8610_hpcd.c
@@ -24,7 +24,6 @@
 #include <linux/delay.h>
 #include <linux/seq_file.h>
 #include <linux/of.h>
-#include <linux/fsl/guts.h>
 
 #include <asm/time.h>
 #include <asm/machdep.h>
@@ -39,6 +38,7 @@
 #include <sysdev/fsl_pci.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/simple_gpio.h>
+#include <asm/fsl_guts.h>
 
 #include "mpc86xx.h"
 
diff --git a/arch/powerpc/sysdev/fsl_rcpm.c b/arch/powerpc/sysdev/fsl_rcpm.c
index 9259a94f70e1..8af22187cb25 100644
--- a/arch/powerpc/sysdev/fsl_rcpm.c
+++ b/arch/powerpc/sysdev/fsl_rcpm.c
@@ -19,7 +19,7 @@
 #include <linux/export.h>
 
 #include <asm/io.h>
-#include <linux/fsl/guts.h>
+#include <asm/fsl_guts.h>
 #include <asm/cputhreads.h>
 #include <asm/fsl_pm.h>
 #include <asm/smp.h>
diff --git a/drivers/clk/clk-qoriq.c b/drivers/clk/clk-qoriq.c
index 58566a17944a..f311bd399672 100644
--- a/drivers/clk/clk-qoriq.c
+++ b/drivers/clk/clk-qoriq.c
@@ -12,7 +12,6 @@
 
 #include <linux/clk.h>
 #include <linux/clk-provider.h>
-#include <linux/fsl/guts.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -21,6 +20,10 @@
 #include <linux/of.h>
 #include <linux/slab.h>
 
+#ifdef CONFIG_PPC
+#include <asm/fsl_guts.h>
+#endif
+
 #define PLL_DIV1	0
 #define PLL_DIV2	1
 #define PLL_DIV3	2
@@ -341,6 +344,8 @@ static const struct clockgen_muxinfo t4240_hwa5 = {
 	},
 };
 
+#ifdef CONFIG_PPC
+
 #define RCWSR7_FM1_CLK_SEL	0x40000000
 #define RCWSR7_FM2_CLK_SEL	0x20000000
 #define RCWSR7_HWA_ASYNC_DIV	0x04000000
@@ -408,6 +413,7 @@ static void __init p5040_init_periph(struct clockgen *cg)
 	else
 		cg->fman[1] = cg->pll[PLATFORM_PLL].div[PLL_DIV2].clk;
 }
+#endif
 
 static void __init t1023_init_periph(struct clockgen *cg)
 {
@@ -499,6 +505,7 @@ static const struct clockgen_chipinfo chipinfo[] = {
 		.pll_mask = 0x37,
 		.flags = CG_VER3 | CG_LITTLE_ENDIAN,
 	},
+#ifdef CONFIG_PPC
 	{
 		.compat = "fsl,p2041-clockgen",
 		.guts_compat = "fsl,qoriq-device-config-1.0",
@@ -559,6 +566,7 @@ static const struct clockgen_chipinfo chipinfo[] = {
 		},
 		.pll_mask = 0x0f,
 	},
+#endif
 	{
 		.compat = "fsl,t1023-clockgen",
 		.guts_compat = "fsl,t1023-device-config",
diff --git a/drivers/iommu/fsl_pamu.c b/drivers/iommu/fsl_pamu.c
index a34355fca37a..2570f2a25dc4 100644
--- a/drivers/iommu/fsl_pamu.c
+++ b/drivers/iommu/fsl_pamu.c
@@ -20,11 +20,11 @@
 
 #include "fsl_pamu.h"
 
-#include <linux/fsl/guts.h>
 #include <linux/interrupt.h>
 #include <linux/genalloc.h>
 
 #include <asm/mpc85xx.h>
+#include <asm/fsl_guts.h>
 
 /* define indexes for each operation mapping scenario */
 #define OMI_QMAN        0x00
diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 1de2e1e51c2b..dabee93fcadd 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -35,7 +35,6 @@
 #include "fman.h"
 #include "fman_muram.h"
 
-#include <linux/fsl/guts.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/module.h>
@@ -46,6 +45,10 @@
 #include <linux/interrupt.h>
 #include <linux/libfdt_env.h>
 
+#ifdef CONFIG_PPC
+#include <asm/fsl_guts.h>
+#endif
+
 /* General defines */
 #define FMAN_LIODN_TBL			64	/* size of LIODN table */
 #define MAX_NUM_OF_MACS			10
@@ -1889,7 +1892,9 @@ static int fman_reset(struct fman *fman)
 			err = -EBUSY;
 
 		goto _return;
-	} else {
+	}
+#ifdef CONFIG_PPC
+	else {
 		struct device_node *guts_node;
 		struct ccsr_guts __iomem *guts_regs;
 		u32 devdisr2, reg;
@@ -1952,6 +1957,7 @@ guts_node:
 		dev_dbg(fman->dev, "%s: Didn't perform FManV3 reset due to Errata A007273!\n",
 			__func__);
 	}
+#endif
 _return:
 	return err;
 }
diff --git a/sound/soc/fsl/mpc8610_hpcd.c b/sound/soc/fsl/mpc8610_hpcd.c
index ddf49f30b23f..73b2b89d4a3e 100644
--- a/sound/soc/fsl/mpc8610_hpcd.c
+++ b/sound/soc/fsl/mpc8610_hpcd.c
@@ -12,11 +12,11 @@
 
 #include <linux/module.h>
 #include <linux/interrupt.h>
-#include <linux/fsl/guts.h>
 #include <linux/of_address.h>
 #include <linux/of_device.h>
 #include <linux/slab.h>
 #include <sound/soc.h>
+#include <asm/fsl_guts.h>
 
 #include "fsl_dma.h"
 #include "fsl_ssi.h"
diff --git a/sound/soc/fsl/p1022_ds.c b/sound/soc/fsl/p1022_ds.c
index a1f780ecadf5..a24e04919f71 100644
--- a/sound/soc/fsl/p1022_ds.c
+++ b/sound/soc/fsl/p1022_ds.c
@@ -11,12 +11,12 @@
  */
 
 #include <linux/module.h>
-#include <linux/fsl/guts.h>
 #include <linux/interrupt.h>
 #include <linux/of_address.h>
 #include <linux/of_device.h>
 #include <linux/slab.h>
 #include <sound/soc.h>
+#include <asm/fsl_guts.h>
 
 #include "fsl_dma.h"
 #include "fsl_ssi.h"
diff --git a/sound/soc/fsl/p1022_rdk.c b/sound/soc/fsl/p1022_rdk.c
index d4d88a8cb9c0..d8448887bfda 100644
--- a/sound/soc/fsl/p1022_rdk.c
+++ b/sound/soc/fsl/p1022_rdk.c
@@ -18,12 +18,12 @@
  */
 
 #include <linux/module.h>
-#include <linux/fsl/guts.h>
 #include <linux/interrupt.h>
 #include <linux/of_address.h>
 #include <linux/of_device.h>
 #include <linux/slab.h>
 #include <sound/soc.h>
+#include <asm/fsl_guts.h>
 
 #include "fsl_dma.h"
 #include "fsl_ssi.h"

