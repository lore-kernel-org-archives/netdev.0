From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 31 Aug 2010 09:10:09 -0700
Message-ID: <1283271009.1797.28.camel@Joe-Laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <4C7D0E7A.5060309@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C7D0E7A.5060309@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-08-31 at 23:15 +0900, Masayuki Ohtake wrote:
> We have modified this driver for your comment.

Some trivial logging message cleanups:

Missing newline
Alignment
Grammar
80 column coalescing

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c  |  180 ++++++++++++++++-------------------
 drivers/net/pch_gbe/pch_gbe_param.c |   36 +++-----
 drivers/net/pch_gbe/pch_gbe_phy.c   |    2 +-
 3 files changed, 94 insertions(+), 124 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index ce0c38e..264f275 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -284,7 +284,7 @@ s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw)
 		rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
 	iowrite32(rx_fctrl, &hw->reg->RX_FCTRL);
 	pr_debug("RX_FCTRL reg : 0x%08x  mac->tx_fc_enable : %d\n",
-			ioread32(&hw->reg->RX_FCTRL), mac->tx_fc_enable);
+		 ioread32(&hw->reg->RX_FCTRL), mac->tx_fc_enable);
 	return 0;
 }
 
@@ -299,7 +299,7 @@ void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32 wu_evt)
 
 	FUNC_ENTER();
 	pr_debug("wu_evt : 0x%08x  ADDR_MASK reg : 0x%08x\n",
-			wu_evt, ioread32(&hw->reg->ADDR_MASK));
+		 wu_evt, ioread32(&hw->reg->ADDR_MASK));
 
 	if (wu_evt) {
 		/* Set Wake-On-Lan address mask */
@@ -360,8 +360,8 @@ u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr, u32 dir, u32 reg,
 	spin_unlock_irqrestore(&hw->miim_lock, flags);
 
 	pr_debug("PHY %s: reg=%d, data=0x%04X\n",
-			dir == PCH_GBE_MIIM_OPER_READ ? "READ" : "WRITE", reg,
-			dir == PCH_GBE_MIIM_OPER_READ ? data_out : data);
+		 dir == PCH_GBE_MIIM_OPER_READ ? "READ" : "WRITE", reg,
+		 dir == PCH_GBE_MIIM_OPER_READ ? data_out : data);
 	return (u16) data_out;
 }
 
@@ -394,9 +394,9 @@ void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
 	iowrite32(PCH_GBE_PS_PKT_RQ, &hw->reg->PAUSE_REQ);
 
 	pr_debug("PAUSE_PKT1-5 reg : 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x\n",
-	     ioread32(&hw->reg->PAUSE_PKT1), ioread32(&hw->reg->PAUSE_PKT2),
-	     ioread32(&hw->reg->PAUSE_PKT3), ioread32(&hw->reg->PAUSE_PKT4),
-	     ioread32(&hw->reg->PAUSE_PKT5));
+		 ioread32(&hw->reg->PAUSE_PKT1), ioread32(&hw->reg->PAUSE_PKT2),
+		 ioread32(&hw->reg->PAUSE_PKT3), ioread32(&hw->reg->PAUSE_PKT4),
+		 ioread32(&hw->reg->PAUSE_PKT5));
 
 	return;
 }
@@ -607,7 +607,7 @@ static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
 	free_irq(adapter->pdev->irq, netdev);
 	if (adapter->have_msi) {
 		pci_disable_msi(adapter->pdev);
-		pr_debug("call pci_disable_msi");
+		pr_debug("call pci_disable_msi\n");
 	}
 }
 
@@ -677,8 +677,9 @@ static void pch_gbe_configure_tx(struct pch_gbe_adapter *adapter)
 	u32 tdba, tdlen, dctrl;
 
 	FUNC_ENTER();
