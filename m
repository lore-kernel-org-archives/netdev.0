From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/23] e1000e: cleanup ops function pointers
Date: Sat, 21 Nov 2009 01:25:26 -0800
Message-ID: <20091121092524.5715.22539.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:50853 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbZKUJZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:25:36 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The phy and nvm operations structures have function pointers that contain
"phy" and "nvm" in the pointer names which are redundant since the
structures are already obviously in phy and nvm structures.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |   54 +++++++--------
 drivers/net/e1000e/e1000.h   |   16 ++--
 drivers/net/e1000e/es2lan.c  |   26 ++++---
 drivers/net/e1000e/hw.h      |   32 ++++-----
 drivers/net/e1000e/ich8lan.c |  156 +++++++++++++++++++++---------------------
 drivers/net/e1000e/lib.c     |    6 +-
 drivers/net/e1000e/netdev.c  |    4 +
 drivers/net/e1000e/phy.c     |  110 +++++++++++++++---------------
 8 files changed, 201 insertions(+), 203 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 680b7c7..6fe1b3c 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1671,64 +1671,64 @@ static struct e1000_mac_operations e82571_mac_ops = {
 };
 
 static struct e1000_phy_operations e82_phy_ops_igp = {
-	.acquire_phy		= e1000_get_hw_semaphore_82571,
+	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_reset_block	= e1000e_check_reset_block_generic,
-	.commit_phy		= NULL,
+	.commit			= NULL,
 	.force_speed_duplex	= e1000e_phy_force_speed_duplex_igp,
 	.get_cfg_done		= e1000_get_cfg_done_82571,
 	.get_cable_length	= e1000e_get_cable_length_igp_2,
-	.get_phy_info		= e1000e_get_phy_info_igp,
-	.read_phy_reg		= e1000e_read_phy_reg_igp,
-	.release_phy		= e1000_put_hw_semaphore_82571,
-	.reset_phy		= e1000e_phy_hw_reset_generic,
+	.get_info		= e1000e_get_phy_info_igp,
+	.read_reg		= e1000e_read_phy_reg_igp,
+	.release		= e1000_put_hw_semaphore_82571,
+	.reset			= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
-	.write_phy_reg		= e1000e_write_phy_reg_igp,
+	.write_reg		= e1000e_write_phy_reg_igp,
 	.cfg_on_link_up      	= NULL,
 };
 
 static struct e1000_phy_operations e82_phy_ops_m88 = {
-	.acquire_phy		= e1000_get_hw_semaphore_82571,
+	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_reset_block	= e1000e_check_reset_block_generic,
-	.commit_phy		= e1000e_phy_sw_reset,
+	.commit			= e1000e_phy_sw_reset,
 	.force_speed_duplex	= e1000e_phy_force_speed_duplex_m88,
 	.get_cfg_done		= e1000e_get_cfg_done,
 	.get_cable_length	= e1000e_get_cable_length_m88,
-	.get_phy_info		= e1000e_get_phy_info_m88,
-	.read_phy_reg		= e1000e_read_phy_reg_m88,
-	.release_phy		= e1000_put_hw_semaphore_82571,
-	.reset_phy		= e1000e_phy_hw_reset_generic,
+	.get_info		= e1000e_get_phy_info_m88,
+	.read_reg		= e1000e_read_phy_reg_m88,
+	.release		= e1000_put_hw_semaphore_82571,
+	.reset			= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
-	.write_phy_reg		= e1000e_write_phy_reg_m88,
+	.write_reg		= e1000e_write_phy_reg_m88,
 	.cfg_on_link_up      	= NULL,
 };
 
 static struct e1000_phy_operations e82_phy_ops_bm = {
-	.acquire_phy		= e1000_get_hw_semaphore_82571,
+	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_reset_block	= e1000e_check_reset_block_generic,
-	.commit_phy		= e1000e_phy_sw_reset,
+	.commit			= e1000e_phy_sw_reset,
 	.force_speed_duplex	= e1000e_phy_force_speed_duplex_m88,
 	.get_cfg_done		= e1000e_get_cfg_done,
 	.get_cable_length	= e1000e_get_cable_length_m88,
-	.get_phy_info		= e1000e_get_phy_info_m88,
-	.read_phy_reg		= e1000e_read_phy_reg_bm2,
-	.release_phy		= e1000_put_hw_semaphore_82571,
-	.reset_phy		= e1000e_phy_hw_reset_generic,
+	.get_info		= e1000e_get_phy_info_m88,
+	.read_reg		= e1000e_read_phy_reg_bm2,
+	.release		= e1000_put_hw_semaphore_82571,
+	.reset			= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
-	.write_phy_reg		= e1000e_write_phy_reg_bm2,
+	.write_reg		= e1000e_write_phy_reg_bm2,
 	.cfg_on_link_up      	= NULL,
 };
 
 static struct e1000_nvm_operations e82571_nvm_ops = {
-	.acquire_nvm		= e1000_acquire_nvm_82571,
-	.read_nvm		= e1000e_read_nvm_eerd,
-	.release_nvm		= e1000_release_nvm_82571,
-	.update_nvm		= e1000_update_nvm_checksum_82571,
+	.acquire		= e1000_acquire_nvm_82571,
+	.read			= e1000e_read_nvm_eerd,
+	.release		= e1000_release_nvm_82571,
+	.update			= e1000_update_nvm_checksum_82571,
 	.valid_led_default	= e1000_valid_led_default_82571,
-	.validate_nvm		= e1000_validate_nvm_checksum_82571,
-	.write_nvm		= e1000_write_nvm_82571,
+	.validate		= e1000_validate_nvm_checksum_82571,
+	.write			= e1000_write_nvm_82571,
 };
 
 struct e1000_info e1000_82571_info = {
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index dac00a0..602598c 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -584,7 +584,7 @@ extern s32 e1000_get_cable_length_82577(struct e1000_hw *hw);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
-	return hw->phy.ops.reset_phy(hw);
+	return hw->phy.ops.reset(hw);
 }
 
 static inline s32 e1000_check_reset_block(struct e1000_hw *hw)
