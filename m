From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/7 v3] au1000-eth: fix all but one "line over 80 characters warnings"
Date: Wed, 8 Sep 2010 23:11:40 +0200
Message-ID: <201009082311.40651.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46813 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329Ab0IHVKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:10:38 -0400
Received: by wyf22 with SMTP id 22so488057wyf.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 14:10:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One line has not been changed because it would not improve readability.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index df3eee1..a2d86cf 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -357,6 +357,7 @@ static int au1000_mii_probe(struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
+	int phy_addr;
 
 	if (aup->phy_static_config) {
 		BUG_ON(aup->mac_id < 0 || aup->mac_id > 1);
@@ -366,42 +367,45 @@ static int au1000_mii_probe(struct net_device *dev)
 		else
 			netdev_info(dev, "using PHY-less setup\n");
 		return 0;
-	} else {
-		int phy_addr;
-
-		/* find the first (lowest address) PHY on the current MAC's MII bus */
-		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
-			if (aup->mii_bus->phy_map[phy_addr]) {
-				phydev = aup->mii_bus->phy_map[phy_addr];
-				if (!aup->phy_search_highest_addr)
-					break; /* break out with first one found */
-			}
-
-		if (aup->phy1_search_mac0) {
-			/* try harder to find a PHY */
-			if (!phydev && (aup->mac_id == 1)) {
-				/* no PHY found, maybe we have a dual PHY? */
-				dev_info(&dev->dev, ": no PHY found on MAC1, "
-					"let's see if it's attached to MAC0...\n");
-
-				/* find the first (lowest address) non-attached PHY on
-				 * the MAC0 MII bus */
-				for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-					struct phy_device *const tmp_phydev =
-							aup->mii_bus->phy_map[phy_addr];
-
-					if (aup->mac_id == 1)
-						break;
-
-					if (!tmp_phydev)
-						continue; /* no PHY here... */
+	}
 
-					if (tmp_phydev->attached_dev)
-						continue; /* already claimed by MAC0 */
+	/* find the first (lowest address) PHY
+	 * on the current MAC's MII bus */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
+		if (aup->mii_bus->phy_map[phy_addr]) {
+			phydev = aup->mii_bus->phy_map[phy_addr];
+			if (!aup->phy_search_highest_addr)
+				/* break out with first one found */
+				break;
+		}
 
-					phydev = tmp_phydev;
-					break; /* found it */
-				}
+	if (aup->phy1_search_mac0) {
+		/* try harder to find a PHY */
+		if (!phydev && (aup->mac_id == 1)) {
+			/* no PHY found, maybe we have a dual PHY? */
+			dev_info(&dev->dev, ": no PHY found on MAC1, "
+				"let's see if it's attached to MAC0...\n");
+
+			/* find the first (lowest address) non-attached
+			 * PHY on the MAC0 MII bus
+			 */
+			for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+				struct phy_device *const tmp_phydev =
+					aup->mii_bus->phy_map[phy_addr];
+
+				if (aup->mac_id == 1)
+					break;
+
+				/* no PHY here... */
+				if (!tmp_phydev)
+					continue;
+
+				/* already claimed by MAC0 */
+				if (tmp_phydev->attached_dev)
+					continue;
+
+				phydev = tmp_phydev;
+				break; /* found it */
 			}
 		}
 	}
@@ -524,11 +528,13 @@ au1000_setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		aup->rx_dma_ring[i] =
-			(volatile struct rx_dma *) (rx_base + sizeof(struct rx_dma)*i);
+			(volatile struct rx_dma *)
+					(rx_base + sizeof(struct rx_dma)*i);
 	}
 	for (i = 0; i < NUM_TX_DMA; i++) {
 		aup->tx_dma_ring[i] =
-			(volatile struct tx_dma *) (tx_base + sizeof(struct tx_dma)*i);
+			(volatile struct tx_dma *)
+					(tx_base + sizeof(struct tx_dma)*i);
 	}
 }
 
@@ -625,6 +631,7 @@ static int au1000_init(struct net_device *dev)
 	aup->mac->mac_addr_low = dev->dev_addr[3]<<24 | dev->dev_addr[2]<<16 |
 		dev->dev_addr[1]<<8 | dev->dev_addr[0];
 
