From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/3] drivers/net/ixgbe/ixgbe_main.c: Checkpatch cleanups
Date: Sun, 22 Aug 2010 19:53:00 -0700
Message-ID: <c4222d22591d5d656a62384fd9f00e911629f49a.1282531322.git.joe@perches.com>
References: <cover.1282531322.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1282531322.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whitespace cleanups.
Move inline keyword after function type declarations.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgbe/ixgbe_main.c |  467 ++++++++++++++++++++--------------------
 1 files changed, 236 insertions(+), 231 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 18163e3..5afbd99 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -50,7 +50,7 @@
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
-                              "Intel(R) 10 Gigabit PCI Express Network Driver";
+			      "Intel(R) 10 Gigabit PCI Express Network Driver";
 
 #define DRV_VERSION "2.0.84-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
@@ -120,7 +120,7 @@ MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
 #ifdef CONFIG_IXGBE_DCA
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
-                            void *p);
+			    void *p);
 static struct notifier_block dca_notifier = {
 	.notifier_call = ixgbe_notify_dca,
 	.next          = NULL,
@@ -131,8 +131,8 @@ static struct notifier_block dca_notifier = {
 #ifdef CONFIG_PCI_IOV
 static unsigned int max_vfs;
 module_param(max_vfs, uint, 0);
-MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate "
-                 "per physical function");
+MODULE_PARM_DESC(max_vfs,
+		 "Maximum number of virtual functions to allocate per physical function");
 #endif /* CONFIG_PCI_IOV */
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -169,8 +169,8 @@ static inline void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 
 	/* take a breather then clean up driver data */
 	msleep(100);
-	if (adapter->vfinfo)
-		kfree(adapter->vfinfo);
+
+	kfree(adapter->vfinfo);
 	adapter->vfinfo = NULL;
 
 	adapter->num_vfs = 0;
@@ -523,7 +523,7 @@ static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
 	/* Let firmware take over control of h/w */
 	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-	                ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
 static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
@@ -533,7 +533,7 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
 	/* Let firmware know the driver has taken over */
 	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-	                ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
+			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
 /*
@@ -545,7 +545,7 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
  *
  */
 static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, s8 direction,
-	                   u8 queue, u8 msix_vector)
+			   u8 queue, u8 msix_vector)
 {
 	u32 ivar, index;
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -586,7 +586,7 @@ static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, s8 direction,
 }
 
 static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
-                                          u64 qmask)
+					  u64 qmask)
 {
 	u32 mask;
 
@@ -602,8 +602,8 @@ static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
 }
 
 void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
-                                      struct ixgbe_tx_buffer
-                                      *tx_buffer_info)
+				      struct ixgbe_tx_buffer
+				      *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
 		if (tx_buffer_info->mapped_as_page)
@@ -637,7 +637,7 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
  * Returns : true if in xon state (currently not paused)
  */
 static inline bool ixgbe_tx_xon_state(struct ixgbe_adapter *adapter,
-                                      struct ixgbe_ring *tx_ring)
+				      struct ixgbe_ring *tx_ring)
 {
 	u32 txoff = IXGBE_TFCS_TXOFF;
 
@@ -682,8 +682,8 @@ static inline bool ixgbe_tx_xon_state(struct ixgbe_adapter *adapter,
 }
 
 static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
-                                       struct ixgbe_ring *tx_ring,
-                                       unsigned int eop)
+				       struct ixgbe_ring *tx_ring,
+				       unsigned int eop)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 
@@ -732,7 +732,7 @@ static void ixgbe_tx_timeout(struct net_device *netdev);
  * @tx_ring: tx ring to clean
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
-                               struct ixgbe_ring *tx_ring)
+			       struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct net_device *netdev = adapter->netdev;
@@ -781,7 +781,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			}
 
 			ixgbe_unmap_and_free_tx_resource(adapter,
-			                                 tx_buffer_info);
+							 tx_buffer_info);
 
 			tx_desc->wb.status = 0;
 
@@ -798,7 +798,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
 	if (unlikely(count && netif_carrier_ok(netdev) &&
-	             (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
+		     (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
@@ -832,7 +832,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 #ifdef CONFIG_IXGBE_DCA
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-                                struct ixgbe_ring *rx_ring)
+				struct ixgbe_ring *rx_ring)
 {
 	u32 rxctrl;
 	int cpu = get_cpu();
@@ -846,13 +846,13 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
 			rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK_82599;
 			rxctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
-			           IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
+				   IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
 		}
 		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
 		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
 		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
-		            IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+			    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
 		rx_ring->cpu = cpu;
 	}
@@ -860,7 +860,7 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-                                struct ixgbe_ring *tx_ring)
+				struct ixgbe_ring *tx_ring)
 {
 	u32 txctrl;
 	int cpu = get_cpu();
@@ -878,7 +878,7 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(q));
 			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
 			txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
-			          IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
+				  IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
 			txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(q), txctrl);
 		}
@@ -946,9 +946,9 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
  * @rx_desc: rx descriptor
  **/
 static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
-                              struct sk_buff *skb, u8 status,
-                              struct ixgbe_ring *ring,
-                              union ixgbe_adv_rx_desc *rx_desc)
+			      struct sk_buff *skb, u8 status,
+			      struct ixgbe_ring *ring,
+			      union ixgbe_adv_rx_desc *rx_desc)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct napi_struct *napi = &q_vector->napi;
@@ -1016,7 +1016,7 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 }
 
 static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
-                                         struct ixgbe_ring *rx_ring, u32 val)
+					 struct ixgbe_ring *rx_ring, u32 val)
 {
 	/*
 	 * Force memory writes to complete before letting h/w
@@ -1033,8 +1033,8 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
  * @adapter: address of board private structure
  **/
 void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
-                            struct ixgbe_ring *rx_ring,
-                            int cleaned_count)
+			    struct ixgbe_ring *rx_ring,
+			    int cleaned_count)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1064,8 +1064,8 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			}
 
 			bi->page_dma = dma_map_page(&pdev->dev, bi->page,
-			                            bi->page_offset,
-			                            (PAGE_SIZE / 2),
+						    bi->page_offset,
+						    (PAGE_SIZE / 2),
 						    DMA_FROM_DEVICE);
 		}
 
