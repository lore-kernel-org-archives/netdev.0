From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 1/2] net: phy: smsc: Move SMSC PHY constants to <linux/smscphy.h>
Date: Mon,  2 Jan 2012 18:08:50 +0100
Message-ID: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>,
	netdev@vger.kernel.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46112 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab2ABRIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 12:08:07 -0500
Received: by wgbdr13 with SMTP id dr13so26809211wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 09:08:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMSC generation 4 LAN chips integrate an IEEE 802.3 ethernet physical layer.
The ethernet driver for this family of devices needs to access the SMSC PHY
registers and bits.

So, this patch moves these constants to a place where it can be used for both
the PHY and LAN drivers.

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.h |    4 +++
 drivers/net/phy/smsc.c               |   21 +----------------
 include/linux/smscphy.h              |   42 ++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 20 deletions(-)
 create mode 100644 include/linux/smscphy.h

diff --git a/drivers/net/ethernet/smsc/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
index 8d67aac..938ecf2 100644
--- a/drivers/net/ethernet/smsc/smsc911x.h
+++ b/drivers/net/ethernet/smsc/smsc911x.h
@@ -401,4 +401,8 @@
 #include <asm/smsc911x.h>
 #endif
 
+#ifdef CONFIG_SMSC_PHY
+#include <linux/smscphy.h>
+#endif
+
 #endif				/* __SMSC911X_H__ */
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 342505c..fc3e7e9 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -22,26 +22,7 @@
 #include <linux/ethtool.h>
 #include <linux/phy.h>
 #include <linux/netdevice.h>
-
-#define MII_LAN83C185_ISF 29 /* Interrupt Source Flags */
-#define MII_LAN83C185_IM  30 /* Interrupt Mask */
-#define MII_LAN83C185_CTRL_STATUS 17 /* Mode/Status Register */
-
-#define MII_LAN83C185_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
-#define MII_LAN83C185_ISF_INT2 (1<<2) /* Parallel Detection Fault */
-#define MII_LAN83C185_ISF_INT3 (1<<3) /* Auto-Negotiation LP Ack */
-#define MII_LAN83C185_ISF_INT4 (1<<4) /* Link Down */
-#define MII_LAN83C185_ISF_INT5 (1<<5) /* Remote Fault Detected */
-#define MII_LAN83C185_ISF_INT6 (1<<6) /* Auto-Negotiation complete */
-#define MII_LAN83C185_ISF_INT7 (1<<7) /* ENERGYON */
-
-#define MII_LAN83C185_ISF_INT_ALL (0x0e)
-
-#define MII_LAN83C185_ISF_INT_PHYLIB_EVENTS \
-	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4 | \
-	 MII_LAN83C185_ISF_INT7)
-
-#define MII_LAN83C185_EDPWRDOWN	(1 << 13) /* EDPWRDOWN */
+#include <linux/smscphy.h>
 
 static int smsc_phy_config_intr(struct phy_device *phydev)
 {
diff --git a/include/linux/smscphy.h b/include/linux/smscphy.h
new file mode 100644
index 0000000..c8eb7ed
--- /dev/null
+++ b/include/linux/smscphy.h
@@ -0,0 +1,42 @@
+/***************************************************************************
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ ***************************************************************************/
+#ifndef __LINUX_SMSCPHY_H__
+#define __LINUX_SMSCPHY_H__
+
+#define MII_LAN83C185_ISF 29 /* Interrupt Source Flags */
+#define MII_LAN83C185_IM  30 /* Interrupt Mask */
+#define MII_LAN83C185_CTRL_STATUS 17 /* Mode/Status Register */
+
+#define MII_LAN83C185_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
+#define MII_LAN83C185_ISF_INT2 (1<<2) /* Parallel Detection Fault */
+#define MII_LAN83C185_ISF_INT3 (1<<3) /* Auto-Negotiation LP Ack */
+#define MII_LAN83C185_ISF_INT4 (1<<4) /* Link Down */
+#define MII_LAN83C185_ISF_INT5 (1<<5) /* Remote Fault Detected */
+#define MII_LAN83C185_ISF_INT6 (1<<6) /* Auto-Negotiation complete */
+#define MII_LAN83C185_ISF_INT7 (1<<7) /* ENERGYON */
+
+#define MII_LAN83C185_ISF_INT_ALL (0x0e)
+
+#define MII_LAN83C185_ISF_INT_PHYLIB_EVENTS \
+	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4 | \
+	 MII_LAN83C185_ISF_INT7)
+
+#define MII_LAN83C185_EDPWRDOWN (1 << 13) /* EDPWRDOWN */
+#define MII_LAN83C185_ENERGYON  (1 << 1)  /* ENERGYON */
+
+#endif /* __LINUX_SMSCPHY_H__ */
-- 
1.7.4.1
