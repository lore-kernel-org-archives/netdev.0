From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/11] rtlwifi: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:29 -0700
Message-ID: <a958df5dc3065ce517726dc54087639e13ffee8f.1380137610.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/cam.h           | 10 ++---
 drivers/net/wireless/rtlwifi/efuse.h         | 29 +++++++------
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h | 49 ++++++++++------------
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h | 54 ++++++++++--------------
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h  | 13 +++---
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h  | 13 +++---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.h  |  7 ++--
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h | 44 +++++++++-----------
 drivers/net/wireless/rtlwifi/rtl8192de/rf.h  | 18 ++++----
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h | 61 +++++++++++++---------------
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h  | 13 +++---
 11 files changed, 141 insertions(+), 170 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/cam.h b/drivers/net/wireless/rtlwifi/cam.h
index 35e0008..0105e6c 100644
--- a/drivers/net/wireless/rtlwifi/cam.h
+++ b/drivers/net/wireless/rtlwifi/cam.h
@@ -41,12 +41,12 @@
 #define	CAM_CONFIG_USEDK				1
 #define	CAM_CONFIG_NO_USEDK				0
 
-extern void rtl_cam_reset_all_entry(struct ieee80211_hw *hw);
-extern u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
-			u32 ul_key_id, u32 ul_entry_idx, u32 ul_enc_alg,
-			u32 ul_default_key, u8 *key_content);
+void rtl_cam_reset_all_entry(struct ieee80211_hw *hw);
+u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
+			 u32 ul_key_id, u32 ul_entry_idx, u32 ul_enc_alg,
+			 u32 ul_default_key, u8 *key_content);
 int rtl_cam_delete_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
-			u32 ul_key_id);
+			     u32 ul_key_id);
 void rtl_cam_mark_invalid(struct ieee80211_hw *hw, u8 uc_index);
 void rtl_cam_empty_entry(struct ieee80211_hw *hw, u8 uc_index);
 void rtl_cam_reset_sec_info(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/efuse.h b/drivers/net/wireless/rtlwifi/efuse.h
index 395a326..1663b3a 100644
--- a/drivers/net/wireless/rtlwifi/efuse.h
+++ b/drivers/net/wireless/rtlwifi/efuse.h
@@ -104,20 +104,19 @@ struct efuse_priv {
 	u8 tx_power_g[14];
 };
 
-extern void read_efuse_byte(struct ieee80211_hw *hw, u16 _offset, u8 *pbuf);
-extern void efuse_initialize(struct ieee80211_hw *hw);
-extern u8 efuse_read_1byte(struct ieee80211_hw *hw, u16 address);
-extern void efuse_write_1byte(struct ieee80211_hw *hw, u16 address, u8 value);
-extern void read_efuse(struct ieee80211_hw *hw, u16 _offset,
-		       u16 _size_byte, u8 *pbuf);
-extern void efuse_shadow_read(struct ieee80211_hw *hw, u8 type,
-			      u16 offset, u32 *value);
-extern void efuse_shadow_write(struct ieee80211_hw *hw, u8 type,
-			       u16 offset, u32 value);
-extern bool efuse_shadow_update(struct ieee80211_hw *hw);
-extern bool efuse_shadow_update_chk(struct ieee80211_hw *hw);
-extern void rtl_efuse_shadow_map_update(struct ieee80211_hw *hw);
-extern void efuse_force_write_vendor_Id(struct ieee80211_hw *hw);
-extern void efuse_re_pg_section(struct ieee80211_hw *hw, u8 section_idx);
+void read_efuse_byte(struct ieee80211_hw *hw, u16 _offset, u8 *pbuf);
+void efuse_initialize(struct ieee80211_hw *hw);
+u8 efuse_read_1byte(struct ieee80211_hw *hw, u16 address);
+void efuse_write_1byte(struct ieee80211_hw *hw, u16 address, u8 value);
+void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf);
+void efuse_shadow_read(struct ieee80211_hw *hw, u8 type, u16 offset,
+		       u32 *value);
+void efuse_shadow_write(struct ieee80211_hw *hw, u8 type, u16 offset,
+			u32 value);
+bool efuse_shadow_update(struct ieee80211_hw *hw);
+bool efuse_shadow_update_chk(struct ieee80211_hw *hw);
+void rtl_efuse_shadow_map_update(struct ieee80211_hw *hw);
+void efuse_force_write_vendor_Id(struct ieee80211_hw *hw);
+void efuse_re_pg_section(struct ieee80211_hw *hw, u8 section_idx);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
index f1acd6d..71ddf4f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
@@ -200,37 +200,32 @@ enum _ANT_DIV_TYPE {
 	CGCS_RX_SW_ANTDIV		= 0x05,
 };
 