@@ -1085,7 +1085,7 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		if (!bi->dma) {
 			bi->dma = dma_map_single(&pdev->dev,
 						 bi->skb->data,
-			                         rx_ring->rx_buf_len,
+						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
@@ -1127,8 +1127,8 @@ static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
 static inline u32 ixgbe_get_rsc_count(union ixgbe_adv_rx_desc *rx_desc)
 {
 	return (le32_to_cpu(rx_desc->wb.lower.lo_dword.data) &
-	        IXGBE_RXDADV_RSCCNT_MASK) >>
-	        IXGBE_RXDADV_RSCCNT_SHIFT;
+		IXGBE_RXDADV_RSCCNT_MASK) >>
+		IXGBE_RXDADV_RSCCNT_SHIFT;
 }
 
 /**
@@ -1141,7 +1141,7 @@ static inline u32 ixgbe_get_rsc_count(union ixgbe_adv_rx_desc *rx_desc)
  * turns it into the frag list owner.
  **/
 static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb,
-                                                        u64 *count)
+							u64 *count)
 {
 	unsigned int frag_list_size = 0;
 
@@ -1169,8 +1169,8 @@ struct ixgbe_rsc_cb {
 #define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
 
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
-                               struct ixgbe_ring *rx_ring,
-                               int *work_done, int work_to_do)
+			       struct ixgbe_ring *rx_ring,
+			       int *work_done, int work_to_do)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct net_device *netdev = adapter->netdev;
@@ -1232,9 +1232,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
 			} else {
 				dma_unmap_single(&pdev->dev,
-				                 rx_buffer_info->dma,
-				                 rx_ring->rx_buf_len,
-				                 DMA_FROM_DEVICE);
+						 rx_buffer_info->dma,
+						 rx_ring->rx_buf_len,
+						 DMA_FROM_DEVICE);
 			}
 			rx_buffer_info->dma = 0;
 			skb_put(skb, len);
@@ -1245,9 +1245,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-			                   rx_buffer_info->page,
-			                   rx_buffer_info->page_offset,
-			                   upper_len);
+					   rx_buffer_info->page,
+					   rx_buffer_info->page_offset,
+					   upper_len);
 
 			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
 			    (page_count(rx_buffer_info->page) != 1))
@@ -1281,18 +1281,20 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		if (staterr & IXGBE_RXD_STAT_EOP) {
 			if (skb->prev)
-				skb = ixgbe_transform_rsc_queue(skb, &(rx_ring->rsc_count));
+				skb = ixgbe_transform_rsc_queue(skb,
+								&(rx_ring->rsc_count));
 			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 				if (IXGBE_RSC_CB(skb)->delay_unmap) {
 					dma_unmap_single(&pdev->dev,
 							 IXGBE_RSC_CB(skb)->dma,
-					                 rx_ring->rx_buf_len,
+							 rx_ring->rx_buf_len,
 							 DMA_FROM_DEVICE);
 					IXGBE_RSC_CB(skb)->dma = 0;
 					IXGBE_RSC_CB(skb)->delay_unmap = false;
 				}
 				if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)
-					rx_ring->rsc_count += skb_shinfo(skb)->nr_frags;
+					rx_ring->rsc_count +=
+						skb_shinfo(skb)->nr_frags;
 				else
 					rx_ring->rsc_count++;
 				rx_ring->rsc_flush++;
@@ -1404,24 +1406,24 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		q_vector = adapter->q_vector[v_idx];
 		/* XXX for_each_set_bit(...) */
 		r_idx = find_first_bit(q_vector->rxr_idx,
-		                       adapter->num_rx_queues);
+				       adapter->num_rx_queues);
 
 		for (i = 0; i < q_vector->rxr_count; i++) {
 			j = adapter->rx_ring[r_idx]->reg_idx;
 			ixgbe_set_ivar(adapter, 0, j, v_idx);
 			r_idx = find_next_bit(q_vector->rxr_idx,
-			                      adapter->num_rx_queues,
-			                      r_idx + 1);
+					      adapter->num_rx_queues,
+					      r_idx + 1);
 		}
 		r_idx = find_first_bit(q_vector->txr_idx,
-		                       adapter->num_tx_queues);
+				       adapter->num_tx_queues);
 
 		for (i = 0; i < q_vector->txr_count; i++) {
 			j = adapter->tx_ring[r_idx]->reg_idx;
 			ixgbe_set_ivar(adapter, 1, j, v_idx);
 			r_idx = find_next_bit(q_vector->txr_idx,
-			                      adapter->num_tx_queues,
-			                      r_idx + 1);
+					      adapter->num_tx_queues,
+					      r_idx + 1);
 		}
 
 		if (q_vector->txr_count && !q_vector->rxr_count)
@@ -1436,7 +1438,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
 		ixgbe_set_ivar(adapter, -1, IXGBE_IVAR_OTHER_CAUSES_INDEX,
-		               v_idx);
+			       v_idx);
 	else if (adapter->hw.mac.type == ixgbe_mac_82599EB)
 		ixgbe_set_ivar(adapter, -1, 1, v_idx);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx), 1950);
@@ -1478,8 +1480,8 @@ enum latency_range {
  *      parameter (see ixgbe_param.c)
  **/
 static u8 ixgbe_update_itr(struct ixgbe_adapter *adapter,
-                           u32 eitr, u8 itr_setting,
-                           int packets, int bytes)
+			   u32 eitr, u8 itr_setting,
+			   int packets, int bytes)
 {
 	unsigned int retval = itr_setting;
 	u32 timepassed_us;
@@ -1568,30 +1570,30 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = adapter->tx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-		                           q_vector->tx_itr,
-		                           tx_ring->total_packets,
-		                           tx_ring->total_bytes);
+					   q_vector->tx_itr,
+					   tx_ring->total_packets,
+					   tx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
 		q_vector->tx_itr = ((q_vector->tx_itr > ret_itr) ?
-		                    q_vector->tx_itr - 1 : ret_itr);
+				    q_vector->tx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
 		rx_ring = adapter->rx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-		                           q_vector->rx_itr,
