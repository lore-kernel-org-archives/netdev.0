From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/3] drivers/net/bfin_mac.c: Neatening
Date: Thu, 29 Jul 2010 16:58:22 -0700
Message-ID: <ce9ceb5b6cd6628ac5f3fba69f56356f0854c720.1280447281.git.joe@perches.com>
References: <cover.1280447281.git.joe@perches.com>
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Hennerich <michael.hennerich@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2168 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756919Ab0G2X61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 19:58:27 -0400
In-Reply-To: <cover.1280447281.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

80 column fixes
Spelling/typo corrections
Argument alignment

checkpatch clean

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bfin_mac.c |  204 ++++++++++++++++++++++++++----------------------
 1 files changed, 112 insertions(+), 92 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 012613f..0b032a5 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -132,14 +132,14 @@ static int desc_list_init(void)
 #endif
 
 	tx_desc = bfin_mac_alloc(&dma_handle,
-				sizeof(struct net_dma_desc_tx) *
-				CONFIG_BFIN_TX_DESC_NUM);
+				 sizeof(struct net_dma_desc_tx) *
+				 CONFIG_BFIN_TX_DESC_NUM);
 	if (tx_desc == NULL)
 		goto init_error;
 
 	rx_desc = bfin_mac_alloc(&dma_handle,
-				sizeof(struct net_dma_desc_rx) *
-				CONFIG_BFIN_RX_DESC_NUM);
+				 sizeof(struct net_dma_desc_rx) *
+				 CONFIG_BFIN_RX_DESC_NUM);
 	if (rx_desc == NULL)
 		goto init_error;
 
@@ -200,8 +200,9 @@ static int desc_list_init(void)
 			goto init_error;
 		}
 		skb_reserve(new_skb, NET_IP_ALIGN);
-		/* Invidate the data cache of skb->data range when it is write back
-		 * cache. It will prevent overwritting the new data from DMA
+		/* Invalidate the data cache of skb->data range when it is
+		 * write back cache.
+		 * It will prevent overwriting the new data from DMA
 		 */
 		blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
 					 (unsigned long)new_skb->end);
@@ -229,8 +230,8 @@ static int desc_list_init(void)
 		 * 6 half words is desc size
 		 * large desc flow
 		 */
-		b->config = DMAEN | WNR | WDSIZE_32 | DI_EN |
-				NDSIZE_6 | DMAFLOW_LARGE;
+		b->config = (DMAEN | WNR | WDSIZE_32 | DI_EN |
+			     NDSIZE_6 | DMAFLOW_LARGE);
 		b->start_addr = (unsigned long)(&(r->status));
 		b->x_count = 0;
 
@@ -284,15 +285,15 @@ static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 		return ret;
 
 	/* read mode */
-	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
-				SET_REGAD((u16) regnum) |
-				STABUSY);
+	bfin_write_EMAC_STAADD((SET_PHYAD((u16)phy_addr) |
+				SET_REGAD((u16)regnum) |
+				STABUSY));
 
 	ret = bfin_mdio_poll();
 	if (ret)
 		return ret;
 
-	return (int) bfin_read_EMAC_STADAT();
+	return (int)bfin_read_EMAC_STADAT();
 }
 
 /* Write an off-chip register in a PHY through the MDC/MDIO port */
@@ -308,10 +309,10 @@ static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 	bfin_write_EMAC_STADAT((u32) value);
 
 	/* write mode */
-	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
-				SET_REGAD((u16) regnum) |
+	bfin_write_EMAC_STAADD((SET_PHYAD((u16)phy_addr) |
+				SET_REGAD((u16)regnum) |
 				STAOP |
-				STABUSY);
+				STABUSY));
 
 	return bfin_mdio_poll();
 }
@@ -421,7 +422,7 @@ static int mii_probe(struct net_device *dev)
 		break; /* found it */
 	}
 
-	/* now we are supposed to have a proper phydev, to attach to... */
+	/* now we are supposed to have a proper phydev to attach to... */
 	if (!phydev) {
 		printk(KERN_INFO "%s: Don't found any phy device at all\n",
 			dev->name);
@@ -430,10 +431,10 @@ static int mii_probe(struct net_device *dev)
 
 #if defined(CONFIG_BFIN_MAC_RMII)
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, PHY_INTERFACE_MODE_RMII);
+			     0, PHY_INTERFACE_MODE_RMII);
 #else
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, PHY_INTERFACE_MODE_MII);
+			     0, PHY_INTERFACE_MODE_MII);
 #endif
 
 	if (IS_ERR(phydev)) {
@@ -442,14 +443,15 @@ static int mii_probe(struct net_device *dev)
 	}
 
 	/* mask with MAC supported features */
