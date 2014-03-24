From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 7/7] rtlwifi: Remove casts of pointer to same type
Date: Mon, 24 Mar 2014 13:15:40 -0700
Message-ID: <a7751e9c8d815a5d68614b4e662f3f1bba6d45c2.1395692043.git.joe@perches.com>
References: <cover.1395692043.git.joe@perches.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casting a pointer to a pointer of the same type is pointless,
so remove these unnecessary casts.

Around these changes:

o Remove unnecessary parentheses
o Use consistent dereference style (change ptr[0] to *ptr)
o Argument alignment

Done via coccinelle script: (and some typing)

$ cat typecast_2.cocci
@@
type T;
T *foo;
@@

-	(T *)foo
+	foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/core.c                |  2 +-
 drivers/net/wireless/rtlwifi/ps.c                  | 19 ++++---
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |  5 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  4 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 57 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        | 14 ++---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        | 14 +++--
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 60 ++++++++++------------
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  4 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |  2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 57 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  4 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |  4 +-
 15 files changed, 118 insertions(+), 137 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index ded691f..4ec424f 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -982,7 +982,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				u8 keep_alive = 10;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						 HW_VAR_KEEP_ALIVE,
-						 (u8 *)(&keep_alive));
+						 &keep_alive);
 
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						      HW_VAR_H2C_FW_JOINBSSRPT,
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index de7f05f..5050494 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -759,7 +759,7 @@ static void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data,
 			   unsigned int len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct ieee80211_mgmt *mgmt = (void *)data;
+	struct ieee80211_mgmt *mgmt = data;
 	struct rtl_p2p_ps_info *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
 	u8 *pos, *end, *ie;
 	u16 noa_len;
@@ -858,7 +858,7 @@ static void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data,
 			      unsigned int len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct ieee80211_mgmt *mgmt = (void *)data;
+	struct ieee80211_mgmt *mgmt = data;
 	struct rtl_p2p_ps_info *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
 	u8 noa_num, index, i, noa_index = 0;
 	u8 *pos, *end, *ie;
@@ -950,9 +950,8 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		p2pinfo->p2p_ps_state = p2p_ps_state;
-		rtlpriv->cfg->ops->set_hw_reg(hw,
-				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
-				 (u8 *)(&p2p_ps_state));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+					      &p2p_ps_state);
 
 		p2pinfo->noa_index = 0;
 		p2pinfo->ctwindow = 0;
@@ -964,7 +963,7 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 				rtlps->smart_ps = 2;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 					 HW_VAR_H2C_FW_PWRMODE,
-					 (u8 *)(&rtlps->pwr_mode));
+					 &rtlps->pwr_mode);
 			}
 		}
 		break;
@@ -977,12 +976,12 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 					rtlps->smart_ps = 0;
 					rtlpriv->cfg->ops->set_hw_reg(hw,
 						 HW_VAR_H2C_FW_PWRMODE,
-						 (u8 *)(&rtlps->pwr_mode));
+						 &rtlps->pwr_mode);
 				}
 			}
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
-				 (u8 *)(&p2p_ps_state));
+				 &p2p_ps_state);
 		}
 		break;
 	case P2P_PS_SCAN:
@@ -992,7 +991,7 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 			p2pinfo->p2p_ps_state = p2p_ps_state;
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
-				 (u8 *)(&p2p_ps_state));
+				 &p2p_ps_state);
 		}
 		break;
 	default:
@@ -1012,7 +1011,7 @@ void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct ieee80211_hdr *hdr = (void *)data;
+	struct ieee80211_hdr *hdr = data;
 
 	if (!mac->p2p)
 		return;
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
index 97bc9aa..f8daa61 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
@@ -851,9 +851,8 @@ static void rtl88e_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	} else {
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_AC_PARAM,
-						      (u8 *)(&tmp));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      &tmp);
 			rtlpriv->dm.current_turbo_edca = false;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
index 557bc5b..4f9376a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
@@ -119,7 +119,7 @@ static void _rtl88e_write_fw(struct ieee80211_hw *hw,
 			     enum version_8188e version, u8 *buffer, u32 size)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 *buf_ptr = (u8 *)buffer;