-	pr_debug("dma adr = 0x%08x  size = 0x%08x\n",
-			adapter->tx_ring->dma, adapter->tx_ring->size);
+	pr_debug("dma addr = 0x%08llx  size = 0x%08x\n",
+		 (unsigned long long)adapter->tx_ring->dma,
+		 adapter->tx_ring->size);
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	tdba = adapter->tx_ring->dma;
@@ -731,8 +732,9 @@ static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
 	u32 rdba, rdlen, rctl, rxdma;
 
 	FUNC_ENTER();
-	pr_debug("dma adr = 0x%08x  size = 0x%08x\n",
-			adapter->rx_ring->dma, adapter->rx_ring->size);
+	pr_debug("dma adr = 0x%08llx  size = 0x%08x\n",
+		 (unsigned long long)adapter->rx_ring->dma,
+		 adapter->rx_ring->size);
 
 	pch_gbe_mac_force_mac_fc(hw);
 
@@ -746,8 +748,8 @@ static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
 	iowrite32(rxdma, &hw->reg->DMA_CTRL);
 
 	pr_debug("MAC_RX_EN reg = 0x%08x  DMA_CTRL reg = 0x%08x\n",
-			ioread32(&hw->reg->MAC_RX_EN),
-			ioread32(&hw->reg->DMA_CTRL));
+		 ioread32(&hw->reg->MAC_RX_EN),
+		 ioread32(&hw->reg->DMA_CTRL));
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
@@ -827,8 +829,7 @@ static void pch_gbe_clean_tx_ring(struct pch_gbe_adapter *adapter,
 		buffer_info = &tx_ring->buffer_info[i];
 		pch_gbe_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
-	pr_debug("call pch_gbe_unmap_and_free_tx_resource() %d count\n",
-			i);
+	pr_debug("call pch_gbe_unmap_and_free_tx_resource() %d count\n", i);
 
 	size = (unsigned long)sizeof(struct pch_gbe_buffer) * tx_ring->count;
 	memset(tx_ring->buffer_info, 0, size);
@@ -861,8 +862,7 @@ pch_gbe_clean_rx_ring(struct pch_gbe_adapter *adapter,
 		buffer_info = &rx_ring->buffer_info[i];
 		pch_gbe_unmap_and_free_rx_resource(adapter, buffer_info);
 	}
-	pr_debug("call pch_gbe_unmap_and_free_rx_resource() %d count\n",
-			i);
+	pr_debug("call pch_gbe_unmap_and_free_rx_resource() %d count\n", i);
 	size = (unsigned long)sizeof(struct pch_gbe_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
 
@@ -964,14 +964,16 @@ static void pch_gbe_watchdog(unsigned long data)
 						hw->mac.link_duplex);
 		/* Set the communication mode */
 		pch_gbe_set_mode(adapter, hw->mac.link_speed,
-						hw->mac.link_duplex);
-		pr_debug("NIC Link is Up %d Mbps %s-Duplex\n",
-			cmd.speed, cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
+				 hw->mac.link_duplex);
+		netdev_dbg(netdev,
+			   "Link is Up %d Mbps %s-Duplex\n",
+			   cmd.speed,
+			   cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
 		netif_carrier_on(netdev);
 		netif_wake_queue(netdev);
 	} else if ((!mii_link_ok(&adapter->mii)) &&
-					(netif_carrier_ok(netdev))) {
-		pr_debug("NIC Link is Down\n");
+		   (netif_carrier_ok(netdev))) {
+		netdev_dbg(netdev, "NIC Link is Down\n");
 		hw->mac.link_speed = SPEED_10;
 		hw->mac.link_duplex = DUPLEX_HALF;
 		netif_carrier_off(netdev);
@@ -1183,7 +1185,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 		}
 	}
 	pr_debug("return = 0x%08x  INT_EN reg = 0x%08x\n",
-			IRQ_HANDLED, ioread32(&hw->reg->INT_EN));
+		 IRQ_HANDLED, ioread32(&hw->reg->INT_EN));
 	return IRQ_HANDLED;
 }
 
@@ -1238,9 +1240,9 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 		rx_desc->buffer_addr = (buffer_info->dma);
 		rx_desc->gbec_status = DSC_INIT16;
 
