From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 1/3] TI Davinci EMAC : Re-use driver for other platforms.
Date: Wed, 18 Nov 2009 15:12:06 +0530
Message-ID: <1258537328-31527-2-git-send-email-srk@ti.com>
References: <1258537328-31527-1-git-send-email-srk@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:56557 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbZKRJmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 04:42:10 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAI9gDaF010849
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 03:42:16 -0600
In-Reply-To: <1258537328-31527-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The davinci EMAC peripheral is also available on other TI
platforms -notably TI AM3517 SoC. This patch modifies the
config option and the platform structure header files so that
the driver can be reused on non-davinci platforms as well.

Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Chaithrika U S <chaithrika@ti.com>
---
 arch/arm/mach-davinci/board-dm644x-evm.c    |    2 +-
 arch/arm/mach-davinci/board-dm646x-evm.c    |    2 +-
 arch/arm/mach-davinci/common.c              |    2 +-
 arch/arm/mach-davinci/include/mach/da8xx.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 arch/arm/mach-davinci/include/mach/emac.h   |   36 ---------------------------
 drivers/net/Kconfig                         |    2 +-
 drivers/net/davinci_emac.c                  |    3 +-
 include/linux/davinci_emac.h                |   36 +++++++++++++++++++++++++++
 11 files changed, 45 insertions(+), 46 deletions(-)
 delete mode 100644 arch/arm/mach-davinci/include/mach/emac.h
 create mode 100644 include/linux/davinci_emac.h

diff --git a/arch/arm/mach-davinci/board-dm644x-evm.c b/arch/arm/mach-davinci/board-dm644x-evm.c
index 1213a00..e930281 100644
--- a/arch/arm/mach-davinci/board-dm644x-evm.c
+++ b/arch/arm/mach-davinci/board-dm644x-evm.c
@@ -29,6 +29,7 @@
 #include <linux/phy.h>
 #include <linux/clk.h>
 #include <linux/videodev2.h>
+#include <linux/davinci_emac.h>
 
 #include <media/tvp514x.h>
 
@@ -47,7 +48,6 @@
 #include <mach/psc.h>
 #include <mach/nand.h>
 #include <mach/mmc.h>
-#include <mach/emac.h>
 
 #define DM644X_EVM_PHY_MASK		(0x2)
 #define DM644X_EVM_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
diff --git a/arch/arm/mach-davinci/board-dm646x-evm.c b/arch/arm/mach-davinci/board-dm646x-evm.c
index 24e0e13..6f9fe36 100644
--- a/arch/arm/mach-davinci/board-dm646x-evm.c
+++ b/arch/arm/mach-davinci/board-dm646x-evm.c
@@ -33,6 +33,7 @@
 #include <linux/i2c/at24.h>
 #include <linux/i2c/pcf857x.h>
 #include <linux/etherdevice.h>
+#include <linux/davinci_emac.h>
 
 #include <media/tvp514x.h>
 
@@ -48,7 +49,6 @@
 #include <mach/serial.h>
 #include <mach/i2c.h>
 #include <mach/mmc.h>
-#include <mach/emac.h>
 
 #if defined(CONFIG_BLK_DEV_PALMCHIP_BK3710) || \
     defined(CONFIG_BLK_DEV_PALMCHIP_BK3710_MODULE)
diff --git a/arch/arm/mach-davinci/common.c b/arch/arm/mach-davinci/common.c
index 61ede19..d62398b 100644
--- a/arch/arm/mach-davinci/common.c
+++ b/arch/arm/mach-davinci/common.c
@@ -11,13 +11,13 @@
 #include <linux/module.h>
 #include <linux/io.h>
 #include <linux/etherdevice.h>
+#include <linux/davinci_emac.h>
 
 #include <asm/tlb.h>
 #include <asm/mach/map.h>
 
 #include <mach/common.h>
 #include <mach/cputype.h>
-#include <mach/emac.h>
 
 #include "clock.h"
 
diff --git a/arch/arm/mach-davinci/include/mach/da8xx.h b/arch/arm/mach-davinci/include/mach/da8xx.h
index d4095d0..f056178 100644
--- a/arch/arm/mach-davinci/include/mach/da8xx.h
+++ b/arch/arm/mach-davinci/include/mach/da8xx.h
@@ -11,10 +11,10 @@
 #ifndef __ASM_ARCH_DAVINCI_DA8XX_H
 #define __ASM_ARCH_DAVINCI_DA8XX_H
 
+#include <linux/davinci_emac.h>
 #include <mach/serial.h>
 #include <mach/edma.h>
 #include <mach/i2c.h>
-#include <mach/emac.h>
 #include <mach/asp.h>
 #include <mach/mmc.h>
 
diff --git a/arch/arm/mach-davinci/include/mach/dm365.h b/arch/arm/mach-davinci/include/mach/dm365.h
index 09db434..f2e34d8 100644
--- a/arch/arm/mach-davinci/include/mach/dm365.h
+++ b/arch/arm/mach-davinci/include/mach/dm365.h
@@ -14,8 +14,8 @@
 #define __ASM_ARCH_DM665_H
 
 #include <linux/platform_device.h>
+#include <linux/davinci_emac.h>
 #include <mach/hardware.h>
