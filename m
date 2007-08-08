From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Remove unused or empty labels
Date: Wed, 08 Aug 2007 10:21:52 -0700
Message-ID: <20070808172152.12223.94635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4557 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937528AbXHHRV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 13:21:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove labels with only return, remove E1000_SUCCESS code and
replace with 0. Remove most goto's.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |  138 +++++---------
 drivers/net/e1000e/defines.h |    1 
 drivers/net/e1000e/es2lan.c  |  162 +++++++----------
 drivers/net/e1000e/ich8lan.c |  401 +++++++++++++++++-------------------------
 drivers/net/e1000e/lib.c     |  314 +++++++++++++--------------------
 drivers/net/e1000e/netdev.c  |    4 
 drivers/net/e1000e/phy.c     |  278 ++++++++++++-----------------
 7 files changed, 521 insertions(+), 777 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index a1b9d16..ddf2303 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -67,11 +67,11 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw);
 static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	if (hw->media_type != e1000_media_type_copper) {
 		phy->type = e1000_phy_none;
-		goto out;
+		return 0;
 	}
 
 	phy->addr			 = 1;
@@ -87,8 +87,7 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 		phy->type		 = e1000_phy_m88;
 		break;
 	default:
-		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return -E1000_ERR_PHY;
 		break;
 	}
 
@@ -99,25 +98,19 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
-		if (phy->id != IGP01E1000_I_PHY_ID) {
-			ret_val = -E1000_ERR_PHY;
-			goto out;
-		}
+		if (phy->id != IGP01E1000_I_PHY_ID)
+			return -E1000_ERR_PHY;
 		break;
 	case e1000_82573:
-		if (phy->id != M88E1111_I_PHY_ID) {
-			ret_val = -E1000_ERR_PHY;
-			goto out;
-		}
+		if (phy->id != M88E1111_I_PHY_ID)
+			return -E1000_ERR_PHY;
 		break;
 	default:
-		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return -E1000_ERR_PHY;
 		break;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -174,7 +167,7 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		break;
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -188,7 +181,6 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
 	struct e1000_mac_operations *func = &mac->ops;
