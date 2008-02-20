From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sungem: remove superfluous variable
Date: Wed, 20 Feb 2008 13:47:11 -0800
Message-ID: <1203544031.7181.222.camel@localhost>
References: <1203507467.17534.34.camel@johannes.berg>
	 <1203534567.7181.200.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1427 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1758576AbYBTVsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 16:48:16 -0500
In-Reply-To: <1203534567.7181.200.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sungem.c checkpatch error clean

gem_rx: reuse dma_addr temporary
gem_clean_rings: remove an indentation level
80 columns (not function definitions)
Remove spaces before tabs
__inline__ to inline
labels in column 1
printk cleanup
begnign/benign typo

Signed-off-by: Joe Perches

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 9721279..c7f9875 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -97,7 +97,7 @@
 #define DRV_AUTHOR	"David S. Miller (davem@redhat.com)"
 
 static char version[] __devinitdata =
-        DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE " " DRV_AUTHOR "\n";
+	DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE " " DRV_AUTHOR "\n";
 
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_DESCRIPTION("Sun GEM Gbit ethernet driver");
@@ -258,7 +258,7 @@ static int gem_pcs_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 
 	if (netif_msg_intr(gp))
 		printk(KERN_DEBUG "%s: pcs interrupt, pcs_istat: 0x%x\n",
-			gp->dev->name, pcs_istat);
+		       gp->dev->name, pcs_istat);
 
 	if (!(pcs_istat & PCS_ISTAT_LSC)) {
 		printk(KERN_ERR "%s: PCS irq but no link status change???\n",
@@ -284,17 +284,15 @@ static int gem_pcs_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 			printk(KERN_INFO "%s: PCS AutoNEG complete, "
 			       "RemoteFault\n", dev->name);
 		else
-			printk(KERN_INFO "%s: PCS AutoNEG complete.\n",
+			printk(KERN_INFO "%s: PCS AutoNEG complete\n",
 			       dev->name);
 	}
 
 	if (pcs_miistat & PCS_MIISTAT_LS) {
-		printk(KERN_INFO "%s: PCS link is now up.\n",
-		       dev->name);
+		printk(KERN_INFO "%s: PCS link is now up\n", dev->name);
 		netif_carrier_on(gp->dev);
 	} else {
-		printk(KERN_INFO "%s: PCS link is now down.\n",
-		       dev->name);
+		printk(KERN_INFO "%s: PCS link is now down\n", dev->name);
 		netif_carrier_off(gp->dev);
 		/* If this happens and the link timer is not running,
 		 * reset so we re-negotiate.
@@ -312,7 +310,7 @@ static int gem_txmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 
 	if (netif_msg_intr(gp))
 		printk(KERN_DEBUG "%s: txmac interrupt, txmac_stat: 0x%x\n",
-			gp->dev->name, txmac_stat);
+		       gp->dev->name, txmac_stat);
 
 	/* Defer timer expiration is quite normal,
 	 * don't even log the event.
@@ -322,13 +320,12 @@ static int gem_txmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 		return 0;
 
 	if (txmac_stat & MAC_TXSTAT_URUN) {
-		printk(KERN_ERR "%s: TX MAC xmit underrun.\n",
-		       dev->name);
+		printk(KERN_ERR "%s: TX MAC xmit underrun\n", dev->name);
 		gp->net_stats.tx_fifo_errors++;
 	}
 
 	if (txmac_stat & MAC_TXSTAT_MPE) {
-		printk(KERN_ERR "%s: TX MAC max packet size error.\n",
+		printk(KERN_ERR "%s: TX MAC max packet size error\n",
 		       dev->name);
 		gp->net_stats.tx_errors++;
 	}
@@ -376,8 +373,8 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX MAC will not reset, resetting whole "
-                       "chip.\n", dev->name);
+		printk(KERN_ERR "%s: RX MAC will not reset, "
+		       "resetting whole chip\n", dev->name);
 		return 1;
 	}
 
@@ -389,8 +386,8 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX MAC will not disable, resetting whole "
-		       "chip.\n", dev->name);
+		printk(KERN_ERR "%s: RX MAC will not disable, "
+		       "resetting whole chip\n", dev->name);
 		return 1;
 	}
 
@@ -402,8 +399,8 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX DMA will not disable, resetting whole "
-		       "chip.\n", dev->name);
+		printk(KERN_ERR "%s: RX DMA will not disable, "
+		       "resetting whole chip\n", dev->name);
 		return 1;
 	}
 
@@ -418,8 +415,8 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX reset command will not execute, resetting "
-		       "whole chip.\n", dev->name);
+		printk(KERN_ERR "%s: RX reset command will not execute, "
+		       "resetting whole chip\n", dev->name);
 		return 1;
 	}
 
@@ -428,8 +425,8 @@ static int gem_rxmac_reset(struct gem *gp)
 		struct gem_rxd *rxd = &gp->init_block->rxd[i];
 
 		if (gp->rx_skbs[i] == NULL) {
-			printk(KERN_ERR "%s: Parts of RX ring empty, resetting "
-			       "whole chip.\n", dev->name);
+			printk(KERN_ERR "%s: Parts of RX ring empty, "
+			       "resetting whole chip\n", dev->name);
 			return 1;
 		}
 
@@ -473,13 +470,13 @@ static int gem_rxmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 
 	if (netif_msg_intr(gp))
 		printk(KERN_DEBUG "%s: rxmac interrupt, rxmac_stat: 0x%x\n",
-			gp->dev->name, rxmac_stat);
+		       gp->dev->name, rxmac_stat);
 
 	if (rxmac_stat & MAC_RXSTAT_OFLW) {
 		u32 smac = readl(gp->regs + MAC_SMACHINE);
 
-		printk(KERN_ERR "%s: RX MAC fifo overflow smac[%08x].\n",
-				dev->name, smac);
+		printk(KERN_ERR "%s: RX MAC fifo overflow smac[%08x]\n",
+		       dev->name, smac);
 		gp->net_stats.rx_over_errors++;
 		gp->net_stats.rx_fifo_errors++;
 
@@ -507,7 +504,7 @@ static int gem_mac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 
 	if (netif_msg_intr(gp))
 		printk(KERN_DEBUG "%s: mac interrupt, mac_cstat: 0x%x\n",
-			gp->dev->name, mac_cstat);
+		       gp->dev->name, mac_cstat);
 
 	/* This interrupt is just for pause frame and pause
 	 * tracking.  It is useful for diagnostics and debug
@@ -541,16 +538,15 @@ static int gem_pci_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 
 	if (gp->pdev->vendor == PCI_VENDOR_ID_SUN &&
 	    gp->pdev->device == PCI_DEVICE_ID_SUN_GEM) {
-		printk(KERN_ERR "%s: PCI error [%04x] ",
-		       dev->name, pci_estat);
+		printk(KERN_ERR "%s: PCI error [%04x]", dev->name, pci_estat);
 
 		if (pci_estat & GREG_PCIESTAT_BADACK)
-			printk("<No ACK64# during ABS64 cycle> ");
+			printk(KERN_CONT " <No ACK64# during ABS64 cycle>");
 		if (pci_estat & GREG_PCIESTAT_DTRTO)
-			printk("<Delayed transaction timeout> ");
+			printk(KERN_CONT " <Delayed transaction timeout>");
 		if (pci_estat & GREG_PCIESTAT_OTHER)
-			printk("<other>");
-		printk("\n");
+			printk(KERN_CONT " <other>");
+		printk(KERN_CONT "\n");
 	} else {
 		pci_estat |= GREG_PCIESTAT_OTHER;
 		printk(KERN_ERR "%s: PCI error\n", dev->name);
@@ -567,22 +563,22 @@ static int gem_pci_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 		printk(KERN_ERR "%s: Read PCI cfg space status [%04x]\n",
 		       dev->name, pci_cfg_stat);
 		if (pci_cfg_stat & PCI_STATUS_PARITY)
-			printk(KERN_ERR "%s: PCI parity error detected.\n",
+			printk(KERN_ERR "%s: PCI parity error detected\n",
 			       dev->name);
 		if (pci_cfg_stat & PCI_STATUS_SIG_TARGET_ABORT)
-			printk(KERN_ERR "%s: PCI target abort.\n",
+			printk(KERN_ERR "%s: PCI target abort\n",
 			       dev->name);
 		if (pci_cfg_stat & PCI_STATUS_REC_TARGET_ABORT)
-			printk(KERN_ERR "%s: PCI master acks target abort.\n",
+			printk(KERN_ERR "%s: PCI master acks target abort\n",
 			       dev->name);
 		if (pci_cfg_stat & PCI_STATUS_REC_MASTER_ABORT)
-			printk(KERN_ERR "%s: PCI master abort.\n",
+			printk(KERN_ERR "%s: PCI master abort\n",
 			       dev->name);
 		if (pci_cfg_stat & PCI_STATUS_SIG_SYSTEM_ERROR)
-			printk(KERN_ERR "%s: PCI system error SERR#.\n",
+			printk(KERN_ERR "%s: PCI system error SERR#\n",
 			       dev->name);
 		if (pci_cfg_stat & PCI_STATUS_DETECTED_PARITY)
-			printk(KERN_ERR "%s: PCI parity error.\n",
+			printk(KERN_ERR "%s: PCI parity error\n",
 			       dev->name);
 
 		/* Write the error bits back to clear them. */
@@ -611,7 +607,7 @@ static int gem_abnormal_irq(struct net_device *dev, struct gem *gp, u32 gem_stat
 		/* Frame arrived, no free RX buffers available. */
 		if (netif_msg_rx_err(gp))
 			printk(KERN_DEBUG "%s: no buffer for rx frame\n",
-				gp->dev->name);
+			       gp->dev->name);
 		gp->net_stats.rx_dropped++;
 	}
 
@@ -619,7 +615,7 @@ static int gem_abnormal_irq(struct net_device *dev, struct gem *gp, u32 gem_stat
 		/* corrupt RX tag framing */
 		if (netif_msg_rx_err(gp))
 			printk(KERN_DEBUG "%s: corrupt rx tag framing\n",
-				gp->dev->name);
+			       gp->dev->name);
 		gp->net_stats.rx_errors++;
 
 		goto do_reset;
@@ -664,13 +660,13 @@ do_reset:
 	return 1;
 }
 
-static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_status)
+static inline void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_status)
 {
 	int entry, limit;
 
 	if (netif_msg_intr(gp))
 		printk(KERN_DEBUG "%s: tx interrupt, gem_status: 0x%x\n",
-			gp->dev->name, gem_status);
+		       gp->dev->name, gem_status);
 
 	entry = gp->tx_old;
 	limit = ((gem_status & GREG_STAT_TXNR) >> GREG_STAT_TXNR_SHIFT);
