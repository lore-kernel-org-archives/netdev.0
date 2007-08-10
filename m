From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/6] e1000e: remove namespace collisions with e1000
Date: Fri, 10 Aug 2007 13:00:47 -0700
Message-ID: <20070810200047.21509.46779.stgit@localhost.localdomain>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9264 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760095AbXHJUAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:00:51 -0400
In-Reply-To: <20070810200038.21509.77815.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To prevent future collisions we rename all extern's from e1000_
to e1000e_*. The list of changed symbols was taken from e1000.h
Compile tested with CONFIG_E1000=y and CONFIG_E1000E=y.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |  129 +++++++++++++-------------
 drivers/net/e1000e/e1000.h   |  194 +++++++++++++++++++--------------------
 drivers/net/e1000e/es2lan.c  |  118 ++++++++++++------------
 drivers/net/e1000e/ethtool.c |   62 ++++++------
 drivers/net/e1000e/ich8lan.c |   92 +++++++++---------
 drivers/net/e1000e/lib.c     |  210 +++++++++++++++++++++---------------------
 drivers/net/e1000e/netdev.c  |  168 +++++++++++++++++-----------------
 drivers/net/e1000e/param.c   |    8 +-
 drivers/net/e1000e/phy.c     |  138 ++++++++++++++--------------
 9 files changed, 559 insertions(+), 560 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 0f8f0ac..cf70522 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -54,7 +54,6 @@
 static s32 e1000_get_phy_id_82571(struct e1000_hw *hw);
 static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw);
 static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw);
-static s32 e1000_get_phy_id_82571(struct e1000_hw *hw);
 static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 				      u16 words, u16 *data);
 static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw);
@@ -214,18 +213,18 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	switch (hw->media_type) {
 	case e1000_media_type_copper:
 		func->setup_physical_interface = e1000_setup_copper_link_82571;
-		func->check_for_link = e1000_check_for_copper_link;
-		func->get_link_up_info = e1000_get_speed_and_duplex_copper;
+		func->check_for_link = e1000e_check_for_copper_link;
+		func->get_link_up_info = e1000e_get_speed_and_duplex_copper;
 		break;
 	case e1000_media_type_fiber:
 		func->setup_physical_interface = e1000_setup_fiber_serdes_link_82571;
-		func->check_for_link = e1000_check_for_fiber_link;
-		func->get_link_up_info = e1000_get_speed_and_duplex_fiber_serdes;
+		func->check_for_link = e1000e_check_for_fiber_link;
+		func->get_link_up_info = e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
 	case e1000_media_type_internal_serdes:
 		func->setup_physical_interface = e1000_setup_fiber_serdes_link_82571;
-		func->check_for_link = e1000_check_for_serdes_link;
-		func->get_link_up_info = e1000_get_speed_and_duplex_fiber_serdes;
+		func->check_for_link = e1000e_check_for_serdes_link;
+		func->get_link_up_info = e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
 	default:
 		return -E1000_ERR_CONFIG;
@@ -324,7 +323,7 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 		phy->id = IGP01E1000_I_PHY_ID;
 		break;
 	case e1000_82573:
-		return e1000_get_phy_id(hw);
+		return e1000e_get_phy_id(hw);
 		break;
 	default:
 		return -E1000_ERR_PHY;
@@ -360,7 +359,7 @@ static s32 e1000_get_hw_semaphore_82571(struct e1000_hw *hw)
 
 	if (i == timeout) {
 		/* Release semaphores */
-		e1000_put_hw_semaphore(hw);
+		e1000e_put_hw_semaphore(hw);
 		hw_dbg(hw, "Driver can't access the NVM\n");
 		return -E1000_ERR_NVM;
 	}
@@ -403,7 +402,7 @@ static s32 e1000_acquire_nvm_82571(struct e1000_hw *hw)
 		return ret_val;
 
 	if (hw->mac.type != e1000_82573)
-		ret_val = e1000_acquire_nvm(hw);
+		ret_val = e1000e_acquire_nvm(hw);
 
 	if (ret_val)
 		e1000_put_hw_semaphore_82571(hw);
@@ -419,7 +418,7 @@ static s32 e1000_acquire_nvm_82571(struct e1000_hw *hw)
  **/
 static void e1000_release_nvm_82571(struct e1000_hw *hw)
 {
-	e1000_release_nvm(hw);
+	e1000e_release_nvm(hw);
 	e1000_put_hw_semaphore_82571(hw);
 }
 
@@ -432,7 +431,7 @@ static void e1000_release_nvm_82571(struct e1000_hw *hw)
  *
  *  For non-82573 silicon, write data to EEPROM at offset using SPI interface.
  *
- *  If e1000_update_nvm_checksum is not called after this function, the
+ *  If e1000e_update_nvm_checksum is not called after this function, the
  *  EEPROM will most likley contain an invalid checksum.
  **/
 static s32 e1000_write_nvm_82571(struct e1000_hw *hw, u16 offset, u16 words,
@@ -446,7 +445,7 @@ static s32 e1000_write_nvm_82571(struct e1000_hw *hw, u16 offset, u16 words,
 		break;
 	case e1000_82571:
 	case e1000_82572:
-		ret_val = e1000_write_nvm_spi(hw, offset, words, data);
+		ret_val = e1000e_write_nvm_spi(hw, offset, words, data);
 		break;
 	default:
 		ret_val = -E1000_ERR_NVM;
@@ -470,7 +469,7 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 i;
 
-	ret_val = e1000_update_nvm_checksum_generic(hw);
+	ret_val = e1000e_update_nvm_checksum_generic(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -527,7 +526,7 @@ static s32 e1000_validate_nvm_checksum_82571(struct e1000_hw *hw)
 	if (hw->nvm.type == e1000_nvm_flash_hw)
 		e1000_fix_nvm_checksum_82571(hw);
 
-	return e1000_validate_nvm_checksum_generic(hw);
+	return e1000e_validate_nvm_checksum_generic(hw);
 }
 
 /**
@@ -541,7 +540,7 @@ static s32 e1000_validate_nvm_checksum_82571(struct e1000_hw *hw)
  *  command has completed before trying to write the next word.  After write
  *  poll for completion.
  *
- *  If e1000_update_nvm_checksum is not called after this function, the
+ *  If e1000e_update_nvm_checksum is not called after this function, the
  *  EEPROM will most likley contain an invalid checksum.
  **/
 static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
@@ -565,13 +564,13 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 		       ((offset+i) << E1000_NVM_RW_ADDR_SHIFT) |
 		       E1000_NVM_RW_REG_START;
 
-		ret_val = e1000_poll_eerd_eewr_done(hw, E1000_NVM_POLL_WRITE);
+		ret_val = e1000e_poll_eerd_eewr_done(hw, E1000_NVM_POLL_WRITE);
 		if (ret_val)
 			break;
 
 		ew32(EEWR, eewr);
 
-		ret_val = e1000_poll_eerd_eewr_done(hw, E1000_NVM_POLL_WRITE);
+		ret_val = e1000e_poll_eerd_eewr_done(hw, E1000_NVM_POLL_WRITE);
 		if (ret_val)
 			break;
 	}
@@ -691,7 +690,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	/* Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
-	ret_val = e1000_disable_pcie_master(hw);
+	ret_val = e1000e_disable_pcie_master(hw);
 	if (ret_val)
 		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
 
@@ -737,7 +736,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 		e1e_flush();
 	}
 
-	ret_val = e1000_get_auto_rd_done(hw);
+	ret_val = e1000e_get_auto_rd_done(hw);
 	if (ret_val)
 		/* We don't want to continue accessing MAC registers. */
 		return ret_val;
@@ -773,7 +772,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	e1000_initialize_hw_bits_82571(hw);
 
 	/* Initialize identification LED */
-	ret_val = e1000_id_led_init(hw);
+	ret_val = e1000e_id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
 		return ret_val;
@@ -781,16 +780,16 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 
 	/* Disabling VLAN filtering */
 	hw_dbg(hw, "Initializing the IEEE VLAN\n");
-	e1000_clear_vfta(hw);
+	e1000e_clear_vfta(hw);
 
 	/* Setup the receive address. */
 	/* If, however, a locally administered address was assigned to the
 	 * 82571, we must reserve a RAR for it to work around an issue where
 	 * resetting one port will reload the MAC on the other port.
 	 */
-	if (e1000_get_laa_state_82571(hw))
+	if (e1000e_get_laa_state_82571(hw))
 		rar_count--;
-	e1000_init_rx_addrs(hw, rar_count);
+	e1000e_init_rx_addrs(hw, rar_count);
 
 	/* Zero out the Multicast HASH table */
 	hw_dbg(hw, "Zeroing the MTA\n");
@@ -815,7 +814,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 			   E1000_TXDCTL_COUNT_DESC;
 		ew32(TXDCTL1, reg_data);
 	} else {
-		e1000_enable_tx_pkt_filtering(hw);
+		e1000e_enable_tx_pkt_filtering(hw);
 		reg_data = er32(GCR);
 		reg_data |= E1000_GCR_L1_ACT_WITHOUT_L0S_RX;
 		ew32(GCR, reg_data);
@@ -898,13 +897,13 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_clear_vfta - Clear VLAN filter table
+ *  e1000e_clear_vfta - Clear VLAN filter table
  *  @hw: pointer to the HW structure
  *
  *  Clears the register array which contains the VLAN filter table by
  *  setting all the values to 0.
  **/
-void e1000_clear_vfta(struct e1000_hw *hw)
+void e1000e_clear_vfta(struct e1000_hw *hw)
 {
 	u32 offset;
 	u32 vfta_value = 0;
@@ -956,10 +955,10 @@ static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
 					    u32 rar_used_count,
 					    u32 rar_count)
 {
-	if (e1000_get_laa_state_82571(hw))
+	if (e1000e_get_laa_state_82571(hw))
 		rar_count--;
 
-	e1000_mc_addr_list_update_generic(hw, mc_addr_list, mc_addr_count,
+	e1000e_mc_addr_list_update_generic(hw, mc_addr_list, mc_addr_count,
 					  rar_used_count, rar_count);
 }
 
@@ -982,7 +981,7 @@ static s32 e1000_setup_link_82571(struct e1000_hw *hw)
 	if (hw->mac.type == e1000_82573)
 		hw->mac.fc = e1000_fc_full;
 
-	return e1000_setup_link(hw);
+	return e1000e_setup_link(hw);
 }
 
 /**
@@ -1006,10 +1005,10 @@ static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 
 	switch (hw->phy.type) {
 	case e1000_phy_m88:
-		ret_val = e1000_copper_link_setup_m88(hw);
+		ret_val = e1000e_copper_link_setup_m88(hw);
 		break;
 	case e1000_phy_igp_2:
-		ret_val = e1000_copper_link_setup_igp(hw);
+		ret_val = e1000e_copper_link_setup_igp(hw);
 		/* Setup activity LED */
 		led_ctrl = er32(LEDCTL);
 		led_ctrl &= IGP_ACTIVITY_LED_MASK;
@@ -1024,7 +1023,7 @@ static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000_setup_copper_link(hw);
+	ret_val = e1000e_setup_copper_link(hw);
 
 	return ret_val;
 }
@@ -1054,7 +1053,7 @@ static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw)
 		break;
 	}
 
-	return e1000_setup_fiber_serdes_link(hw);
+	return e1000e_setup_fiber_serdes_link(hw);
 }
 
 /**
@@ -1086,12 +1085,12 @@ static s32 e1000_valid_led_default_82571(struct e1000_hw *hw, u16 *data)
 }
 
 /**
- *  e1000_get_laa_state_82571 - Get locally administered address state
+ *  e1000e_get_laa_state_82571 - Get locally administered address state
  *  @hw: pointer to the HW structure
  *
  *  Retrieve and return the current locally administed address state.
  **/