@@ -594,12 +594,12 @@ static inline s32 e1000_check_reset_block(struct e1000_hw *hw)
 
 static inline s32 e1e_rphy(struct e1000_hw *hw, u32 offset, u16 *data)
 {
-	return hw->phy.ops.read_phy_reg(hw, offset, data);
+	return hw->phy.ops.read_reg(hw, offset, data);
 }
 
 static inline s32 e1e_wphy(struct e1000_hw *hw, u32 offset, u16 data)
 {
-	return hw->phy.ops.write_phy_reg(hw, offset, data);
+	return hw->phy.ops.write_reg(hw, offset, data);
 }
 
 static inline s32 e1000_get_cable_length(struct e1000_hw *hw)
@@ -619,27 +619,27 @@ extern s32 e1000e_read_mac_addr(struct e1000_hw *hw);
 
 static inline s32 e1000_validate_nvm_checksum(struct e1000_hw *hw)
 {
-	return hw->nvm.ops.validate_nvm(hw);
+	return hw->nvm.ops.validate(hw);
 }
 
 static inline s32 e1000e_update_nvm_checksum(struct e1000_hw *hw)
 {
-	return hw->nvm.ops.update_nvm(hw);
+	return hw->nvm.ops.update(hw);
 }
 
 static inline s32 e1000_read_nvm(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
-	return hw->nvm.ops.read_nvm(hw, offset, words, data);
+	return hw->nvm.ops.read(hw, offset, words, data);
 }
 
 static inline s32 e1000_write_nvm(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
-	return hw->nvm.ops.write_nvm(hw, offset, words, data);
+	return hw->nvm.ops.write(hw, offset, words, data);
 }
 
 static inline s32 e1000_get_phy_info(struct e1000_hw *hw)
 {
-	return hw->phy.ops.get_phy_info(hw);
+	return hw->phy.ops.get_info(hw);
 }
 
 static inline s32 e1000e_check_mng_mode(struct e1000_hw *hw)
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index f5601c5..d024e20 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1378,30 +1378,30 @@ static struct e1000_mac_operations es2_mac_ops = {
 };
 
 static struct e1000_phy_operations es2_phy_ops = {
-	.acquire_phy		= e1000_acquire_phy_80003es2lan,
+	.acquire		= e1000_acquire_phy_80003es2lan,
 	.check_reset_block	= e1000e_check_reset_block_generic,
-	.commit_phy	 	= e1000e_phy_sw_reset,
+	.commit		 	= e1000e_phy_sw_reset,
 	.force_speed_duplex 	= e1000_phy_force_speed_duplex_80003es2lan,
 	.get_cfg_done       	= e1000_get_cfg_done_80003es2lan,
 	.get_cable_length   	= e1000_get_cable_length_80003es2lan,
-	.get_phy_info       	= e1000e_get_phy_info_m88,
-	.read_phy_reg       	= e1000_read_phy_reg_gg82563_80003es2lan,
-	.release_phy		= e1000_release_phy_80003es2lan,
-	.reset_phy	  	= e1000e_phy_hw_reset_generic,
+	.get_info       	= e1000e_get_phy_info_m88,
+	.read_reg       	= e1000_read_phy_reg_gg82563_80003es2lan,
+	.release		= e1000_release_phy_80003es2lan,
+	.reset		  	= e1000e_phy_hw_reset_generic,
 	.set_d0_lplu_state  	= NULL,
 	.set_d3_lplu_state  	= e1000e_set_d3_lplu_state,
-	.write_phy_reg      	= e1000_write_phy_reg_gg82563_80003es2lan,
+	.write_reg      	= e1000_write_phy_reg_gg82563_80003es2lan,
 	.cfg_on_link_up      	= e1000_cfg_on_link_up_80003es2lan,
 };
 
 static struct e1000_nvm_operations es2_nvm_ops = {
-	.acquire_nvm		= e1000_acquire_nvm_80003es2lan,
-	.read_nvm		= e1000e_read_nvm_eerd,
-	.release_nvm		= e1000_release_nvm_80003es2lan,
-	.update_nvm		= e1000e_update_nvm_checksum_generic,
+	.acquire		= e1000_acquire_nvm_80003es2lan,
+	.read			= e1000e_read_nvm_eerd,
+	.release		= e1000_release_nvm_80003es2lan,
+	.update			= e1000e_update_nvm_checksum_generic,
 	.valid_led_default	= e1000e_valid_led_default,
-	.validate_nvm		= e1000e_validate_nvm_checksum_generic,
-	.write_nvm		= e1000_write_nvm_80003es2lan,
+	.validate		= e1000e_validate_nvm_checksum_generic,
+	.write			= e1000_write_nvm_80003es2lan,
 };
 
 struct e1000_info e1000_es2_info = {
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 44808b0..842d8e7 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -755,34 +755,34 @@ struct e1000_mac_operations {
 
 /* Function pointers for the PHY. */
 struct e1000_phy_operations {
-	s32  (*acquire_phy)(struct e1000_hw *);
+	s32  (*acquire)(struct e1000_hw *);
+	s32  (*cfg_on_link_up)(struct e1000_hw *);
 	s32  (*check_polarity)(struct e1000_hw *);
 	s32  (*check_reset_block)(struct e1000_hw *);
-	s32  (*commit_phy)(struct e1000_hw *);
+	s32  (*commit)(struct e1000_hw *);
 	s32  (*force_speed_duplex)(struct e1000_hw *);
 	s32  (*get_cfg_done)(struct e1000_hw *hw);
 	s32  (*get_cable_length)(struct e1000_hw *);
-	s32  (*get_phy_info)(struct e1000_hw *);
-	s32  (*read_phy_reg)(struct e1000_hw *, u32, u16 *);
-	s32  (*read_phy_reg_locked)(struct e1000_hw *, u32, u16 *);
-	void (*release_phy)(struct e1000_hw *);
-	s32  (*reset_phy)(struct e1000_hw *);
+	s32  (*get_info)(struct e1000_hw *);
+	s32  (*read_reg)(struct e1000_hw *, u32, u16 *);
+	s32  (*read_reg_locked)(struct e1000_hw *, u32, u16 *);
+	void (*release)(struct e1000_hw *);
+	s32  (*reset)(struct e1000_hw *);
 	s32  (*set_d0_lplu_state)(struct e1000_hw *, bool);
 	s32  (*set_d3_lplu_state)(struct e1000_hw *, bool);
-	s32  (*write_phy_reg)(struct e1000_hw *, u32, u16);
-	s32  (*write_phy_reg_locked)(struct e1000_hw *, u32, u16);
-	s32  (*cfg_on_link_up)(struct e1000_hw *);
+	s32  (*write_reg)(struct e1000_hw *, u32, u16);
+	s32  (*write_reg_locked)(struct e1000_hw *, u32, u16);
 };
 
 /* Function pointers for the NVM. */
 struct e1000_nvm_operations {
-	s32  (*acquire_nvm)(struct e1000_hw *);
-	s32  (*read_nvm)(struct e1000_hw *, u16, u16, u16 *);
-	void (*release_nvm)(struct e1000_hw *);
-	s32  (*update_nvm)(struct e1000_hw *);
+	s32  (*acquire)(struct e1000_hw *);
+	s32  (*read)(struct e1000_hw *, u16, u16, u16 *);
+	void (*release)(struct e1000_hw *);
+	s32  (*update)(struct e1000_hw *);
 	s32  (*valid_led_default)(struct e1000_hw *, u16 *);
-	s32  (*validate_nvm)(struct e1000_hw *);
-	s32  (*write_nvm)(struct e1000_hw *, u16, u16, u16 *);
+	s32  (*validate)(struct e1000_hw *);
+	s32  (*write)(struct e1000_hw *, u16, u16, u16 *);
 };
 
 struct e1000_mac_info {
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 101a271..dd94fc2 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -260,12 +260,12 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->reset_delay_us           = 100;
 
 	phy->ops.check_polarity       = e1000_check_polarity_ife_ich8lan;
-	phy->ops.read_phy_reg         = e1000_read_phy_reg_hv;
-	phy->ops.read_phy_reg_locked  = e1000_read_phy_reg_hv_locked;
+	phy->ops.read_reg             = e1000_read_phy_reg_hv;
+	phy->ops.read_reg_locked      = e1000_read_phy_reg_hv_locked;
 	phy->ops.set_d0_lplu_state    = e1000_set_lplu_state_pchlan;
 	phy->ops.set_d3_lplu_state    = e1000_set_lplu_state_pchlan;
-	phy->ops.write_phy_reg        = e1000_write_phy_reg_hv;
-	phy->ops.write_phy_reg_locked = e1000_write_phy_reg_hv_locked;
+	phy->ops.write_reg            = e1000_write_phy_reg_hv;
+	phy->ops.write_reg_locked     = e1000_write_phy_reg_hv_locked;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
 	phy->id = e1000_phy_unknown;
@@ -277,8 +277,8 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		phy->ops.force_speed_duplex =
 			e1000_phy_force_speed_duplex_82577;
 		phy->ops.get_cable_length   = e1000_get_cable_length_82577;
-		phy->ops.get_phy_info = e1000_get_phy_info_82577;
-		phy->ops.commit_phy = e1000e_phy_sw_reset;
+		phy->ops.get_info = e1000_get_phy_info_82577;
+		phy->ops.commit = e1000e_phy_sw_reset;
 	}
 
 	return ret_val;
@@ -305,8 +305,8 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_determine_phy_address(hw);
 	if (ret_val) {
-		hw->phy.ops.write_phy_reg = e1000e_write_phy_reg_bm;
-		hw->phy.ops.read_phy_reg  = e1000e_read_phy_reg_bm;
+		phy->ops.write_reg = e1000e_write_phy_reg_bm;
+		phy->ops.read_reg  = e1000e_read_phy_reg_bm;
 		ret_val = e1000e_determine_phy_address(hw);
 		if (ret_val)
 			return ret_val;
@@ -326,8 +326,8 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	case IGP03E1000_E_PHY_ID:
 		phy->type = e1000_phy_igp_3;
 		phy->autoneg_mask = AUTONEG_ADVERTISE_SPEED_DEFAULT;
-		phy->ops.read_phy_reg_locked = e1000e_read_phy_reg_igp_locked;
-		phy->ops.write_phy_reg_locked = e1000e_write_phy_reg_igp_locked;
+		phy->ops.read_reg_locked = e1000e_read_phy_reg_igp_locked;
+		phy->ops.write_reg_locked = e1000e_write_phy_reg_igp_locked;
 		break;
 	case IFE_E_PHY_ID:
 	case IFE_PLUS_E_PHY_ID:
@@ -338,9 +338,9 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	case BME1000_E_PHY_ID:
 		phy->type = e1000_phy_bm;
 		phy->autoneg_mask = AUTONEG_ADVERTISE_SPEED_DEFAULT;
-		hw->phy.ops.read_phy_reg = e1000e_read_phy_reg_bm;
-		hw->phy.ops.write_phy_reg = e1000e_write_phy_reg_bm;
-		hw->phy.ops.commit_phy = e1000e_phy_sw_reset;
+		phy->ops.read_reg = e1000e_read_phy_reg_bm;
+		phy->ops.write_reg = e1000e_write_phy_reg_bm;
+		phy->ops.commit = e1000e_phy_sw_reset;
 		break;
 	default:
 		return -E1000_ERR_PHY;
@@ -816,7 +816,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 word_addr, reg_data, reg_addr, phy_page = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -912,7 +912,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 			reg_addr &= PHY_REG_MASK;
 			reg_addr |= phy_page;
 
-			ret_val = phy->ops.write_phy_reg_locked(hw,
+			ret_val = phy->ops.write_reg_locked(hw,
 			                                    (u32)reg_addr,
 			                                    reg_data);
 			if (ret_val)
@@ -921,7 +921,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	}
 
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 	return ret_val;
 }
 
@@ -945,15 +945,14 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 		goto out;
 
 	/* Wrap the whole flow with the sw flag */
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		goto out;
 
 	/* Disable K1 when link is 1Gbps, otherwise use the NVM setting */
 	if (link) {
 		if (hw->phy.type == e1000_phy_82578) {
-			ret_val = hw->phy.ops.read_phy_reg_locked(hw,
-			                                          BM_CS_STATUS,
+			ret_val = hw->phy.ops.read_reg_locked(hw, BM_CS_STATUS,
 			                                          &status_reg);
 			if (ret_val)
 				goto release;
@@ -969,8 +968,7 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 		}
 
 		if (hw->phy.type == e1000_phy_82577) {
-			ret_val = hw->phy.ops.read_phy_reg_locked(hw,
-			                                          HV_M_STATUS,
+			ret_val = hw->phy.ops.read_reg_locked(hw, HV_M_STATUS,
 			                                          &status_reg);
 			if (ret_val)
 				goto release;
@@ -986,14 +984,14 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 		}
 
 		/* Link stall fix for link up */
-		ret_val = hw->phy.ops.write_phy_reg_locked(hw, PHY_REG(770, 19),
+		ret_val = hw->phy.ops.write_reg_locked(hw, PHY_REG(770, 19),
 		                                           0x0100);
 		if (ret_val)
 			goto release;
 
 	} else {
 		/* Link stall fix for link down */
-		ret_val = hw->phy.ops.write_phy_reg_locked(hw, PHY_REG(770, 19),
+		ret_val = hw->phy.ops.write_reg_locked(hw, PHY_REG(770, 19),
 		                                           0x4100);
 		if (ret_val)
 			goto release;
@@ -1002,7 +1000,7 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 	ret_val = e1000_configure_k1_ich8lan(hw, k1_enable);
 
 release:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 out:
 	return ret_val;
 }
@@ -1078,7 +1076,7 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 	if (hw->mac.type != e1000_pchlan)
 		return ret_val;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -1092,7 +1090,7 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 
 	mac_reg = er32(PHY_CTRL);
 
-	ret_val = hw->phy.ops.read_phy_reg_locked(hw, HV_OEM_BITS, &oem_reg);
+	ret_val = hw->phy.ops.read_reg_locked(hw, HV_OEM_BITS, &oem_reg);
 	if (ret_val)
 		goto out;
 
@@ -1113,10 +1111,10 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 	}
 	/* Restart auto-neg to activate the bits */
 	oem_reg |= HV_OEM_BITS_RESTART_AN;
-	ret_val = hw->phy.ops.write_phy_reg_locked(hw, HV_OEM_BITS, oem_reg);
+	ret_val = hw->phy.ops.write_reg_locked(hw, HV_OEM_BITS, oem_reg);
 
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 
 	return ret_val;
 }
@@ -1159,7 +1157,7 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	}
 
 	/* Select page 0 */
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -1167,7 +1165,7 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT, 0);
 	if (ret_val)
 		goto out;
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 
 	/*
 	 * Configure the K1 Si workaround during phy reset assuming there is
@@ -1667,7 +1665,7 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		goto out;
 	}
 
-	nvm->ops.acquire_nvm(hw);
+	nvm->ops.acquire(hw);
 
 	ret_val = e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
 	if (ret_val) {
@@ -1693,7 +1691,7 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		}
 	}
 
-	nvm->ops.release_nvm(hw);
+	nvm->ops.release(hw);
 
 out:
 	if (ret_val)
@@ -1951,14 +1949,14 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		return -E1000_ERR_NVM;
 	}
 
-	nvm->ops.acquire_nvm(hw);
+	nvm->ops.acquire(hw);
 
 	for (i = 0; i < words; i++) {
 		dev_spec->shadow_ram[offset+i].modified = 1;
 		dev_spec->shadow_ram[offset+i].value = data[i];
 	}
 
-	nvm->ops.release_nvm(hw);
+	nvm->ops.release(hw);
 
 	return 0;
 }
@@ -1989,7 +1987,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (nvm->type != e1000_nvm_flash_sw)
 		goto out;
 
-	nvm->ops.acquire_nvm(hw);
+	nvm->ops.acquire(hw);
 
 	/*
 	 * We're writing to the opposite bank so if we're on bank 1,
@@ -2007,7 +2005,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		old_bank_offset = 0;
 		ret_val = e1000_erase_flash_bank_ich8lan(hw, 1);
 		if (ret_val) {
-			nvm->ops.release_nvm(hw);
+			nvm->ops.release(hw);
 			goto out;
 		}
 	} else {
@@ -2015,7 +2013,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		new_bank_offset = 0;
 		ret_val = e1000_erase_flash_bank_ich8lan(hw, 0);
 		if (ret_val) {
-			nvm->ops.release_nvm(hw);
+			nvm->ops.release(hw);
 			goto out;
 		}
 	}
@@ -2073,7 +2071,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (ret_val) {
 		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
 		e_dbg("Flash commit failed.\n");
-		nvm->ops.release_nvm(hw);
+		nvm->ops.release(hw);
 		goto out;
 	}
 
@@ -2086,7 +2084,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	act_offset = new_bank_offset + E1000_ICH_NVM_SIG_WORD;
 	ret_val = e1000_read_flash_word_ich8lan(hw, act_offset, &data);
 	if (ret_val) {
-		nvm->ops.release_nvm(hw);
+		nvm->ops.release(hw);
 		goto out;
 	}
 	data &= 0xBFFF;
@@ -2094,7 +2092,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 						       act_offset * 2 + 1,
 						       (u8)(data >> 8));
 	if (ret_val) {
-		nvm->ops.release_nvm(hw);
+		nvm->ops.release(hw);
 		goto out;
 	}
 
@@ -2107,7 +2105,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	act_offset = (old_bank_offset + E1000_ICH_NVM_SIG_WORD) * 2 + 1;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
 	if (ret_val) {
-		nvm->ops.release_nvm(hw);
+		nvm->ops.release(hw);
 		goto out;
 	}
 
@@ -2117,7 +2115,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		dev_spec->shadow_ram[i].value = 0xFFFF;
 	}
 
-	nvm->ops.release_nvm(hw);
+	nvm->ops.release(hw);
 
 	/*
 	 * Reload the EEPROM, or else modifications will not appear
@@ -2186,7 +2184,7 @@ void e1000e_write_protect_nvm_ich8lan(struct e1000_hw *hw)
 	union ich8_hws_flash_status hsfsts;
 	u32 gfpreg;
 
-	nvm->ops.acquire_nvm(hw);
+	nvm->ops.acquire(hw);
 
 	gfpreg = er32flash(ICH_FLASH_GFPREG);
 
@@ -2207,7 +2205,7 @@ void e1000e_write_protect_nvm_ich8lan(struct e1000_hw *hw)
 	hsfsts.hsf_status.flockdn = true;
 	ew32flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 
-	nvm->ops.release_nvm(hw);
+	nvm->ops.release(hw);
 }
 
 /**
@@ -2743,7 +2741,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	 * Reset the phy after disabling host wakeup to reset the Rx buffer.
 	 */
 	if (hw->phy.type == e1000_phy_82578) {
-		hw->phy.ops.read_phy_reg(hw, BM_WUC, &i);
+		hw->phy.ops.read_reg(hw, BM_WUC, &i);
 		ret_val = e1000_phy_hw_reset_ich8lan(hw);
 		if (ret_val)
 			return ret_val;
@@ -2890,7 +2888,7 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	ew32(FCTTV, hw->fc.pause_time);
 	if ((hw->phy.type == e1000_phy_82578) ||
 	    (hw->phy.type == e1000_phy_82577)) {
-		ret_val = hw->phy.ops.write_phy_reg(hw,
+		ret_val = hw->phy.ops.write_reg(hw,
 		                             PHY_REG(BM_PORT_CTRL_PAGE, 27),
 		                             hw->fc.pause_time);
 		if (ret_val)
@@ -2953,7 +2951,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 			return ret_val;
 		break;
 	case e1000_phy_ife:
-		ret_val = hw->phy.ops.read_phy_reg(hw, IFE_PHY_MDIX_CONTROL,
+		ret_val = hw->phy.ops.read_reg(hw, IFE_PHY_MDIX_CONTROL,
 		                               &reg_data);
 		if (ret_val)
 			return ret_val;
@@ -2972,7 +2970,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 			reg_data |= IFE_PMC_AUTO_MDIX;
 			break;
 		}
-		ret_val = hw->phy.ops.write_phy_reg(hw, IFE_PHY_MDIX_CONTROL,
+		ret_val = hw->phy.ops.write_reg(hw, IFE_PHY_MDIX_CONTROL,
 		                                reg_data);
 		if (ret_val)
 			return ret_val;
@@ -3274,7 +3272,7 @@ static s32 e1000_led_off_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_setup_led_pchlan(struct e1000_hw *hw)
 {
-	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG,
+	return hw->phy.ops.write_reg(hw, HV_LED_CONFIG,
 					(u16)hw->mac.ledctl_mode1);
 }
 
@@ -3286,7 +3284,7 @@ static s32 e1000_setup_led_pchlan(struct e1000_hw *hw)
  **/
 static s32 e1000_cleanup_led_pchlan(struct e1000_hw *hw)
 {
-	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG,
+	return hw->phy.ops.write_reg(hw, HV_LED_CONFIG,
 					(u16)hw->mac.ledctl_default);
 }
 
@@ -3318,7 +3316,7 @@ static s32 e1000_led_on_pchlan(struct e1000_hw *hw)
 		}
 	}
 
-	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG, data);
+	return hw->phy.ops.write_reg(hw, HV_LED_CONFIG, data);
 }
 
 /**
@@ -3349,7 +3347,7 @@ static s32 e1000_led_off_pchlan(struct e1000_hw *hw)
 		}
 	}
 
-	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG, data);
+	return hw->phy.ops.write_reg(hw, HV_LED_CONFIG, data);
 }
 
 /**
@@ -3426,20 +3424,20 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 	/* Clear PHY statistics registers */
 	if ((hw->phy.type == e1000_phy_82578) ||
 	    (hw->phy.type == e1000_phy_82577)) {
-		hw->phy.ops.read_phy_reg(hw, HV_SCC_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_SCC_LOWER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_ECOL_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_ECOL_LOWER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_MCC_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_MCC_LOWER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_LATECOL_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_LATECOL_LOWER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_COLC_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_COLC_LOWER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_DC_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_DC_LOWER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_TNCRS_UPPER, &phy_data);
-		hw->phy.ops.read_phy_reg(hw, HV_TNCRS_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_SCC_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_SCC_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_ECOL_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_ECOL_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_MCC_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_MCC_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_LATECOL_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_LATECOL_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_COLC_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_COLC_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_DC_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_DC_LOWER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_TNCRS_UPPER, &phy_data);
+		hw->phy.ops.read_reg(hw, HV_TNCRS_LOWER, &phy_data);
 	}
 }
 
@@ -3462,29 +3460,29 @@ static struct e1000_mac_operations ich8_mac_ops = {
 };
 
 static struct e1000_phy_operations ich8_phy_ops = {
-	.acquire_phy		= e1000_acquire_swflag_ich8lan,
+	.acquire		= e1000_acquire_swflag_ich8lan,
 	.check_reset_block	= e1000_check_reset_block_ich8lan,
-	.commit_phy		= NULL,
+	.commit			= NULL,
 	.force_speed_duplex	= e1000_phy_force_speed_duplex_ich8lan,
 	.get_cfg_done		= e1000_get_cfg_done_ich8lan,
 	.get_cable_length	= e1000e_get_cable_length_igp_2,
-	.get_phy_info		= e1000_get_phy_info_ich8lan,
-	.read_phy_reg		= e1000e_read_phy_reg_igp,
-	.release_phy		= e1000_release_swflag_ich8lan,
-	.reset_phy		= e1000_phy_hw_reset_ich8lan,
+	.get_info		= e1000_get_phy_info_ich8lan,
+	.read_reg		= e1000e_read_phy_reg_igp,
+	.release		= e1000_release_swflag_ich8lan,
+	.reset			= e1000_phy_hw_reset_ich8lan,
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_ich8lan,
 	.set_d3_lplu_state	= e1000_set_d3_lplu_state_ich8lan,
-	.write_phy_reg		= e1000e_write_phy_reg_igp,
+	.write_reg		= e1000e_write_phy_reg_igp,
 };
 
 static struct e1000_nvm_operations ich8_nvm_ops = {
-	.acquire_nvm		= e1000_acquire_nvm_ich8lan,
-	.read_nvm	 	= e1000_read_nvm_ich8lan,
-	.release_nvm		= e1000_release_nvm_ich8lan,
-	.update_nvm		= e1000_update_nvm_checksum_ich8lan,
+	.acquire		= e1000_acquire_nvm_ich8lan,
+	.read		 	= e1000_read_nvm_ich8lan,
+	.release		= e1000_release_nvm_ich8lan,
+	.update			= e1000_update_nvm_checksum_ich8lan,
 	.valid_led_default	= e1000_valid_led_default_ich8lan,
-	.validate_nvm		= e1000_validate_nvm_checksum_ich8lan,
-	.write_nvm		= e1000_write_nvm_ich8lan,
+	.validate		= e1000_validate_nvm_checksum_ich8lan,
+	.write			= e1000_write_nvm_ich8lan,
 };
 
 struct e1000_info e1000_ich8_info = {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index fa31c51..f664fc0 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1985,7 +1985,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		return -E1000_ERR_NVM;
 	}
 
-	ret_val = nvm->ops.acquire_nvm(hw);
+	ret_val = nvm->ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -1996,7 +1996,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 
 		ret_val = e1000_ready_nvm_eeprom(hw);
 		if (ret_val) {
-			nvm->ops.release_nvm(hw);
+			nvm->ops.release(hw);
 			return ret_val;
 		}
 
@@ -2035,7 +2035,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	}
 
 	msleep(10);
