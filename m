From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: Move all values that deal with count, next_to_use, next_to_clean to u16
Date: Sat, 25 Jun 2011 00:22:20 -0700
Message-ID: <1308986546-12964-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28761 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910Ab1FYHWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:30 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updates all values dealing with count, next_to_use, and
next_to_clean so that they stay u16 values.  The advantage of this is that
there is no re-casting of type during the propagation through the stack.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f8a22eb..4fbe077 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6537,11 +6537,12 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int len;
 	unsigned int total = skb->len;
-	unsigned int offset = 0, size, count = 0, i;
+	unsigned int offset = 0, size, count = 0;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
 	unsigned int bytecount = skb->len;
 	u16 gso_segs = 1;
+	u16 i;
 
 	i = tx_ring->next_to_use;
 
@@ -6807,7 +6808,7 @@ static void ixgbe_atr(struct ixgbe_ring *ring, struct sk_buff *skb,
 					      input, common, ring->queue_index);
 }
 
-static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
+static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 {
 	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 	/* Herbert's original patch had:
@@ -6826,7 +6827,7 @@ static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
 	return 0;
 }
 
-static int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
+static int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 {
 	if (likely(ixgbe_desc_unused(tx_ring) >= size))
 		return 0;
@@ -6864,13 +6865,13 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
 {
-	unsigned int first;
 	unsigned int tx_flags = 0;
-	u8 hdr_len = 0;
 	int tso;
-	int count = 0;
+	u16 count = 0;
+	u16 first;
 	unsigned int f;
 	__be16 protocol;
+	u8 hdr_len = 0;
 
 	protocol = vlan_get_protocol(skb);
 
-- 
1.7.5.4

