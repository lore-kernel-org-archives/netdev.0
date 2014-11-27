From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 3/3] fm10k/igb/ixgbe: Use napi_alloc_skb
Date: Wed, 26 Nov 2014 16:06:11 -0800
Message-ID: <20141127000611.1617.27320.stgit@ahduyck-vm-fedora20>
References: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brouer@redhat.com,
	jeffrey.t.kirsher@intel.com, eric.dumazet@gmail.com,
	ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbaK0AGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2014 19:06:19 -0500
In-Reply-To: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces calls to netdev_alloc_skb_ip_align with
napi_alloc_skb.  The advantage of napi_alloc_skb is currently the fact that
the page allocation doesn't make use of any irq disable calls.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c     |    3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 3acdec3..7eff7c6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -310,8 +310,8 @@ static struct sk_buff *fm10k_fetch_rx_buffer(struct fm10k_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						FM10K_RX_HDR_LEN);
+		skb = napi_alloc_skb(&rx_ring->q_vector->napi,
+				     FM10K_RX_HDR_LEN);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_failed++;
 			return NULL;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 536ef9d..922d78c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6638,8 +6638,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						IGB_RX_HDR_LEN);
+		skb = napi_alloc_skb(&rx_ring->q_vector->napi, IGB_RX_HDR_LEN);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_failed++;
 			return NULL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a195d24..03df91f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1858,8 +1858,8 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						IXGBE_RX_HDR_SIZE);
+		skb = napi_alloc_skb(&rx_ring->q_vector->napi,
+				     IXGBE_RX_HDR_SIZE);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_rx_buff_failed++;
 			return NULL;
