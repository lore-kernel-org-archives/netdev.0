From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: phy: fix uninitialized status in ixgbe_setup_phy_link_tnx
Date: Tue, 11 Nov 2014 10:22:05 -0800
Message-ID: <1415730125-13732-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14850 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbaKKS0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 13:26:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

Status variable is never initialized, can carry an arbitrary value
on the stack and thus may let the function fail.

Fixes: e90dd2645664 ("ixgbe: Make return values more direct")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index d47b19f..28b81ae0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -635,7 +635,6 @@ s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
  **/
 s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw)
 {
-	s32 status;
 	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
 	bool autoneg = false;
 	ixgbe_link_speed speed;
@@ -700,8 +699,7 @@ s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw)
 
 	hw->phy.ops.write_reg(hw, MDIO_CTRL1,
 			      MDIO_MMD_AN, autoneg_reg);
-
-	return status;
+	return 0;
 }
 
 /**
-- 
1.9.3
