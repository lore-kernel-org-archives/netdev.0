From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/11] forcedeth: Remove netdev_dbg uses
Date: Mon, 29 Nov 2010 09:42:01 -0800
Message-ID: <f7c2186e05de1ac8da10f5ae28a3ba34f98aaed1.1291051316.git.joe@perches.com>
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

These were probably just for initial driver debugging
and have not been enabled in builds in git history.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |  133 -----------------------------------------------
 1 files changed, 0 insertions(+), 133 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 60edf01..c2945d6 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1136,22 +1136,14 @@ static int mii_rw(struct net_device *dev, int addr, int miireg, int value)
 
 	if (reg_delay(dev, NvRegMIIControl, NVREG_MIICTL_INUSE, 0,
 			NV_MIIPHY_DELAY, NV_MIIPHY_DELAYMAX)) {
-		netdev_dbg(dev, "mii_rw of reg %d at PHY %d timed out\n",
-			   miireg, addr);
 		retval = -1;
 	} else if (value != MII_READ) {
 		/* it was a write operation - fewer failures are detectable */
-		netdev_dbg(dev, "mii_rw wrote 0x%x to reg %d at PHY %d\n",
-			   value, miireg, addr);
 		retval = 0;
 	} else if (readl(base + NvRegMIIStatus) & NVREG_MIISTAT_ERROR) {
-		netdev_dbg(dev, "mii_rw of reg %d at PHY %d failed\n",
-			   miireg, addr);
 		retval = -1;
 	} else {
 		retval = readl(base + NvRegMIIData);
-		netdev_dbg(dev, "mii_rw read from reg %d at PHY %d: 0x%x\n",
-			   miireg, addr, retval);
 	}
 
 	return retval;
@@ -1516,7 +1508,6 @@ static void nv_start_rx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 rx_ctrl = readl(base + NvRegReceiverControl);
 
-	netdev_dbg(dev, "%s\n", __func__);
 	/* Already running? Stop it. */
 	if ((readl(base + NvRegReceiverControl) & NVREG_RCVCTL_START) && !np->mac_in_use) {
 		rx_ctrl &= ~NVREG_RCVCTL_START;
@@ -1529,8 +1520,6 @@ static void nv_start_rx(struct net_device *dev)
 	if (np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
-	netdev_dbg(dev, "%s: duplex %d, speed 0x%08x\n",
-		   __func__, np->duplex, np->linkspeed);
 	pci_push(base);
 }
 
@@ -1540,7 +1529,6 @@ static void nv_stop_rx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 rx_ctrl = readl(base + NvRegReceiverControl);
 
-	netdev_dbg(dev, "%s\n", __func__);
 	if (!np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_START;
 	else
@@ -1562,7 +1550,6 @@ static void nv_start_tx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 tx_ctrl = readl(base + NvRegTransmitterControl);
 
-	netdev_dbg(dev, "%s\n", __func__);
 	tx_ctrl |= NVREG_XMITCTL_START;
 	if (np->mac_in_use)
 		tx_ctrl &= ~NVREG_XMITCTL_TX_PATH_EN;
@@ -1576,7 +1563,6 @@ static void nv_stop_tx(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 tx_ctrl = readl(base + NvRegTransmitterControl);
 
-	netdev_dbg(dev, "%s\n", __func__);
 	if (!np->mac_in_use)
 		tx_ctrl &= ~NVREG_XMITCTL_START;
 	else
@@ -1610,7 +1596,6 @@ static void nv_txrx_reset(struct net_device *dev)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	netdev_dbg(dev, "%s\n", __func__);
 	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 	udelay(NV_TXRX_RESET_DELAY);
@@ -1624,8 +1609,6 @@ static void nv_mac_reset(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 temp1, temp2, temp3;
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 
@@ -2202,13 +2185,6 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	netdev_dbg(dev, "%s: entries %d queued for transmission. tx_flags_extra: %x\n",
-		   __func__, entries, tx_flags_extra);
-#ifdef DEBUG
-	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1,
-		       skb->data, 64, true);
-#endif
-
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	return NETDEV_TX_OK;
 }
@@ -2348,13 +2324,6 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	netdev_dbg(dev, "%s: entries %d queued for transmission. tx_flags_extra: %x\n",
-		   __func__, entries, tx_flags_extra);
-#ifdef DEBUG
-	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1,
-		       skb->data, 64, true);
-#endif
-
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	return NETDEV_TX_OK;
 }