-		                           rx_ring->total_packets,
-		                           rx_ring->total_bytes);
+					   q_vector->rx_itr,
+					   rx_ring->total_packets,
+					   rx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
 		q_vector->rx_itr = ((q_vector->rx_itr > ret_itr) ?
-		                    q_vector->rx_itr - 1 : ret_itr);
+				    q_vector->rx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
@@ -1628,8 +1630,8 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 static void ixgbe_check_overtemp_task(struct work_struct *work)
 {
 	struct ixgbe_adapter *adapter = container_of(work,
-	                                             struct ixgbe_adapter,
-	                                             check_overtemp_task);
+						     struct ixgbe_adapter,
+						     check_overtemp_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr = adapter->interrupt_event;
 
@@ -1747,9 +1749,9 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 			netif_tx_stop_all_queues(netdev);
 			for (i = 0; i < adapter->num_tx_queues; i++) {
 				struct ixgbe_ring *tx_ring =
-				                            adapter->tx_ring[i];
+							    adapter->tx_ring[i];
 				if (test_and_clear_bit(__IXGBE_FDIR_INIT_DONE,
-				                       &tx_ring->reinit_state))
+						       &tx_ring->reinit_state))
 					schedule_work(&adapter->fdir_reinit_task);
 			}
 		}
@@ -1778,7 +1780,7 @@ static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
 }
 
 static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
-                                            u64 qmask)
+					    u64 qmask)
 {
 	u32 mask;
 
@@ -1810,7 +1812,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 		tx_ring->total_bytes = 0;
 		tx_ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	/* EIAM disabled interrupts (on this vector) for us */
@@ -1838,7 +1840,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 		rx_ring->total_bytes = 0;
 		rx_ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	if (!q_vector->rxr_count)
@@ -1868,7 +1870,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 		ring->total_bytes = 0;
 		ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
@@ -1877,7 +1879,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 		ring->total_bytes = 0;
 		ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	/* EIAM disabled interrupts (on this vector) for us */
@@ -1897,7 +1899,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
-	                       container_of(napi, struct ixgbe_q_vector, napi);
+			       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0;
@@ -1919,7 +1921,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
-			                        ((u64)1 << q_vector->v_idx));
+						((u64)1 << q_vector->v_idx));
 	}
 
 	return work_done;
@@ -1936,7 +1938,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
-	                       container_of(napi, struct ixgbe_q_vector, napi);
+			       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *ring = NULL;
 	int work_done = 0, i;
@@ -1952,7 +1954,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 #endif
 		tx_clean_complete &= ixgbe_clean_tx_irq(q_vector, ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
@@ -1968,7 +1970,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 #endif
 		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-		                      r_idx + 1);
+				      r_idx + 1);
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
@@ -1980,7 +1982,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
-			                        ((u64)1 << q_vector->v_idx));
+						((u64)1 << q_vector->v_idx));
 		return 0;
 	}
 
@@ -1998,7 +2000,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
-	                       container_of(napi, struct ixgbe_q_vector, napi);
+			       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *tx_ring = NULL;
 	int work_done = 0;
@@ -2020,14 +2022,15 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 		if (adapter->tx_itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
+			ixgbe_irq_enable_queues(adapter,
+						((u64)1 << q_vector->v_idx));
 	}
 
 	return work_done;
 }
 
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
-                                     int r_idx)
+				     int r_idx)
 {
 	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
 
@@ -2036,7 +2039,7 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
-                                     int t_idx)
+				     int t_idx)
 {
 	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
 
@@ -2056,7 +2059,7 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
  * mapping configurations in here.
  **/
 static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
-                                      int vectors)
+				      int vectors)
 {
 	int v_start = 0;
 	int rxr_idx = 0, txr_idx = 0;
@@ -2123,7 +2126,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	irqreturn_t (*handler)(int, void *);
 	int i, vector, q_vectors, err;
-	int ri=0, ti=0;
+	int ri = 0, ti = 0;
 
 	/* Decrement for Other and TCP Timer vectors */
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
@@ -2134,26 +2137,24 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		goto out;
 
 #define SET_HANDLER(_v) ((!(_v)->rxr_count) ? &ixgbe_msix_clean_tx : \
-                         (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
-                         &ixgbe_msix_clean_many)
+			 (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
+			 &ixgbe_msix_clean_many)
 	for (vector = 0; vector < q_vectors; vector++) {
 		handler = SET_HANDLER(adapter->q_vector[vector]);
 
-		if(handler == &ixgbe_msix_clean_rx) {
+		if (handler == &ixgbe_msix_clean_rx) {
 			sprintf(adapter->name[vector], "%s-%s-%d",
 				netdev->name, "rx", ri++);
-		}
-		else if(handler == &ixgbe_msix_clean_tx) {
+		} else if (handler == &ixgbe_msix_clean_tx) {
 			sprintf(adapter->name[vector], "%s-%s-%d",
 				netdev->name, "tx", ti++);
-		}
-		else
+		} else
 			sprintf(adapter->name[vector], "%s-%s-%d",
 				netdev->name, "TxRx", vector);
 
 		err = request_irq(adapter->msix_entries[vector].vector,
-		                  handler, 0, adapter->name[vector],
-		                  adapter->q_vector[vector]);
+				  handler, 0, adapter->name[vector],
+				  adapter->q_vector[vector]);
 		if (err) {
 			e_err(probe, "request_irq failed for MSIX interrupt "
 			      "Error: %d\n", err);
@@ -2163,7 +2164,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 
 	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-	                  ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
+			  ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {
 		e_err(probe, "request_irq for msix_lsc failed: %d\n", err);
 		goto free_queue_irqs;
@@ -2174,7 +2175,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 free_queue_irqs:
 	for (i = vector - 1; i >= 0; i--)
 		free_irq(adapter->msix_entries[--vector].vector,
-		         adapter->q_vector[i]);
+			 adapter->q_vector[i]);
 	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
@@ -2192,13 +2193,13 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *tx_ring = adapter->tx_ring[0];
 
 	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
-	                                    q_vector->tx_itr,
-	                                    tx_ring->total_packets,
-	                                    tx_ring->total_bytes);
+					    q_vector->tx_itr,
+					    tx_ring->total_packets,
+					    tx_ring->total_bytes);
 	q_vector->rx_itr = ixgbe_update_itr(adapter, new_itr,
-	                                    q_vector->rx_itr,
-	                                    rx_ring->total_packets,
-	                                    rx_ring->total_bytes);
+					    q_vector->rx_itr,
+					    rx_ring->total_packets,
+					    rx_ring->total_bytes);
 
 	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
 