+	u8 *buf_ptr = buffer;
 	u32 page_no, remain;
 	u32 page, offset;
 
@@ -213,7 +213,7 @@ int rtl88e_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_wlan_fw)
 		return 1;
 
 	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
-	pfwdata = (u8 *)rtlhal->pfirmware;
+	pfwdata = rtlhal->pfirmware;
 	fwsize = rtlhal->fwsize;
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
 		 "normal Firmware SIZE %d\n", fwsize);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index 5a30e4e..94cd9df 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -147,8 +147,7 @@ static void _rtl88ee_set_fw_clock_on(struct ieee80211_hw *hw,
 	}
 
 	if (IS_IN_LOW_POWER_STATE_88E(rtlhal->fw_ps_state)) {
-		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_SET_RPWM,
-					      (u8 *)(&rpwm_val));
+		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
 		if (FW_PS_IS_ACK(rpwm_val)) {
 			isr_regaddr = REG_HISR;
 			content = rtl_read_dword(rtlpriv, isr_regaddr);
@@ -225,7 +224,7 @@ static void _rtl88ee_set_fw_clock_off(struct ieee80211_hw *hw,
 			rtlhal->fw_ps_state = FW_PS_STATE(rpwm_val);
 			rtl_write_word(rtlpriv, REG_HISR, 0x0100);
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-						      (u8 *)(&rpwm_val));
+						      &rpwm_val);
 			spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 			rtlhal->fw_clk_change_in_progress = false;
 			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
@@ -273,15 +272,14 @@ static void _rtl88ee_fwlps_leave(struct ieee80211_hw *hw)
 		_rtl88ee_set_fw_clock_on(hw, rpwm_val, false);
 		rtlhal->allow_sw_to_change_hwclc = false;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&fw_pwrmode));
+					      &fw_pwrmode);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 	} else {
 		rpwm_val = FW_PS_STATE_ALL_ON_88E;	/* RF on */
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					      (u8 *)(&rpwm_val));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&fw_pwrmode));
+					      &fw_pwrmode);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 	}
@@ -300,7 +298,7 @@ static void _rtl88ee_fwlps_enter(struct ieee80211_hw *hw)
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&ppsc->fwctrl_psmode));
+					      &ppsc->fwctrl_psmode);
 		rtlhal->allow_sw_to_change_hwclc = true;
 		_rtl88ee_set_fw_clock_off(hw, rpwm_val);
 	} else {
@@ -308,9 +306,8 @@ static void _rtl88ee_fwlps_enter(struct ieee80211_hw *hw)
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&ppsc->fwctrl_psmode));
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					      (u8 *)(&rpwm_val));
+					      &ppsc->fwctrl_psmode);
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
 	}
 }
 
@@ -419,12 +416,12 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      (u8 *)(&e_aci));
+						      &e_aci);
 		}
 		break; }
 	case HW_VAR_ACK_PREAMBLE:{
 		u8 reg_tmp;
-		u8 short_preamble = (bool) (*(u8 *)val);
+		u8 short_preamble = (bool)*val;
 		reg_tmp = rtl_read_byte(rtlpriv, REG_TRXPTCL_CTL+2);
 		if (short_preamble) {
 			reg_tmp |= 0x02;
@@ -435,13 +432,13 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break; }
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *)val));
+		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
 		break;
 	case HW_VAR_AMPDU_MIN_SPACE:{
 		u8 min_spacing_to_set;
 		u8 sec_min_space;
 
-		min_spacing_to_set = *((u8 *)val);
+		min_spacing_to_set = *val;
 		if (min_spacing_to_set <= 7) {
 			sec_min_space = 0;
 
@@ -464,7 +461,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY:{
 		u8 density_to_set;
 
-		density_to_set = *((u8 *)val);
+		density_to_set = *val;
 		mac->min_space_cfg |= (density_to_set << 3);
 
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -482,7 +479,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		reg = regtoset_normal;
 
-		factor = *((u8 *)val);
+		factor = *val;
 		if (factor <= 3) {
 			factor = (1 << (factor + 2));
 			if (factor > 0xf)
@@ -505,15 +502,15 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break; }
 	case HW_VAR_AC_PARAM:{
-		u8 e_aci = *((u8 *)val);
+		u8 e_aci = *val;
 		rtl88e_dm_init_edca_turbo(hw);
 
 		if (rtlpci->acm_method != EACMWAY2_SW)
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
-						      (u8 *)(&e_aci));
+						      &e_aci);
 		break; }
 	case HW_VAR_ACM_CTRL:{
-		u8 e_aci = *((u8 *)val);
+		u8 e_aci = *val;
 		union aci_aifsn *p_aci_aifsn =
 		    (union aci_aifsn *)(&(mac->ac[0].aifs));
 		u8 acm = p_aci_aifsn->f.acm;
@@ -566,7 +563,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlpci->receive_config = ((u32 *)(val))[0];
 		break;
 	case HW_VAR_RETRY_LIMIT:{
-		u8 retry_limit = ((u8 *)(val))[0];
+		u8 retry_limit = *val;
 
 		rtl_write_word(rtlpriv, REG_RL,
 			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -579,7 +576,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *)val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *((u8 *)val);
+		rtlefuse->efuse_usedpercentage = *val;
 		break;
 	case HW_VAR_IO_CMD:
 		rtl88e_phy_set_io_cmd(hw, (*(enum io_type *)val));
@@ -591,15 +588,13 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		udelay(1);
 
 		if (rpwm_val & BIT(7)) {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-				       (*(u8 *)val));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val);
 		} else {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-				       ((*(u8 *)val) | BIT(7)));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val | BIT(7));
 		}
 		break; }
 	case HW_VAR_H2C_FW_PWRMODE:
-		rtl88e_set_fw_pwrmode_cmd(hw, (*(u8 *)val));
+		rtl88e_set_fw_pwrmode_cmd(hw, *val);
 		break;
 	case HW_VAR_FW_PSMODE_STATUS:
 		ppsc->fw_current_inpsmode = *((bool *)val);
@@ -616,7 +611,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			_rtl88ee_fwlps_leave(hw);
 		 break; }
 	case HW_VAR_H2C_FW_JOINBSSRPT:{
-		u8 mstatus = (*(u8 *)val);
+		u8 mstatus = *val;
 		u8 tmp, tmp_reg422, uval;
 		u8 count = 0, dlbcn_count = 0;
 		bool recover = false;
@@ -667,10 +662,10 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			}
 			rtl_write_byte(rtlpriv, REG_CR + 1, (tmp & ~(BIT(0))));
 		}
-		rtl88e_set_fw_joinbss_report_cmd(hw, (*(u8 *)val));
+		rtl88e_set_fw_joinbss_report_cmd(hw, *val);
 		break; }
 	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
-		rtl88e_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		rtl88e_set_p2p_ps_offload_cmd(hw, *val);
 		break;
 	case HW_VAR_AID:{
 		u16 u2btmp;
@@ -680,7 +675,7 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			       mac->assoc_id));
 		break; }
 	case HW_VAR_CORRECT_TSF:{
-		u8 btype_ibss = ((u8 *)(val))[0];
+		u8 btype_ibss = *val;
 
 		if (btype_ibss == true)
 			_rtl88ee_stop_tx_beacon(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index 2ba6f51..06ef47c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -497,7 +497,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	u8 *pdesc = (u8 *)pdesc_tx;
+	u8 *pdesc = pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	unsigned int buf_len = 0;
@@ -716,7 +716,7 @@ void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	SET_TX_DESC_OWN(pdesc, 1);
 
-	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
+	SET_TX_DESC_PKT_SIZE(pdesc, (u16)(skb->len));
 
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 4ae51d5..55adf04 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -476,7 +476,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
-		rtl92c_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		rtl92c_set_p2p_ps_offload_cmd(hw, *val);
 		break;
 	case HW_VAR_AID:{
 			u16 u2btmp;
@@ -521,21 +521,21 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 						(u8 *)(&fw_current_inps));
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						HW_VAR_H2C_FW_PWRMODE,
-						(u8 *)(&ppsc->fwctrl_psmode));
+						&ppsc->fwctrl_psmode);
 
 				rtlpriv->cfg->ops->set_hw_reg(hw,
-						HW_VAR_SET_RPWM,
-						(u8 *)(&rpwm_val));
+							      HW_VAR_SET_RPWM,
+							      &rpwm_val);
 			} else {
 				rpwm_val = 0x0C;	/* RF on */
 				fw_pwrmode = FW_PS_ACTIVE_MODE;
 				fw_current_inps = false;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
-						HW_VAR_SET_RPWM,
-						(u8 *)(&rpwm_val));
+							      HW_VAR_SET_RPWM,
+							      &rpwm_val);
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						HW_VAR_H2C_FW_PWRMODE,
-						(u8 *)(&fw_pwrmode));
+						&fw_pwrmode);
 
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						HW_VAR_FW_PSMODE_STATUS,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 3015af1..9098558 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -413,20 +413,18 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					(u8 *)(&fw_current_inps));
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 					HW_VAR_H2C_FW_PWRMODE,
-					(u8 *)(&ppsc->fwctrl_psmode));
+					&ppsc->fwctrl_psmode);
 
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_SET_RPWM,
-					(u8 *)(&rpwm_val));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+						      &rpwm_val);
 		} else {
 			rpwm_val = 0x0C;	/* RF on */
 			fw_pwrmode = FW_PS_ACTIVE_MODE;
 			fw_current_inps = false;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					(u8 *)(&rpwm_val));
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_H2C_FW_PWRMODE,
-					(u8 *)(&fw_pwrmode));
+						      &rpwm_val);
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+						      &fw_pwrmode);
 
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 					HW_VAR_FW_PSMODE_STATUS,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index 863ddb3..25cc830 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -647,9 +647,8 @@ static void rtl8723ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	} else {
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_AC_PARAM,
-						      (u8 *) (&tmp));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      &tmp);
 			rtlpriv->dm.current_turbo_edca = false;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index dd383b1..65c9e80 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -207,14 +207,13 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
 
 		for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_AC_PARAM,