-	nvm->ops.release_nvm(hw);
+	nvm->ops.release(hw);
 	return 0;
 }
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0b53523..6eb9693 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4419,7 +4419,7 @@ static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
 	e1e_wphy(&adapter->hw, BM_WUC, E1000_WUC_PME_EN);
 
 	/* activate PHY wakeup */
-	retval = hw->phy.ops.acquire_phy(hw);
+	retval = hw->phy.ops.acquire(hw);
 	if (retval) {
 		e_err("Could not acquire PHY\n");
 		return retval;
@@ -4436,7 +4436,7 @@ static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
 	if (retval)
 		e_err("Could not set PHY Host Wakeup bit\n");
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 
 	return retval;
 }
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index cff1df2..765dc38 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -131,7 +131,7 @@ s32 e1000e_get_phy_id(struct e1000_hw *hw)
 	u16 phy_id;
 	u16 retry_count = 0;
 
-	if (!(phy->ops.read_phy_reg))
+	if (!(phy->ops.read_reg))
 		goto out;
 
 	while (retry_count < 2) {
@@ -157,24 +157,24 @@ s32 e1000e_get_phy_id(struct e1000_hw *hw)
 		 * MDIC mode. No harm in trying again in this case since
 		 * the PHY ID is unknown at this point anyway
 		 */
-		ret_val = phy->ops.acquire_phy(hw);
+		ret_val = phy->ops.acquire(hw);
 		if (ret_val)
 			goto out;
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
 		if (ret_val)
 			goto out;
-		phy->ops.release_phy(hw);
+		phy->ops.release(hw);
 
 		retry_count++;
 	}
 out:
 	/* Revert to MDIO fast mode, if applicable */
 	if (retry_count) {
-		ret_val = phy->ops.acquire_phy(hw);
+		ret_val = phy->ops.acquire(hw);
 		if (ret_val)
 			return ret_val;
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
-		phy->ops.release_phy(hw);
+		phy->ops.release(hw);
 	}
 
 	return ret_val;