-extern u32 rtl88e_phy_query_bb_reg(struct ieee80211_hw *hw,
-				   u32 regaddr, u32 bitmask);
-extern void rtl88e_phy_set_bb_reg(struct ieee80211_hw *hw,
-				  u32 regaddr, u32 bitmask, u32 data);
-extern u32 rtl88e_phy_query_rf_reg(struct ieee80211_hw *hw,
-				   enum radio_path rfpath, u32 regaddr,
-				   u32 bitmask);
-extern void rtl88e_phy_set_rf_reg(struct ieee80211_hw *hw,
-				  enum radio_path rfpath, u32 regaddr,
-				  u32 bitmask, u32 data);
-extern bool rtl88e_phy_mac_config(struct ieee80211_hw *hw);
-extern bool rtl88e_phy_bb_config(struct ieee80211_hw *hw);
-extern bool rtl88e_phy_rf_config(struct ieee80211_hw *hw);
-extern void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
-extern void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw,
-					 long *powerlevel);
-extern void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
-extern void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw,
-					     u8 operation);
-extern void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
-extern void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
-				   enum nl80211_channel_type ch_type);
-extern void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw);
-extern u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw);
-extern void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
+u32 rtl88e_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask);
+void rtl88e_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
+			   u32 data);
+u32 rtl88e_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
+			    u32 regaddr, u32 bitmask);
+void rtl88e_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
+			   u32 regaddr, u32 bitmask, u32 data);
+bool rtl88e_phy_mac_config(struct ieee80211_hw *hw);
+bool rtl88e_phy_bb_config(struct ieee80211_hw *hw);
+bool rtl88e_phy_rf_config(struct ieee80211_hw *hw);
+void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
+void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel);
+void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
+void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
+void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
+			    enum nl80211_channel_type ch_type);
+void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw);
+u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw);
+void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
 void rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw);
 void rtl88e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
 bool rtl88e_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 					  enum radio_path rfpath);
 bool rtl88e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
-extern bool rtl88e_phy_set_rf_power_state(struct ieee80211_hw *hw,
-					  enum rf_pwrstate rfpwr_state);
+bool rtl88e_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				   enum rf_pwrstate rfpwr_state);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
index d5e3b70..f8973e5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
@@ -188,65 +188,55 @@ struct tx_power_struct {
 };
 
 bool rtl92c_phy_bb_config(struct ieee80211_hw *hw);
-u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw,
-				   u32 regaddr, u32 bitmask);
-void rtl92c_phy_set_bb_reg(struct ieee80211_hw *hw,
-				  u32 regaddr, u32 bitmask, u32 data);
-u32 rtl92c_phy_query_rf_reg(struct ieee80211_hw *hw,
-				   enum radio_path rfpath, u32 regaddr,
-				   u32 bitmask);
-extern void rtl92ce_phy_set_rf_reg(struct ieee80211_hw *hw,
-				   enum radio_path rfpath, u32 regaddr,
-				   u32 bitmask, u32 data);
+u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask);
+void rtl92c_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
+			   u32 data);
+u32 rtl92c_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
+			    u32 regaddr, u32 bitmask);
+void rtl92ce_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
+			    u32 regaddr, u32 bitmask, u32 data);
 bool rtl92c_phy_mac_config(struct ieee80211_hw *hw);
 bool rtl92ce_phy_bb_config(struct ieee80211_hw *hw);
 bool rtl92c_phy_rf_config(struct ieee80211_hw *hw);
 bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
