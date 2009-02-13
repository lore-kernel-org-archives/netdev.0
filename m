From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/6] igb: misc whitespace/formatting cleanups
Date: Thu, 12 Feb 2009 20:16:59 -0800
Message-ID: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:38463 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754429AbZBMERV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 23:17:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is intended to hold several whitespace, formatting, and
comment cleanups that have been found while cleaning up the igb driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   58 +++++++++++++++-----------------------------
 1 files changed, 20 insertions(+), 38 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f8c2919..1e7678c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1566,7 +1566,6 @@ static int igb_close(struct net_device *netdev)
  *
  * Return 0 on success, negative on failure
  **/
-
 int igb_setup_tx_resources(struct igb_adapter *adapter,
 			   struct igb_ring *tx_ring)
 {
@@ -1646,13 +1645,13 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 	int i, j;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct igb_ring *ring = &(adapter->tx_ring[i]);
+		struct igb_ring *ring = &adapter->tx_ring[i];
 		j = ring->reg_idx;
 		wr32(E1000_TDLEN(j),
-				ring->count * sizeof(struct e1000_tx_desc));
+		     ring->count * sizeof(struct e1000_tx_desc));
 		tdba = ring->dma;
 		wr32(E1000_TDBAL(j),
-				tdba & 0x00000000ffffffffULL);
+		     tdba & 0x00000000ffffffffULL);
 		wr32(E1000_TDBAH(j), tdba >> 32);
 
 		ring->head = E1000_TDH(j);
@@ -1672,8 +1671,6 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 		wr32(E1000_DCA_TXCTRL(j), txctrl);
 	}
 
-
-
 	/* Use the default values for the Tx Inter Packet Gap (IPG) timer */
 
 	/* Program the Transmit Control Register */
@@ -1701,7 +1698,6 @@ static void igb_configure_tx(struct igb_adapter *adapter)
  *
  * Returns 0 on success, negative on failure
  **/
-
 int igb_setup_rx_resources(struct igb_adapter *adapter,
 			   struct igb_ring *rx_ring)
 {
@@ -1788,7 +1784,7 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	 * enable stripping of CRC. It's unlikely this will break BMC
 	 * redirection as it did with e1000. Newer features require
 	 * that the HW strips the CRC.
-	*/
+	 */
 	rctl |= E1000_RCTL_SECRC;
 
 	/*
@@ -1866,14 +1862,14 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct igb_ring *ring = &(adapter->rx_ring[i]);
+		struct igb_ring *ring = &adapter->rx_ring[i];
 		j = ring->reg_idx;
 		rdba = ring->dma;
 		wr32(E1000_RDBAL(j),
-				rdba & 0x00000000ffffffffULL);
+		     rdba & 0x00000000ffffffffULL);
 		wr32(E1000_RDBAH(j), rdba >> 32);
 		wr32(E1000_RDLEN(j),
-			       ring->count * sizeof(union e1000_adv_rx_desc));
+		     ring->count * sizeof(union e1000_adv_rx_desc));
 
 		ring->head = E1000_RDH(j);
 		ring->tail = E1000_RDT(j);
@@ -2011,6 +2007,7 @@ static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
 		buffer_info->skb = NULL;
 	}
 	buffer_info->time_stamp = 0;
+	buffer_info->next_to_watch = 0;
 	/* buffer_info must be completely set up in the transmit path */
 }
 
@@ -2576,15 +2573,13 @@ static void igb_set_itr(struct igb_adapter *adapter)
 					    adapter->tx_itr,
 					    adapter->tx_ring->total_packets,
 					    adapter->tx_ring->total_bytes);
-
 		current_itr = max(adapter->rx_itr, adapter->tx_itr);
 	} else {
 		current_itr = adapter->rx_itr;
 	}
 
 	/* conservative mode (itr 3) eliminates the lowest_latency setting */
-	if (adapter->itr_setting == 3 &&
-	    current_itr == lowest_latency)
+	if (adapter->itr_setting == 3 && current_itr == lowest_latency)
 		current_itr = low_latency;
 
 	switch (current_itr) {
@@ -2701,7 +2696,7 @@ static inline int igb_tso_adv(struct igb_adapter *adapter,
 	mss_l4len_idx = (skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIFT);
 	mss_l4len_idx |= (l4len << E1000_ADVTXD_L4LEN_SHIFT);
 
-	/* Context index must be unique per ring. */
+	/* For 82575, context index must be unique per ring. */
 	if (adapter->flags & IGB_FLAG_NEED_CTX_IDX)
 		mss_l4len_idx |= tx_ring->queue_index << 4;
 
@@ -2785,8 +2780,6 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 
 		return true;
 	}
-
-
 	return false;
 }
 
