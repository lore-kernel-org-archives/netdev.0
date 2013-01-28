From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] e1000e: cleanup: remove e1000_get_phy_cfg_done()
Date: Mon, 28 Jan 2013 01:04:19 -0800
Message-ID: <1359363869-32391-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab3A1JEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:35 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove the function e1000_get_phy_cfg_done() and replace the single call
to it with the same function pointer that it would call.  The function
pointer is always set so there is no risk of a NULL pointer dereference.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 37a85d4..3cf627b 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -28,7 +28,6 @@
 
 #include "e1000.h"
 
-static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read, bool page_set);
@@ -2165,7 +2164,7 @@ s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 
 	phy->ops.release(hw);
 
-	return e1000_get_phy_cfg_done(hw);
+	return phy->ops.get_cfg_done(hw);
 }
 
 /**
@@ -2265,23 +2264,6 @@ s32 e1000e_phy_init_script_igp3(struct e1000_hw *hw)
 	return 0;
 }
 
-/* Internal function pointers */
-
-/**
- *  e1000_get_phy_cfg_done - Generic PHY configuration done
- *  @hw: pointer to the HW structure
- *
- *  Return success if silicon family did not implement a family specific
- *  get_cfg_done function.
- **/
-static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.get_cfg_done)
-		return hw->phy.ops.get_cfg_done(hw);
-
-	return 0;
-}
-
 /**
  *  e1000e_get_phy_type_from_id - Get PHY type from id
  *  @phy_id: phy_id read from the phy
-- 
1.7.11.7