-						 enum radio_path rfpath);
+					  enum radio_path rfpath);
 void rtl92c_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
-void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw,
-					 long *powerlevel);
+void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel);
 void rtl92c_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
-bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw,
-					  long power_indbm);
-void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw,
-					     u8 operation);
+bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm);
+void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
-				   enum nl80211_channel_type ch_type);
+			    enum nl80211_channel_type ch_type);
 void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw);
 void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
-void rtl92c_phy_set_beacon_hw_reg(struct ieee80211_hw *hw,
-					 u16 beaconinterval);
+void rtl92c_phy_set_beacon_hw_reg(struct ieee80211_hw *hw, u16 beaconinterval);
 void rtl92c_phy_ap_calibrate(struct ieee80211_hw *hw, char delta);
 void rtl92c_phy_lc_calibrate(struct ieee80211_hw *hw);
 void _rtl92ce_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t);
 void rtl92c_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
 bool rtl92c_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 					  enum radio_path rfpath);
-bool rtl8192_phy_check_is_legal_rfpath(struct ieee80211_hw *hw,
-					      u32 rfpath);
+bool rtl8192_phy_check_is_legal_rfpath(struct ieee80211_hw *hw, u32 rfpath);
 bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
 bool rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
-					  enum rf_pwrstate rfpwr_state);
+				    enum rf_pwrstate rfpwr_state);
 void rtl92ce_phy_set_rf_on(struct ieee80211_hw *hw);
 bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
 void rtl92c_phy_set_io(struct ieee80211_hw *hw);
 void rtl92c_bb_block_on(struct ieee80211_hw *hw);
-u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw,
-				      enum radio_path rfpath, u32 offset);
+u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw, enum radio_path rfpath,
+			       u32 offset);
 u32 _rtl92c_phy_fw_rf_serial_read(struct ieee80211_hw *hw,
-					 enum radio_path rfpath, u32 offset);
+				  enum radio_path rfpath, u32 offset);
 u32 _rtl92c_phy_calculate_bit_shift(u32 bitmask);
 void _rtl92c_phy_rf_serial_write(struct ieee80211_hw *hw,
-					enum radio_path rfpath, u32 offset,
-					u32 data);
+				 enum radio_path rfpath, u32 offset, u32 data);
 void _rtl92c_phy_fw_rf_serial_write(struct ieee80211_hw *hw,
-					   enum radio_path rfpath, u32 offset,
-					   u32 data);
+				    enum radio_path rfpath, u32 offset,
+				    u32 data);
 void _rtl92c_store_pwrIndex_diffrate_offset(struct ieee80211_hw *hw,
-						   u32 regaddr, u32 bitmask,
-						   u32 data);
+					    u32 regaddr, u32 bitmask, u32 data);
 bool _rtl92ce_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
 void _rtl92c_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw);
 bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
index 6c8d56e..d8fe68b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.h
@@ -34,11 +34,10 @@
 #define RF6052_MAX_REG			0x3F
 #define RF6052_MAX_PATH			2
 
-extern void rtl92ce_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
-					     u8 bandwidth);
-extern void rtl92ce_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-					       u8 *ppowerlevel);
-extern void rtl92ce_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-						u8 *ppowerlevel, u8 channel);
-extern bool rtl92ce_phy_rf6052_config(struct ieee80211_hw *hw);
+void rtl92ce_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
+void rtl92ce_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					u8 *ppowerlevel);
+void rtl92ce_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					 u8 *ppowerlevel, u8 channel);
+bool rtl92ce_phy_rf6052_config(struct ieee80211_hw *hw);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
index 090fd33..11b439d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.h
@@ -34,15 +34,14 @@
 #define RF6052_MAX_REG			0x3F
 #define RF6052_MAX_PATH			2
 
