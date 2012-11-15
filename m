From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbevf: Fix unnecessary dereference where local var is available.
Date: Thu, 15 Nov 2012 06:39:41 -0800
Message-ID: <1352990387-3872-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53540 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993467Ab2KOOjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:53 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Remove dereference of hw pointer from adapter structure since a pointer
to the hw structure has already been allocated off the stack.  Also clean
up useless parenthesis.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b46dff8..a001684 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1312,8 +1312,8 @@ static inline void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
 		       "not set within the polling period\n", rxr);
 	}
 
-	ixgbevf_release_rx_desc(&adapter->hw, &adapter->rx_ring[rxr],
-				(adapter->rx_ring[rxr].count - 1));
+	ixgbevf_release_rx_desc(hw, &adapter->rx_ring[rxr],
+				adapter->rx_ring[rxr].count - 1);
 }
 
 static void ixgbevf_save_reset_stats(struct ixgbevf_adapter *adapter)
-- 
1.7.11.7
