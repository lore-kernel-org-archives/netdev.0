From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: remove platform data header file of cpsw
Date: Mon, 19 Aug 2013 17:47:40 +0530
Message-ID: <1376914660-20431-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:48884 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334Ab3HSMRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 08:17:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPSW driver no longer supports platform register as all the SoCs which has CPSW
are supporting DT only booting, so moving cpsw.h header file from platform
include to drivers/net/ethernet/ti

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c     |  2 +-
 drivers/net/ethernet/ti/cpsw.h     | 42 ++++++++++++++++++++++++++++++++++++
 include/linux/platform_data/cpsw.h | 44 --------------------------------------
 3 files changed, 43 insertions(+), 45 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw.h
 delete mode 100644 include/linux/platform_data/cpsw.h

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0fcf212..b4a85f5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -34,9 +34,9 @@
 #include <linux/of_device.h>
 #include <linux/if_vlan.h>
 
-#include <linux/platform_data/cpsw.h>
 #include <linux/pinctrl/consumer.h>
 
+#include "cpsw.h"
 #include "cpsw_ale.h"
 #include "cpts.h"
 #include "davinci_cpdma.h"
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
new file mode 100644
index 0000000..eb3e101
--- /dev/null
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -0,0 +1,42 @@
+/* Texas Instruments Ethernet Switch Driver
+ *
+ * Copyright (C) 2013 Texas Instruments
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#ifndef __CPSW_H__
+#define __CPSW_H__
+
+#include <linux/if_ether.h>
+
+struct cpsw_slave_data {
+	char		phy_id[MII_BUS_ID_SIZE];
+	int		phy_if;
+	u8		mac_addr[ETH_ALEN];
+	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
+};
+
+struct cpsw_platform_data {
+	struct cpsw_slave_data	*slave_data;
+	u32	ss_reg_ofs;	/* Subsystem control register offset */
+	u32	channels;	/* number of cpdma channels (symmetric) */
+	u32	slaves;		/* number of slave cpgmac ports */
+	u32	active_slave; /* time stamping, ethtool and SIOCGMIIPHY slave */
+	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
+	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
+	u32	ale_entries;	/* ale table size */
+	u32	bd_ram_size;  /*buffer descriptor ram size */
+	u32	rx_descs;	/* Number of Rx Descriptios */
+	u32	mac_control;	/* Mac control register */
+	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
+	bool	dual_emac;	/* Enable Dual EMAC mode */
+};
+
+#endif /* __CPSW_H__ */
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
deleted file mode 100644
index bb3cd58..0000000
--- a/include/linux/platform_data/cpsw.h
+++ /dev/null
@@ -1,44 +0,0 @@
-/*
- * Texas Instruments Ethernet Switch Driver
- *
- * Copyright (C) 2012 Texas Instruments
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License as
- * published by the Free Software Foundation version 2.
- *
- * This program is distributed "as is" WITHOUT ANY WARRANTY of any
- * kind, whether express or implied; without even the implied warranty
- * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- */
-#ifndef __CPSW_H__
-#define __CPSW_H__
-
-#include <linux/if_ether.h>
-
-struct cpsw_slave_data {
-	char		phy_id[MII_BUS_ID_SIZE];
-	int		phy_if;
-	u8		mac_addr[ETH_ALEN];
-	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
-
-};
-
-struct cpsw_platform_data {
-	u32	ss_reg_ofs;	/* Subsystem control register offset */
-	u32	channels;	/* number of cpdma channels (symmetric) */
-	u32	slaves;		/* number of slave cpgmac ports */
-	struct cpsw_slave_data	*slave_data;
-	u32	active_slave; /* time stamping, ethtool and SIOCGMIIPHY slave */
-	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
-	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
-	u32	ale_entries;	/* ale table size */
-	u32	bd_ram_size;  /*buffer descriptor ram size */
-	u32	rx_descs;	/* Number of Rx Descriptios */
-	u32	mac_control;	/* Mac control register */
-	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
-	bool	dual_emac;	/* Enable Dual EMAC mode */
-};
-
-#endif /* __CPSW_H__ */
-- 
1.8.4.rc1.21.gfb56570