-						      (u8 *) (&e_aci));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      &e_aci);
 		}
 		break; }
 	case HW_VAR_ACK_PREAMBLE:{
 		u8 reg_tmp;
-		u8 short_preamble = (bool) (*(u8 *) val);
+		u8 short_preamble = (bool)*val;
 		reg_tmp = (mac->cur_40_prime_sc) << 5;
 		if (short_preamble)
 			reg_tmp |= 0x80;
@@ -225,7 +224,7 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		u8 min_spacing_to_set;
 		u8 sec_min_space;
 
-		min_spacing_to_set = *((u8 *) val);
+		min_spacing_to_set = *val;
 		if (min_spacing_to_set <= 7) {
 			sec_min_space = 0;
 
@@ -249,7 +248,7 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY:{
 		u8 density_to_set;
 
-		density_to_set = *((u8 *) val);
+		density_to_set = *val;
 		mac->min_space_cfg |= (density_to_set << 3);
 
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -273,7 +272,7 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		else
 			p_regtoset = regtoset_normal;
 
-		factor_toset = *((u8 *) val);
+		factor_toset = *val;
 		if (factor_toset <= 3) {
 			factor_toset = (1 << (factor_toset + 2));
 			if (factor_toset > 0xf)
@@ -304,16 +303,15 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break; }
 	case HW_VAR_AC_PARAM:{
-		u8 e_aci = *((u8 *) val);
+		u8 e_aci = *val;
 		rtl8723_dm_init_edca_turbo(hw);
 
 		if (rtlpci->acm_method != EACMWAY2_SW)
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_ACM_CTRL,
-						      (u8 *) (&e_aci));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
+						      &e_aci);
 		break; }
 	case HW_VAR_ACM_CTRL:{
-		u8 e_aci = *((u8 *) val);
+		u8 e_aci = *val;
 		union aci_aifsn *p_aci_aifsn =
 		    (union aci_aifsn *)(&(mac->ac[0].aifs));
 		u8 acm = p_aci_aifsn->f.acm;
@@ -366,7 +364,7 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlpci->receive_config = ((u32 *) (val))[0];
 		break;
 	case HW_VAR_RETRY_LIMIT:{
-		u8 retry_limit = ((u8 *) (val))[0];
+		u8 retry_limit = *val;
 
 		rtl_write_word(rtlpriv, REG_RL,
 			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -379,13 +377,13 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *) val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *((u8 *) val);
+		rtlefuse->efuse_usedpercentage = *val;
 		break;
 	case HW_VAR_IO_CMD:
 		rtl8723ae_phy_set_io_cmd(hw, (*(enum io_type *)val));
 		break;
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *) val));
+		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
 		break;
 	case HW_VAR_SET_RPWM:{
 		u8 rpwm_val;
@@ -394,27 +392,25 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		udelay(1);
 
 		if (rpwm_val & BIT(7)) {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-				       (*(u8 *) val));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val);
 		} else {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-				       ((*(u8 *) val) | BIT(7)));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val | BIT(7));
 		}
 
 		break; }
 	case HW_VAR_H2C_FW_PWRMODE:{
-		u8 psmode = (*(u8 *) val);
+		u8 psmode = *val;
 
 		if (psmode != FW_PS_ACTIVE_MODE)
 			rtl8723ae_dm_rf_saving(hw, true);
 
-		rtl8723ae_set_fw_pwrmode_cmd(hw, (*(u8 *) val));
+		rtl8723ae_set_fw_pwrmode_cmd(hw, *val);
 		break; }
 	case HW_VAR_FW_PSMODE_STATUS:
 		ppsc->fw_current_inpsmode = *((bool *) val);
 		break;
 	case HW_VAR_H2C_FW_JOINBSSRPT:{
-		u8 mstatus = (*(u8 *) val);
+		u8 mstatus = *val;
 		u8 tmp_regcr, tmp_reg422;
 		bool recover = false;
 
@@ -447,11 +443,11 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_byte(rtlpriv, REG_CR + 1,
 				       (tmp_regcr & ~(BIT(0))));
 		}