-		pr_debug("i = %d  buffer_info->dma = 0x%x  "
-			 "buffer_info->length = 0x%x\n",
-			 i, buffer_info->dma, buffer_info->length);
+		pr_debug("i = %d  buffer_info->dma = 0x08%llx  buffer_info->length = 0x%x\n",
+			 i, (unsigned long long)buffer_info->dma,
+			 buffer_info->length);
 
 		if (unlikely(++i == rx_ring->count))
 			i = 0;
@@ -1311,7 +1313,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	i = tx_ring->next_to_clean;
 	tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
 	pr_debug("gbec_status:0x%04x  dma_status:0x%04x\n",
-			tx_desc->gbec_status, tx_desc->dma_status);
+		 tx_desc->gbec_status, tx_desc->dma_status);
 
 	while ((tx_desc->gbec_status & DSC_INIT16) == 0x0000) {
 		pr_debug("gbec_status:0x%04x\n", tx_desc->gbec_status);
@@ -1321,7 +1323,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 
 		if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_ABT)) {
 			adapter->stats.tx_aborted_errors++;
-			pr_err("Transfer Aboat Error\n");
+			pr_err("Transfer Abort Error\n");
 		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CRSER)
 			  ) {
 			adapter->stats.tx_carrier_errors++;
@@ -1353,9 +1355,8 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 			skb_trim(buffer_info->skb, 0);
 		}
 		if (buffer_info->kernel_skb) {
-			pr_debug
-			    ("free buffer_info->kernel_skb adr: 0x%x\n",
-			     (u32)(buffer_info->kernel_skb));
+			pr_debug("free buffer_info->kernel_skb adr: 0x%x\n",
+				 (u32)(buffer_info->kernel_skb));
 			dev_kfree_skb(buffer_info->kernel_skb);
 			buffer_info->kernel_skb = NULL;
 		}
@@ -1368,8 +1369,8 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 		if (cleaned_count++ == PCH_GBE_TX_WEIGHT)
 			break;
 	}
-	pr_debug("called pch_gbe_unmap_and_free_tx_resource() %dcount\n",
-			cleaned_count);
+	pr_debug("called pch_gbe_unmap_and_free_tx_resource() %d count\n",
+		 cleaned_count);
 	/* Recover from running out of Tx resources in xmit_frame */
 	if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev)))) {
 		netif_wake_queue(adapter->netdev);
@@ -1439,8 +1440,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 		/* Prefetch the packet */
 		prefetch(skb->data);
 
-		pr_debug
-			("RxDecNo = 0x%04x  Status[DMA:0x%02x GBE:0x%04x "
+		pr_debug("RxDecNo = 0x%04x  Status[DMA:0x%02x GBE:0x%04x "
 			 "TCP:0x%08x]  BufInf = 0x%08x\n",
 			 i, dma_status, gbec_status, tcp_ip_status,
 			 (u32) (buffer_info));
@@ -1528,9 +1528,8 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			}
 			(*work_done)++;
 			netdev->last_rx = jiffies;
-			pr_debug
-			    ("Receive skb->ip_summed: %d length: %d\n",
-			     skb->ip_summed, length);
+			pr_debug("Receive skb->ip_summed: %d length: %d\n",
+				 skb->ip_summed, length);
 		}
 dorrop:
 		/* return some buffers to hardware, one at a time is too slow */
@@ -1568,8 +1567,7 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 	size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
 	tx_ring->buffer_info = vmalloc(size);
 	if (!tx_ring->buffer_info) {
-		pr_err("Unable to allocate memory "
-			"for the buffer infomation\n");
+		pr_err("Unable to allocate memory for the buffer infomation\n");
 		return -ENOMEM;
 	}
 	memset(tx_ring->buffer_info, 0, size);
