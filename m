From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [RFC PATCH 1/2] move flow control definitions to mii.h
Date: Sun, 14 Dec 2008 12:38:20 +0000
Message-ID: <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:59731 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752355AbYLNMiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 07:38:15 -0500
In-Reply-To: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flags used within drivers for indicating tx and rx flow control are
defined in 4 drivers (and probably more), move these constants to mii.h.

The 3 SMSC drivers use the same constants (FLOW_CTRL_TX), but TG3 uses
TG3_FLOW_CTRL_TX, so this patch also renames the constants within TG3.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.h     |    3 --
 drivers/net/smsc9420.h     |    3 --
 drivers/net/tg3.c          |   50 ++++++++++++++++++++++----------------------
 drivers/net/tg3.h          |    2 -
 drivers/net/usb/smsc95xx.c |    2 -
 include/linux/mii.h        |    4 +++
 6 files changed, 29 insertions(+), 35 deletions(-)

diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index f818cf0..2b76654 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -61,9 +61,6 @@
 #define SMSC_ASSERT_MAC_LOCK(pdata) do {} while (0)
 #endif				/* CONFIG_DEBUG_SPINLOCK */
 
-#define FLOW_CTRL_TX		(1)
-#define FLOW_CTRL_RX		(2)
-
 /* SMSC911x registers and bitfields */
 #define RX_DATA_FIFO			0x00
 
diff --git a/drivers/net/smsc9420.h b/drivers/net/smsc9420.h
index 80c426d..69c351f 100644
--- a/drivers/net/smsc9420.h
+++ b/drivers/net/smsc9420.h
@@ -45,9 +45,6 @@
 
 #define SMSC9420_EEPROM_SIZE		((u32)11)
 
-#define FLOW_CTRL_TX			(1)
-#define FLOW_CTRL_RX			(2)
-
 #define PKT_BUF_SZ			(VLAN_ETH_FRAME_LEN + NET_IP_ALIGN + 4)
 
 /***********************************************/
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6e40d52..f353f69 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1187,9 +1187,9 @@ static void tg3_link_report(struct tg3 *tp)
 		printk(KERN_INFO PFX
 		       "%s: Flow control is %s for TX and %s for RX.\n",
 		       tp->dev->name,
-		       (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_TX) ?
+		       (tp->link_config.active_flowctrl & FLOW_CTRL_TX) ?
 		       "on" : "off",
-		       (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_RX) ?
+		       (tp->link_config.active_flowctrl & FLOW_CTRL_RX) ?
 		       "on" : "off");
 		tg3_ump_link_report(tp);
 	}
