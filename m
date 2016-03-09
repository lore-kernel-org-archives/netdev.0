From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v6, 4/5] powerpc/fsl: move mpc85xx.h to include/linux/fsl
Date: Wed, 9 Mar 2016 18:08:50 +0800
Message-ID: <1457518131-11339-5-git-send-email-yangbo.lu@nxp.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>, <scott.wood@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	<ulf.hansson@linaro.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"Zhao Qiang" <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	"Santosh Shilimkar" <ssantosh@kernel.org>, <leoyang.li@nxp.com>,
	<xiaobo.xie@nxp.com>, Yangbo Lu <yangbo.lu@nxp.com>
To: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-clk@vger.kernel.org>, <linux-i2c@vger.kernel.org>,
	<iommu@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-mmc@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0053.outbound.protection.outlook.com ([157.56.110.53]:57440
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752395AbcCIKSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 05:18:51 -0500
In-Reply-To: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move mpc85xx.h to include/linux/fsl and rename it to svr.h as
a common header file. It has been used for mpc85xx and it will
be used for ARM-based SoC as well.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
Changes for v2:
	- None
Changes for v3:
	- None
Changes for v4:
	- None
Changes for v5:
	- Changed to Move mpc85xx.h to include/linux/fsl/
	- Adjusted '#include <linux/fsl/svr.h>' position in file
Changes for v6:
	- None
---
 drivers/clk/clk-qoriq.c                                       | 3 +--
 drivers/i2c/busses/i2c-mpc.c                                  | 2 +-
 drivers/iommu/fsl_pamu.c                                      | 3 +--
 drivers/net/ethernet/freescale/gianfar.c                      | 2 +-
 arch/powerpc/include/asm/mpc85xx.h => include/linux/fsl/svr.h | 4 ++--
 5 files changed, 6 insertions(+), 8 deletions(-)
 rename arch/powerpc/include/asm/mpc85xx.h => include/linux/fsl/svr.h (97%)

diff --git a/drivers/clk/clk-qoriq.c b/drivers/clk/clk-qoriq.c
index 7bc1c45..fc7f722 100644
--- a/drivers/clk/clk-qoriq.c
+++ b/drivers/clk/clk-qoriq.c
@@ -13,6 +13,7 @@
 #include <linux/clk.h>
 #include <linux/clk-provider.h>
 #include <linux/fsl/guts.h>
+#include <linux/fsl/svr.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -1148,8 +1149,6 @@ bad_args:
 }
 
 #ifdef CONFIG_PPC
-#include <asm/mpc85xx.h>
-
 static const u32 a4510_svrs[] __initconst = {
 	(SVR_P2040 << 8) | 0x10,	/* P2040 1.0 */
 	(SVR_P2040 << 8) | 0x11,	/* P2040 1.1 */
diff --git a/drivers/i2c/busses/i2c-mpc.c b/drivers/i2c/busses/i2c-mpc.c
index 48ecffe..600704c 100644
--- a/drivers/i2c/busses/i2c-mpc.c
+++ b/drivers/i2c/busses/i2c-mpc.c
@@ -27,9 +27,9 @@
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
+#include <linux/fsl/svr.h>
 
 #include <asm/mpc52xx.h>
-#include <asm/mpc85xx.h>
 #include <sysdev/fsl_soc.h>
 
 #define DRV_NAME "mpc-i2c"
diff --git a/drivers/iommu/fsl_pamu.c b/drivers/iommu/fsl_pamu.c
index a34355f..af8fb27 100644
--- a/drivers/iommu/fsl_pamu.c
+++ b/drivers/iommu/fsl_pamu.c
@@ -21,11 +21,10 @@
 #include "fsl_pamu.h"
 
 #include <linux/fsl/guts.h>
+#include <linux/fsl/svr.h>
 #include <linux/interrupt.h>
 #include <linux/genalloc.h>
 
-#include <asm/mpc85xx.h>
-
 /* define indexes for each operation mapping scenario */
 #define OMI_QMAN        0x00
 #define OMI_FMAN        0x01
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2aa7b40..675da4a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -86,11 +86,11 @@
 #include <linux/udp.h>
 #include <linux/in.h>
 #include <linux/net_tstamp.h>
+#include <linux/fsl/svr.h>
 
 #include <asm/io.h>
 #ifdef CONFIG_PPC
 #include <asm/reg.h>
-#include <asm/mpc85xx.h>
 #endif
 #include <asm/irq.h>
 #include <asm/uaccess.h>
diff --git a/arch/powerpc/include/asm/mpc85xx.h b/include/linux/fsl/svr.h
similarity index 97%
rename from arch/powerpc/include/asm/mpc85xx.h
rename to include/linux/fsl/svr.h
index 213f3a8..8d13836 100644
--- a/arch/powerpc/include/asm/mpc85xx.h
+++ b/include/linux/fsl/svr.h
@@ -9,8 +9,8 @@
  * (at your option) any later version.
  */
 
-#ifndef __ASM_PPC_MPC85XX_H
-#define __ASM_PPC_MPC85XX_H
+#ifndef FSL_SVR_H
+#define FSL_SVR_H
 
 #define SVR_REV(svr)	((svr) & 0xFF)		/* SOC design resision */
 #define SVR_MAJ(svr)	(((svr) >>  4) & 0xF)	/* Major revision field*/
-- 
2.1.0.27.g96db324
