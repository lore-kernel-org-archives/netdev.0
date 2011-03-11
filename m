From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/11] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
Date: Fri, 11 Mar 2011 03:06:27 -0800
Message-ID: <1299841590-30676-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38925 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527Ab1CKLGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:51 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When PHY reset is intentionally blocked on 82577/8/9, do not toggle the
LANPHYPC value bit (essentially performing a hard power reset of the
device) otherwise the PHY can be put into an unknown state.

Cleanup whitespace in the same function.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index cf18d65..9b434c0 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -307,9 +307,9 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	 * the interconnect to PCIe mode.
 	 */
 	fwsm = er32(FWSM);
-	if (!(fwsm & E1000_ICH_FWSM_FW_VALID)) {
+	if (!(fwsm & E1000_ICH_FWSM_FW_VALID) && !e1000_check_reset_block(hw)) {
 		ctrl = er32(CTRL);
-		ctrl |=  E1000_CTRL_LANPHYPC_OVERRIDE;
+		ctrl |= E1000_CTRL_LANPHYPC_OVERRIDE;
 		ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
 		ew32(CTRL, ctrl);
 		udelay(10);
@@ -336,7 +336,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		goto out;
 
 	/* Ungate automatic PHY configuration on non-managed 82579 */
-	if ((hw->mac.type == e1000_pch2lan)  &&
+	if ((hw->mac.type == e1000_pch2lan) &&
 	    !(fwsm & E1000_ICH_FWSM_FW_VALID)) {
 		msleep(10);
 		e1000_gate_hw_phy_config_ich8lan(hw, false);
@@ -371,7 +371,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	case e1000_phy_82579:
 		phy->ops.check_polarity = e1000_check_polarity_82577;
 		phy->ops.force_speed_duplex =
-			e1000_phy_force_speed_duplex_82577;
+		    e1000_phy_force_speed_duplex_82577;
 		phy->ops.get_cable_length = e1000_get_cable_length_82577;
 		phy->ops.get_info = e1000_get_phy_info_82577;
 		phy->ops.commit = e1000e_phy_sw_reset;
-- 
1.7.4

