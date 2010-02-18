From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 11/15] drivers/net/skge.c: Use (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:58 -0800
Message-ID: <68f273dcc35e852e462f2e49ca563ddc5bf74ab0.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1063 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161Ab0BRBCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:13 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Checkpatch cleaning

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skge.c |   81 +++++++++++++++++++++++++++-------------------------
 1 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 8aa24c5..720af1c 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -71,9 +71,9 @@ MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static const u32 default_msg
-	= NETIF_MSG_DRV| NETIF_MSG_PROBE| NETIF_MSG_LINK
-	  | NETIF_MSG_IFUP| NETIF_MSG_IFDOWN;
+static const u32 default_msg = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
+				NETIF_MSG_LINK | NETIF_MSG_IFUP |
+				NETIF_MSG_IFDOWN);
 
 static int debug = -1;	/* defaults above */
 module_param(debug, int, 0);
@@ -188,8 +188,8 @@ static void skge_wol_init(struct skge_port *skge)
 
 	/* Force to 10/100 skge_reset will re-enable on resume	 */
 	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV,
-		     PHY_AN_100FULL | PHY_AN_100HALF |
-		     PHY_AN_10FULL | PHY_AN_10HALF| PHY_AN_CSMA);
+		     (PHY_AN_100FULL | PHY_AN_100HALF |
+		      PHY_AN_10FULL | PHY_AN_10HALF | PHY_AN_CSMA));
 	/* no 1000 HD/FD */
 	gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, 0);
 	gm_phy_write(hw, port, PHY_MARV_CTRL,
@@ -258,25 +258,28 @@ static u32 skge_supported_modes(const struct skge_hw *hw)
 	u32 supported;
 
 	if (hw->copper) {
-		supported = SUPPORTED_10baseT_Half
-			| SUPPORTED_10baseT_Full
-			| SUPPORTED_100baseT_Half
-			| SUPPORTED_100baseT_Full
-			| SUPPORTED_1000baseT_Half
-			| SUPPORTED_1000baseT_Full
-			| SUPPORTED_Autoneg| SUPPORTED_TP;
+		supported = (SUPPORTED_10baseT_Half |
+			     SUPPORTED_10baseT_Full |
+			     SUPPORTED_100baseT_Half |
+			     SUPPORTED_100baseT_Full |
+			     SUPPORTED_1000baseT_Half |
+			     SUPPORTED_1000baseT_Full |
+			     SUPPORTED_Autoneg |
+			     SUPPORTED_TP);
 
 		if (hw->chip_id == CHIP_ID_GENESIS)
-			supported &= ~(SUPPORTED_10baseT_Half
-					     | SUPPORTED_10baseT_Full
-					     | SUPPORTED_100baseT_Half
-					     | SUPPORTED_100baseT_Full);
+			supported &= ~(SUPPORTED_10baseT_Half |
+				       SUPPORTED_10baseT_Full |
+				       SUPPORTED_100baseT_Half |
+				       SUPPORTED_100baseT_Full);
 
 		else if (hw->chip_id == CHIP_ID_YUKON)
 			supported &= ~SUPPORTED_1000baseT_Half;
 	} else
-		supported = SUPPORTED_1000baseT_Full | SUPPORTED_1000baseT_Half
-			| SUPPORTED_FIBRE | SUPPORTED_Autoneg;
+		supported = (SUPPORTED_1000baseT_Full |
+			     SUPPORTED_1000baseT_Half |
+			     SUPPORTED_FIBRE |
+			     SUPPORTED_Autoneg);
 
 	return supported;
 }
@@ -366,7 +369,7 @@ static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 	}
 
