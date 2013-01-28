From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] e1000e: cleanup: remove e1000_force_speed_duplex()
Date: Mon, 28 Jan 2013 01:04:17 -0800
Message-ID: <1359363869-32391-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773Ab3A1JEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:34 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove the function e1000_force_speed_duplex() and replace the single call
to it with the same function pointer that it would call.  The function
pointer is always set so there is no risk of a NULL pointer dereference.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 73d7813..81fba6c 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -29,7 +29,6 @@
 #include "e1000.h"
 
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
-static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read, bool page_set);
@@ -1196,7 +1195,7 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 		 * depending on user settings.
 		 */
 		e_dbg("Forcing Speed and Duplex\n");
-		ret_val = e1000_phy_force_speed_duplex(hw);
+		ret_val = hw->phy.ops.force_speed_duplex(hw);
 		if (ret_val) {
 			e_dbg("Error Forcing Speed and Duplex\n");
 			return ret_val;
@@ -2284,21 +2283,6 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_force_speed_duplex - Generic force PHY speed/duplex
- *  @hw: pointer to the HW structure
- *
- *  When the silicon family has not implemented a forced speed/duplex
- *  function for the PHY, simply return 0.
- **/
-static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.force_speed_duplex)
-		return hw->phy.ops.force_speed_duplex(hw);
-
-	return 0;
-}
-
-/**
  *  e1000e_get_phy_type_from_id - Get PHY type from id
  *  @phy_id: phy_id read from the phy
  *
-- 
1.7.11.7
