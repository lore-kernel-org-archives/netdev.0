From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e/i40evf: force inline transmit functions
Date: Thu, 28 May 2015 04:25:37 -0700
Message-ID: <1432812339-17129-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4939 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014AbbE1L0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:26:02 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Inlining these functions gives us about 15% more 64 byte packets per
second when using pktgen. 13.3 million to 15 million with a single
queue.

Also fix the function names in i40evf to i40evf not i40e while we are
touching the function header.

Change-ID: I3294ae9b085cf438672b6db5f9af122490ead9d0
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 32 ++++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 36 ++++++++++++---------------
 2 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 3414e46..5fa43f7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2063,13 +2063,13 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
  * otherwise  returns 0 to indicate the flags has been set properly.
  **/
 #ifdef I40E_FCOE
-int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
-			       struct i40e_ring *tx_ring,
-			       u32 *flags)
-#else
-static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
+inline int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 				      struct i40e_ring *tx_ring,
 				      u32 *flags)
+#else
+static inline int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
+					     struct i40e_ring *tx_ring,
+					     u32 *flags)
 #endif
 {
 	__be16 protocol = skb->protocol;
@@ -2412,9 +2412,9 @@ static inline int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
  * Returns 0 if stop is not needed
  **/
 #ifdef I40E_FCOE
-int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
+inline int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 #else
-static int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
+static inline int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 #endif
 {
 	if (likely(I40E_DESC_UNUSED(tx_ring) >= size))
@@ -2494,13 +2494,13 @@ linearize_chk_done:
  * @td_offset: offset for checksum or crc
  **/
 #ifdef I40E_FCOE
-void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
-		 struct i40e_tx_buffer *first, u32 tx_flags,
-		 const u8 hdr_len, u32 td_cmd, u32 td_offset)
-#else
-static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
+inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			struct i40e_tx_buffer *first, u32 tx_flags,
 			const u8 hdr_len, u32 td_cmd, u32 td_offset)
+#else
+static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
+			       struct i40e_tx_buffer *first, u32 tx_flags,
+			       const u8 hdr_len, u32 td_cmd, u32 td_offset)
 #endif
 {
 	unsigned int data_len = skb->data_len;
@@ -2661,11 +2661,11 @@ dma_error:
  * one descriptor.
  **/
 #ifdef I40E_FCOE
-int i40e_xmit_descriptor_count(struct sk_buff *skb,
-			       struct i40e_ring *tx_ring)
-#else
-static int i40e_xmit_descriptor_count(struct sk_buff *skb,
+inline int i40e_xmit_descriptor_count(struct sk_buff *skb,
 				      struct i40e_ring *tx_ring)
+#else
+static inline int i40e_xmit_descriptor_count(struct sk_buff *skb,
+					     struct i40e_ring *tx_ring)
 #endif
 {
 	unsigned int f;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 6450663..0ac134b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1347,7 +1347,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 }
 
 /**
- * i40e_tx_prepare_vlan_flags - prepare generic TX VLAN tagging flags for HW
+ * i40evf_tx_prepare_vlan_flags - prepare generic TX VLAN tagging flags for HW
  * @skb:     send buffer
  * @tx_ring: ring to send buffer on
  * @flags:   the tx flags to be set
@@ -1358,9 +1358,9 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
  * Returns error code indicate the frame should be dropped upon error and the
  * otherwise  returns 0 to indicate the flags has been set properly.
  **/
-static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
-				      struct i40e_ring *tx_ring,
-				      u32 *flags)
+static inline int i40evf_tx_prepare_vlan_flags(struct sk_buff *skb,
+					       struct i40e_ring *tx_ring,
+					       u32 *flags)
 {
 	__be16 protocol = skb->protocol;
 	u32  tx_flags = 0;
@@ -1699,11 +1699,7 @@ static inline int __i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
  *
  * Returns 0 if stop is not needed
  **/
-#ifdef I40E_FCOE
-int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
-#else
-static int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
-#endif
+static inline int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 {
 	if (likely(I40E_DESC_UNUSED(tx_ring) >= size))
 		return 0;
@@ -1711,7 +1707,7 @@ static int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 }
 
 /**
- * i40e_tx_map - Build the Tx descriptor
+ * i40evf_tx_map - Build the Tx descriptor
  * @tx_ring:  ring to send buffer on
  * @skb:      send buffer
  * @first:    first buffer info buffer to use
@@ -1720,9 +1716,9 @@ static int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
  * @td_cmd:   the command field in the descriptor
  * @td_offset: offset for checksum or crc
  **/
-static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
-			struct i40e_tx_buffer *first, u32 tx_flags,
-			const u8 hdr_len, u32 td_cmd, u32 td_offset)
+static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
+				 struct i40e_tx_buffer *first, u32 tx_flags,
+				 const u8 hdr_len, u32 td_cmd, u32 td_offset)
 {
 	unsigned int data_len = skb->data_len;
 	unsigned int size = skb_headlen(skb);
@@ -1874,7 +1870,7 @@ dma_error:
 }
 
 /**
- * i40e_xmit_descriptor_count - calculate number of tx descriptors needed
+ * i40evf_xmit_descriptor_count - calculate number of tx descriptors needed
  * @skb:     send buffer
  * @tx_ring: ring to send buffer on
  *
@@ -1882,8 +1878,8 @@ dma_error:
  * there is not enough descriptors available in this ring since we need at least
  * one descriptor.
  **/
-static int i40e_xmit_descriptor_count(struct sk_buff *skb,
-				      struct i40e_ring *tx_ring)
+static inline int i40evf_xmit_descriptor_count(struct sk_buff *skb,
+					       struct i40e_ring *tx_ring)
 {
 	unsigned int f;
 	int count = 0;
@@ -1924,11 +1920,11 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	u32 td_cmd = 0;
 	u8 hdr_len = 0;
 	int tso;
-	if (0 == i40e_xmit_descriptor_count(skb, tx_ring))
+	if (0 == i40evf_xmit_descriptor_count(skb, tx_ring))
 		return NETDEV_TX_BUSY;
 
 	/* prepare the xmit flags */
-	if (i40e_tx_prepare_vlan_flags(skb, tx_ring, &tx_flags))
+	if (i40evf_tx_prepare_vlan_flags(skb, tx_ring, &tx_flags))
 		goto out_drop;
 
 	/* obtain protocol of skb */
@@ -1971,8 +1967,8 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	i40e_create_tx_ctx(tx_ring, cd_type_cmd_tso_mss,
 			   cd_tunneling, cd_l2tag2);
 
-	i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
-		    td_cmd, td_offset);
+	i40evf_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
+		      td_cmd, td_offset);
 
 	return NETDEV_TX_OK;
 
-- 
2.1.0