-	phydev->supported &= (SUPPORTED_10baseT_Half
-			      | SUPPORTED_10baseT_Full
-			      | SUPPORTED_100baseT_Half
-			      | SUPPORTED_100baseT_Full
-			      | SUPPORTED_Autoneg
-			      | SUPPORTED_Pause | SUPPORTED_Asym_Pause
-			      | SUPPORTED_MII
-			      | SUPPORTED_TP);
+	phydev->supported &= (SUPPORTED_10baseT_Half |
+			      SUPPORTED_10baseT_Full |
+			      SUPPORTED_100baseT_Half |
+			      SUPPORTED_100baseT_Full |
+			      SUPPORTED_Autoneg |
+			      SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause |
+			      SUPPORTED_MII |
+			      SUPPORTED_TP);
 
 	phydev->advertising = phydev->supported;
 
@@ -514,7 +516,7 @@ static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
 }
 
 static void bfin_mac_ethtool_getwol(struct net_device *dev,
-	struct ethtool_wolinfo *wolinfo)
+				    struct ethtool_wolinfo *wolinfo)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 
@@ -523,7 +525,7 @@ static void bfin_mac_ethtool_getwol(struct net_device *dev,
 }
 
 static int bfin_mac_ethtool_setwol(struct net_device *dev,
-	struct ethtool_wolinfo *wolinfo)
+				   struct ethtool_wolinfo *wolinfo)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int rc;
@@ -601,8 +603,8 @@ void setup_system_regs(struct net_device *dev)
 
 static void setup_mac_addr(u8 *mac_addr)
 {
-	u32 addr_low = le32_to_cpu(*(__le32 *) & mac_addr[0]);
-	u16 addr_hi = le16_to_cpu(*(__le16 *) & mac_addr[4]);
+	u32 addr_low = le32_to_cpu(*(__le32 *)&mac_addr[0]);
+	u16 addr_hi = le16_to_cpu(*(__le16 *)&mac_addr[4]);
 
 	/* this depends on a little-endian machine */
 	bfin_write_EMAC_ADDRLO(addr_low);
@@ -612,6 +614,7 @@ static void setup_mac_addr(u8 *mac_addr)
 static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
+
 	if (netif_running(dev))
 		return -EBUSY;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -623,7 +626,7 @@ static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 #define bfin_mac_hwtstamp_is_none(cfg) ((cfg) == HWTSTAMP_FILTER_NONE)
 
 static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
-		struct ifreq *ifr, int cmd)
+				   struct ifreq *ifr, int cmd)
 {
 	struct hwtstamp_config config;
 	struct bfin_mac_local *lp = netdev_priv(netdev);
@@ -634,14 +637,14 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		return -EFAULT;
 
 	pr_debug("%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
-			__func__, config.flags, config.tx_type, config.rx_filter);
+		 __func__, config.flags, config.tx_type, config.rx_filter);
 
 	/* reserved for future extensions */
 	if (config.flags)
 		return -EINVAL;
 
 	if ((config.tx_type != HWTSTAMP_TX_OFF) &&
-			(config.tx_type != HWTSTAMP_TX_ON))
+	    (config.tx_type != HWTSTAMP_TX_ON))
 		return -ERANGE;
 
 	ptpctl = bfin_read_EMAC_PTP_CTL();
@@ -658,7 +661,8 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		/*
-		 * Clear the five comparison mask bits (bits[12:8]) in EMAC_PTP_CTL)
+		 * Clear the five comparison mask bits
+		 * (bits[12:8] in EMAC_PTP_CTL)
 		 * to enable all the field matches.
 		 */
 		ptpctl &= ~0x1F00;
@@ -694,8 +698,8 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		ptpctl &= ~0x1F00;
 		bfin_write_EMAC_PTP_CTL(ptpctl);
 		/*
-		 * Keep the default values of the EMAC_PTP_FOFF register, except set
-		 * the PTPCOF field to 0x2A.
+		 * Keep the default values of the EMAC_PTP_FOFF register,
+		 * except set the PTPCOF field to 0x2A.
 		 */
 		ptpfoff = 0x2A24170C;
 		bfin_write_EMAC_PTP_FOFF(ptpfoff);