@@ -2344,10 +2345,10 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 		err = ixgbe_request_msix_irqs(adapter);
 	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, 0,
-		                  netdev->name, netdev);
+				  netdev->name, netdev);
 	} else {
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, IRQF_SHARED,
-		                  netdev->name, netdev);
+				  netdev->name, netdev);
 	}
 
 	if (err)
@@ -2371,7 +2372,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		i--;
 		for (; i >= 0; i--) {
 			free_irq(adapter->msix_entries[i].vector,
-			         adapter->q_vector[i]);
+				 adapter->q_vector[i]);
 		}
 
 		ixgbe_reset_q_vectors(adapter);
@@ -2414,7 +2415,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
-	                EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr_param));
+			EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr_param));
 
 	ixgbe_set_ivar(adapter, 0, 0, 0);
 	ixgbe_set_ivar(adapter, 1, 0, 0);
@@ -2448,7 +2449,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_FLUSH(hw);
 
 	IXGBE_WRITE_REG(hw, IXGBE_TDBAL(reg_idx),
-	                (tdba & DMA_BIT_MASK(32)));
+			(tdba & DMA_BIT_MASK(32)));
 	IXGBE_WRITE_REG(hw, IXGBE_TDBAH(reg_idx), (tdba >> 32));
 	IXGBE_WRITE_REG(hw, IXGBE_TDLEN(reg_idx),
 			ring->count * sizeof(union ixgbe_adv_tx_desc));
@@ -2559,7 +2560,7 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT 2
 
 static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
-                                   struct ixgbe_ring *rx_ring)
+				   struct ixgbe_ring *rx_ring)
 {
 	u32 srrctl;
 	int index;
@@ -2601,8 +2602,8 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
-	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
-	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
+			  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
+			  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 mrqc = 0, reta = 0;
 	u32 rxcsum;
 	int i, j;
@@ -2813,10 +2814,10 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 
 	/* PSRTYPE must be initialized in non 82598 adapters */
 	u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
-	              IXGBE_PSRTYPE_UDPHDR |
-	              IXGBE_PSRTYPE_IPV4HDR |
+		      IXGBE_PSRTYPE_UDPHDR |
+		      IXGBE_PSRTYPE_IPV4HDR |
 		      IXGBE_PSRTYPE_L2HDR |
-	              IXGBE_PSRTYPE_IPV6HDR;
+		      IXGBE_PSRTYPE_IPV6HDR;
 
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
@@ -2931,15 +2932,14 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 			rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
 
 #ifdef IXGBE_FCOE
-		if (netdev->features & NETIF_F_FCOE_MTU)
-		{
+		if (netdev->features & NETIF_F_FCOE_MTU) {
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((i >= f->mask) && (i < f->mask + f->indices)) {
 				rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
 				if (rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE)
 					rx_ring->rx_buf_len =
-					        IXGBE_FCOE_JUMBO_FRAME_SIZE;
+						IXGBE_FCOE_JUMBO_FRAME_SIZE;
 			}
 		}
 #endif /* IXGBE_FCOE */
@@ -3128,7 +3128,7 @@ static void ixgbe_vlan_filter_enable(struct ixgbe_adapter *adapter)
 }
 
 static void ixgbe_vlan_rx_register(struct net_device *netdev,
-                                   struct vlan_group *grp)
+				   struct vlan_group *grp)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -3386,7 +3386,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			adapter->tx_ring[i]->atr_sample_rate =
-			                               adapter->atr_sample_rate;
+						       adapter->atr_sample_rate;
 		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
 	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
 		ixgbe_init_fdir_perfect_82599(hw, adapter->fdir_pballoc);
@@ -3464,7 +3464,8 @@ static int ixgbe_non_sfp_link_config(struct ixgbe_hw *hw)
 		goto link_cfg_out;
 
 	if (hw->mac.ops.get_link_capabilities)
-		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
+		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg,
+							&negotiation);
 	if (ret)
 		goto link_cfg_out;
 
@@ -3666,7 +3667,7 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
  * @rx_ring: ring to free buffers from
  **/
 static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
-                                struct ixgbe_ring *rx_ring)
+				struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
@@ -3683,7 +3684,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
 			dma_unmap_single(&pdev->dev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len,
+					 rx_ring->rx_buf_len,
 					 DMA_FROM_DEVICE);
 			rx_buffer_info->dma = 0;
 		}
@@ -3695,7 +3696,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 				if (IXGBE_RSC_CB(this)->delay_unmap) {
 					dma_unmap_single(&pdev->dev,
 							 IXGBE_RSC_CB(this)->dma,
-					                 rx_ring->rx_buf_len,
+							 rx_ring->rx_buf_len,
 							 DMA_FROM_DEVICE);
 					IXGBE_RSC_CB(this)->dma = 0;
 					IXGBE_RSC_CB(skb)->delay_unmap = false;
@@ -3737,7 +3738,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
  * @tx_ring: ring to be cleaned
  **/
 static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
-                                struct ixgbe_ring *tx_ring)
+				struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned long size;
@@ -3849,13 +3850,13 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
-		                (txdctl & ~IXGBE_TXDCTL_ENABLE));
+				(txdctl & ~IXGBE_TXDCTL_ENABLE));
 	}
 	/* Disable the Tx DMA engine on 82599 */
 	if (hw->mac.type == ixgbe_mac_82599EB)
 		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL,
