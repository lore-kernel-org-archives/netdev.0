From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 01/10] r6040: prefix all functions with r6040
Date: Sun, 13 Jul 2008 13:39:32 +0200
Message-ID: <200807131339.33512.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:59351 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbYGMLkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 07:40:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefix all functions inside the r6040 driver with r6040 to
avoid namespace clashing.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 504a48f..4e67884 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -183,7 +183,7 @@ static char version[] __devinitdata = KERN_INFO DRV_NAME
 static int phy_table[] = { PHY1_ADDR, PHY2_ADDR };
 
 /* Read a word data from PHY Chip */
-static int phy_read(void __iomem *ioaddr, int phy_addr, int reg)
+static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 {
 	int limit = 2048;
 	u16 cmd;
@@ -200,7 +200,7 @@ static int phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 }
 
 /* Write a word data from PHY Chip */
-static void phy_write(void __iomem *ioaddr, int phy_addr, int reg, u16 val)
+static void r6040_phy_write(void __iomem *ioaddr, int phy_addr, int reg, u16 val)
 {
 	int limit = 2048;
 	u16 cmd;
@@ -216,20 +216,20 @@ static void phy_write(void __iomem *ioaddr, int phy_addr, int reg, u16 val)
 	}
 }
 
-static int mdio_read(struct net_device *dev, int mii_id, int reg)
+static int r6040_mdio_read(struct net_device *dev, int mii_id, int reg)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 
-	return (phy_read(ioaddr, lp->phy_addr, reg));
+	return (r6040_phy_read(ioaddr, lp->phy_addr, reg));
 }
 
-static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
+static void r6040_mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 
-	phy_write(ioaddr, lp->phy_addr, reg, val);
+	r6040_phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
 static void r6040_free_txbufs(struct net_device *dev)
@@ -284,7 +284,7 @@ static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
 }
 
 /* Allocate skb buffer for rx descriptor */