@@ -318,14 +318,14 @@ s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
 {
 	s32 ret_val;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					   data);
 
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 
 	return ret_val;
 }
@@ -343,14 +343,14 @@ s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
 {
 	s32 ret_val;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					    data);
 
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 
 	return ret_val;
 }
@@ -372,10 +372,10 @@ static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire_phy))
+		if (!(hw->phy.ops.acquire))
 			goto out;
 
-		ret_val = hw->phy.ops.acquire_phy(hw);
+		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			goto out;
 	}
@@ -393,7 +393,7 @@ static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
 
 release:
 	if (!locked)
-		hw->phy.ops.release_phy(hw);
+		hw->phy.ops.release(hw);
 out:
 	return ret_val;
 }
@@ -443,10 +443,10 @@ static s32 __e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire_phy))
+		if (!(hw->phy.ops.acquire))
 			goto out;
 
-		ret_val = hw->phy.ops.acquire_phy(hw);
+		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			goto out;
 	}
@@ -464,7 +464,7 @@ static s32 __e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data,
 
 release:
 	if (!locked)
-		hw->phy.ops.release_phy(hw);
+		hw->phy.ops.release(hw);
 
 out:
 	return ret_val;
@@ -516,10 +516,10 @@ static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire_phy))
+		if (!(hw->phy.ops.acquire))
 			goto out;
 