@@ -2984,7 +2977,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		tx_flags |= IGB_TX_FLAGS_IPV4;
 
 	first = tx_ring->next_to_use;
-
 	tso = skb_is_gso(skb) ? igb_tso_adv(adapter, tx_ring, skb, tx_flags,
 					      &hdr_len) : 0;
 
@@ -3058,8 +3050,7 @@ static void igb_reset_task(struct work_struct *work)
  * Returns the address of the device statistics structure.
  * The statistics are actually updated from the timer callback.
  **/
-static struct net_device_stats *
-igb_get_stats(struct net_device *netdev)
+static struct net_device_stats *igb_get_stats(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
@@ -3093,6 +3084,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 
 	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
 		msleep(1);
+
 	/* igb_down has a dependency on max_frame_size */
 	adapter->max_frame_size = max_frame;
 	if (netif_running(netdev))
@@ -3262,8 +3254,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	/* Phy Stats */
 	if (hw->phy.media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
-		   (!igb_read_phy_reg(hw, PHY_1000T_STATUS,
-					      &phy_tmp))) {
+		   (!igb_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
 			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
 			adapter->phy_stats.idle_errors += phy_tmp;
 		}
@@ -3275,7 +3266,6 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.mgpdc += rd32(E1000_MGTPDC);
 }
 
-
 static irqreturn_t igb_msix_other(int irq, void *data)
 {
 	struct net_device *netdev = data;
@@ -3313,6 +3303,7 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(tx_ring);
 #endif
+
 	tx_ring->total_bytes = 0;
 	tx_ring->total_packets = 0;
 
@@ -3333,13 +3324,11 @@ static void igb_write_itr(struct igb_ring *ring)
 	if ((ring->adapter->itr_setting & 3) && ring->set_itr) {
 		switch (hw->mac.type) {
 		case e1000_82576:
-			wr32(ring->itr_register,
-			     ring->itr_val |
+			wr32(ring->itr_register, ring->itr_val |
 			     0x80000000);
 			break;
 		default:
-			wr32(ring->itr_register,
-			     ring->itr_val |
+			wr32(ring->itr_register, ring->itr_val |
 			     (ring->itr_val << 16));
 			break;
 		}
@@ -3610,7 +3599,6 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 #endif
 	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
 
-
 	/* If not enough Rx work done, exit the polling mode */
 	if ((work_done == 0) || !netif_running(netdev)) {
 		napi_complete(napi);
@@ -3621,7 +3609,6 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 			else
 				igb_update_ring_itr(rx_ring);
 		}
-
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			wr32(E1000_EIMS, rx_ring->eims_value);
 
@@ -3678,7 +3665,6 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 			if (i == tx_ring->count)
 				i = 0;
 		}
-
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
 	}
@@ -3747,7 +3733,7 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
  * igb_receive_skb - helper function to handle rx indications
  * @ring: pointer to receive ring receving this packet
  * @status: descriptor status field as written by hardware
- * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
+ * @rx_desc: receive descriptor containing vlan and type information.
  * @skb: pointer to sk_buff to be indicated to stack
  **/
 static void igb_receive_skb(struct igb_ring *ring, u8 status,
@@ -3774,7 +3760,6 @@ static void igb_receive_skb(struct igb_ring *ring, u8 status,
 	}
 }
 
-
 static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 				       u32 status_err, struct sk_buff *skb)
 {
@@ -3806,11 +3791,11 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
 	struct igb_buffer *buffer_info , *next_buffer;
 	struct sk_buff *skb;
-	unsigned int i;
-	u32 length, hlen, staterr;
 	bool cleaned = false;
 	int cleaned_count = 0;
 	unsigned int total_bytes = 0, total_packets = 0;
+	unsigned int i;
+	u32 length, hlen, staterr;
 
 	i = rx_ring->next_to_clean;
 	buffer_info = &rx_ring->buffer_info[i];
@@ -3858,8 +3843,7 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 
 		if (!skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, buffer_info->dma,
-					 adapter->rx_ps_hdr_size +
-					   NET_IP_ALIGN,
+					 adapter->rx_ps_hdr_size + NET_IP_ALIGN,
 					 PCI_DMA_FROMDEVICE);
 			skb_put(skb, hlen);
 		}
@@ -3938,7 +3922,6 @@ next_desc:
 	return cleaned;
 }
 
-
 /**
  * igb_alloc_rx_buffers_adv - Replace used receive buffers; packet split
  * @adapter: address of board private structure
@@ -4227,7 +4210,6 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 	return 0;
 }
 
-
 static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);