@@ -720,20 +724,20 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 		/*
-		 * Clear bits 8 and 12 of the EMAC_PTP_CTL register to enable only the
-		 * EFTM and PTPCM field comparison.
+		 * Clear bits 8 and 12 of the EMAC_PTP_CTL register to enable
+		 * only the EFTM and PTPCM field comparison.
 		 */
 		ptpctl &= ~0x1100;
 		bfin_write_EMAC_PTP_CTL(ptpctl);
 		/*
-		 * Keep the default values of all the fields of the EMAC_PTP_FOFF
-		 * register, except set the PTPCOF field to 0x0E.
+		 * Keep the default values of all the fields of the
+		 * EMAC_PTP_FOFF register, except set the PTPCOF field to 0x0E.
 		 */
 		ptpfoff = 0x0E24170C;
 		bfin_write_EMAC_PTP_FOFF(ptpfoff);
 		/*
-		 * Program bits [15:0] of the EMAC_PTP_FV1 register to 0x88F7, which
-		 * corresponds to PTP messages on the MAC layer.
+		 * Program bits [15:0] of the EMAC_PTP_FV1 register to 0x88F7,
+		 * which corresponds to PTP messages on the MAC layer.
 		 */
 		ptpfv1 = 0x110488F7;
 		bfin_write_EMAC_PTP_FV1(ptpfv1);
@@ -780,24 +784,29 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		SSYNC();
 
 		lp->compare.last_update = 0;
-		timecounter_init(&lp->clock,
-				&lp->cycles,
-				ktime_to_ns(ktime_get_real()));
+		timecounter_init(&lp->clock, &lp->cycles,
+				 ktime_to_ns(ktime_get_real()));
 		timecompare_update(&lp->compare, 0);
 	}
 
 	lp->stamp_cfg = config;
-	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
-		-EFAULT : 0;
+	if (copy_to_user(ifr->ifr_data, &config, sizeof(config)))
+		return -EFAULT;
+
+	return 0;
 }
 
-static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts, struct timecompare *cmp)
+static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts,
+			     struct timecompare *cmp)
 {
 	ktime_t sys = ktime_get_real();
 
 	pr_debug("%s %s hardware:%d,%d transform system:%d,%d system:%d,%d, cmp:%lld, %lld\n",
-			__func__, s, hw->tv.sec, hw->tv.nsec, ts->tv.sec, ts->tv.nsec, sys.tv.sec,
-			sys.tv.nsec, cmp->offset, cmp->skew);
+		 __func__, s,
+		 hw->tv.sec, hw->tv.nsec,
+		 ts->tv.sec, ts->tv.nsec,
+		 sys.tv.sec, sys.tv.nsec,
+		 cmp->offset, cmp->skew);
 }
 
 static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
@@ -814,12 +823,14 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 		shtx->in_progress = 1;
 
 		/*
-		 * The timestamping is done at the EMAC module's MII/RMII interface
-		 * when the module sees the Start of Frame of an event message packet. This
-		 * interface is the closest possible place to the physical Ethernet transmission
+		 * The timestamping is done at the EMAC module's MII/RMII
+		 * interface when the module sees the Start of Frame of an
+		 * event message packet. This interface is the closest
+		 * possible place to the physical Ethernet transmission
 		 * medium, providing the best timing accuracy.
 		 */
-		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) && (--timeout_cnt))
+		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) &&
+		       (--timeout_cnt))
 			udelay(1);
 		if (timeout_cnt == 0)
 			printk(KERN_ERR DRV_NAME
@@ -832,15 +843,15 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 			regval = bfin_read_EMAC_PTP_TXSNAPLO();
 			regval |= (u64)bfin_read_EMAC_PTP_TXSNAPHI() << 32;
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
-			ns = timecounter_cyc2time(&lp->clock,
-					regval);
+			ns = timecounter_cyc2time(&lp->clock, regval);
 			timecompare_update(&lp->compare, ns);
 			shhwtstamps.hwtstamp = ns_to_ktime(ns);
 			shhwtstamps.syststamp =
 				timecompare_transform(&lp->compare, ns);
 			skb_tstamp_tx(skb, &shhwtstamps);
 
-			bfin_dump_hwtamp("TX", &shhwtstamps.hwtstamp, &shhwtstamps.syststamp, &lp->compare);
+			bfin_dump_hwtamp("TX", &shhwtstamps.hwtstamp,
+					 &shhwtstamps.syststamp, &lp->compare);
 		}
 	}
 }