-		ret_val = hw->phy.ops.acquire_phy(hw);
+		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			goto out;
 	}
@@ -534,7 +534,7 @@ static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
 	*data = (u16)kmrnctrlsta;
 
 	if (!locked)
-		hw->phy.ops.release_phy(hw);
+		hw->phy.ops.release(hw);
 
 out:
 	return ret_val;
@@ -588,10 +588,10 @@ static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
 	s32 ret_val = 0;
 
 	if (!locked) {
-		if (!(hw->phy.ops.acquire_phy))
+		if (!(hw->phy.ops.acquire))
 			goto out;
 
-		ret_val = hw->phy.ops.acquire_phy(hw);
+		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			goto out;
 	}
@@ -603,7 +603,7 @@ static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
 	udelay(2);
 
 	if (!locked)
-		hw->phy.ops.release_phy(hw);
+		hw->phy.ops.release(hw);
 
 out:
 	return ret_val;
@@ -650,7 +650,7 @@ s32 e1000_copper_link_setup_82577(struct e1000_hw *hw)
 	u16 phy_data;
 
 	/* Enable CRS on TX. This must be set for half-duplex operation. */
-	ret_val = phy->ops.read_phy_reg(hw, I82577_CFG_REG, &phy_data);
+	ret_val = phy->ops.read_reg(hw, I82577_CFG_REG, &phy_data);
 	if (ret_val)
 		goto out;
 