@@ -1580,8 +1578,7 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 		pci_alloc_consistent(pdev, tx_ring->size, &tx_ring->dma);
 	if (!tx_ring->desc) {
 		vfree(tx_ring->buffer_info);
-		pr_err("Unable to allocate memory "
-			"for the transmit descriptor ring\n");
+		pr_err("Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(tx_ring->desc, 0, tx_ring->size);
@@ -1594,10 +1591,10 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, desNo);
 		tx_desc->gbec_status = DSC_INIT16;
 	}
-	pr_debug("tx_ring->desc = 0x%08x  tx_ring->dma = 0x%08x\n"
-			"next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
-			(u32) tx_ring->desc, tx_ring->dma,
-			tx_ring->next_to_clean, tx_ring->next_to_use);
+	pr_debug("tx_ring->desc = 0x%08x  tx_ring->dma = 0x%08llx\n"
+		 "next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
+		 (u32) tx_ring->desc, (unsigned long long)tx_ring->dma,
+		 tx_ring->next_to_clean, tx_ring->next_to_use);
 	return 0;
 }
 
@@ -1621,8 +1618,7 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 	size = (int)sizeof(struct pch_gbe_buffer) * rx_ring->count;
 	rx_ring->buffer_info = vmalloc(size);
 	if (!rx_ring->buffer_info) {
-		pr_err("Unable to allocate memory "
-			"for the receive descriptor ring\n");
+		pr_err("Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rx_ring->buffer_info, 0, size);
@@ -1631,8 +1627,7 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 		pci_alloc_consistent(pdev, rx_ring->size, &rx_ring->dma);
 
 	if (!rx_ring->desc) {
-		pr_err("Unable to allocate memory "
-			"for the receive descriptor ring\n");
+		pr_err("Unable to allocate memory for the receive descriptor ring\n");
 		vfree(rx_ring->buffer_info);
 		return -ENOMEM;
 	}
@@ -1643,10 +1638,10 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 		rx_desc = PCH_GBE_RX_DESC(*rx_ring, desNo);
 		rx_desc->gbec_status = DSC_INIT16;
 	}
-	pr_debug("rx_ring->desc = 0x%08x  rx_ring->dma = 0x%08x "
-			"next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
-			(u32) rx_ring->desc, rx_ring->dma,
-			rx_ring->next_to_clean, rx_ring->next_to_use);
+	pr_debug("rx_ring->desc = 0x%08x  rx_ring->dma = 0x%08llx "
+		 "next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
+		 (u32) rx_ring->desc, (unsigned long long)rx_ring->dma,
+		 rx_ring->next_to_clean, rx_ring->next_to_use);
 	return 0;
 }
 
@@ -1714,8 +1709,8 @@ static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
 			  flags, netdev->name, netdev);
 	if (err)
 		pr_err("Unable to allocate interrupt Error: %d\n", err);
-	pr_debug("adapter->have_msi : %d  flags : 0x%04x  "
-			"return : 0x%04x\n", adapter->have_msi, flags, err);
+	pr_debug("adapter->have_msi : %d  flags : 0x%04x  return : 0x%04x\n",
+		 adapter->have_msi, flags, err);
 	return err;
 }
 
@@ -1834,14 +1829,13 @@ static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
 	pch_gbe_init_stats(adapter);
 
 	pr_debug("vendor_id : 0x%08x  device_id : 0x%08x\n",
-			hw->vendor_id, hw->device_id);
-	pr_debug("subsystem vendor_id :0x%08x device_id :0x%08x\n"
-			"revision_id :0x%08x\n", hw->subsystem_vendor_id,
-			hw->subsystem_device_id, hw->revision_id);
-	pr_debug("rx_buffer_len : %d  mac.max_frame_size : %d  "
-			"mac.min_frame_size : %d\n",
-			(u32) adapter->rx_buffer_len,
-			hw->mac.max_frame_size,	hw->mac.min_frame_size);
+		 hw->vendor_id, hw->device_id);
+	pr_debug("subsystem vendor_id :0x%08x device_id :0x%08x revision_id :0x%08x\n",
+		 hw->subsystem_vendor_id,
+		 hw->subsystem_device_id, hw->revision_id);
+	pr_debug("rx_buffer_len : %d  mac.min_frame_size : %d  mac.max_frame_size : %d\n",
+		 (u32) adapter->rx_buffer_len,
+		 hw->mac.min_frame_size, hw->mac.max_frame_size);
 	return 0;
 }
 