@@ -683,7 +679,7 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 
 		if (netif_msg_tx_done(gp))
 			printk(KERN_DEBUG "%s: tx done, slot %d\n",
-				gp->dev->name, entry);
+			       gp->dev->name, entry);
 		skb = gp->tx_skbs[entry];
 		if (skb_shinfo(skb)->nr_frags) {
 			int last = entry + skb_shinfo(skb)->nr_frags;
@@ -708,9 +704,11 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 			txd = &gp->init_block->txd[entry];
 
 			dma_addr = le64_to_cpu(txd->buffer);
-			dma_len = le64_to_cpu(txd->control_word) & TXDCTRL_BUFSZ;
+			dma_len = le64_to_cpu(txd->control_word) &
+				TXDCTRL_BUFSZ;
 
-			pci_unmap_page(gp->pdev, dma_addr, dma_len, PCI_DMA_TODEVICE);
+			pci_unmap_page(gp->pdev, dma_addr, dma_len,
+				       PCI_DMA_TODEVICE);
 			entry = NEXT_TX(entry);
 		}
 
@@ -724,7 +722,7 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 		netif_wake_queue(dev);
 }
 
-static __inline__ void gem_post_rxds(struct gem *gp, int limit)
+static inline void gem_post_rxds(struct gem *gp, int limit)
 {
 	int cluster_start, curr, count, kick;
 
@@ -738,7 +736,8 @@ static __inline__ void gem_post_rxds(struct gem *gp, int limit)
 			struct gem_rxd *rxd =
 				&gp->init_block->rxd[cluster_start];
 			for (;;) {
-				rxd->status_word = cpu_to_le64(RXDCTRL_FRESH(gp));
+				rxd->status_word =
+					cpu_to_le64(RXDCTRL_FRESH(gp));
 				rxd++;
 				cluster_start = NEXT_RX(cluster_start);
 				if (cluster_start == curr)
@@ -762,7 +761,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 
 	if (netif_msg_rx_status(gp))
 		printk(KERN_DEBUG "%s: rx interrupt, done: %d, rx_new: %d\n",
-			gp->dev->name, readl(gp->regs + RXDMA_DONE), gp->rx_new);
+		       gp->dev->name, readl(gp->regs + RXDMA_DONE), gp->rx_new);
 
 	entry = gp->rx_new;
 	drops = 0;
@@ -807,7 +806,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 				gp->net_stats.rx_crc_errors++;
 
 			/* We'll just return it to GEM. */
-		drop_it:
+drop_it:
 			gp->net_stats.rx_dropped++;
 			goto next;
 		}