@@ -659,16 +659,16 @@ s32 e1000_copper_link_setup_82577(struct e1000_hw *hw)
 	/* Enable downshift */
 	phy_data |= I82577_CFG_ENABLE_DOWNSHIFT;
 
-	ret_val = phy->ops.write_phy_reg(hw, I82577_CFG_REG, phy_data);
+	ret_val = phy->ops.write_reg(hw, I82577_CFG_REG, phy_data);
 	if (ret_val)
 		goto out;
 
 	/* Set number of link attempts before downshift */
-	ret_val = phy->ops.read_phy_reg(hw, I82577_CTRL_REG, &phy_data);
+	ret_val = phy->ops.read_reg(hw, I82577_CTRL_REG, &phy_data);
 	if (ret_val)
 		goto out;
 	phy_data &= ~I82577_CTRL_DOWNSHIFT_MASK;
-	ret_val = phy->ops.write_phy_reg(hw, I82577_CTRL_REG, phy_data);
+	ret_val = phy->ops.write_reg(hw, I82577_CTRL_REG, phy_data);
 
 out:
 	return ret_val;
@@ -791,7 +791,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	}
 
 	if (phy->type == e1000_phy_82578) {
-		ret_val = phy->ops.read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+		ret_val = phy->ops.read_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
 		                            &phy_data);
 		if (ret_val)
 			return ret_val;