@@ -869,7 +880,8 @@ static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 	shhwtstamps->hwtstamp = ns_to_ktime(ns);
 	shhwtstamps->syststamp = timecompare_transform(&lp->compare, ns);
 
-	bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp, &shhwtstamps->syststamp, &lp->compare);
+	bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp,
+			 &shhwtstamps->syststamp, &lp->compare);
 }
 
 /*
@@ -879,8 +891,8 @@ static cycle_t bfin_read_clock(const struct cyclecounter *tc)
 {
 	u64 stamp;
 
-	stamp =  bfin_read_EMAC_PTP_TIMELO();
-	stamp |= (u64)bfin_read_EMAC_PTP_TIMEHI() << 32ULL;
+	stamp = bfin_read_EMAC_PTP_TIMELO();
+	stamp |= ((u64)bfin_read_EMAC_PTP_TIMEHI()) << 32;
 
 	return stamp;
 }
@@ -961,7 +973,7 @@ static void tx_reclaim_skb(struct bfin_mac_local *lp)
 	}
 
 	if (current_tx_ptr->next != tx_list_head &&
-		netif_queue_stopped(lp->ndev))
+	    netif_queue_stopped(lp->ndev))
 		netif_wake_queue(lp->ndev);
 
 	if (tx_list_head != current_tx_ptr) {
@@ -974,10 +986,8 @@ static void tx_reclaim_skb(struct bfin_mac_local *lp)
 				jiffies + TX_RECLAIM_JIFFIES;
 
 		mod_timer(&lp->tx_reclaim_timer,
-			lp->tx_reclaim_timer.expires);
+			  lp->tx_reclaim_timer.expires);
 	}
-
-	return;
 }
 
 static void tx_reclaim_skb_timeout(unsigned long lp)
@@ -985,8 +995,7 @@ static void tx_reclaim_skb_timeout(unsigned long lp)
 	tx_reclaim_skb((struct bfin_mac_local *)lp);
 }
 
-static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+static int bfin_mac_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	u16 *data;
@@ -1000,10 +1009,11 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		data = (u16 *)(skb->data) - 1;
 		*data = (u16)(skb->len);
 		/*
-		 * When transmitting an Ethernet packet, the PTP_TSYNC module requires
-		 * a DMA_Length_Word field associated with the packet. The lower 12 bits
-		 * of this field are the length of the packet payload in bytes and the higher
-		 * 4 bits are the timestamping enable field.
+		 * When transmitting an Ethernet packet, the PTP_TSYNC module
+		 * requires a DMA_Length_Word field associated with the packet.
+		 * The lower 12 bits of this field are the length of the packet
+		 * payload in bytes and the higher 4 bits are the timestamping
+		 * enable field.
 		 */
 		if (shtx->hardware)
 			*data |= 0x1000;
@@ -1011,7 +1021,7 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		current_tx_ptr->desc_a.start_addr = (u32)data;
 		/* this is important! */
 		blackfin_dcache_flush_range((u32)data,
-				(u32)((u8 *)data + skb->len + 4));
+					    (u32)((u8 *)data + skb->len + 4));
 	} else {
 		*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
 		/* enable timestamping for the sent packet */
@@ -1026,7 +1036,8 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 			(u32)(current_tx_ptr->packet + skb->len + 2));
 	}
 
-	/* make sure the internal data buffers in the core are drained
+	/*
+	 * Make sure the internal data buffers in the core are drained
 	 * so that the DMA descriptors are completely written when the
 	 * DMA engine goes to fetch them below
 	 */
@@ -1063,7 +1074,8 @@ out:
 
 #define IP_HEADER_OFF  0
 #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
-	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
+		       RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | \
+		       RX_LATE | RX_RANGE)
 
 static void bfin_mac_rx(struct net_device *dev)
 {
@@ -1097,8 +1109,9 @@ static void bfin_mac_rx(struct net_device *dev)
 	}
 	/* reserve 2 bytes for RXDWA padding */
 	skb_reserve(new_skb, NET_IP_ALIGN);
