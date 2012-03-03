From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ixgbe: Fix comments that are out of date or formatted incorrectly
Date: Fri,  2 Mar 2012 18:24:27 -0800
Message-ID: <1330741468-23900-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260Ab2CCCYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:38 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch corrects several comments that are either incorrect or formatted
incorrectly for multiline comments.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1cf676b..23a4665 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2359,7 +2359,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	u32 eicr;
 
 	/*
-	 * Workaround for silicon errata on 82598.  Mask the interrupts
+	 * Workaround for silicon errata #26 on 82598.  Mask the interrupt
 	 * before the read of EICR.
 	 */
 	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_IRQ_CLEAR_MASK);
@@ -4381,7 +4381,11 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
 	f_fdir->indices = min((int)num_online_cpus(), f_fdir->indices);
 	f_fdir->mask = 0;
 
-	/* Flow Director must have RSS enabled */
+	/*
+	 * Use RSS in addition to Flow Director to ensure the best
+	 * distribution of flows across cores, even when an FDIR flow
+	 * isn't matched.
+	 */
 	if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
 	    (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)) {
 		adapter->num_tx_queues = f_fdir->indices;
@@ -4558,7 +4562,8 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 	 */
 	vector_threshold = MIN_MSIX_COUNT;
 
-	/* The more we get, the more we will assign to Tx/Rx Cleanup
+	/*
+	 * The more we get, the more we will assign to Tx/Rx Cleanup
 	 * for the separate queues...where Rx Cleanup >= Tx Cleanup.
 	 * Right now, we simply care about how many we'll get; we'll
 	 * set them up later while requesting irq's.
@@ -6996,7 +7001,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 
 	/*
 	 * need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
-	 *       + 1 desc for skb_head_len/IXGBE_MAX_DATA_PER_TXD,
+	 *       + 1 desc for skb_headlen/IXGBE_MAX_DATA_PER_TXD,
 	 *       + 2 desc gap to keep tail from touching head,
 	 *       + 1 desc for context descriptor,
 	 * otherwise try next time
-- 
1.7.7.6