@@ -799,7 +799,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		/* 82578 PHY - set the downshift count to 1x. */
 		phy_data |= I82578_EPSCR_DOWNSHIFT_ENABLE;
 		phy_data &= ~I82578_EPSCR_DOWNSHIFT_COUNTER_MASK;
-		ret_val = phy->ops.write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+		ret_val = phy->ops.write_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
 		                             phy_data);
 		if (ret_val)
 			return ret_val;
@@ -1990,7 +1990,7 @@ s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 	if (ret_val)
 		return 0;
 
-	ret_val = phy->ops.acquire_phy(hw);
+	ret_val = phy->ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -2005,7 +2005,7 @@ s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 
 	udelay(150);
 
-	phy->ops.release_phy(hw);
+	phy->ops.release(hw);
 
 	return e1000_get_phy_cfg_done(hw);
 }
@@ -2256,7 +2256,7 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 	u32 page = offset >> IGP_PAGE_SHIFT;
 	u32 page_shift = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -2294,7 +2294,7 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 	                                    data);
 
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 	return ret_val;
 }
 
@@ -2315,7 +2315,7 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 	u32 page = offset >> IGP_PAGE_SHIFT;
 	u32 page_shift = 0;
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -2352,7 +2352,7 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 	                                   data);
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 	return ret_val;
 }
 
