From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbevf: Remove mailbox spinlock from the reset function
Date: Thu, 15 Nov 2012 06:39:44 -0800
Message-ID: <1352990387-3872-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59047 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993467Ab2KOOjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:55 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The spinlocks are not required during reset.  There won't be any
contention for the mailbox resource.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8b8a685..592fe99 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1702,15 +1702,11 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
-	spin_lock_bh(&adapter->mbx_lock);
-
 	if (hw->mac.ops.reset_hw(hw))
 		hw_dbg(hw, "PF still resetting\n");
 	else
 		hw->mac.ops.init_hw(hw);
 
-	spin_unlock_bh(&adapter->mbx_lock);
-
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
-- 
1.7.11.7