-		                (IXGBE_READ_REG(hw, IXGBE_DMATXCTL) &
-		                 ~IXGBE_DMATXCTL_TE));
+				(IXGBE_READ_REG(hw, IXGBE_DMATXCTL) &
+				 ~IXGBE_DMATXCTL_TE));
 
 	/* power down the optics */
 	if (hw->phy.multispeed_fiber)
@@ -3885,7 +3886,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 static int ixgbe_poll(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
-	                        container_of(napi, struct ixgbe_q_vector, napi);
+				container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_clean_complete, work_done = 0;
 
@@ -3995,7 +3996,7 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
  * Rx load across CPUs using RSS.
  *
  **/
-static bool inline ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
+static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
 	struct ixgbe_ring_feature *f_fdir = &adapter->ring_feature[RING_F_FDIR];
@@ -4124,7 +4125,7 @@ done:
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
-                                       int vectors)
+				       int vectors)
 {
 	int err, vector_threshold;
 
@@ -4143,7 +4144,7 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 	 */
 	while (vectors >= vector_threshold) {
 		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-		                      vectors);
+				      vectors);
 		if (!err) /* Success in acquiring all requested vectors. */
 			break;
 		else if (err < 0)
@@ -4170,7 +4171,7 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		 * vectors we were allocated.
 		 */
 		adapter->num_msix_vectors = min(vectors,
-		                   adapter->max_msix_q_vectors + NON_Q_VECTORS);
+				   adapter->max_msix_q_vectors + NON_Q_VECTORS);
 	}
 }
 
@@ -4241,12 +4242,12 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 				}
 				for ( ; i < 5; i++) {
 					adapter->tx_ring[i]->reg_idx =
-					                         ((i + 2) << 4);
+								 ((i + 2) << 4);
 					adapter->rx_ring[i]->reg_idx = i << 4;
 				}
 				for ( ; i < dcb_i; i++) {
 					adapter->tx_ring[i]->reg_idx =
-					                         ((i + 8) << 3);
+								 ((i + 8) << 3);
 					adapter->rx_ring[i]->reg_idx = i << 4;
 				}
 
@@ -4289,7 +4290,7 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
  * Cache the descriptor ring offsets for Flow Director to the assigned rings.
  *
  **/
-static bool inline ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
+static inline bool ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
 {
 	int i;
 	bool ret = false;
@@ -4446,7 +4447,7 @@ static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 			adapter->node = cur_node;
 		}
 		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
-		                    adapter->node);
+				    adapter->node);
 		if (!ring)
 			ring = kzalloc(sizeof(struct ixgbe_ring), GFP_KERNEL);
 		if (!ring)
@@ -4470,7 +4471,7 @@ static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 			adapter->node = cur_node;
 		}
 		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
-		                    adapter->node);
+				    adapter->node);
 		if (!ring)
 			ring = kzalloc(sizeof(struct ixgbe_ring), GFP_KERNEL);
 		if (!ring)
@@ -4516,7 +4517,7 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * (roughly) the same number of vectors as there are CPU's.
 	 */
 	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
-	               (int)num_online_cpus()) + NON_Q_VECTORS;
+		       (int)num_online_cpus()) + NON_Q_VECTORS;
 
 	/*
 	 * At the same time, hardware can only support a maximum of
@@ -4530,7 +4531,7 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */
 	adapter->msix_entries = kcalloc(v_budget,
-	                                sizeof(struct msix_entry), GFP_KERNEL);
+					sizeof(struct msix_entry), GFP_KERNEL);
 	if (adapter->msix_entries) {
 		for (vector = 0; vector < v_budget; vector++)
 			adapter->msix_entries[vector].entry = vector;
@@ -4592,10 +4593,10 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 
 	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
 		q_vector = kzalloc_node(sizeof(struct ixgbe_q_vector),
-		                        GFP_KERNEL, adapter->node);
+					GFP_KERNEL, adapter->node);
 		if (!q_vector)
 			q_vector = kzalloc(sizeof(struct ixgbe_q_vector),
-			                   GFP_KERNEL);
+					   GFP_KERNEL);
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
@@ -4756,8 +4757,8 @@ static void ixgbe_sfp_timer(unsigned long data)
 static void ixgbe_sfp_task(struct work_struct *work)
 {
 	struct ixgbe_adapter *adapter = container_of(work,
-	                                             struct ixgbe_adapter,
-	                                             sfp_task);
+						     struct ixgbe_adapter,
+						     sfp_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	if ((hw->phy.type == ixgbe_phy_nl) &&
@@ -4782,7 +4783,7 @@ static void ixgbe_sfp_task(struct work_struct *work)
 reschedule:
 	if (test_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state))
 		mod_timer(&adapter->sfp_timer,
-		          round_jiffies(jiffies + (2 * HZ)));
+			  round_jiffies(jiffies + (2 * HZ)));
 }
 
 /**
@@ -4838,7 +4839,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 			adapter->atr_sample_rate = 20;
 		}
 		adapter->ring_feature[RING_F_FDIR].indices =
-		                                         IXGBE_MAX_FDIR_INDICES;
+							 IXGBE_MAX_FDIR_INDICES;
 		adapter->fdir_pballoc = 0;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
@@ -4869,7 +4870,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.round_robin_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
-	                   adapter->ring_feature[RING_F_DCB].indices);
+			   adapter->ring_feature[RING_F_DCB].indices);
 
 #endif
 
@@ -4924,7 +4925,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
  * Return 0 on success, negative on failure
  **/
 int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-                             struct ixgbe_ring *tx_ring)