@@ -815,8 +814,8 @@ static int gem_rx(struct gem *gp, int work_to_do)
 		dma_addr = le64_to_cpu(rxd->buffer);
 		if (len > RX_COPY_THRESHOLD) {
 			struct sk_buff *new_skb;
-
-			new_skb = gem_alloc_skb(RX_BUF_ALLOC_SIZE(gp), GFP_ATOMIC);
+			new_skb = gem_alloc_skb(RX_BUF_ALLOC_SIZE(gp),
+						GFP_ATOMIC);
 			if (new_skb == NULL) {
 				drops++;
 				goto drop_it;
@@ -827,11 +826,12 @@ static int gem_rx(struct gem *gp, int work_to_do)
 			gp->rx_skbs[entry] = new_skb;
 			new_skb->dev = gp->dev;
 			skb_put(new_skb, (gp->rx_buf_sz + RX_OFFSET));
-			rxd->buffer = cpu_to_le64(pci_map_page(gp->pdev,
-							       virt_to_page(new_skb->data),
-							       offset_in_page(new_skb->data),
-							       RX_BUF_ALLOC_SIZE(gp),
-							       PCI_DMA_FROMDEVICE));
+			dma_addr = pci_map_page(gp->pdev,
+						virt_to_page(new_skb->data),
+						offset_in_page(new_skb->data),
+						RX_BUF_ALLOC_SIZE(gp),
+						PCI_DMA_FROMDEVICE);
+			rxd->buffer = cpu_to_le64(dma_addr);
 			skb_reserve(new_skb, RX_OFFSET);
 
 			/* Trim the original skb for the netif. */
@@ -846,15 +846,18 @@ static int gem_rx(struct gem *gp, int work_to_do)
 
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
-			pci_dma_sync_single_for_cpu(gp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_cpu(gp->pdev, dma_addr, len,
+						    PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
-			pci_dma_sync_single_for_device(gp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_device(gp->pdev, dma_addr, len,
+						       PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
 			skb = copy_skb;
 		}
 
-		csum = (__force __sum16)htons((status & RXDCTRL_TCPCSUM) ^ 0xffff);
+		csum = (__force __sum16)
+			htons((status & RXDCTRL_TCPCSUM) ^ 0xffff);
 		skb->csum = csum_unfold(csum);
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->protocol = eth_type_trans(skb, gp->dev);
@@ -865,7 +868,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 		gp->net_stats.rx_bytes += len;
 		gp->dev->last_rx = jiffies;
 
-	next:
+next:
 		entry = NEXT_RX(entry);
 	}
 
@@ -874,7 +877,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 	gp->rx_new = entry;
 
 	if (drops)
-		printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
+		printk(KERN_INFO "%s: Memory squeeze, deferring packet\n",
 		       gp->dev->name);
 
 	return work_done;
@@ -983,7 +986,7 @@ static void gem_tx_timeout(struct net_device *dev)
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 	if (!gp->running) {
-		printk("%s: hrm.. hw not running !\n", dev->name);
+		printk(KERN_ERR "%s: hrm.. hw not running !\n", dev->name);
 		return;
 	}
 	printk(KERN_ERR "%s: TX_STATE[%08x:%08x:%08x]\n",
@@ -1007,7 +1010,7 @@ static void gem_tx_timeout(struct net_device *dev)
 	spin_unlock_irq(&gp->lock);
 }
 
-static __inline__ int gem_intme(int entry)
+static inline int gem_intme(int entry)
 {
 	/* Algorithm: IRQ every 1/2 of descriptors. */
 	if (!(entry & ((TX_RING_SIZE>>1)-1)))
@@ -1167,7 +1170,7 @@ static void gem_reset(struct gem *gp)
 	} while (val & (GREG_SWRST_TXRST | GREG_SWRST_RXRST));
 
 	if (limit <= 0)
-		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
+		printk(KERN_ERR "%s: SW reset is ghetto\n", gp->dev->name);
 }
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
@@ -1217,7 +1220,7 @@ static void gem_stop_dma(struct gem *gp)
 
 
 /* Must be invoked under gp->lock and gp->tx_lock. */
-// XXX dbl check what that function should do when called on PCS PHY
+/* XXX dbl check what that function should do when called on PCS PHY */
 static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 {
 	u32 advertise, features;
@@ -1226,8 +1229,8 @@ static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 	int duplex;
 
 	if (gp->phy_type != phy_mii_mdio0 &&
-     	    gp->phy_type != phy_mii_mdio1)
-     	    	goto non_mii;
+	    gp->phy_type != phy_mii_mdio1)
+		goto non_mii;
 
 	/* Setup advertise */
 	if (found_mii_phy(gp))
@@ -1267,9 +1270,9 @@ start_aneg:
 		speed = SPEED_10;
 	if (duplex == DUPLEX_FULL &&
 	    !(features & (SUPPORTED_1000baseT_Full |
-	    		  SUPPORTED_100baseT_Full |
-	    		  SUPPORTED_10baseT_Full)))
-	    	duplex = DUPLEX_HALF;
+			  SUPPORTED_100baseT_Full |
+			  SUPPORTED_10baseT_Full)))
+		duplex = DUPLEX_HALF;
 	if (speed == 0)
 		speed = SPEED_10;
 