-	/* Invidate the data cache of skb->data range when it is write back
-	 * cache. It will prevent overwritting the new data from DMA
+	/*
+	 * Invalidate the data cache of skb->data range when it is write back
+	 * cache. It will prevent overwriting the new data from DMA
 	 */
 	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
 					 (unsigned long)new_skb->end);
@@ -1116,25 +1129,29 @@ static void bfin_mac_rx(struct net_device *dev)
 	bfin_rx_hwtstamp(dev, skb);
 
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
-	/* Checksum offloading only works for IPv4 packets with the standard IP header
-	 * length of 20 bytes, because the blackfin MAC checksum calculation is
-	 * based on that assumption. We must NOT use the calculated checksum if our
-	 * IP version or header break that assumption.
+	/*
+	 * Checksum offloading only works for IPv4 packets with the standard
+	 * IP header length of 20 bytes, because the blackfin MAC checksum
+	 * calculation is based on that assumption. We must NOT use the
+	 * calculated checksum if our IP version or header break that
+	 * assumption.
 	 */
 	if (skb->data[IP_HEADER_OFF] == 0x45) {
 		skb->csum = current_rx_ptr->status.ip_payload_csum;
 		/*
-		 * Deduce Ethernet FCS from hardware generated IP payload checksum.
-		 * IP checksum is based on 16-bit one's complement algorithm.
-		 * To deduce a value from checksum is equal to add its inversion.
-		 * If the IP payload len is odd, the inversed FCS should also
-		 * begin from odd address and leave first byte zero.
+		 * Deduce Ethernet FCS from hardware generated IP payload
+		 * checksum.  IP checksum is based on 16-bit one's complement
+		 * algorithm.  To deduce a value from checksum is equal to
+		 * add its inversion.  If the IP payload len is odd, the
+		 * inversed FCS should also begin from odd address and leave
+		 * first byte zero.
 		 */
 		if (skb->len % 2) {
 			fcs[0] = 0;
 			for (i = 0; i < ETH_FCS_LEN; i++)
 				fcs[i + 1] = ~skb->data[skb->len + i];
-			skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1, skb->csum);
+			skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1,
+						 skb->csum);
 		} else {
 			for (i = 0; i < ETH_FCS_LEN; i++)
 				fcs[i] = ~skb->data[skb->len + i];
@@ -1465,8 +1482,10 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	lp->ndev = ndev;
 
 	/* Grab the MAC address in the MAC */
-	*(__le32 *) (&(ndev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
-	*(__le16 *) (&(ndev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
+	*(__le32 *)(&(ndev->dev_addr[0])) =
+		cpu_to_le32(bfin_read_EMAC_ADDRLO());
+	*(__le16 *)(&(ndev->dev_addr[4])) =
+		cpu_to_le16((u16)bfin_read_EMAC_ADDRHI());
 
 	/* probe mac */
 	/*todo: how to proble? which is revision_register */
@@ -1526,8 +1545,8 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 
 	/* now, enable interrupts */
 	/* register irq handler */
-	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
-			IRQF_DISABLED, "EMAC_RX", ndev);
+	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt, IRQF_DISABLED,
+			 "EMAC_RX", ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
 		rc = -EBUSY;
@@ -1647,7 +1666,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	miibus->parent = &pdev->dev;
 	miibus->name = "bfin_mii_bus";
 	snprintf(miibus->id, MII_BUS_ID_SIZE, "0");
-	miibus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	miibus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (miibus->irq == NULL)
 		goto out_err_alloc;
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
@@ -1674,6 +1693,7 @@ out_err_alloc:
 static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
 {
 	struct mii_bus *miibus = platform_get_drvdata(pdev);
+
 	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
 	kfree(miibus->irq);
@@ -1698,13 +1718,14 @@ static struct platform_driver bfin_mac_driver = {
 	.suspend = bfin_mac_suspend,
 	.driver = {
 		.name = DRV_NAME,
-		.owner	= THIS_MODULE,
+		.owner = THIS_MODULE,
 	},
 };
 
 static int __init bfin_mac_init(void)
 {
 	int ret;
+
 	ret = platform_driver_register(&bfin_mii_bus_driver);
 	if (!ret)
 		return platform_driver_register(&bfin_mac_driver);
@@ -1720,4 +1741,3 @@ static void __exit bfin_mac_cleanup(void)
 }
 
 module_exit(bfin_mac_cleanup);
-
-- 
1.7.2.19.g9a302

