From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] igb: remove redundant PHY power down register write
Date: Tue, 27 May 2014 02:12:29 -0700
Message-ID: <1401181951-31358-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17026 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbaE0JMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:46 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

One of the registers used to power down the PHY was found to be wrong
(should be bit 2 not bit 1) on further inspection it was also found to
be redundant.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 14 --------------
 drivers/net/ethernet/intel/igb/e1000_phy.h |  1 -
 2 files changed, 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 424f16c..c1bb64d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -2204,16 +2204,10 @@ s32 igb_phy_init_script_igp3(struct e1000_hw *hw)
 void igb_power_up_phy_copper(struct e1000_hw *hw)
 {
 	u16 mii_reg = 0;
-	u16 power_reg = 0;
 
 	/* The PHY will retain its settings across a power down/up cycle */
 	hw->phy.ops.read_reg(hw, PHY_CONTROL, &mii_reg);
 	mii_reg &= ~MII_CR_POWER_DOWN;
-	if (hw->phy.type == e1000_phy_i210) {
-		hw->phy.ops.read_reg(hw, GS40G_COPPER_SPEC, &power_reg);
-		power_reg &= ~GS40G_CS_POWER_DOWN;
-		hw->phy.ops.write_reg(hw, GS40G_COPPER_SPEC, power_reg);
-	}
 	hw->phy.ops.write_reg(hw, PHY_CONTROL, mii_reg);
 }
 
@@ -2227,18 +2221,10 @@ void igb_power_up_phy_copper(struct e1000_hw *hw)
 void igb_power_down_phy_copper(struct e1000_hw *hw)
 {
 	u16 mii_reg = 0;
-	u16 power_reg = 0;
 
 	/* The PHY will retain its settings across a power down/up cycle */
 	hw->phy.ops.read_reg(hw, PHY_CONTROL, &mii_reg);
 	mii_reg |= MII_CR_POWER_DOWN;
-
-	/* i210 Phy requires an additional bit for power up/down */
-	if (hw->phy.type == e1000_phy_i210) {
-		hw->phy.ops.read_reg(hw, GS40G_COPPER_SPEC, &power_reg);
-		power_reg |= GS40G_CS_POWER_DOWN;
-		hw->phy.ops.write_reg(hw, GS40G_COPPER_SPEC, power_reg);
-	}
 	hw->phy.ops.write_reg(hw, PHY_CONTROL, mii_reg);
 	usleep_range(1000, 2000);
 }
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index fe921e2..7af4ffa 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -151,7 +151,6 @@ s32  igb_check_polarity_m88(struct e1000_hw *hw);
 #define GS40G_MAC_LB			0x4140
 #define GS40G_MAC_SPEED_1G		0X0006
 #define GS40G_COPPER_SPEC		0x0010
-#define GS40G_CS_POWER_DOWN		0x0002
 #define GS40G_LINE_LB			0x4000
 
 /* SFP modules ID memory locations */
-- 
1.9.3