-extern void rtl92cu_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
-					    u8 bandwidth);
-extern void rtl92c_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-					      u8 *ppowerlevel);
-extern void rtl92c_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-					       u8 *ppowerlevel, u8 channel);
+void rtl92cu_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
+void rtl92c_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+				       u8 *ppowerlevel);
+void rtl92c_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					u8 *ppowerlevel, u8 channel);
 bool rtl92cu_phy_rf6052_config(struct ieee80211_hw *hw);
 bool rtl92cu_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
-					  enum radio_path rfpath);
+					   enum radio_path rfpath);
 void rtl92cu_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 					u8 *ppowerlevel);
 void rtl92cu_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.h b/drivers/net/wireless/rtlwifi/rtl8192de/hw.h
index 7c9f7a2..1bc7b1a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.h
@@ -55,10 +55,9 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 		     u8 *p_macaddr, bool is_group, u8 enc_algo,
 		     bool is_wepkey, bool clear_all);
 
-extern void rtl92de_write_dword_dbi(struct ieee80211_hw *hw, u16 offset,
-				    u32 value, u8 direct);
-extern u32 rtl92de_read_dword_dbi(struct ieee80211_hw *hw, u16 offset,
-				  u8 direct);
+void rtl92de_write_dword_dbi(struct ieee80211_hw *hw, u16 offset, u32 value,
+			     u8 direct);
+u32 rtl92de_read_dword_dbi(struct ieee80211_hw *hw, u16 offset, u8 direct);
 void rtl92de_suspend(struct ieee80211_hw *hw);
 void rtl92de_resume(struct ieee80211_hw *hw);
 void rtl92d_linked_set_reg(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.h b/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
index f074952..0f993f4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
@@ -127,34 +127,30 @@ static inline void rtl92d_release_cckandrw_pagea_ctl(struct ieee80211_hw *hw,
 			*flag);
 }
 
-extern u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw,
-				   u32 regaddr, u32 bitmask);
-extern void rtl92d_phy_set_bb_reg(struct ieee80211_hw *hw,
-				  u32 regaddr, u32 bitmask, u32 data);
-extern u32 rtl92d_phy_query_rf_reg(struct ieee80211_hw *hw,
-				   enum radio_path rfpath, u32 regaddr,
-				   u32 bitmask);
-extern void rtl92d_phy_set_rf_reg(struct ieee80211_hw *hw,
-				  enum radio_path rfpath, u32 regaddr,
-				  u32 bitmask, u32 data);
-extern bool rtl92d_phy_mac_config(struct ieee80211_hw *hw);
-extern bool rtl92d_phy_bb_config(struct ieee80211_hw *hw);
-extern bool rtl92d_phy_rf_config(struct ieee80211_hw *hw);
-extern bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
-						 enum radio_path rfpath);
-extern void rtl92d_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
-extern void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
-extern void rtl92d_phy_scan_operation_backup(struct ieee80211_hw *hw,
-					     u8 operation);
-extern void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
-				   enum nl80211_channel_type ch_type);
-extern u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw);
+u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask);
+void rtl92d_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
+			   u32 data);
+u32 rtl92d_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
+			    u32 regaddr, u32 bitmask);
+void rtl92d_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
+			   u32 regaddr, u32 bitmask, u32 data);
+bool rtl92d_phy_mac_config(struct ieee80211_hw *hw);
+bool rtl92d_phy_bb_config(struct ieee80211_hw *hw);
+bool rtl92d_phy_rf_config(struct ieee80211_hw *hw);
+bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
+					  enum radio_path rfpath);
+void rtl92d_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
+void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
+void rtl92d_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
+void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
+			    enum nl80211_channel_type ch_type);
+u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw);
 bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 					  enum rf_content content,
 					  enum radio_path rfpath);
 bool rtl92d_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
