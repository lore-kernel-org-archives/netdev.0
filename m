From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/7] au1000-eth: prefix all functions with au1000_
Date: Wed, 7 Apr 2010 10:09:01 +0200
Message-ID: <201004071009.01103.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:64281 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143Ab0DGIKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:07 -0400
Received: by mail-ew0-f220.google.com with SMTP id 20so385422ewy.1
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid namespace clashes, prefix all internal driver functions
with au1000_.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index b96abc5..7d40177 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -149,7 +149,7 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
  * specific irq-map
  */
 
-static void enable_mac(struct net_device *dev, int force_reset)
+static void au1000_enable_mac(struct net_device *dev, int force_reset)
 {
 	unsigned long flags;
 	struct au1000_private *aup = netdev_priv(dev);
@@ -237,7 +237,7 @@ static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus) */
 	struct net_device *const dev = bus->priv;
 
-	enable_mac(dev, 0); /* make sure the MAC associated with this
+	au1000_enable_mac(dev, 0); /* make sure the MAC associated with this
 			     * mii_bus is enabled */
 	return au1000_mdio_read(dev, phy_addr, regnum);
 }
@@ -247,7 +247,7 @@ static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 {
 	struct net_device *const dev = bus->priv;
 
-	enable_mac(dev, 0); /* make sure the MAC associated with this
+	au1000_enable_mac(dev, 0); /* make sure the MAC associated with this
 			     * mii_bus is enabled */
 	au1000_mdio_write(dev, phy_addr, regnum, value);
 	return 0;
@@ -257,12 +257,12 @@ static int au1000_mdiobus_reset(struct mii_bus *bus)
 {
 	struct net_device *const dev = bus->priv;
 
-	enable_mac(dev, 0); /* make sure the MAC associated with this
+	au1000_enable_mac(dev, 0); /* make sure the MAC associated with this
 			     * mii_bus is enabled */
 	return 0;
 }
 
-static void hard_stop(struct net_device *dev)
+static void au1000_hard_stop(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
@@ -273,7 +273,7 @@ static void hard_stop(struct net_device *dev)
 	au_sync_delay(10);
 }
 
-static void enable_rx_tx(struct net_device *dev)
+static void au1000_enable_rx_tx(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
@@ -320,7 +320,7 @@ au1000_adjust_link(struct net_device *dev)
 		// duplex mode changed
 
 		/* switching duplex mode requires to disable rx and tx! */
-		hard_stop(dev);
+		au1000_hard_stop(dev);
 
 		if (DUPLEX_FULL == phydev->duplex)
 			aup->mac->control = ((aup->mac->control
@@ -332,7 +332,7 @@ au1000_adjust_link(struct net_device *dev)
 					     | MAC_DISABLE_RX_OWN);
 		au_sync_delay(1);
 
-		enable_rx_tx(dev);
+		au1000_enable_rx_tx(dev);
 		aup->old_duplex = phydev->duplex;
 
 		status_change = 1;
@@ -363,7 +363,7 @@ au1000_adjust_link(struct net_device *dev)
 	}
 }
 
-static int mii_probe (struct net_device *dev)
+static int au1000_mii_probe (struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
@@ -463,7 +463,7 @@ static int mii_probe (struct net_device *dev)
  * has the virtual and dma address of a buffer suitable for
  * both, receive and transmit operations.
  */
-static db_dest_t *GetFreeDB(struct au1000_private *aup)
+static db_dest_t *au1000_GetFreeDB(struct au1000_private *aup)
 {
 	db_dest_t *pDB;
 	pDB = aup->pDBfree;
@@ -474,7 +474,7 @@ static db_dest_t *GetFreeDB(struct au1000_private *aup)
 	return pDB;
 }
 
-void ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
+void au1000_ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
 {
 	db_dest_t *pDBfree = aup->pDBfree;
 	if (pDBfree)
@@ -482,12 +482,12 @@ void ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
 	aup->pDBfree = pDB;
 }
 
-static void reset_mac_unlocked(struct net_device *dev)
+static void au1000_reset_mac_unlocked(struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
 	int i;
 
-	hard_stop(dev);
+	au1000_hard_stop(dev);
 
 	*aup->enable = MAC_EN_CLOCK_ENABLE;
 	au_sync_delay(2);
@@ -508,7 +508,7 @@ static void reset_mac_unlocked(struct net_device *dev)
 
 }
 
-static void reset_mac(struct net_device *dev)
+static void au1000_reset_mac(struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
 	unsigned long flags;
@@ -519,7 +519,7 @@ static void reset_mac(struct net_device *dev)
 
 	spin_lock_irqsave(&aup->lock, flags);
 
-	reset_mac_unlocked (dev);
+	au1000_reset_mac_unlocked (dev);
 
 	spin_unlock_irqrestore(&aup->lock, flags);
 }
@@ -530,7 +530,7 @@ static void reset_mac(struct net_device *dev)
  * these are not descriptors sitting in memory.
  */
 static void
-setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
+au1000_setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
 {
 	int i;
 
@@ -611,7 +611,7 @@ static int au1000_init(struct net_device *dev)
 		printk("%s: au1000_init\n", dev->name);
 
 	/* bring the device out of reset */
-	enable_mac(dev, 1);
+	au1000_enable_mac(dev, 1);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -650,7 +650,7 @@ static int au1000_init(struct net_device *dev)
 	return 0;
 }
 
-static inline void update_rx_stats(struct net_device *dev, u32 status)
+static inline void au1000_update_rx_stats(struct net_device *dev, u32 status)
 {
 	struct net_device_stats *ps = &dev->stats;
 
@@ -694,7 +694,7 @@ static int au1000_rx(struct net_device *dev)
 	while (buff_stat & RX_T_DONE)  {
 		status = prxd->status;
 		pDB = aup->rx_db_inuse[aup->rx_head];
-		update_rx_stats(dev, status);
+		au1000_update_rx_stats(dev, status);
 		if (!(status & RX_ERROR))  {
 
 			/* good frame */
@@ -748,7 +748,7 @@ static int au1000_rx(struct net_device *dev)
 	return 0;
 }
 
-static void update_tx_stats(struct net_device *dev, u32 status)
+static void au1000_update_tx_stats(struct net_device *dev, u32 status)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
@@ -784,7 +784,7 @@ static void au1000_tx_ack(struct net_device *dev)
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
 
 	while (ptxd->buff_stat & TX_T_DONE) {
-		update_tx_stats(dev, ptxd->status);
+		au1000_update_tx_stats(dev, ptxd->status);
 		ptxd->buff_stat &= ~TX_T_DONE;
 		ptxd->len = 0;
 		au_sync();
@@ -861,7 +861,7 @@ static int au1000_close(struct net_device *dev)
 
 	spin_lock_irqsave(&aup->lock, flags);
 
-	reset_mac_unlocked (dev);
+	au1000_reset_mac_unlocked (dev);
 
 	/* stop the device */
 	netif_stop_queue(dev);
@@ -899,7 +899,7 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 	else if (buff_stat & TX_T_DONE) {
-		update_tx_stats(dev, ptxd->status);
+		au1000_update_tx_stats(dev, ptxd->status);
 		ptxd->len = 0;
 	}
 
@@ -937,7 +937,7 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 static void au1000_tx_timeout(struct net_device *dev)
 {
 	printk(KERN_ERR "%s: au1000_tx_timeout: dev=%p\n", dev->name, dev);
-	reset_mac(dev);
+	au1000_reset_mac(dev);
 	au1000_init(dev);
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
@@ -1089,9 +1089,9 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 				/* Use the hard coded MAC addresses */
 		}
 
-		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
+		au1000_setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
 	} else if (pdev->id == 1)
-		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
+		au1000_setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
 
 	/*
 	 * Assign to the Ethernet ports two consecutive MAC addresses
@@ -1153,7 +1153,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		goto err_mdiobus_reg;
 	}
 
-	if (mii_probe(dev) != 0)
+	if (au1000_mii_probe(dev) != 0)
 		goto err_out;
 
 	pDBfree = NULL;
@@ -1169,7 +1169,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup->pDBfree = pDBfree;
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
-		pDB = GetFreeDB(aup);
+		pDB = au1000_GetFreeDB(aup);
 		if (!pDB) {
 			goto err_out;
 		}
@@ -1177,7 +1177,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		aup->rx_db_inuse[i] = pDB;
 	}
 	for (i = 0; i < NUM_TX_DMA; i++) {
-		pDB = GetFreeDB(aup);
+		pDB = au1000_GetFreeDB(aup);
 		if (!pDB) {
 			goto err_out;
 		}
@@ -1196,7 +1196,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	 * The boot code uses the ethernet controller, so reset it to start
 	 * fresh.  au1000_init() expects that the device is in reset state.
 	 */
-	reset_mac(dev);
+	au1000_reset_mac(dev);
 
 	err = register_netdev(dev);
 	if (err) {
@@ -1218,15 +1218,15 @@ err_out:
 
 	/* here we should have a valid dev plus aup-> register addresses
 	 * so we can reset the mac properly.*/
-	reset_mac(dev);
+	au1000_reset_mac(dev);
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		if (aup->rx_db_inuse[i])
-			ReleaseDB(aup, aup->rx_db_inuse[i]);
+			au1000_ReleaseDB(aup, aup->rx_db_inuse[i]);
 	}
 	for (i = 0; i < NUM_TX_DMA; i++) {
 		if (aup->tx_db_inuse[i])
-			ReleaseDB(aup, aup->tx_db_inuse[i]);
+			au1000_ReleaseDB(aup, aup->tx_db_inuse[i]);
 	}
 err_mdiobus_reg:
 	mdiobus_free(aup->mii_bus);
@@ -1262,11 +1262,11 @@ static int __devexit au1000_remove(struct platform_device *pdev)
 
 	for (i = 0; i < NUM_RX_DMA; i++)
 		if (aup->rx_db_inuse[i])
-			ReleaseDB(aup, aup->rx_db_inuse[i]);
+			au1000_ReleaseDB(aup, aup->rx_db_inuse[i]);
 
 	for (i = 0; i < NUM_TX_DMA; i++)
 		if (aup->tx_db_inuse[i])
-			ReleaseDB(aup, aup->tx_db_inuse[i]);
+			au1000_ReleaseDB(aup, aup->tx_db_inuse[i]);
 
 	dma_free_noncoherent(NULL, MAX_BUF_SIZE *
 			(NUM_TX_BUFFS + NUM_RX_BUFFS),
