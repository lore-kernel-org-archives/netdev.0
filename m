From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH-v2 1/3] TI Davinci EMAC : Re-use driver for other platforms.
Date: Thu, 19 Nov 2009 15:58:25 +0530
Message-ID: <1258626507-5570-2-git-send-email-srk@ti.com>
References: <1258626507-5570-1-git-send-email-srk@ti.com>
Cc: netdev@vger.kernel.org, Sriramakrishnan <srk@ti.com>
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60626 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101AbZKSK23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 05:28:29 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAJASWA6011840
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 04:28:34 -0600
In-Reply-To: <1258626507-5570-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The davinci EMAC peripheral is also available on other TI
platforms -notably TI AM3517 SoC. This patch modifies the
config option and the platform structure header files so that
the driver can be reused on non-davinci platforms as well.

Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Chaithrika U S <chaithrika@ti.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/arm/mach-davinci/common.c              |    2 +-
 arch/arm/mach-davinci/include/mach/da8xx.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 arch/arm/mach-davinci/include/mach/emac.h   |   36 ---------------------------
 drivers/net/Kconfig                         |    2 +-
 drivers/net/davinci_emac.c                  |    3 +-
 include/linux/davinci_emac.h                |   36 +++++++++++++++++++++++++++
 9 files changed, 43 insertions(+), 44 deletions(-)
 delete mode 100644 arch/arm/mach-davinci/include/mach/emac.h
 create mode 100644 include/linux/davinci_emac.h

diff --git a/arch/arm/mach-davinci/common.c b/arch/arm/mach-davinci/common.c
index c2de94c..94f27cb 100644
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
index 9070491..2af95ff 100644
--- a/arch/arm/mach-davinci/include/mach/da8xx.h
+++ b/arch/arm/mach-davinci/include/mach/da8xx.h
@@ -13,10 +13,10 @@
 
 #include <video/da8xx-fb.h>
 
+#include <linux/davinci_emac.h>
 #include <mach/serial.h>
 #include <mach/edma.h>
 #include <mach/i2c.h>
-#include <mach/emac.h>
 #include <mach/asp.h>
 #include <mach/mmc.h>
 #include <mach/usb.h>
diff --git a/arch/arm/mach-davinci/include/mach/dm365.h b/arch/arm/mach-davinci/include/mach/dm365.h
index f1710a3..3c07a88 100644
--- a/arch/arm/mach-davinci/include/mach/dm365.h
+++ b/arch/arm/mach-davinci/include/mach/dm365.h
@@ -14,8 +14,8 @@
 #define __ASM_ARCH_DM665_H
 
 #include <linux/platform_device.h>
+#include <linux/davinci_emac.h>
 #include <mach/hardware.h>
-#include <mach/emac.h>
 #include <mach/asp.h>
 #include <mach/keyscan.h>
 
diff --git a/arch/arm/mach-davinci/include/mach/dm644x.h b/arch/arm/mach-davinci/include/mach/dm644x.h
index 44e8f0f..1a8b09c 100644
--- a/arch/arm/mach-davinci/include/mach/dm644x.h
+++ b/arch/arm/mach-davinci/include/mach/dm644x.h
@@ -22,8 +22,8 @@
 #ifndef __ASM_ARCH_DM644X_H
 #define __ASM_ARCH_DM644X_H
 
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

