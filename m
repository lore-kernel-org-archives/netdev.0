From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] ixgbe: Eliminate useless message and improve logic
Date: Tue, 30 Aug 2016 11:33:43 -0700
Message-ID: <1472582023-53939-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:13906 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758987AbcH3Sdq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 14:33:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Remove a useless log message and improve the logic for setting
a PHY address from the contents of the MNG_IF_SEL register.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index fb1b819..e092a89 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2394,18 +2394,12 @@ static void ixgbe_read_mng_if_sel_x550em(struct ixgbe_hw *hw)
 	/* If X552 (X550EM_a) and MDIO is connected to external PHY, then set
 	 * PHY address. This register field was has only been used for X552.
 	 */
-	if (!hw->phy.nw_mng_if_sel) {
-		if (hw->mac.type == ixgbe_mac_x550em_a) {
-			struct ixgbe_adapter *adapter = hw->back;
-
-			e_warn(drv, "nw_mng_if_sel not set\n");
-		}
-		return;
+	if (hw->mac.type == ixgbe_mac_x550em_a &&
+	    hw->phy.nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_MDIO_ACT) {
+		hw->phy.mdio.prtad = (hw->phy.nw_mng_if_sel &
+				      IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD) >>
+				     IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD_SHIFT;
 	}
-
-	hw->phy.mdio.prtad = (hw->phy.nw_mng_if_sel &
-			      IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD) >>
-			     IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD_SHIFT;
 }
 
 /** ixgbe_init_phy_ops_X550em - PHY/SFP specific init
-- 
2.7.4