@@ -1199,11 +1199,11 @@ static u16 tg3_advert_flowctrl_1000T(u8 flow_ctrl)
 {
 	u16 miireg;
 
-	if ((flow_ctrl & TG3_FLOW_CTRL_TX) && (flow_ctrl & TG3_FLOW_CTRL_RX))
+	if ((flow_ctrl & FLOW_CTRL_TX) && (flow_ctrl & FLOW_CTRL_RX))
 		miireg = ADVERTISE_PAUSE_CAP;
-	else if (flow_ctrl & TG3_FLOW_CTRL_TX)
+	else if (flow_ctrl & FLOW_CTRL_TX)
 		miireg = ADVERTISE_PAUSE_ASYM;
-	else if (flow_ctrl & TG3_FLOW_CTRL_RX)
+	else if (flow_ctrl & FLOW_CTRL_RX)
 		miireg = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 	else
 		miireg = 0;
@@ -1215,11 +1215,11 @@ static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
 {
 	u16 miireg;
 
-	if ((flow_ctrl & TG3_FLOW_CTRL_TX) && (flow_ctrl & TG3_FLOW_CTRL_RX))
+	if ((flow_ctrl & FLOW_CTRL_TX) && (flow_ctrl & FLOW_CTRL_RX))
 		miireg = ADVERTISE_1000XPAUSE;
-	else if (flow_ctrl & TG3_FLOW_CTRL_TX)
+	else if (flow_ctrl & FLOW_CTRL_TX)
 		miireg = ADVERTISE_1000XPSE_ASYM;
-	else if (flow_ctrl & TG3_FLOW_CTRL_RX)
+	else if (flow_ctrl & FLOW_CTRL_RX)
 		miireg = ADVERTISE_1000XPAUSE | ADVERTISE_1000XPSE_ASYM;
 	else
 		miireg = 0;
@@ -1256,16 +1256,16 @@ static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
 	if (lcladv & ADVERTISE_1000XPAUSE) {
 		if (lcladv & ADVERTISE_1000XPSE_ASYM) {
 			if (rmtadv & LPA_1000XPAUSE)
-				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
 			else if (rmtadv & LPA_1000XPAUSE_ASYM)
-				cap = TG3_FLOW_CTRL_RX;
+				cap = FLOW_CTRL_RX;
 		} else {
 			if (rmtadv & LPA_1000XPAUSE)
-				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
 		}
 	} else if (lcladv & ADVERTISE_1000XPSE_ASYM) {
 		if ((rmtadv & LPA_1000XPAUSE) && (rmtadv & LPA_1000XPAUSE_ASYM))
-			cap = TG3_FLOW_CTRL_TX;
+			cap = FLOW_CTRL_TX;
 	}
 
 	return cap;
@@ -1294,7 +1294,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 
 	tp->link_config.active_flowctrl = flowctrl;
 
-	if (flowctrl & TG3_FLOW_CTRL_RX)
+	if (flowctrl & FLOW_CTRL_RX)
 		tp->rx_mode |= RX_MODE_FLOW_CTRL_ENABLE;
 	else
 		tp->rx_mode &= ~RX_MODE_FLOW_CTRL_ENABLE;
@@ -1302,7 +1302,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 	if (old_rx_mode != tp->rx_mode)
 		tw32_f(MAC_RX_MODE, tp->rx_mode);
 
-	if (flowctrl & TG3_FLOW_CTRL_TX)
+	if (flowctrl & FLOW_CTRL_TX)
 		tp->tx_mode |= TX_MODE_FLOW_CTRL_ENABLE;
 	else
 		tp->tx_mode &= ~TX_MODE_FLOW_CTRL_ENABLE;
@@ -9419,12 +9419,12 @@ static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 
 	epause->autoneg = (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) != 0;
 
-	if (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_RX)
+	if (tp->link_config.active_flowctrl & FLOW_CTRL_RX)
 		epause->rx_pause = 1;
 	else
 		epause->rx_pause = 0;
 
-	if (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_TX)
+	if (tp->link_config.active_flowctrl & FLOW_CTRL_TX)
 		epause->tx_pause = 1;
 	else
 		epause->tx_pause = 0;
@@ -9475,14 +9475,14 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 			}
 		} else {
 			if (epause->rx_pause)
-				tp->link_config.flowctrl |= TG3_FLOW_CTRL_RX;
+				tp->link_config.flowctrl |= FLOW_CTRL_RX;
 			else
-				tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_RX;
+				tp->link_config.flowctrl &= ~FLOW_CTRL_RX;
 
 			if (epause->tx_pause)
-				tp->link_config.flowctrl |= TG3_FLOW_CTRL_TX;
+				tp->link_config.flowctrl |= FLOW_CTRL_TX;
 			else
-				tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_TX;
+				tp->link_config.flowctrl &= ~FLOW_CTRL_TX;
 
 			if (netif_running(dev))
 				tg3_setup_flow_control(tp, 0, 0);
@@ -9502,13 +9502,13 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 		else
 			tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
 		if (epause->rx_pause)
-			tp->link_config.flowctrl |= TG3_FLOW_CTRL_RX;
+			tp->link_config.flowctrl |= FLOW_CTRL_RX;
 		else
-			tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_RX;
+			tp->link_config.flowctrl &= ~FLOW_CTRL_RX;
 		if (epause->tx_pause)
-			tp->link_config.flowctrl |= TG3_FLOW_CTRL_TX;
+			tp->link_config.flowctrl |= FLOW_CTRL_TX;
 		else
-			tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_TX;
+			tp->link_config.flowctrl &= ~FLOW_CTRL_TX;
 
 		if (netif_running(dev)) {
 			tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -13849,7 +13849,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	/* flow control autonegotiation is default behavior */
 	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
-	tp->link_config.flowctrl = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
 
 	tg3_init_coal(tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6155676..0880cfa 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2338,8 +2338,6 @@ struct tg3_link_config {
 	u8				duplex;
 	u8				autoneg;
 	u8				flowctrl;
-#define TG3_FLOW_CTRL_TX		0x01
-#define TG3_FLOW_CTRL_RX		0x02
 
 	/* Describes what we actually have. */
 	u8				active_flowctrl;
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 4638a7b..ee2eac3 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -45,8 +45,6 @@
 #define SMSC95XX_INTERNAL_PHY_ID	(1)
 #define SMSC95XX_TX_OVERHEAD		(8)
 #define SMSC95XX_TX_OVERHEAD_CSUM	(12)
-#define FLOW_CTRL_TX			(1)
-#define FLOW_CTRL_RX			(2)
 
 struct smsc95xx_priv {
 	u32 mac_cr;
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 151b7e0..4a376e0 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -135,6 +135,10 @@
 #define LPA_1000FULL            0x0800  /* Link partner 1000BASE-T full duplex */
 #define LPA_1000HALF            0x0400  /* Link partner 1000BASE-T half duplex */
 
+/* Flow control flags */
+#define FLOW_CTRL_TX		0x01
+#define FLOW_CTRL_RX		0x02
+
 /* This structure is used in all SIOCxMIIxxx ioctl calls */
 struct mii_ioctl_data {
 	__u16		phy_id;
-- 
1.6.0.4