+
 	for (i = 0; i < NUM_RX_DMA; i++)
 		aup->rx_dma_ring[i]->buff_stat |= RX_DMA_ENABLE;
 
@@ -936,8 +943,7 @@ static void au1000_multicast_list(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
-	netif_dbg(aup, drv, dev, "au1000_multicast_list: flags=%x\n", dev->flags);
-
+	netif_dbg(aup, drv, dev, "%s: flags=%x\n", __func__, dev->flags);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
@@ -1016,13 +1022,15 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	if (!request_mem_region(base->start, resource_size(base), pdev->name)) {
+	if (!request_mem_region(base->start, resource_size(base),
+							pdev->name)) {
 		dev_err(&pdev->dev, "failed to request memory region for base registers\n");
 		err = -ENXIO;
 		goto out;
 	}
 
-	if (!request_mem_region(macen->start, resource_size(macen), pdev->name)) {
+	if (!request_mem_region(macen->start, resource_size(macen),
+							pdev->name)) {
 		dev_err(&pdev->dev, "failed to request memory region for MAC enable register\n");
 		err = -ENXIO;
 		goto err_request;
@@ -1040,7 +1048,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup = netdev_priv(dev);
 
 	spin_lock_init(&aup->lock);
-	aup->msg_enable = (au1000_debug < 4 ? AU1000_DEF_MSG_ENABLE : au1000_debug);
+	aup->msg_enable = (au1000_debug < 4 ?
+				AU1000_DEF_MSG_ENABLE : au1000_debug);
 
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
@@ -1054,7 +1063,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* aup->mac is the base address of the MAC's registers */
-	aup->mac = (volatile struct mac_reg *)ioremap_nocache(base->start, resource_size(base));
+	aup->mac = (volatile struct mac_reg *)
+			ioremap_nocache(base->start, resource_size(base));
 	if (!aup->mac) {
 		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
 		err = -ENXIO;
@@ -1062,7 +1072,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* Setup some variables for quick register address access */
-	aup->enable = (volatile u32 *)ioremap_nocache(macen->start, resource_size(macen));
+	aup->enable = (volatile u32 *)ioremap_nocache(macen->start,
+						resource_size(macen));
 	if (!aup->enable) {
 		dev_err(&pdev->dev, "failed to ioremap MAC enable register\n");
 		err = -ENXIO;
@@ -1083,7 +1094,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	pd = pdev->dev.platform_data;
 	if (!pd) {
-		dev_info(&pdev->dev, "no platform_data passed, PHY search on MAC0\n");
+		dev_info(&pdev->dev, "no platform_data passed,"
+					" PHY search on MAC0\n");
 		aup->phy1_search_mac0 = 1;
 	} else {
 		if (is_valid_ether_addr(pd->mac))
@@ -1098,8 +1110,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	if (aup->phy_busid && aup->phy_busid > 0) {
-		dev_err(&pdev->dev, "MAC0-associated PHY attached 2nd MACs MII"
-				"bus not supported yet\n");
+		dev_err(&pdev->dev, "MAC0-associated PHY attached 2nd MACs MII bus not supported yet\n");
 		err = -ENODEV;
 		goto err_mdiobus_alloc;
 	}
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 44003e4..38c1d88 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -99,7 +99,8 @@ struct au1000_private {
 
 	int mac_id;
 
-	int mac_enabled;       /* whether MAC is currently enabled and running (req. for mdio) */
+	int mac_enabled;       /* whether MAC is currently enabled and running
+				 (req. for mdio) */
 
 	int old_link;          /* used by au1000_adjust_link */
 	int old_speed;
@@ -117,7 +118,8 @@ struct au1000_private {
 	int phy_busid;
 	int phy_irq;
 
-	/* These variables are just for quick access to certain regs addresses. */
+	/* These variables are just for quick access
+	 * to certain regs addresses. */
 	volatile struct mac_reg *mac;  /* mac registers                      */
 	volatile u32 *enable;     /* address of MAC Enable Register     */
 