@@ -2393,8 +2362,6 @@ static int nv_tx_done(struct net_device *dev, int limit)
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
 	       (tx_work < limit)) {
 
-		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
-
 		nv_unmap_txskb(np, np->get_tx_ctx);
 
 		if (np->desc_ver == DESC_VER_1) {
@@ -2457,8 +2424,6 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID) &&
 	       (tx_work < limit)) {
 
-		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
-
 		nv_unmap_txskb(np, np->get_tx_ctx);
 
 		if (flags & NV_TX2_LASTPACKET) {
@@ -2607,8 +2572,6 @@ static int nv_getlen(struct net_device *dev, void *packet, int datalen)
 		protolen = ntohs(((struct ethhdr *)packet)->h_proto);
 		hdrlen = ETH_HLEN;
 	}
-	netdev_dbg(dev, "%s: datalen %d, protolen %d, hdrlen %d\n",
-		   __func__, datalen, protolen, hdrlen);
 	if (protolen > ETH_DATA_LEN)
 		return datalen; /* Value in proto field not a len, no checks possible */
 
@@ -2619,25 +2582,18 @@ static int nv_getlen(struct net_device *dev, void *packet, int datalen)
 			/* more data on wire than in 802 header, trim of
 			 * additional data.
 			 */
-			netdev_dbg(dev, "%s: accepting %d bytes\n",
-				   __func__, protolen);
 			return protolen;
 		} else {
 			/* less data on wire than mentioned in header.
 			 * Discard the packet.
 			 */
-			netdev_dbg(dev, "%s: discarding long packet\n",
-				   __func__);
 			return -1;
 		}
 	} else {
 		/* short packet. Accept only if 802 values are also short */
 		if (protolen > ETH_ZLEN) {
-			netdev_dbg(dev, "%s: discarding short packet\n",
-				   __func__);
 			return -1;
 		}
-		netdev_dbg(dev, "%s: accepting %d bytes\n", __func__, datalen);
 		return datalen;
 	}
 }