-		rtl8723ae_set_fw_joinbss_report_cmd(hw, (*(u8 *) val));
+		rtl8723ae_set_fw_joinbss_report_cmd(hw, *val);
 
 		break; }
 	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
-		rtl8723ae_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		rtl8723ae_set_p2p_ps_offload_cmd(hw, *val);
 		break;
 	case HW_VAR_AID:{
 		u16 u2btmp;
@@ -461,7 +457,7 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				mac->assoc_id));
 		break; }
 	case HW_VAR_CORRECT_TSF:{
-		u8 btype_ibss = ((u8 *) (val))[0];
+		u8 btype_ibss = *val;
 
 		if (btype_ibss == true)
 			_rtl8723ae_stop_tx_beacon(hw);
@@ -491,20 +487,18 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					(u8 *)(&fw_current_inps));
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 					HW_VAR_H2C_FW_PWRMODE,
-					(u8 *)(&ppsc->fwctrl_psmode));
+					&ppsc->fwctrl_psmode);
 
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_SET_RPWM,
-					(u8 *)(&rpwm_val));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+						      &rpwm_val);
 		} else {
 			rpwm_val = 0x0C;	/* RF on */
 			fw_pwrmode = FW_PS_ACTIVE_MODE;
 			fw_current_inps = false;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					(u8 *)(&rpwm_val));
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_H2C_FW_PWRMODE,
-					(u8 *)(&fw_pwrmode));
+						      &rpwm_val);
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+						      &fw_pwrmode);
 
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 					HW_VAR_FW_PSMODE_STATUS,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index 29adf55..10b7577 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -375,7 +375,7 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	bool defaultadapter = true;
-	u8 *pdesc = (u8 *) pdesc_tx;
+	u8 *pdesc = pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	u8 fw_qsel = _rtl8723ae_map_hwqueue_to_fwqueue(skb, hw_queue);
@@ -577,7 +577,7 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	SET_TX_DESC_OWN(pdesc, 1);
 