-#include <mach/emac.h>
 
 #define DM365_EMAC_BASE			(0x01D07000)
 #define DM365_EMAC_CNTRL_OFFSET		(0x0000)
diff --git a/arch/arm/mach-davinci/include/mach/dm644x.h b/arch/arm/mach-davinci/include/mach/dm644x.h
index 0efb738..dad3622 100644
--- a/arch/arm/mach-davinci/include/mach/dm644x.h
+++ b/arch/arm/mach-davinci/include/mach/dm644x.h
@@ -23,8 +23,8 @@
 #define __ASM_ARCH_DM644X_H
 
 #include <linux/platform_device.h>
+#include <linux/davinci_emac.h>
 #include <mach/hardware.h>
-#include <mach/emac.h>
 #include <mach/asp.h>
 #include <media/davinci/vpfe_capture.h>
 
diff --git a/arch/arm/mach-davinci/include/mach/dm646x.h b/arch/arm/mach-davinci/include/mach/dm646x.h
index 8cec746..5c92dfb 100644
--- a/arch/arm/mach-davinci/include/mach/dm646x.h
+++ b/arch/arm/mach-davinci/include/mach/dm646x.h
@@ -12,10 +12,10 @@
 #define __ASM_ARCH_DM646X_H
 
 #include <mach/hardware.h>
-#include <mach/emac.h>
 #include <mach/asp.h>
 #include <linux/i2c.h>
 #include <linux/videodev2.h>
+#include <linux/davinci_emac.h>
 
 #define DM646X_EMAC_BASE		(0x01C80000)
 #define DM646X_EMAC_CNTRL_OFFSET	(0x0000)
diff --git a/arch/arm/mach-davinci/include/mach/emac.h b/arch/arm/mach-davinci/include/mach/emac.h
deleted file mode 100644
index beff4fb..0000000
--- a/arch/arm/mach-davinci/include/mach/emac.h
+++ /dev/null
@@ -1,36 +0,0 @@
-/*
- * TI DaVinci EMAC platform support
- *
- * Author: Kevin Hilman, Deep Root Systems, LLC
- *
- * 2007 (c) Deep Root Systems, LLC. This file is licensed under
- * the terms of the GNU General Public License version 2. This program
- * is licensed "as is" without any warranty of any kind, whether express
- * or implied.
- */
-#ifndef _MACH_DAVINCI_EMAC_H
-#define _MACH_DAVINCI_EMAC_H
-
-#include <linux/if_ether.h>
-#include <linux/memory.h>
-
-struct emac_platform_data {
-	char mac_addr[ETH_ALEN];
-	u32 ctrl_reg_offset;
-	u32 ctrl_mod_reg_offset;
-	u32 ctrl_ram_offset;
-	u32 mdio_reg_offset;
-	u32 ctrl_ram_size;
-	u32 phy_mask;
-	u32 mdio_max_freq;
-	u8 rmii_en;
-	u8 version;
-};
-
-enum {
-	EMAC_VERSION_1,	/* DM644x */
-	EMAC_VERSION_2,	/* DM646x */
-};
-
-void davinci_get_mac_addr(struct memory_accessor *mem_acc, void *context);
-#endif
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e19ca4b..2d3443c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -920,7 +920,7 @@ config NET_NETX
 
 config TI_DAVINCI_EMAC
 	tristate "TI DaVinci EMAC Support"
-	depends on ARM && ARCH_DAVINCI
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
 	select PHYLIB
 	help
 	  This driver supports TI's DaVinci Ethernet .
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 4cf80ec..6aec8f5 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -62,12 +62,11 @@
 #include <linux/bitops.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
+#include <linux/davinci_emac.h>
 
 #include <asm/irq.h>
 #include <asm/page.h>
 
-#include <mach/emac.h>
-
 static int debug_level;
 module_param(debug_level, int, 0);
 MODULE_PARM_DESC(debug_level, "DaVinci EMAC debug level (NETIF_MSG bits)");
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
new file mode 100644
index 0000000..ff55487
--- /dev/null
+++ b/include/linux/davinci_emac.h
@@ -0,0 +1,36 @@
+/*
+ * TI DaVinci EMAC platform support
+ *
+ * Author: Kevin Hilman, Deep Root Systems, LLC
+ *
+ * 2007 (c) Deep Root Systems, LLC. This file is licensed under
+ * the terms of the GNU General Public License version 2. This program
+ * is licensed "as is" without any warranty of any kind, whether express
+ * or implied.
+ */
+#ifndef _LINUX_DAVINCI_EMAC_H
+#define _LINUX_DAVINCI_EMAC_H
+
+#include <linux/if_ether.h>
+#include <linux/memory.h>
+
+struct emac_platform_data {
+	char mac_addr[ETH_ALEN];
+	u32 ctrl_reg_offset;
+	u32 ctrl_mod_reg_offset;
+	u32 ctrl_ram_offset;
+	u32 mdio_reg_offset;
+	u32 ctrl_ram_size;
+	u32 phy_mask;
+	u32 mdio_max_freq;
+	u8 rmii_en;
+	u8 version;
+};
+
+enum {
+	EMAC_VERSION_1,	/* DM644x */
+	EMAC_VERSION_2,	/* DM646x */
+};
+
+void davinci_get_mac_addr(struct memory_accessor *mem_acc, void *context);
+#endif
-- 
1.6.2.4