-extern bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
-					  enum rf_pwrstate rfpwr_state);
+bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				   enum rf_pwrstate rfpwr_state);
 
 void rtl92d_phy_config_macphymode(struct ieee80211_hw *hw);
 void rtl92d_phy_config_macphymode_info(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/rf.h b/drivers/net/wireless/rtlwifi/rtl8192de/rf.h
index 0fe1a48..7303d12 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/rf.h
@@ -30,15 +30,13 @@
 #ifndef __RTL92D_RF_H__
 #define __RTL92D_RF_H__
 
-extern void rtl92d_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
-					    u8 bandwidth);
-extern void rtl92d_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-					      u8 *ppowerlevel);
-extern void rtl92d_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-					       u8 *ppowerlevel, u8 channel);
-extern bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw);
-extern bool rtl92d_phy_enable_anotherphy(struct ieee80211_hw *hw, bool bmac0);
-extern void rtl92d_phy_powerdown_anotherphy(struct ieee80211_hw *hw,
-					    bool bmac0);
+void rtl92d_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
+void rtl92d_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+				       u8 *ppowerlevel);
+void rtl92d_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					u8 *ppowerlevel, u8 channel);
+bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw);
+bool rtl92d_phy_enable_anotherphy(struct ieee80211_hw *hw, bool bmac0);
+void rtl92d_phy_powerdown_anotherphy(struct ieee80211_hw *hw, bool bmac0);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
index e7a59eb..bbb950d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
@@ -183,42 +183,39 @@ struct tx_power_struct {
 	u32 mcs_original_offset[4][16];
 };
 
-extern u32 rtl8723ae_phy_query_bb_reg(struct ieee80211_hw *hw,
-				      u32 regaddr, u32 bitmask);
-extern void rtl8723ae_phy_set_bb_reg(struct ieee80211_hw *hw,
-				     u32 regaddr, u32 bitmask, u32 data);
-extern u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
-				      enum radio_path rfpath, u32 regaddr,
-				      u32 bitmask);
-extern void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
-				     enum radio_path rfpath, u32 regaddr,
-				     u32 bitmask, u32 data);
-extern bool rtl8723ae_phy_mac_config(struct ieee80211_hw *hw);
-extern bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw);
-extern bool rtl8723ae_phy_rf_config(struct ieee80211_hw *hw);
-extern bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
-						 enum radio_path rfpath);
-extern void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
-extern void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw,
-					    long *powerlevel);
-extern void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw,
-					    u8 channel);
-extern bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw,
-					     long power_indbm);
-extern void rtl8723ae_phy_scan_operation_backup(struct ieee80211_hw *hw,
-						u8 operation);
-extern void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
-extern void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
-				      enum nl80211_channel_type ch_type);
-extern void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw);
-extern u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw);
-extern void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery);
+u32 rtl8723ae_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
+			       u32 bitmask);
+void rtl8723ae_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
+			      u32 data);
+u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
+			       enum radio_path rfpath, u32 regaddr,
+			       u32 bitmask);
+void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
+			      enum radio_path rfpath, u32 regaddr, u32 bitmask,
+			      u32 data);
+bool rtl8723ae_phy_mac_config(struct ieee80211_hw *hw);
+bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw);
+bool rtl8723ae_phy_rf_config(struct ieee80211_hw *hw);
+bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
+					  enum radio_path rfpath);
+void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
+void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel);
+void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
+bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw,
+				      long power_indbm);
+void rtl8723ae_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
+void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
+			       enum nl80211_channel_type ch_type);
+void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw);
+u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw);
+void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery);
 void rtl8723ae_phy_lc_calibrate(struct ieee80211_hw *hw);
 void rtl8723ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
 bool rtl8723ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 					     enum radio_path rfpath);
 bool rtl8723ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
-extern bool rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
-					     enum rf_pwrstate rfpwr_state);
+bool rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				      enum rf_pwrstate rfpwr_state);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
index d0f9dd7..57f1933 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
@@ -32,12 +32,11 @@
 
 #define RF6052_MAX_TX_PWR		0x3F
 
-extern void rtl8723ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
-					    u8 bandwidth);
-extern void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-					      u8 *ppowerlevel);
-extern void rtl8723ae_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-					       u8 *ppowerlevel, u8 channel);
-extern bool rtl8723ae_phy_rf6052_config(struct ieee80211_hw *hw);
+void rtl8723ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
+void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel);
+void rtl8723ae_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					   u8 *ppowerlevel, u8 channel);
+bool rtl8723ae_phy_rf6052_config(struct ieee80211_hw *hw);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
