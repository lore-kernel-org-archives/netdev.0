From: Javier Martinez Canillas <javier@dowhile0.org>
Subject: [PATCH v2 1/2] net: phy: smsc: Move SMSC PHY constants to <linux/smscphy.h>
Date: Wed,  4 Jan 2012 00:36:18 +0100
Message-ID: <1325633779-6159-1-git-send-email-javier@dowhile0.org>
Cc: steve.glendinning@smsc.com, eballetbo@iseebcn.com,
	ben@decadent.org.uk, netdev@vger.kernel.org,
	Javier Martinez Canillas <javier@dowhile0.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50590 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449Ab2ACXfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 18:35:32 -0500
Received: by werm1 with SMTP id m1so8211402wer.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 15:35:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMSC generation 4 LAN chips integrate an IEEE 802.3 ethernet physical layer.
The ethernet driver for this family of devices needs to access the SMSC PHY
registers and bit-fields.

So, this patch moves these constants to a place where it can be used for both
the PHY and LAN drivers.

Signed-off-by: Javier Martinez Canillas <javier@dowhile0.org>
---
v2: Remove the GPL license from the file since are only trivial defines.
	
 drivers/net/ethernet/smsc/smsc911x.h |    4 ++++
 drivers/net/phy/smsc.c               |   21 +--------------------
 include/linux/smscphy.h              |   25 +++++++++++++++++++++++++
 3 files changed, 30 insertions(+), 20 deletions(-)
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
index 0000000..ce718cb
--- /dev/null
+++ b/include/linux/smscphy.h
@@ -0,0 +1,25 @@
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
