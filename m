From: ganesh.venkatesan@intel.com
Subject: [PATCH 12/12 2.4] e1000 - white space and other cleanup
Date: Thu, 29 Jul 2004 08:33:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290751360.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000.h linux-2.4/drivers/net/e1000.new/e1000.h
--- linux-2.4/drivers/net/e1000/e1000.h	2004-07-28 08:47:08.172582760 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000.h	2004-07-28 08:47:09.439390176 -0700
@@ -103,11 +103,12 @@ struct e1000_adapter;
 
 #define E1000_MAX_INTR 10
 
-/* How many descriptors for TX and RX ? */
+/* TX/RX descriptor defines */
 #define E1000_DEFAULT_TXD                  256
 #define E1000_MAX_TXD                      256
 #define E1000_MIN_TXD                       80
 #define E1000_MAX_82544_TXD               4096
+
 #define E1000_DEFAULT_RXD                  256
 #define E1000_MAX_RXD                      256
 #define E1000_MIN_RXD                       80
@@ -128,14 +129,11 @@ struct e1000_adapter;
 #define E1000_TX_HEAD_ADDR_SHIFT 7
 #define E1000_PBA_TX_MASK 0xFFFF0000
 
-/* Flow Control High-Watermark: 5688 bytes below Rx FIFO size */
-#define E1000_FC_HIGH_DIFF 0x1638
-
-/* Flow Control Low-Watermark: 5696 bytes below Rx FIFO size */
-#define E1000_FC_LOW_DIFF 0x1640
+/* Flow Control Watermarks */
+#define E1000_FC_HIGH_DIFF 0x1638  /* High: 5688 bytes below Rx FIFO size */
+#define E1000_FC_LOW_DIFF 0x1640   /* Low:  5696 bytes below Rx FIFO size */
 
-/* Flow Control Pause Time: 858 usec */
-#define E1000_FC_PAUSE_TIME 0x0680
+#define E1000_FC_PAUSE_TIME 0x0680 /* 858 usec */
 
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define E1000_TX_QUEUE_WAKE	16
diff -up linux-2.4/drivers/net/e1000/e1000_hw.c linux-2.4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.4/drivers/net/e1000/e1000_hw.c	2004-07-28 08:47:08.174582456 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.c	2004-07-28 08:47:09.499381056 -0700
@@ -3445,7 +3445,6 @@ e1000_read_eeprom(struct e1000_hw *hw,
     uint32_t i = 0;
 
     DEBUGFUNC("e1000_read_eeprom");
-
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
@@ -5216,3 +5215,4 @@ e1000_enable_mng_pass_thru(struct e1000_
     }
     return FALSE;
 }