-bool e1000_get_laa_state_82571(struct e1000_hw *hw)
+bool e1000e_get_laa_state_82571(struct e1000_hw *hw)
 {
 	if (hw->mac.type != e1000_82571)
 		return 0;
@@ -1100,13 +1099,13 @@ bool e1000_get_laa_state_82571(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_laa_state_82571 - Set locally administered address state
+ *  e1000e_set_laa_state_82571 - Set locally administered address state
  *  @hw: pointer to the HW structure
  *  @state: enable/disable locally administered address
  *
  *  Enable/Disable the current locally administed address state.
  **/
-void e1000_set_laa_state_82571(struct e1000_hw *hw, bool state)
+void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state)
 {
 	if (hw->mac.type != e1000_82571)
 		return;
@@ -1121,7 +1120,7 @@ void e1000_set_laa_state_82571(struct e1000_hw *hw, bool state)
 		 * incoming packets directed to this port are dropped.
 		 * Eventually the LAA will be in RAR[0] and RAR[14].
 		 */
-		e1000_rar_set(hw, hw->mac.addr, hw->mac.rar_entry_count - 1);
+		e1000e_rar_set(hw, hw->mac.addr, hw->mac.rar_entry_count - 1);
 }
 
 /**
@@ -1167,7 +1166,7 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 			ret_val = e1000_write_nvm(hw, 0x23, 1, &data);
 			if (ret_val)
 				return ret_val;
-			ret_val = e1000_update_nvm_checksum(hw);
+			ret_val = e1000e_update_nvm_checksum(hw);
 		}
 	}
 
@@ -1184,7 +1183,7 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
 {
 	u32 temp;
 
-	e1000_clear_hw_cntrs_base(hw);
+	e1000e_clear_hw_cntrs_base(hw);
 
 	temp = er32(PRC64);
 	temp = er32(PRC127);
@@ -1225,12 +1224,12 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
 static struct e1000_mac_operations e82571_mac_ops = {
 	.mng_mode_enab		= E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT,
 	/* .check_for_link: media type dependent */
-	.cleanup_led		= e1000_cleanup_led_generic,
+	.cleanup_led		= e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_82571,
-	.get_bus_info		= e1000_get_bus_info_pcie,
+	.get_bus_info		= e1000e_get_bus_info_pcie,
 	/* .get_link_up_info: media type dependent */
-	.led_on			= e1000_led_on_generic,
-	.led_off		= e1000_led_off_generic,
+	.led_on			= e1000e_led_on_generic,
+	.led_off		= e1000e_led_off_generic,
 	.mc_addr_list_update	= e1000_mc_addr_list_update_82571,
 	.reset_hw		= e1000_reset_hw_82571,
 	.init_hw		= e1000_init_hw_82571,
@@ -1240,39 +1239,39 @@ static struct e1000_mac_operations e82571_mac_ops = {
 
 static struct e1000_phy_operations e82_phy_ops_igp = {
 	.acquire_phy		= e1000_get_hw_semaphore_82571,
-	.check_reset_block	= e1000_check_reset_block_generic,
+	.check_reset_block	= e1000e_check_reset_block_generic,
 	.commit_phy		= NULL,
-	.force_speed_duplex	= e1000_phy_force_speed_duplex_igp,
+	.force_speed_duplex	= e1000e_phy_force_speed_duplex_igp,
 	.get_cfg_done		= e1000_get_cfg_done_82571,
-	.get_cable_length	= e1000_get_cable_length_igp_2,
-	.get_phy_info		= e1000_get_phy_info_igp,
-	.read_phy_reg		= e1000_read_phy_reg_igp,
+	.get_cable_length	= e1000e_get_cable_length_igp_2,
+	.get_phy_info		= e1000e_get_phy_info_igp,
+	.read_phy_reg		= e1000e_read_phy_reg_igp,
 	.release_phy		= e1000_put_hw_semaphore_82571,
-	.reset_phy		= e1000_phy_hw_reset_generic,
+	.reset_phy		= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
-	.set_d3_lplu_state	= e1000_set_d3_lplu_state,
-	.write_phy_reg		= e1000_write_phy_reg_igp,
+	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
+	.write_phy_reg		= e1000e_write_phy_reg_igp,
 };
 
 static struct e1000_phy_operations e82_phy_ops_m88 = {
 	.acquire_phy		= e1000_get_hw_semaphore_82571,
-	.check_reset_block	= e1000_check_reset_block_generic,
-	.commit_phy		= e1000_phy_sw_reset,
-	.force_speed_duplex	= e1000_phy_force_speed_duplex_m88,
-	.get_cfg_done		= e1000_get_cfg_done,
-	.get_cable_length	= e1000_get_cable_length_m88,
-	.get_phy_info		= e1000_get_phy_info_m88,
-	.read_phy_reg		= e1000_read_phy_reg_m88,
+	.check_reset_block	= e1000e_check_reset_block_generic,
+	.commit_phy		= e1000e_phy_sw_reset,
+	.force_speed_duplex	= e1000e_phy_force_speed_duplex_m88,
+	.get_cfg_done		= e1000e_get_cfg_done,
+	.get_cable_length	= e1000e_get_cable_length_m88,
+	.get_phy_info		= e1000e_get_phy_info_m88,
+	.read_phy_reg		= e1000e_read_phy_reg_m88,
 	.release_phy		= e1000_put_hw_semaphore_82571,
-	.reset_phy		= e1000_phy_hw_reset_generic,
+	.reset_phy		= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
-	.set_d3_lplu_state	= e1000_set_d3_lplu_state,
-	.write_phy_reg		= e1000_write_phy_reg_m88,
+	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
+	.write_phy_reg		= e1000e_write_phy_reg_m88,
 };
 
 static struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_82571,
-	.read_nvm		= e1000_read_nvm_spi,
+	.read_nvm		= e1000e_read_nvm_spi,
 	.release_nvm		= e1000_release_nvm_82571,
 	.update_nvm		= e1000_update_nvm_checksum_82571,
 	.valid_led_default	= e1000_valid_led_default_82571,
@@ -1282,7 +1281,7 @@ static struct e1000_nvm_operations e82571_nvm_ops = {
 
 static struct e1000_nvm_operations e82573_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_82571,
-	.read_nvm		= e1000_read_nvm_eerd,
+	.read_nvm		= e1000e_read_nvm_eerd,
 	.release_nvm		= e1000_release_nvm_82571,
 	.update_nvm		= e1000_update_nvm_checksum_82571,
 	.valid_led_default	= e1000_valid_led_default_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index de17537..3475e48 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -337,26 +337,26 @@ enum latency_range {
 	latency_invalid = 255
 };
 
-extern char e1000_driver_name[];
-extern const char e1000_driver_version[];
-
-extern void e1000_check_options(struct e1000_adapter *adapter);
-extern void e1000_set_ethtool_ops(struct net_device *netdev);
-
-extern int e1000_up(struct e1000_adapter *adapter);
-extern void e1000_down(struct e1000_adapter *adapter);
-extern void e1000_reinit_locked(struct e1000_adapter *adapter);
-extern void e1000_reset(struct e1000_adapter *adapter);
-extern void e1000_power_up_phy(struct e1000_adapter *adapter);
-extern int e1000_setup_rx_resources(struct e1000_adapter *adapter);
-extern int e1000_setup_tx_resources(struct e1000_adapter *adapter);
-extern void e1000_free_rx_resources(struct e1000_adapter *adapter);
-extern void e1000_free_tx_resources(struct e1000_adapter *adapter);
-extern void e1000_update_stats(struct e1000_adapter *adapter);
+extern char e1000e_driver_name[];
+extern const char e1000e_driver_version[];
+
+extern void e1000e_check_options(struct e1000_adapter *adapter);
+extern void e1000e_set_ethtool_ops(struct net_device *netdev);
+
+extern int e1000e_up(struct e1000_adapter *adapter);
+extern void e1000e_down(struct e1000_adapter *adapter);
+extern void e1000e_reinit_locked(struct e1000_adapter *adapter);
+extern void e1000e_reset(struct e1000_adapter *adapter);
+extern void e1000e_power_up_phy(struct e1000_adapter *adapter);
+extern int e1000e_setup_rx_resources(struct e1000_adapter *adapter);
+extern int e1000e_setup_tx_resources(struct e1000_adapter *adapter);
+extern void e1000e_free_rx_resources(struct e1000_adapter *adapter);
+extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
+extern void e1000e_update_stats(struct e1000_adapter *adapter);
 
 extern unsigned int copybreak;
 
-extern char *e1000_get_hw_dev_name(struct e1000_hw *hw);
+extern char *e1000e_get_hw_dev_name(struct e1000_hw *hw);
 
 extern struct e1000_info e1000_82571_info;
 extern struct e1000_info e1000_82572_info;
@@ -365,79 +365,79 @@ extern struct e1000_info e1000_ich8_info;
 extern struct e1000_info e1000_ich9_info;
 extern struct e1000_info e1000_es2_info;
 
-extern s32  e1000_commit_phy(struct e1000_hw *hw);
+extern s32  e1000e_commit_phy(struct e1000_hw *hw);
 
-extern bool e1000_enable_mng_pass_thru(struct e1000_hw *hw);
+extern bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw);
 
-extern bool e1000_get_laa_state_82571(struct e1000_hw *hw);
-extern void e1000_set_laa_state_82571(struct e1000_hw *hw, bool state);
+extern bool e1000e_get_laa_state_82571(struct e1000_hw *hw);
+extern void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state);
 
-extern void e1000_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
+extern void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 						 bool state);
-extern void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
-extern void e1000_gig_downshift_workaround_ich8lan(struct e1000_hw *hw);
-
-extern s32 e1000_check_for_copper_link(struct e1000_hw *hw);
-extern s32 e1000_check_for_fiber_link(struct e1000_hw *hw);
-extern s32 e1000_check_for_serdes_link(struct e1000_hw *hw);
-extern s32 e1000_cleanup_led_generic(struct e1000_hw *hw);
-extern s32 e1000_led_on_generic(struct e1000_hw *hw);
-extern s32 e1000_led_off_generic(struct e1000_hw *hw);
-extern s32 e1000_get_bus_info_pcie(struct e1000_hw *hw);
-extern s32 e1000_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex);
-extern s32 e1000_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex);
-extern s32 e1000_disable_pcie_master(struct e1000_hw *hw);
-extern s32 e1000_get_auto_rd_done(struct e1000_hw *hw);
-extern s32 e1000_id_led_init(struct e1000_hw *hw);
-extern void e1000_clear_hw_cntrs_base(struct e1000_hw *hw);
-extern s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
-extern s32 e1000_copper_link_setup_m88(struct e1000_hw *hw);
-extern s32 e1000_copper_link_setup_igp(struct e1000_hw *hw);
-extern s32 e1000_setup_link(struct e1000_hw *hw);
-extern void e1000_clear_vfta(struct e1000_hw *hw);
-extern void e1000_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
-extern void e1000_mc_addr_list_update_generic(struct e1000_hw *hw,
+extern void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
+extern void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw);
+
+extern s32 e1000e_check_for_copper_link(struct e1000_hw *hw);
+extern s32 e1000e_check_for_fiber_link(struct e1000_hw *hw);
+extern s32 e1000e_check_for_serdes_link(struct e1000_hw *hw);
+extern s32 e1000e_cleanup_led_generic(struct e1000_hw *hw);
+extern s32 e1000e_led_on_generic(struct e1000_hw *hw);
+extern s32 e1000e_led_off_generic(struct e1000_hw *hw);
+extern s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw);
+extern s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex);
+extern s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex);
+extern s32 e1000e_disable_pcie_master(struct e1000_hw *hw);
+extern s32 e1000e_get_auto_rd_done(struct e1000_hw *hw);
+extern s32 e1000e_id_led_init(struct e1000_hw *hw);
+extern void e1000e_clear_hw_cntrs_base(struct e1000_hw *hw);
+extern s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw);
+extern s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw);
+extern s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw);
+extern s32 e1000e_setup_link(struct e1000_hw *hw);
+extern void e1000e_clear_vfta(struct e1000_hw *hw);
+extern void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
+extern void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
 				       u8 *mc_addr_list, u32 mc_addr_count,
 				       u32 rar_used_count, u32 rar_count);
-extern void e1000_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
-extern s32 e1000_set_fc_watermarks(struct e1000_hw *hw);
-extern void e1000_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop);
-extern s32 e1000_get_hw_semaphore(struct e1000_hw *hw);
-extern s32 e1000_valid_led_default(struct e1000_hw *hw, u16 *data);
-extern void e1000_config_collision_dist(struct e1000_hw *hw);
-extern s32 e1000_config_fc_after_link_up(struct e1000_hw *hw);
-extern s32 e1000_force_mac_fc(struct e1000_hw *hw);
-extern s32 e1000_blink_led(struct e1000_hw *hw);
-extern void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
-extern void e1000_reset_adaptive(struct e1000_hw *hw);
-extern void e1000_update_adaptive(struct e1000_hw *hw);
-
-extern s32 e1000_setup_copper_link(struct e1000_hw *hw);
-extern s32 e1000_get_phy_id(struct e1000_hw *hw);
-extern void e1000_put_hw_semaphore(struct e1000_hw *hw);
-extern s32 e1000_check_reset_block_generic(struct e1000_hw *hw);
-extern s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw);
-extern s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw);
-extern s32 e1000_get_phy_info_igp(struct e1000_hw *hw);
-extern s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data);
-extern s32 e1000_phy_hw_reset_generic(struct e1000_hw *hw);
-extern s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
-extern s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
-extern s32 e1000_phy_sw_reset(struct e1000_hw *hw);
-extern s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw);
-extern s32 e1000_get_cfg_done(struct e1000_hw *hw);
-extern s32 e1000_get_cable_length_m88(struct e1000_hw *hw);
-extern s32 e1000_get_phy_info_m88(struct e1000_hw *hw);
-extern s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data);
-extern s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data);
-extern enum e1000_phy_type e1000_get_phy_type_from_id(u32 phy_id);
-extern void e1000_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
-extern s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
-extern s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
-extern s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
+extern void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
+extern s32 e1000e_set_fc_watermarks(struct e1000_hw *hw);
+extern void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop);
+extern s32 e1000e_get_hw_semaphore(struct e1000_hw *hw);
+extern s32 e1000e_valid_led_default(struct e1000_hw *hw, u16 *data);
+extern void e1000e_config_collision_dist(struct e1000_hw *hw);
+extern s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw);
+extern s32 e1000e_force_mac_fc(struct e1000_hw *hw);
+extern s32 e1000e_blink_led(struct e1000_hw *hw);
+extern void e1000e_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
+extern void e1000e_reset_adaptive(struct e1000_hw *hw);
+extern void e1000e_update_adaptive(struct e1000_hw *hw);
+
+extern s32 e1000e_setup_copper_link(struct e1000_hw *hw);
+extern s32 e1000e_get_phy_id(struct e1000_hw *hw);
+extern void e1000e_put_hw_semaphore(struct e1000_hw *hw);
+extern s32 e1000e_check_reset_block_generic(struct e1000_hw *hw);
+extern s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw);
+extern s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw);
+extern s32 e1000e_get_phy_info_igp(struct e1000_hw *hw);
+extern s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw);
+extern s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active);
+extern s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000e_phy_sw_reset(struct e1000_hw *hw);
+extern s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw);
+extern s32 e1000e_get_cfg_done(struct e1000_hw *hw);
+extern s32 e1000e_get_cable_length_m88(struct e1000_hw *hw);
+extern s32 e1000e_get_phy_info_m88(struct e1000_hw *hw);
+extern s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data);
+extern enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id);
+extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
+extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success);
-extern s32 e1000_phy_reset_dsp(struct e1000_hw *hw);
-extern s32 e1000_check_downshift(struct e1000_hw *hw);
+extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
+extern s32 e1000e_check_downshift(struct e1000_hw *hw);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
@@ -464,23 +464,23 @@ static inline s32 e1000_get_cable_length(struct e1000_hw *hw)
 	return hw->phy.ops.get_cable_length(hw);
 }
 
-extern s32 e1000_acquire_nvm(struct e1000_hw *hw);
-extern s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-extern s32 e1000_update_nvm_checksum_generic(struct e1000_hw *hw);
-extern s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
-extern s32 e1000_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-extern s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-extern s32 e1000_validate_nvm_checksum_generic(struct e1000_hw *hw);
-extern void e1000_release_nvm(struct e1000_hw *hw);
-extern void e1000_reload_nvm(struct e1000_hw *hw);
-extern s32 e1000_read_mac_addr(struct e1000_hw *hw);
+extern s32 e1000e_acquire_nvm(struct e1000_hw *hw);
+extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+extern s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw);
+extern s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
+extern s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+extern s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw);
+extern void e1000e_release_nvm(struct e1000_hw *hw);
+extern void e1000e_reload_nvm(struct e1000_hw *hw);
+extern s32 e1000e_read_mac_addr(struct e1000_hw *hw);
 
 static inline s32 e1000_validate_nvm_checksum(struct e1000_hw *hw)
 {
 	return hw->nvm.ops.validate_nvm(hw);
 }
 
-static inline s32 e1000_update_nvm_checksum(struct e1000_hw *hw)
+static inline s32 e1000e_update_nvm_checksum(struct e1000_hw *hw)
 {
 	return hw->nvm.ops.update_nvm(hw);
 }
@@ -500,9 +500,9 @@ static inline s32 e1000_get_phy_info(struct e1000_hw *hw)
 	return hw->phy.ops.get_phy_info(hw);
 }
 