+			     struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
@@ -4991,7 +4992,7 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
  * Returns 0 on success, negative on failure
  **/
 int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-                             struct ixgbe_ring *rx_ring)
+			     struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
@@ -5064,7 +5065,7 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
  * Free all transmit software resources
  **/
 void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-                             struct ixgbe_ring *tx_ring)
+			     struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -5102,7 +5103,7 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
  * Free all receive software resources
  **/
 void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
-                             struct ixgbe_ring *rx_ring)
+			     struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -5406,7 +5407,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		u64 rsc_flush = 0;
 		for (i = 0; i < 16; i++)
 			adapter->hw_rx_no_dma_resources +=
-			                     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+					     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			rsc_count += adapter->rx_ring[i]->rsc_count;
 			rsc_flush += adapter->rx_ring[i]->rsc_flush;
@@ -5439,20 +5440,20 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		adapter->stats.qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
 		if (hw->mac.type == ixgbe_mac_82599EB) {
 			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
-			                                    IXGBE_PXONRXCNT(i));
+							    IXGBE_PXONRXCNT(i));
 			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
-			                                   IXGBE_PXOFFRXCNT(i));
+							   IXGBE_PXOFFRXCNT(i));
 			adapter->stats.qprdc[i] += IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		} else {
 			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
-			                                      IXGBE_PXONRXC(i));
+							      IXGBE_PXONRXC(i));
 			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
-			                                     IXGBE_PXOFFRXC(i));
+							     IXGBE_PXOFFRXC(i));
 		}
 		adapter->stats.pxontxc[i] += IXGBE_READ_REG(hw,
-		                                            IXGBE_PXONTXC(i));
+							    IXGBE_PXONTXC(i));
 		adapter->stats.pxofftxc[i] += IXGBE_READ_REG(hw,
-		                                             IXGBE_PXOFFTXC(i));
+							     IXGBE_PXOFFTXC(i));
 	}
 	adapter->stats.gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
 	/* work around hardware counting issue */
@@ -5462,13 +5463,15 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		u64 tmp;
 		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
-		tmp = IXGBE_READ_REG(hw, IXGBE_GORCH) & 0xF; /* 4 high bits of GORC */
+		tmp = IXGBE_READ_REG(hw, IXGBE_GORCH) & 0xF;
+						/* 4 high bits of GORC */
 		adapter->stats.gorc += (tmp << 32);
 		adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
-		tmp = IXGBE_READ_REG(hw, IXGBE_GOTCH) & 0xF; /* 4 high bits of GOTC */
+		tmp = IXGBE_READ_REG(hw, IXGBE_GOTCH) & 0xF;
+						/* 4 high bits of GOTC */
 		adapter->stats.gotc += (tmp << 32);
 		adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORL);
-		IXGBE_READ_REG(hw, IXGBE_TORH); /* to clear */
+		IXGBE_READ_REG(hw, IXGBE_TORH);	/* to clear */
 		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
 		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
 		adapter->stats.fdirmatch += IXGBE_READ_REG(hw, IXGBE_FDIRMATCH);
@@ -5533,7 +5536,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 	/* Rx Errors */
 	netdev->stats.rx_errors = adapter->stats.crcerrs +
-	                               adapter->stats.rlec;
+				       adapter->stats.rlec;
 	netdev->stats.rx_dropped = 0;
 	netdev->stats.rx_length_errors = adapter->stats.rlec;
 	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
@@ -5595,8 +5598,8 @@ watchdog_short_circuit:
 static void ixgbe_multispeed_fiber_task(struct work_struct *work)
 {
 	struct ixgbe_adapter *adapter = container_of(work,
-	                                             struct ixgbe_adapter,
-	                                             multispeed_fiber_task);
+						     struct ixgbe_adapter,
+						     multispeed_fiber_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 autoneg;
 	bool negotiation;
@@ -5619,8 +5622,8 @@ static void ixgbe_multispeed_fiber_task(struct work_struct *work)
 static void ixgbe_sfp_config_module_task(struct work_struct *work)
 {
 	struct ixgbe_adapter *adapter = container_of(work,
-	                                             struct ixgbe_adapter,
-	                                             sfp_config_module_task);
+						     struct ixgbe_adapter,
+						     sfp_config_module_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 err;
 
@@ -5653,15 +5656,15 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 static void ixgbe_fdir_reinit_task(struct work_struct *work)
 {
 	struct ixgbe_adapter *adapter = container_of(work,
-	                                             struct ixgbe_adapter,
-	                                             fdir_reinit_task);
+						     struct ixgbe_adapter,
+						     fdir_reinit_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
 	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			set_bit(__IXGBE_FDIR_INIT_DONE,
-			        &(adapter->tx_ring[i]->reinit_state));
+				&(adapter->tx_ring[i]->reinit_state));
 	} else {
 		e_err(probe, "failed to finish FDIR re-initialization, "
 		      "ignored adding FDIR ATR filters\n");
@@ -5679,8 +5682,8 @@ static DEFINE_MUTEX(ixgbe_watchdog_lock);
 static void ixgbe_watchdog_task(struct work_struct *work)
 {
 	struct ixgbe_adapter *adapter = container_of(work,
-	                                             struct ixgbe_adapter,
-	                                             watchdog_task);
+						     struct ixgbe_adapter,
+						     watchdog_task);
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 link_speed;
@@ -5711,7 +5714,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 
 		if (link_up ||
 		    time_after(jiffies, (adapter->link_check_timeout +
-		                         IXGBE_TRY_LINK_TIMEOUT))) {
+					 IXGBE_TRY_LINK_TIMEOUT))) {
 			adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
 			IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
 		}
@@ -5782,8 +5785,8 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
-                     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
-                     u32 tx_flags, u8 *hdr_len)
+		     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
+		     u32 tx_flags, u8 *hdr_len)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -5806,15 +5809,15 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			iph->tot_len = 0;
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-			                                         iph->daddr, 0,
-			                                         IPPROTO_TCP,
-			                                         0);
+								 iph->daddr, 0,
+								 IPPROTO_TCP,
+								 0);
 		} else if (skb_is_gso_v6(skb)) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-			                     &ipv6_hdr(skb)->daddr,