@@ -1287,11 +1290,13 @@ start_aneg:
 	gp->want_autoneg = autoneg;
 	if (autoneg) {
 		if (found_mii_phy(gp))
-			gp->phy_mii.def->ops->setup_aneg(&gp->phy_mii, advertise);
+			gp->phy_mii.def->ops->setup_aneg(&gp->phy_mii,
+							 advertise);
 		gp->lstate = link_aneg;
 	} else {
 		if (found_mii_phy(gp))
-			gp->phy_mii.def->ops->setup_forced(&gp->phy_mii, speed, duplex);
+			gp->phy_mii.def->ops->setup_forced(&gp->phy_mii, speed,
+							   duplex);
 		gp->lstate = link_force_ok;
 	}
 
@@ -1315,13 +1320,13 @@ static int gem_set_link_modes(struct gem *gp)
 	pause = 0;
 
 	if (found_mii_phy(gp)) {
-	    	if (gp->phy_mii.def->ops->read_link(&gp->phy_mii))
-	    		return 1;
+		if (gp->phy_mii.def->ops->read_link(&gp->phy_mii))
+			return 1;
 		full_duplex = (gp->phy_mii.duplex == DUPLEX_FULL);
 		speed = gp->phy_mii.speed;
 		pause = gp->phy_mii.pause;
 	} else if (gp->phy_type == phy_serialink ||
-	    	   gp->phy_type == phy_serdes) {
+		   gp->phy_type == phy_serdes) {
 		u32 pcs_lpa = readl(gp->regs + PCS_MIILP);
 
 		if (pcs_lpa & PCS_MIIADV_FD)
@@ -1330,8 +1335,8 @@ static int gem_set_link_modes(struct gem *gp)
 	}
 
 	if (netif_msg_link(gp))
-		printk(KERN_INFO "%s: Link is up at %d Mbps, %s-duplex.\n",
-			gp->dev->name, speed, (full_duplex ? "full" : "half"));
+		printk(KERN_INFO "%s: Link is up at %d Mbps, %s-duplex\n",
+		       gp->dev->name, speed, (full_duplex ? "full" : "half"));
 
 	if (!gp->running)
 		return 0;
@@ -1358,8 +1363,8 @@ static int gem_set_link_modes(struct gem *gp)
 
 	writel(val, gp->regs + MAC_XIFCFG);
 
-	/* If gigabit and half-duplex, enable carrier extension
-	 * mode.  Else, disable it.
+	/* If gigabit and half-duplex, enable carrier extension mode.
+	 * Else, disable it.
 	 */
 	if (speed == SPEED_1000 && !full_duplex) {
 		val = readl(gp->regs + MAC_TXCFG);
@@ -1377,7 +1382,7 @@ static int gem_set_link_modes(struct gem *gp)
 
 	if (gp->phy_type == phy_serialink ||
 	    gp->phy_type == phy_serdes) {
- 		u32 pcs_lpa = readl(gp->regs + PCS_MIILP);
+		u32 pcs_lpa = readl(gp->regs + PCS_MIILP);
 
 		if (pcs_lpa & (PCS_MIIADV_SP | PCS_MIIADV_AP))
 			pause = 1;
@@ -1419,26 +1424,28 @@ static int gem_mdio_link_not_up(struct gem *gp)
 	switch (gp->lstate) {
 	case link_force_ret:
 		if (netif_msg_link(gp))
-			printk(KERN_INFO "%s: Autoneg failed again, keeping"
-				" forced mode\n", gp->dev->name);
+			printk(KERN_INFO "%s: Autoneg failed again, "
+			       "keeping forced mode\n", gp->dev->name);
 		gp->phy_mii.def->ops->setup_forced(&gp->phy_mii,
-			gp->last_forced_speed, DUPLEX_HALF);
+						   gp->last_forced_speed,
+						   DUPLEX_HALF);
 		gp->timer_ticks = 5;
 		gp->lstate = link_force_ok;
 		return 0;
 	case link_aneg:
-		/* We try forced modes after a failed aneg only on PHYs that don't
-		 * have "magic_aneg" bit set, which means they internally do the
-		 * while forced-mode thingy. On these, we just restart aneg
+		/* We try forced modes after a failed aneg only on PHYs
+		 * that don't have "magic_aneg" bit set, which means they
+		 * internally do the while forced-mode thingy.
+		 * On these, we just restart aneg
 		 */
 		if (gp->phy_mii.def->magic_aneg)
 			return 1;
 		if (netif_msg_link(gp))
 			printk(KERN_INFO "%s: switching to forced 100bt\n",
-				gp->dev->name);
+			       gp->dev->name);
 		/* Try forced modes. */
 		gp->phy_mii.def->ops->setup_forced(&gp->phy_mii, SPEED_100,
-			DUPLEX_HALF);
+						   DUPLEX_HALF);
 		gp->timer_ticks = 5;
 		gp->lstate = link_force_try;
 		return 0;