-	SET_TX_DESC_PKT_SIZE((u8 *) pdesc, (u16) (skb->len));
+	SET_TX_DESC_PKT_SIZE(pdesc, (u16) (skb->len));
 
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
index 736bfcb..13d53a1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
@@ -1083,7 +1083,7 @@ static void rtl8723be_dm_check_edca_turbo(struct ieee80211_hw *hw)
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      (u8 *)(&tmp));
+						      &tmp);
 		}
 		rtlpriv->dm.current_turbo_edca = false;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index 223728d..0fdf090 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -147,7 +147,7 @@ static void _rtl8723be_set_fw_clock_on(struct ieee80211_hw *hw, u8 rpwm_val,
 	}
 	if (IS_IN_LOW_POWER_STATE_88E(rtlhal->fw_ps_state)) {
 		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_SET_RPWM,
-					      (u8 *)(&rpwm_val));
+					      &rpwm_val);
 		if (FW_PS_IS_ACK(rpwm_val)) {
 			isr_regaddr = REG_HISR;
 			content = rtl_read_dword(rtlpriv, isr_regaddr);
@@ -221,7 +221,7 @@ static void _rtl8723be_set_fw_clock_off(struct ieee80211_hw *hw, u8 rpwm_val)
 			rtlhal->fw_ps_state = FW_PS_STATE(rpwm_val);
 			rtl_write_word(rtlpriv, REG_HISR, 0x0100);
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-						      (u8 *)(&rpwm_val));
+						      &rpwm_val);
 			spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 			rtlhal->fw_clk_change_in_progress = false;
 			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
@@ -253,15 +253,14 @@ static void _rtl8723be_fwlps_leave(struct ieee80211_hw *hw)
 		_rtl8723be_set_fw_clock_on(hw, rpwm_val, false);
 		rtlhal->allow_sw_to_change_hwclc = false;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&fw_pwrmode));
+					      &fw_pwrmode);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 	} else {
 		rpwm_val = FW_PS_STATE_ALL_ON_88E;	/* RF on */
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					      (u8 *)(&rpwm_val));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&fw_pwrmode));
+					      &fw_pwrmode);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 	}
@@ -280,7 +279,7 @@ static void _rtl8723be_fwlps_enter(struct ieee80211_hw *hw)
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&ppsc->fwctrl_psmode));
+					      &ppsc->fwctrl_psmode);
 		rtlhal->allow_sw_to_change_hwclc = true;
 		_rtl8723be_set_fw_clock_off(hw, rpwm_val);
 
@@ -289,9 +288,8 @@ static void _rtl8723be_fwlps_enter(struct ieee80211_hw *hw)
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      (u8 *)(&ppsc->fwctrl_psmode));
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					      (u8 *)(&rpwm_val));
+					      &ppsc->fwctrl_psmode);
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
 	}
 }
 
@@ -400,12 +398,12 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      (u8 *)(&e_aci));
+						      &e_aci);
 		}
 		break; }
 	case HW_VAR_ACK_PREAMBLE: {
 		u8 reg_tmp;
-		u8 short_preamble = (bool) (*(u8 *)val);
+		u8 short_preamble = (bool)*val;
 		reg_tmp = rtl_read_byte(rtlpriv, REG_TRXPTCL_CTL + 2);
 		if (short_preamble) {
 			reg_tmp |= 0x02;
@@ -416,13 +414,13 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break; }
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *)val));
+		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
 		break;
 	case HW_VAR_AMPDU_MIN_SPACE: {
 		u8 min_spacing_to_set;
 		u8 sec_min_space;
 
-		min_spacing_to_set = *((u8 *)val);
+		min_spacing_to_set = *val;
 		if (min_spacing_to_set <= 7) {
 			sec_min_space = 0;
 
@@ -445,7 +443,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY: {
 		u8 density_to_set;
 
-		density_to_set = *((u8 *)val);
+		density_to_set = *val;
 		mac->min_space_cfg |= (density_to_set << 3);
 
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -463,7 +461,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		p_regtoset = regtoset_normal;
 
-		factor_toset = *((u8 *)val);
+		factor_toset = *val;
 		if (factor_toset <= 3) {
 			factor_toset = (1 << (factor_toset + 2));
 			if (factor_toset > 0xf)
@@ -491,15 +489,15 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 		break; }
 	case HW_VAR_AC_PARAM: {
-		u8 e_aci = *((u8 *)val);
+		u8 e_aci = *val;
 		rtl8723_dm_init_edca_turbo(hw);
 
 		if (rtlpci->acm_method != EACMWAY2_SW)
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
-						      (u8 *)(&e_aci));
+						      &e_aci);
 		break; }
 	case HW_VAR_ACM_CTRL: {
-		u8 e_aci = *((u8 *)val);
+		u8 e_aci = *val;
 		union aci_aifsn *p_aci_aifsn =
 				(union aci_aifsn *)(&(mac->ac[0].aifs));
 		u8 acm = p_aci_aifsn->f.acm;
@@ -552,7 +550,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlpci->receive_config = ((u32 *)(val))[0];
 		break;
 	case HW_VAR_RETRY_LIMIT: {
-		u8 retry_limit = ((u8 *)(val))[0];
+		u8 retry_limit = *val;
 
 		rtl_write_word(rtlpriv, REG_RL,
 			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -565,7 +563,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *)val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *((u8 *)val);
+		rtlefuse->efuse_usedpercentage = *val;
 		break;
 	case HW_VAR_IO_CMD:
 		rtl8723be_phy_set_io_cmd(hw, (*(enum io_type *)val));
@@ -577,14 +575,13 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		udelay(1);
 
 		if (rpwm_val & BIT(7)) {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, (*(u8 *)val));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val);
 		} else {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-				       ((*(u8 *)val) | BIT(7)));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val | BIT(7));
 		}
 		break; }
 	case HW_VAR_H2C_FW_PWRMODE:
-		rtl8723be_set_fw_pwrmode_cmd(hw, (*(u8 *)val));
+		rtl8723be_set_fw_pwrmode_cmd(hw, *val);
 		break;
 	case HW_VAR_FW_PSMODE_STATUS:
 		ppsc->fw_current_inpsmode = *((bool *)val);
@@ -602,7 +599,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		break; }
 	case HW_VAR_H2C_FW_JOINBSSRPT: {
-		u8 mstatus = (*(u8 *)val);
+		u8 mstatus = *val;
 		u8 tmp_regcr, tmp_reg422, bcnvalid_reg;
 		u8 count = 0, dlbcn_count = 0;
 		bool recover = false;
@@ -657,10 +654,10 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_byte(rtlpriv, REG_CR + 1,
 				       (tmp_regcr & ~(BIT(0))));
 		}
-		rtl8723be_set_fw_joinbss_report_cmd(hw, (*(u8 *)val));
+		rtl8723be_set_fw_joinbss_report_cmd(hw, *val);
 		break; }
 	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
-		rtl8723be_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		rtl8723be_set_p2p_ps_offload_cmd(hw, *val);
 		break;
 	case HW_VAR_AID: {
 		u16 u2btmp;
@@ -670,7 +667,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			       (u2btmp | mac->assoc_id));
 		break; }
 	case HW_VAR_CORRECT_TSF: {
-		u8 btype_ibss = ((u8 *)(val))[0];
+		u8 btype_ibss = *val;
 
 		if (btype_ibss)
 			_rtl8723be_stop_tx_beacon(hw);
@@ -690,7 +687,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_KEEP_ALIVE: {
 		u8 array[2];
 		array[0] = 0xff;
-		array[1] = *((u8 *)val);
+		array[1] = *val;
 		rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_KEEP_ALIVE_CTRL,
 				       2, array);
 		break; }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index 74a75dc..e0a0d8c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -647,7 +647,7 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	u8 *pdesc = (u8 *)pdesc_tx;
+	u8 *pdesc = pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	unsigned int buf_len = 0;
@@ -850,7 +850,7 @@ void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 
 	SET_TX_DESC_OWN(pdesc, 1);
 
-	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
+	SET_TX_DESC_PKT_SIZE(pdesc, (u16)(skb->len));
 
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
index c12da55..540278f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
@@ -115,7 +115,7 @@ void rtl8723_write_fw(struct ieee80211_hw *hw,
 		      u8 *buffer, u32 size)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 *bufferptr = (u8 *)buffer;
+	u8 *bufferptr = buffer;
 	u32 pagenums, remainsize;
 	u32 page, offset;
 
@@ -257,7 +257,7 @@ int rtl8723_download_fw(struct ieee80211_hw *hw,
 		return 1;
 
 	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
-	pfwdata = (u8 *)rtlhal->pfirmware;
+	pfwdata = rtlhal->pfirmware;
 	fwsize = rtlhal->fwsize;
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
 		 "normal Firmware SIZE %d\n", fwsize);
-- 
1.8.1.2.459.gbcd45b4.dirty
