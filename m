From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] e1000e: cleanup e1000_init_mac_params_80003es2lan()
Date: Tue,  7 Feb 2012 04:33:52 -0800
Message-ID: <1328618038-5008-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40692 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756027Ab2BGMeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:14 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Combine two switch statements into one, convert a nebulous pointer to one
that is a bit more in keeping with the rest of the driver code and remove
some dead code (there are no 80003es2lan devices with fiber).  No change in
functionality, just cosmetic changes.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   28 +++++-----------------
 1 files changed, 7 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 82a5d87..9b96961 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -205,15 +205,20 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
-	struct e1000_mac_operations *func = &mac->ops;
 
-	/* Set media type */
+	/* Set media type and media-dependent function pointers */
 	switch (adapter->pdev->device) {
 	case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
 		hw->phy.media_type = e1000_media_type_internal_serdes;
+		mac->ops.check_for_link = e1000e_check_for_serdes_link;
+		mac->ops.setup_physical_interface =
+		    e1000e_setup_fiber_serdes_link;
 		break;
 	default:
 		hw->phy.media_type = e1000_media_type_copper;
+		mac->ops.check_for_link = e1000e_check_for_copper_link;
+		mac->ops.setup_physical_interface =
+		    e1000_setup_copper_link_80003es2lan;
 		break;
 	}
 
@@ -230,25 +235,6 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	/* Adaptive IFS not supported */
 	mac->adaptive_ifs = false;
 
-	/* check for link */
-	switch (hw->phy.media_type) {
-	case e1000_media_type_copper:
-		func->setup_physical_interface = e1000_setup_copper_link_80003es2lan;
-		func->check_for_link = e1000e_check_for_copper_link;
-		break;
-	case e1000_media_type_fiber:
-		func->setup_physical_interface = e1000e_setup_fiber_serdes_link;
-		func->check_for_link = e1000e_check_for_fiber_link;
-		break;
-	case e1000_media_type_internal_serdes:
-		func->setup_physical_interface = e1000e_setup_fiber_serdes_link;
-		func->check_for_link = e1000e_check_for_serdes_link;
-		break;
-	default:
-		return -E1000_ERR_CONFIG;
-		break;
-	}
-
 	/* set lan id for port to determine which phy lock to use */
 	hw->mac.ops.set_lan_id(hw);
 
-- 
1.7.7.6