@@ -2654,8 +2610,6 @@ static int nv_rx_process(struct net_device *dev, int limit)
 	      !((flags = le32_to_cpu(np->get_rx.orig->flaglen)) & NV_RX_AVAIL) &&
 		(rx_work < limit)) {
 
-		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
-
 		/*
 		 * the packet is for us - immediately tear down the pci mapping.
 		 * TODO: check if a prefetch of the first cacheline improves
@@ -2667,11 +2621,6 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb = np->get_rx_ctx->skb;
 		np->get_rx_ctx->skb = NULL;
 
-			netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
-#ifdef DEBUG
-			print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET,
-				       16, 1, skb->data, 64, true);
-#endif
 		/* look at what we actually got: */
 		if (np->desc_ver == DESC_VER_1) {
 			if (likely(flags & NV_RX_DESCRIPTORVALID)) {
@@ -2746,8 +2695,6 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		/* got a valid packet - forward it to the network core */
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, dev);
-		netdev_dbg(dev, "%s: %d bytes, proto %d accepted\n",
-			   __func__, len, skb->protocol);
 		napi_gro_receive(&np->napi, skb);
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
@@ -2776,8 +2723,6 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 	      !((flags = le32_to_cpu(np->get_rx.ex->flaglen)) & NV_RX2_AVAIL) &&
 	      (rx_work < limit)) {
 
-		netdev_dbg(dev, "%s: flags 0x%x\n", __func__, flags);
-
 		/*
 		 * the packet is for us - immediately tear down the pci mapping.
 		 * TODO: check if a prefetch of the first cacheline improves
@@ -2789,11 +2734,6 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 		skb = np->get_rx_ctx->skb;
 		np->get_rx_ctx->skb = NULL;
 
-		netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
-#ifdef DEBUG
-		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1,
-			       skb->data, 64, true);
-#endif
 		/* look at what we actually got: */
 		if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
 			len = flags & LEN_MASK_V2;
@@ -2826,9 +2766,6 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			skb->protocol = eth_type_trans(skb, dev);
 			prefetch(skb->data);
 
-			netdev_dbg(dev, "%s: %d bytes, proto %d accepted\n",
-				   __func__, len, skb->protocol);
-
 			if (likely(!np->vlangrp)) {
 				napi_gro_receive(&np->napi, skb);
 			} else {
@@ -3044,7 +2981,6 @@ static void nv_set_multicast(struct net_device *dev)
 	writel(mask[0], base + NvRegMulticastMaskA);
 	writel(mask[1], base + NvRegMulticastMaskB);
 	writel(pff, base + NvRegPacketFilterFlags);
-	netdev_dbg(dev, "reconfiguration for multicast lists\n");
 	nv_start_rx(dev);
 	spin_unlock_irq(&np->lock);
 }
@@ -3119,8 +3055,6 @@ static int nv_update_linkspeed(struct net_device *dev)
 	mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
 
 	if (!(mii_status & BMSR_LSTATUS)) {
-		netdev_dbg(dev,
-			   "no link detected by phy - falling back to 10HD\n");
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 		retval = 0;
@@ -3128,8 +3062,6 @@ static int nv_update_linkspeed(struct net_device *dev)
 	}
 
 	if (np->autoneg == 0) {
-		netdev_dbg(dev, "%s: autoneg off, PHY set to 0x%04x\n",
-			   __func__, np->fixed_mode);
 		if (np->fixed_mode & LPA_100FULL) {
 			newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_100;
 			newdup = 1;
@@ -3152,15 +3084,11 @@ static int nv_update_linkspeed(struct net_device *dev)
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 		retval = 0;
-		netdev_dbg(dev,
-			   "autoneg not completed - falling back to 10HD\n");
 		goto set_speed;
 	}
 
 	adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 	lpa = mii_rw(dev, np->phyaddr, MII_LPA, MII_READ);
-	netdev_dbg(dev, "%s: PHY advertises 0x%04x, lpa 0x%04x\n",
-		   __func__, adv, lpa);
 
 	retval = 1;
 	if (np->gigabit == PHY_GIGABIT) {
@@ -3169,8 +3097,6 @@ static int nv_update_linkspeed(struct net_device *dev)
 
 		if ((control_1000 & ADVERTISE_1000FULL) &&
 			(status_1000 & LPA_1000FULL)) {
-			netdev_dbg(dev, "%s: GBit ethernet detected\n",
-				   __func__);
 			newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_1000;
 			newdup = 1;
 			goto set_speed;
@@ -3192,8 +3118,6 @@ static int nv_update_linkspeed(struct net_device *dev)
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 	} else {
-		netdev_dbg(dev, "bad ability %04x - falling back to 10HD\n",
-			   adv_lpa);
 		newls = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;
 		newdup = 0;
 	}
@@ -3202,9 +3126,6 @@ set_speed:
 	if (np->duplex == newdup && np->linkspeed == newls)
 		return retval;
 
-	netdev_dbg(dev, "changing link setting from %d/%d to %d/%d\n",
-		   np->linkspeed, np->duplex, newls, newdup);
-
 	np->duplex = newdup;
 	np->linkspeed = newls;
 
@@ -3346,11 +3267,9 @@ static void nv_link_irq(struct net_device *dev)
 
 	miistat = readl(base + NvRegMIIStatus);
 	writel(NVREG_MIISTAT_LINKCHANGE, base + NvRegMIIStatus);
-	netdev_dbg(dev, "link change irq, status 0x%x\n", miistat);
 
 	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
 		nv_linkchange(dev);
-	netdev_dbg(dev, "link change notification done\n");
 }
 
 static void nv_msi_workaround(struct fe_priv *np)
@@ -3401,8 +3320,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		np->events = readl(base + NvRegIrqStatus);
 		writel(np->events, base + NvRegIrqStatus);
@@ -3410,7 +3327,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		np->events = readl(base + NvRegMSIXIrqStatus);
 		writel(np->events, base + NvRegMSIXIrqStatus);
 	}
-	netdev_dbg(dev, "irq: %08x\n", np->events);
 	if (!(np->events & np->irqmask))
 		return IRQ_NONE;
 
@@ -3424,8 +3340,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		__napi_schedule(&np->napi);
 	}
 
-	netdev_dbg(dev, "%s: completed\n", __func__);
-
 	return IRQ_HANDLED;
 }
 
