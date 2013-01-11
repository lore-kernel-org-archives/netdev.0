From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] e1000e: cleanup code duplication
Date: Fri, 11 Jan 2013 02:23:50 -0800
Message-ID: <1357899831-4168-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8893 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754607Ab3AKKYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:24:08 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 94312a4..f51b353 100644
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
