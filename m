From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] e1000e: cleanup: remove e1000_set_d0_lplu_state()
Date: Mon, 28 Jan 2013 01:04:16 -0800
Message-ID: <1359363869-32391-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3A1JEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:34 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Replace the function e1000_set_d0_lplu_state() with the contents of it
coded in place of the single call to the function.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 33 ++++++---------------------------
 1 file changed, 6 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 44fb432..73d7813 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -30,7 +30,6 @@
 
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
-static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read, bool page_set);
@@ -894,10 +893,12 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 	msleep(100);
 
 	/* disable lplu d0 during driver init */
-	ret_val = e1000_set_d0_lplu_state(hw, false);
-	if (ret_val) {
-		e_dbg("Error Disabling LPLU D0\n");
-		return ret_val;
+	if (hw->phy.ops.set_d0_lplu_state) {
+		ret_val = hw->phy.ops.set_d0_lplu_state(hw, false);
+		if (ret_val) {
+			e_dbg("Error Disabling LPLU D0\n");
+			return ret_val;
+		}
 	}
 	/* Configure mdi-mdix settings */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CTRL, &data);
@@ -2820,28 +2821,6 @@ s32 e1000e_commit_phy(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_d0_lplu_state - Sets low power link up state for D0
- *  @hw: pointer to the HW structure
- *  @active: boolean used to enable/disable lplu
- *
- *  Success returns 0, Failure returns 1
- *
- *  The low power link up (lplu) state is set to the power management level D0
- *  and SmartSpeed is disabled when active is true, else clear lplu for D0
- *  and enable Smartspeed.  LPLU and Smartspeed are mutually exclusive.  LPLU
- *  is used during Dx states where the power conservation is most important.
- *  During driver activity, SmartSpeed should be enabled so performance is
- *  maintained.  This is a function pointer entry point called by drivers.
- **/
-static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
-{
-	if (hw->phy.ops.set_d0_lplu_state)
-		return hw->phy.ops.set_d0_lplu_state(hw, active);
-
-	return 0;
-}
-
-/**
  *  __e1000_read_phy_reg_hv -  Read HV PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
-- 
1.7.11.7