-			                     0, IPPROTO_TCP, 0);
+					     &ipv6_hdr(skb)->daddr,
+					     0, IPPROTO_TCP, 0);
 		}
 
 		i = tx_ring->next_to_use;
@@ -5827,7 +5830,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			vlan_macip_lens |=
 			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
 		vlan_macip_lens |= ((skb_network_offset(skb)) <<
-		                    IXGBE_ADVTXD_MACLEN_SHIFT);
+				    IXGBE_ADVTXD_MACLEN_SHIFT);
 		*hdr_len += skb_network_offset(skb);
 		vlan_macip_lens |=
 		    (skb_transport_header(skb) - skb_network_header(skb));
@@ -5838,7 +5841,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 
 		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
-		                   IXGBE_ADVTXD_DTYP_CTXT);
+				   IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->protocol == htons(ETH_P_IP))
 			type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
@@ -5867,8 +5870,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 }
 
 static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
-                          struct ixgbe_ring *tx_ring,
-                          struct sk_buff *skb, u32 tx_flags)
+			  struct ixgbe_ring *tx_ring,
+			  struct sk_buff *skb, u32 tx_flags)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -5885,16 +5888,16 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 			vlan_macip_lens |=
 			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
 		vlan_macip_lens |= (skb_network_offset(skb) <<
-		                    IXGBE_ADVTXD_MACLEN_SHIFT);
+				    IXGBE_ADVTXD_MACLEN_SHIFT);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			vlan_macip_lens |= (skb_transport_header(skb) -
-			                    skb_network_header(skb));
+					    skb_network_header(skb));
 
 		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
 		context_desc->seqnum_seed = 0;
 
 		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
-		                    IXGBE_ADVTXD_DTYP_CTXT);
+				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			__be16 protocol;
@@ -5913,19 +5916,19 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					type_tucmd_mlhl |=
-					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
+						IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				else if (ip_hdr(skb)->protocol == IPPROTO_SCTP)
 					type_tucmd_mlhl |=
-					        IXGBE_ADVTXD_TUCMD_L4T_SCTP;
+						IXGBE_ADVTXD_TUCMD_L4T_SCTP;
 				break;
 			case cpu_to_be16(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					type_tucmd_mlhl |=
-					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
+						IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				else if (ipv6_hdr(skb)->nexthdr == IPPROTO_SCTP)
 					type_tucmd_mlhl |=
-					        IXGBE_ADVTXD_TUCMD_L4T_SCTP;
+						IXGBE_ADVTXD_TUCMD_L4T_SCTP;
 				break;
 			default:
 				if (unlikely(net_ratelimit())) {
@@ -5956,9 +5959,9 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 }
 
 static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
-                        struct ixgbe_ring *tx_ring,
-                        struct sk_buff *skb, u32 tx_flags,
-                        unsigned int first)
+			struct ixgbe_ring *tx_ring,
+			struct sk_buff *skb, u32 tx_flags,
+			unsigned int first)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct ixgbe_tx_buffer *tx_buffer_info;
@@ -6053,7 +6056,7 @@ dma_error:
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
 	while (count--) {
-		if (i==0)
+		if (i == 0)
 			i += tx_ring->count;
 		i--;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
@@ -6064,8 +6067,8 @@ dma_error:
 }
 
 static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
-                           struct ixgbe_ring *tx_ring,
-                           int tx_flags, int count, u32 paylen, u8 hdr_len)
+			   struct ixgbe_ring *tx_ring,
+			   int tx_flags, int count, u32 paylen, u8 hdr_len)
 {
 	union ixgbe_adv_tx_desc *tx_desc = NULL;
 	struct ixgbe_tx_buffer *tx_buffer_info;
@@ -6084,17 +6087,17 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
 
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-		                 IXGBE_ADVTXD_POPTS_SHIFT;
+				 IXGBE_ADVTXD_POPTS_SHIFT;
 
 		/* use index 1 context for tso */
 		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
-			                 IXGBE_ADVTXD_POPTS_SHIFT;
+					 IXGBE_ADVTXD_POPTS_SHIFT;
 
 	} else if (tx_flags & IXGBE_TX_FLAGS_CSUM)
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-		                 IXGBE_ADVTXD_POPTS_SHIFT;
+				 IXGBE_ADVTXD_POPTS_SHIFT;
 
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
 		olinfo_status |= IXGBE_ADVTXD_CC;
@@ -6111,7 +6114,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
 		tx_desc->read.cmd_type_len =
-		        cpu_to_le32(cmd_type_len | tx_buffer_info->length);
+			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
 		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
 		i++;
 		if (i == tx_ring->count)
@@ -6133,7 +6136,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
-	              int queue, u32 tx_flags)
+		      int queue, u32 tx_flags)
 {
 	struct ixgbe_atr_input atr_input;
 	struct tcphdr *th;
@@ -6161,7 +6164,7 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 	memset(&atr_input, 0, sizeof(struct ixgbe_atr_input));
 
 	vlan_id = (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK) >>
-	           IXGBE_TX_FLAGS_VLAN_SHIFT;
+		   IXGBE_TX_FLAGS_VLAN_SHIFT;
 	src_ipv4_addr = iph->saddr;
 	dst_ipv4_addr = iph->daddr;
 	flex_bytes = eth->h_proto;
@@ -6180,7 +6183,7 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 }
 
 static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