@@ -1927,8 +1921,8 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
-		pr_err("Transfer length Error: %d over %d\n",
-			skb->len, adapter->hw.mac.max_frame_size);
+		pr_err("Transfer length Error: skb len: %d > max: %d\n",
+		       skb->len, adapter->hw.mac.max_frame_size);
 		dev_kfree_skb_any(skb);
 		adapter->stats.tx_length_errors++;
 		return NETDEV_TX_BUSY;
@@ -1940,10 +1934,8 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring))) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
-		pr_debug
-		("Return : BUSY  next_to use : 0x%08x  "
-		 "next_to clean : 0x%08x\n",
-		 tx_ring->next_to_use, tx_ring->next_to_clean);
+		pr_debug("Return : BUSY  next_to use : 0x%08x  next_to clean : 0x%08x\n",
+			 tx_ring->next_to_use, tx_ring->next_to_clean);
 		return NETDEV_TX_BUSY;
 	}
 	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
@@ -2023,9 +2015,8 @@ static void pch_gbe_set_multi(struct net_device *netdev)
 					PCH_GBE_MAR_ENTRIES);
 	kfree(mta_list);
 
-	pr_debug("RX_MODE reg(check bit31,30 ADD,MLT) : 0x%08x  "
-			 "netdev->mc_count : 0x%08x\n",
-			 ioread32(&hw->reg->RX_MODE), mc_count);
+	pr_debug("RX_MODE reg(check bit31,30 ADD,MLT) : 0x%08x  netdev->mc_count : 0x%08x\n",
+		 ioread32(&hw->reg->RX_MODE), mc_count);
 }
 
 /**
@@ -2052,17 +2043,11 @@ static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
 		ret_val = 0;
 	}
 	pr_debug("ret_val : 0x%08x\n", ret_val);
-	pr_debug("dev_addr : %02x:%02x:%02x:%02x:%02x:%02x\n",
-			netdev->dev_addr[0], netdev->dev_addr[1],
-			netdev->dev_addr[2], netdev->dev_addr[3],
-			netdev->dev_addr[4], netdev->dev_addr[5]);
-	pr_debug("mac_addr : %02x:%02x:%02x:%02x:%02x:%02x\n",
-			adapter->hw.mac.addr[0], adapter->hw.mac.addr[1],
-			adapter->hw.mac.addr[2], adapter->hw.mac.addr[3],
-			adapter->hw.mac.addr[4], adapter->hw.mac.addr[5]);
+	pr_debug("dev_addr : %pM\n", netdev->dev_addr);
+	pr_debug("mac_addr : %pM\n", adapter->hw.mac.addr);
 	pr_debug("MAC_ADR1AB reg : 0x%08x 0x%08x\n",
-			ioread32(&adapter->hw.reg->mac_adr[0].high),
-			ioread32(&adapter->hw.reg->mac_adr[0].low));
+		 ioread32(&adapter->hw.reg->mac_adr[0].high),
+		 ioread32(&adapter->hw.reg->mac_adr[0].low));
 	return ret_val;
 }
 
@@ -2102,10 +2087,9 @@ static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
 	else
 		pch_gbe_reset(adapter);
 
-	pr_debug
-	("max_frame : %d  rx_buffer_len : %d  mtu : %d  max_frame_size : %d\n",
-	 max_frame, (u32) adapter->rx_buffer_len, netdev->mtu,
-	 adapter->hw.mac.max_frame_size);
+	pr_debug("max_frame : %d  rx_buffer_len : %d  mtu : %d  max_frame_size : %d\n",
+		 max_frame, (u32) adapter->rx_buffer_len, netdev->mtu,
+		 adapter->hw.mac.max_frame_size);
 	return 0;
 }
 
@@ -2184,7 +2168,7 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	pr_debug("poll_end_flag : %d  work_done : %d  budget : %d\n",
-			poll_end_flag, work_done, budget);
+		 poll_end_flag, work_done, budget);
 	return work_done;
 }
 
@@ -2242,7 +2226,7 @@ static pci_ers_result_t pch_gbe_io_slot_reset(struct pci_dev *pdev)
 
 	FUNC_ENTER();
 	if (pci_enable_device(pdev)) {
-		pr_err("Cannot re-enable PCI device after reset.\n");
+		pr_err("Cannot re-enable PCI device after reset\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -2263,8 +2247,7 @@ static void pch_gbe_io_resume(struct pci_dev *pdev)
 	FUNC_ENTER();
 	if (netif_running(netdev)) {
 		if (pch_gbe_up(adapter)) {
-			pr_debug("can't bring device back up after reset\n"
-					);
+			pr_debug("can't bring device back up after reset\n");
 			return;
 		}
 	}
@@ -2398,8 +2381,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 			ret = dma_set_coherent_mask(&pdev->dev,
 						    DMA_BIT_MASK(32));
 			if (ret) {
-				pr_err("ERR: "
-				    "No usable DMA configuration, aborting\n");
+				pr_err("ERR: No usable DMA configuration, aborting\n");
 				goto err_disable_device;
 			}
 		}
@@ -2414,7 +2396,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	netdev = alloc_etherdev((int)sizeof(struct pch_gbe_adapter));
 	if (!netdev) {
 		ret = -ENOMEM;
-		pr_err("ERR: Can't allocates and sets up an Ethernet device\n");
+		pr_err("ERR: Can't allocate and set up an Ethernet device\n");
 		goto err_release_pci;
 	}
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -2558,10 +2540,10 @@ static int __init pch_gbe_init_module(void)
 	ret = pci_register_driver(&pch_gbe_pcidev);
 	if (copybreak != PCH_GBE_COPYBREAK_DEFAULT) {
 		if (copybreak == 0) {
-			pr_info("pch_gbe: copybreak disabled\n");
+			pr_info("copybreak disabled\n");
 		} else {
-			pr_info("pch_gbe: copybreak enabled for "
-				"packets <= %u bytes\n", copybreak);
+			pr_info("copybreak enabled for packets <= %u bytes\n",
+				copybreak);
 		}
 	}
 	return ret;
@@ -2569,7 +2551,7 @@ static int __init pch_gbe_init_module(void)
 
 static void __exit pch_gbe_exit_module(void)
 {
-	pr_debug("pch_gbe_exit_module\n");
+	FUNC_ENTER();
 	pci_unregister_driver(&pch_gbe_pcidev);
 
 	pr_info("%s - unregister\n", DRV_STRING);
diff --git a/drivers/net/pch_gbe/pch_gbe_param.c b/drivers/net/pch_gbe/pch_gbe_param.c
index 08e1e00..1ac7aaa 100644
--- a/drivers/net/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/pch_gbe/pch_gbe_param.c
@@ -197,8 +197,7 @@ static int pch_gbe_validate_option(int *value, struct pch_gbe_option *opt,
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			pr_debug(
-					"%s set to %i\n", opt->name, *value);
+			pr_debug("%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -221,7 +220,7 @@ static int pch_gbe_validate_option(int *value, struct pch_gbe_option *opt,
 	}
 
 	pr_debug("Invalid %s value specified (%i) %s\n",
-			opt->name, *value, opt->err);
+		 opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -315,9 +314,7 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 					 .p = an_list} }
 		};
 		if (speed || dplx) {
-			pr_debug(
-			"AutoNeg specified along with Speed or Duplex, "
-			"parameter ignored\n");
+			pr_debug("AutoNeg specified along with Speed or Duplex, AutoNeg parameter ignored\n");
 			hw->phy.autoneg_advertised = opt.def;
 		} else {
 			hw->phy.autoneg_advertised = AutoNeg;
@@ -331,15 +328,13 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 	case 0:
 		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
 		if ((speed || dplx))
-			pr_debug(
-				"Speed and duplex autonegotiation enabled\n");
+			pr_debug("Speed and duplex autonegotiation enabled\n");
 		hw->mac.link_speed = SPEED_10;
 		hw->mac.link_duplex = DUPLEX_HALF;
 		break;
 	case PHY_HALF_DUPLEX:
 		pr_debug("Half Duplex specified without Speed\n");
-		pr_debug("Using Autonegotiation at "
-			"Half Duplex only\n");
+		pr_debug("Using Autonegotiation at Half Duplex only\n");
 		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
 		hw->phy.autoneg_advertised = PHY_ADVERTISE_10_HALF |
 						PHY_ADVERTISE_100_HALF;
@@ -348,8 +343,7 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 		break;
 	case PHY_FULL_DUPLEX:
 		pr_debug("Full Duplex specified without Speed\n");
-		pr_debug("Using Autonegotiation at "
-			"Full Duplex only\n");
+		pr_debug("Using Autonegotiation at Full Duplex only\n");
 		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
 		hw->phy.autoneg_advertised = PHY_ADVERTISE_10_FULL |
 						PHY_ADVERTISE_100_FULL |
@@ -358,8 +352,7 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 		hw->mac.link_duplex = DUPLEX_FULL;
 		break;
 	case PHY_SPEED_10:
-		pr_debug("10 Mbps Speed specified "
-			"without Duplex\n");
+		pr_debug("10 Mbps Speed specified without Duplex\n");
 		pr_debug("Using Autonegotiation at 10 Mbps only\n");
 		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
 		hw->phy.autoneg_advertised = PHY_ADVERTISE_10_HALF |
@@ -382,10 +375,8 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 		hw->mac.link_duplex = DUPLEX_FULL;
 		break;
 	case PHY_SPEED_100:
-		pr_debug("100 Mbps Speed specified "
-			"without Duplex\n");
-		pr_debug("Using Autonegotiation at "
-			"100 Mbps only\n");
+		pr_debug("100 Mbps Speed specified without Duplex\n");
+		pr_debug("Using Autonegotiation at 100 Mbps only\n");
 		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
 		hw->phy.autoneg_advertised = PHY_ADVERTISE_100_HALF |
 						PHY_ADVERTISE_100_FULL;
@@ -407,17 +398,14 @@ static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
 		hw->mac.link_duplex = DUPLEX_FULL;
 		break;
 	case PHY_SPEED_1000:
-		pr_debug("1000 Mbps Speed specified without "
-			"Duplex\n");
+		pr_debug("1000 Mbps Speed specified without Duplex\n");
 		goto full_duplex_only;
 	case PHY_SPEED_1000 + PHY_HALF_DUPLEX:
-		pr_debug(
-			"Half Duplex is not supported at 1000 Mbps\n");
+		pr_debug("Half Duplex is not supported at 1000 Mbps\n");
 		/* fall through */
 	case PHY_SPEED_1000 + PHY_FULL_DUPLEX:
 full_duplex_only:
-		pr_debug(
-		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+		pr_debug("Using Autonegotiation at 1000 Mbps Full Duplex only\n");
 		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
 		hw->phy.autoneg_advertised = PHY_ADVERTISE_1000_FULL;
 		hw->mac.link_speed = SPEED_1000;
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.c b/drivers/net/pch_gbe/pch_gbe_phy.c
index 6a553c5..c4832d3 100644
--- a/drivers/net/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/pch_gbe/pch_gbe_phy.c
@@ -118,7 +118,7 @@ s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw)
 	phy->id = ((phy->id << 6) | ((phy_id2 & 0xFC00) >> 10));
 	phy->revision = (u32) (phy_id2 & 0x000F);
 	pr_debug("phy->id : 0x%08x  phy->revision : 0x%08x\n",
-			phy->id, phy->revision);
+		 phy->id, phy->revision);
 	return 0;
 }
 