@@ -3440,8 +3354,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		np->events = readl(base + NvRegIrqStatus);
 		writel(np->events, base + NvRegIrqStatus);
@@ -3449,7 +3361,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		np->events = readl(base + NvRegMSIXIrqStatus);
 		writel(np->events, base + NvRegMSIXIrqStatus);
 	}
-	netdev_dbg(dev, "irq: %08x\n", np->events);
 	if (!(np->events & np->irqmask))
 		return IRQ_NONE;
 
@@ -3462,7 +3373,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		writel(0, base + NvRegIrqMask);
 		__napi_schedule(&np->napi);
 	}
-	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_HANDLED;
 }
@@ -3476,12 +3386,9 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	int i;
 	unsigned long flags;
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
 		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
-		netdev_dbg(dev, "tx irq: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3505,7 +3412,6 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 		}
 
 	}
-	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(i);
 }
@@ -3590,12 +3496,9 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	int i;
 	unsigned long flags;
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
 		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
-		netdev_dbg(dev, "rx irq: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3623,7 +3526,6 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 			break;
 		}
 	}
-	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(i);
 }
@@ -3637,12 +3539,9 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 	int i;
 	unsigned long flags;
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
 		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
-		netdev_dbg(dev, "irq: %08x\n", events);
 		if (!(events & np->irqmask))
 			break;
 
@@ -3692,7 +3591,6 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 		}
 
 	}
-	netdev_dbg(dev, "%s: completed\n", __func__);
 
 	return IRQ_RETVAL(i);
 }
@@ -3704,8 +3602,6 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
 		writel(NVREG_IRQ_TIMER, base + NvRegIrqStatus);
@@ -3714,7 +3610,6 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 		writel(NVREG_IRQ_TIMER, base + NvRegMSIXIrqStatus);
 	}
 	pci_push(base);
-	netdev_dbg(dev, "irq: %08x\n", events);
 	if (!(events & NVREG_IRQ_TIMER))
 		return IRQ_RETVAL(0);
 
@@ -3724,8 +3619,6 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 	np->intr_test = 1;
 	spin_unlock(&np->lock);
 
-	netdev_dbg(dev, "%s: completed\n", __func__);
-
 	return IRQ_RETVAL(1);
 }
 
@@ -4868,21 +4761,15 @@ static int nv_loopback_test(struct net_device *dev)
 	if (ret) {
 		if (len != pkt_len) {
 			ret = 0;
-			netdev_dbg(dev, "loopback len mismatch %d vs %d\n",
-				   len, pkt_len);
 		} else {
 			rx_skb = np->rx_skb[0].skb;
 			for (i = 0; i < pkt_len; i++) {
 				if (rx_skb->data[i] != (u8)(i & 0xff)) {
 					ret = 0;
-					netdev_dbg(dev, "loopback pattern check failed on byte %d\n",
-						   i);
 					break;
 				}
 			}
 		}
-	} else {
-		netdev_dbg(dev, "loopback - did not receive test packet\n");
 	}
 
 	pci_unmap_single(np->pci_dev, test_dma_addr,
@@ -5132,8 +5019,6 @@ static int nv_open(struct net_device *dev)
 	int oom, i;
 	u32 low;
 
-	netdev_dbg(dev, "%s\n", __func__);
-
 	/* power up phy */
 	mii_rw(dev, np->phyaddr, MII_BMCR,
 	       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ) & ~BMCR_PDOWN);
