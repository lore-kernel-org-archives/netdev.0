From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: remove wait loop on autoneg for copper devices
Date: Thu,  2 Oct 2014 03:16:29 -0700
Message-ID: <1412244994-23636-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509AbaJBKQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:44 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch removes couple of wait loops on autoneg that are not needed.

During validation we noticed that the loops always time out, so there
should be no user impact.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 41 ----------------------------
 1 file changed, 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 11f02ea..d47b19f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -445,8 +445,6 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
-	u32 time_out;
-	u32 max_time_out = 10;
 	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
 	bool autoneg = false;
 	ixgbe_link_speed speed;
@@ -514,25 +512,6 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 	hw->phy.ops.write_reg(hw, MDIO_CTRL1,
 			      MDIO_MMD_AN, autoneg_reg);
 
-	/* Wait for autonegotiation to finish */
-	for (time_out = 0; time_out < max_time_out; time_out++) {
-		udelay(10);
-		/* Restart PHY autonegotiation and wait for completion */
-		status = hw->phy.ops.read_reg(hw, MDIO_STAT1,
-					      MDIO_MMD_AN,
-					      &autoneg_reg);
-
-		autoneg_reg &= MDIO_AN_STAT1_COMPLETE;
-		if (autoneg_reg == MDIO_AN_STAT1_COMPLETE) {
-			break;
-		}
-	}
-
-	if (time_out == max_time_out) {
-		hw_dbg(hw, "ixgbe_setup_phy_link_generic: time out\n");
-		return IXGBE_ERR_LINK_SETUP;
-	}
-
 	return status;
 }
 
@@ -657,8 +636,6 @@ s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw)
 {
 	s32 status;
-	u32 time_out;
-	u32 max_time_out = 10;
 	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
 	bool autoneg = false;
 	ixgbe_link_speed speed;
@@ -724,24 +701,6 @@ s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw)
 	hw->phy.ops.write_reg(hw, MDIO_CTRL1,
 			      MDIO_MMD_AN, autoneg_reg);
 
-	/* Wait for autonegotiation to finish */
-	for (time_out = 0; time_out < max_time_out; time_out++) {
-		udelay(10);
-		/* Restart PHY autonegotiation and wait for completion */
-		status = hw->phy.ops.read_reg(hw, MDIO_STAT1,
-					      MDIO_MMD_AN,
-					      &autoneg_reg);
-
-		autoneg_reg &= MDIO_AN_STAT1_COMPLETE;
-		if (autoneg_reg == MDIO_AN_STAT1_COMPLETE)
-			break;
-	}
-
-	if (time_out == max_time_out) {
-		hw_dbg(hw, "ixgbe_setup_phy_link_tnx: time out\n");
-		return IXGBE_ERR_LINK_SETUP;
-	}
-
 	return status;
 }
 
-- 
1.9.3
