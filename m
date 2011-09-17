From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] v2 ixgbe: Update packet buffer reservation to correct fdir headroom size
Date: Fri, 16 Sep 2011 19:15:44 -0700
Message-ID: <1316225752-1709-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30296 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab1IQCP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:57 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes an issue in which the incorrect amount of headroom was
being reserved for flow director filters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fec49e6..0283e12 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3372,15 +3372,17 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 
 static void ixgbe_configure_pb(struct ixgbe_adapter *adapter)
 {
-	int hdrm = 0;
-	int num_tc = netdev_get_num_tc(adapter->netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	int hdrm;
+	u8 tc = netdev_get_num_tc(adapter->netdev);
 
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
-		hdrm = 64 << adapter->fdir_pballoc;
+		hdrm = 32 << adapter->fdir_pballoc;
+	else
+		hdrm = 0;
 
-	hw->mac.ops.set_rxpba(&adapter->hw, num_tc, hdrm, PBA_STRATEGY_EQUAL);
+	hw->mac.ops.set_rxpba(hw, tc, hdrm, PBA_STRATEGY_EQUAL);
 }
 
 static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
-- 
1.7.6