@@ -2371,7 +2371,7 @@ s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data)
 	s32 ret_val;
 	u16 page = (u16)(offset >> IGP_PAGE_SHIFT);
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -2397,7 +2397,7 @@ s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data)
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					   data);
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 	return ret_val;
 }
 
@@ -2415,7 +2415,7 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
 	s32 ret_val;
 	u16 page = (u16)(offset >> IGP_PAGE_SHIFT);
 
-	ret_val = hw->phy.ops.acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		return ret_val;
 
@@ -2441,7 +2441,7 @@ s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data)
 					    data);
 
 out:
-	hw->phy.ops.release_phy(hw);
+	hw->phy.ops.release(hw);
 	return ret_val;
 }
 
@@ -2544,8 +2544,8 @@ out:
  **/
 s32 e1000e_commit_phy(struct e1000_hw *hw)
 {
-	if (hw->phy.ops.commit_phy)
-		return hw->phy.ops.commit_phy(hw);
+	if (hw->phy.ops.commit)
+		return hw->phy.ops.commit(hw);
 
 	return 0;
 }
@@ -2624,7 +2624,7 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 	bool in_slow_mode = false;
 
 	if (!locked) {
-		ret_val = hw->phy.ops.acquire_phy(hw);
+		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return ret_val;
 	}
@@ -2681,7 +2681,7 @@ out:
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
 
 	if (!locked)
-		hw->phy.ops.release_phy(hw);
+		hw->phy.ops.release(hw);
 
 	return ret_val;
 }
@@ -2734,7 +2734,7 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	bool in_slow_mode = false;
 
 	if (!locked) {
-		ret_val = hw->phy.ops.acquire_phy(hw);
+		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return ret_val;
 	}
@@ -2808,7 +2808,7 @@ out:
 		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
 
 	if (!locked)
-		hw->phy.ops.release_phy(hw);
+		hw->phy.ops.release(hw);
 
 	return ret_val;
 }
@@ -2923,12 +2923,12 @@ s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
 		goto out;
 
 	/* Do not apply workaround if in PHY loopback bit 14 set */
-	hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &data);
+	hw->phy.ops.read_reg(hw, PHY_CONTROL, &data);
 	if (data & PHY_CONTROL_LB)
 		goto out;
 
 	/* check if link is up and at 1Gbps */
-	ret_val = hw->phy.ops.read_phy_reg(hw, BM_CS_STATUS, &data);
+	ret_val = hw->phy.ops.read_reg(hw, BM_CS_STATUS, &data);
 	if (ret_val)
 		goto out;
 
@@ -2944,13 +2944,13 @@ s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
 	mdelay(200);
 
 	/* flush the packets in the fifo buffer */
-	ret_val = hw->phy.ops.write_phy_reg(hw, HV_MUX_DATA_CTRL,
+	ret_val = hw->phy.ops.write_reg(hw, HV_MUX_DATA_CTRL,
 	                                HV_MUX_DATA_CTRL_GEN_TO_MAC |
 	                                HV_MUX_DATA_CTRL_FORCE_SPEED);
 	if (ret_val)
 		goto out;
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, HV_MUX_DATA_CTRL,
+	ret_val = hw->phy.ops.write_reg(hw, HV_MUX_DATA_CTRL,
 	                                HV_MUX_DATA_CTRL_GEN_TO_MAC);
 
 out:
@@ -2971,7 +2971,7 @@ s32 e1000_check_polarity_82577(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_STATUS_2, &data);
+	ret_val = phy->ops.read_reg(hw, I82577_PHY_STATUS_2, &data);
 
 	if (!ret_val)
 		phy->cable_polarity = (data & I82577_PHY_STATUS2_REV_POLARITY)
@@ -2996,13 +2996,13 @@ s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	ret_val = phy->ops.read_phy_reg(hw, PHY_CONTROL, &phy_data);
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
 		goto out;
 
 	e1000e_phy_force_speed_duplex_setup(hw, &phy_data);
 
-	ret_val = phy->ops.write_phy_reg(hw, PHY_CONTROL, phy_data);
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -3010,14 +3010,14 @@ s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
 	 * Clear Auto-Crossover to force MDI manually.  82577 requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
-	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_CTRL_2, &phy_data);
+	ret_val = phy->ops.read_reg(hw, I82577_PHY_CTRL_2, &phy_data);
 	if (ret_val)
 		goto out;
 
 	phy_data &= ~I82577_PHY_CTRL2_AUTO_MDIX;
 	phy_data &= ~I82577_PHY_CTRL2_FORCE_MDI_MDIX;
 
-	ret_val = phy->ops.write_phy_reg(hw, I82577_PHY_CTRL_2, phy_data);
+	ret_val = phy->ops.write_reg(hw, I82577_PHY_CTRL_2, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -3083,7 +3083,7 @@ s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_STATUS_2, &data);
+	ret_val = phy->ops.read_reg(hw, I82577_PHY_STATUS_2, &data);
 	if (ret_val)
 		goto out;
 
@@ -3095,7 +3095,7 @@ s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
 		if (ret_val)
 			goto out;
 
-		ret_val = phy->ops.read_phy_reg(hw, PHY_1000T_STATUS, &data);
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_STATUS, &data);
 		if (ret_val)
 			goto out;
 
@@ -3129,7 +3129,7 @@ s32 e1000_get_cable_length_82577(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data, length;
 
-	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_DIAG_STATUS, &phy_data);
+	ret_val = phy->ops.read_reg(hw, I82577_PHY_DIAG_STATUS, &phy_data);
 	if (ret_val)
 		goto out;
 