-	s32 ret_val = E1000_SUCCESS;
 
 	/* Set media type */
 	switch (adapter->pdev->device) {
@@ -232,13 +224,11 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 		func->get_link_up_info = e1000_get_speed_and_duplex_fiber_serdes;
 		break;
 	default:
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 		break;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
@@ -306,7 +296,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 		break;
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -319,7 +309,6 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = E1000_SUCCESS;
 
 	switch (hw->mac.type) {
 	case e1000_82571:
@@ -331,14 +320,14 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 		phy->id = IGP01E1000_I_PHY_ID;
 		break;
 	case e1000_82573:
-		ret_val = e1000_get_phy_id(hw);
+		return e1000_get_phy_id(hw);
 		break;
 	default:
-		ret_val = -E1000_ERR_PHY;
+		return -E1000_ERR_PHY;
 		break;
 	}
 
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -350,7 +339,6 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 static s32 e1000_get_hw_semaphore_82571(struct e1000_hw *hw)
 {
 	u32 swsm;
-	s32 ret_val = E1000_SUCCESS;
 	s32 timeout = hw->nvm.word_size + 1;
 	s32 i = 0;
 
@@ -370,12 +358,10 @@ static s32 e1000_get_hw_semaphore_82571(struct e1000_hw *hw)
 		/* Release semaphores */
 		e1000_put_hw_semaphore(hw);
 		hw_dbg(hw, "Driver can't access the NVM\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -410,7 +396,7 @@ static s32 e1000_acquire_nvm_82571(struct e1000_hw *hw)
 
 	ret_val = e1000_get_hw_semaphore_82571(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (hw->mac.type != e1000_82573)
 		ret_val = e1000_acquire_nvm(hw);
@@ -418,7 +404,6 @@ static s32 e1000_acquire_nvm_82571(struct e1000_hw *hw)
 	if (ret_val)
 		e1000_put_hw_semaphore_82571(hw);
 
-out:
 	return ret_val;
 }
 
@@ -449,7 +434,7 @@ static void e1000_release_nvm_82571(struct e1000_hw *hw)
 static s32 e1000_write_nvm_82571(struct e1000_hw *hw, u16 offset, u16 words,
 				 u16 *data)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	switch (hw->mac.type) {
 	case e1000_82573:
@@ -483,12 +468,12 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 
 	ret_val = e1000_update_nvm_checksum_generic(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* If our nvm is an EEPROM, then we're done
 	 * otherwise, commit the checksum to the flash NVM. */
 	if (hw->nvm.type != e1000_nvm_flash_hw)
-		goto out;
+		return ret_val;
 
 	/* Check for pending operations. */
 	for (i = 0; i < E1000_FLASH_UPDATES; i++) {
@@ -497,10 +482,8 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 			break;
 	}
 
-	if (i == E1000_FLASH_UPDATES) {
-		ret_val = -E1000_ERR_NVM;
-		goto out;
-	}
+	if (i == E1000_FLASH_UPDATES)
+		return -E1000_ERR_NVM;
 
 	/* Reset the firmware if using STM opcode. */
 	if ((er32(FLOP) & 0xFF00) == E1000_STM_OPCODE) {
@@ -522,13 +505,10 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 			break;
 	}
 
-	if (i == E1000_FLASH_UPDATES) {
-		ret_val = -E1000_ERR_NVM;
-		goto out;
-	}
+	if (i == E1000_FLASH_UPDATES)
+		return -E1000_ERR_NVM;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -573,8 +553,7 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	for (i = 0; i < words; i++) {
@@ -593,7 +572,6 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 			break;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -606,7 +584,6 @@ out:
 static s32 e1000_get_cfg_done_82571(struct e1000_hw *hw)
 {
 	s32 timeout = PHY_CFG_TIMEOUT;
-	s32 ret_val = E1000_SUCCESS;
 
 	while (timeout) {
 		if (er32(EEMNGCTL) &
@@ -617,12 +594,10 @@ static s32 e1000_get_cfg_done_82571(struct e1000_hw *hw)
 	}
 	if (!timeout) {
 		hw_dbg(hw, "MNG configuration cycle has not completed.\n");
-		ret_val = -E1000_ERR_RESET;
-		goto out;
+		return -E1000_ERR_RESET;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -644,20 +619,20 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
 
 	ret_val = e1e_rphy(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (active) {
 		data |= IGP02E1000_PM_D0_LPLU;
 		ret_val = e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
 		ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG, &data);
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 		ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG, data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	} else {
 		data &= ~IGP02E1000_PM_D0_LPLU;
 		ret_val = e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
@@ -669,29 +644,28 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -762,7 +736,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	ret_val = e1000_get_auto_rd_done(hw);
 	if (ret_val)
 		/* We don't want to continue accessing MAC registers. */
-		goto out;
+		return ret_val;
 
 	/* Phy configuration from NVM just starts after EECD_AUTO_RD is set.
 	 * Need to wait for Phy configuration completion before accessing
@@ -775,8 +749,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	ew32(IMC, 0xffffffff);
 	icr = er32(ICR);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -799,7 +772,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	ret_val = e1000_id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
-		goto out;
+		return ret_val;
 	}
 
 	/* Disabling VLAN filtering */
@@ -851,7 +824,6 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	 */
 	e1000_clear_hw_cntrs_82571(hw);
 
-out:
 	return ret_val;
 }
 
@@ -1041,16 +1013,15 @@ static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 		ew32(LEDCTL, led_ctrl);
 		break;
 	default:
-		ret_val = -E1000_ERR_PHY;
+		return -E1000_ERR_PHY;
 		break;
 	}
 
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_setup_copper_link(hw);
 
-out:
 	return ret_val;
 }
 
@@ -1097,7 +1068,7 @@ static s32 e1000_valid_led_default_82571(struct e1000_hw *hw, u16 *data)
 	ret_val = e1000_read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
-		goto out;
+		return ret_val;
 	}
 
 	if (hw->mac.type == e1000_82573 &&
@@ -1107,8 +1078,7 @@ static s32 e1000_valid_led_default_82571(struct e1000_hw *hw, u16 *data)
 		 *data == ID_LED_RESERVED_FFFF)
 		*data = ID_LED_DEFAULT;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1135,7 +1105,7 @@ bool e1000_get_laa_state_82571(struct e1000_hw *hw)
 void e1000_set_laa_state_82571(struct e1000_hw *hw, bool state)
 {
 	if (hw->mac.type != e1000_82571)
-		goto out;
+		return;
 
 	hw->dev_spec.e82571.laa_is_present = state;
 
@@ -1148,9 +1118,6 @@ void e1000_set_laa_state_82571(struct e1000_hw *hw, bool state)
 		 * Eventually the LAA will be in RAR[0] and RAR[14].
 		 */
 		e1000_rar_set(hw, hw->mac.addr, hw->mac.rar_entry_count - 1);
-
-out:
-	return;
 }
 
 /**
@@ -1166,18 +1133,18 @@ out:
 static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 data;
 
 	if (nvm->type != e1000_nvm_flash_hw)
-		goto out;
+		return 0;
 
 	/* Check bit 4 of word 10h.  If it is 0, firmware is done updating
 	 * 10h-12h.  Checksum may need to be fixed.
 	 */
 	ret_val = e1000_read_nvm(hw, 0x10, 1, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (!(data & 0x10)) {
 		/* Read 0x23 and check bit 15.  This bit is a 1
@@ -1189,19 +1156,18 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 		 */
 		ret_val = e1000_read_nvm(hw, 0x23, 1, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		if (!(data & 0x8000)) {
 			data |= 0x8000;
 			ret_val = e1000_write_nvm(hw, 0x23, 1, &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 			ret_val = e1000_update_nvm_checksum(hw);
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index e0a36f1..ca80fde 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -413,7 +413,6 @@
 #define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */
 
 /* Error Codes */
-#define E1000_SUCCESS      0
 #define E1000_ERR_NVM      1
 #define E1000_ERR_PHY      2
 #define E1000_ERR_CONFIG   3
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index b5143e9..5604c50 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -111,11 +111,11 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex);
 static s32 e1000_init_phy_params_80003es2lan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	if (hw->media_type != e1000_media_type_copper) {
 		phy->type	= e1000_phy_none;
-		goto out;
+		return 0;
 	}
 
 	phy->addr		= 1;
@@ -127,12 +127,9 @@ static s32 e1000_init_phy_params_80003es2lan(struct e1000_hw *hw)
 	ret_val = e1000_get_phy_id(hw);
 
 	/* Verify phy id */
-	if (phy->id != GG82563_E_PHY_ID) {
-		ret_val = -E1000_ERR_PHY;
-		goto out;
-	}
+	if (phy->id != GG82563_E_PHY_ID)
+		return -E1000_ERR_PHY;
 
-out:
 	return ret_val;
 }
 
@@ -176,7 +173,7 @@ static s32 e1000_init_nvm_params_80003es2lan(struct e1000_hw *hw)
 	size += NVM_WORD_SIZE_BASE_SHIFT;
 	nvm->word_size	= 1 << size;
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -190,7 +187,6 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
 	struct e1000_mac_operations *func = &mac->ops;
-	s32 ret_val = E1000_SUCCESS;
 
 	/* Set media type */
 	switch (adapter->pdev->device) {
@@ -225,13 +221,11 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 		func->check_for_link = e1000_check_for_serdes_link;
 		break;
 	default:
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 		break;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 static s32 e1000_get_invariants_80003es2lan(struct e1000_adapter *adapter)
@@ -251,7 +245,7 @@ static s32 e1000_get_invariants_80003es2lan(struct e1000_adapter *adapter)
 	if (rc)
 		return rc;
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -298,14 +292,13 @@ static s32 e1000_acquire_nvm_80003es2lan(struct e1000_hw *hw)
 
 	ret_val = e1000_acquire_swfw_sync_80003es2lan(hw, E1000_SWFW_EEP_SM);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_acquire_nvm(hw);
 
 	if (ret_val)
 		e1000_release_swfw_sync_80003es2lan(hw, E1000_SWFW_EEP_SM);
 
-out:
 	return ret_val;
 }
 
@@ -335,15 +328,12 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 	u32 swfw_sync;
 	u32 swmask = mask;
 	u32 fwmask = mask << 16;
-	s32 ret_val = E1000_SUCCESS;
 	s32 i = 0;
 	s32 timeout = 200;
 
 	while (i < timeout) {
-		if (e1000_get_hw_semaphore(hw)) {
-			ret_val = -E1000_ERR_SWFW_SYNC;
-			goto out;
-		}
+		if (e1000_get_hw_semaphore(hw))
+			return -E1000_ERR_SWFW_SYNC;
 
 		swfw_sync = er32(SW_FW_SYNC);
 		if (!(swfw_sync & (fwmask | swmask)))
@@ -359,8 +349,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 	if (i == timeout) {
 		hw_dbg(hw,
 		       "Driver can't access resource, SW_FW_SYNC timeout.\n");
-		ret_val = -E1000_ERR_SWFW_SYNC;
-		goto out;
+		return -E1000_ERR_SWFW_SYNC;
 	}
 
 	swfw_sync |= swmask;
@@ -368,8 +357,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 
 	e1000_put_hw_semaphore(hw);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -384,7 +372,7 @@ static void e1000_release_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 {
 	u32 swfw_sync;
 
-	while (e1000_get_hw_semaphore(hw) != E1000_SUCCESS);
+	while (e1000_get_hw_semaphore(hw) != 0);
 	/* Empty */
 
 	swfw_sync = er32(SW_FW_SYNC);
@@ -422,7 +410,7 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	temp = (u16)((u16)offset >> GG82563_PAGE_SHIFT);
 	ret_val = e1000_write_phy_reg_m88(hw, page_select, temp);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* The "ready" bit in the MDIC register may be incorrectly set
 	 * before the device has completed the "Page Select" MDI
@@ -435,7 +423,7 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 
 	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp) {
 		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return ret_val;
 	}
 
 	udelay(200);
@@ -446,7 +434,6 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 
 	udelay(200);
 
-out:
 	return ret_val;
 }
 
@@ -478,7 +465,7 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	temp = (u16)((u16)offset >> GG82563_PAGE_SHIFT);
 	ret_val = e1000_write_phy_reg_m88(hw, page_select, temp);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 
 	/* The "ready" bit in the MDIC register may be incorrectly set
@@ -490,10 +477,8 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	/* ...and verify the command was successful. */
 	ret_val = e1000_read_phy_reg_m88(hw, page_select, &temp);
 
-	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp) {
-		ret_val = -E1000_ERR_PHY;
-		goto out;
-	}
+	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp)
+		return -E1000_ERR_PHY;
 
 	udelay(200);
 
@@ -503,7 +488,6 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 
 	udelay(200);
 
-out:
 	return ret_val;
 }
 
@@ -533,7 +517,6 @@ static s32 e1000_write_nvm_80003es2lan(struct e1000_hw *hw, u16 offset,
 static s32 e1000_get_cfg_done_80003es2lan(struct e1000_hw *hw)
 {
 	s32 timeout = PHY_CFG_TIMEOUT;
-	s32 ret_val = E1000_SUCCESS;
 	u32 mask = E1000_NVM_CFG_DONE_PORT_0;
 
 	if (hw->bus.func == 1)
@@ -547,12 +530,10 @@ static s32 e1000_get_cfg_done_80003es2lan(struct e1000_hw *hw)
 	}
 	if (!timeout) {
 		hw_dbg(hw, "MNG configuration cycle has not completed.\n");
-		ret_val = -E1000_ERR_RESET;
-		goto out;
+		return -E1000_ERR_RESET;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -573,18 +554,18 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_data &= ~GG82563_PSCR_CROSSOVER_MODE_AUTO;
 	ret_val = e1e_wphy(hw, GG82563_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	hw_dbg(hw, "GG82563 PSCR: %X\n", phy_data);
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
 
@@ -593,7 +574,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	udelay(1);
 
@@ -604,7 +585,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		if (!link) {
 			/* We didn't get link.
@@ -612,19 +593,19 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 			 */
 			ret_val = e1000_phy_reset_dsp(hw);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 
 		/* Try once more */
 		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Resetting the phy means we need to verify the TX_CLK corresponds
 	 * to the link speed.  10Mbps -> 2.5MHz, else 25MHz.
@@ -641,7 +622,6 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	phy_data |= GG82563_MSCR_ASSERT_CRS_ON_TX;
 	ret_val = e1e_wphy(hw, GG82563_PHY_MAC_SPEC_CTRL, phy_data);
 
-out:
 	return ret_val;
 }
 
@@ -661,7 +641,7 @@ static s32 e1000_get_cable_length_80003es2lan(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_DSP_DISTANCE, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	index = phy_data & GG82563_DSPD_CABLE_LENGTH;
 	phy->min_cable_length = e1000_gg82563_cable_length_table[index];
@@ -669,8 +649,7 @@ static s32 e1000_get_cable_length_80003es2lan(struct e1000_hw *hw)
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -692,7 +671,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
 								    speed,
 								    duplex);
 		if (ret_val)
-			goto out;
+			return ret_val;
 		if (*speed == SPEED_1000)
 			ret_val = e1000_cfg_kmrn_1000_80003es2lan(hw);
 		else
@@ -704,7 +683,6 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
 								  duplex);
 	}
 
-out:
 	return ret_val;
 }
 
@@ -745,14 +723,13 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	ret_val = e1000_get_auto_rd_done(hw);
 	if (ret_val)
 		/* We don't want to continue accessing MAC registers. */
-		goto out;
+		return ret_val;
 
 	/* Clear any pending interrupt events. */
 	ew32(IMC, 0xffffffff);
 	icr = er32(ICR);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -775,7 +752,7 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	ret_val = e1000_id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
-		goto out;
+		return ret_val;
 	}
 
 	/* Disabling VLAN filtering */
@@ -833,7 +810,6 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	 */
 	e1000_clear_hw_cntrs_80003es2lan(hw);
 
-out:
 	return ret_val;
 }
 
@@ -881,15 +857,15 @@ static void e1000_initialize_hw_bits_80003es2lan(struct e1000_hw *hw)
  **/
 static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 {
-	struct   e1000_phy_info *phy = &hw->phy;
-	s32  ret_val;
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
 	u32 ctrl_ext;
 	u16 data;
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL,
 				     &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	data |= GG82563_MSCR_ASSERT_CRS_ON_TX;
 	/* Use 25MHz for both link down and 1000Base-T for Tx clock. */
@@ -898,7 +874,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	ret_val = e1e_wphy(hw, GG82563_PHY_MAC_SPEC_CTRL,
 				      data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Options:
 	 *   MDI/MDI-X = 0 (default)
@@ -909,7 +885,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1e_rphy(hw, GG82563_PHY_SPEC_CTRL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	data &= ~GG82563_PSCR_CROSSOVER_MODE_MASK;
 
@@ -938,13 +914,13 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 
 	ret_val = e1e_wphy(hw, GG82563_PHY_SPEC_CTRL, data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* SW Reset the PHY so all changes take effect */
 	ret_val = e1000_commit_phy(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error Resetting the PHY\n");
-		goto out;
+		return ret_val;
 	}
 
 	/* Bypass RX and TX FIFO's */
@@ -953,16 +929,16 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 				E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
 					E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_SPEC_CTRL_2, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	data &= ~GG82563_PSCR2_REVERSE_AUTO_NEG;
 	ret_val = e1e_wphy(hw, GG82563_PHY_SPEC_CTRL_2, data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ctrl_ext = er32(CTRL_EXT);
 	ctrl_ext &= ~(E1000_CTRL_EXT_LINK_MODE_MASK);
@@ -970,7 +946,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_PWR_MGMT_CTRL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Do not init these registers when the HW is in IAMT mode, since the
 	 * firmware will have already initialized them.  We only initialize
@@ -981,16 +957,16 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		data |= GG82563_PMCR_ENABLE_ELECTRICAL_IDLE;
 		ret_val = e1e_wphy(hw, GG82563_PHY_PWR_MGMT_CTRL, data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
 		ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
 	/* Workaround: Disable padding in Kumeran interface in the MAC
@@ -998,15 +974,14 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1e_rphy(hw, GG82563_PHY_INBAND_CTRL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	data |= GG82563_ICR_DIS_PADDING;
 	ret_val = e1e_wphy(hw, GG82563_PHY_INBAND_CTRL, data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1019,7 +994,7 @@ out:
 static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 {
 	u32 ctrl;
-	s32  ret_val;
+	s32 ret_val;
 	u16 reg_data;
 
 	ctrl = er32(CTRL);
@@ -1032,34 +1007,33 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	 * polling the phy; this fixes erroneous timeouts at 10Mbps. */
 	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	ret_val = e1000_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	reg_data |= 0x3F;
 	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	ret_val = e1000_read_kmrn_reg(hw,
 				      E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
 				      &reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	reg_data |= E1000_KMRNCTRLSTA_INB_CTRL_DIS_PADDING;
 	ret_val = e1000_write_kmrn_reg(hw,
 				       E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
 				       reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_copper_link_setup_gg82563_80003es2lan(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_setup_copper_link(hw);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1072,7 +1046,7 @@ out:
  **/
 static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u32 tipg;
 	u16 reg_data;
 
@@ -1081,7 +1055,7 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
 				       reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Configure Transmit Inter-Packet Gap */
 	tipg = er32(TIPG);
@@ -1091,7 +1065,7 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (duplex == HALF_DUPLEX)
 		reg_data |= GG82563_KMCR_PASS_FALSE_CARRIER;
@@ -1100,8 +1074,7 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 
 	ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1113,7 +1086,7 @@ out:
  **/
 static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 reg_data;
 	u32 tipg;
 
@@ -1122,7 +1095,7 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
 				       reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Configure Transmit Inter-Packet Gap */
 	tipg = er32(TIPG);
@@ -1132,12 +1105,11 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
 	ret_val = e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
 
-out:
 	return ret_val;
 }
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 5967139..042abd4 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -187,7 +187,7 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 i = 0;
 
 	phy->addr			= 1;
@@ -199,7 +199,7 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		msleep(1);
 		ret_val = e1000_get_phy_id(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
 	/* Verify phy id */
@@ -215,12 +215,11 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		phy->autoneg_mask = E1000_ALL_NOT_GIG;
 		break;
 	default:
-		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return -E1000_ERR_PHY;
+		break;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -237,15 +236,13 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	u32 gfpreg;
 	u32 sector_base_addr;
 	u32 sector_end_addr;
-	s32 ret_val = E1000_SUCCESS;
 	u16 i;
 
 	/* Can't read flash registers if the register set isn't mapped.
 	 */
 	if (!hw->flash_address) {
 		hw_dbg(hw, "ERROR: Flash registers not mapped\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
 	nvm->type = e1000_nvm_flash_sw;
@@ -277,8 +274,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 		dev_spec->shadow_ram[i].value    = 0xFFFF;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -309,7 +305,7 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 	if (mac->type == e1000_ich8lan)
 		e1000_set_kmrn_lock_loss_workaround_ich8lan(hw, 1);
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 static s32 e1000_get_invariants_ich8lan(struct e1000_adapter *adapter)
@@ -333,7 +329,7 @@ static s32 e1000_get_invariants_ich8lan(struct e1000_adapter *adapter)
 	    (adapter->hw.phy.type == e1000_phy_igp_3))
 		adapter->flags |= FLAG_LSC_GIG_SPEED_DROP;
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -348,7 +344,6 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 {
 	u32 extcnf_ctrl;
 	u32 timeout = PHY_CFG_TIMEOUT;
-	s32 ret_val = E1000_SUCCESS;
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
@@ -364,12 +359,10 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	if (!timeout) {
 		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -403,8 +396,7 @@ static s32 e1000_check_reset_block_ich8lan(struct e1000_hw *hw)
 
 	fwsm = er32(FWSM);
 
-	return (fwsm & E1000_ICH_FWSM_RSPCIPHY) ? E1000_SUCCESS
-						: E1000_BLK_PHY_RESET;
+	return (fwsm & E1000_ICH_FWSM_RSPCIPHY) ? 0 : E1000_BLK_PHY_RESET;
 }
 
 /**
@@ -424,30 +416,30 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 
 	if (phy->type != e1000_phy_ife) {
 		ret_val = e1000_phy_force_speed_duplex_igp(hw);
-		goto out;
+		return ret_val;
 	}
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	e1000_phy_force_speed_duplex_setup(hw, &data);
 
 	ret_val = e1e_wphy(hw, PHY_CONTROL, data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Disable MDI-X support for 10/100 */
 	ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	data &= ~IFE_PMC_AUTO_MDIX;
 	data &= ~IFE_PMC_FORCE_MDIX;
 
 	ret_val = e1e_wphy(hw, IFE_PHY_MDIX_CONTROL, data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	hw_dbg(hw, "IFE PMC: %X\n", data);
 
@@ -461,7 +453,7 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 						     100000,
 						     &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		if (!link)
 			hw_dbg(hw, "Link taking longer than expected.\n");
@@ -472,11 +464,10 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 						     100000,
 						     &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -498,7 +489,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000_phy_hw_reset_generic(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Initialize the PHY from the NVM on ICH platforms.  This
 	 * is needed due to an issue where the NVM configuration is
@@ -518,7 +509,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 
 		data = er32(FEXTNVM);
 		if (!(data & sw_cfg_mask))
-			goto out;
+			return 0;
 
 		/* Wait for basic configuration completes before proceeding*/
 		do {
@@ -544,13 +535,13 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 		 * extended configuration before SW configuration */
 		data = er32(EXTCNF_CTRL);
 		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
-			goto out;
+			return 0;
 
 		cnf_size = er32(EXTCNF_SIZE);
 		cnf_size &= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK;
 		cnf_size >>= E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT;
 		if (!cnf_size)
-			goto out;
+			return 0;
 
 		cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
 		cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
@@ -567,14 +558,14 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 						1,
 						&reg_data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			ret_val = e1000_read_nvm(hw,
 						(word_addr + i * 2 + 1),
 						1,
 						&reg_addr);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			/* Save off the PHY page for future writes. */
 			if (reg_addr == IGP01E1000_PHY_PAGE_SELECT) {
@@ -586,12 +577,11 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 
 			ret_val = e1e_wphy(hw, (u32)reg_addr, reg_data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -611,23 +601,22 @@ static s32 e1000_get_phy_info_ife_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (!link) {
 		hw_dbg(hw, "Phy info is only valid if link is up\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
 	ret_val = e1e_rphy(hw, IFE_PHY_SPECIAL_CONTROL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	phy->polarity_correction = (!(data & IFE_PSC_AUTO_POLARITY_DISABLE));
 
 	if (phy->polarity_correction) {
 		ret_val = e1000_check_polarity_ife_ich8lan(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	} else {
 		/* Polarity is forced */
 		phy->cable_polarity = (data & IFE_PSC_FORCE_POLARITY)
@@ -637,7 +626,7 @@ static s32 e1000_get_phy_info_ife_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy->is_mdix = (data & IFE_PMC_MDIX_STATUS);
 
@@ -646,8 +635,7 @@ static s32 e1000_get_phy_info_ife_ich8lan(struct e1000_hw *hw)
 	phy->local_rx = e1000_1000t_rx_status_undefined;
 	phy->remote_rx = e1000_1000t_rx_status_undefined;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -660,20 +648,18 @@ out:
  **/
 static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
 {
-	s32 ret_val = -E1000_ERR_PHY_TYPE;
-
 	switch (hw->phy.type) {
 	case e1000_phy_ife:
-		ret_val = e1000_get_phy_info_ife_ich8lan(hw);
+		return e1000_get_phy_info_ife_ich8lan(hw);
 		break;
 	case e1000_phy_igp_3:
-		ret_val = e1000_get_phy_info_igp(hw);
+		return e1000_get_phy_info_igp(hw);
 		break;
 	default:
 		break;
 	}
 
-	return ret_val;
+	return -E1000_ERR_PHY_TYPE;
 }
 
 /**
@@ -728,11 +714,11 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 phy_ctrl;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val = 0;
 	u16 data;
 
 	if (phy->type != e1000_phy_igp_3)
-		goto out;
+		return ret_val;
 
 	phy_ctrl = er32(PHY_CTRL);
 
@@ -751,7 +737,7 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 		ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG, data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	} else {
 		phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
@@ -764,29 +750,28 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						    &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						    &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -806,7 +791,7 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 phy_ctrl;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 data;
 
 	phy_ctrl = er32(PHY_CTRL);
@@ -823,27 +808,27 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 						    IGP01E1000_PHY_PORT_CONFIG,
 						    &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw,
 						     IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw,
 						    IGP01E1000_PHY_PORT_CONFIG,
 						    &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw,
 						     IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 	} else if ((phy->autoneg_advertised == E1000_ALL_SPEED_DUPLEX) ||
 		   (phy->autoneg_advertised == E1000_ALL_NOT_GIG) ||
@@ -862,7 +847,7 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 					    IGP01E1000_PHY_PORT_CONFIG,
 					    &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 		ret_val = e1e_wphy(hw,
@@ -870,8 +855,7 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 					     data);
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -889,19 +873,18 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 	u32 act_offset;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 i, word;
 
 	if ((offset >= nvm->word_size) || (words > nvm->word_size - offset) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Start with the bank offset, then add the relative offset. */
 	act_offset = (er32(EECD) & E1000_EECD_SEC1VAL)
@@ -925,7 +908,6 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	e1000_release_swflag_ich8lan(hw);
 
-out:
 	return ret_val;
 }
 
@@ -948,7 +930,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	if (hsfsts.hsf_status.fldesvalid == 0) {
 		hw_dbg(hw, "Flash descriptor invalid.  "
 			 "SW Sequencing must be used.");
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	/* Clear FCERR and DAEL in hw status by writing 1 */
@@ -971,19 +953,19 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 		/* Begin by setting Flash Cycle Done. */
 		hsfsts.hsf_status.flcdone = 1;
 		ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
-		ret_val = E1000_SUCCESS;
+		ret_val = 0;
 	} else {
 		/* otherwise poll for sometime so the current
 		 * cycle has a chance to end before giving up. */
 		for (i = 0; i < ICH_FLASH_READ_COMMAND_TIMEOUT; i++) {
 			hsfsts.regval = __er16flash(hw, ICH_FLASH_HSFSTS);
 			if (hsfsts.hsf_status.flcinprog == 0) {
-				ret_val = E1000_SUCCESS;
+				ret_val = 0;
 				break;
 			}
 			udelay(1);
 		}
-		if (ret_val == E1000_SUCCESS) {
+		if (ret_val == 0) {
 			/* Successful in waiting for previous cycle to timeout,
 			 * now set the Flash Cycle Done. */
 			hsfsts.hsf_status.flcdone = 1;
@@ -993,7 +975,6 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 		}
 	}
 
-out:
 	return ret_val;
 }
 
@@ -1025,7 +1006,7 @@ static s32 e1000_flash_cycle_ich8lan(struct e1000_hw *hw, u32 timeout)
 	} while (i++ < timeout);
 
 	if (hsfsts.hsf_status.flcdone == 1 && hsfsts.hsf_status.flcerr == 0)
-		ret_val = E1000_SUCCESS;
+		return 0;
 
 	return ret_val;
 }
@@ -1042,20 +1023,10 @@ static s32 e1000_flash_cycle_ich8lan(struct e1000_hw *hw, u32 timeout)
 static s32 e1000_read_flash_word_ich8lan(struct e1000_hw *hw, u32 offset,
 					 u16 *data)
 {
-	s32 ret_val;
-
-	if (!data) {
-		ret_val = -E1000_ERR_NVM;
-		goto out;
-	}
-
 	/* Must convert offset into bytes. */
 	offset <<= 1;
 
-	ret_val = e1000_read_flash_data_ich8lan(hw, offset, 2, data);
-
-out:
-	return ret_val;
+	return e1000_read_flash_data_ich8lan(hw, offset, 2, data);
 }
 
 /**
@@ -1078,7 +1049,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 	u8 count = 0;
 
 	if (size < 1  || size > 2 || offset > ICH_FLASH_LINEAR_ADDR_MASK)
-		goto out;
+		return -E1000_ERR_NVM;
 
 	flash_linear_addr = (ICH_FLASH_LINEAR_ADDR_MASK & offset) +
 			    hw->nvm.flash_base_addr;
@@ -1087,7 +1058,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		udelay(1);
 		/* Steps */
 		ret_val = e1000_flash_cycle_init_ich8lan(hw);
-		if (ret_val != E1000_SUCCESS)
+		if (ret_val != 0)
 			break;
 
 		hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
@@ -1105,7 +1076,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		 * and try the whole sequence a few more times, else
 		 * read in (shift in) the Flash Data0, the order is
 		 * least significant byte first msb to lsb */
-		if (ret_val == E1000_SUCCESS) {
+		if (ret_val == 0) {
 			flash_data = er32flash(ICH_FLASH_FDATA0);
 			if (size == 1) {
 				*data = (u8)(flash_data & 0x000000FF);
@@ -1131,7 +1102,6 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		}
 	} while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
 
-out:
 	return ret_val;
 }
 
@@ -1149,19 +1119,18 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 i;
 
 	if ((offset >= nvm->word_size) || (words > nvm->word_size - offset) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	for (i = 0; i < words; i++) {
 		dev_spec->shadow_ram[offset+i].modified = 1;
@@ -1170,8 +1139,7 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	e1000_release_swflag_ich8lan(hw);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1195,14 +1163,14 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000_update_nvm_checksum_generic(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;;
 
 	if (nvm->type != e1000_nvm_flash_sw)
-		goto out;
+		return ret_val;;
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;;
 
 	/* We're writing to the opposite bank so if we're on bank 1,
 	 * write to bank 0 etc.  We also need to erase the segment that
@@ -1262,7 +1230,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (ret_val) {
 		hw_dbg(hw, "Flash commit failed.\n");
 		e1000_release_swflag_ich8lan(hw);
-		goto out;
+		return ret_val;
 	}
 
 	/* Finally validate the new segment by setting bit 15:14
@@ -1277,7 +1245,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 						       (u8)(data >> 8));
 	if (ret_val) {
 		e1000_release_swflag_ich8lan(hw);
-		goto out;
+		return ret_val;
 	}
 
 	/* And invalidate the previously valid segment by setting
@@ -1288,7 +1256,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
 	if (ret_val) {
 		e1000_release_swflag_ich8lan(hw);
-		goto out;
+		return ret_val;
 	}
 
 	/* Great!  Everything worked, we can now clear the cached entries. */
@@ -1305,7 +1273,6 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	e1000_reload_nvm(hw);
 	msleep(10);
 
-out:
 	return ret_val;
 }
 
@@ -1319,7 +1286,7 @@ out:
  **/
 static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 data;
 
 	/* Read 0x19 and check bit 6.  If this bit is 0, the checksum
@@ -1329,22 +1296,19 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1000_read_nvm(hw, 0x19, 1, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if ((data & 0x40) == 0) {
 		data |= 0x40;
 		ret_val = e1000_write_nvm(hw, 0x19, 1, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 		ret_val = e1000_update_nvm_checksum(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
-	ret_val = e1000_validate_nvm_checksum_generic(hw);
-
-out:
-	return ret_val;
+	return e1000_validate_nvm_checksum_generic(hw);
 }
 
 /**
@@ -1363,12 +1327,12 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 	union ich8_hws_flash_ctrl hsflctl;
 	u32 flash_linear_addr;
 	u32 flash_data = 0;
-	s32 ret_val = -E1000_ERR_NVM;
+	s32 ret_val;
 	u8 count = 0;
 
 	if (size < 1 || size > 2 || data > size * 0xff ||
 	    offset > ICH_FLASH_LINEAR_ADDR_MASK)
-		goto out;
+		return -E1000_ERR_NVM;
 
 	flash_linear_addr = (ICH_FLASH_LINEAR_ADDR_MASK & offset) +
 			    hw->nvm.flash_base_addr;
@@ -1377,7 +1341,7 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		udelay(1);
 		/* Steps */
 		ret_val = e1000_flash_cycle_init_ich8lan(hw);
-		if (ret_val != E1000_SUCCESS)
+		if (ret_val)
 			break;
 
 		hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
@@ -1399,27 +1363,25 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		 * and try the whole sequence a few more times else done */
 		ret_val = e1000_flash_cycle_ich8lan(hw,
 					       ICH_FLASH_WRITE_COMMAND_TIMEOUT);
-		if (ret_val == E1000_SUCCESS) {
+		if (!ret_val)
+			break;
+
+		/* If we're here, then things are most likely
+		 * completely hosed, but if the error condition
+		 * is detected, it won't hurt to give it another
+		 * try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
+		 */
+		hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
+		if (hsfsts.hsf_status.flcerr == 1)
+			/* Repeat for some time before giving up. */
+			continue;
+		if (hsfsts.hsf_status.flcdone == 0) {
+			hw_dbg(hw, "Timeout error - flash cycle "
+				 "did not complete.");
 			break;
-		} else {
-			/* If we're here, then things are most likely
-			 * completely hosed, but if the error condition
-			 * is detected, it won't hurt to give it another
-			 * try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
-			 */
-			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-			if (hsfsts.hsf_status.flcerr == 1) {
-				/* Repeat for some time before giving up. */
-				continue;
-			} else if (hsfsts.hsf_status.flcdone == 0) {
-				hw_dbg(hw, "Timeout error - flash cycle "
-					 "did not complete.");
-				break;
-			}
 		}
 	} while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
 
-out:
 	return ret_val;
 }
 
@@ -1455,23 +1417,20 @@ static s32 e1000_retry_write_flash_byte_ich8lan(struct e1000_hw *hw,
 	u16 program_retries;
 
 	ret_val = e1000_write_flash_byte_ich8lan(hw, offset, byte);
-	if (ret_val == E1000_SUCCESS)
-		goto out;
+	if (!ret_val)
+		return ret_val;
 
 	for (program_retries = 0; program_retries < 100; program_retries++) {
 		hw_dbg(hw, "Retrying Byte %2.2X at offset %u\n", byte, offset);
 		udelay(100);
 		ret_val = e1000_write_flash_byte_ich8lan(hw, offset, byte);
-		if (ret_val == E1000_SUCCESS)
+		if (!ret_val)
 			break;
 	}
-	if (program_retries == 100) {
-		ret_val = -E1000_ERR_NVM;
-		goto out;
-	}
+	if (program_retries == 100)
+		return -E1000_ERR_NVM;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1490,9 +1449,11 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 	u32 flash_linear_addr;
 	/* bank size is in 16bit words - adjust to bytes */
 	u32 flash_bank_size = nvm->flash_bank_size * 2;
-	s32  ret_val = E1000_SUCCESS;
-	s32  count = 0;
-	s32  j, iteration, sector_size;
+	s32 ret_val;
+	s32 count = 0;
+	s32 iteration;
+	s32 sector_size;
+	s32 j;
 
 	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 
@@ -1523,8 +1484,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			sector_size = ICH_FLASH_SEG_SIZE_8K;
 			iteration = flash_bank_size / ICH_FLASH_SEG_SIZE_8K;
 		} else {
-			ret_val = -E1000_ERR_NVM;
-			goto out;
+			return -E1000_ERR_NVM;
 		}
 		break;
 	case 3:
@@ -1532,8 +1492,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 		iteration = flash_bank_size / ICH_FLASH_SEG_SIZE_64K;
 		break;
 	default:
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	/* Start with the base address, then add the sector offset. */
@@ -1545,7 +1504,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			/* Steps */
 			ret_val = e1000_flash_cycle_init_ich8lan(hw);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			/* Write a value 11 (block Erase) in Flash
 			 * Cycle field in hw flash control */
@@ -1562,25 +1521,23 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 
 			ret_val = e1000_flash_cycle_ich8lan(hw,
 					       ICH_FLASH_ERASE_COMMAND_TIMEOUT);
-			if (ret_val == E1000_SUCCESS) {
+			if (ret_val == 0)
 				break;
-			} else {
-				/* Check if FCERR is set to 1.  If 1,
-				 * clear it and try the whole sequence
-				 * a few more times else Done */
-				hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-				if (hsfsts.hsf_status.flcerr == 1) {
-					/* repeat for some time before
-					 * giving up */
-					continue;
-				} else if (hsfsts.hsf_status.flcdone == 0)
-					goto out;
-			}
+
+			/* Check if FCERR is set to 1.  If 1,
+			 * clear it and try the whole sequence
+			 * a few more times else Done */
+			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
+			if (hsfsts.hsf_status.flcerr == 1)
+				/* repeat for some time before
+				 * giving up */
+				continue;
+			else if (hsfsts.hsf_status.flcdone == 0)
+				return ret_val;
 		} while (++count < ICH_FLASH_CYCLE_REPEAT_COUNT);
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1599,15 +1556,14 @@ static s32 e1000_valid_led_default_ich8lan(struct e1000_hw *hw, u16 *data)
 	ret_val = e1000_read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
-		goto out;
+		return ret_val;
 	}
 
 	if (*data == ID_LED_RESERVED_0000 ||
 	    *data == ID_LED_RESERVED_FFFF)
 		*data = ID_LED_DEFAULT_ICH8LAN;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1735,7 +1691,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	ret_val = e1000_id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
-		goto out;
+		return ret_val;
 	}
 
 	/* Setup the receive address. */
@@ -1782,8 +1738,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	 */
 	e1000_clear_hw_cntrs_ich8lan(hw);
 
-out:
-	return ret_val;
+	return 0;
 }
 /**
  *  e1000_initialize_hw_bits_ich8lan - Initialize required hardware bits
@@ -1848,10 +1803,10 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	if (e1000_check_reset_block(hw))
-		goto out;
+		return 0;
 
 	/* ICH parts do not have a word in the NVM to determine
 	 * the default flow control setting, so we explicitly
@@ -1867,14 +1822,11 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	/* Continue to configure the copper link. */
 	ret_val = e1000_setup_copper_link_ich8lan(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ew32(FCTTV, mac->fc_pause_time);
 
-	ret_val = e1000_set_fc_watermarks(hw);
-
-out:
-	return ret_val;
+	return e1000_set_fc_watermarks(hw);
 }
 
 /**
@@ -1901,25 +1853,22 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	 * this fixes erroneous timeouts at 10Mbps. */
 	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	ret_val = e1000_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 	reg_data |= 0x3F;
 	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (hw->phy.type == e1000_phy_igp_3) {
 		ret_val = e1000_copper_link_setup_igp(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
-	ret_val = e1000_setup_copper_link(hw);
-
-out:
-	return ret_val;
+	return e1000_setup_copper_link(hw);
 }
 
 /**
@@ -1939,7 +1888,7 @@ static s32 e1000_get_link_up_info_ich8lan(struct e1000_hw *hw, u16 *speed,
 
 	ret_val = e1000_get_speed_and_duplex_copper(hw, speed, duplex);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if ((hw->mac.type == e1000_ich8lan) &&
 	    (hw->phy.type == e1000_phy_igp_3) &&
@@ -1947,7 +1896,6 @@ static s32 e1000_get_link_up_info_ich8lan(struct e1000_hw *hw, u16 *speed,
 		ret_val = e1000_kmrn_lock_loss_workaround_ich8lan(hw);
 	}
 
-out:
 	return ret_val;
 }
 
@@ -1970,37 +1918,33 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 	u32 phy_ctrl;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 i, data;
 	bool link;
 
 	if (!dev_spec->kmrn_lock_loss_workaround_enabled)
-		goto out;
+		return 0;
 
 	/* Make sure link is up before proceeding.  If not just return.
 	 * Attempting this while link is negotiating fouled up link
 	 * stability */
 	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
-	if (!link) {
-		ret_val = E1000_SUCCESS;
-		goto out;
-	}
+	if (!link)
+		return 0;
 
 	for (i = 0; i < 10; i++) {
 		/* read once to clear */
 		ret_val = e1e_rphy(hw, IGP3_KMRN_DIAG, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 		/* and again to get new status */
 		ret_val = e1e_rphy(hw, IGP3_KMRN_DIAG, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		/* check for PCS lock */
-		if (!(data & IGP3_KMRN_DIAG_PCS_LOCK_LOSS)) {
-			ret_val = E1000_SUCCESS;
-			goto out;
-		}
+		if (!(data & IGP3_KMRN_DIAG_PCS_LOCK_LOSS))
+			return 0;
 
 		/* Issue PHY reset */
 		e1000_phy_hw_reset(hw);
@@ -2017,10 +1961,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 	e1000_gig_downshift_workaround_ich8lan(hw);
 
 	/* unable to acquire PCS lock */
-	ret_val = -E1000_ERR_PHY;
-
-out:
-	return ret_val;
+	return -E1000_ERR_PHY;
 }
 
 /**
@@ -2038,13 +1979,10 @@ void e1000_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 
 	if (hw->mac.type != e1000_ich8lan) {
 		hw_dbg(hw, "Workaround applies to ICH8 only.\n");
-		goto out;
+		return;
 	}
 
 	dev_spec->kmrn_lock_loss_workaround_enabled = state;
-
-out:
-	return;
 }
 
 /**
@@ -2064,7 +2002,7 @@ void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 	u8  retry = 0;
 
 	if (hw->phy.type != e1000_phy_igp_3)
-		goto out;
+		return;
 
 	/* Try the workaround twice (if needed) */
 	do {
@@ -2095,9 +2033,6 @@ void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 		ew32(CTRL, reg | E1000_CTRL_PHY_RST);
 		retry++;
 	} while (retry);
-
-out:
-	return;
 }
 
 /**
@@ -2112,27 +2047,25 @@ out:
  **/
 void e1000_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 reg_data;
 
 	if ((hw->mac.type != e1000_ich8lan) ||
 	    (hw->phy.type != e1000_phy_igp_3))
-		goto out;
+		return;
 
 	ret_val = e1000_read_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
 				      &reg_data);
 	if (ret_val)
-		goto out;
+		return;
 	reg_data |= E1000_KMRNCTRLSTA_DIAG_NELPBK;
 	ret_val = e1000_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
 				       reg_data);
 	if (ret_val)
-		goto out;
+		return;
 	reg_data &= ~E1000_KMRNCTRLSTA_DIAG_NELPBK;
 	ret_val = e1000_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
 				       reg_data);
-out:
-	return;
 }
 
 /**
@@ -2143,14 +2076,11 @@ out:
  **/
 static s32 e1000_cleanup_led_ich8lan(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
-
 	if (hw->phy.type == e1000_phy_ife)
-		ret_val = e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
-	else
-		ew32(LEDCTL, hw->mac.ledctl_default);
+		return e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
 
-	return ret_val;
+	ew32(LEDCTL, hw->mac.ledctl_default);
+	return 0;
 }
 
 /**
@@ -2161,15 +2091,12 @@ static s32 e1000_cleanup_led_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_led_on_ich8lan(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
-
 	if (hw->phy.type == e1000_phy_ife)
-		ret_val = e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED,
+		return e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED,
 				(IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_ON));
-	else
-		ew32(LEDCTL, hw->mac.ledctl_mode2);
 
-	return ret_val;
+	ew32(LEDCTL, hw->mac.ledctl_mode2);
+	return 0;
 }
 
 /**
@@ -2180,16 +2107,12 @@ static s32 e1000_led_on_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_led_off_ich8lan(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
-
 	if (hw->phy.type == e1000_phy_ife)
-		ret_val = e1e_wphy(hw,
-			       IFE_PHY_SPECIAL_CONTROL_LED,
+		return e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED,
 			       (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_OFF));
-	else
-		ew32(LEDCTL, hw->mac.ledctl_mode1);
 
-	return ret_val;
+	ew32(LEDCTL, hw->mac.ledctl_mode1);
+	return 0;
 }
 
 /**
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 21c16e0..d11b518 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -81,7 +81,7 @@ s32 e1000_get_bus_info_pcie(struct e1000_hw *hw)
 		bus->func = 0;
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -378,10 +378,8 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 	 * get_link_status flag is set upon receiving a Link Status
 	 * Change or Rx Sequence Error interrupt.
 	 */
-	if (!mac->get_link_status) {
-		ret_val = E1000_SUCCESS;
-		goto out;
-	}
+	if (!mac->get_link_status)
+		return 0;
 
 	/* First we want to see if the MII Status Register reports
 	 * link.  If so, then we want to get the current speed/duplex
@@ -389,10 +387,10 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 	 */
 	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (!link)
-		goto out; /* No link detected */
+		return ret_val; /* No link detected */
 
 	mac->get_link_status = 0;
 
@@ -405,7 +403,7 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 	 */
 	if (!mac->autoneg) {
 		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return ret_val;
 	}
 
 	/* Auto-Neg is enabled.  Auto Speed Detection takes care
@@ -424,7 +422,6 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 		hw_dbg(hw, "Error configuring flow control\n");
 	}
 
-out:
 	return ret_val;
 }
 
@@ -441,7 +438,7 @@ s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
 	u32 rxcw;
 	u32 ctrl;
 	u32 status;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	ctrl = er32(CTRL);
 	status = er32(STATUS);
@@ -459,7 +456,7 @@ s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
 	    (!(rxcw & E1000_RXCW_C))) {
 		if (mac->autoneg_failed == 0) {
 			mac->autoneg_failed = 1;
-			goto out;
+			return 0;
 		}
 		hw_dbg(hw, "NOT RXing /C/, disable AutoNeg and force link.\n");
 
@@ -475,7 +472,7 @@ s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
 		ret_val = e1000_config_fc_after_link_up(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error configuring flow control\n");
-			goto out;
+			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
 		/* If we are forcing link and we are receiving /C/ ordered
@@ -490,8 +487,7 @@ s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
 		mac->serdes_has_link = 1;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -507,7 +503,7 @@ s32 e1000_check_for_serdes_link(struct e1000_hw *hw)
 	u32 rxcw;
 	u32 ctrl;
 	u32 status;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	ctrl = er32(CTRL);
 	status = er32(STATUS);
@@ -523,7 +519,7 @@ s32 e1000_check_for_serdes_link(struct e1000_hw *hw)
 	if ((!(status & E1000_STATUS_LU)) && (!(rxcw & E1000_RXCW_C))) {
 		if (mac->autoneg_failed == 0) {
 			mac->autoneg_failed = 1;
-			goto out;
+			return 0;
 		}
 		hw_dbg(hw, "NOT RXing /C/, disable AutoNeg and force link.\n");
 
@@ -539,7 +535,7 @@ s32 e1000_check_for_serdes_link(struct e1000_hw *hw)
 		ret_val = e1000_config_fc_after_link_up(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error configuring flow control\n");
-			goto out;
+			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
 		/* If we are forcing link and we are receiving /C/ ordered
@@ -575,8 +571,7 @@ s32 e1000_check_for_serdes_link(struct e1000_hw *hw)
 		mac->serdes_has_link = (status & E1000_STATUS_LU);
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -589,11 +584,11 @@ out:
 static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 nvm_data;
 
 	if (mac->fc != e1000_fc_default)
-		goto out;
+		return 0;
 
 	/* Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
@@ -607,7 +602,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
-		goto out;
+		return ret_val;
 	}
 
 	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
@@ -618,8 +613,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	else
 		mac->fc = e1000_fc_full;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -635,17 +629,17 @@ out:
 s32 e1000_setup_link(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	/* In the case of the phy reset being blocked, we already have a link.
 	 * We do not need to set it up again.
 	 */
 	if (e1000_check_reset_block(hw))
-		goto out;
+		return 0;
 
 	ret_val = e1000_set_default_fc_generic(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* We want to save off the original Flow Control configuration just
 	 * in case we get disconnected and then reconnected into a different
@@ -658,7 +652,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = mac->ops.setup_physical_interface(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Initialize the flow control address, type, and PAUSE timer
 	 * registers to their default values.  This is done even if flow
@@ -672,10 +666,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 
 	ew32(FCTTV, mac->fc_pause_time);
 
-	ret_val = e1000_set_fc_watermarks(hw);
-
-out:
-	return ret_val;
+	return e1000_set_fc_watermarks(hw);
 }
 
 /**
@@ -689,7 +680,6 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 txcw;
-	s32 ret_val = E1000_SUCCESS;
 
 	/* Check for a software override of the flow control settings, and
 	 * setup the device accordingly.  If auto-negotiation is enabled, then
@@ -736,16 +726,14 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 		break;
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 		break;
 	}
 
 	ew32(TXCW, txcw);
 	mac->txcw = txcw;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -759,7 +747,7 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 i, status;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	/* If we have a signal (the cable is plugged in, or assumed true for
 	 * serdes media) then poll for a "Link-Up" indication in the Device
@@ -784,7 +772,7 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 		ret_val = mac->ops.check_for_link(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error while checking for link\n");
-			goto out;
+			return ret_val;
 		}
 		mac->autoneg_failed = 0;
 	} else {
@@ -792,8 +780,7 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 		hw_dbg(hw, "Valid Link Found\n");
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -806,7 +793,7 @@ out:
 s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
 	u32 ctrl;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	ctrl = er32(CTRL);
 
@@ -817,7 +804,7 @@ s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 
 	ret_val = e1000_commit_fc_settings_generic(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Since auto-negotiation is enabled, take the link out of reset (the
 	 * link will be in reset, because we previously reset the chip). This
@@ -842,8 +829,7 @@ s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 		hw_dbg(hw, "No signal detected\n");
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -878,7 +864,6 @@ void e1000_config_collision_dist(struct e1000_hw *hw)
 s32 e1000_set_fc_watermarks(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	s32 ret_val = E1000_SUCCESS;
 	u32 fcrtl = 0, fcrth = 0;
 
 	/* Set the flow control receive threshold registers.  Normally,
@@ -894,13 +879,12 @@ s32 e1000_set_fc_watermarks(struct e1000_hw *hw)
 		 */
 		fcrtl = mac->fc_low_water;
 		fcrtl |= E1000_FCRTL_XONE;
-
 		fcrth = mac->fc_high_water;
 	}
 	ew32(FCRTL, fcrtl);
 	ew32(FCRTH, fcrth);
 
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -917,7 +901,6 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 ctrl;
-	s32 ret_val = E1000_SUCCESS;
 
 	ctrl = er32(CTRL);
 
@@ -957,14 +940,12 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
 		break;
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
 	ew32(CTRL, ctrl);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -980,7 +961,7 @@ out:
 s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val = 0;
 	u16 mii_status_reg, mii_nway_adv_reg, mii_nway_lp_ability_reg;
 	u16 speed, duplex;
 
@@ -999,7 +980,7 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 
 	if (ret_val) {
 		hw_dbg(hw, "Error forcing flow control settings\n");
-		goto out;
+		return ret_val;
 	}
 
 	/* Check for the case where we have copper media and auto-neg is
@@ -1014,15 +995,15 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = e1e_rphy(hw, PHY_STATUS, &mii_status_reg);
 		if (ret_val)
-			goto out;
+			return ret_val;
 		ret_val = e1e_rphy(hw, PHY_STATUS, &mii_status_reg);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
 			hw_dbg(hw, "Copper PHY and Auto Neg "
 				 "has not completed.\n");
-			goto out;
+			return ret_val;
 		}
 
 		/* The AutoNeg process has completed, so we now need to
@@ -1033,10 +1014,10 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = e1e_rphy(hw, PHY_AUTONEG_ADV, &mii_nway_adv_reg);
 		if (ret_val)
-			goto out;
+			return ret_val;
 		ret_val = e1e_rphy(hw, PHY_LP_ABILITY, &mii_nway_lp_ability_reg);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		/* Two bits in the Auto Negotiation Advertisement Register
 		 * (Address 4) and two bits in the Auto Negotiation Base
@@ -1155,7 +1136,7 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 		ret_val = mac->ops.get_link_up_info(hw, &speed, &duplex);
 		if (ret_val) {
 			hw_dbg(hw, "Error getting link speed and duplex\n");
-			goto out;
+			return ret_val;
 		}
 
 		if (duplex == HALF_DUPLEX)
@@ -1167,12 +1148,11 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 		ret_val = e1000_force_mac_fc(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error forcing flow control settings\n");
-			goto out;
+			return ret_val;
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1208,7 +1188,7 @@ s32 e1000_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dupl
 		hw_dbg(hw, "Half Duplex\n");
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -1225,7 +1205,7 @@ s32 e1000_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16
 	*speed = SPEED_1000;
 	*duplex = FULL_DUPLEX;
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -1237,7 +1217,6 @@ s32 e1000_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16
 s32 e1000_get_hw_semaphore(struct e1000_hw *hw)
 {
 	u32 swsm;
-	s32 ret_val = E1000_SUCCESS;
 	s32 timeout = hw->nvm.word_size + 1;
 	s32 i = 0;
 
@@ -1253,8 +1232,7 @@ s32 e1000_get_hw_semaphore(struct e1000_hw *hw)
 
 	if (i == timeout) {
 		hw_dbg(hw, "Driver can't access device - SMBI bit is set.\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	/* Get the FW semaphore. */
@@ -1273,12 +1251,10 @@ s32 e1000_get_hw_semaphore(struct e1000_hw *hw)
 		/* Release semaphores */
 		e1000_put_hw_semaphore(hw);
 		hw_dbg(hw, "Driver can't access the NVM\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1292,9 +1268,7 @@ void e1000_put_hw_semaphore(struct e1000_hw *hw)
 	u32 swsm;
 
 	swsm = er32(SWSM);
-
 	swsm &= ~(E1000_SWSM_SMBI | E1000_SWSM_SWESMBI);
-
 	ew32(SWSM, swsm);
 }
 
@@ -1307,7 +1281,6 @@ void e1000_put_hw_semaphore(struct e1000_hw *hw)
 s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
 	s32 i = 0;
-	s32 ret_val = E1000_SUCCESS;
 
 	while (i < AUTO_READ_DONE_TIMEOUT) {
 		if (er32(EECD) & E1000_EECD_AUTO_RD)
@@ -1318,12 +1291,10 @@ s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 
 	if (i == AUTO_READ_DONE_TIMEOUT) {
 		hw_dbg(hw, "Auto read by HW from NVM has not completed.\n");
-		ret_val = -E1000_ERR_RESET;
-		goto out;
+		return -E1000_ERR_RESET;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1341,14 +1312,13 @@ s32 e1000_valid_led_default(struct e1000_hw *hw, u16 *data)
 	ret_val = e1000_read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
-		goto out;
+		return ret_val;
 	}
 
 	if (*data == ID_LED_RESERVED_0000 || *data == ID_LED_RESERVED_FFFF)
 		*data = ID_LED_DEFAULT;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1368,7 +1338,7 @@ s32 e1000_id_led_init(struct e1000_hw *hw)
 
 	ret_val = hw->nvm.ops.valid_led_default(hw, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	mac->ledctl_default = er32(LEDCTL);
 	mac->ledctl_mode1 = mac->ledctl_default;
@@ -1412,8 +1382,7 @@ s32 e1000_id_led_init(struct e1000_hw *hw)
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1426,8 +1395,7 @@ out:
 s32 e1000_cleanup_led_generic(struct e1000_hw *hw)
 {
 	ew32(LEDCTL, hw->mac.ledctl_default);
-
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -1458,7 +1426,7 @@ s32 e1000_blink_led(struct e1000_hw *hw)
 
 	ew32(LEDCTL, ledctl_blink);
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -1485,7 +1453,7 @@ s32 e1000_led_on_generic(struct e1000_hw *hw)
 		break;
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -1512,7 +1480,7 @@ s32 e1000_led_off_generic(struct e1000_hw *hw)
 		break;
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -1538,7 +1506,7 @@ void e1000_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
  *  e1000_disable_pcie_master - Disables PCI-express master access
  *  @hw: pointer to the HW structure
  *
- *  Returns 0 (E1000_SUCCESS) if successful, else returns -10
+ *  Returns 0 if successful, else returns -10
  *  (-E1000_ERR_MASTER_REQUESTS_PENDING) if master disable bit has not casued
  *  the master requests to be disabled.
  *
@@ -1549,7 +1517,6 @@ s32 e1000_disable_pcie_master(struct e1000_hw *hw)
 {
 	u32 ctrl;
 	s32 timeout = MASTER_DISABLE_TIMEOUT;
-	s32 ret_val = E1000_SUCCESS;
 
 	ctrl = er32(CTRL);
 	ctrl |= E1000_CTRL_GIO_MASTER_DISABLE;
@@ -1565,12 +1532,10 @@ s32 e1000_disable_pcie_master(struct e1000_hw *hw)
 
 	if (!timeout) {
 		hw_dbg(hw, "Master requests are pending.\n");
-		ret_val = -E1000_ERR_MASTER_REQUESTS_PENDING;
-		goto out;
+		return -E1000_ERR_MASTER_REQUESTS_PENDING;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1748,7 +1713,6 @@ s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
 {
 	u32 attempts = 100000;
 	u32 i, reg = 0;
-	s32 ret_val = -E1000_ERR_NVM;
 
 	for (i = 0; i < attempts; i++) {
 		if (ee_reg == E1000_NVM_POLL_READ)
@@ -1756,15 +1720,13 @@ s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
 		else
 			reg = er32(EEWR);
 
-		if (reg & E1000_NVM_RW_REG_DONE) {
-			ret_val = E1000_SUCCESS;
-			break;
-		}
+		if (reg & E1000_NVM_RW_REG_DONE)
+			return 0;
 
 		udelay(5);
 	}
 
-	return ret_val;
+	return -E1000_ERR_NVM;
 }
 
 /**
@@ -1779,7 +1741,6 @@ s32 e1000_acquire_nvm(struct e1000_hw *hw)
 {
 	u32 eecd = er32(EECD);
 	s32 timeout = E1000_NVM_GRANT_ATTEMPTS;
-	s32 ret_val = E1000_SUCCESS;
 
 	ew32(EECD, eecd | E1000_EECD_REQ);
 	eecd = er32(EECD);
@@ -1796,10 +1757,10 @@ s32 e1000_acquire_nvm(struct e1000_hw *hw)
 		eecd &= ~E1000_EECD_REQ;
 		ew32(EECD, eecd);
 		hw_dbg(hw, "Could not acquire NVM grant\n");
-		ret_val = -E1000_ERR_NVM;
+		return -E1000_ERR_NVM;
 	}
 
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1871,7 +1832,6 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 eecd = er32(EECD);
-	s32 ret_val = E1000_SUCCESS;
 	u16 timeout = 0;
 	u8 spi_stat_reg;
 
@@ -1900,13 +1860,11 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 
 		if (!timeout) {
 			hw_dbg(hw, "SPI NVM Status error\n");
-			ret_val = -E1000_ERR_NVM;
-			goto out;
+			return -E1000_ERR_NVM;
 		}
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1931,17 +1889,18 @@ s32 e1000_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	ret_val = nvm->ops.acquire_nvm(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_ready_nvm_eeprom(hw);
-	if (ret_val)
-		goto release;
+	if (ret_val) {
+		nvm->ops.release_nvm(hw);
+		return ret_val;
+	}
 
 	e1000_standby_nvm(hw);
 
@@ -1960,11 +1919,8 @@ s32 e1000_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		data[i] = (word_in >> 8) | (word_in << 8);
 	}
 
-release:
 	nvm->ops.release_nvm(hw);
-
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1980,15 +1936,14 @@ s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 i, eerd = 0;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 
 	/* A check for invalid values:  offset too large, too many words,
 	 * and not enough words. */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	for (i = 0; i < words; i++) {
@@ -2004,7 +1959,6 @@ s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 			   E1000_NVM_RW_REG_DATA);
 	}
 
-out:
 	return ret_val;
 }
 
@@ -2031,13 +1985,12 @@ s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
 	ret_val = nvm->ops.acquire_nvm(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	msleep(10);
 
@@ -2045,8 +1998,10 @@ s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
 
 		ret_val = e1000_ready_nvm_eeprom(hw);
-		if (ret_val)
-			goto release;
+		if (ret_val) {
+			nvm->ops.release_nvm(hw);
+			return ret_val;
+		}
 
 		e1000_standby_nvm(hw);
 
@@ -2081,11 +2036,7 @@ s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	}
 
 	msleep(10);
-release:
-	nvm->ops.release_nvm(hw);
-
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2098,7 +2049,7 @@ out:
  **/
 s32 e1000_read_mac_addr(struct e1000_hw *hw)
 {
-	s32  ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 offset, nvm_data, i;
 
 	for (i = 0; i < ETH_ALEN; i += 2) {
@@ -2106,7 +2057,7 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
 		ret_val = e1000_read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg(hw, "NVM Read Error\n");
-			goto out;
+			return ret_val;
 		}
 		hw->mac.perm_addr[i] = (u8)(nvm_data & 0xFF);
 		hw->mac.perm_addr[i+1] = (u8)(nvm_data >> 8);
@@ -2119,8 +2070,7 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
 	for (i = 0; i < ETH_ALEN; i++)
 		hw->mac.addr[i] = hw->mac.perm_addr[i];
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2132,7 +2082,7 @@ out:
  **/
 s32 e1000_validate_nvm_checksum_generic(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 checksum = 0;
 	u16 i, nvm_data;
 
@@ -2140,19 +2090,17 @@ s32 e1000_validate_nvm_checksum_generic(struct e1000_hw *hw)
 		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg(hw, "NVM Read Error\n");
-			goto out;
+			return ret_val;
 		}
 		checksum += nvm_data;
 	}
 
 	if (checksum != (u16) NVM_SUM) {
 		hw_dbg(hw, "NVM Checksum Invalid\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return -E1000_ERR_NVM;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2165,7 +2113,7 @@ out:
  **/
 s32 e1000_update_nvm_checksum_generic(struct e1000_hw *hw)
 {
-	s32  ret_val;
+	s32 ret_val;
 	u16 checksum = 0;
 	u16 i, nvm_data;
 
@@ -2173,17 +2121,15 @@ s32 e1000_update_nvm_checksum_generic(struct e1000_hw *hw)
 		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg(hw, "NVM Read Error while updating checksum.\n");
-			goto out;
+			return ret_val;
 		}
 		checksum += nvm_data;
 	}
 	checksum = (u16) NVM_SUM - checksum;
 	ret_val = e1000_write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
-	if (ret_val) {
+	if (ret_val)
 		hw_dbg(hw, "NVM Write Error while updating checksum.\n");
-	}
 
-out:
 	return ret_val;
 }
 
@@ -2240,15 +2186,13 @@ static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
 static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 {
 	u32 hicr;
-	s32 ret_val = E1000_SUCCESS;
-	u8  i;
+	u8 i;
 
 	/* Check that the host interface is enabled. */
 	hicr = er32(HICR);
 	if ((hicr & E1000_HICR_EN) == 0) {
 		hw_dbg(hw, "E1000_HOST_EN bit disabled.\n");
-		ret_val = -E1000_ERR_HOST_INTERFACE_COMMAND;
-		goto out;
+		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 	/* check the previous command is completed */
 	for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
@@ -2260,12 +2204,10 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 
 	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
 		hw_dbg(hw, "Previous command timeout failed .\n");
-		ret_val = -E1000_ERR_HOST_INTERFACE_COMMAND;
-		goto out;
+		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2296,21 +2238,20 @@ bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	u32 offset;
 	s32 ret_val, hdr_csum, csum;
 	u8 i, len;
-	bool tx_filter = 1;
 
 	/* No manageability, no filtering */
 	if (!e1000_check_mng_mode(hw)) {
-		tx_filter = 0;
-		goto out;
+		hw->mac.tx_pkt_filtering = 0;
+		return 0;
 	}
 
 	/* If we can't read from the host interface for whatever
 	 * reason, disable filtering.
 	 */
 	ret_val = e1000_mng_enable_host_if(hw);
-	if (ret_val != E1000_SUCCESS) {
-		tx_filter = 0;
-		goto out;
+	if (ret_val != 0) {
+		hw->mac.tx_pkt_filtering = 0;
+		return ret_val;
 	}
 
 	/* Read in the header.  Length and offset are in dwords. */
@@ -2326,18 +2267,19 @@ bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	 * the cookie area isn't considered valid, in which case we
 	 * take the safe route of assuming Tx filtering is enabled.
 	 */
-	if (hdr_csum != csum)
-		goto out;
-	if (hdr->signature != E1000_IAMT_SIGNATURE)
-		goto out;
+	if ((hdr_csum != csum) || (hdr->signature != E1000_IAMT_SIGNATURE)) {
+		hw->mac.tx_pkt_filtering = 1;
+		return 1;
+	}
 
 	/* Cookie area is valid, make the final check for filtering. */
-	if (!(hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING))
-		tx_filter = 0;
+	if (!(hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING)) {
+		hw->mac.tx_pkt_filtering = 0;
+		return 0;
+	}
 
-out:
-	hw->mac.tx_pkt_filtering = tx_filter;
-	return tx_filter;
+	hw->mac.tx_pkt_filtering = 1;
+	return 1;
 }
 
 /**
@@ -2364,7 +2306,7 @@ s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
 		e1e_flush();
 	}
 
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /**
@@ -2385,15 +2327,12 @@ static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
 	u8 *tmp;
 	u8 *bufptr = buffer;
 	u32 data = 0;
-	s32 ret_val = E1000_SUCCESS;
 	u16 remaining, i, j, prev_bytes;
 
 	/* sum = only sum of the data and it is not checksum */
 
-	if (length == 0 || offset + length > E1000_HI_MAX_MNG_DATA_LENGTH) {
-		ret_val = -E1000_ERR_PARAM;
-		goto out;
-	}
+	if (length == 0 || offset + length > E1000_HI_MAX_MNG_DATA_LENGTH)
+		return -E1000_ERR_PARAM;
 
 	tmp = (u8 *)&data;
 	prev_bytes = offset & 0x3;
@@ -2438,8 +2377,7 @@ static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
 		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset + i, data);
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2465,25 +2403,24 @@ s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
 	/* Enable the host interface */
 	ret_val = e1000_mng_enable_host_if(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Populate the host interface with the contents of "buffer". */
 	ret_val = e1000_mng_host_if_write(hw, buffer, length,
 					  sizeof(hdr), &(hdr.checksum));
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Write the manageability command header */
 	ret_val = e1000_mng_write_cmd_header(hw, &hdr);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Tell the ARC a new command is pending. */
 	hicr = er32(HICR);
 	ew32(HICR, hicr | E1000_HICR_C);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2502,7 +2439,7 @@ bool e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 
 	if (!(manc & E1000_MANC_RCV_TCO_EN) ||
 	    !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
-		goto out;
+		return ret_val;
 
 	if (hw->mac.arc_subsystem_valid) {
 		fwsm = er32(FWSM);
@@ -2512,17 +2449,16 @@ bool e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 		    ((fwsm & E1000_FWSM_MODE_MASK) ==
 		     (e1000_mng_mode_pt << E1000_FWSM_MODE_SHIFT))) {
 			ret_val = 1;
-			goto out;
+			return ret_val;
 		}
 	} else {
 		if ((manc & E1000_MANC_SMBUS_EN) &&
 		    !(manc & E1000_MANC_ASF_EN)) {
 			ret_val = 1;
-			goto out;
+			return ret_val;
 		}
 	}
 
-out:
 	return ret_val;
 }
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 2d0e78c..c8d50cc 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2584,7 +2584,7 @@ static int e1000_open(struct net_device *netdev)
 	/* fire a link status change interrupt to start the watchdog */
 	ew32(ICS, E1000_ICS_LSC);
 
-	return E1000_SUCCESS;
+	return 0;
 
 err_req_irq:
 	e1000_release_hw_control(adapter);
@@ -3667,7 +3667,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	default:
 		return -EOPNOTSUPP;
 	}
-	return E1000_SUCCESS;
+	return 0;
 }
 
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 6fd55e7..d7947b0 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -53,7 +53,7 @@ static const u16 e1000_igp_2_cable_length_table[] =
  *  @hw: pointer to the HW structure
  *
  *  Read the PHY management control register and check whether a PHY reset
- *  is blocked.  If a reset is not blocked return E1000_SUCCESS, otherwise
+ *  is blocked.  If a reset is not blocked return 0, otherwise
  *  return E1000_BLK_PHY_RESET (12).
  **/
 s32 e1000_check_reset_block_generic(struct e1000_hw *hw)
@@ -63,7 +63,7 @@ s32 e1000_check_reset_block_generic(struct e1000_hw *hw)
 	manc = er32(MANC);
 
 	return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ?
-	       E1000_BLK_PHY_RESET : E1000_SUCCESS;
+	       E1000_BLK_PHY_RESET : 0;
 }
 
 /**
@@ -76,24 +76,23 @@ s32 e1000_check_reset_block_generic(struct e1000_hw *hw)
 s32 e1000_get_phy_id(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 phy_id;
 
 	ret_val = e1e_rphy(hw, PHY_ID1, &phy_id);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy->id = (u32)(phy_id << 16);
 	udelay(20);
 	ret_val = e1e_rphy(hw, PHY_ID2, &phy_id);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy->id |= (u32)(phy_id & PHY_REVISION_MASK);
 	phy->revision = (u32)(phy_id & ~PHY_REVISION_MASK);
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -108,12 +107,9 @@ s32 e1000_phy_reset_dsp(struct e1000_hw *hw)
 
 	ret_val = e1e_wphy(hw, M88E1000_PHY_GEN_CONTROL, 0xC1);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
-	ret_val = e1e_wphy(hw, M88E1000_PHY_GEN_CONTROL, 0);
-
-out:
-	return ret_val;
+	return e1e_wphy(hw, M88E1000_PHY_GEN_CONTROL, 0);
 }
 
 /**
@@ -129,12 +125,10 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 i, mdic = 0;
-	s32 ret_val = E1000_SUCCESS;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
 		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
-		ret_val = -E1000_ERR_PARAM;
-		goto out;
+		return -E1000_ERR_PARAM;
 	}
 
 	/* Set up Op-code, Phy Address, and register offset in the MDI
@@ -156,18 +150,15 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
 		hw_dbg(hw, "MDI Read did not complete\n");
-		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return -E1000_ERR_PHY;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
 		hw_dbg(hw, "MDI Error\n");
-		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return -E1000_ERR_PHY;
 	}
 	*data = (u16) mdic;
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -182,12 +173,10 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 i, mdic = 0;
-	s32 ret_val = E1000_SUCCESS;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
 		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
-		ret_val = -E1000_ERR_PARAM;
-		goto out;
+		return -E1000_ERR_PARAM;
 	}
 
 	/* Set up Op-code, Phy Address, and register offset in the MDI
@@ -210,12 +199,10 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
 		hw_dbg(hw, "MDI Write did not complete\n");
-		ret_val = -E1000_ERR_PHY;
-		goto out;
+		return -E1000_ERR_PHY;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -234,7 +221,7 @@ s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_read_phy_reg_mdic(hw,
 					  MAX_PHY_REG_ADDRESS & offset,
@@ -242,7 +229,6 @@ s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	hw->phy.ops.release_phy(hw);
 
-out:
 	return ret_val;
 }
 
@@ -261,7 +247,7 @@ s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1000_write_phy_reg_mdic(hw,
 					   MAX_PHY_REG_ADDRESS & offset,
@@ -269,7 +255,6 @@ s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 
 	hw->phy.ops.release_phy(hw);
 
-out:
 	return ret_val;
 }
 
@@ -289,7 +274,7 @@ s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
 		ret_val = e1000_write_phy_reg_mdic(hw,
@@ -297,7 +282,7 @@ s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 						   (u16)offset);
 		if (ret_val) {
 			hw->phy.ops.release_phy(hw);
-			goto out;
+			return ret_val;
 		}
 	}
 
@@ -307,7 +292,6 @@ s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	hw->phy.ops.release_phy(hw);
 
-out:
 	return ret_val;
 }
 
@@ -326,7 +310,7 @@ s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
 		ret_val = e1000_write_phy_reg_mdic(hw,
@@ -334,7 +318,7 @@ s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 						   (u16)offset);
 		if (ret_val) {
 			hw->phy.ops.release_phy(hw);
-			goto out;
+			return ret_val;
 		}
 	}
 
@@ -344,7 +328,6 @@ s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 
 	hw->phy.ops.release_phy(hw);
 
-out:
 	return ret_val;
 }
 
@@ -365,7 +348,7 @@ s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 		       E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
@@ -378,7 +361,6 @@ s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	hw->phy.ops.release_phy(hw);
 
-out:
 	return ret_val;
 }
 
@@ -399,7 +381,7 @@ s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
 
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 		       E1000_KMRNCTRLSTA_OFFSET) | data;
@@ -408,7 +390,6 @@ s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
 	udelay(2);
 	hw->phy.ops.release_phy(hw);
 
-out:
 	return ret_val;
 }
 
@@ -428,7 +409,7 @@ s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
 	/* Enable CRS on TX. This must be set for half-duplex operation. */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 
@@ -469,7 +450,7 @@ s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
 
 	ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (phy->revision < 4) {
 		/* Force TX_CLK in the Extended PHY Specific Control Register
@@ -477,7 +458,7 @@ s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
 		 */
 		ret_val = e1e_rphy(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		phy_data |= M88E1000_EPSCR_TX_CLK_25;
 
@@ -495,17 +476,14 @@ s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
 		}
 		ret_val = e1e_wphy(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
 	/* Commit the changes. */
 	ret_val = e1000_commit_phy(hw);
-	if (ret_val) {
+	if (ret_val)
 		hw_dbg(hw, "Error committing the PHY changes\n");
-		goto out;
-	}
 
-out:
 	return ret_val;
 }
 
@@ -525,7 +503,7 @@ s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
 	ret_val = e1000_phy_hw_reset(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error resetting the PHY.\n");
-		goto out;
+		return ret_val;
 	}
 
 	/* Wait 15ms for MAC to configure PHY from NVM settings. */
@@ -535,12 +513,12 @@ s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
 	ret_val = e1000_set_d0_lplu_state(hw, 0);
 	if (ret_val) {
 		hw_dbg(hw, "Error Disabling LPLU D0\n");
-		goto out;
+		return ret_val;
 	}
 	/* Configure mdi-mdix settings */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CTRL, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	data &= ~IGP01E1000_PSCR_AUTO_MDIX;
 
@@ -558,7 +536,7 @@ s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
 	}
 	ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CTRL, data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* set auto-master slave resolution settings */
 	if (hw->mac.autoneg) {
@@ -570,28 +548,28 @@ s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			/* Set auto Master/Slave resolution process */
 			ret_val = e1e_rphy(hw, PHY_1000T_CTRL, &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data &= ~CR_1000T_MS_ENABLE;
 			ret_val = e1e_wphy(hw, PHY_1000T_CTRL, data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 
 		ret_val = e1e_rphy(hw, PHY_1000T_CTRL, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		/* load defaults for future use */
 		phy->original_ms_type = (data & CR_1000T_MS_ENABLE) ?
@@ -614,11 +592,8 @@ s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
 			break;
 		}
 		ret_val = e1e_wphy(hw, PHY_1000T_CTRL, data);
-		if (ret_val)
-			goto out;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -643,13 +618,13 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
 	ret_val = e1e_rphy(hw, PHY_AUTONEG_ADV, &mii_autoneg_adv_reg);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		/* Read the MII 1000Base-T Control Register (Address 9). */
 		ret_val = e1e_rphy(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
 	/* Need to parse both autoneg_advertised and fc and set up
@@ -757,22 +732,19 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return ret_val;
 	}
 
 	ret_val = e1e_wphy(hw, PHY_AUTONEG_ADV, mii_autoneg_adv_reg);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	hw_dbg(hw, "Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		ret_val = e1e_wphy(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
-		if (ret_val)
-			goto out;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -806,7 +778,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	ret_val = e1000_phy_setup_autoneg(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error Setting up Auto-Negotiation\n");
-		goto out;
+		return ret_val;
 	}
 	hw_dbg(hw, "Restarting Auto-Neg\n");
 
@@ -815,12 +787,12 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	 */
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_ctrl);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_ctrl |= (MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG);
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_ctrl);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Does the user want to wait for Auto-Neg to complete here, or
 	 * check at a later time (for example, callback routine).
@@ -830,13 +802,12 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 		if (ret_val) {
 			hw_dbg(hw, "Error while waiting for "
 				 "autoneg to complete\n");
-			goto out;
+			return ret_val;
 		}
 	}
 
 	hw->mac.get_link_status = 1;
 
-out:
 	return ret_val;
 }
 
@@ -859,7 +830,7 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 		 * autonegotiation. */
 		ret_val = e1000_copper_link_autoneg(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	} else {
 		/* PHY will be set to 10H, 10F, 100H or 100F
 		 * depending on user settings. */
@@ -867,7 +838,7 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 		ret_val = e1000_phy_force_speed_duplex(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error Forcing Speed and Duplex\n");
-			goto out;
+			return ret_val;
 		}
 	}
 
@@ -879,7 +850,7 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 					     10,
 					     &link);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (link) {
 		hw_dbg(hw, "Valid link established!!!\n");
@@ -889,7 +860,6 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 		hw_dbg(hw, "Unable to establish link!!!\n");
 	}
 
-out:
 	return ret_val;
 }
 
@@ -910,27 +880,27 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
 
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_data &= ~IGP01E1000_PSCR_AUTO_MDIX;
 	phy_data &= ~IGP01E1000_PSCR_FORCE_MDI_MDIX;
 
 	ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CTRL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	hw_dbg(hw, "IGP PSCR: %X\n", phy_data);
 
@@ -944,7 +914,7 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 						     100000,
 						     &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		if (!link)
 			hw_dbg(hw, "Link taking longer than expected.\n");
@@ -955,10 +925,9 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 						     100000,
 						     &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -984,18 +953,18 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
 	ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	hw_dbg(hw, "M88E1000 PSCR: %X\n", phy_data);
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
 
@@ -1004,7 +973,7 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	udelay(1);
 
@@ -1014,7 +983,7 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		if (!link) {
 			/* We didn't get link.
@@ -1022,22 +991,22 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			 */
 			ret_val = e1e_wphy(hw, M88E1000_PHY_PAGE_SELECT, 0x001d);
 			if (ret_val)
-				goto out;
+				return ret_val;
 			ret_val = e1000_phy_reset_dsp(hw);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 
 		/* Try once more */
 		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
-			goto out;
+			return ret_val;
 	}
 
 	ret_val = e1e_rphy(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Resetting the phy means we need to re-force TX_CLK in the
 	 * Extended PHY Specific Control Register to 25MHz clock from
@@ -1046,19 +1015,18 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	phy_data |= M88E1000_EPSCR_TX_CLK_25;
 	ret_val = e1e_wphy(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* In addition, we must re-enable CRS on Tx for both half and full
 	 * duplex.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 	ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 
-out:
 	return ret_val;
 }
 
@@ -1144,7 +1112,7 @@ s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 
 	ret_val = e1e_rphy(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (!active) {
 		data &= ~IGP02E1000_PM_D3_LPLU;
@@ -1152,7 +1120,7 @@ s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 					     IGP02E1000_PHY_POWER_MGMT,
 					     data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
@@ -1161,24 +1129,24 @@ s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						    &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     &data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
-				goto out;
+				return ret_val;
 		}
 	} else if ((phy->autoneg_advertised == E1000_ALL_SPEED_DUPLEX) ||
 		   (phy->autoneg_advertised == E1000_ALL_NOT_GIG) ||
@@ -1186,18 +1154,17 @@ s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 		data |= IGP02E1000_PM_D3_LPLU;
 		ret_val = e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
 		ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 		ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG, data);
 	}
 
-out:
 	return ret_val;
 }
 
@@ -1229,8 +1196,7 @@ s32 e1000_check_downshift(struct e1000_hw *hw)
 	default:
 		/* speed downshift not supported */
 		phy->speed_downgraded = 0;
-		ret_val = E1000_SUCCESS;
-		goto out;
+		return 0;
 	}
 
 	ret_val = e1e_rphy(hw, offset, &phy_data);
@@ -1238,7 +1204,6 @@ s32 e1000_check_downshift(struct e1000_hw *hw)
 	if (!ret_val)
 		phy->speed_downgraded = (phy_data & mask);
 
-out:
 	return ret_val;
 }
 
@@ -1275,7 +1240,7 @@ static s32 e1000_check_polarity_m88(struct e1000_hw *hw)
  *  Polarity is determined based on the PHY port status register, and the
  *  current speed (since there is no polarity at 100Mbps).
  **/
-static  s32 e1000_check_polarity_igp(struct e1000_hw *hw)
+static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -1285,7 +1250,7 @@ static  s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 	 * our connection. */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_STATUS, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if ((data & IGP01E1000_PSSR_SPEED_MASK) ==
 	    IGP01E1000_PSSR_SPEED_1000MBPS) {
@@ -1306,7 +1271,6 @@ static  s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 				      ? e1000_rev_polarity_reversed
 				      : e1000_rev_polarity_normal;
 
-out:
 	return ret_val;
 }
 
@@ -1319,7 +1283,7 @@ out:
  **/
 s32 e1000_wait_autoneg(struct e1000_hw *hw)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val = 0;
 	u16 i, phy_status;
 
 	/* Break after autoneg completes or PHY_AUTO_NEG_LIMIT expires. */
@@ -1353,7 +1317,7 @@ s32 e1000_wait_autoneg(struct e1000_hw *hw)
 s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success)
 {
-	s32 ret_val = E1000_SUCCESS;
+	s32 ret_val;
 	u16 i, phy_status;
 
 	for (i = 0; i < iterations; i++) {
@@ -1403,7 +1367,7 @@ s32 e1000_get_cable_length_m88(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
 		M88E1000_PSSR_CABLE_LENGTH_SHIFT;
@@ -1412,7 +1376,6 @@ s32 e1000_get_cable_length_m88(struct e1000_hw *hw)
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 
-out:
 	return ret_val;
 }
 
@@ -1444,7 +1407,7 @@ s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
 	for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
 		ret_val = e1e_rphy(hw, agc_reg_array[i], &phy_data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		/* Getting bits 15:9, which represent the combination of
 		 * course and fine gain values.  The result is a number
@@ -1455,10 +1418,8 @@ s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
 
 		/* Array index bound check. */
 		if ((cur_agc_index >= IGP02E1000_CABLE_LENGTH_TABLE_SIZE) ||
-		    (cur_agc_index == 0)) {
-			ret_val = -E1000_ERR_PHY;
-			goto out;
-		}
+		    (cur_agc_index == 0))
+			return -E1000_ERR_PHY;
 
 		/* Remove min & max AGC values from calculation. */
 		if (e1000_igp_2_cable_length_table[min_agc_index] >
@@ -1482,7 +1443,6 @@ s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 
-out:
 	return ret_val;
 }
 
@@ -1505,45 +1465,43 @@ s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
 
 	if (hw->media_type != e1000_media_type_copper) {
 		hw_dbg(hw, "Phy info is only valid for copper media\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
 	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (!link) {
 		hw_dbg(hw, "Phy info is only valid if link is up\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy->polarity_correction = (phy_data &
 				    M88E1000_PSCR_POLARITY_REVERSAL);
 
 	ret_val = e1000_check_polarity_m88(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy->is_mdix = (phy_data & M88E1000_PSSR_MDIX);
 
 	if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
 		ret_val = e1000_get_cable_length(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		ret_val = e1e_rphy(hw, PHY_1000T_STATUS, &phy_data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		phy->local_rx = (phy_data & SR_1000T_LOCAL_RX_STATUS)
 				? e1000_1000t_rx_status_ok
@@ -1559,7 +1517,6 @@ s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
 		phy->remote_rx = e1000_1000t_rx_status_undefined;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -1581,23 +1538,22 @@ s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
 
 	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	if (!link) {
 		hw_dbg(hw, "Phy info is only valid if link is up\n");
-		ret_val = -E1000_ERR_CONFIG;
-		goto out;
+		return -E1000_ERR_CONFIG;
 	}
 
 	phy->polarity_correction = 1;
 
 	ret_val = e1000_check_polarity_igp(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_STATUS, &data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy->is_mdix = (data & IGP01E1000_PSSR_MDIX);
 
@@ -1605,11 +1561,11 @@ s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
 	    IGP01E1000_PSSR_SPEED_1000MBPS) {
 		ret_val = e1000_get_cable_length(hw);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		ret_val = e1e_rphy(hw, PHY_1000T_STATUS, &data);
 		if (ret_val)
-			goto out;
+			return ret_val;
 
 		phy->local_rx = (data & SR_1000T_LOCAL_RX_STATUS)
 				? e1000_1000t_rx_status_ok
@@ -1624,7 +1580,6 @@ s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
 		phy->remote_rx = e1000_1000t_rx_status_undefined;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -1642,16 +1597,15 @@ s32 e1000_phy_sw_reset(struct e1000_hw *hw)
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_ctrl);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	phy_ctrl |= MII_CR_RESET;
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_ctrl);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	udelay(1);
 
-out:
 	return ret_val;
 }
 
@@ -1667,18 +1621,16 @@ out:
 s32 e1000_phy_hw_reset_generic(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32  ret_val;
+	s32 ret_val;
 	u32 ctrl;
 
 	ret_val = e1000_check_reset_block(hw);
-	if (ret_val) {
-		ret_val = E1000_SUCCESS;
-		goto out;
-	}
+	if (ret_val)
+		return 0;
 
 	ret_val = phy->ops.acquire_phy(hw);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	ctrl = er32(CTRL);
 	ew32(CTRL, ctrl | E1000_CTRL_PHY_RST);
@@ -1693,10 +1645,7 @@ s32 e1000_phy_hw_reset_generic(struct e1000_hw *hw)
 
 	phy->ops.release_phy(hw);
 
-	ret_val = e1000_get_phy_cfg_done(hw);
-
-out:
-	return ret_val;
+	return e1000_get_phy_cfg_done(hw);
 }
 
 /**
@@ -1709,8 +1658,7 @@ out:
 s32 e1000_get_cfg_done(struct e1000_hw *hw)
 {
 	mdelay(10);
-
-	return E1000_SUCCESS;
+	return 0;
 }
 
 /* Internal function pointers */
@@ -1726,8 +1674,8 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.get_cfg_done)
 		return hw->phy.ops.get_cfg_done(hw);
-	else
-		return E1000_SUCCESS;
+
+	return 0;
 }
 
 /**
@@ -1735,14 +1683,14 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
  *  @hw: pointer to the HW structure
  *
  *  When the silicon family has not implemented a forced speed/duplex
- *  function for the PHY, simply return E1000_SUCCESS.
+ *  function for the PHY, simply return 0.
  **/
 static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.force_speed_duplex)
 		return hw->phy.ops.force_speed_duplex(hw);
-	else
-		return E1000_SUCCESS;
+
+	return 0;
 }
 
 /**
@@ -1794,8 +1742,8 @@ s32 e1000_commit_phy(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.commit_phy)
 		return hw->phy.ops.commit_phy(hw);
-	else
-		return E1000_SUCCESS;
+
+	return 0;
 }
 
 /**
@@ -1816,6 +1764,6 @@ s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 {
 	if (hw->phy.ops.set_d0_lplu_state)
 		return hw->phy.ops.set_d0_lplu_state(hw, active);
-	else
-		return E1000_SUCCESS;
+
+	return 0;
 }