@@ -5261,7 +5146,6 @@ static int nv_open(struct net_device *dev)
 		u32 miistat;
 		miistat = readl(base + NvRegMIIStatus);
 		writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
-		netdev_dbg(dev, "startup: got 0x%08x\n", miistat);
 	}
 	/* set linkspeed to invalid value, thus force nv_update_linkspeed
 	 * to init hw */
@@ -5317,7 +5201,6 @@ static int nv_close(struct net_device *dev)
 	base = get_hwbase(dev);
 	nv_disable_hw_interrupts(dev, np->irqmask);
 	pci_push(base);
-	netdev_dbg(dev, "Irqmask is zero again\n");
 
 	spin_unlock_irq(&np->lock);
 
@@ -5430,11 +5313,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	err = -EINVAL;
 	addr = 0;
 	for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
-		netdev_dbg(dev, "%s: resource %d start %p len %lld flags 0x%08lx\n",
-			   pci_name(pci_dev), i,
-			   (void *)(unsigned long)pci_resource_start(pci_dev, i),
-			   (long long)pci_resource_len(pci_dev, i),
-			   pci_resource_flags(pci_dev, i));
 		if (pci_resource_flags(pci_dev, i) & IORESOURCE_MEM &&
 				pci_resource_len(pci_dev, i) >= np->register_size) {
 			addr = pci_resource_start(pci_dev, i);
@@ -5602,9 +5480,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		random_ether_addr(dev->dev_addr);
 	}
 
-	netdev_dbg(dev, "%s: MAC Address %pM\n",
-		   pci_name(pci_dev), dev->dev_addr);
-
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
 
@@ -5666,11 +5541,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	if (id->driver_data & DEV_NEED_TIMERIRQ)
 		np->irqmask |= NVREG_IRQ_TIMER;
 	if (id->driver_data & DEV_NEED_LINKTIMER) {
-		netdev_dbg(dev, "%s: link timer on\n", pci_name(pci_dev));
 		np->need_linktimer = 1;
 		np->link_timeout = jiffies + LINK_TIMEOUT;
 	} else {
-		netdev_dbg(dev, "%s: link timer off\n", pci_name(pci_dev));
 		np->need_linktimer = 0;
 	}
 
@@ -5701,16 +5574,12 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 			np->mac_in_use = 1;
 			if (np->mgmt_version > 0)
 				np->mac_in_use = readl(base + NvRegMgmtUnitControl) & NVREG_MGMTUNITCONTROL_INUSE;
-			netdev_dbg(dev, "%s: mgmt unit is running. mac in use %x\n",
-				   pci_name(pci_dev), np->mac_in_use);
 			/* management unit setup the phy already? */
 			if (np->mac_in_use &&
 			    ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
 			     NVREG_XMITCTL_SYNC_PHY_INIT)) {
 				/* phy is inited by mgmt unit */
 				phyinitialized = 1;
-				netdev_dbg(dev, "%s: Phy already initialized by mgmt unit\n",
-					   pci_name(pci_dev));
 			} else {
 				/* we need to init the phy */
 			}
@@ -5736,8 +5605,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->phy_model = id2 & PHYID2_MODEL_MASK;
 		id1 = (id1 & PHYID1_OUI_MASK) << PHYID1_OUI_SHFT;
 		id2 = (id2 & PHYID2_OUI_MASK) >> PHYID2_OUI_SHFT;
-		netdev_dbg(dev, "%s: %s: Found PHY %04x:%04x at address %d\n",
-			   pci_name(pci_dev), __func__, id1, id2, phyaddr);
 		np->phyaddr = phyaddr;
 		np->phy_oui = id1 | id2;
 
-- 
1.7.3.2.245.g03276.dirty
