From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] e1000e: cleanup long [read|write]_reg_locked PHY ops function pointers
Date: Thu,  3 May 2012 02:56:25 -0700
Message-ID: <1336038992-3144-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64596 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981Ab2ECJ4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:35 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Calling the locked versions of the read/write PHY ops function pointers
often produces excessively long lines.  Shorten these as is done with
the non-locked versions of the PHY register read/write functions.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |   10 ++++++
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   47 +++++++++++----------------
 2 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 1da9bfa..c960cf8 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -673,11 +673,21 @@ static inline s32 e1e_rphy(struct e1000_hw *hw, u32 offset, u16 *data)
 	return hw->phy.ops.read_reg(hw, offset, data);
 }
 
+static inline s32 e1e_rphy_locked(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	return hw->phy.ops.read_reg_locked(hw, offset, data);
+}
+
 static inline s32 e1e_wphy(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	return hw->phy.ops.write_reg(hw, offset, data);
 }
 
+static inline s32 e1e_wphy_locked(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	return hw->phy.ops.write_reg_locked(hw, offset, data);
+}
+
 static inline s32 e1000_get_cable_length(struct e1000_hw *hw)
 {
 	return hw->phy.ops.get_cable_length(hw);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index ca34ebf..c58ed26 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -304,9 +304,9 @@ static bool e1000_phy_is_accessible_pchlan(struct e1000_hw *hw)
 	u16 phy_reg;
 	u32 phy_id;
 
-	hw->phy.ops.read_reg_locked(hw, PHY_ID1, &phy_reg);
+	e1e_rphy_locked(hw, PHY_ID1, &phy_reg);
 	phy_id = (u32)(phy_reg << 16);
-	hw->phy.ops.read_reg_locked(hw, PHY_ID2, &phy_reg);
+	e1e_rphy_locked(hw, PHY_ID2, &phy_reg);
 	phy_id |= (u32)(phy_reg & PHY_REVISION_MASK);
 
 	if (hw->phy.id) {
@@ -1271,8 +1271,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 		reg_addr &= PHY_REG_MASK;
 		reg_addr |= phy_page;
 
-		ret_val = phy->ops.write_reg_locked(hw, (u32)reg_addr,
-						    reg_data);
+		ret_val = e1e_wphy_locked(hw, (u32)reg_addr, reg_data);
 		if (ret_val)
 			goto release;
 	}
@@ -1309,8 +1308,8 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 	/* Disable K1 when link is 1Gbps, otherwise use the NVM setting */
 	if (link) {
 		if (hw->phy.type == e1000_phy_82578) {
-			ret_val = hw->phy.ops.read_reg_locked(hw, BM_CS_STATUS,
-			                                          &status_reg);
+			ret_val = e1e_rphy_locked(hw, BM_CS_STATUS,
+						  &status_reg);
 			if (ret_val)
 				goto release;
 
@@ -1325,8 +1324,7 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 		}
 
 		if (hw->phy.type == e1000_phy_82577) {
-			ret_val = hw->phy.ops.read_reg_locked(hw, HV_M_STATUS,
-			                                          &status_reg);
+			ret_val = e1e_rphy_locked(hw, HV_M_STATUS, &status_reg);
 			if (ret_val)
 				goto release;
 
@@ -1341,15 +1339,13 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 		}
 
 		/* Link stall fix for link up */
-		ret_val = hw->phy.ops.write_reg_locked(hw, PHY_REG(770, 19),
-		                                           0x0100);
+		ret_val = e1e_wphy_locked(hw, PHY_REG(770, 19), 0x0100);
 		if (ret_val)
 			goto release;
 
 	} else {
 		/* Link stall fix for link down */
-		ret_val = hw->phy.ops.write_reg_locked(hw, PHY_REG(770, 19),
-		                                           0x4100);
+		ret_val = e1e_wphy_locked(hw, PHY_REG(770, 19), 0x4100);
 		if (ret_val)
 			goto release;
 	}
@@ -1448,7 +1444,7 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 
 	mac_reg = er32(PHY_CTRL);
 
-	ret_val = hw->phy.ops.read_reg_locked(hw, HV_OEM_BITS, &oem_reg);
+	ret_val = e1e_rphy_locked(hw, HV_OEM_BITS, &oem_reg);
 	if (ret_val)
 		goto release;
 
@@ -1475,7 +1471,7 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 	    !hw->phy.ops.check_reset_block(hw))
 		oem_reg |= HV_OEM_BITS_RESTART_AN;
 
-	ret_val = hw->phy.ops.write_reg_locked(hw, HV_OEM_BITS, oem_reg);
+	ret_val = e1e_wphy_locked(hw, HV_OEM_BITS, oem_reg);
 
 release:
 	hw->phy.ops.release(hw);
@@ -1571,11 +1567,10 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
-	ret_val = hw->phy.ops.read_reg_locked(hw, BM_PORT_GEN_CFG, &phy_data);
+	ret_val = e1e_rphy_locked(hw, BM_PORT_GEN_CFG, &phy_data);
 	if (ret_val)
 		goto release;
-	ret_val = hw->phy.ops.write_reg_locked(hw, BM_PORT_GEN_CFG,
-					       phy_data & 0x00FF);
+	ret_val = e1e_wphy_locked(hw, BM_PORT_GEN_CFG, phy_data & 0x00FF);
 release:
 	hw->phy.ops.release(hw);
 
@@ -1807,20 +1802,18 @@ static s32 e1000_lv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
-	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_ADDR,
-					       I82579_MSE_THRESHOLD);
+	ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR, I82579_MSE_THRESHOLD);
 	if (ret_val)
 		goto release;
 	/* set MSE higher to enable link to stay up when noise is high */
-	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_DATA, 0x0034);
+	ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, 0x0034);
 	if (ret_val)
 		goto release;
-	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_ADDR,
-					       I82579_MSE_LINK_DOWN);
+	ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR, I82579_MSE_LINK_DOWN);
 	if (ret_val)
 		goto release;
 	/* drop link after 5 times MSE threshold was reached */
-	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_DATA, 0x0005);
+	ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, 0x0005);
 release:
 	hw->phy.ops.release(hw);
 
@@ -1995,12 +1988,10 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return ret_val;
-		ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_ADDR,
-						       I82579_LPI_UPDATE_TIMER);
+		ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR,
+					  I82579_LPI_UPDATE_TIMER);
 		if (!ret_val)
-			ret_val = hw->phy.ops.write_reg_locked(hw,
-							       I82579_EMI_DATA,
-							       0x1387);
+			ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, 0x1387);
 		hw->phy.ops.release(hw);
 	}
 
-- 
1.7.7.6