-static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
+static void r6040_rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 {
 	struct r6040_descriptor *descptr;
 	void __iomem *ioaddr = lp->base;
@@ -331,7 +331,7 @@ static void r6040_alloc_rxbufs(struct net_device *dev)
 	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
 	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
 
-	rx_buf_alloc(lp, dev);
+	r6040_rx_buf_alloc(lp, dev);
 
 	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
 	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
@@ -345,7 +345,7 @@ static void r6040_tx_timeout(struct net_device *dev)
 	printk(KERN_WARNING "%s: transmit timed out, status %4.4x, PHY status "
 		"%4.4x\n",
 		dev->name, ioread16(ioaddr + MIER),
-		mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
+		r6040_mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
 
 	disable_irq(dev->irq);
 	napi_disable(&priv->napi);
@@ -432,23 +432,23 @@ static int r6040_close(struct net_device *dev)
 }
 
 /* Status of PHY CHIP */
-static int phy_mode_chk(struct net_device *dev)
+static int r6040_phy_mode_chk(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	int phy_dat;
 
 	/* PHY Link Status Check */
-	phy_dat = phy_read(ioaddr, lp->phy_addr, 1);
+	phy_dat = r6040_phy_read(ioaddr, lp->phy_addr, 1);
 	if (!(phy_dat & 0x4))
 		phy_dat = 0x8000;	/* Link Failed, full duplex */
 
 	/* PHY Chip Auto-Negotiation Status */
-	phy_dat = phy_read(ioaddr, lp->phy_addr, 1);
+	phy_dat = r6040_phy_read(ioaddr, lp->phy_addr, 1);
 	if (phy_dat & 0x0020) {
 		/* Auto Negotiation Mode */
-		phy_dat = phy_read(ioaddr, lp->phy_addr, 5);
-		phy_dat &= phy_read(ioaddr, lp->phy_addr, 4);
+		phy_dat = r6040_phy_read(ioaddr, lp->phy_addr, 5);
+		phy_dat &= r6040_phy_read(ioaddr, lp->phy_addr, 4);
 		if (phy_dat & 0x140)
 			/* Force full duplex */
 			phy_dat = 0x8000;
@@ -456,7 +456,7 @@ static int phy_mode_chk(struct net_device *dev)
 			phy_dat = 0;
 	} else {
 		/* Force Mode */
-		phy_dat = phy_read(ioaddr, lp->phy_addr, 0);
+		phy_dat = r6040_phy_read(ioaddr, lp->phy_addr, 0);
 		if (phy_dat & 0x100)
 			phy_dat = 0x8000;
 		else
@@ -468,12 +468,12 @@ static int phy_mode_chk(struct net_device *dev)
 
 static void r6040_set_carrier(struct mii_if_info *mii)
 {
-	if (phy_mode_chk(mii->dev)) {
+	if (r6040_phy_mode_chk(mii->dev)) {
 		/* autoneg is off: Link is always assumed to be up */
 		if (!netif_carrier_ok(mii->dev))
 			netif_carrier_on(mii->dev);
 	} else
-		phy_mode_chk(mii->dev);
+		r6040_phy_mode_chk(mii->dev);
 }
 
 static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
@@ -560,7 +560,7 @@ static int r6040_rx(struct net_device *dev, int limit)
 	}
 	/* Allocate new RX buffer */
 	if (priv->rx_free_desc < RX_DCNT)
-		rx_buf_alloc(priv, priv->dev);
+		r6040_rx_buf_alloc(priv, priv->dev);
 
 	return count;
 }
@@ -672,18 +672,18 @@ static void r6040_up(struct net_device *dev)
 	/* Buffer Size Register */
 	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
 	/* Read the PHY ID */
-	lp->switch_sig = phy_read(ioaddr, 0, 2);
+	lp->switch_sig = r6040_phy_read(ioaddr, 0, 2);
 
 	if (lp->switch_sig  == ICPLUS_PHY_ID) {
-		phy_write(ioaddr, 29, 31, 0x175C); /* Enable registers */
+		r6040_phy_write(ioaddr, 29, 31, 0x175C); /* Enable registers */
 		lp->phy_mode = 0x8000;
 	} else {
 		/* PHY Mode Check */
-		phy_write(ioaddr, lp->phy_addr, 4, PHY_CAP);
-		phy_write(ioaddr, lp->phy_addr, 0, PHY_MODE);
+		r6040_phy_write(ioaddr, lp->phy_addr, 4, PHY_CAP);
+		r6040_phy_write(ioaddr, lp->phy_addr, 0, PHY_MODE);
 
 		if (PHY_MODE == 0x3100)
-			lp->phy_mode = phy_mode_chk(dev);
+			lp->phy_mode = r6040_phy_mode_chk(dev);
 		else
 			lp->phy_mode = (PHY_MODE & 0x0100) ? 0x8000:0x0;
 	}
@@ -699,10 +699,10 @@ static void r6040_up(struct net_device *dev)
 	iowrite16(0x0F06, ioaddr + MR_ICR);
 
 	/* improve performance (by RDC guys) */
-	phy_write(ioaddr, 30, 17, (phy_read(ioaddr, 30, 17) | 0x4000));
-	phy_write(ioaddr, 30, 17, ~((~phy_read(ioaddr, 30, 17)) | 0x2000));
-	phy_write(ioaddr, 0, 19, 0x0000);
-	phy_write(ioaddr, 0, 30, 0x01F0);
+	r6040_phy_write(ioaddr, 30, 17, (r6040_phy_read(ioaddr, 30, 17) | 0x4000));
+	r6040_phy_write(ioaddr, 30, 17, ~((~r6040_phy_read(ioaddr, 30, 17)) | 0x2000));
+	r6040_phy_write(ioaddr, 0, 19, 0x0000);
+	r6040_phy_write(ioaddr, 0, 30, 0x01F0);
 
 	/* Interrupt Mask Register */
 	iowrite16(INT_MASK, ioaddr + MIER);
@@ -721,7 +721,7 @@ static void r6040_timer(unsigned long data)
 
 	/* Polling PHY Chip Status */
 	if (PHY_MODE == 0x3100)
-		phy_mode = phy_mode_chk(dev);
+		phy_mode = r6040_phy_mode_chk(dev);
 	else
 		phy_mode = (PHY_MODE & 0x0100) ? 0x8000:0x0;
 
@@ -1070,8 +1070,8 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 #endif
 	netif_napi_add(dev, &lp->napi, r6040_poll, 64);
 	lp->mii_if.dev = dev;
-	lp->mii_if.mdio_read = mdio_read;
-	lp->mii_if.mdio_write = mdio_write;
+	lp->mii_if.mdio_read = r6040_mdio_read;
+	lp->mii_if.mdio_write = r6040_mdio_write;
 	lp->mii_if.phy_id = lp->phy_addr;
 	lp->mii_if.phy_id_mask = 0x1f;
 	lp->mii_if.reg_num_mask = 0x1f;