@@ -1448,12 +1455,14 @@ static int gem_mdio_link_not_up(struct gem *gp)
 		 * situation every 10 ticks.
 		 */
 		if (gp->phy_mii.speed == SPEED_100) {
-			gp->phy_mii.def->ops->setup_forced(&gp->phy_mii, SPEED_10,
-				DUPLEX_HALF);
+			gp->phy_mii.def->ops->setup_forced(&gp->phy_mii,
+							   SPEED_10,
+							   DUPLEX_HALF);
 			gp->timer_ticks = 5;
 			if (netif_msg_link(gp))
-				printk(KERN_INFO "%s: switching to forced 10bt\n",
-					gp->dev->name);
+				printk(KERN_INFO "%s: switching to "
+				       "forced 10bt\n",
+				       gp->dev->name);
 			return 0;
 		} else
 			return 1;
@@ -1494,7 +1503,8 @@ static void gem_link_timer(unsigned long data)
 		}
 		goto restart;
 	}
-	if (found_mii_phy(gp) && gp->phy_mii.def->ops->poll_link(&gp->phy_mii)) {
+	if (found_mii_phy(gp) &&
+	    gp->phy_mii.def->ops->poll_link(&gp->phy_mii)) {
 		/* Ok, here we got a link. If we had it due to a forced
 		 * fallback, and we were configured for autoneg, we do
 		 * retry a short autoneg pass. If you know your hub is
@@ -1505,9 +1515,12 @@ static void gem_link_timer(unsigned long data)
 			gp->last_forced_speed = gp->phy_mii.speed;
 			gp->timer_ticks = 5;
 			if (netif_msg_link(gp))
-				printk(KERN_INFO "%s: Got link after fallback, retrying"
-					" autoneg once...\n", gp->dev->name);
-			gp->phy_mii.def->ops->setup_aneg(&gp->phy_mii, gp->phy_mii.advertising);
+				printk(KERN_INFO "%s: Got link after fallback, "
+				       "retrying autoneg once..\n",
+				       gp->dev->name);
+			gp->phy_mii.def->
+				ops->setup_aneg(&gp->phy_mii,
+						gp->phy_mii.advertising);
 		} else if (gp->lstate != link_up) {
 			gp->lstate = link_up;
 			netif_carrier_on(gp->dev);
@@ -1522,7 +1535,7 @@ static void gem_link_timer(unsigned long data)
 			gp->lstate = link_down;
 			if (netif_msg_link(gp))
 				printk(KERN_INFO "%s: Link down\n",
-					gp->dev->name);
+				       gp->dev->name);
 			netif_carrier_off(gp->dev);
 			gp->reset_task_pending = 1;
 			schedule_work(&gp->reset_task);
@@ -1573,27 +1586,27 @@ static void gem_clean_rings(struct gem *gp)
 	}
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		if (gp->tx_skbs[i] != NULL) {
-			struct gem_txd *txd;
-			int frag;
+		int frag;
 
-			skb = gp->tx_skbs[i];
-			gp->tx_skbs[i] = NULL;
+		if (!gp->tx_skbs[i])
+			continue;
 
-			for (frag = 0; frag <= skb_shinfo(skb)->nr_frags; frag++) {
-				int ent = i & (TX_RING_SIZE - 1);
+		skb = gp->tx_skbs[i];
+		gp->tx_skbs[i] = NULL;
 
-				txd = &gb->txd[ent];
-				dma_addr = le64_to_cpu(txd->buffer);
-				pci_unmap_page(gp->pdev, dma_addr,
-					       le64_to_cpu(txd->control_word) &
-					       TXDCTRL_BUFSZ, PCI_DMA_TODEVICE);
+		for (frag = 0; frag <= skb_shinfo(skb)->nr_frags; frag++) {
+			int ent = i & (TX_RING_SIZE - 1);
+			struct gem_txd *txd = &gb->txd[ent];
 
-				if (frag != skb_shinfo(skb)->nr_frags)
-					i++;
-			}
-			dev_kfree_skb_any(skb);
+			dma_addr = le64_to_cpu(txd->buffer);
+			pci_unmap_page(gp->pdev, dma_addr,
+				       le64_to_cpu(txd->control_word) &
+				       TXDCTRL_BUFSZ, PCI_DMA_TODEVICE);
+
+			if (frag != skb_shinfo(skb)->nr_frags)
+				i++;
 		}
+		dev_kfree_skb_any(skb);
 	}
 }
 
@@ -1666,19 +1679,20 @@ static void gem_init_phy(struct gem *gp)
 		 */
 		for (i = 0; i < 3; i++) {
 #ifdef CONFIG_PPC_PMAC
-			pmac_call_feature(PMAC_FTR_GMAC_PHY_RESET, gp->of_node, 0, 0);
+			pmac_call_feature(PMAC_FTR_GMAC_PHY_RESET,
+					  gp->of_node, 0, 0);
 			msleep(20);
 #endif
-			/* Some PHYs used by apple have problem getting back to us,
-			 * we do an additional reset here
+			/* Some PHYs used by apple have a problem
+			 * getting back to us, we do an additional reset here
 			 */
 			phy_write(gp, MII_BMCR, BMCR_RESET);
 			msleep(20);
 			if (phy_read(gp, MII_BMCR) != 0xffff)
 				break;
 			if (i == 2)
-				printk(KERN_WARNING "%s: GMAC PHY not responding !\n",
-				       gp->dev->name);
+				printk(KERN_WARNING "%s: GMAC PHY "
+				       "not responding !\n", gp->dev->name);
 		}
 	}
 
@@ -1701,7 +1715,7 @@ static void gem_init_phy(struct gem *gp)
 
 	if (gp->phy_type == phy_mii_mdio0 ||
 	    gp->phy_type == phy_mii_mdio1) {
-	    	// XXX check for errors
+		/* XXX check for errors */
 		mii_phy_probe(&gp->phy_mii, gp->mii_phy_addr);
 
 		/* Init PHY */
@@ -1723,8 +1737,8 @@ static void gem_init_phy(struct gem *gp)
 				break;
 		}
 		if (limit <= 0)
-			printk(KERN_WARNING "%s: PCS reset bit would not clear.\n",
-			       gp->dev->name);
+			printk(KERN_WARNING "%s: PCS reset bit "
+			       "would not clear\n", gp->dev->name);
 
 		/* Make sure PCS is disabled while changing advertisement
 		 * configuration.
@@ -1733,16 +1747,15 @@ static void gem_init_phy(struct gem *gp)
 		val &= ~(PCS_CFG_ENABLE | PCS_CFG_TO);
 		writel(val, gp->regs + PCS_CFG);
 
-		/* Advertise all capabilities except assymetric
-		 * pause.
+		/* Advertise all capabilities except assymetric pause.
 		 */
 		val = readl(gp->regs + PCS_MIIADV);
 		val |= (PCS_MIIADV_FD | PCS_MIIADV_HD |
 			PCS_MIIADV_SP | PCS_MIIADV_AP);
 		writel(val, gp->regs + PCS_MIIADV);
 
-		/* Enable and restart auto-negotiation, disable wrapback/loopback,
-		 * and re-enable PCS.
+		/* Enable and restart auto-negotiation,
+		 * disable wrapback/loopback, and re-enable PCS.
 		 */
 		val = readl(gp->regs + PCS_MIICTRL);
 		val |= (PCS_MIICTRL_RAN | PCS_MIICTRL_ANE);
@@ -1817,24 +1830,22 @@ static void gem_init_dma(struct gem *gp)
 /* Must be invoked under gp->lock and gp->tx_lock. */
 static u32 gem_setup_multicast(struct gem *gp)
 {
-	u32 rxcfg = 0;
+	u32 rxcfg;
 	int i;
 
 	if ((gp->dev->flags & IFF_ALLMULTI) ||
 	    (gp->dev->mc_count > 256)) {
-	    	for (i=0; i<16; i++)
+		for (i = 0; i < 16; i++)
 			writel(0xffff, gp->regs + MAC_HASH0 + (i << 2));
-		rxcfg |= MAC_RXCFG_HFE;
+		rxcfg = MAC_RXCFG_HFE;
 	} else if (gp->dev->flags & IFF_PROMISC) {
-		rxcfg |= MAC_RXCFG_PROM;
+		rxcfg = MAC_RXCFG_PROM;
 	} else {
 		u16 hash_table[16];
 		u32 crc;
 		struct dev_mc_list *dmi = gp->dev->mc_list;
-		int i;
 
-		for (i = 0; i < 16; i++)
-			hash_table[i] = 0;
+		memset(hash_table, 0, sizeof(hash_table));
 
 		for (i = 0; i < gp->dev->mc_count; i++) {
 			char *addrs = dmi->dmi_addr;
@@ -1844,13 +1855,13 @@ static u32 gem_setup_multicast(struct gem *gp)
 			if (!(*addrs & 1))
 				continue;
 
- 			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, addrs);
 			crc >>= 24;
 			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
 		}
-	    	for (i=0; i<16; i++)
+		for (i = 0; i < ARRAY_SIZE(hash_table); i++)
 			writel(hash_table[i], gp->regs + MAC_HASH0 + (i << 2));
-		rxcfg |= MAC_RXCFG_HFE;
+		rxcfg = MAC_RXCFG_HFE;
 	}
 
 	return rxcfg;
@@ -1942,7 +1953,7 @@ static void gem_init_mac(struct gem *gp)
 /* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_pause_thresholds(struct gem *gp)
 {
-       	u32 cfg;
+	u32 cfg;
 
 	/* Calculate pause thresholds.  Setting the OFF threshold to the
 	 * full RX fifo size effectively disables PAUSE generation which
@@ -1964,15 +1975,15 @@ static void gem_init_pause_thresholds(struct gem *gp)
 	/* Configure the chip "burst" DMA mode & enable some
 	 * HW bug fixes on Apple version
 	 */
-       	cfg  = 0;
-       	if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
+	cfg  = 0;
+	if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
 		cfg |= GREG_CFG_RONPAULBIT | GREG_CFG_ENBUG2FIX;
 #if !defined(CONFIG_SPARC64) && !defined(CONFIG_ALPHA)
-       	cfg |= GREG_CFG_IBURST;
+	cfg |= GREG_CFG_IBURST;
 #endif
-       	cfg |= ((31 << 1) & GREG_CFG_TXDMALIM);
-       	cfg |= ((31 << 6) & GREG_CFG_RXDMALIM);
-       	writel(cfg, gp->regs + GREG_CFG);
+	cfg |= ((31 << 1) & GREG_CFG_TXDMALIM);
+	cfg |= ((31 << 6) & GREG_CFG_RXDMALIM);
+	writel(cfg, gp->regs + GREG_CFG);
 
 	/* If Infinite Burst didn't stick, then use different
 	 * thresholds (and Apple bug fixes don't exist)
@@ -2000,15 +2011,16 @@ static int gem_check_invariants(struct gem *gp)
 		gp->swrst_base = 0;
 
 		mif_cfg = readl(gp->regs + MIF_CFG);
-		mif_cfg &= ~(MIF_CFG_PSELECT|MIF_CFG_POLL|MIF_CFG_BBMODE|MIF_CFG_MDI1);
+		mif_cfg &= ~(MIF_CFG_PSELECT | MIF_CFG_POLL |
+			     MIF_CFG_BBMODE | MIF_CFG_MDI1);
 		mif_cfg |= MIF_CFG_MDI0;
 		writel(mif_cfg, gp->regs + MIF_CFG);
 		writel(PCS_DMODE_MGM, gp->regs + PCS_DMODE);
 		writel(MAC_XIFCFG_OE, gp->regs + MAC_XIFCFG);
 
-		/* We hard-code the PHY address so we can properly bring it out of
-		 * reset later on, we can't really probe it at this point, though
-		 * that isn't an issue.
+		/* We hard-code the PHY address so we can properly bring it
+		 * out of reset later on, we can't really probe it at this
+		 * point, though that isn't an issue.
 		 */
 		if (gp->pdev->device == PCI_DEVICE_ID_APPLE_K2_GMAC)
 			gp->mii_phy_addr = 1;
@@ -2026,8 +2038,8 @@ static int gem_check_invariants(struct gem *gp)
 		 * as this chip has no gigabit PHY.
 		 */
 		if ((mif_cfg & (MIF_CFG_MDI0 | MIF_CFG_MDI1)) == 0) {
-			printk(KERN_ERR PFX "RIO GEM lacks MII phy, mif_cfg[%08x]\n",
-			       mif_cfg);
+			printk(KERN_ERR PFX "RIO GEM lacks MII phy, "
+			       "mif_cfg[%08x]\n", mif_cfg);
 			return -1;
 		}
 	}