-                                 struct ixgbe_ring *tx_ring, int size)
+				 struct ixgbe_ring *tx_ring, int size)
 {
 	netif_stop_subqueue(netdev, tx_ring->queue_index);
 	/* Herbert's original patch had:
@@ -6200,7 +6203,7 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 }
 
 static int ixgbe_maybe_stop_tx(struct net_device *netdev,
-                              struct ixgbe_ring *tx_ring, int size)
+			      struct ixgbe_ring *tx_ring, int size)
 {
 	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
 		return 0;
@@ -6343,10 +6346,10 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 		if (tx_ring->atr_sample_rate) {
 			++tx_ring->atr_count;
 			if ((tx_ring->atr_count >= tx_ring->atr_sample_rate) &&
-		             test_bit(__IXGBE_FDIR_INIT_DONE,
-                                      &tx_ring->reinit_state)) {
+			     test_bit(__IXGBE_FDIR_INIT_DONE,
+				      &tx_ring->reinit_state)) {
 				ixgbe_atr(adapter, skb, tx_ring->queue_index,
-				          tx_flags);
+					  tx_flags);
 				tx_ring->atr_count = 0;
 			}
 		}
@@ -6354,7 +6357,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 		txq->tx_bytes += skb->len;
 		txq->tx_packets++;
 		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
-		               hdr_len);
+			       hdr_len);
 		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
 
 	} else {
@@ -6506,7 +6509,7 @@ static void ixgbe_netpoll(struct net_device *netdev)
 #endif
 
 static const struct net_device_ops ixgbe_netdev_ops = {
-	.ndo_open 		= ixgbe_open,
+	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_select_queue	= ixgbe_select_queue,
@@ -6601,7 +6604,7 @@ err_novfs:
  * and a hardware reset occur.
  **/
 static int __devinit ixgbe_probe(struct pci_dev *pdev,
-                                 const struct pci_device_id *ent)
+				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct ixgbe_adapter *adapter = NULL;
@@ -6646,7 +6649,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-	                                   IORESOURCE_MEM), ixgbe_driver_name);
+					   IORESOURCE_MEM), ixgbe_driver_name);
 	if (err) {
 		dev_err(&pdev->dev,
 			"pci_request_selected_regions failed 0x%x\n", err);
@@ -6686,7 +6689,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
-	                      pci_resource_len(pdev, 0));
+			      pci_resource_len(pdev, 0));
 	if (!hw->hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
@@ -6740,7 +6743,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* a new SFP+ module arrival, called from GPI SDP2 context */
 	INIT_WORK(&adapter->sfp_config_module_task,
-	          ixgbe_sfp_config_module_task);
+		  ixgbe_sfp_config_module_task);
 
 	ii->get_invariants(hw);
 
@@ -6792,10 +6795,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	ixgbe_probe_vf(adapter, ii);
 
 	netdev->features = NETIF_F_SG |
-	                   NETIF_F_IP_CSUM |
-	                   NETIF_F_HW_VLAN_TX |
-	                   NETIF_F_HW_VLAN_RX |
-	                   NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_IP_CSUM |
+			   NETIF_F_HW_VLAN_TX |
+			   NETIF_F_HW_VLAN_RX |
+			   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
@@ -6875,7 +6878,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	switch (pdev->device) {
 	case IXGBE_DEV_ID_82599_KX4:
 		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
-		                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+				IXGBE_WUFC_MC | IXGBE_WUFC_BC);
 		break;
 	default:
 		adapter->wol = 0;
@@ -6888,13 +6891,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* print bus type/speed/width info */
 	e_dev_info("(PCI Express:%s:%s) %pM\n",
-	        ((hw->bus.speed == ixgbe_bus_speed_5000) ? "5.0Gb/s":
-	         (hw->bus.speed == ixgbe_bus_speed_2500) ? "2.5Gb/s":"Unknown"),
-	        ((hw->bus.width == ixgbe_bus_width_pcie_x8) ? "Width x8" :
-	         (hw->bus.width == ixgbe_bus_width_pcie_x4) ? "Width x4" :
-	         (hw->bus.width == ixgbe_bus_width_pcie_x1) ? "Width x1" :
-	         "Unknown"),
-	        netdev->dev_addr);
+		   (hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0Gb/s" :
+		    hw->bus.speed == ixgbe_bus_speed_2500 ? "2.5Gb/s" :
+		    "Unknown"),
+		   (hw->bus.width == ixgbe_bus_width_pcie_x8 ? "Width x8" :
+		    hw->bus.width == ixgbe_bus_width_pcie_x4 ? "Width x4" :
+		    hw->bus.width == ixgbe_bus_width_pcie_x1 ? "Width x1" :
+		    "Unknown"),
+		   netdev->dev_addr);
 	ixgbe_read_pba_num_generic(hw, &part_num);
 	if (ixgbe_is_sfp(hw) && hw->phy.sfp_type != ixgbe_sfp_type_not_present)
 		e_dev_info("MAC: %d, PHY: %d, SFP+: %d, "
@@ -6941,7 +6945,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		INIT_WORK(&adapter->fdir_reinit_task, ixgbe_fdir_reinit_task);
 
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		INIT_WORK(&adapter->check_overtemp_task, ixgbe_check_overtemp_task);
+		INIT_WORK(&adapter->check_overtemp_task,
+			  ixgbe_check_overtemp_task);
 #ifdef CONFIG_IXGBE_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
@@ -6977,8 +6982,8 @@ err_eeprom:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_selected_regions(pdev, pci_select_bars(pdev,
-	                             IORESOURCE_MEM));
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -7045,7 +7050,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	iounmap(adapter->hw.hw_addr);
 	pci_release_selected_regions(pdev, pci_select_bars(pdev,
-	                             IORESOURCE_MEM));
+				     IORESOURCE_MEM));
 
 	e_dev_info("complete\n");
 
@@ -7065,7 +7070,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
  * this device has been detected.
  */
 static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
-                                                pci_channel_state_t state)
+						pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -7201,12 +7206,12 @@ static void __exit ixgbe_exit_module(void)
 
 #ifdef CONFIG_IXGBE_DCA
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
-                            void *p)
+			    void *p)
 {
 	int ret_val;
 
 	ret_val = driver_for_each_device(&ixgbe_driver.driver, NULL, &event,
-	                                 __ixgbe_notify_dca);
+					 __ixgbe_notify_dca);
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
-- 
1.7.2.19.g9a302
