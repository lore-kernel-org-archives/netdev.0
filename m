From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] e1000e: cleanup code duplication
Date: Wed, 16 Jan 2013 01:10:26 -0800
Message-ID: <1358327427-3146-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27582 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932509Ab3APJKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:10:51 -0500
In-Reply-To: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The removed code block is duplicated in e1000e_write_itr() so use that
instead.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 18790a6..6aa9c5d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2405,7 +2405,6 @@ static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 
 static void e1000_set_itr(struct e1000_adapter *adapter)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	u16 current_itr;
 	u32 new_itr = adapter->itr;
 
@@ -2468,10 +2467,7 @@ set_itr_now:
 		if (adapter->msix_entries)
 			adapter->rx_ring->set_itr = 1;
 		else
-			if (new_itr)
-				ew32(ITR, 1000000000 / (new_itr * 256));
-			else
-				ew32(ITR, 0);
+			e1000e_write_itr(adapter, new_itr);
 	}
 }
 
-- 
1.7.11.7
