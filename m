From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/11] forcedeth: convert dprintk(KERN_DEBUG to netdev_dbg
Date: Mon, 29 Nov 2010 09:41:53 -0800
Message-ID: <3297c5fec244b76d7e96f0aa875effbb5c4e0f9f.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more standard macro to preface netdev->name.
Fix casting on resource use.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |  176 +++++++++++++++++++++++------------------------
 1 files changed, 87 insertions(+), 89 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e5f9d4b..767d1eb 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1139,22 +1139,22 @@ static int mii_rw(struct net_device *dev, int addr, int miireg, int value)
 
 	if (reg_delay(dev, NvRegMIIControl, NVREG_MIICTL_INUSE, 0,
 			NV_MIIPHY_DELAY, NV_MIIPHY_DELAYMAX)) {
-		dprintk(KERN_DEBUG "%s: mii_rw of reg %d at PHY %d timed out.\n",
-			dev->name, miireg, addr);
+		netdev_dbg(dev, "mii_rw of reg %d at PHY %d timed out\n",
+			   miireg, addr);
 		retval = -1;
 	} else if (value != MII_READ) {
 		/* it was a write operation - fewer failures are detectable */
-		dprintk(KERN_DEBUG "%s: mii_rw wrote 0x%x to reg %d at PHY %d\n",
-				dev->name, value, miireg, addr);
+		netdev_dbg(dev, "mii_rw wrote 0x%x to reg %d at PHY %d\n",
+			   value, miireg, addr);
 		retval = 0;
 	} else if (readl(base + NvRegMIIStatus) & NVREG_MIISTAT_ERROR) {
-		dprintk(KERN_DEBUG "%s: mii_rw of reg %d at PHY %d failed.\n",
-				dev->name, miireg, addr);
+		netdev_dbg(dev, "mii_rw of reg %d at PHY %d failed\n",
+			   miireg, addr);
 		retval = -1;
 	} else {
 		retval = readl(base + NvRegMIIData);
-		dprintk(KERN_DEBUG "%s: mii_rw read from reg %d at PHY %d: 0x%x.\n",
-				dev->name, miireg, addr, retval);
+		netdev_dbg(dev, "mii_rw read from reg %d at PHY %d: 0x%x\n",
+			   miireg, addr, retval);
 	}
 
 	return retval;
@@ -1506,7 +1506,7 @@ static void nv_start_rx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 rx_ctrl = readl(base + NvRegReceiverControl);
 
-	dprintk(KERN_DEBUG "%s: nv_start_rx\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 	/* Already running? Stop it. */
 	if ((readl(base + NvRegReceiverControl) & NVREG_RCVCTL_START) && !np->mac_in_use) {
 		rx_ctrl &= ~NVREG_RCVCTL_START;
@@ -1519,8 +1519,8 @@ static void nv_start_rx(struct net_device *dev)
 	if (np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
-	dprintk(KERN_DEBUG "%s: nv_start_rx to duplex %d, speed 0x%08x.\n",
-				dev->name, np->duplex, np->linkspeed);
+	netdev_dbg(dev, "%s: duplex %d, speed 0x%08x\n",
+		   __func__, np->duplex, np->linkspeed);
 	pci_push(base);
 }
 
@@ -1530,7 +1530,7 @@ static void nv_stop_rx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 rx_ctrl = readl(base + NvRegReceiverControl);
 
-	dprintk(KERN_DEBUG "%s: nv_stop_rx\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 	if (!np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_START;
 	else
@@ -1551,7 +1551,7 @@ static void nv_start_tx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 tx_ctrl = readl(base + NvRegTransmitterControl);
 
-	dprintk(KERN_DEBUG "%s: nv_start_tx\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 	tx_ctrl |= NVREG_XMITCTL_START;
 	if (np->mac_in_use)
 		tx_ctrl &= ~NVREG_XMITCTL_TX_PATH_EN;
@@ -1565,7 +1565,7 @@ static void nv_stop_tx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 tx_ctrl = readl(base + NvRegTransmitterControl);
 
-	dprintk(KERN_DEBUG "%s: nv_stop_tx\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 	if (!np->mac_in_use)
 		tx_ctrl &= ~NVREG_XMITCTL_START;
 	else
@@ -1598,7 +1598,7 @@ static void nv_txrx_reset(struct net_device *dev)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	dprintk(KERN_DEBUG "%s: nv_txrx_reset\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 	udelay(NV_TXRX_RESET_DELAY);
@@ -1612,7 +1612,7 @@ static void nv_mac_reset(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 temp1, temp2, temp3;
 
-	dprintk(KERN_DEBUG "%s: nv_mac_reset\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
@@ -2190,8 +2190,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	dprintk(KERN_DEBUG "%s: nv_start_xmit: entries %d queued for transmission. tx_flags_extra: %x\n",
-		dev->name, entries, tx_flags_extra);
+	netdev_dbg(dev, "%s: entries %d queued for transmission. tx_flags_extra: %x\n",
+		   __func__, entries, tx_flags_extra);
 	{
 		int j;
 		for (j = 0; j < 64; j++) {
@@ -2341,8 +2341,8 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	dprintk(KERN_DEBUG "%s: nv_start_xmit_optimized: entries %d queued for transmission. tx_flags_extra: %x\n",
-		dev->name, entries, tx_flags_extra);
+	netdev_dbg(dev, "%s: entries %d queued for transmission. tx_flags_extra: %x\n",
+		   __func__, entries, tx_flags_extra);
 	{
 		int j;
 		for (j = 0; j < 64; j++) {
@@ -2391,8 +2391,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
 	       (tx_work < limit)) {
 
-		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
-					dev->name, flags);
+		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
 
 		nv_unmap_txskb(np, np->get_tx_ctx);
 
@@ -2456,8 +2455,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID) &&
 	       (tx_work < limit)) {
 
-		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
-					dev->name, flags);
+		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
 
 		nv_unmap_txskb(np, np->get_tx_ctx);
 
@@ -2608,8 +2606,8 @@ static int nv_getlen(struct net_device *dev, void *packet, int datalen)
 		protolen = ntohs(((struct ethhdr *)packet)->h_proto);
 		hdrlen = ETH_HLEN;
 	}
-	dprintk(KERN_DEBUG "%s: nv_getlen: datalen %d, protolen %d, hdrlen %d\n",
-				dev->name, datalen, protolen, hdrlen);
+	netdev_dbg(dev, "%s: datalen %d, protolen %d, hdrlen %d\n",
+		   __func__, datalen, protolen, hdrlen);
 	if (protolen > ETH_DATA_LEN)
 		return datalen; /* Value in proto field not a len, no checks possible */
 
@@ -2620,26 +2618,25 @@ static int nv_getlen(struct net_device *dev, void *packet, int datalen)
 			/* more data on wire than in 802 header, trim of
 			 * additional data.
 			 */
-			dprintk(KERN_DEBUG "%s: nv_getlen: accepting %d bytes.\n",
-					dev->name, protolen);
+			netdev_dbg(dev, "%s: accepting %d bytes\n",
+				   __func__, protolen);
 			return protolen;
 		} else {
 			/* less data on wire than mentioned in header.
 			 * Discard the packet.
 			 */
-			dprintk(KERN_DEBUG "%s: nv_getlen: discarding long packet.\n",
-					dev->name);
+			netdev_dbg(dev, "%s: discarding long packet\n",
+				   __func__);
 			return -1;
 		}
 	} else {
 		/* short packet. Accept only if 802 values are also short */
 		if (protolen > ETH_ZLEN) {
-			dprintk(KERN_DEBUG "%s: nv_getlen: discarding short packet.\n",
-					dev->name);
+			netdev_dbg(dev, "%s: discarding short packet\n",
+				   __func__);
 			return -1;
 		}
-		dprintk(KERN_DEBUG "%s: nv_getlen: accepting %d bytes.\n",
-				dev->name, datalen);
+		netdev_dbg(dev, "%s: accepting %d bytes\n", __func__, datalen);
 		return datalen;
 	}
 }
@@ -2656,8 +2653,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 	      !((flags = le32_to_cpu(np->get_rx.orig->flaglen)) & NV_RX_AVAIL) &&
 		(rx_work < limit)) {
 
-		dprintk(KERN_DEBUG "%s: nv_rx_process: flags 0x%x.\n",
-					dev->name, flags);
+		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
 
 		/*
 		 * the packet is for us - immediately tear down the pci mapping.
@@ -2672,9 +2668,9 @@ static int nv_rx_process(struct net_device *dev, int limit)
 
 		{
 			int j;
-			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).", flags);
+			netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
 			for (j = 0; j < 64; j++) {
-				if ((j%16) == 0)
+				if ((j%16) == 0 && j)
 					dprintk("\n%03x:", j);
 				dprintk(" %02x", ((unsigned char *)skb->data)[j]);
 			}
@@ -2754,8 +2750,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		/* got a valid packet - forward it to the network core */
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, dev);
-		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
-					dev->name, len, skb->protocol);
+		netdev_dbg(dev, "%s: %d bytes, proto %d accepted\n",
+			   __func__, len, skb->protocol);
 		napi_gro_receive(&np->napi, skb);
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
@@ -2784,8 +2780,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 	      !((flags = le32_to_cpu(np->get_rx.ex->flaglen)) & NV_RX2_AVAIL) &&
 	      (rx_work < limit)) {
 
-		dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: flags 0x%x.\n",
-					dev->name, flags);
+		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
 
 		/*
 		 * the packet is for us - immediately tear down the pci mapping.
@@ -2800,9 +2795,9 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 
 		{
 			int j;
-			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).", flags);
+			netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
 			for (j = 0; j < 64; j++) {
-				if ((j%16) == 0)
+				if ((j%16) == 0 && j)
 					dprintk("\n%03x:", j);
 				dprintk(" %02x", ((unsigned char *)skb->data)[j]);
 			}
@@ -2840,8 +2835,8 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			skb->protocol = eth_type_trans(skb, dev);
 			prefetch(skb->data);
 
-			dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: %d bytes, proto %d accepted.\n",
-				dev->name, len, skb->protocol);
+			netdev_dbg(dev, "%s: %d bytes, proto %d accepted\n",
+				   __func__, len, skb->protocol);
 
 			if (likely(!np->vlangrp)) {
 				napi_gro_receive(&np->napi, skb);
@@ -3134,8 +3129,8 @@ static int nv_update_linkspeed(struct net_device *dev)
 	mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
 
 	if (!(mii_status & BMSR_LSTATUS)) {
-		dprintk(KERN_DEBUG "%s: no link detected by phy - falling back to 10HD.\n",
-				dev->name);
+		netdev_dbg(dev,
+			   "no link detected by phy - falling back to 10HD\n");
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 		retval = 0;
@@ -3143,8 +3138,8 @@ static int nv_update_linkspeed(struct net_device *dev)
 	}
 
 	if (np->autoneg == 0) {
-		dprintk(KERN_DEBUG "%s: nv_update_linkspeed: autoneg off, PHY set to 0x%04x.\n",
-				dev->name, np->fixed_mode);
+		netdev_dbg(dev, "%s: autoneg off, PHY set to 0x%04x\n",
+			   __func__, np->fixed_mode);
 		if (np->fixed_mode & LPA_100FULL) {
 			newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_100;
 			newdup = 1;
@@ -3167,14 +3162,15 @@ static int nv_update_linkspeed(struct net_device *dev)
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 		retval = 0;
-		dprintk(KERN_DEBUG "%s: autoneg not completed - falling back to 10HD.\n", dev->name);
+		netdev_dbg(dev,
+			   "autoneg not completed - falling back to 10HD\n");
 		goto set_speed;
 	}
 
 	adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 	lpa = mii_rw(dev, np->phyaddr, MII_LPA, MII_READ);
-	dprintk(KERN_DEBUG "%s: nv_update_linkspeed: PHY advertises 0x%04x, lpa 0x%04x.\n",
-				dev->name, adv, lpa);
+	netdev_dbg(dev, "%s: PHY advertises 0x%04x, lpa 0x%04x\n",
+		   __func__, adv, lpa);
 
 	retval = 1;
 	if (np->gigabit == PHY_GIGABIT) {
@@ -3183,8 +3179,8 @@ static int nv_update_linkspeed(struct net_device *dev)
 
 		if ((control_1000 & ADVERTISE_1000FULL) &&
 			(status_1000 & LPA_1000FULL)) {
-			dprintk(KERN_DEBUG "%s: nv_update_linkspeed: GBit ethernet detected.\n",
-				dev->name);
+			netdev_dbg(dev, "%s: GBit ethernet detected\n",
+				   __func__);
 			newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_1000;
 			newdup = 1;
 			goto set_speed;
@@ -3206,7 +3202,8 @@ static int nv_update_linkspeed(struct net_device *dev)
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 	} else {
-		dprintk(KERN_DEBUG "%s: bad ability %04x - falling back to 10HD.\n", dev->name, adv_lpa);
+		netdev_dbg(dev, "bad ability %04x - falling back to 10HD\n",
+			   adv_lpa);
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 	}
@@ -3363,7 +3360,7 @@ static void nv_link_irq(struct net_device *dev)
 
 	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
 		nv_linkchange(dev);
-	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
+	netdev_dbg(dev, "link change notification done\n");
 }
 
 static void nv_msi_workaround(struct fe_priv *np)
@@ -3414,7 +3411,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		np->events = readl(base + NvRegIrqStatus);
@@ -3423,7 +3420,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		np->events = readl(base + NvRegMSIXIrqStatus);
 		writel(np->events, base + NvRegMSIXIrqStatus);
 	}
-	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
+	netdev_dbg(dev, "irq: %08x\n", np->events);
 	if (!(np->events & np->irqmask))
 		return IRQ_NONE;
 
@@ -3437,7 +3434,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		__napi_schedule(&np->napi);
 	}
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
+	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_HANDLED;
 }
@@ -3453,7 +3450,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		np->events = readl(base + NvRegIrqStatus);
@@ -3462,7 +3459,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		np->events = readl(base + NvRegMSIXIrqStatus);
 		writel(np->events, base + NvRegMSIXIrqStatus);
 	}
-	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
+	netdev_dbg(dev, "irq: %08x\n", np->events);
 	if (!(np->events & np->irqmask))
 		return IRQ_NONE;
 
@@ -3475,7 +3472,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		writel(0, base + NvRegIrqMask);
 		__napi_schedule(&np->napi);
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
+	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_HANDLED;
 }
@@ -3489,12 +3486,12 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	int i;
 	unsigned long flags;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
 		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: tx irq: %08x\n", dev->name, events);
+		netdev_dbg(dev, "tx irq: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3518,7 +3515,7 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 		}
 
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx completed\n", dev->name);
+	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(i);
 }
@@ -3603,12 +3600,12 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	int i;
 	unsigned long flags;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
 		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: rx irq: %08x\n", dev->name, events);
+		netdev_dbg(dev, "rx irq: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3636,7 +3633,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 			break;
 		}
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx completed\n", dev->name);
+	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(i);
 }
@@ -3650,12 +3647,12 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 	int i;
 	unsigned long flags;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_other\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
 		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
+		netdev_dbg(dev, "irq: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3705,7 +3702,7 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 		}
 
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_other completed\n", dev->name);
+	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(i);
 }
@@ -3717,7 +3714,7 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_test\n", dev->name);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
@@ -3727,7 +3724,7 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 		writel(NVREG_IRQ_TIMER, base + NvRegMSIXIrqStatus);
 	}
 	pci_push(base);
-	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
+	netdev_dbg(dev, "irq: %08x\n", events);
 	if (!(events & NVREG_IRQ_TIMER))
 		return IRQ_RETVAL(0);
 
@@ -3737,7 +3734,7 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 	np->intr_test = 1;
 	spin_unlock(&np->lock);
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_test completed\n", dev->name);
+	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(1);
 }
@@ -4874,21 +4871,21 @@ static int nv_loopback_test(struct net_device *dev)
 	if (ret) {
 		if (len != pkt_len) {
 			ret = 0;
-			dprintk(KERN_DEBUG "%s: loopback len mismatch %d vs %d\n",
-				dev->name, len, pkt_len);
+			netdev_dbg(dev, "loopback len mismatch %d vs %d\n",
+				   len, pkt_len);
 		} else {
 			rx_skb = np->rx_skb[0].skb;
 			for (i = 0; i < pkt_len; i++) {
 				if (rx_skb->data[i] != (u8)(i & 0xff)) {
 					ret = 0;
-					dprintk(KERN_DEBUG "%s: loopback pattern check failed on byte %d\n",
-						dev->name, i);
+					netdev_dbg(dev, "loopback pattern check failed on byte %d\n",
+						   i);
 					break;
 				}
 			}
 		}
 	} else {
-		dprintk(KERN_DEBUG "%s: loopback - did not receive test packet\n", dev->name);
+		netdev_dbg(dev, "loopback - did not receive test packet\n");
 	}
 
 	pci_unmap_single(np->pci_dev, test_dma_addr,
@@ -5138,7 +5135,7 @@ static int nv_open(struct net_device *dev)
 	int oom, i;
 	u32 low;
 
-	dprintk(KERN_DEBUG "nv_open: begin\n");
+	netdev_dbg(dev, "%s\n", __func__);
 
 	/* power up phy */
 	mii_rw(dev, np->phyaddr, MII_BMCR,
@@ -5435,10 +5432,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	err = -EINVAL;
 	addr = 0;
 	for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
-		dprintk(KERN_DEBUG "%s: resource %d start %p len %ld flags 0x%08lx.\n",
-				pci_name(pci_dev), i, (void *)pci_resource_start(pci_dev, i),
-				pci_resource_len(pci_dev, i),
-				pci_resource_flags(pci_dev, i));
+		netdev_dbg(dev, "%s: resource %d start %p len %lld flags 0x%08lx\n",
+			   pci_name(pci_dev), i,
+			   (void *)(unsigned long)pci_resource_start(pci_dev, i),
+			   (long long)pci_resource_len(pci_dev, i),
+			   pci_resource_flags(pci_dev, i));
 		if (pci_resource_flags(pci_dev, i) & IORESOURCE_MEM &&
 				pci_resource_len(pci_dev, i) >= np->register_size) {
 			addr = pci_resource_start(pci_dev, i);
@@ -5607,8 +5605,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		random_ether_addr(dev->dev_addr);
 	}
 
-	dprintk(KERN_DEBUG "%s: MAC Address %pM\n",
-		pci_name(pci_dev), dev->dev_addr);
+	netdev_dbg(dev, "%s: MAC Address %pM\n",
+		   pci_name(pci_dev), dev->dev_addr);
 
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
@@ -5741,8 +5739,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->phy_model = id2 & PHYID2_MODEL_MASK;
 		id1 = (id1 & PHYID1_OUI_MASK) << PHYID1_OUI_SHFT;
 		id2 = (id2 & PHYID2_OUI_MASK) >> PHYID2_OUI_SHFT;
-		dprintk(KERN_DEBUG "%s: open: Found PHY %04x:%04x at address %d.\n",
-			pci_name(pci_dev), id1, id2, phyaddr);
+		netdev_dbg(dev, "%s: %s: Found PHY %04x:%04x at address %d\n",
+			   pci_name(pci_dev), __func__, id1, id2, phyaddr);
 		np->phyaddr = phyaddr;
 		np->phy_oui = id1 | id2;
 
-- 
1.7.3.2.245.g03276.dirty
