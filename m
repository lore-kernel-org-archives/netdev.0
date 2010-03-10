From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 6/6] smsc95xx: remove unnecessary variables
Date: Wed, 10 Mar 2010 18:32:39 +0000
Message-ID: <1268245959-13861-7-git-send-email-steve.glendinning@smsc.com>
References: <1268245959-13861-1-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-2-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-3-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-4-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-5-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-6-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:41122 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932718Ab0CJScz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:32:55 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 1CE1467E47
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:32:40 +0000 (GMT)
In-Reply-To: <1268245959-13861-6-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes unnecessary variables as smsc95xx_write_reg takes its
value by parameter.  Early versions passed this parameter by
reference.

Also replace hardcoded interrupt status value with a #define

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   29 +++++++++--------------------
 drivers/net/usb/smsc95xx.h |    1 +
 2 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index aeaa793..18adc39 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -485,15 +485,13 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	struct ethtool_cmd ecmd;
 	unsigned long flags;
 	u16 lcladv, rmtadv;
-	u32 intdata;
 	int ret;
 
 	/* clear interrupt status */
 	ret = smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
 	check_warn_return(ret, "Error reading PHY_INT_SRC");
 
-	intdata = 0xFFFFFFFF;
-	ret = smsc95xx_write_reg(dev, INT_STS, intdata);
+	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
 	check_warn_return(ret, "Error writing INT_STS");
 
 	mii_check_media(mii, 1, 1);
@@ -700,7 +698,6 @@ static int smsc95xx_start_tx_path(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	unsigned long flags;
-	u32 reg_val;
 	int ret;
 
 	/* Enable Tx at MAC */
@@ -712,8 +709,7 @@ static int smsc95xx_start_tx_path(struct usbnet *dev)
 	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
 
 	/* Enable Tx at SCSRs */
-	reg_val = TX_CFG_ON_;
-	ret = smsc95xx_write_reg(dev, TX_CFG, reg_val);
+	ret = smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON_);
 	check_warn_return(ret, "Failed to write TX_CFG: %d\n", ret);
 
 	return 0;
@@ -786,8 +782,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
-	write_buf = HW_CFG_LRST_;
-	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
+	ret = smsc95xx_write_reg(dev, HW_CFG, HW_CFG_LRST_);
 	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 	timeout = 0;
@@ -803,8 +798,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 	}
 
-	write_buf = PM_CTL_PHY_RST_;
-	ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
+	ret = smsc95xx_write_reg(dev, PM_CTRL, PM_CTL_PHY_RST_);
 	check_warn_return(ret, "Failed to write PM_CTRL: %d\n", ret);
 
 	timeout = 0;
@@ -871,8 +865,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  "Read Value from BURST_CAP after writing: 0x%08x\n",
 		  read_buf);
 
-	read_buf = DEFAULT_BULK_IN_DELAY;
-	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
+	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
 	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
@@ -905,8 +898,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
-	write_buf = 0xFFFFFFFF;
-	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
+	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
 	check_warn_return(ret, "Failed to write INT_STS: %d\n", ret);
 
 	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
@@ -921,12 +913,10 @@ static int smsc95xx_reset(struct usbnet *dev)
 	check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d\n", ret);
 
 	/* Init Tx */
-	write_buf = 0;
-	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
+	ret = smsc95xx_write_reg(dev, FLOW, 0);
 	check_warn_return(ret, "Failed to write FLOW: %d\n", ret);
 
-	read_buf = AFC_CFG_DEFAULT;
-	ret = smsc95xx_write_reg(dev, AFC_CFG, read_buf);
+	ret = smsc95xx_write_reg(dev, AFC_CFG, AFC_CFG_DEFAULT);
 	check_warn_return(ret, "Failed to write AFC_CFG: %d\n", ret);
 
 	/* Don't need mac_cr_lock during initialisation */
@@ -935,8 +925,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	/* Init Rx */
 	/* Set Vlan */
-	write_buf = (u32)ETH_P_8021Q;
-	ret = smsc95xx_write_reg(dev, VLAN1, write_buf);
+	ret = smsc95xx_write_reg(dev, VLAN1, (u32)ETH_P_8021Q);
 	check_warn_return(ret, "Failed to write VLAN1: %d\n", ret);
 
 	/* Enable or disable checksum offload engines */
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 86bc449..a275b62 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -63,6 +63,7 @@
 #define INT_STS_TDFO_			(0x00001000)
 #define INT_STS_RXDF_			(0x00000800)
 #define INT_STS_GPIOS_			(0x000007FF)
+#define INT_STS_CLEAR_ALL_		(0xFFFFFFFF)
 
 #define RX_CFG				(0x0C)
 #define RX_FIFO_FLUSH_			(0x00000001)
-- 
1.6.6.1

