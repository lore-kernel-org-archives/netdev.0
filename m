From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: Convert the normal transmit complete path to dev_consume_skb_any()
Date: Thu,  2 Oct 2014 03:16:28 -0700
Message-ID: <1412244994-23636-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbaJBKQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:42 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Convert the normal packet completion path to dev_consume_skb_any() so
packet drop profiling via dropwatch or perf top -G -e skb_kfree_skb
is not cluttered with false hits.

Compile tested only.  There is a dev_kfree_skb_any() in the routine
ixgbe_ptp_tx_hwtstamp() in ixgbe_ptp.c that looks like a conversion
candidate but I wasn't familiar enough with the code to pull the
trigger.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 06ef5a3..2daf257 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1094,7 +1094,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_kfree_skb_any(tx_buffer->skb);
+		dev_consume_skb_any(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
-- 
1.9.3
