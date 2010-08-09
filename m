From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/6] au1000-eth: fix all "line over 80 characters warnings"
Date: Mon, 9 Aug 2010 22:03:35 +0200
Message-ID: <201008092203.36778.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35474 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604Ab0HIUCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 16:02:49 -0400
Received: by mail-wy0-f174.google.com with SMTP id 11so48087wyi.19
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 13:02:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index b5f992a..9a0515d 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -377,12 +377,15 @@ static int au1000_mii_probe(struct net_device *dev)
 	} else {
 		int phy_addr;
 
-		/* find the first (lowest address) PHY on the current MAC's MII bus */
-		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
+		/* find the first (lowest address) PHY
+		 * on the current MAC's MII bus */
+		for (phy_addr = 0;
+			phy_addr < PHY_MAX_ADDR; phy_addr++)
 			if (aup->mii_bus->phy_map[phy_addr]) {
 				phydev = aup->mii_bus->phy_map[phy_addr];
 				if (!aup->phy_search_highest_addr)
-					break; /* break out with first one found */
+					/* break out with first one found */
+					break;
 			}
 
 		if (aup->phy1_search_mac0) {
@@ -390,22 +393,26 @@ static int au1000_mii_probe(struct net_device *dev)
 			if (!phydev && (aup->mac_id == 1)) {
 				/* no PHY found, maybe we have a dual PHY? */
 				dev_info(&dev->dev, ": no PHY found on MAC1, "
-					"let's see if it's attached to MAC0...\n");
+					"let's see if it's attached to MAC0..."
+					"\n");
 
-				/* find the first (lowest address) non-attached PHY on
-				 * the MAC0 MII bus */
-				for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+				/* find the first (lowest address) non-attached
+				 * PHY on the MAC0 MII bus */
+				for (phy_addr = 0; phy_addr < PHY_MAX_ADDR;
+								phy_addr++) {
 					struct phy_device *const tmp_phydev =
-							aup->mii_bus->phy_map[phy_addr];
+						aup->mii_bus->phy_map[phy_addr];
 
 					if (aup->mac_id == 1)
 						break;
 
+					/* no PHY here... */
 					if (!tmp_phydev)
-						continue; /* no PHY here... */
+						continue;
 
+					/* already claimed by MAC0 */
 					if (tmp_phydev->attached_dev)
-						continue; /* already claimed by MAC0 */
+						continue;
 
 					phydev = tmp_phydev;
 					break; /* found it */
@@ -532,11 +539,13 @@ au1000_setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
 
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
 
@@ -633,6 +642,7 @@ static int au1000_init(struct net_device *dev)
 	aup->mac->mac_addr_low = dev->dev_addr[3]<<24 | dev->dev_addr[2]<<16 |
 		dev->dev_addr[1]<<8 | dev->dev_addr[0];
 
+
 	for (i = 0; i < NUM_RX_DMA; i++)
 		aup->rx_dma_ring[i]->buff_stat |= RX_DMA_ENABLE;
 
@@ -709,7 +719,8 @@ static int au1000_rx(struct net_device *dev)
 			frmlen -= 4; /* Remove FCS */
 			skb = dev_alloc_skb(frmlen + 2);
 			if (skb == NULL) {
-				netdev_err(dev, "Memory squeeze, dropping packet.\n");
+				netdev_err(dev, "Memory squeeze,"
+							" dropping packet.\n");
 				dev->stats.rx_dropped++;
 				continue;
 			}
@@ -944,8 +955,8 @@ static void au1000_multicast_list(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
-	netif_dbg(aup, drv, dev, "au1000_multicast_list: flags=%x\n", dev->flags);
-
+	netif_dbg(aup, drv, dev, "au1000_multicast_list: flags=%x\n",
+							dev->flags);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
@@ -1025,14 +1036,18 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	if (!request_mem_region(base->start, resource_size(base), pdev->name)) {
-		dev_err(&pdev->dev, "failed to request memory region for base registers\n");
+	if (!request_mem_region(base->start, resource_size(base),
+							pdev->name)) {
+		dev_err(&pdev->dev, "failed to request memory region for"
+						" base registers\n");
 		err = -ENXIO;
 		goto out;
 	}
 
-	if (!request_mem_region(macen->start, resource_size(macen), pdev->name)) {
-		dev_err(&pdev->dev, "failed to request memory region for MAC enable register\n");
+	if (!request_mem_region(macen->start, resource_size(macen),
+							pdev->name)) {
+		dev_err(&pdev->dev, "failed to request memory region for"
+						" MAC enable register\n");
 		err = -ENXIO;
 		goto err_request;
 	}
@@ -1049,7 +1064,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup = netdev_priv(dev);
 
 	spin_lock_init(&aup->lock);
-	aup->msg_enable = (au1000_debug < 4 ? AU1000_DEF_MSG_ENABLE : au1000_debug);
+	aup->msg_enable = (au1000_debug < 4 ?
+				AU1000_DEF_MSG_ENABLE : au1000_debug);
 
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
@@ -1063,7 +1079,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* aup->mac is the base address of the MAC's registers */
-	aup->mac = (volatile struct mac_reg *)ioremap_nocache(base->start, resource_size(base));
+	aup->mac = (volatile struct mac_reg *)
+			ioremap_nocache(base->start, resource_size(base));
 	if (!aup->mac) {
 		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
 		err = -ENXIO;
@@ -1071,7 +1088,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* Setup some variables for quick register address access */
-	aup->enable = (volatile u32 *)ioremap_nocache(macen->start, resource_size(macen));
+	aup->enable = (volatile u32 *)ioremap_nocache(macen->start,
+						resource_size(macen));
 	if (!aup->enable) {
 		dev_err(&pdev->dev, "failed to ioremap MAC enable register\n");
 		err = -ENXIO;
@@ -1081,7 +1099,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	if (pdev->id == 0) {
 		if (prom_get_ethernet_addr(ethaddr) == 0)
-			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
+			memcpy(au1000_mac_addr, ethaddr,
+						sizeof(au1000_mac_addr));
 		else {
 			netdev_info(dev, "No MAC address found\n");
 				/* Use the hard coded MAC addresses */
@@ -1103,7 +1122,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	pd = pdev->dev.platform_data;
 	if (!pd) {
-		dev_info(&pdev->dev, "no platform_data passed, PHY search on MAC0\n");
+		dev_info(&pdev->dev, "no platform_data passed,"
+					" PHY search on MAC0\n");
 		aup->phy1_search_mac0 = 1;
 	} else {
 		aup->phy_static_config = pd->phy_static_config;
@@ -1116,7 +1136,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	if (aup->phy_busid && aup->phy_busid > 0) {
 		dev_err(&pdev->dev, "MAC0-associated PHY attached 2nd MACs MII"
-				"bus not supported yet\n");
+				" bus not supported yet\n");
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
 


