From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] ixgbe: remove redundant configuration of tx_sample_rate
Date: Fri, 16 Sep 2011 19:15:43 -0700
Message-ID: <1316225752-1709-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31405 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663Ab1IQCP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:57 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes a minor redundancy in that tx_sample_rate was set twice.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bb069bc..fec49e6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3409,16 +3409,12 @@ static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
 
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
-	struct ixgbe_hw *hw = &adapter->hw;
-	int i;
-
 	ixgbe_configure_pb(adapter);
 #ifdef CONFIG_IXGBE_DCB
 	ixgbe_configure_dcb(adapter);
 #endif
 
-	ixgbe_set_rx_mode(netdev);
+	ixgbe_set_rx_mode(adapter->netdev);
 	ixgbe_restore_vlan(adapter);
 
 #ifdef IXGBE_FCOE
@@ -3427,15 +3423,14 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 
 #endif /* IXGBE_FCOE */
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i]->atr_sample_rate =
-						       adapter->atr_sample_rate;
-		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
+		ixgbe_init_fdir_signature_82599(&adapter->hw,
+						adapter->fdir_pballoc);
 	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
 		ixgbe_init_fdir_perfect_82599(&adapter->hw,
 					      adapter->fdir_pballoc);
 		ixgbe_fdir_filter_restore(adapter);
 	}
+
 	ixgbe_configure_virtualization(adapter);
 
 	ixgbe_configure_tx(adapter);
-- 
1.7.6
