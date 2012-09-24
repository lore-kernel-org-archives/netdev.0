From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbevf: Fix AIM (Adaptive Interrupt Moderation)
Date: Mon, 24 Sep 2012 02:00:05 -0700
Message-ID: <1348477207-27030-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab2IXJAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 05:00:14 -0400
In-Reply-To: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

While fixing up a patch from Alex Duyck to use q_vectors in ring containers
to update the ITR I bungled it and missed actually updating the counters
in the ring container q_vectors.  This patch fixes my mistake and makes
interrupt moderation actually work.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index cb215c6..37bbd86 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -263,6 +263,8 @@ cont_loop:
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
 	u64_stats_update_end(&tx_ring->syncp);
+	q_vector->tx.total_bytes += total_bytes;
+	q_vector->tx.total_packets += total_packets;
 
 	return count < tx_ring->count;
 }
@@ -488,6 +490,8 @@ next_desc:
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
 	u64_stats_update_end(&rx_ring->syncp);
+	q_vector->rx.total_packets += total_rx_packets;
+	q_vector->rx.total_bytes += total_rx_bytes;
 
 	return !!budget;
 }
-- 
1.7.11.4