-	return (0);
+	return 0;
 }
 
 static void skge_get_drvinfo(struct net_device *dev,
@@ -813,7 +816,7 @@ static int skge_get_eeprom_len(struct net_device *dev)
 	u32 reg2;
 
 	pci_read_config_dword(skge->hw->pdev, PCI_DEV_REG2, &reg2);
-	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+	return 1 << (((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 }
 
 static u32 skge_vpd_read(struct pci_dev *pdev, int cap, u16 offset)
@@ -1044,7 +1047,7 @@ static int skge_rx_fill(struct net_device *dev)
 
 		skb_reserve(skb, NET_IP_ALIGN);
 		skge_rx_setup(skge, e, skb, skge->rx_buf_size);
-	} while ( (e = e->next) != ring->start);
+	} while ((e = e->next) != ring->start);
 
 	ring->to_clean = ring->start;
 	return 0;
@@ -1052,7 +1055,7 @@ static int skge_rx_fill(struct net_device *dev)
 
 static const char *skge_pause(enum pause_status status)
 {
-	switch(status) {
+	switch (status) {
 	case FLOW_STAT_NONE:
 		return "none";
 	case FLOW_STAT_REM_SEND:
@@ -1322,7 +1325,7 @@ static void bcom_phy_init(struct skge_port *skge)
 	/* Optimize MDIO transfer by suppressing preamble. */
 	r = xm_read16(hw, port, XM_MMU_CMD);
 	r |=  XM_MMU_NO_PRE;
-	xm_write16(hw, port, XM_MMU_CMD,r);
+	xm_write16(hw, port, XM_MMU_CMD, r);
 
 	switch (id1) {
 	case PHY_BCOM_ID1_C0:
@@ -1512,7 +1515,7 @@ static void xm_link_timer(unsigned long arg)
 {
 	struct skge_port *skge = (struct skge_port *) arg;
 	struct net_device *dev = skge->netdev;
- 	struct skge_hw *hw = skge->hw;
+	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 	int i;
 	unsigned long flags;
@@ -1531,7 +1534,7 @@ static void xm_link_timer(unsigned long arg)
 			goto link_down;
 	}
 
-        /* Re-enable interrupt to detect link down */
+	/* Re-enable interrupt to detect link down */
 	if (xm_check_link(dev)) {
 		u16 msk = xm_read16(hw, port, XM_IMSK);
 		msk &= ~XM_IS_INP_ASS;
@@ -1588,7 +1591,7 @@ static void genesis_mac_init(struct skge_hw *hw, int port)
 	}
 
 
-	switch(hw->phy_type) {
+	switch (hw->phy_type) {
 	case SK_PHY_XMAC:
 		xm_phy_init(skge);
 		break;
@@ -1695,7 +1698,7 @@ static void genesis_mac_init(struct skge_hw *hw, int port)
 
 	if (jumbo) {
 		/* Enable frame flushing if jumbo frames used */
-		skge_write16(hw, SK_REG(port,RX_MFF_CTRL1), MFF_ENA_FLUSH);
+		skge_write16(hw, SK_REG(port, RX_MFF_CTRL1), MFF_ENA_FLUSH);
 	} else {
 		/* enable timeout timers if normal frames */
 		skge_write16(hw, B3_PA_CTRL,
@@ -1710,7 +1713,7 @@ static void genesis_stop(struct skge_port *skge)
 	unsigned retries = 1000;
 	u16 cmd;
 
- 	/* Disable Tx and Rx */
+	/* Disable Tx and Rx */
 	cmd = xm_read16(hw, port, XM_MMU_CMD);
 	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
 	xm_write16(hw, port, XM_MMU_CMD, cmd);
@@ -1789,7 +1792,7 @@ static void genesis_mac_intr(struct skge_hw *hw, int port)
 		     "mac interrupt status 0x%x\n", status);
 
 	if (hw->phy_type == SK_PHY_XMAC && (status & XM_IS_INP_ASS)) {
-  		xm_link_down(hw, port);
+		xm_link_down(hw, port);
 		mod_timer(&skge->link_timer, jiffies + 1);
 	}
 
@@ -1823,7 +1826,7 @@ static void genesis_link_up(struct skge_port *skge)
 	xm_write16(hw, port, XM_MMU_CMD, cmd);
 
 	mode = xm_read32(hw, port, XM_MODE);
-	if (skge->flow_status== FLOW_STAT_SYMMETRIC ||
+	if (skge->flow_status == FLOW_STAT_SYMMETRIC ||
 	    skge->flow_status == FLOW_STAT_LOC_SEND) {
 		/*
 		 * Configure Pause Frame Generation
@@ -2466,7 +2469,7 @@ static int skge_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (!netif_running(dev))
 		return -ENODEV;	/* Phy still in reset */
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id = hw->phy_addr;
 
@@ -2765,7 +2768,7 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 		 * does.  Looks like hardware is wrong?
 		 */
 		if (ipip_hdr(skb)->protocol == IPPROTO_UDP &&
-	            hw->chip_rev == 0 && hw->chip_id == CHIP_ID_YUKON)
+		    hw->chip_rev == 0 && hw->chip_id == CHIP_ID_YUKON)
 			control = BMU_TCP_CHECK;
 		else
 			control = BMU_UDP_CHECK;
@@ -2777,7 +2780,7 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 		control = BMU_CHECK;
 
 	if (!skb_shinfo(skb)->nr_frags) /* single buffer i.e. no fragments */
-		control |= BMU_EOF| BMU_IRQ_EOF;
+		control |= BMU_EOF | BMU_IRQ_EOF;
 	else {
 		struct skge_tx_desc *tf = td;
 
@@ -3077,7 +3080,7 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 				 pci_unmap_len(e, maplen),
 				 PCI_DMA_FROMDEVICE);
 		skb = e->skb;
-  		prefetch(skb->data);
+		prefetch(skb->data);
 		skge_rx_setup(skge, e, nskb, skge->rx_buf_size);
 	}
 
@@ -3554,8 +3557,7 @@ static int skge_reset(struct skge_hw *hw)
 			hw->ram_offset = 0x80000;
 		} else
 			hw->ram_size = t8 * 512;
-	}
-	else if (t8 == 0)
+	} else if (t8 == 0)
 		hw->ram_size = 0x20000;
 	else
 		hw->ram_size = t8 * 4096;
@@ -3709,7 +3711,7 @@ static int skge_device_event(struct notifier_block *unused,
 		goto done;
 
 	skge = netdev_priv(dev);
-	switch(event) {
+	switch (event) {
 	case NETDEV_CHANGENAME:
 		if (skge->debugfs) {
 			d = debugfs_rename(skge_debug, skge->debugfs,
@@ -3914,7 +3916,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 
 	err = -ENOMEM;
 	/* space for skge@pci:0000:04:00.0 */
-	hw = kzalloc(sizeof(*hw) + strlen(DRV_NAME "@pci:" )
+	hw = kzalloc(sizeof(*hw) + strlen(DRV_NAME "@pci:")
 		     + strlen(pci_name(pdev)) + 1, GFP_KERNEL);
 	if (!hw) {
 		dev_err(&pdev->dev, "cannot allocate hardware struct\n");
@@ -4010,7 +4012,8 @@ static void __devexit skge_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	if ((dev1 = hw->dev[1]))
+	dev1 = hw->dev[1];
+	if (dev1)
 		unregister_netdev(dev1);
 	dev0 = hw->dev[0];
 	unregister_netdev(dev0);
-- 
1.7.0.14.g7e948