-extern bool e1000_check_mng_mode(struct e1000_hw *hw);
-extern bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
-extern s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length);
+extern bool e1000e_check_mng_mode(struct e1000_hw *hw);
+extern bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw);
+extern s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length);
 
 static inline u32 __er32(struct e1000_hw *hw, unsigned long reg)
 {
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 8100d03..88657ad 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -129,7 +129,7 @@ static s32 e1000_init_phy_params_80003es2lan(struct e1000_hw *hw)
 	phy->type		= e1000_phy_gg82563;
 
 	/* This can only be done after all function pointers are setup. */
-	ret_val = e1000_get_phy_id(hw);
+	ret_val = e1000e_get_phy_id(hw);
 
 	/* Verify phy id */
 	if (phy->id != GG82563_E_PHY_ID)
@@ -215,15 +215,15 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	switch (hw->media_type) {
 	case e1000_media_type_copper:
 		func->setup_physical_interface = e1000_setup_copper_link_80003es2lan;
-		func->check_for_link = e1000_check_for_copper_link;
+		func->check_for_link = e1000e_check_for_copper_link;
 		break;
 	case e1000_media_type_fiber:
-		func->setup_physical_interface = e1000_setup_fiber_serdes_link;
-		func->check_for_link = e1000_check_for_fiber_link;
+		func->setup_physical_interface = e1000e_setup_fiber_serdes_link;
+		func->check_for_link = e1000e_check_for_fiber_link;
 		break;
 	case e1000_media_type_internal_serdes:
-		func->setup_physical_interface = e1000_setup_fiber_serdes_link;
-		func->check_for_link = e1000_check_for_serdes_link;
+		func->setup_physical_interface = e1000e_setup_fiber_serdes_link;
+		func->check_for_link = e1000e_check_for_serdes_link;
 		break;
 	default:
 		return -E1000_ERR_CONFIG;
@@ -299,7 +299,7 @@ static s32 e1000_acquire_nvm_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000_acquire_nvm(hw);
+	ret_val = e1000e_acquire_nvm(hw);
 
 	if (ret_val)
 		e1000_release_swfw_sync_80003es2lan(hw, E1000_SWFW_EEP_SM);
@@ -316,7 +316,7 @@ static s32 e1000_acquire_nvm_80003es2lan(struct e1000_hw *hw)
  **/
 static void e1000_release_nvm_80003es2lan(struct e1000_hw *hw)
 {
-	e1000_release_nvm(hw);
+	e1000e_release_nvm(hw);
 	e1000_release_swfw_sync_80003es2lan(hw, E1000_SWFW_EEP_SM);
 }
 
@@ -337,7 +337,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 	s32 timeout = 200;
 
 	while (i < timeout) {
-		if (e1000_get_hw_semaphore(hw))
+		if (e1000e_get_hw_semaphore(hw))
 			return -E1000_ERR_SWFW_SYNC;
 
 		swfw_sync = er32(SW_FW_SYNC);
@@ -346,7 +346,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 
 		/* Firmware currently using resource (fwmask)
 		 * or other software thread using resource (swmask) */
-		e1000_put_hw_semaphore(hw);
+		e1000e_put_hw_semaphore(hw);
 		mdelay(5);
 		i++;
 	}
@@ -360,7 +360,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 	swfw_sync |= swmask;
 	ew32(SW_FW_SYNC, swfw_sync);
 
-	e1000_put_hw_semaphore(hw);
+	e1000e_put_hw_semaphore(hw);
 
 	return 0;
 }
@@ -377,14 +377,14 @@ static void e1000_release_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 {
 	u32 swfw_sync;
 
-	while (e1000_get_hw_semaphore(hw) != 0);
+	while (e1000e_get_hw_semaphore(hw) != 0);
 	/* Empty */
 
 	swfw_sync = er32(SW_FW_SYNC);
 	swfw_sync &= ~mask;
 	ew32(SW_FW_SYNC, swfw_sync);
 
-	e1000_put_hw_semaphore(hw);
+	e1000e_put_hw_semaphore(hw);
 }
 
 /**
@@ -413,7 +413,7 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
 
 	temp = (u16)((u16)offset >> GG82563_PAGE_SHIFT);
-	ret_val = e1000_write_phy_reg_m88(hw, page_select, temp);
+	ret_val = e1000e_write_phy_reg_m88(hw, page_select, temp);
 	if (ret_val)
 		return ret_val;
 
@@ -424,7 +424,7 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	udelay(200);
 
 	/* ...and verify the command was successful. */
-	ret_val = e1000_read_phy_reg_m88(hw, page_select, &temp);
+	ret_val = e1000e_read_phy_reg_m88(hw, page_select, &temp);
 
 	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp) {
 		ret_val = -E1000_ERR_PHY;
@@ -433,7 +433,7 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 
 	udelay(200);
 
-	ret_val = e1000_read_phy_reg_m88(hw,
+	ret_val = e1000e_read_phy_reg_m88(hw,
 					 MAX_PHY_REG_ADDRESS & offset,
 					 data);
 
@@ -468,7 +468,7 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
 
 	temp = (u16)((u16)offset >> GG82563_PAGE_SHIFT);
-	ret_val = e1000_write_phy_reg_m88(hw, page_select, temp);
+	ret_val = e1000e_write_phy_reg_m88(hw, page_select, temp);
 	if (ret_val)
 		return ret_val;
 
@@ -480,14 +480,14 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	udelay(200);
 
 	/* ...and verify the command was successful. */
-	ret_val = e1000_read_phy_reg_m88(hw, page_select, &temp);
+	ret_val = e1000e_read_phy_reg_m88(hw, page_select, &temp);
 
 	if (((u16)offset >> GG82563_PAGE_SHIFT) != temp)
 		return -E1000_ERR_PHY;
 
 	udelay(200);
 
-	ret_val = e1000_write_phy_reg_m88(hw,
+	ret_val = e1000e_write_phy_reg_m88(hw,
 					  MAX_PHY_REG_ADDRESS & offset,
 					  data);
 
@@ -509,7 +509,7 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 static s32 e1000_write_nvm_80003es2lan(struct e1000_hw *hw, u16 offset,
 				       u16 words, u16 *data)
 {
-	return e1000_write_nvm_spi(hw, offset, words, data);
+	return e1000e_write_nvm_spi(hw, offset, words, data);
 }
 
 /**
@@ -572,7 +572,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
+	e1000e_phy_force_speed_duplex_setup(hw, &phy_data);
 
 	/* Reset the phy to commit changes. */
 	phy_data |= MII_CR_RESET;
@@ -587,7 +587,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 		hw_dbg(hw, "Waiting for forced speed/duplex link "
 			 "on GG82563 phy.\n");
 
-		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
+		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
 			return ret_val;
@@ -596,13 +596,13 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 			/* We didn't get link.
 			 * Reset the DSP and cross our fingers.
 			 */
-			ret_val = e1000_phy_reset_dsp(hw);
+			ret_val = e1000e_phy_reset_dsp(hw);
 			if (ret_val)
 				return ret_val;
 		}
 
 		/* Try once more */
-		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
+		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
 			return ret_val;
@@ -672,7 +672,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
 	s32 ret_val;
 
 	if (hw->media_type == e1000_media_type_copper) {
-		ret_val = e1000_get_speed_and_duplex_copper(hw,
+		ret_val = e1000e_get_speed_and_duplex_copper(hw,
 								    speed,
 								    duplex);
 		if (ret_val)
@@ -683,7 +683,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
 			ret_val = e1000_cfg_kmrn_10_100_80003es2lan(hw,
 							      *duplex);
 	} else {
-		ret_val = e1000_get_speed_and_duplex_fiber_serdes(hw,
+		ret_val = e1000e_get_speed_and_duplex_fiber_serdes(hw,
 								  speed,
 								  duplex);
 	}
@@ -707,7 +707,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	/* Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
-	ret_val = e1000_disable_pcie_master(hw);
+	ret_val = e1000e_disable_pcie_master(hw);
 	if (ret_val)
 		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
 
@@ -725,7 +725,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	hw_dbg(hw, "Issuing a global reset to MAC\n");
 	ew32(CTRL, ctrl | E1000_CTRL_RST);
 
-	ret_val = e1000_get_auto_rd_done(hw);
+	ret_val = e1000e_get_auto_rd_done(hw);
 	if (ret_val)
 		/* We don't want to continue accessing MAC registers. */
 		return ret_val;
@@ -754,7 +754,7 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	e1000_initialize_hw_bits_80003es2lan(hw);
 
 	/* Initialize identification LED */
-	ret_val = e1000_id_led_init(hw);
+	ret_val = e1000e_id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
 		return ret_val;
@@ -762,10 +762,10 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 
 	/* Disabling VLAN filtering */
 	hw_dbg(hw, "Initializing the IEEE VLAN\n");
-	e1000_clear_vfta(hw);
+	e1000e_clear_vfta(hw);
 
 	/* Setup the receive address. */
-	e1000_init_rx_addrs(hw, mac->rar_entry_count);
+	e1000e_init_rx_addrs(hw, mac->rar_entry_count);
 
 	/* Zero out the Multicast HASH table */
 	hw_dbg(hw, "Zeroing the MTA\n");
@@ -773,7 +773,7 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
 
 	/* Setup link and flow control */
-	ret_val = e1000_setup_link(hw);
+	ret_val = e1000e_setup_link(hw);
 
 	/* Set the transmit descriptor write-back policy */
 	reg_data = er32(TXDCTL);
@@ -922,14 +922,14 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		return ret_val;
 
 	/* SW Reset the PHY so all changes take effect */
-	ret_val = e1000_commit_phy(hw);
+	ret_val = e1000e_commit_phy(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error Resetting the PHY\n");
 		return ret_val;
 	}
 
 	/* Bypass RX and TX FIFO's */
-	ret_val = e1000_write_kmrn_reg(hw,
+	ret_val = e1000e_write_kmrn_reg(hw,
 				E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
 				E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
 					E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS);
@@ -957,7 +957,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	 * firmware will have already initialized them.  We only initialize
 	 * them if the HW is not in IAMT mode.
 	 */
-	if (!e1000_check_mng_mode(hw)) {
+	if (!e1000e_check_mng_mode(hw)) {
 		/* Enable Electrical Idle on the PHY */
 		data |= GG82563_PMCR_ENABLE_ELECTRICAL_IDLE;
 		ret_val = e1e_wphy(hw, GG82563_PHY_PWR_MGMT_CTRL, data);
@@ -1010,23 +1010,23 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	/* Set the mac to wait the maximum time between each
 	 * iteration and increase the max iterations when
 	 * polling the phy; this fixes erroneous timeouts at 10Mbps. */
-	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
+	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1000_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
+	ret_val = e1000e_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= 0x3F;
-	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1000_read_kmrn_reg(hw,
+	ret_val = e1000e_read_kmrn_reg(hw,
 				      E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
 				      &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= E1000_KMRNCTRLSTA_INB_CTRL_DIS_PADDING;
-	ret_val = e1000_write_kmrn_reg(hw,
+	ret_val = e1000e_write_kmrn_reg(hw,
 				       E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
 				       reg_data);
 	if (ret_val)
@@ -1036,7 +1036,7 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	ret_val = e1000_setup_copper_link(hw);
+	ret_val = e1000e_setup_copper_link(hw);
 
 	return 0;
 }
@@ -1056,7 +1056,7 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 	u16 reg_data;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
-	ret_val = e1000_write_kmrn_reg(hw,
+	ret_val = e1000e_write_kmrn_reg(hw,
 				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
 				       reg_data);
 	if (ret_val)
@@ -1096,7 +1096,7 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 	u32 tipg;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
-	ret_val = e1000_write_kmrn_reg(hw,
+	ret_val = e1000e_write_kmrn_reg(hw,
 				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
 				       reg_data);
 	if (ret_val)
@@ -1128,7 +1128,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 {
 	u32 temp;
 
-	e1000_clear_hw_cntrs_base(hw);
+	e1000e_clear_hw_cntrs_base(hw);
 
 	temp = er32(PRC64);
 	temp = er32(PRC127);
@@ -1169,42 +1169,42 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 static struct e1000_mac_operations es2_mac_ops = {
 	.mng_mode_enab		= E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT,
 	/* check_for_link dependent on media type */
-	.cleanup_led		= e1000_cleanup_led_generic,
+	.cleanup_led		= e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_80003es2lan,
-	.get_bus_info		= e1000_get_bus_info_pcie,
+	.get_bus_info		= e1000e_get_bus_info_pcie,
 	.get_link_up_info	= e1000_get_link_up_info_80003es2lan,
-	.led_on			= e1000_led_on_generic,
-	.led_off		= e1000_led_off_generic,
-	.mc_addr_list_update	= e1000_mc_addr_list_update_generic,
+	.led_on			= e1000e_led_on_generic,
+	.led_off		= e1000e_led_off_generic,
+	.mc_addr_list_update	= e1000e_mc_addr_list_update_generic,
 	.reset_hw		= e1000_reset_hw_80003es2lan,
 	.init_hw		= e1000_init_hw_80003es2lan,
-	.setup_link		= e1000_setup_link,
+	.setup_link		= e1000e_setup_link,
 	/* setup_physical_interface dependent on media type */
 };
 
 static struct e1000_phy_operations es2_phy_ops = {
 	.acquire_phy		= e1000_acquire_phy_80003es2lan,
-	.check_reset_block	= e1000_check_reset_block_generic,
-	.commit_phy	 	= e1000_phy_sw_reset,
+	.check_reset_block	= e1000e_check_reset_block_generic,
+	.commit_phy	 	= e1000e_phy_sw_reset,
 	.force_speed_duplex 	= e1000_phy_force_speed_duplex_80003es2lan,
 	.get_cfg_done       	= e1000_get_cfg_done_80003es2lan,
 	.get_cable_length   	= e1000_get_cable_length_80003es2lan,
-	.get_phy_info       	= e1000_get_phy_info_m88,
+	.get_phy_info       	= e1000e_get_phy_info_m88,
 	.read_phy_reg       	= e1000_read_phy_reg_gg82563_80003es2lan,
 	.release_phy		= e1000_release_phy_80003es2lan,
-	.reset_phy	  	= e1000_phy_hw_reset_generic,
+	.reset_phy	  	= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state  	= NULL,
-	.set_d3_lplu_state  	= e1000_set_d3_lplu_state,
+	.set_d3_lplu_state  	= e1000e_set_d3_lplu_state,
 	.write_phy_reg      	= e1000_write_phy_reg_gg82563_80003es2lan,
 };
 
 static struct e1000_nvm_operations es2_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_80003es2lan,
-	.read_nvm		= e1000_read_nvm_eerd,
+	.read_nvm		= e1000e_read_nvm_eerd,
 	.release_nvm		= e1000_release_nvm_80003es2lan,
-	.update_nvm		= e1000_update_nvm_checksum_generic,
-	.valid_led_default	= e1000_valid_led_default,
-	.validate_nvm		= e1000_validate_nvm_checksum_generic,
+	.update_nvm		= e1000e_update_nvm_checksum_generic,
+	.valid_led_default	= e1000e_valid_led_default,
+	.validate_nvm		= e1000e_validate_nvm_checksum_generic,
 	.write_nvm		= e1000_write_nvm_80003es2lan,
 };
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index a8fa1db..c9d74a8 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -246,10 +246,10 @@ static int e1000_set_settings(struct net_device *netdev,
 	/* reset the link */
 
 	if (netif_running(adapter->netdev)) {
-		e1000_down(adapter);
-		e1000_up(adapter);
+		e1000e_down(adapter);
+		e1000e_up(adapter);
 	} else {
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 	}
 
 	clear_bit(__E1000_RESETTING, &adapter->state);
@@ -300,14 +300,14 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
 		if (netif_running(adapter->netdev)) {
-			e1000_down(adapter);
-			e1000_up(adapter);
+			e1000e_down(adapter);
+			e1000e_up(adapter);
 		} else {
-			e1000_reset(adapter);
+			e1000e_reset(adapter);
 		}
 	} else {
 		retval = ((hw->media_type == e1000_media_type_fiber) ?
-			  hw->mac.ops.setup_link(hw) : e1000_force_mac_fc(hw));
+			  hw->mac.ops.setup_link(hw) : e1000e_force_mac_fc(hw));
 	}
 
 	clear_bit(__E1000_RESETTING, &adapter->state);
@@ -330,9 +330,9 @@ static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
 		adapter->flags &= ~FLAG_RX_CSUM_ENABLED;
 
 	if (netif_running(netdev))
-		e1000_reinit_locked(adapter);
+		e1000e_reinit_locked(adapter);
 	else
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 	return 0;
 }
 
@@ -549,7 +549,7 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	 * and flush shadow RAM for 82573 controllers */
 	if ((ret_val == 0) && ((first_word <= NVM_CHECKSUM_REG) ||
 			       (hw->mac.type == e1000_82573)))
-		e1000_update_nvm_checksum(hw);
+		e1000e_update_nvm_checksum(hw);
 
 	kfree(eeprom_buff);
 	return ret_val;
@@ -562,8 +562,8 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 	char firmware_version[32];
 	u16 eeprom_data;
 
-	strncpy(drvinfo->driver,  e1000_driver_name, 32);
-	strncpy(drvinfo->version, e1000_driver_version, 32);
+	strncpy(drvinfo->driver,  e1000e_driver_name, 32);
+	strncpy(drvinfo->version, e1000e_driver_version, 32);
 
 	/* EEPROM image version # is reported as firmware version # for
 	 * PCI-E controllers */
@@ -613,7 +613,7 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		msleep(1);
 
 	if (netif_running(adapter->netdev))
-		e1000_down(adapter);
+		e1000e_down(adapter);
 
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
@@ -640,10 +640,10 @@ static int e1000_set_ringparam(struct net_device *netdev,
 
 	if (netif_running(adapter->netdev)) {
 		/* Try to get new resources before deleting old */
-		err = e1000_setup_rx_resources(adapter);
+		err = e1000e_setup_rx_resources(adapter);
 		if (err)
 			goto err_setup_rx;
-		err = e1000_setup_tx_resources(adapter);
+		err = e1000e_setup_tx_resources(adapter);
 		if (err)
 			goto err_setup_tx;
 
@@ -651,13 +651,13 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		 * then restore the new back again */
 		adapter->rx_ring = rx_old;
 		adapter->tx_ring = tx_old;
-		e1000_free_rx_resources(adapter);
-		e1000_free_tx_resources(adapter);
+		e1000e_free_rx_resources(adapter);
+		e1000e_free_tx_resources(adapter);
 		kfree(tx_old);
 		kfree(rx_old);
 		adapter->rx_ring = rx_ring;
 		adapter->tx_ring = tx_ring;
-		err = e1000_up(adapter);
+		err = e1000e_up(adapter);
 		if (err)
 			goto err_setup;
 	}
@@ -665,7 +665,7 @@ static int e1000_set_ringparam(struct net_device *netdev,
 	clear_bit(__E1000_RESETTING, &adapter->state);
 	return 0;
 err_setup_tx:
-	e1000_free_rx_resources(adapter);
+	e1000e_free_rx_resources(adapter);
 err_setup_rx:
 	adapter->rx_ring = rx_old;
 	adapter->tx_ring = tx_old;
@@ -673,7 +673,7 @@ err_setup_rx:
 err_alloc_rx:
 	kfree(tx_ring);
 err_alloc_tx:
-	e1000_up(adapter);
+	e1000e_up(adapter);
 err_setup:
 	clear_bit(__E1000_RESETTING, &adapter->state);
 	return err;
@@ -1326,7 +1326,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		if (phy_reg & MII_CR_LOOPBACK) {
 			phy_reg &= ~MII_CR_LOOPBACK;
 			e1e_wphy(hw, PHY_CONTROL, phy_reg);
-			e1000_commit_phy(hw);
+			e1000e_commit_phy(hw);
 		}
 		break;
 	}
@@ -1517,22 +1517,22 @@ static void e1000_diag_test(struct net_device *netdev,
 			/* indicate we're in test mode */
 			dev_close(netdev);
 		else
-			e1000_reset(adapter);
+			e1000e_reset(adapter);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 		if (e1000_eeprom_test(adapter, &data[1]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 		if (e1000_intr_test(adapter, &data[2]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 		/* make sure the phy is powered up */
-		e1000_power_up_phy(adapter);
+		e1000e_power_up_phy(adapter);
 		if (e1000_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1543,7 +1543,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		/* force this routine to wait until autoneg complete/timeout */
 		adapter->hw.phy.wait_for_link = 1;
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 		adapter->hw.phy.wait_for_link = 0;
 
 		clear_bit(__E1000_TESTING, &adapter->state);
@@ -1663,7 +1663,7 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 		e1e_wphy(&adapter->hw,
 				    IFE_PHY_SPECIAL_CONTROL_LED, 0);
 	} else {
-		e1000_blink_led(&adapter->hw);
+		e1000e_blink_led(&adapter->hw);
 		msleep_interruptible(data * 1000);
 	}
 
@@ -1678,7 +1678,7 @@ static int e1000_nway_reset(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	if (netif_running(netdev))
-		e1000_reinit_locked(adapter);
+		e1000e_reinit_locked(adapter);
 	return 0;
 }
 
@@ -1694,7 +1694,7 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
 
-	e1000_update_stats(adapter);
+	e1000e_update_stats(adapter);
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		char *p = (char *)adapter+e1000_gstrings_stats[i].stat_offset;
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
@@ -1758,7 +1758,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_ethtool_stats	= e1000_get_ethtool_stats,
 };
 
-void e1000_set_ethtool_ops(struct net_device *netdev)
+void e1000e_set_ethtool_ops(struct net_device *netdev)
 {
 	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 }
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 85095af..8f8139d 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -199,10 +199,10 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	phy->reset_delay_us		= 100;
 
 	phy->id = 0;
-	while ((e1000_phy_unknown == e1000_get_phy_type_from_id(phy->id)) &&
+	while ((e1000_phy_unknown == e1000e_get_phy_type_from_id(phy->id)) &&
 	       (i++ < 100)) {
 		msleep(1);
-		ret_val = e1000_get_phy_id(hw);
+		ret_val = e1000e_get_phy_id(hw);
 		if (ret_val)
 			return ret_val;
 	}
@@ -308,7 +308,7 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 
 	/* Enable PCS Lock-loss workaround for ICH8 */
 	if (mac->type == e1000_ich8lan)
-		e1000_set_kmrn_lock_loss_workaround_ich8lan(hw, 1);
+		e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw, 1);
 
 	return 0;
 }
@@ -420,7 +420,7 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 	bool link;
 
 	if (phy->type != e1000_phy_ife) {
-		ret_val = e1000_phy_force_speed_duplex_igp(hw);
+		ret_val = e1000e_phy_force_speed_duplex_igp(hw);
 		return ret_val;
 	}
 
@@ -428,7 +428,7 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e1000_phy_force_speed_duplex_setup(hw, &data);
+	e1000e_phy_force_speed_duplex_setup(hw, &data);
 
 	ret_val = e1e_wphy(hw, PHY_CONTROL, data);
 	if (ret_val)
@@ -453,7 +453,7 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 	if (phy->wait_for_link) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on IFE phy.\n");
 
-		ret_val = e1000_phy_has_link_generic(hw,
+		ret_val = e1000e_phy_has_link_generic(hw,
 						     PHY_FORCE_LIMIT,
 						     100000,
 						     &link);
@@ -464,7 +464,7 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 			hw_dbg(hw, "Link taking longer than expected.\n");
 
 		/* Try once more */
-		ret_val = e1000_phy_has_link_generic(hw,
+		ret_val = e1000e_phy_has_link_generic(hw,
 						     PHY_FORCE_LIMIT,
 						     100000,
 						     &link);
@@ -492,7 +492,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	u16 loop = E1000_ICH8_LAN_INIT_TIMEOUT;
 	u16 word_addr, reg_data, reg_addr, phy_page = 0;
 
-	ret_val = e1000_phy_hw_reset_generic(hw);
+	ret_val = e1000e_phy_hw_reset_generic(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -604,7 +604,7 @@ static s32 e1000_get_phy_info_ife_ich8lan(struct e1000_hw *hw)
 	u16 data;
 	bool link;
 
-	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
 		return ret_val;
 
@@ -658,7 +658,7 @@ static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
 		return e1000_get_phy_info_ife_ich8lan(hw);
 		break;
 	case e1000_phy_igp_3:
-		return e1000_get_phy_info_igp(hw);
+		return e1000e_get_phy_info_igp(hw);
 		break;
 	default:
 		break;
@@ -735,7 +735,7 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		 * any PHY registers */
 		if ((hw->mac.type == e1000_ich8lan) &&
 		    (hw->phy.type == e1000_phy_igp_3))
-			e1000_gig_downshift_workaround_ich8lan(hw);
+			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
 		ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG, &data);
@@ -845,7 +845,7 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		 * any PHY registers */
 		if ((hw->mac.type == e1000_ich8lan) &&
 		    (hw->phy.type == e1000_phy_igp_3))
-			e1000_gig_downshift_workaround_ich8lan(hw);
+			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
 		ret_val = e1e_rphy(hw,
@@ -1166,7 +1166,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = e1000_update_nvm_checksum_generic(hw);
+	ret_val = e1000e_update_nvm_checksum_generic(hw);
 	if (ret_val)
 		return ret_val;;
 
@@ -1275,7 +1275,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	/* Reload the EEPROM, or else modifications will not appear
 	 * until after the next adapter reset.
 	 */
-	e1000_reload_nvm(hw);
+	e1000e_reload_nvm(hw);
 	msleep(10);
 
 	return ret_val;
@@ -1308,12 +1308,12 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		ret_val = e1000_write_nvm(hw, 0x19, 1, &data);
 		if (ret_val)
 			return ret_val;
-		ret_val = e1000_update_nvm_checksum(hw);
+		ret_val = e1000e_update_nvm_checksum(hw);
 		if (ret_val)
 			return ret_val;
 	}
 
-	return e1000_validate_nvm_checksum_generic(hw);
+	return e1000e_validate_nvm_checksum_generic(hw);
 }
 
 /**
@@ -1583,7 +1583,7 @@ static s32 e1000_get_bus_info_ich8lan(struct e1000_hw *hw)
 	struct e1000_bus_info *bus = &hw->bus;
 	s32 ret_val;
 
-	ret_val = e1000_get_bus_info_pcie(hw);
+	ret_val = e1000e_get_bus_info_pcie(hw);
 
 	/* ICH devices are "PCI Express"-ish.  They have
 	 * a configuration space, but do not contain
@@ -1611,7 +1611,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	/* Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
-	ret_val = e1000_disable_pcie_master(hw);
+	ret_val = e1000e_disable_pcie_master(hw);
 	if (ret_val) {
 		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
 	}
@@ -1651,7 +1651,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL, (ctrl | E1000_CTRL_RST));
 	msleep(20);
 
-	ret_val = e1000_get_auto_rd_done(hw);
+	ret_val = e1000e_get_auto_rd_done(hw);
 	if (ret_val) {
 		/*
 		 * When auto config read does not complete, do not
@@ -1693,14 +1693,14 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	e1000_initialize_hw_bits_ich8lan(hw);
 
 	/* Initialize identification LED */
-	ret_val = e1000_id_led_init(hw);
+	ret_val = e1000e_id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
 		return ret_val;
 	}
 
 	/* Setup the receive address. */
-	e1000_init_rx_addrs(hw, mac->rar_entry_count);
+	e1000e_init_rx_addrs(hw, mac->rar_entry_count);
 
 	/* Zero out the Multicast HASH table */
 	hw_dbg(hw, "Zeroing the MTA\n");
@@ -1730,7 +1730,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 		snoop = PCIE_ICH8_SNOOP_ALL;
 	else
 		snoop = (u32) ~(PCIE_NO_SNOOP_ALL);
-	e1000_set_pcie_no_snoop(hw, snoop);
+	e1000e_set_pcie_no_snoop(hw, snoop);
 
 	ctrl_ext = er32(CTRL_EXT);
 	ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
@@ -1831,7 +1831,7 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 
 	ew32(FCTTV, mac->fc_pause_time);
 
-	return e1000_set_fc_watermarks(hw);
+	return e1000e_set_fc_watermarks(hw);
 }
 
 /**
@@ -1856,24 +1856,24 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	/* Set the mac to wait the maximum time between each iteration
 	 * and increase the max iterations when polling the phy;
 	 * this fixes erroneous timeouts at 10Mbps. */
-	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
+	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1000_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
+	ret_val = e1000e_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= 0x3F;
-	ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
 	if (ret_val)
 		return ret_val;
 
 	if (hw->phy.type == e1000_phy_igp_3) {
-		ret_val = e1000_copper_link_setup_igp(hw);
+		ret_val = e1000e_copper_link_setup_igp(hw);
 		if (ret_val)
 			return ret_val;
 	}
 
-	return e1000_setup_copper_link(hw);
+	return e1000e_setup_copper_link(hw);
 }
 
 /**
@@ -1891,7 +1891,7 @@ static s32 e1000_get_link_up_info_ich8lan(struct e1000_hw *hw, u16 *speed,
 {
 	s32 ret_val;
 
-	ret_val = e1000_get_speed_and_duplex_copper(hw, speed, duplex);
+	ret_val = e1000e_get_speed_and_duplex_copper(hw, speed, duplex);
 	if (ret_val)
 		return ret_val;
 
@@ -1933,7 +1933,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 	/* Make sure link is up before proceeding.  If not just return.
 	 * Attempting this while link is negotiating fouled up link
 	 * stability */
-	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (!link)
 		return 0;
 
@@ -1963,7 +1963,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 
 	/* Call gig speed drop workaround on Giga disable before accessing
 	 * any PHY registers */
-	e1000_gig_downshift_workaround_ich8lan(hw);
+	e1000e_gig_downshift_workaround_ich8lan(hw);
 
 	/* unable to acquire PCS lock */
 	return -E1000_ERR_PHY;
@@ -1977,7 +1977,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
  *  If ICH8, set the current Kumeran workaround state (enabled - TRUE
  *  /disabled - FALSE).
  **/
-void e1000_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
+void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 						 bool state)
 {
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
@@ -2000,7 +2000,7 @@ void e1000_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
  *    3) read it back
  *  Continue if successful, else issue LCD reset and repeat
  **/
-void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
+void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 {
 	u32 reg;
 	u16 data;
@@ -2020,7 +2020,7 @@ void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 		/* Call gig speed drop workaround on Giga disable before
 		 * accessing any PHY registers */
 		if (hw->mac.type == e1000_ich8lan)
-			e1000_gig_downshift_workaround_ich8lan(hw);
+			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* Write VR power-down enable */
 		e1e_rphy(hw, IGP3_VR_CTRL, &data);
@@ -2041,7 +2041,7 @@ void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_gig_downshift_workaround_ich8lan - WoL from S5 stops working
+ *  e1000e_gig_downshift_workaround_ich8lan - WoL from S5 stops working
  *  @hw: pointer to the HW structure
  *
  *  Steps to take when dropping from 1Gb/s (eg. link cable removal (LSC),
@@ -2050,7 +2050,7 @@ void e1000_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
  *    2) Clear Kumeran Near-end loopback
  *  Should only be called for ICH8[m] devices with IGP_3 Phy.
  **/
-void e1000_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
+void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 reg_data;
@@ -2059,17 +2059,17 @@ void e1000_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 	    (hw->phy.type != e1000_phy_igp_3))
 		return;
 
-	ret_val = e1000_read_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
+	ret_val = e1000e_read_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
 				      &reg_data);
 	if (ret_val)
 		return;
 	reg_data |= E1000_KMRNCTRLSTA_DIAG_NELPBK;
-	ret_val = e1000_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
 				       reg_data);
 	if (ret_val)
 		return;
 	reg_data &= ~E1000_KMRNCTRLSTA_DIAG_NELPBK;
-	ret_val = e1000_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
 				       reg_data);
 }
 
@@ -2131,7 +2131,7 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 {
 	u32 temp;
 
-	e1000_clear_hw_cntrs_base(hw);
+	e1000e_clear_hw_cntrs_base(hw);
 
 	temp = er32(ALGNERRC);
 	temp = er32(RXERRC);
@@ -2151,14 +2151,14 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 
 static struct e1000_mac_operations ich8_mac_ops = {
 	.mng_mode_enab		= E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT,
-	.check_for_link		= e1000_check_for_copper_link,
+	.check_for_link		= e1000e_check_for_copper_link,
 	.cleanup_led		= e1000_cleanup_led_ich8lan,
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_ich8lan,
 	.get_bus_info		= e1000_get_bus_info_ich8lan,
 	.get_link_up_info	= e1000_get_link_up_info_ich8lan,
 	.led_on			= e1000_led_on_ich8lan,
 	.led_off		= e1000_led_off_ich8lan,
-	.mc_addr_list_update	= e1000_mc_addr_list_update_generic,
+	.mc_addr_list_update	= e1000e_mc_addr_list_update_generic,
 	.reset_hw		= e1000_reset_hw_ich8lan,
 	.init_hw		= e1000_init_hw_ich8lan,
 	.setup_link		= e1000_setup_link_ich8lan,
@@ -2170,15 +2170,15 @@ static struct e1000_phy_operations ich8_phy_ops = {
 	.check_reset_block	= e1000_check_reset_block_ich8lan,
 	.commit_phy		= NULL,
 	.force_speed_duplex	= e1000_phy_force_speed_duplex_ich8lan,
-	.get_cfg_done		= e1000_get_cfg_done,
-	.get_cable_length	= e1000_get_cable_length_igp_2,
+	.get_cfg_done		= e1000e_get_cfg_done,
+	.get_cable_length	= e1000e_get_cable_length_igp_2,
 	.get_phy_info		= e1000_get_phy_info_ich8lan,
-	.read_phy_reg		= e1000_read_phy_reg_igp,
+	.read_phy_reg		= e1000e_read_phy_reg_igp,
 	.release_phy		= e1000_release_swflag_ich8lan,
 	.reset_phy		= e1000_phy_hw_reset_ich8lan,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_ich8lan,
 	.set_d3_lplu_state	= e1000_set_d3_lplu_state_ich8lan,
-	.write_phy_reg		= e1000_write_phy_reg_igp,
+	.write_phy_reg		= e1000e_write_phy_reg_igp,
 };
 
 static struct e1000_nvm_operations ich8_nvm_ops = {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index c92ea77..a04c1e4 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -47,14 +47,14 @@ enum e1000_mng_mode {
 						    * Technology signature */
 
 /**
- *  e1000_get_bus_info_pcie - Get PCIe bus information
+ *  e1000e_get_bus_info_pcie - Get PCIe bus information
  *  @hw: pointer to the HW structure
  *
  *  Determines and stores the system bus information for a particular
  *  network interface.  The following bus information is determined and stored:
  *  bus speed, bus width, type (PCIe), and PCIe function.
  **/
-s32 e1000_get_bus_info_pcie(struct e1000_hw *hw)
+s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw)
 {
 	struct e1000_bus_info *bus = &hw->bus;
 	struct e1000_adapter *adapter = hw->adapter;
@@ -87,7 +87,7 @@ s32 e1000_get_bus_info_pcie(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_write_vfta - Write value to VLAN filter table
+ *  e1000e_write_vfta - Write value to VLAN filter table
  *  @hw: pointer to the HW structure
  *  @offset: register offset in VLAN filter table
  *  @value: register value written to VLAN filter table
@@ -95,14 +95,14 @@ s32 e1000_get_bus_info_pcie(struct e1000_hw *hw)
  *  Writes value at the given offset in the register array which stores
  *  the VLAN filter table.
  **/
-void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
+void e1000e_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 {
 	E1000_WRITE_REG_ARRAY(hw, E1000_VFTA, offset, value);
 	e1e_flush();
 }
 
 /**
- *  e1000_init_rx_addrs - Initialize receive address's
+ *  e1000e_init_rx_addrs - Initialize receive address's
  *  @hw: pointer to the HW structure
  *  @rar_count: receive address registers
  *
@@ -110,14 +110,14 @@ void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
  *  register to the devices MAC address and clearing all the other receive
  *  address registers to 0.
  **/
-void e1000_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
+void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 {
 	u32 i;
 
 	/* Setup the receive address */
 	hw_dbg(hw, "Programming MAC Address into RAR[0]\n");
 
-	e1000_rar_set(hw, hw->mac.addr, 0);
+	e1000e_rar_set(hw, hw->mac.addr, 0);
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
 	hw_dbg(hw, "Clearing RAR[1-%u]\n", rar_count-1);
@@ -130,7 +130,7 @@ void e1000_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 }
 
 /**
- *  e1000_rar_set - Set receive address register
+ *  e1000e_rar_set - Set receive address register
  *  @hw: pointer to the HW structure
  *  @addr: pointer to the receive address
  *  @index: receive address array register
@@ -138,7 +138,7 @@ void e1000_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
  *  Sets the receive address array register at index to the address passed
  *  in by addr.
  **/
-void e1000_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
+void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 {
 	u32 rar_low, rar_high;
 
@@ -260,7 +260,7 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  e1000_mc_addr_list_update_generic - Update Multicast addresses
+ *  e1000e_mc_addr_list_update_generic - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -272,7 +272,7 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-void e1000_mc_addr_list_update_generic(struct e1000_hw *hw,
+void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
 				       u8 *mc_addr_list, u32 mc_addr_count,
 				       u32 rar_used_count, u32 rar_count)
 {
@@ -285,7 +285,7 @@ void e1000_mc_addr_list_update_generic(struct e1000_hw *hw,
 	 */
 	for (i = rar_used_count; i < rar_count; i++) {
 		if (mc_addr_count) {
-			e1000_rar_set(hw, mc_addr_list, i);
+			e1000e_rar_set(hw, mc_addr_list, i);
 			mc_addr_count--;
 			mc_addr_list += ETH_ALEN;
 		} else {
@@ -313,12 +313,12 @@ void e1000_mc_addr_list_update_generic(struct e1000_hw *hw,
 }
 
 /**
- *  e1000_clear_hw_cntrs_base - Clear base hardware counters
+ *  e1000e_clear_hw_cntrs_base - Clear base hardware counters
  *  @hw: pointer to the HW structure
  *
  *  Clears the base hardware counters by reading the counter registers.
  **/
-void e1000_clear_hw_cntrs_base(struct e1000_hw *hw)
+void e1000e_clear_hw_cntrs_base(struct e1000_hw *hw)
 {
 	u32 temp;
 
@@ -362,14 +362,14 @@ void e1000_clear_hw_cntrs_base(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_copper_link - Check for link (Copper)
+ *  e1000e_check_for_copper_link - Check for link (Copper)
  *  @hw: pointer to the HW structure
  *
  *  Checks to see of the link status of the hardware has changed.  If a
  *  change in link status has been detected, then we read the PHY registers
  *  to get the current speed/duplex if link exists.
  **/
-s32 e1000_check_for_copper_link(struct e1000_hw *hw)
+s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
@@ -387,7 +387,7 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 	 * link.  If so, then we want to get the current speed/duplex
 	 * of the PHY.
 	 */
-	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
 		return ret_val;
 
@@ -398,7 +398,7 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 
 	/* Check if there was DownShift, must be checked
 	 * immediately after link-up */
-	e1000_check_downshift(hw);
+	e1000e_check_downshift(hw);
 
 	/* If we are forcing speed/duplex, then we simply return since
 	 * we have already determined whether we have link or not.
@@ -412,14 +412,14 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 	 * of MAC speed/duplex configuration.  So we only need to
 	 * configure Collision Distance in the MAC.
 	 */
-	e1000_config_collision_dist(hw);
+	e1000e_config_collision_dist(hw);
 
 	/* Configure Flow Control now that Auto-Neg has completed.
 	 * First, we need to restore the desired flow control
 	 * settings because we may have had to re-autoneg with a
 	 * different link partner.
 	 */
-	ret_val = e1000_config_fc_after_link_up(hw);
+	ret_val = e1000e_config_fc_after_link_up(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error configuring flow control\n");
 	}
@@ -428,13 +428,13 @@ s32 e1000_check_for_copper_link(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_fiber_link - Check for link (Fiber)
+ *  e1000e_check_for_fiber_link - Check for link (Fiber)
  *  @hw: pointer to the HW structure
  *
  *  Checks for link up on the hardware.  If link is not up and we have
  *  a signal, then we need to force link up.
  **/
-s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
+s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 rxcw;
@@ -471,7 +471,7 @@ s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
 		ew32(CTRL, ctrl);
 
 		/* Configure Flow Control after forcing link up. */
-		ret_val = e1000_config_fc_after_link_up(hw);
+		ret_val = e1000e_config_fc_after_link_up(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error configuring flow control\n");
 			return ret_val;
@@ -493,13 +493,13 @@ s32 e1000_check_for_fiber_link(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_serdes_link - Check for link (Serdes)
+ *  e1000e_check_for_serdes_link - Check for link (Serdes)
  *  @hw: pointer to the HW structure
  *
  *  Checks for link up on the hardware.  If link is not up and we have
  *  a signal, then we need to force link up.
  **/
-s32 e1000_check_for_serdes_link(struct e1000_hw *hw)
+s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 rxcw;
@@ -534,7 +534,7 @@ s32 e1000_check_for_serdes_link(struct e1000_hw *hw)
 		ew32(CTRL, ctrl);
 
 		/* Configure Flow Control after forcing link up. */
-		ret_val = e1000_config_fc_after_link_up(hw);
+		ret_val = e1000e_config_fc_after_link_up(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error configuring flow control\n");
 			return ret_val;
@@ -619,7 +619,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_setup_link - Setup flow control and link settings
+ *  e1000e_setup_link - Setup flow control and link settings
  *  @hw: pointer to the HW structure
  *
  *  Determines which flow control settings to use, then configures flow
@@ -628,7 +628,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
  *  should be established.  Assumes the hardware has previously been reset
  *  and the transmitter and receiver are not enabled.
  **/
-s32 e1000_setup_link(struct e1000_hw *hw)
+s32 e1000e_setup_link(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
@@ -668,7 +668,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 
 	ew32(FCTTV, mac->fc_pause_time);
 
-	return e1000_set_fc_watermarks(hw);
+	return e1000e_set_fc_watermarks(hw);
 }
 
 /**
@@ -786,13 +786,13 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_setup_fiber_serdes_link - Setup link for fiber/serdes
+ *  e1000e_setup_fiber_serdes_link - Setup link for fiber/serdes
  *  @hw: pointer to the HW structure
  *
  *  Configures collision distance and flow control for fiber and serdes
  *  links.  Upon successful setup, poll for link.
  **/
-s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
+s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
 	u32 ctrl;
 	s32 ret_val;
@@ -802,7 +802,7 @@ s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 	/* Take the link out of reset */
 	ctrl &= ~E1000_CTRL_LRST;
 
-	e1000_config_collision_dist(hw);
+	e1000e_config_collision_dist(hw);
 
 	ret_val = e1000_commit_fc_settings_generic(hw);
 	if (ret_val)
@@ -835,14 +835,14 @@ s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_config_collision_dist - Configure collision distance
+ *  e1000e_config_collision_dist - Configure collision distance
  *  @hw: pointer to the HW structure
  *
  *  Configures the collision distance to the default value and is used
  *  during link setup. Currently no func pointer exists and all
  *  implementations are handled in the generic version of this function.
  **/
-void e1000_config_collision_dist(struct e1000_hw *hw)
+void e1000e_config_collision_dist(struct e1000_hw *hw)
 {
 	u32 tctl;
 
@@ -856,14 +856,14 @@ void e1000_config_collision_dist(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_fc_watermarks - Set flow control high/low watermarks
+ *  e1000e_set_fc_watermarks - Set flow control high/low watermarks
  *  @hw: pointer to the HW structure
  *
  *  Sets the flow control high/low threshold (watermark) registers.  If
  *  flow control XON frame transmission is enabled, then set XON frame
  *  tansmission as well.
  **/
-s32 e1000_set_fc_watermarks(struct e1000_hw *hw)
+s32 e1000e_set_fc_watermarks(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 fcrtl = 0, fcrth = 0;
@@ -890,7 +890,7 @@ s32 e1000_set_fc_watermarks(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_force_mac_fc - Force the MAC's flow control settings
+ *  e1000e_force_mac_fc - Force the MAC's flow control settings
  *  @hw: pointer to the HW structure
  *
  *  Force the MAC's flow control settings.  Sets the TFCE and RFCE bits in the
@@ -899,7 +899,7 @@ s32 e1000_set_fc_watermarks(struct e1000_hw *hw)
  *  autonegotiation is managed by the PHY rather than the MAC.  Software must
  *  also configure these bits when link is forced on a fiber connection.
  **/
-s32 e1000_force_mac_fc(struct e1000_hw *hw)
+s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 ctrl;
@@ -951,7 +951,7 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_config_fc_after_link_up - Configures flow control after link
+ *  e1000e_config_fc_after_link_up - Configures flow control after link
  *  @hw: pointer to the HW structure
  *
  *  Checks the status of auto-negotiation after link up to ensure that the
@@ -960,7 +960,7 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
  *  and did not fail, then we configure flow control based on our link
  *  partner.
  **/
-s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
+s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val = 0;
@@ -974,10 +974,10 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 	if (mac->autoneg_failed) {
 		if (hw->media_type == e1000_media_type_fiber ||
 		    hw->media_type == e1000_media_type_internal_serdes)
-			ret_val = e1000_force_mac_fc(hw);
+			ret_val = e1000e_force_mac_fc(hw);
 	} else {
 		if (hw->media_type == e1000_media_type_copper)
-			ret_val = e1000_force_mac_fc(hw);
+			ret_val = e1000e_force_mac_fc(hw);
 	}
 
 	if (ret_val) {
@@ -1147,7 +1147,7 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 		/* Now we call a subroutine to actually force the MAC
 		 * controller to use the correct flow control settings.
 		 */
-		ret_val = e1000_force_mac_fc(hw);
+		ret_val = e1000e_force_mac_fc(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error forcing flow control settings\n");
 			return ret_val;
@@ -1158,7 +1158,7 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_speed_and_duplex_copper - Retreive current speed/duplex
+ *  e1000e_get_speed_and_duplex_copper - Retreive current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1166,7 +1166,7 @@ s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
  *  Read the status register for the current speed/duplex and store the current
  *  speed and duplex for copper connections.
  **/
-s32 e1000_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex)
+s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex)
 {
 	u32 status;
 
@@ -1194,7 +1194,7 @@ s32 e1000_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dupl
 }
 
 /**
- *  e1000_get_speed_and_duplex_fiber_serdes - Retreive current speed/duplex
+ *  e1000e_get_speed_and_duplex_fiber_serdes - Retreive current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1202,7 +1202,7 @@ s32 e1000_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dupl
  *  Sets the speed and duplex to gigabit full duplex (the only possible option)
  *  for fiber/serdes links.
  **/
-s32 e1000_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex)
+s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex)
 {
 	*speed = SPEED_1000;
 	*duplex = FULL_DUPLEX;
@@ -1211,12 +1211,12 @@ s32 e1000_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16
 }
 
 /**
- *  e1000_get_hw_semaphore - Acquire hardware semaphore
+ *  e1000e_get_hw_semaphore - Acquire hardware semaphore
  *  @hw: pointer to the HW structure
  *
  *  Acquire the HW semaphore to access the PHY or NVM
  **/
-s32 e1000_get_hw_semaphore(struct e1000_hw *hw)
+s32 e1000e_get_hw_semaphore(struct e1000_hw *hw)
 {
 	u32 swsm;
 	s32 timeout = hw->nvm.word_size + 1;
@@ -1251,7 +1251,7 @@ s32 e1000_get_hw_semaphore(struct e1000_hw *hw)
 
 	if (i == timeout) {
 		/* Release semaphores */
-		e1000_put_hw_semaphore(hw);
+		e1000e_put_hw_semaphore(hw);
 		hw_dbg(hw, "Driver can't access the NVM\n");
 		return -E1000_ERR_NVM;
 	}
@@ -1260,12 +1260,12 @@ s32 e1000_get_hw_semaphore(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_put_hw_semaphore - Release hardware semaphore
+ *  e1000e_put_hw_semaphore - Release hardware semaphore
  *  @hw: pointer to the HW structure
  *
  *  Release hardware semaphore used to access the PHY or NVM
  **/
-void e1000_put_hw_semaphore(struct e1000_hw *hw)
+void e1000e_put_hw_semaphore(struct e1000_hw *hw)
 {
 	u32 swsm;
 
@@ -1275,12 +1275,12 @@ void e1000_put_hw_semaphore(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_auto_rd_done - Check for auto read completion
+ *  e1000e_get_auto_rd_done - Check for auto read completion
  *  @hw: pointer to the HW structure
  *
  *  Check EEPROM for Auto Read done bit.
  **/
-s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
+s32 e1000e_get_auto_rd_done(struct e1000_hw *hw)
 {
 	s32 i = 0;
 
@@ -1300,14 +1300,14 @@ s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_valid_led_default - Verify a valid default LED config
+ *  e1000e_valid_led_default - Verify a valid default LED config
  *  @hw: pointer to the HW structure
  *  @data: pointer to the NVM (EEPROM)
  *
  *  Read the EEPROM for the current default LED configuration.  If the
  *  LED configuration is not valid, set to a valid LED configuration.
  **/
-s32 e1000_valid_led_default(struct e1000_hw *hw, u16 *data)
+s32 e1000e_valid_led_default(struct e1000_hw *hw, u16 *data)
 {
 	s32 ret_val;
 
@@ -1324,11 +1324,11 @@ s32 e1000_valid_led_default(struct e1000_hw *hw, u16 *data)
 }
 
 /**
- *  e1000_id_led_init -
+ *  e1000e_id_led_init -
  *  @hw: pointer to the HW structure
  *
  **/
-s32 e1000_id_led_init(struct e1000_hw *hw)
+s32 e1000e_id_led_init(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
@@ -1388,25 +1388,25 @@ s32 e1000_id_led_init(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_cleanup_led_generic - Set LED config to default operation
+ *  e1000e_cleanup_led_generic - Set LED config to default operation
  *  @hw: pointer to the HW structure
  *
  *  Remove the current LED configuration and set the LED configuration
  *  to the default value, saved from the EEPROM.
  **/
-s32 e1000_cleanup_led_generic(struct e1000_hw *hw)
+s32 e1000e_cleanup_led_generic(struct e1000_hw *hw)
 {
 	ew32(LEDCTL, hw->mac.ledctl_default);
 	return 0;
 }
 
 /**
- *  e1000_blink_led - Blink LED
+ *  e1000e_blink_led - Blink LED
  *  @hw: pointer to the HW structure
  *
  *  Blink the led's which are set to be on.
  **/
-s32 e1000_blink_led(struct e1000_hw *hw)
+s32 e1000e_blink_led(struct e1000_hw *hw)
 {
 	u32 ledctl_blink = 0;
 	u32 i;
@@ -1432,12 +1432,12 @@ s32 e1000_blink_led(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_on_generic - Turn LED on
+ *  e1000e_led_on_generic - Turn LED on
  *  @hw: pointer to the HW structure
  *
  *  Turn LED on.
  **/
-s32 e1000_led_on_generic(struct e1000_hw *hw)
+s32 e1000e_led_on_generic(struct e1000_hw *hw)
 {
 	u32 ctrl;
 
@@ -1459,12 +1459,12 @@ s32 e1000_led_on_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_off_generic - Turn LED off
+ *  e1000e_led_off_generic - Turn LED off
  *  @hw: pointer to the HW structure
  *
  *  Turn LED off.
  **/
-s32 e1000_led_off_generic(struct e1000_hw *hw)
+s32 e1000e_led_off_generic(struct e1000_hw *hw)
 {
 	u32 ctrl;
 
@@ -1486,13 +1486,13 @@ s32 e1000_led_off_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_pcie_no_snoop - Set PCI-express capabilities
+ *  e1000e_set_pcie_no_snoop - Set PCI-express capabilities
  *  @hw: pointer to the HW structure
  *  @no_snoop: bitmap of snoop events
  *
  *  Set the PCI-express register to snoop for events enabled in 'no_snoop'.
  **/
-void e1000_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
+void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
 {
 	u32 gcr;
 
@@ -1505,7 +1505,7 @@ void e1000_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
 }
 
 /**
- *  e1000_disable_pcie_master - Disables PCI-express master access
+ *  e1000e_disable_pcie_master - Disables PCI-express master access
  *  @hw: pointer to the HW structure
  *
  *  Returns 0 if successful, else returns -10
@@ -1515,7 +1515,7 @@ void e1000_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
  *  Disables PCI-Express master access and verifies there are no pending
  *  requests.
  **/
-s32 e1000_disable_pcie_master(struct e1000_hw *hw)
+s32 e1000e_disable_pcie_master(struct e1000_hw *hw)
 {
 	u32 ctrl;
 	s32 timeout = MASTER_DISABLE_TIMEOUT;
@@ -1541,12 +1541,12 @@ s32 e1000_disable_pcie_master(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_reset_adaptive - Reset Adaptive Interframe Spacing
+ *  e1000e_reset_adaptive - Reset Adaptive Interframe Spacing
  *  @hw: pointer to the HW structure
  *
  *  Reset the Adaptive Interframe Spacing throttle to default values.
  **/
-void e1000_reset_adaptive(struct e1000_hw *hw)
+void e1000e_reset_adaptive(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 
@@ -1561,13 +1561,13 @@ void e1000_reset_adaptive(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_update_adaptive - Update Adaptive Interframe Spacing
+ *  e1000e_update_adaptive - Update Adaptive Interframe Spacing
  *  @hw: pointer to the HW structure
  *
  *  Update the Adaptive Interframe Spacing Throttle value based on the
  *  time between transmitted packets and time between collisions.
  **/
-void e1000_update_adaptive(struct e1000_hw *hw)
+void e1000e_update_adaptive(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 
@@ -1704,14 +1704,14 @@ static u16 e1000_shift_in_eec_bits(struct e1000_hw *hw, u16 count)
 }
 
 /**
- *  e1000_poll_eerd_eewr_done - Poll for EEPROM read/write completion
+ *  e1000e_poll_eerd_eewr_done - Poll for EEPROM read/write completion
  *  @hw: pointer to the HW structure
  *  @ee_reg: EEPROM flag for polling
  *
  *  Polls the EEPROM status bit for either read or write completion based
  *  upon the value of 'ee_reg'.
  **/
-s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
+s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
 {
 	u32 attempts = 100000;
 	u32 i, reg = 0;
@@ -1732,14 +1732,14 @@ s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
 }
 
 /**
- *  e1000_acquire_nvm - Generic request for access to EEPROM
+ *  e1000e_acquire_nvm - Generic request for access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
  *  Return successful if access grant bit set, else clear the request for
  *  EEPROM access and return -E1000_ERR_NVM (-1).
  **/
-s32 e1000_acquire_nvm(struct e1000_hw *hw)
+s32 e1000e_acquire_nvm(struct e1000_hw *hw)
 {
 	u32 eecd = er32(EECD);
 	s32 timeout = E1000_NVM_GRANT_ATTEMPTS;
@@ -1808,12 +1808,12 @@ static void e1000_stop_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_nvm - Release exclusive access to EEPROM
+ *  e1000e_release_nvm - Release exclusive access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Stop any current commands to the EEPROM and clear the EEPROM request bit.
  **/
-void e1000_release_nvm(struct e1000_hw *hw)
+void e1000e_release_nvm(struct e1000_hw *hw)
 {
 	u32 eecd;
 
@@ -1870,7 +1870,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_read_nvm_spi - Read EEPROM's using SPI
+ *  e1000e_read_nvm_spi - Read EEPROM's using SPI
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
  *  @words: number of words to read
@@ -1878,7 +1878,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
  *
  *  Reads a 16 bit word from the EEPROM.
  **/
-s32 e1000_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 i = 0;
@@ -1926,7 +1926,7 @@ s32 e1000_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 }
 
 /**
- *  e1000_read_nvm_eerd - Reads EEPROM using EERD register
+ *  e1000e_read_nvm_eerd - Reads EEPROM using EERD register
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
  *  @words: number of words to read
@@ -1934,7 +1934,7 @@ s32 e1000_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
  *
  *  Reads a 16 bit word from the EEPROM using the EERD register.
  **/
-s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 i, eerd = 0;
@@ -1953,7 +1953,7 @@ s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		       E1000_NVM_RW_REG_START;
 
 		ew32(EERD, eerd);
-		ret_val = e1000_poll_eerd_eewr_done(hw, E1000_NVM_POLL_READ);
+		ret_val = e1000e_poll_eerd_eewr_done(hw, E1000_NVM_POLL_READ);
 		if (ret_val)
 			break;
 
@@ -1965,7 +1965,7 @@ s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 }
 
 /**
- *  e1000_write_nvm_spi - Write to EEPROM using SPI
+ *  e1000e_write_nvm_spi - Write to EEPROM using SPI
  *  @hw: pointer to the HW structure
  *  @offset: offset within the EEPROM to be written to
  *  @words: number of words to write
@@ -1973,10 +1973,10 @@ s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
  *
  *  Writes data to EEPROM at offset using SPI interface.
  *
- *  If e1000_update_nvm_checksum is not called after this function , the
+ *  If e1000e_update_nvm_checksum is not called after this function , the
  *  EEPROM will most likley contain an invalid checksum.
  **/
-s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	s32 ret_val;
@@ -2042,14 +2042,14 @@ s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 }
 
 /**
- *  e1000_read_mac_addr - Read device MAC address
+ *  e1000e_read_mac_addr - Read device MAC address
  *  @hw: pointer to the HW structure
  *
  *  Reads the device MAC address from the EEPROM and stores the value.
  *  Since devices with two ports use the same EEPROM, we increment the
  *  last bit in the MAC address for the second port.
  **/
-s32 e1000_read_mac_addr(struct e1000_hw *hw)
+s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 offset, nvm_data, i;
@@ -2076,13 +2076,13 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_validate_nvm_checksum_generic - Validate EEPROM checksum
+ *  e1000e_validate_nvm_checksum_generic - Validate EEPROM checksum
  *  @hw: pointer to the HW structure
  *
  *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
  *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
  **/
-s32 e1000_validate_nvm_checksum_generic(struct e1000_hw *hw)
+s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 checksum = 0;
@@ -2106,14 +2106,14 @@ s32 e1000_validate_nvm_checksum_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_update_nvm_checksum_generic - Update EEPROM checksum
+ *  e1000e_update_nvm_checksum_generic - Update EEPROM checksum
  *  @hw: pointer to the HW structure
  *
  *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
  *  up to the checksum.  Then calculates the EEPROM checksum and writes the
  *  value to the EEPROM.
  **/
-s32 e1000_update_nvm_checksum_generic(struct e1000_hw *hw)
+s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 checksum = 0;
@@ -2136,13 +2136,13 @@ s32 e1000_update_nvm_checksum_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_reload_nvm - Reloads EEPROM
+ *  e1000e_reload_nvm - Reloads EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Reloads the EEPROM by setting the "Reinitialize from EEPROM" bit in the
  *  extended control register.
  **/
-void e1000_reload_nvm(struct e1000_hw *hw)
+void e1000e_reload_nvm(struct e1000_hw *hw)
 {
 	u32 ctrl_ext;
 
@@ -2213,13 +2213,13 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_mng_mode - check managament mode
+ *  e1000e_check_mng_mode - check managament mode
  *  @hw: pointer to the HW structure
  *
  *  Reads the firmware semaphore register and returns true (>0) if
  *  manageability is enabled, else false (0).
  **/
-bool e1000_check_mng_mode(struct e1000_hw *hw)
+bool e1000e_check_mng_mode(struct e1000_hw *hw)
 {
 	u32 fwsm = er32(FWSM);
 
@@ -2227,13 +2227,13 @@ bool e1000_check_mng_mode(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_enable_tx_pkt_filtering - Enable packet filtering on TX
+ *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on TX
  *  @hw: pointer to the HW structure
  *
  *  Enables packet filtering on transmit packets if manageability is enabled
  *  and host interface is enabled.
  **/
-bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
+bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 {
 	struct e1000_host_mng_dhcp_cookie *hdr = &hw->mng_cookie;
 	u32 *buffer = (u32 *)&hw->mng_cookie;
@@ -2242,7 +2242,7 @@ bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	u8 i, len;
 
 	/* No manageability, no filtering */
-	if (!e1000_check_mng_mode(hw)) {
+	if (!e1000e_check_mng_mode(hw)) {
 		hw->mac.tx_pkt_filtering = 0;
 		return 0;
 	}
@@ -2383,14 +2383,14 @@ static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
 }
 
 /**
- *  e1000_mng_write_dhcp_info - Writes DHCP info to host interface
+ *  e1000e_mng_write_dhcp_info - Writes DHCP info to host interface
  *  @hw: pointer to the HW structure
  *  @buffer: pointer to the host interface
  *  @length: size of the buffer
  *
  *  Writes the DHCP information to the host interface.
  **/
-s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
+s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
 {
 	struct e1000_host_mng_command_header hdr;
 	s32 ret_val;
@@ -2426,12 +2426,12 @@ s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
 }
 
 /**
- *  e1000_enable_mng_pass_thru - Enable processing of ARP's
+ *  e1000e_enable_mng_pass_thru - Enable processing of ARP's
  *  @hw: pointer to the HW structure
  *
  *  Verifies the hardware needs to allow ARPs to be processed by the host.
  **/
-bool e1000_enable_mng_pass_thru(struct e1000_hw *hw)
+bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 {
 	u32 manc;
 	u32 fwsm, factps;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 01a9a4f..d711e14 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -47,8 +47,8 @@
 #include "e1000.h"
 
 #define DRV_VERSION "0.2.0"
-char e1000_driver_name[] = "e1000e";
-const char e1000_driver_version[] = DRV_VERSION;
+char e1000e_driver_name[] = "e1000e";
+const char e1000e_driver_version[] = DRV_VERSION;
 
 static const struct e1000_info *e1000_info_tbl[] = {
 	[board_82571]		= &e1000_82571_info,
@@ -64,7 +64,7 @@ static const struct e1000_info *e1000_info_tbl[] = {
  * e1000_get_hw_dev_name - return device name string
  * used by hardware layer to print debugging information
  **/
-char *e1000_get_hw_dev_name(struct e1000_hw *hw)
+char *e1000e_get_hw_dev_name(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
 	struct net_device *netdev = adapter->netdev;
@@ -1108,7 +1108,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 		 * disconnect (LSC) before accessing any PHY registers */
 		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
 		    (!(er32(STATUS) & E1000_STATUS_LU)))
-			e1000_gig_downshift_workaround_ich8lan(hw);
+			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* 80003ES2LAN workaround-- For packet buffer work-around on
 		 * link down event; disable receives here in the ISR and reset
@@ -1169,7 +1169,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		 * disconnect (LSC) before accessing any PHY registers */
 		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
 		    (!(er32(STATUS) & E1000_STATUS_LU)))
-			e1000_gig_downshift_workaround_ich8lan(hw);
+			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* 80003ES2LAN workaround--
 		 * For packet buffer work-around on link down event;
@@ -1352,12 +1352,12 @@ static int e1000_alloc_ring_dma(struct e1000_adapter *adapter,
 }
 
 /**
- * e1000_setup_tx_resources - allocate Tx resources (Descriptors)
+ * e1000e_setup_tx_resources - allocate Tx resources (Descriptors)
  * @adapter: board private structure
  *
  * Return 0 on success, negative on failure
  **/
-int e1000_setup_tx_resources(struct e1000_adapter *adapter)
+int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 {
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	int err = -ENOMEM, size;
@@ -1389,12 +1389,12 @@ err:
 }
 
 /**
- * e1000_setup_rx_resources - allocate Rx resources (Descriptors)
+ * e1000e_setup_rx_resources - allocate Rx resources (Descriptors)
  * @adapter: board private structure
  *
  * Returns 0 on success, negative on failure
  **/
-int e1000_setup_rx_resources(struct e1000_adapter *adapter)
+int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 {
 	struct e1000_ring *rx_ring = adapter->rx_ring;
 	int size, desc_len, err = -ENOMEM;
@@ -1464,12 +1464,12 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_free_tx_resources - Free Tx Resources per Queue
+ * e1000e_free_tx_resources - Free Tx Resources per Queue
  * @adapter: board private structure
  *
  * Free all transmit software resources
  **/
-void e1000_free_tx_resources(struct e1000_adapter *adapter)
+void e1000e_free_tx_resources(struct e1000_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
@@ -1484,13 +1484,13 @@ void e1000_free_tx_resources(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_free_rx_resources - Free Rx Resources
+ * e1000e_free_rx_resources - Free Rx Resources
  * @adapter: board private structure
  *
  * Free all receive software resources
  **/
 
-void e1000_free_rx_resources(struct e1000_adapter *adapter)
+void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_ring *rx_ring = adapter->rx_ring;
@@ -1693,7 +1693,7 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	index = (vid >> 5) & 0x7F;
 	vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
-	e1000_write_vfta(hw, index, vfta);
+	e1000e_write_vfta(hw, index, vfta);
 }
 
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -1718,7 +1718,7 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	index = (vid >> 5) & 0x7F;
 	vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
-	e1000_write_vfta(hw, index, vfta);
+	e1000e_write_vfta(hw, index, vfta);
 }
 
 static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
@@ -1904,7 +1904,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		ew32(TARC1, tarc);
 	}
 
-	e1000_config_collision_dist(hw);
+	e1000e_config_collision_dist(hw);
 
 	/* Setup Transmit Descriptor Settings for eop descriptor */
 	adapter->txd_cmd = E1000_TXD_CMD_EOP | E1000_TXD_CMD_IFCS;
@@ -2237,14 +2237,14 @@ static void e1000_configure(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_power_up_phy - restore link in case the phy was powered down
+ * e1000e_power_up_phy - restore link in case the phy was powered down
  * @adapter: address of board private structure
  *
  * The phy may be powered down to save power and turn off link when the
  * driver is unloaded and wake on lan is not enabled (among others)
- * *** this routine MUST be followed by a call to e1000_reset ***
+ * *** this routine MUST be followed by a call to e1000e_reset ***
  **/
-void e1000_power_up_phy(struct e1000_adapter *adapter)
+void e1000e_power_up_phy(struct e1000_adapter *adapter)
 {
 	u16 mii_reg = 0;
 
@@ -2280,7 +2280,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		return;
 
 	/* reset is blocked because of a SoL/IDER session */
-	if (e1000_check_mng_mode(hw) ||
+	if (e1000e_check_mng_mode(hw) ||
 	    e1000_check_reset_block(hw))
 		return;
 
@@ -2296,14 +2296,14 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_reset - bring the hardware into a known good state
+ * e1000e_reset - bring the hardware into a known good state
  *
  * This function boots the hardware and enables some settings that
  * require a configuration cycle of the hardware - those cannot be
  * set/changed during runtime. After reset the device needs to be
  * properly configured for rx, tx etc.
  */
-void e1000_reset(struct e1000_adapter *adapter)
+void e1000e_reset(struct e1000_adapter *adapter)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	struct e1000_hw *hw = &adapter->hw;
@@ -2388,7 +2388,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
 	ew32(VET, ETH_P_8021Q);
 
-	e1000_reset_adaptive(hw);
+	e1000e_reset_adaptive(hw);
 	e1000_get_phy_info(hw);
 
 	if (!(adapter->flags & FLAG_SMART_POWER_DOWN)) {
@@ -2404,7 +2404,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 	e1000_release_manageability(adapter);
 }
 
-int e1000_up(struct e1000_adapter *adapter)
+int e1000e_up(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
@@ -2421,7 +2421,7 @@ int e1000_up(struct e1000_adapter *adapter)
 	return 0;
 }
 
-void e1000_down(struct e1000_adapter *adapter)
+void e1000e_down(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
@@ -2457,7 +2457,7 @@ void e1000_down(struct e1000_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
-	e1000_reset(adapter);
+	e1000e_reset(adapter);
 	e1000_clean_tx_ring(adapter);
 	e1000_clean_rx_ring(adapter);
 
@@ -2467,13 +2467,13 @@ void e1000_down(struct e1000_adapter *adapter)
 	 */
 }
 
-void e1000_reinit_locked(struct e1000_adapter *adapter)
+void e1000e_reinit_locked(struct e1000_adapter *adapter)
 {
 	might_sleep();
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		msleep(1);
-	e1000_down(adapter);
-	e1000_up(adapter);
+	e1000e_down(adapter);
+	e1000e_up(adapter);
 	clear_bit(__E1000_RESETTING, &adapter->state);
 }
 
@@ -2544,16 +2544,16 @@ static int e1000_open(struct net_device *netdev)
 		return -EBUSY;
 
 	/* allocate transmit descriptors */
-	err = e1000_setup_tx_resources(adapter);
+	err = e1000e_setup_tx_resources(adapter);
 	if (err)
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
-	err = e1000_setup_rx_resources(adapter);
+	err = e1000e_setup_rx_resources(adapter);
 	if (err)
 		goto err_setup_rx;
 
-	e1000_power_up_phy(adapter);
+	e1000e_power_up_phy(adapter);
 
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 	if ((adapter->hw.mng_cookie.status &
@@ -2563,7 +2563,7 @@ static int e1000_open(struct net_device *netdev)
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now open */
 	if ((adapter->flags & FLAG_HAS_AMT) &&
-	    e1000_check_mng_mode(&adapter->hw))
+	    e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
 	/* before we allocate an interrupt, we must be ready to handle it.
@@ -2576,7 +2576,7 @@ static int e1000_open(struct net_device *netdev)
 	if (err)
 		goto err_req_irq;
 
-	/* From here on the code is the same as e1000_up() */
+	/* From here on the code is the same as e1000e_up() */
 	clear_bit(__E1000_DOWN, &adapter->state);
 
 	netif_poll_enable(netdev);
@@ -2591,11 +2591,11 @@ static int e1000_open(struct net_device *netdev)
 err_req_irq:
 	e1000_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
-	e1000_free_rx_resources(adapter);
+	e1000e_free_rx_resources(adapter);
 err_setup_rx:
-	e1000_free_tx_resources(adapter);
+	e1000e_free_tx_resources(adapter);
 err_setup_tx:
-	e1000_reset(adapter);
+	e1000e_reset(adapter);
 
 	return err;
 }
@@ -2616,12 +2616,12 @@ static int e1000_close(struct net_device *netdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
-	e1000_down(adapter);
+	e1000e_down(adapter);
 	e1000_power_down_phy(adapter);
 	e1000_free_irq(adapter);
 
-	e1000_free_tx_resources(adapter);
-	e1000_free_rx_resources(adapter);
+	e1000e_free_tx_resources(adapter);
+	e1000e_free_rx_resources(adapter);
 
 	/* kill manageability vlan ID if supported, but not if a vlan with
 	 * the same ID is registered on the host OS (let 8021q kill it) */
@@ -2634,7 +2634,7 @@ static int e1000_close(struct net_device *netdev)
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now closed */
 	if ((adapter->flags & FLAG_HAS_AMT) &&
-	    e1000_check_mng_mode(&adapter->hw))
+	    e1000e_check_mng_mode(&adapter->hw))
 		e1000_release_hw_control(adapter);
 
 	return 0;
@@ -2657,11 +2657,11 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
 
-	e1000_rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
+	e1000e_rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
 
 	if (adapter->flags & FLAG_RESET_OVERWRITES_LAA) {
 		/* activate the work around */
-		e1000_set_laa_state_82571(&adapter->hw, 1);
+		e1000e_set_laa_state_82571(&adapter->hw, 1);
 
 		/* Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered  and the time it
@@ -2669,7 +2669,7 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 		 * of the RARs and no incoming packets directed to this port
 		 * are dropped. Eventually the LAA will be in RAR[0] and
 		 * RAR[14] */
-		e1000_rar_set(&adapter->hw,
+		e1000e_rar_set(&adapter->hw,
 			      adapter->hw.mac.addr,
 			      adapter->hw.mac.rar_entry_count - 1);
 	}
@@ -2686,10 +2686,10 @@ static void e1000_update_phy_info(unsigned long data)
 }
 
 /**
- * e1000_update_stats - Update the board statistics counters
+ * e1000e_update_stats - Update the board statistics counters
  * @adapter: board private structure
  **/
-void e1000_update_stats(struct e1000_adapter *adapter)
+void e1000e_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
@@ -2903,7 +2903,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			"Gigabit has been disabled, downgrading speed\n");
 	}
 
-	if ((e1000_enable_tx_pkt_filtering(hw)) &&
+	if ((e1000e_enable_tx_pkt_filtering(hw)) &&
 	    (adapter->mng_vlan_id != adapter->hw.mng_cookie.vlan_id))
 		e1000_update_mng_vlan(adapter);
 
@@ -3005,7 +3005,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 	}
 
 link_up:
-	e1000_update_stats(adapter);
+	e1000e_update_stats(adapter);
 
 	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
@@ -3017,7 +3017,7 @@ link_up:
 	adapter->gotcl = adapter->stats.gotcl - adapter->gotcl_old;
 	adapter->gotcl_old = adapter->stats.gotcl;
 
-	e1000_update_adaptive(&adapter->hw);
+	e1000e_update_adaptive(&adapter->hw);
 
 	if (!netif_carrier_ok(netdev)) {
 		tx_pending = (e1000_desc_unused(tx_ring) + 1 <
@@ -3040,8 +3040,8 @@ link_up:
 
 	/* With 82571 controllers, LAA may be overwritten due to controller
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
-	if (e1000_get_laa_state_82571(hw))
-		e1000_rar_set(hw, adapter->hw.mac.addr, 0);
+	if (e1000e_get_laa_state_82571(hw))
+		e1000e_rar_set(hw, adapter->hw.mac.addr, 0);
 
 	/* Reset the timer */
 	if (!test_bit(__E1000_DOWN, &adapter->state))
@@ -3358,7 +3358,7 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 
 		offset = (u8 *)udp + 8 - skb->data;
 		length = skb->len - offset;
-		return e1000_mng_write_dhcp_info(hw, (u8 *)udp + 8, length);
+		return e1000e_mng_write_dhcp_info(hw, (u8 *)udp + 8, length);
 	}
 
 	return 0;
@@ -3540,7 +3540,7 @@ static void e1000_reset_task(struct work_struct *work)
 	struct e1000_adapter *adapter;
 	adapter = container_of(work, struct e1000_adapter, reset_task);
 
-	e1000_reinit_locked(adapter);
+	e1000e_reinit_locked(adapter);
 }
 
 /**
@@ -3596,10 +3596,10 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		msleep(1);
-	/* e1000_down has a dependency on max_frame_size */
+	/* e1000e_down has a dependency on max_frame_size */
 	adapter->hw.mac.max_frame_size = max_frame;
 	if (netif_running(netdev))
-		e1000_down(adapter);
+		e1000e_down(adapter);
 
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
@@ -3630,9 +3630,9 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	if (netif_running(netdev))
-		e1000_up(adapter);
+		e1000e_up(adapter);
 	else
-		e1000_reset(adapter);
+		e1000e_reset(adapter);
 
 	clear_bit(__E1000_RESETTING, &adapter->state);
 
@@ -3696,7 +3696,7 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	if (netif_running(netdev)) {
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
-		e1000_down(adapter);
+		e1000e_down(adapter);
 		e1000_free_irq(adapter);
 	}
 
@@ -3737,7 +3737,7 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		}
 
 		/* Allow time for pending master requests to run */
-		e1000_disable_pcie_master(&adapter->hw);
+		e1000e_disable_pcie_master(&adapter->hw);
 
 		ew32(WUC, E1000_WUC_PME_EN);
 		ew32(WUFC, wufc);
@@ -3759,7 +3759,7 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 	if (adapter->hw.phy.type == e1000_phy_igp_3)
-		e1000_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
+		e1000e_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
 
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
@@ -3800,21 +3800,21 @@ static int e1000_resume(struct pci_dev *pdev)
 			return err;
 	}
 
-	e1000_power_up_phy(adapter);
-	e1000_reset(adapter);
+	e1000e_power_up_phy(adapter);
+	e1000e_reset(adapter);
 	ew32(WUS, ~0);
 
 	e1000_init_manageability(adapter);
 
 	if (netif_running(netdev))
-		e1000_up(adapter);
+		e1000e_up(adapter);
 
 	netif_device_attach(netdev);
 
 	/* If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver. */
-	if (!(adapter->flags & FLAG_HAS_AMT) || !e1000_check_mng_mode(&adapter->hw))
+	if (!(adapter->flags & FLAG_HAS_AMT) || !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
 	return 0;
@@ -3862,7 +3862,7 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev))
-		e1000_down(adapter);
+		e1000e_down(adapter);
 	pci_disable_device(pdev);
 
 	/* Request a slot slot reset. */
@@ -3892,7 +3892,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	e1000_reset(adapter);
+	e1000e_reset(adapter);
 	ew32(WUS, ~0);
 
 	return PCI_ERS_RESULT_RECOVERED;
@@ -3914,7 +3914,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	e1000_init_manageability(adapter);
 
 	if (netif_running(netdev)) {
-		if (e1000_up(adapter)) {
+		if (e1000e_up(adapter)) {
 			dev_err(&pdev->dev,
 				"can't bring device back up after reset\n");
 			return;
@@ -3927,7 +3927,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver. */
 	if (!(adapter->flags & FLAG_HAS_AMT) ||
-	    !e1000_check_mng_mode(&adapter->hw))
+	    !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
 }
@@ -4001,7 +4001,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		}
 	}
 
-	err = pci_request_regions(pdev, e1000_driver_name);
+	err = pci_request_regions(pdev, e1000e_driver_name);
 	if (err)
 		goto err_pci_reg;
 
@@ -4053,7 +4053,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->set_mac_address		= &e1000_set_mac;
 	netdev->change_mtu		= &e1000_change_mtu;
 	netdev->do_ioctl		= &e1000_ioctl;
-	e1000_set_ethtool_ops(netdev);
+	e1000e_set_ethtool_ops(netdev);
 	netdev->tx_timeout		= &e1000_tx_timeout;
 	netdev->watchdog_timeo		= 5 * HZ;
 	netdev->poll			= &e1000_clean;
@@ -4119,7 +4119,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	 * it. */
 	netdev->features |= NETIF_F_LLTX;
 
-	if (e1000_enable_mng_pass_thru(&adapter->hw))
+	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
 
 	/* before reading the NVM, reset the controller to
@@ -4141,7 +4141,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	}
 
 	/* copy the MAC address out of the NVM */
-	if (e1000_read_mac_addr(&adapter->hw))
+	if (e1000e_read_mac_addr(&adapter->hw))
 		ndev_err(netdev, "NVM Read Error while reading MAC address\n");
 
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
@@ -4168,7 +4168,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
 	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
 
-	e1000_check_options(adapter);
+	e1000e_check_options(adapter);
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
@@ -4214,13 +4214,13 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->wol = adapter->eeprom_wol;
 
 	/* reset the hardware with the new settings */
-	e1000_reset(adapter);
+	e1000e_reset(adapter);
 
 	/* If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver. */
 	if (!(adapter->flags & FLAG_HAS_AMT) ||
-	    !e1000_check_mng_mode(&adapter->hw))
+	    !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
 	/* tell the stack to leave us alone until e1000_open() is called */
@@ -4315,7 +4315,7 @@ static struct pci_error_handlers e1000_err_handler = {
 	.resume = e1000_io_resume,
 };
 
-static struct pci_device_id e1000e_pci_tbl[] = {
+static struct pci_device_id e1000_pci_tbl[] = {
 	/*
 	 * Support for 82571/2/3, es2lan and ich8 will be phased in
 	 * stepwise.
@@ -4358,12 +4358,12 @@ static struct pci_device_id e1000e_pci_tbl[] = {
 
 	{ }	/* terminate list */
 };
-MODULE_DEVICE_TABLE(pci, e1000e_pci_tbl);
+MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
 /* PCI Device API Driver */
 static struct pci_driver e1000_driver = {
-	.name     = e1000_driver_name,
-	.id_table = e1000e_pci_tbl,
+	.name     = e1000e_driver_name,
+	.id_table = e1000_pci_tbl,
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
@@ -4381,17 +4381,17 @@ static struct pci_driver e1000_driver = {
  * e1000_init_module is the first routine called when the driver is
  * loaded. All it does is register with the PCI subsystem.
  **/
-static int __init e1000e_init_module(void)
+static int __init e1000_init_module(void)
 {
 	int ret;
 	printk(KERN_INFO "Intel(R) PRO/1000 Network Driver - %s\n",
-	       e1000_driver_version);
+	       e1000e_driver_version);
 	printk(KERN_INFO "Copyright (c) 1999-2007 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
 }
-module_init(e1000e_init_module);
+module_init(e1000_init_module);
 
 /**
  * e1000_exit_module - Driver Exit Cleanup Routine
@@ -4399,11 +4399,11 @@ module_init(e1000e_init_module);
  * e1000_exit_module is called just before the driver is removed
  * from memory.
  **/
-static void __exit e1000e_exit_module(void)
+static void __exit e1000_exit_module(void)
 {
 	pci_unregister_driver(&e1000_driver);
 }
-module_exit(e1000e_exit_module);
+module_exit(e1000_exit_module);
 
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 9a70d22..e4e655e 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -192,7 +192,7 @@ static int __devinit e1000_validate_option(int *value,
 }
 
 /**
- * e1000_check_options - Range Checking for Command Line Parameters
+ * e1000e_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
  *
  * This routine checks all command line parameters for valid user
@@ -200,7 +200,7 @@ static int __devinit e1000_validate_option(int *value,
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
  **/
-void __devinit e1000_check_options(struct e1000_adapter *adapter)
+void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
@@ -371,11 +371,11 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 			int kmrn_lock_loss = KumeranLockLoss[bd];
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
 			if (hw->mac.type == e1000_ich8lan)
-				e1000_set_kmrn_lock_loss_workaround_ich8lan(hw,
+				e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw,
 								kmrn_lock_loss);
 		} else {
 			if (hw->mac.type == e1000_ich8lan)
-				e1000_set_kmrn_lock_loss_workaround_ich8lan(hw,
+				e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw,
 								       opt.def);
 		}
 	}
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index c9304d8..1efb47a 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -53,14 +53,14 @@ static const u16 e1000_igp_2_cable_length_table[] =
 		 sizeof(e1000_igp_2_cable_length_table[0]))
 
 /**
- *  e1000_check_reset_block_generic - Check if PHY reset is blocked
+ *  e1000e_check_reset_block_generic - Check if PHY reset is blocked
  *  @hw: pointer to the HW structure
  *
  *  Read the PHY management control register and check whether a PHY reset
  *  is blocked.  If a reset is not blocked return 0, otherwise
  *  return E1000_BLK_PHY_RESET (12).
  **/
-s32 e1000_check_reset_block_generic(struct e1000_hw *hw)
+s32 e1000e_check_reset_block_generic(struct e1000_hw *hw)
 {
 	u32 manc;
 
@@ -71,13 +71,13 @@ s32 e1000_check_reset_block_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_phy_id - Retrieve the PHY ID and revision
+ *  e1000e_get_phy_id - Retrieve the PHY ID and revision
  *  @hw: pointer to the HW structure
  *
  *  Reads the PHY registers and stores the PHY ID and possibly the PHY
  *  revision in the hardware structure.
  **/
-s32 e1000_get_phy_id(struct e1000_hw *hw)
+s32 e1000e_get_phy_id(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -100,12 +100,12 @@ s32 e1000_get_phy_id(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_reset_dsp - Reset PHY DSP
+ *  e1000e_phy_reset_dsp - Reset PHY DSP
  *  @hw: pointer to the HW structure
  *
  *  Reset the digital signal processor.
  **/
-s32 e1000_phy_reset_dsp(struct e1000_hw *hw)
+s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
 {
 	s32 ret_val;
 
@@ -210,7 +210,7 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
- *  e1000_read_phy_reg_m88 - Read m88 PHY register
+ *  e1000e_read_phy_reg_m88 - Read m88 PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -219,7 +219,7 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
  *  and storing the retrieved information in data.  Release any acquired
  *  semaphores before exiting.
  **/
-s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
+s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	s32 ret_val;
 
@@ -237,7 +237,7 @@ s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
 }
 
 /**
- *  e1000_write_phy_reg_m88 - Write m88 PHY register
+ *  e1000e_write_phy_reg_m88 - Write m88 PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -245,7 +245,7 @@ s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
  *  Acquires semaphore, if necessary, then writes the data to PHY register
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
-s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
+s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	s32 ret_val;
 
@@ -263,7 +263,7 @@ s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
- *  e1000_read_phy_reg_igp - Read igp PHY register
+ *  e1000e_read_phy_reg_igp - Read igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -272,7 +272,7 @@ s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
  *  and storing the retrieved information in data.  Release any acquired
  *  semaphores before exiting.
  **/
-s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
+s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	s32 ret_val;
 
@@ -300,7 +300,7 @@ s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 }
 
 /**
- *  e1000_write_phy_reg_igp - Write igp PHY register
+ *  e1000e_write_phy_reg_igp - Write igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -308,7 +308,7 @@ s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
  *  Acquires semaphore, if necessary, then writes the data to PHY register
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
-s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
+s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	s32 ret_val;
 
@@ -336,7 +336,7 @@ s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
- *  e1000_read_kmrn_reg - Read kumeran register
+ *  e1000e_read_kmrn_reg - Read kumeran register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -345,7 +345,7 @@ s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
  *  using the kumeran interface.  The information retrieved is stored in data.
  *  Release any acquired semaphores before exiting.
  **/
-s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
+s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	u32 kmrnctrlsta;
 	s32 ret_val;
@@ -369,7 +369,7 @@ s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
 }
 
 /**
- *  e1000_write_kmrn_reg - Write kumeran register
+ *  e1000e_write_kmrn_reg - Write kumeran register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -378,7 +378,7 @@ s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data)
  *  at the offset using the kumeran interface.  Release any acquired semaphores
  *  before exiting.
  **/
-s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
+s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	u32 kmrnctrlsta;
 	s32 ret_val;
@@ -398,13 +398,13 @@ s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
- *  e1000_copper_link_setup_m88 - Setup m88 PHY's for copper link
+ *  e1000e_copper_link_setup_m88 - Setup m88 PHY's for copper link
  *  @hw: pointer to the HW structure
  *
  *  Sets up MDI/MDI-X and polarity for m88 PHY's.  If necessary, transmit clock
  *  and downshift values are set also.
  **/
-s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
+s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -484,7 +484,7 @@ s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
 	}
 
 	/* Commit the changes. */
-	ret_val = e1000_commit_phy(hw);
+	ret_val = e1000e_commit_phy(hw);
 	if (ret_val)
 		hw_dbg(hw, "Error committing the PHY changes\n");
 
@@ -492,13 +492,13 @@ s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_copper_link_setup_igp - Setup igp PHY's for copper link
+ *  e1000e_copper_link_setup_igp - Setup igp PHY's for copper link
  *  @hw: pointer to the HW structure
  *
  *  Sets up LPLU, MDI/MDI-X, polarity, Smartspeed and Master/Slave config for
  *  igp PHY's.
  **/
-s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
+s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -715,7 +715,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		/* Since there really isn't a way to advertise that we are
 		 * capable of RX Pause ONLY, we will advertise that we
 		 * support both symmetric and asymmetric RX PAUSE.  Later
-		 * (in e1000_config_fc_after_link_up) we will disable the
+		 * (in e1000e_config_fc_after_link_up) we will disable the
 		 * hw's ability to send PAUSE frames.
 		 */
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
@@ -816,7 +816,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_setup_copper_link - Configure copper link settings
+ *  e1000e_setup_copper_link - Configure copper link settings
  *  @hw: pointer to the HW structure
  *
  *  Calls the appropriate function to configure the link for auto-neg or forced
@@ -824,7 +824,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
  *  to configure collision distance and flow control are called.  If link is
  *  not established, we return -E1000_ERR_PHY (-2).
  **/
-s32 e1000_setup_copper_link(struct e1000_hw *hw)
+s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	bool link;
@@ -849,7 +849,7 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 	/* Check link status. Wait up to 100 microseconds for link to become
 	 * valid.
 	 */
-	ret_val = e1000_phy_has_link_generic(hw,
+	ret_val = e1000e_phy_has_link_generic(hw,
 					     COPPER_LINK_UP_LIMIT,
 					     10,
 					     &link);
@@ -858,8 +858,8 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 
 	if (link) {
 		hw_dbg(hw, "Valid link established!!!\n");
-		e1000_config_collision_dist(hw);
-		ret_val = e1000_config_fc_after_link_up(hw);
+		e1000e_config_collision_dist(hw);
+		ret_val = e1000e_config_fc_after_link_up(hw);
 	} else {
 		hw_dbg(hw, "Unable to establish link!!!\n");
 	}
@@ -868,14 +868,14 @@ s32 e1000_setup_copper_link(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
+ *  e1000e_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
  *  @hw: pointer to the HW structure
  *
  *  Calls the PHY setup function to force speed and duplex.  Clears the
  *  auto-crossover to force MDI manually.  Waits for link and returns
  *  successful if link up is successful, else -E1000_ERR_PHY (-2).
  **/
-s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
+s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -886,7 +886,7 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
+	e1000e_phy_force_speed_duplex_setup(hw, &phy_data);
 
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
@@ -913,7 +913,7 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (phy->wait_for_link) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on IGP phy.\n");
 
-		ret_val = e1000_phy_has_link_generic(hw,
+		ret_val = e1000e_phy_has_link_generic(hw,
 						     PHY_FORCE_LIMIT,
 						     100000,
 						     &link);
@@ -924,7 +924,7 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 			hw_dbg(hw, "Link taking longer than expected.\n");
 
 		/* Try once more */
-		ret_val = e1000_phy_has_link_generic(hw,
+		ret_val = e1000e_phy_has_link_generic(hw,
 						     PHY_FORCE_LIMIT,
 						     100000,
 						     &link);
@@ -936,7 +936,7 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
+ *  e1000e_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
  *  @hw: pointer to the HW structure
  *
  *  Calls the PHY setup function to force speed and duplex.  Clears the
@@ -945,7 +945,7 @@ s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
  *  After reset, TX_CLK and CRS on TX must be set.  Return successful upon
  *  successful completion, else return corresponding error code.
  **/
-s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
+s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -970,7 +970,7 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
+	e1000e_phy_force_speed_duplex_setup(hw, &phy_data);
 
 	/* Reset the phy to commit changes. */
 	phy_data |= MII_CR_RESET;
@@ -984,7 +984,7 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (phy->wait_for_link) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on M88 phy.\n");
 
-		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
+		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
 			return ret_val;
@@ -996,13 +996,13 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			ret_val = e1e_wphy(hw, M88E1000_PHY_PAGE_SELECT, 0x001d);
 			if (ret_val)
 				return ret_val;
-			ret_val = e1000_phy_reset_dsp(hw);
+			ret_val = e1000e_phy_reset_dsp(hw);
 			if (ret_val)
 				return ret_val;
 		}
 
 		/* Try once more */
-		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
+		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
 		if (ret_val)
 			return ret_val;
@@ -1035,7 +1035,7 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
+ *  e1000e_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
  *  @hw: pointer to the HW structure
  *  @phy_ctrl: pointer to current value of PHY_CONTROL
  *
@@ -1046,7 +1046,7 @@ s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
  *  caller must write to the PHY_CONTROL register for these settings to
  *  take affect.
  **/
-void e1000_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
+void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 ctrl;
@@ -1089,13 +1089,13 @@ void e1000_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
 		hw_dbg(hw, "Forcing 10mb\n");
 	}
 
-	e1000_config_collision_dist(hw);
+	e1000e_config_collision_dist(hw);
 
 	ew32(CTRL, ctrl);
 }
 
 /**
- *  e1000_set_d3_lplu_state - Sets low power link up state for D3
+ *  e1000e_set_d3_lplu_state - Sets low power link up state for D3
  *  @hw: pointer to the HW structure
  *  @active: boolean used to enable/disable lplu
  *
@@ -1108,7 +1108,7 @@ void e1000_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
  *  During driver activity, SmartSpeed should be enabled so performance is
  *  maintained.
  **/
-s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
+s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -1173,14 +1173,14 @@ s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 }
 
 /**
- *  e1000_check_downshift - Checks whether a downshift in speed occured
+ *  e1000e_check_downshift - Checks whether a downshift in speed occured
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns 1
  *
  *  A downshift is detected by querying the PHY link health.
  **/
-s32 e1000_check_downshift(struct e1000_hw *hw)
+s32 e1000e_check_downshift(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -1310,7 +1310,7 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_has_link_generic - Polls PHY for link
+ *  e1000e_phy_has_link_generic - Polls PHY for link
  *  @hw: pointer to the HW structure
  *  @iterations: number of times to poll for link
  *  @usec_interval: delay between polling attempts
@@ -1318,7 +1318,7 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw)
  *
  *  Polls the PHY status register for link, 'iterations' number of times.
  **/
-s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
+s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success)
 {
 	s32 ret_val;
@@ -1349,7 +1349,7 @@ s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 }
 
 /**
- *  e1000_get_cable_length_m88 - Determine cable length for m88 PHY
+ *  e1000e_get_cable_length_m88 - Determine cable length for m88 PHY
  *  @hw: pointer to the HW structure
  *
  *  Reads the PHY specific status register to retrieve the cable length
@@ -1363,7 +1363,7 @@ s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
  *	3			110 - 140 meters
  *	4			> 140 meters
  **/
-s32 e1000_get_cable_length_m88(struct e1000_hw *hw)
+s32 e1000e_get_cable_length_m88(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -1384,7 +1384,7 @@ s32 e1000_get_cable_length_m88(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_cable_length_igp_2 - Determine cable length for igp2 PHY
+ *  e1000e_get_cable_length_igp_2 - Determine cable length for igp2 PHY
  *  @hw: pointer to the HW structure
  *
  *  The automatic gain control (agc) normalizes the amplitude of the
@@ -1394,7 +1394,7 @@ s32 e1000_get_cable_length_m88(struct e1000_hw *hw)
  *  into a lookup table to obtain the approximate cable length
  *  for each channel.
  **/
-s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
+s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -1451,7 +1451,7 @@ s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_phy_info_m88 - Retrieve PHY information
+ *  e1000e_get_phy_info_m88 - Retrieve PHY information
  *  @hw: pointer to the HW structure
  *
  *  Valid for only copper links.  Read the PHY status register (sticky read)
@@ -1460,7 +1460,7 @@ s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
  *  special status register to determine MDI/MDIx and current speed.  If
  *  speed is 1000, then determine cable length, local and remote receiver.
  **/
-s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
+s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32  ret_val;
@@ -1472,7 +1472,7 @@ s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
 		return -E1000_ERR_CONFIG;
 	}
 
-	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
 		return ret_val;
 
@@ -1525,7 +1525,7 @@ s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_phy_info_igp - Retrieve igp PHY information
+ *  e1000e_get_phy_info_igp - Retrieve igp PHY information
  *  @hw: pointer to the HW structure
  *
  *  Read PHY status to determine if link is up.  If link is up, then
@@ -1533,14 +1533,14 @@ s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
  *  PHY port status to determine MDI/MDIx and speed.  Based on the speed,
  *  determine on the cable length, local and remote receiver.
  **/
-s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
+s32 e1000e_get_phy_info_igp(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 	u16 data;
 	bool link;
 
-	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (ret_val)
 		return ret_val;
 
@@ -1588,13 +1588,13 @@ s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_sw_reset - PHY software reset
+ *  e1000e_phy_sw_reset - PHY software reset
  *  @hw: pointer to the HW structure
  *
  *  Does a software reset of the PHY by reading the PHY control register and
  *  setting/write the control register reset bit to the PHY.
  **/
-s32 e1000_phy_sw_reset(struct e1000_hw *hw)
+s32 e1000e_phy_sw_reset(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 phy_ctrl;
@@ -1614,7 +1614,7 @@ s32 e1000_phy_sw_reset(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_hw_reset_generic - PHY hardware reset
+ *  e1000e_phy_hw_reset_generic - PHY hardware reset
  *  @hw: pointer to the HW structure
  *
  *  Verify the reset block is not blocking us from resetting.  Acquire
@@ -1622,7 +1622,7 @@ s32 e1000_phy_sw_reset(struct e1000_hw *hw)
  *  bit in the PHY.  Wait the appropriate delay time for the device to
  *  reset and relase the semaphore (if necessary).
  **/
-s32 e1000_phy_hw_reset_generic(struct e1000_hw *hw)
+s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
@@ -1653,13 +1653,13 @@ s32 e1000_phy_hw_reset_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_cfg_done - Generic configuration done
+ *  e1000e_get_cfg_done - Generic configuration done
  *  @hw: pointer to the HW structure
  *
  *  Generic function to wait 10 milli-seconds for configuration to complete
  *  and return success.
  **/
-s32 e1000_get_cfg_done(struct e1000_hw *hw)
+s32 e1000e_get_cfg_done(struct e1000_hw *hw)
 {
 	mdelay(10);
 	return 0;
@@ -1698,12 +1698,12 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_phy_type_from_id - Get PHY type from id
+ *  e1000e_get_phy_type_from_id - Get PHY type from id
  *  @phy_id: phy_id read from the phy
  *
  *  Returns the phy type from the id.
  **/
-enum e1000_phy_type e1000_get_phy_type_from_id(u32 phy_id)
+enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 {
 	enum e1000_phy_type phy_type = e1000_phy_unknown;
 
@@ -1736,13 +1736,13 @@ enum e1000_phy_type e1000_get_phy_type_from_id(u32 phy_id)
 }
 
 /**
- *  e1000_commit_phy - Soft PHY reset
+ *  e1000e_commit_phy - Soft PHY reset
  *  @hw: pointer to the HW structure
  *
  *  Performs a soft PHY reset on those that apply. This is a function pointer
  *  entry point called by drivers.
  **/
-s32 e1000_commit_phy(struct e1000_hw *hw)
+s32 e1000e_commit_phy(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.commit_phy)
 		return hw->phy.ops.commit_phy(hw);
