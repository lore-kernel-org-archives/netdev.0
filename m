From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 7/7 v3] au1000-eth: change multi-line comments style
Date: Wed, 8 Sep 2010 23:11:59 +0200
Message-ID: <201009082312.00527.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46813 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab0IHVKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:10:49 -0400
Received: by mail-wy0-f174.google.com with SMTP id 22so488057wyf.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 14:10:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index f4c394f..43489f8 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -229,11 +229,15 @@ static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
 	/* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
-	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus) */
+	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus)
+	 */
 	struct net_device *const dev = bus->priv;
 
-	au1000_enable_mac(dev, 0); /* make sure the MAC associated with this
-			     * mii_bus is enabled */
+	/* make sure the MAC associated with this
+	 * mii_bus is enabled
+	 */
+	au1000_enable_mac(dev, 0);
+
 	return au1000_mdio_read(dev, phy_addr, regnum);
 }
 
@@ -242,8 +246,11 @@ static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 {
 	struct net_device *const dev = bus->priv;
 
-	au1000_enable_mac(dev, 0); /* make sure the MAC associated with this
-			     * mii_bus is enabled */
+	/* make sure the MAC associated with this
+	 * mii_bus is enabled
+	 */
+	au1000_enable_mac(dev, 0);
+
 	au1000_mdio_write(dev, phy_addr, regnum, value);
 	return 0;
 }
@@ -252,8 +259,11 @@ static int au1000_mdiobus_reset(struct mii_bus *bus)
 {
 	struct net_device *const dev = bus->priv;
 
-	au1000_enable_mac(dev, 0); /* make sure the MAC associated with this
-			     * mii_bus is enabled */
+	/* make sure the MAC associated with this
+	 * mii_bus is enabled
+	 */
+	au1000_enable_mac(dev, 0);
+
 	return 0;
 }
 
@@ -380,7 +390,8 @@ static int au1000_mii_probe(struct net_device *dev)
 	}
 
 	/* find the first (lowest address) PHY
-	 * on the current MAC's MII bus */
+	 * on the current MAC's MII bus
+	 */
 	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
 		if (aup->mii_bus->phy_map[phy_addr]) {
 			phydev = aup->mii_bus->phy_map[phy_addr];
@@ -774,7 +785,8 @@ static void au1000_update_tx_stats(struct net_device *dev, u32 status)
 		if (!aup->phy_dev || (DUPLEX_FULL == aup->phy_dev->duplex)) {
 			if (status & (TX_JAB_TIMEOUT | TX_UNDERRUN)) {
 				/* any other tx errors are only valid
-				 * in half duplex mode */
+				 * in half duplex mode
+				 */
 				ps->tx_errors++;
 				ps->tx_aborted_errors++;
 			}
@@ -1068,8 +1080,9 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup->msg_enable = (au1000_debug < 4 ?
 				AU1000_DEF_MSG_ENABLE : au1000_debug);
 
-	/* Allocate the data buffers */
-	/* Snooping works fine with eth on all au1xxx */
+	/* Allocate the data buffers
+	 * Snooping works fine with eth on all au1xxx
+	 */
 	aup->vaddr = (u32)dma_alloc_noncoherent(NULL, MAX_BUF_SIZE *
 						(NUM_TX_BUFFS + NUM_RX_BUFFS),
 						&aup->dma_addr,	0);
@@ -1226,7 +1239,8 @@ err_out:
 		mdiobus_unregister(aup->mii_bus);
 
 	/* here we should have a valid dev plus aup-> register addresses
-	 * so we can reset the mac properly.*/
+	 * so we can reset the mac properly.
+	 */
 	au1000_reset_mac(dev);
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 4b638df..6229c77 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -100,7 +100,8 @@ struct au1000_private {
 	int mac_id;
 
 	int mac_enabled;       /* whether MAC is currently enabled and running
-				 (req. for mdio) */
+				* (req. for mdio)
+				*/
 
 	int old_link;          /* used by au1000_adjust_link */
 	int old_speed;
@@ -119,7 +120,8 @@ struct au1000_private {
 	int phy_irq;
 
 	/* These variables are just for quick access
-	 * to certain regs addresses. */
+	 * to certain regs addresses.
+	 */
 	struct mac_reg *mac;  /* mac registers                      */
 	u32 *enable;     /* address of MAC Enable Register     */
 