@@ -2058,7 +2070,8 @@ static int gem_check_invariants(struct gem *gp)
 		}
 		if (i == 32) {
 			if (pdev->device != PCI_DEVICE_ID_SUN_GEM) {
-				printk(KERN_ERR PFX "RIO MII phy will not respond.\n");
+				printk(KERN_ERR PFX "RIO MII phy "
+				       "will not respond\n");
 				return -1;
 			}
 			gp->phy_type = phy_serdes;
@@ -2073,7 +2086,8 @@ static int gem_check_invariants(struct gem *gp)
 		if (pdev->device == PCI_DEVICE_ID_SUN_GEM) {
 			if (gp->tx_fifo_sz != (9 * 1024) ||
 			    gp->rx_fifo_sz != (20 * 1024)) {
-				printk(KERN_ERR PFX "GEM has bogus fifo sizes tx(%d) rx(%d)\n",
+				printk(KERN_ERR PFX "GEM has bogus "
+				       "fifo sizes tx(%d) rx(%d)\n",
 				       gp->tx_fifo_sz, gp->rx_fifo_sz);
 				return -1;
 			}
@@ -2081,7 +2095,8 @@ static int gem_check_invariants(struct gem *gp)
 		} else {
 			if (gp->tx_fifo_sz != (2 * 1024) ||
 			    gp->rx_fifo_sz != (2 * 1024)) {
-				printk(KERN_ERR PFX "RIO GEM has bogus fifo sizes tx(%d) rx(%d)\n",
+				printk(KERN_ERR PFX "RIO GEM has bogus "
+				       "fifo sizes tx(%d) rx(%d)\n",
 				       gp->tx_fifo_sz, gp->rx_fifo_sz);
 				return -1;
 			}
@@ -2176,15 +2191,16 @@ static void gem_stop_phy(struct gem *gp, int wol)
 		if (found_mii_phy(gp) && gp->phy_mii.def->ops->suspend)
 			gp->phy_mii.def->ops->suspend(&gp->phy_mii);
 
-		/* According to Apple, we must set the MDIO pins to this begnign
+		/* According to Apple, we must set the MDIO pins to this benign
 		 * state or we may 1) eat more current, 2) damage some PHYs
 		 */
 		writel(mifcfg | MIF_CFG_BBMODE, gp->regs + MIF_CFG);
 		writel(0, gp->regs + MIF_BBCLK);
 		writel(0, gp->regs + MIF_BBDATA);
 		writel(0, gp->regs + MIF_BBOENAB);
-		writel(MAC_XIFCFG_GMII | MAC_XIFCFG_LBCK, gp->regs + MAC_XIFCFG);
-		(void) readl(gp->regs + MAC_XIFCFG);
+		writel(MAC_XIFCFG_GMII | MAC_XIFCFG_LBCK,
+		       gp->regs + MAC_XIFCFG);
+		(void)readl(gp->regs + MAC_XIFCFG);
 	}
 }
 
@@ -2216,7 +2232,7 @@ static int gem_do_start(struct net_device *dev)
 	spin_unlock_irqrestore(&gp->lock, flags);
 
 	if (request_irq(gp->pdev->irq, gem_interrupt,
-				   IRQF_SHARED, dev->name, (void *)dev)) {
+			IRQF_SHARED, dev->name, (void *)dev)) {
 		printk(KERN_ERR "%s: failed to request irq !\n", gp->dev->name);
 
 		spin_lock_irqsave(&gp->lock, flags);
@@ -2430,8 +2446,7 @@ static int gem_resume(struct pci_dev *pdev)
 
 	/* Make sure PCI access and bus master are enabled */
 	if (pci_enable_device(gp->pdev)) {
-		printk(KERN_ERR "%s: Can't re-enable chip !\n",
-		       dev->name);
+		printk(KERN_ERR "%s: Can't re-enable chip !\n", dev->name);
 		/* Put cell and forget it for now, it will be considered as
 		 * still asleep, a new sleep cycle may bring it back
 		 */
@@ -2587,7 +2602,7 @@ static void gem_set_multicast(struct net_device *dev)
 
 	netif_wake_queue(dev);
 
- bail:
+bail:
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irq(&gp->lock);
 }
@@ -2671,7 +2686,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		if (cmd->advertising == 0)
 			cmd->advertising = cmd->supported;
 		spin_unlock_irq(&gp->lock);
-	} else { // XXX PCS ?
+	} else { /* XXX PCS ? */
 		cmd->supported =
 			(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
@@ -2825,8 +2840,8 @@ static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		else if (!gp->running)
 			rc = -EAGAIN;
 		else {
-			__phy_write(gp, data->phy_id & 0x1f, data->reg_num & 0x1f,
-				    data->val_in);
+			__phy_write(gp, data->phy_id & 0x1f,
+				    data->reg_num & 0x1f, data->val_in);
 			rc = 0;
 		}
 		break;
@@ -2875,7 +2890,7 @@ static void get_gem_mac_nonobp(struct pci_dev *pdev, unsigned char *dev_addr)
 	void __iomem *p = pci_map_rom(pdev, &size);
 
 	if (p) {
-			int found;
+		int found;
 
 		found = readb(p) == 0x55 &&
 			readb(p + 1) == 0xaa &&
@@ -2961,7 +2976,7 @@ static void gem_remove_one(struct pci_dev *pdev)
 static int __devinit gem_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
-	static int gem_version_printed = 0;
+	static int gem_version_printed;
 	unsigned long gemreg_base, gemreg_len;
 	struct net_device *dev;
 	struct gem *gp;
@@ -2979,8 +2994,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	 */
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable MMIO operation, "
-		       "aborting.\n");
+		printk(KERN_ERR PFX "Cannot enable MMIO operation, aborting\n");
 		return err;
 	}
 	pci_set_master(pdev);
@@ -3002,7 +3016,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
-			       "aborting.\n");
+			       "aborting\n");
 			goto err_disable_device;
 		}
 		pci_using_dac = 0;
