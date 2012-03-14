From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] ixgbe: use typed min/max functions where possible
Date: Wed, 14 Mar 2012 00:55:24 -0700
Message-ID: <1331711726-9439-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7678 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758476Ab2CNHzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:55:32 -0400
In-Reply-To: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

using the form min((int)var, ver)) is replaced by min_t(int, ...)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    8 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 1216bae..24f7291 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -935,12 +935,12 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	new_rx_count = max(ring->rx_pending, (u32)IXGBE_MIN_RXD);
-	new_rx_count = min(new_rx_count, (u32)IXGBE_MAX_RXD);
+	new_rx_count = max_t(u32, ring->rx_pending, IXGBE_MIN_RXD);
+	new_rx_count = min_t(u32, new_rx_count, IXGBE_MAX_RXD);
 	new_rx_count = ALIGN(new_rx_count, IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	new_tx_count = max(ring->tx_pending, (u32)IXGBE_MIN_TXD);
-	new_tx_count = min(new_tx_count, (u32)IXGBE_MAX_TXD);
+	new_tx_count = max_t(u32, ring->tx_pending, IXGBE_MIN_TXD);
+	new_tx_count = min_t(u32, new_tx_count, IXGBE_MAX_TXD);
 	new_tx_count = ALIGN(new_tx_count, IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if ((new_tx_count == adapter->tx_ring[0]->count) &&
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 71ced43..fce33f1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4316,7 +4316,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
 		return false;
 
-	f->indices = min((int)num_online_cpus(), f->indices);
+	f->indices = min_t(int, num_online_cpus(), f->indices);
 
 	adapter->num_rx_queues = 1;
 	adapter->num_tx_queues = 1;
@@ -4352,8 +4352,8 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 		return false;
 
 	/* Map queue offset and counts onto allocated tx queues */
-	per_tc_q = min(dev->num_tx_queues / tcs, (unsigned int)DCB_QUEUE_CAP);
-	q = min((int)num_online_cpus(), per_tc_q);
+	per_tc_q = min_t(unsigned int, dev->num_tx_queues / tcs, DCB_QUEUE_CAP);
+	q = min_t(int, num_online_cpus(), per_tc_q);
 
 	for (i = 0; i < tcs; i++) {
 		netdev_set_tc_queue(dev, i, q, offset);
@@ -5146,7 +5146,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->subsystem_device_id = pdev->subsystem_device;
 
 	/* Set capability flags */
-	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
+	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	switch (hw->mac.type) {
-- 
1.7.7.6
