From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] i40e: Tweak for-loop in i40e_ethtool.c
Date: Tue, 22 Apr 2014 05:39:30 -0700
Message-ID: <1398170371-3333-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3866 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932620AbaDVMjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:44 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Tweak a for-loop to make it easier to add conditional stats in the future.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index d9a41d3..0cf47c9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -649,7 +649,7 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	rcu_read_lock();
-	for (j = 0; j < vsi->num_queue_pairs; j++, i += 4) {
+	for (j = 0; j < vsi->num_queue_pairs; j++) {
 		struct i40e_ring *tx_ring = ACCESS_ONCE(vsi->tx_rings[j]);
 		struct i40e_ring *rx_ring;
 
@@ -662,14 +662,16 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 			data[i] = tx_ring->stats.packets;
 			data[i + 1] = tx_ring->stats.bytes;
 		} while (u64_stats_fetch_retry_irq(&tx_ring->syncp, start));
+		i += 2;
 
 		/* Rx ring is the 2nd half of the queue pair */
 		rx_ring = &tx_ring[1];
 		do {
 			start = u64_stats_fetch_begin_irq(&rx_ring->syncp);
-			data[i + 2] = rx_ring->stats.packets;
-			data[i + 3] = rx_ring->stats.bytes;
+			data[i] = rx_ring->stats.packets;
+			data[i + 1] = rx_ring->stats.bytes;
 		} while (u64_stats_fetch_retry_irq(&rx_ring->syncp, start));
+		i += 2;
 	}
 	rcu_read_unlock();
 	if (vsi == pf->vsi[pf->lan_vsi]) {
-- 
1.9.0