@@ -3013,14 +3027,14 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	if ((pci_resource_flags(pdev, 0) & IORESOURCE_IO) != 0) {
 		printk(KERN_ERR PFX "Cannot find proper PCI device "
-		       "base address, aborting.\n");
+		       "base address, aborting\n");
 		err = -ENODEV;
 		goto err_disable_device;
 	}
 
 	dev = alloc_etherdev(sizeof(*gp));
 	if (!dev) {
-		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
+		printk(KERN_ERR PFX "Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_disable_device;
 	}
@@ -3030,8 +3044,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
-		       "aborting.\n");
+		printk(KERN_ERR PFX "Cannot obtain PCI resources, aborting\n");
 		goto err_out_free_netdev;
 	}
 
@@ -3057,8 +3070,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	gp->regs = ioremap(gemreg_base, gemreg_len);
 	if (!gp->regs) {
-		printk(KERN_ERR PFX "Cannot map device registers, "
-		       "aborting.\n");
+		printk(KERN_ERR PFX "Cannot map device registers, aborting\n");
 		err = -EIO;
 		goto err_out_free_res;
 	}
@@ -3103,8 +3115,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		pci_alloc_consistent(pdev, sizeof(struct gem_init_block),
 				     &gp->gblock_dvma);
 	if (!gp->init_block) {
-		printk(KERN_ERR PFX "Cannot allocate init block, "
-		       "aborting.\n");
+		printk(KERN_ERR PFX "Cannot allocate init block, aborting\n");
 		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
@@ -3144,20 +3155,18 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	/* Register with kernel */
 	if (register_netdev(dev)) {
-		printk(KERN_ERR PFX "Cannot register net device, "
-		       "aborting.\n");
+		printk(KERN_ERR PFX "Cannot register net device, aborting\n");
 		err = -ENOMEM;
 		goto err_out_free_consistent;
 	}
 
-	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet "
-	       "%s\n",
+	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet %s\n",
 	       dev->name, print_mac(mac, dev->dev_addr));
 
 	if (gp->phy_type == phy_mii_mdio0 ||
-     	    gp->phy_type == phy_mii_mdio1)
+	    gp->phy_type == phy_mii_mdio1)
 		printk(KERN_INFO "%s: Found %s PHY\n", dev->name,
-			gp->phy_mii.def ? gp->phy_mii.def->name : "no");
+		       gp->phy_mii.def ? gp->phy_mii.def->name : "no");
 
 	/* GEM can do it all... */
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;