+
diff -up linux-2.4/drivers/net/e1000/e1000_hw.h linux-2.4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.4/drivers/net/e1000/e1000_hw.h	2004-07-28 08:47:08.176582152 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.h	2004-07-28 08:47:09.531376192 -0700
@@ -1043,7 +1043,6 @@ struct e1000_hw {
 
 #define E1000_EEPROM_SWDPIN0   0x0001   /* SWDPIN 0 EEPROM Value */
 #define E1000_EEPROM_LED_LOGIC 0x0020   /* Led Logic Word */
-
 /* Register Bit Masks */
 /* Device Control */
 #define E1000_CTRL_FD       0x00000001  /* Full duplex.0=half; 1=full */
diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-07-28 08:47:08.177582000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-07-28 08:47:09.559371936 -0700
@@ -168,7 +168,7 @@ static int e1000_resume(struct pci_dev *
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
-static void e1000_netpoll (struct net_device *dev);
+static void e1000_netpoll (struct net_device *netdev);
 #endif
 
 struct notifier_block e1000_notifier_reboot = {
@@ -181,7 +181,6 @@ struct notifier_block e1000_notifier_reb
 
 extern void e1000_check_options(struct e1000_adapter *adapter);
 
-
 static struct pci_driver e1000_driver = {
 	.name     = e1000_driver_name,
 	.id_table = e1000_pci_tbl,
@@ -336,10 +335,10 @@ e1000_reset(struct e1000_adapter *adapte
 	E1000_WRITE_REG(&adapter->hw, PBA, pba);
 
 	/* flow control settings */
-	adapter->hw.fc_high_water =
-		(pba << E1000_PBA_BYTES_SHIFT) - E1000_FC_HIGH_DIFF;
-	adapter->hw.fc_low_water =
-		(pba << E1000_PBA_BYTES_SHIFT) - E1000_FC_LOW_DIFF;
+	adapter->hw.fc_high_water = (pba << E1000_PBA_BYTES_SHIFT) -
+				    E1000_FC_HIGH_DIFF;
+	adapter->hw.fc_low_water = (pba << E1000_PBA_BYTES_SHIFT) -
+				   E1000_FC_LOW_DIFF;
 	adapter->hw.fc_pause_time = E1000_FC_PAUSE_TIME;
 	adapter->hw.fc_send_xon = 1;
 	adapter->hw.fc = adapter->hw.original_fc;
@@ -424,8 +423,8 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->msg_enable = (1 << debug) - 1;
 
 	rtnl_lock();
-	/* we need to set the name early since the DPRINTK macro needs it set */
-	if (dev_alloc_name(netdev, netdev->name) < 0) 
+	/* we need to set the name early for the DPRINTK macro */
+	if(dev_alloc_name(netdev, netdev->name) < 0)
 		goto err_free_unlock;
 
 	mmio_start = pci_resource_start(pdev, BAR_0);
@@ -583,10 +582,9 @@ e1000_probe(struct pci_dev *pdev,
 		adapter->wol |= E1000_WUFC_MAG;
 
 	/* reset the hardware with the new settings */
-
 	e1000_reset(adapter);
 
-	/* since we are holding the rtnl lock already, call the no-lock version */
+	/* We're already holding the rtnl lock; call the no-lock version */
 	if((err = register_netdevice(netdev)))
 		goto err_register;
 
@@ -677,7 +675,7 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	/* identify the MAC */
 
-	if (e1000_set_mac_type(hw)) {
+	if(e1000_set_mac_type(hw)) {
 		DPRINTK(PROBE, ERR, "Unknown MAC Type\n");
 		return -EIO;
 	}
@@ -975,7 +973,9 @@ e1000_setup_rctl(struct e1000_adapter *a
 	else
 		rctl &= ~E1000_RCTL_SBP;
 
+	/* Setup buffer sizes */
 	rctl &= ~(E1000_RCTL_SZ_4096);
+	rctl |= (E1000_RCTL_BSEX | E1000_RCTL_LPE);
 	switch (adapter->rx_buffer_len) {
 	case E1000_RXBUFFER_2048:
 	default:
@@ -983,13 +983,13 @@ e1000_setup_rctl(struct e1000_adapter *a
 		rctl &= ~(E1000_RCTL_BSEX | E1000_RCTL_LPE);
 		break;
 	case E1000_RXBUFFER_4096:
-		rctl |= E1000_RCTL_SZ_4096 | E1000_RCTL_BSEX | E1000_RCTL_LPE;
+		rctl |= E1000_RCTL_SZ_4096;
 		break;
 	case E1000_RXBUFFER_8192:
-		rctl |= E1000_RCTL_SZ_8192 | E1000_RCTL_BSEX | E1000_RCTL_LPE;
+		rctl |= E1000_RCTL_SZ_8192;
 		break;
 	case E1000_RXBUFFER_16384:
-		rctl |= E1000_RCTL_SZ_16384 | E1000_RCTL_BSEX | E1000_RCTL_LPE;
+		rctl |= E1000_RCTL_SZ_16384;
 		break;
 	}
 
@@ -1011,13 +1011,11 @@ e1000_configure_rx(struct e1000_adapter 
 	uint32_t rctl;
 	uint32_t rxcsum;
 
-	/* make sure receives are disabled while setting up the descriptors */
-
+	/* disable receives while setting up the descriptors */
 	rctl = E1000_READ_REG(&adapter->hw, RCTL);
 	E1000_WRITE_REG(&adapter->hw, RCTL, rctl & ~E1000_RCTL_EN);
 
 	/* set the Receive Delay Timer Register */
-
 	E1000_WRITE_REG(&adapter->hw, RDTR, adapter->rx_int_delay);
 
 	if(adapter->hw.mac_type >= e1000_82540) {
@@ -1028,7 +1026,6 @@ e1000_configure_rx(struct e1000_adapter 
 	}
 
 	/* Setup the Base and Length of the Rx Descriptor Ring */
-
 	E1000_WRITE_REG(&adapter->hw, RDBAL, (rdba & 0x00000000ffffffffULL));
 	E1000_WRITE_REG(&adapter->hw, RDBAH, (rdba >> 32));
 
@@ -1047,7 +1044,6 @@ e1000_configure_rx(struct e1000_adapter 
 	}
 
 	/* Enable Receives */
-
 	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 }
 
@@ -1095,9 +1091,9 @@ e1000_clean_tx_ring(struct e1000_adapter
 		if(buffer_info->skb) {
 
 			pci_unmap_page(pdev,
-			               buffer_info->dma,
-			               buffer_info->length,
-			               PCI_DMA_TODEVICE);
+				       buffer_info->dma,
+				       buffer_info->length,
+				       PCI_DMA_TODEVICE);
 
 			dev_kfree_skb(buffer_info->skb);
 
@@ -1163,12 +1159,11 @@ e1000_clean_rx_ring(struct e1000_adapter
 		if(buffer_info->skb) {
 
 			pci_unmap_single(pdev,
-			                 buffer_info->dma,
-			                 buffer_info->length,
-			                 PCI_DMA_FROMDEVICE);
+					 buffer_info->dma,
+					 buffer_info->length,
+					 PCI_DMA_FROMDEVICE);
 
 			dev_kfree_skb(buffer_info->skb);
-
 			buffer_info->skb = NULL;
 		}
 	}
@@ -1334,7 +1329,8 @@ e1000_set_multi(struct net_device *netde
 		e1000_leave_82542_rst(adapter);
 }
 
-/* need to wait a few seconds after link up to get diagnostic information from the phy */
+/* Need to wait a few seconds after link up to get diagnostic information from
+ * the phy */
 
 static void
 e1000_update_phy_info(unsigned long data)
@@ -1442,7 +1438,7 @@ e1000_watchdog(unsigned long data)
 	adapter->tpt_old = adapter->stats.tpt;
 	adapter->hw.collision_delta = adapter->stats.colc - adapter->colc_old;
 	adapter->colc_old = adapter->stats.colc;
-	
+
 	adapter->gorcl = adapter->stats.gorcl - adapter->gorcl_old;
 	adapter->gorcl_old = adapter->stats.gorcl;
 	adapter->gotcl = adapter->stats.gotcl - adapter->gotcl_old;
@@ -1590,7 +1586,6 @@ e1000_tx_map(struct e1000_adapter *adapt
 	unsigned int f;
 	len -= skb->data_len;
 
-
 	i = tx_ring->next_to_use;
 
 	while(len) {
@@ -1662,10 +1639,11 @@ e1000_tx_map(struct e1000_adapter *adapt
 			if(unlikely(++i == tx_ring->count)) i = 0;
 		}
 	}
+
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
-	
+
 	return count;
 }
 
@@ -1756,7 +1752,7 @@ no_fifo_stall_required:
 	return 0;
 }
 
-#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 ) 
+#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
@@ -1764,11 +1744,11 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned long flags;
 	unsigned int len = skb->len;
-	int count = 0;
-	unsigned int mss = 0;
+	unsigned long flags;
 	unsigned int nr_frags = 0;
+	unsigned int mss = 0;
+	int count = 0;
 	unsigned int f;
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
@@ -1780,7 +1744,7 @@ 
 
 #ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->tso_size;
-	/* The controller does a simple calculation to 
+	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
@@ -1790,15 +1769,16 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 	}
+
 	if((mss) || (skb->ip_summed == CHECKSUM_HW))
 		count++;
-	count++;	/*for sentinel desc*/
+	count++;	/* for sentinel desc */
 #else
 	if(skb->ip_summed == CHECKSUM_HW)
 		count++;
 #endif
-
 	count += TXD_USE_COUNT(len, max_txd_pwr);
+
 	if(adapter->pcix_82544)
 		count++;
 
@@ -1805,18 +1769,20 @@ 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for(f = 0; f < nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
-		                       max_txd_pwr);
+				       max_txd_pwr);
 	if(adapter->pcix_82544)
 		count += nr_frags;
-	
+
 	spin_lock_irqsave(&adapter->tx_lock, flags);
-	/* need: count +  2 desc gap to keep tail from touching 
+
+	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2 ) {
+	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
+
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
 	if(unlikely(adapter->hw.mac_type == e1000_82547)) {
@@ -1839,8 +1769,8 @@ 
 	else if(likely(e1000_tx_csum(adapter, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	e1000_tx_queue(adapter, 
-		e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss), 
+	e1000_tx_queue(adapter,
+		e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss),
 		tx_flags);
 
 	netdev->trans_start = jiffies;
@@ -1927,7 +1908,6 @@ e1000_change_mtu(struct net_device *netd
 	}
 
 	if(old_mtu != adapter->rx_buffer_len && netif_running(netdev)) {
-
 		e1000_down(adapter);
 		e1000_up(adapter);
 	}
@@ -2181,8 +2179,8 @@ e1000_clean(struct net_device *netdev, i
 
 	return (work_done >= work_to_do);
 }
-#endif
 
+#endif
 /**
  * e1000_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
@@ -2199,31 +2175,25 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	unsigned int i, eop;
 	boolean_t cleaned = FALSE;
 
-
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
 	while(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-
 		for(cleaned = FALSE; !cleaned; ) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
-
 			if(likely(buffer_info->dma)) {
 				pci_unmap_page(pdev,
 					       buffer_info->dma,
 					       buffer_info->length,
 					       PCI_DMA_TODEVICE);
-
 				buffer_info->dma = 0;
 			}
 
 			if(buffer_info->skb) {
-
 				dev_kfree_skb_any(buffer_info->skb);
-
 				buffer_info->skb = NULL;
 			}
 
@@ -2253,7 +2245,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 }
 
 /**
- * e1000_clean_rx_irq - Send received data up the network stack,
+ * e1000_clean_rx_irq - Send received data up the network stack
  * @adapter: board private structure
  **/
 
@@ -2282,14 +2274,11 @@ e1000_clean_rx_irq(struct e1000_adapter 
 
 	while(rx_desc->status & E1000_RXD_STAT_DD) {
 		buffer_info = &rx_ring->buffer_info[i];
-
 #ifdef CONFIG_E1000_NAPI
 		if(*work_done >= work_to_do)
 			break;
-
 		(*work_done)++;
 #endif
-
 		cleaned = TRUE;
 
 		pci_unmap_single(pdev,
@@ -2300,40 +2276,27 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rx_desc->length);
 
-
 		if(unlikely(!(rx_desc->status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
-
-
 			E1000_DBG("%s: Receive packet consumed multiple"
 				  " buffers\n", netdev->name);
 			dev_kfree_skb_irq(skb);
-
-
 			goto next_desc;
 		}
 
-
 		if(unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
 			last_byte = *(skb->data + length - 1);
-
 			if(TBI_ACCEPT(&adapter->hw, rx_desc->status,
 			              rx_desc->errors, length, last_byte)) {
-
 				spin_lock_irqsave(&adapter->stats_lock, flags);
-
 				e1000_tbi_adjust_stats(&adapter->hw,
 				                       &adapter->stats,
 				                       length, skb->data);
-
 				spin_unlock_irqrestore(&adapter->stats_lock,
 				                       flags);
 				length--;
 			} else {
-
 				dev_kfree_skb_irq(skb);
-
-
 				goto next_desc;
 			}
 		}
@@ -2349,8 +2330,8 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		if(unlikely(adapter->vlgrp &&
 			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special &
-					E1000_RXD_SPC_VLAN_MASK));
+						 le16_to_cpu(rx_desc->special &
+						 E1000_RXD_SPC_VLAN_MASK));
 		} else {
 			netif_receive_skb(skb);
 		}
@@ -2358,7 +2330,7 @@ 
 		if(unlikely(adapter->vlgrp &&
 			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special &
+					le16_to_cpu(rx_desc->special &
 					E1000_RXD_SPC_VLAN_MASK));
 		} else {
 			netif_rx(skb);
@@ -2404,7 +2384,7 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	while(!buffer_info->skb) {
 		skb = dev_alloc_skb(adapter->rx_buffer_len + reserve_len);
 
-		if(!skb) {
+		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
 		}
@@ -2419,11 +2403,10 @@ e1000_alloc_rx_buffers(struct e1000_adap
 
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
-		buffer_info->dma =
-			pci_map_single(pdev,
-			               skb->data,
-			               adapter->rx_buffer_len,
-			               PCI_DMA_FROMDEVICE);
+		buffer_info->dma = pci_map_single(pdev,
+						  skb->data,
+						  adapter->rx_buffer_len,
+						  PCI_DMA_FROMDEVICE);
 
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
@@ -2557,24 +2544,24 @@ e1000_mii_ioctl(struct net_device *netde
 			return -EFAULT;
 		mii_reg = data->val_in;
 		if (e1000_write_phy_reg(&adapter->hw, data->reg_num,
-					data->val_in))
+					mii_reg))
 			return -EIO;
 		if (adapter->hw.phy_type == e1000_phy_m88) {
 			switch (data->reg_num) {
 			case PHY_CTRL:
-				if(data->val_in & MII_CR_AUTO_NEG_EN) {
 				if(mii_reg & MII_CR_POWER_DOWN)
 					break;
+				if(mii_reg & MII_CR_AUTO_NEG_EN) {
 					adapter->hw.autoneg = 1;
 					adapter->hw.autoneg_advertised = 0x2F;
 				} else {
-					if (data->val_in & 0x40)
+					if (mii_reg & 0x40)
 						spddplx = SPEED_1000;
-					else if (data->val_in & 0x2000)
+					else if (mii_reg & 0x2000)
 						spddplx = SPEED_100;
 					else
 						spddplx = SPEED_10;
-					spddplx += (data->val_in & 0x100)
+					spddplx += (mii_reg & 0x100)
 						   ? FULL_DUPLEX :
 						   HALF_DUPLEX;
 					retval = e1000_set_spd_dplx(adapter,
@@ -2643,7 +2618,7 @@ e1000_rx_checksum(struct e1000_adapter *
 		skb->ip_summed = CHECKSUM_NONE;
 		adapter->hw_csum_err++;
 	} else {
-	/* TCP checksum is good */
+		/* TCP checksum is good */
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		adapter->hw_csum_good++;
 	}
@@ -2705,26 +2680,22 @@ e1000_vlan_rx_register(struct net_device
 
 	if(grp) {
 		/* enable VLAN tag insert/strip */
-
 		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 		ctrl |= E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
 		/* enable VLAN receive filtering */
-
 		rctl = E1000_READ_REG(&adapter->hw, RCTL);
 		rctl |= E1000_RCTL_VFE;
 		rctl &= ~E1000_RCTL_CFIEN;
 		E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 	} else {
 		/* disable VLAN tag insert/strip */
-
 		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 		ctrl &= ~E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
 		/* disable VLAN filtering */
-
 		rctl = E1000_READ_REG(&adapter->hw, RCTL);
 		rctl &= ~E1000_RCTL_VFE;
 		E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
@@ -2740,7 +2711,6 @@ e1000_vlan_rx_add_vid(struct net_device 
 	uint32_t vfta, index;
 
 	/* add VID to filter table */
-
 	index = (vid >> 5) & 0x7F;
 	vfta = E1000_READ_REG_ARRAY(&adapter->hw, VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
@@ -2760,8 +2730,7 @@ e1000_vlan_rx_kill_vid(struct net_device
 
 	e1000_irq_enable(adapter);
 
-	/* remove VID from filter table*/
-
+	/* remove VID from filter table */
 	index = (vid >> 5) & 0x7F;
 	vfta = E1000_READ_REG_ARRAY(&adapter->hw, VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
@@ -2950,12 +2919,12 @@ e1000_resume(struct pci_dev *pdev)
  * without having to re-enable interrupts. It's not called while
  * the interrupt routine is executing.
  */
-
-static void e1000_netpoll (struct net_device *dev)
+static void
+e1000_netpoll (struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = dev->priv;
+	struct e1000_adapter *adapter = netdev->priv;
 	disable_irq(adapter->pdev->irq);
-	e1000_intr (adapter->pdev->irq, dev, NULL);
+	e1000_intr(adapter->pdev->irq, netdev, NULL);
 	enable_irq(adapter->pdev->irq);
 }
 #endif
diff -up linux-2.4/drivers/net/e1000/e1000_param.c linux-2.4/drivers/net/e1000.new/e1000_param.c
--- linux-2.4/drivers/net/e1000/e1000_param.c	2004-07-28 08:47:08.179581696 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_param.c	2004-07-28 08:47:09.574369656 -0700
@@ -235,7 +235,7 @@ struct e1000_option {
 
 static int __devinit
 e1000_validate_option(int *value, struct e1000_option *opt,
-	struct e1000_adapter *adapter)
+		struct e1000_adapter *adapter)
 {
 	if(*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -256,7 +256,7 @@ e1000_validate_option(int *value, struct
 	case range_option:
 		if(*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
 			DPRINTK(PROBE, INFO,
-				"%s set to %i\n", opt->name, *value);
+					"%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -449,8 +449,7 @@ e1000_check_options(struct e1000_adapter
 			DPRINTK(PROBE, INFO, "%s turned off\n", opt.name);
 			break;
 		case 1:
-			DPRINTK(PROBE, INFO,
-				"%s set to dynamic mode\n", opt.name);
+			DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", opt.name);
 			break;
 		default:
 			e1000_validate_option(&adapter->itr, &opt, adapter);
@@ -493,8 +492,9 @@ e1000_check_fiber_options(struct e1000_a
 		       "parameter ignored\n");
 	}
 	if((AutoNeg[bd] != OPTION_UNSET) && (AutoNeg[bd] != 0x20)) {
-		DPRINTK(PROBE, INFO, "AutoNeg other than Full/1000 is "
-		       "not valid for fiber adapters, parameter ignored\n");
+		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
+				 "not valid for fiber adapters, "
+				 "parameter ignored\n");
 	}
 }
 
@@ -611,24 +611,24 @@ e1000_check_copper_options(struct e1000_
 		break;
 	case HALF_DUPLEX:
 		DPRINTK(PROBE, INFO, "Half Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at Half Duplex only\n");
+		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+			"Half Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Full Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at Full Duplex only\n");
+		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
 		                                 ADVERTISE_100_FULL |
 		                                 ADVERTISE_1000_FULL;
 		break;
 	case SPEED_10:
-		DPRINTK(PROBE, INFO,
-			"10 Mbps Speed specified without Duplex\n");
+		DPRINTK(PROBE, INFO, "10 Mbps Speed specified "
+			"without Duplex\n");
 		DPRINTK(PROBE, INFO, "Using Autonegotiation at 10 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
@@ -647,10 +647,10 @@ e1000_check_copper_options(struct e1000_
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
-		DPRINTK(PROBE, INFO,
-			"100 Mbps Speed specified without Duplex\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at 100 Mbps only\n");
+		DPRINTK(PROBE, INFO, "100 Mbps Speed specified "
+			"without Duplex\n");
+		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+			"100 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
 		                                 ADVERTISE_100_FULL;
@@ -668,10 +668,11 @@ e1000_check_copper_options(struct e1000_
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_1000:
+		DPRINTK(PROBE, INFO, "1000 Mbps Speed specified without "
+			"Duplex\n");
 		DPRINTK(PROBE, INFO,
-			"1000 Mbps Speed specified without Duplex\n");
-		DPRINTK(PROBE, INFO,
-		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+			"Using Autonegotiation at 1000 Mbps "
+			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
@@ -679,7 +680,8 @@ e1000_check_copper_options(struct e1000_
 		DPRINTK(PROBE, INFO,
 			"Half Duplex is not supported at 1000 Mbps\n");
 		DPRINTK(PROBE, INFO,
-		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+			"Using Autonegotiation at 1000 Mbps "
+			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
@@ -696,8 +698,8 @@ e1000_check_copper_options(struct e1000_
 	/* Speed, AutoNeg and MDI/MDI-X must all play nice */
 	if (e1000_validate_mdi_setting(&(adapter->hw)) < 0) {
 		DPRINTK(PROBE, INFO,
-		       "Speed, AutoNeg and MDI-X specifications are "
-		       "incompatible. Setting MDI-X to a compatible value.\n");
+			"Speed, AutoNeg and MDI-X specifications are "
+			"incompatible. Setting MDI-X to a compatible value.\n");
 	}
 }
 
Only in linux-2.4/drivers/net/e1000.new: kcompat_ethtool.c
