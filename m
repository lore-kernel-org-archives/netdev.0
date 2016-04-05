From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/15] fm10k: cleanup remaining right-bit-shifted 1
Date: Tue,  5 Apr 2016 13:02:14 -0700
Message-ID: <1459886547-146445-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56320 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759880AbcDEUCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:02:31 -0400
In-Reply-To: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Use BIT() macro instead.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 12 ++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 20 +++++++++-----------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 20 ++++++++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  8 ++++----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 12 ++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c     | 24 ++++++++++++------------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |  8 ++++----
 8 files changed, 52 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index b34bb00..83f3867 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -262,12 +262,12 @@ struct fm10k_intfc {
 	unsigned long state;
 
 	u32 flags;
-#define FM10K_FLAG_RESET_REQUESTED		(u32)(1 << 0)
-#define FM10K_FLAG_RSS_FIELD_IPV4_UDP		(u32)(1 << 1)
-#define FM10K_FLAG_RSS_FIELD_IPV6_UDP		(u32)(1 << 2)
-#define FM10K_FLAG_RX_TS_ENABLED		(u32)(1 << 3)
-#define FM10K_FLAG_SWPRI_CONFIG			(u32)(1 << 4)
-#define FM10K_FLAG_DEBUG_STATS			(u32)(1 << 5)
+#define FM10K_FLAG_RESET_REQUESTED		(u32)(BIT(0))
+#define FM10K_FLAG_RSS_FIELD_IPV4_UDP		(u32)(BIT(1))
+#define FM10K_FLAG_RSS_FIELD_IPV6_UDP		(u32)(BIT(2))
+#define FM10K_FLAG_RX_TS_ENABLED		(u32)(BIT(3))
+#define FM10K_FLAG_SWPRI_CONFIG			(u32)(BIT(4))
+#define FM10K_FLAG_DEBUG_STATS			(u32)(BIT(5))
 	int xcast_mode;
 
 	/* Tx fast path data */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 2f6a05b..28837ae 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -425,7 +425,7 @@ static void fm10k_get_regs(struct net_device *netdev,
 	u32 *buff = p;
 	u16 i;
 
-	regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
+	regs->version = BIT(24) | (hw->revision_id << 16) | hw->device_id;
 
 	switch (hw->mac.type) {
 	case fm10k_mac_pf:
@@ -942,8 +942,8 @@ static int fm10k_mbx_test(struct fm10k_intfc *interface, u64 *data)
 		return 0;
 
 	/* loop through both nested and unnested attribute types */
-	for (attr_flag = (1 << FM10K_TEST_MSG_UNSET);
-	     attr_flag < (1 << (2 * FM10K_TEST_MSG_NESTED));
+	for (attr_flag = BIT(FM10K_TEST_MSG_UNSET);
+	     attr_flag < BIT(2 * FM10K_TEST_MSG_NESTED);
 	     attr_flag += attr_flag) {
 		/* generate message to be tested */
 		fm10k_tlv_msg_test_create(test_msg, attr_flag);
@@ -1005,7 +1005,7 @@ static u32 fm10k_get_priv_flags(struct net_device *netdev)
 	u32 priv_flags = 0;
 
 	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
-		priv_flags |= 1 << FM10K_PRV_FLAG_DEBUG_STATS;
+		priv_flags |= BIT(FM10K_PRV_FLAG_DEBUG_STATS);
 
 	return priv_flags;
 }
@@ -1014,10 +1014,10 @@ static int fm10k_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 
-	if (priv_flags >= (1 << FM10K_PRV_FLAG_LEN))
+	if (priv_flags >= BIT(FM10K_PRV_FLAG_LEN))
 		return -EINVAL;
 
-	if (priv_flags & (1 << FM10K_PRV_FLAG_DEBUG_STATS))
+	if (priv_flags & BIT(FM10K_PRV_FLAG_DEBUG_STATS))
 		interface->flags |= FM10K_FLAG_DEBUG_STATS;
 	else
 		interface->flags &= ~FM10K_FLAG_DEBUG_STATS;
@@ -1145,7 +1145,7 @@ static unsigned int fm10k_max_channels(struct net_device *dev)
 
 	/* For QoS report channels per traffic class */
 	if (tcs > 1)
-		max_combined = 1 << (fls(max_combined / tcs) - 1);
+		max_combined = BIT((fls(max_combined / tcs) - 1));
 
 	return max_combined;
 }
@@ -1210,11 +1210,9 @@ static int fm10k_get_ts_info(struct net_device *dev,
 	else
 		info->phc_index = -1;
 
-	info->tx_types = (1 << HWTSTAMP_TX_OFF) |
-			 (1 << HWTSTAMP_TX_ON);
+	info->tx_types = BIT(HWTSTAMP_TX_OFF) | BIT(HWTSTAMP_TX_ON);
 
-	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
-			   (1 << HWTSTAMP_FILTER_ALL);
+	info->rx_filters = BIT(HWTSTAMP_FILTER_NONE) | BIT(HWTSTAMP_FILTER_ALL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index d411aa5..db4353b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -401,10 +401,10 @@ static inline void fm10k_rx_checksum(struct fm10k_ring *ring,
 }
 
 #define FM10K_RSS_L4_TYPES_MASK \
-	((1ul << FM10K_RSSTYPE_IPV4_TCP) | \
-	 (1ul << FM10K_RSSTYPE_IPV4_UDP) | \
-	 (1ul << FM10K_RSSTYPE_IPV6_TCP) | \
-	 (1ul << FM10K_RSSTYPE_IPV6_UDP))
+	(BIT(FM10K_RSSTYPE_IPV4_TCP) | \
+	 BIT(FM10K_RSSTYPE_IPV4_UDP) | \
+	 BIT(FM10K_RSSTYPE_IPV6_TCP) | \
+	 BIT(FM10K_RSSTYPE_IPV6_UDP))
 
 static inline void fm10k_rx_hash(struct fm10k_ring *ring,
 				 union fm10k_rx_desc *rx_desc,
@@ -420,7 +420,7 @@ static inline void fm10k_rx_hash(struct fm10k_ring *ring,
 		return;
 
 	skb_set_hash(skb, le32_to_cpu(rx_desc->d.rss),
-		     ((1ul << rss_type) & FM10K_RSS_L4_TYPES_MASK) ?
+		     (BIT(rss_type) & FM10K_RSS_L4_TYPES_MASK) ?
 		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 }
 
@@ -1409,7 +1409,7 @@ static void fm10k_update_itr(struct fm10k_ring_container *ring_container)
 	 * accounts for changes in the ITR due to PCIe link speed.
 	 */
 	itr_round = ACCESS_ONCE(ring_container->itr_scale) + 8;
-	avg_wire_size += (1 << itr_round) - 1;
+	avg_wire_size += BIT(itr_round) - 1;
 	avg_wire_size >>= itr_round;
 
 	/* write back value and retain adaptive flag */
@@ -1511,17 +1511,17 @@ static bool fm10k_set_qos_queues(struct fm10k_intfc *interface)
 	/* set QoS mask and indices */
 	f = &interface->ring_feature[RING_F_QOS];
 	f->indices = pcs;
-	f->mask = (1 << fls(pcs - 1)) - 1;
+	f->mask = BIT(fls(pcs - 1)) - 1;
 
 	/* determine the upper limit for our current DCB mode */
 	rss_i = interface->hw.mac.max_queues / pcs;
-	rss_i = 1 << (fls(rss_i) - 1);
+	rss_i = BIT(fls(rss_i) - 1);
 
 	/* set RSS mask and indices */
 	f = &interface->ring_feature[RING_F_RSS];
 	rss_i = min_t(u16, rss_i, f->limit);
 	f->indices = rss_i;
-	f->mask = (1 << fls(rss_i - 1)) - 1;
+	f->mask = BIT(fls(rss_i - 1)) - 1;
 
 	/* configure pause class to queue mapping */
 	for (i = 0; i < pcs; i++)
@@ -1551,7 +1551,7 @@ static bool fm10k_set_rss_queues(struct fm10k_intfc *interface)
 
 	/* record indices and power of 2 mask for RSS */
 	f->indices = rss_i;
-	f->mask = (1 << fls(rss_i - 1)) - 1;
+	f->mask = BIT(fls(rss_i - 1)) - 1;
 
 	interface->num_rx_queues = rss_i;
 	interface->num_tx_queues = rss_i;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index d09a8dd..0ff6874 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1429,7 +1429,7 @@ struct net_device *fm10k_alloc_netdev(const struct fm10k_info *info)
 
 	/* configure default debug level */
 	interface = netdev_priv(dev);
-	interface->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	interface->msg_enable = BIT(DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
 
 	/* configure default features */
 	dev->features |= NETIF_F_IP_CSUM |
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 86700a4..c9324c7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -579,7 +579,7 @@ static void fm10k_configure_tx_ring(struct fm10k_intfc *interface,
 	u64 tdba = ring->dma;
 	u32 size = ring->count * sizeof(struct fm10k_tx_desc);
 	u32 txint = FM10K_INT_MAP_DISABLE;
-	u32 txdctl = (1 << FM10K_TXDCTL_MAX_TIME_SHIFT) | FM10K_TXDCTL_ENABLE;
+	u32 txdctl = BIT(FM10K_TXDCTL_MAX_TIME_SHIFT) | FM10K_TXDCTL_ENABLE;
 	u8 reg_idx = ring->reg_idx;
 
 	/* disable queue to avoid issues while updating state */
@@ -730,7 +730,7 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	if (interface->pfc_en)
 		rx_pause = interface->pfc_en;
 #endif
-	if (!(rx_pause & (1 << ring->qos_pc)))
+	if (!(rx_pause & BIT(ring->qos_pc)))
 		rxdctl |= FM10K_RXDCTL_DROP_ON_EMPTY;
 
 	fm10k_write_reg(hw, FM10K_RXDCTL(reg_idx), rxdctl);
@@ -779,7 +779,7 @@ void fm10k_update_rx_drop_en(struct fm10k_intfc *interface)
 		u32 rxdctl = FM10K_RXDCTL_WRITE_BACK_MIN_DELAY;
 		u8 reg_idx = ring->reg_idx;
 
-		if (!(rx_pause & (1 << ring->qos_pc)))
+		if (!(rx_pause & BIT(ring->qos_pc)))
 			rxdctl |= FM10K_RXDCTL_DROP_ON_EMPTY;
 
 		fm10k_write_reg(hw, FM10K_RXDCTL(reg_idx), rxdctl);
@@ -1065,7 +1065,7 @@ static void fm10k_reset_drop_on_empty(struct fm10k_intfc *interface, u32 eicr)
 	if (maxholdq)
 		fm10k_write_reg(hw, FM10K_MAXHOLDQ(7), maxholdq);
 	for (q = 255;;) {
-		if (maxholdq & (1 << 31)) {
+		if (maxholdq & BIT(31)) {
 			if (q < FM10K_MAX_QUEUES_PF) {
 				interface->rx_overrun_pf++;
 				fm10k_write_reg(hw, FM10K_RXDCTL(q), rxdctl);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 34a0b03..23de956 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -527,8 +527,8 @@ static s32 fm10k_configure_dglort_map_pf(struct fm10k_hw *hw,
 		return FM10K_ERR_PARAM;
 
 	/* determine count of VSIs and queues */
-	queue_count = 1 << (dglort->rss_l + dglort->pc_l);
-	vsi_count = 1 << (dglort->vsi_l + dglort->queue_l);
+	queue_count = BIT(dglort->rss_l + dglort->pc_l);
+	vsi_count = BIT(dglort->vsi_l + dglort->queue_l);
 	glort = dglort->glort;
 	q_idx = dglort->queue_b;
 
@@ -544,8 +544,8 @@ static s32 fm10k_configure_dglort_map_pf(struct fm10k_hw *hw,
 	}
 
 	/* determine count of PCs and queues */
-	queue_count = 1 << (dglort->queue_l + dglort->rss_l + dglort->vsi_l);
-	pc_count = 1 << dglort->pc_l;
+	queue_count = BIT(dglort->queue_l + dglort->rss_l + dglort->vsi_l);
+	pc_count = BIT(dglort->pc_l);
 
 	/* configure PC for Tx queues */
 	for (pc = 0; pc < pc_count; pc++) {
@@ -952,7 +952,7 @@ static s32 fm10k_iov_reset_resources_pf(struct fm10k_hw *hw,
 		return FM10K_ERR_PARAM;
 
 	/* clear event notification of VF FLR */
-	fm10k_write_reg(hw, FM10K_PFVFLREC(vf_idx / 32), 1 << (vf_idx % 32));
+	fm10k_write_reg(hw, FM10K_PFVFLREC(vf_idx / 32), BIT(vf_idx % 32));
 
 	/* force timeout and then disconnect the mailbox */
 	vf_info->mbx.timeout = 0;
@@ -1370,7 +1370,7 @@ s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *hw, u32 **results,
 		mode = fm10k_iov_supported_xcast_mode_pf(vf_info, mode);
 
 		/* if mode is not currently enabled, enable it */
-		if (!(FM10K_VF_FLAG_ENABLED(vf_info) & (1 << mode)))
+		if (!(FM10K_VF_FLAG_ENABLED(vf_info) & BIT(mode)))
 			fm10k_update_xcast_mode_pf(hw, vf_info->glort, mode);
 
 		/* swap mode back to a bit flag */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
index ab01bb3..b999897 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
@@ -222,7 +222,7 @@ s32 fm10k_tlv_attr_put_value(u32 *msg, u16 attr_id, s64 value, u32 len)
 	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
 
 	if (len < 4) {
-		attr[1] = (u32)value & ((0x1ul << (8 * len)) - 1);
+		attr[1] = (u32)value & (BIT(8 * len) - 1);
 	} else {
 		attr[1] = (u32)value;
 		if (len > 4)
@@ -652,29 +652,29 @@ const struct fm10k_tlv_attr fm10k_tlv_msg_test_attr[] = {
  **/
 static void fm10k_tlv_msg_test_generate_data(u32 *msg, u32 attr_flags)
 {
-	if (attr_flags & (1 << FM10K_TEST_MSG_STRING))
+	if (attr_flags & BIT(FM10K_TEST_MSG_STRING))
 		fm10k_tlv_attr_put_null_string(msg, FM10K_TEST_MSG_STRING,
 					       test_str);
-	if (attr_flags & (1 << FM10K_TEST_MSG_MAC_ADDR))
+	if (attr_flags & BIT(FM10K_TEST_MSG_MAC_ADDR))
 		fm10k_tlv_attr_put_mac_vlan(msg, FM10K_TEST_MSG_MAC_ADDR,
 					    test_mac, test_vlan);
-	if (attr_flags & (1 << FM10K_TEST_MSG_U8))
+	if (attr_flags & BIT(FM10K_TEST_MSG_U8))
 		fm10k_tlv_attr_put_u8(msg, FM10K_TEST_MSG_U8,  test_u8);
-	if (attr_flags & (1 << FM10K_TEST_MSG_U16))
+	if (attr_flags & BIT(FM10K_TEST_MSG_U16))
 		fm10k_tlv_attr_put_u16(msg, FM10K_TEST_MSG_U16, test_u16);
-	if (attr_flags & (1 << FM10K_TEST_MSG_U32))
+	if (attr_flags & BIT(FM10K_TEST_MSG_U32))
 		fm10k_tlv_attr_put_u32(msg, FM10K_TEST_MSG_U32, test_u32);
-	if (attr_flags & (1 << FM10K_TEST_MSG_U64))
+	if (attr_flags & BIT(FM10K_TEST_MSG_U64))
 		fm10k_tlv_attr_put_u64(msg, FM10K_TEST_MSG_U64, test_u64);
-	if (attr_flags & (1 << FM10K_TEST_MSG_S8))
+	if (attr_flags & BIT(FM10K_TEST_MSG_S8))
 		fm10k_tlv_attr_put_s8(msg, FM10K_TEST_MSG_S8,  test_s8);
-	if (attr_flags & (1 << FM10K_TEST_MSG_S16))
+	if (attr_flags & BIT(FM10K_TEST_MSG_S16))
 		fm10k_tlv_attr_put_s16(msg, FM10K_TEST_MSG_S16, test_s16);
-	if (attr_flags & (1 << FM10K_TEST_MSG_S32))
+	if (attr_flags & BIT(FM10K_TEST_MSG_S32))
 		fm10k_tlv_attr_put_s32(msg, FM10K_TEST_MSG_S32, test_s32);
-	if (attr_flags & (1 << FM10K_TEST_MSG_S64))
+	if (attr_flags & BIT(FM10K_TEST_MSG_S64))
 		fm10k_tlv_attr_put_s64(msg, FM10K_TEST_MSG_S64, test_s64);
-	if (attr_flags & (1 << FM10K_TEST_MSG_LE_STRUCT))
+	if (attr_flags & BIT(FM10K_TEST_MSG_LE_STRUCT))
 		fm10k_tlv_attr_put_le_struct(msg, FM10K_TEST_MSG_LE_STRUCT,
 					     test_le, 8);
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 854ebb1..5c05330 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -617,10 +617,10 @@ struct fm10k_vf_info {
 						 */
 };
 
-#define FM10K_VF_FLAG_ALLMULTI_CAPABLE	((u8)1 << FM10K_XCAST_MODE_ALLMULTI)
-#define FM10K_VF_FLAG_MULTI_CAPABLE	((u8)1 << FM10K_XCAST_MODE_MULTI)
-#define FM10K_VF_FLAG_PROMISC_CAPABLE	((u8)1 << FM10K_XCAST_MODE_PROMISC)
-#define FM10K_VF_FLAG_NONE_CAPABLE	((u8)1 << FM10K_XCAST_MODE_NONE)
+#define FM10K_VF_FLAG_ALLMULTI_CAPABLE	(u8)(BIT(FM10K_XCAST_MODE_ALLMULTI))
+#define FM10K_VF_FLAG_MULTI_CAPABLE	(u8)(BIT(FM10K_XCAST_MODE_MULTI))
+#define FM10K_VF_FLAG_PROMISC_CAPABLE	(u8)(BIT(FM10K_XCAST_MODE_PROMISC))
+#define FM10K_VF_FLAG_NONE_CAPABLE	(u8)(BIT(FM10K_XCAST_MODE_NONE))
 #define FM10K_VF_FLAG_CAPABLE(vf_info)	((vf_info)->vf_flags & (u8)0xF)
 #define FM10K_VF_FLAG_ENABLED(vf_info)	((vf_info)->vf_flags >> 4)
 #define FM10K_VF_FLAG_SET_MODE(mode)	((u8)0x10 << (mode))
-- 
2.5.5
