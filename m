From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e1000e: cleanup: rename goto labels to be more meaningful
Date: Mon, 13 Feb 2012 13:47:37 -0800
Message-ID: <1329169670-5403-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28387 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755550Ab2BMVrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:55 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

In the following functions, rename the generic 'out' goto label to the more
descriptive 'release' to indicate the type of common work that is done
before exiting the functions.  No functional change, cosmetic only.

e1000_sw_lcd_config_ich8lan()
e1000_oem_bits_config_ich8lan()
e1000_init_phy_wakeup()
e1000e_write_phy_reg_bm()
e1000e_read_phy_reg_bm()
e1000e_read_phy_reg_bm2()

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   26 +++++++++++++-------------
 drivers/net/ethernet/intel/e1000e/netdev.c  |    4 ++--
 drivers/net/ethernet/intel/e1000e/phy.c     |   24 ++++++++++++------------
 3 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 112d55f..6ab7254 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1065,7 +1065,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 
 	data = er32(FEXTNVM);
 	if (!(data & sw_cfg_mask))
-		goto out;
+		goto release;
 
 	/*
 	 * Make sure HW does not configure LCD from PHY
@@ -1074,14 +1074,14 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	data = er32(EXTCNF_CTRL);
 	if (!(hw->mac.type == e1000_pch2lan)) {
 		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
-			goto out;
+			goto release;
 	}
 
 	cnf_size = er32(EXTCNF_SIZE);
 	cnf_size &= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK;
 	cnf_size >>= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT;
 	if (!cnf_size)
-		goto out;
+		goto release;
 
 	cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
 	cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
@@ -1097,13 +1097,13 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 		 */
 		ret_val = e1000_write_smbus_addr(hw);
 		if (ret_val)
-			goto out;
+			goto release;
 
 		data = er32(LEDCTL);
 		ret_val = e1000_write_phy_reg_hv_locked(hw, HV_LED_CONFIG,
 							(u16)data);
 		if (ret_val)
-			goto out;
+			goto release;
 	}
 
 	/* Configure LCD from extended configuration region. */
@@ -1115,12 +1115,12 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 		ret_val = e1000_read_nvm(hw, (word_addr + i * 2), 1,
 					 &reg_data);
 		if (ret_val)
-			goto out;
+			goto release;
 
 		ret_val = e1000_read_nvm(hw, (word_addr + i * 2 + 1),
 					 1, &reg_addr);
 		if (ret_val)
-			goto out;
+			goto release;
 
 		/* Save off the PHY page for future writes. */
 		if (reg_addr == IGP01E1000_PHY_PAGE_SELECT) {
@@ -1134,10 +1134,10 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 		ret_val = phy->ops.write_reg_locked(hw, (u32)reg_addr,
 						    reg_data);
 		if (ret_val)
-			goto out;
+			goto release;
 	}
 
-out:
+release:
 	hw->phy.ops.release(hw);
 	return ret_val;
 }
@@ -1302,18 +1302,18 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 	if (!(hw->mac.type == e1000_pch2lan)) {
 		mac_reg = er32(EXTCNF_CTRL);
 		if (mac_reg & E1000_EXTCNF_CTRL_OEM_WRITE_ENABLE)
-			goto out;
+			goto release;
 	}
 
 	mac_reg = er32(FEXTNVM);
 	if (!(mac_reg & E1000_FEXTNVM_SW_CONFIG_ICH8M))
-		goto out;
+		goto release;
 
 	mac_reg = er32(PHY_CTRL);
 
 	ret_val = hw->phy.ops.read_reg_locked(hw, HV_OEM_BITS, &oem_reg);
 	if (ret_val)
-		goto out;
+		goto release;
 
 	oem_reg &= ~(HV_OEM_BITS_GBE_DIS | HV_OEM_BITS_LPLU);
 
@@ -1339,7 +1339,7 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 
 	ret_val = hw->phy.ops.write_reg_locked(hw, HV_OEM_BITS, oem_reg);
 
-out:
+release:
 	hw->phy.ops.release(hw);
 
 	return ret_val;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index f868fb8..c11b40b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5365,7 +5365,7 @@ static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
 	/* Enable access to wakeup registers on and set page to BM_WUC_PAGE */
 	retval = e1000_enable_phy_wakeup_reg_access_bm(hw, &wuc_enable);
 	if (retval)
-		goto out;
+		goto release;
 
 	/* copy MAC MTA to PHY MTA - only needed for pchlan */
 	for (i = 0; i < adapter->hw.mac.mta_reg_count; i++) {
@@ -5409,7 +5409,7 @@ static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
 	retval = e1000_disable_phy_wakeup_reg_access_bm(hw, &wuc_enable);
 	if (retval)
 		e_err("Could not set PHY Host Wakeup bit\n");
-out:
+release:
 	hw->phy.ops.release(hw);
 
 	return retval;
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 6f44c3f..70e8eb6 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -2438,7 +2438,7 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
 							 false, false);
-		goto out;
+		goto release;
 	}
 
 	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
@@ -2463,13 +2463,13 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
 		                                    (page << page_shift));
 		if (ret_val)
-			goto out;
+			goto release;
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 	                                    data);
 
-out:
+release:
 	hw->phy.ops.release(hw);
 	return ret_val;
 }
@@ -2497,7 +2497,7 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, data,
 							 true, false);
-		goto out;
+		goto release;
 	}
 
 	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
@@ -2522,12 +2522,12 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
 		                                    (page << page_shift));
 		if (ret_val)
-			goto out;
+			goto release;
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 	                                   data);
-out:
+release:
 	hw->phy.ops.release(hw);
 	return ret_val;
 }
@@ -2555,7 +2555,7 @@ s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data)
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, data,
 							 true, false);
-		goto out;
+		goto release;
 	}
 
 	hw->phy.addr = 1;
@@ -2567,12 +2567,12 @@ s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data)
 						    page);
 
 		if (ret_val)
-			goto out;
+			goto release;
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					   data);
-out:
+release:
 	hw->phy.ops.release(hw);
 	return ret_val;
 }
@@ -2599,7 +2599,7 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
 							 false, false);
-		goto out;
+		goto release;
 	}
 
 	hw->phy.addr = 1;
@@ -2610,13 +2610,13 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
 						    page);
 
 		if (ret_val)
-			goto out;
+			goto release;
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					    data);
 
-out:
+release:
 	hw->phy.ops.release(hw);
 	return ret_val;
 }
-- 
1.7.7.6
