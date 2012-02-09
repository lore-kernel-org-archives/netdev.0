From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] drivers/net: Remove boolean comparisons to
 true/false
Date: Thu, 09 Feb 2012 13:17:23 -0800
Message-ID: <1328822243.29329.11.camel@joe2Laptop>
References: <1328783282-17760-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>
	 <20120209.133413.349832435589531136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120209.133413.349832435589531136.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Booleans should not be compared to true or false
but be directly tested or tested with !.

Done via cocci script:

@@
bool t;
@@
- t == true
+ t
@@
bool t;
@@
- t != true
+ !t
@@
bool t;
@@
- t == false
+ !t
@@
bool t;
@@
- t != false
+ t

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    3 +--
 drivers/net/ethernet/brocade/bna/bfa_cee.c         |    8 ++++----
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_ee.c          |   12 +++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |    2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 +-
 drivers/net/phy/broadcom.c                         |    6 ++----
 drivers/net/wireless/ath/ath5k/ani.c               |    8 ++++----
 drivers/net/wireless/ath/ath9k/ani.c               |    6 +++---
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    5 ++---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   16 +++++++---------
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    4 ++--
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    2 +-
 drivers/net/wireless/mwl8k.c                       |    5 ++---
 drivers/net/wireless/rtlwifi/efuse.c               |    2 +-
 drivers/net/wireless/rtlwifi/ps.c                  |    3 +--
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    8 ++++----
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    9 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    3 +--
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |    3 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    9 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   11 +++++------
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   10 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   13 ++++++-------
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |    2 +-
 36 files changed, 85 insertions(+), 101 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index c7c7bf1..67e97b7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -614,8 +614,7 @@ static inline void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func,
 	u32 igu_addr_ctl = IGU_REG_COMMAND_REG_CTRL;
 	u32 igu_addr_ack = IGU_REG_CSTORM_TYPE_0_SB_CLEANUP + (idu_sb_id/32)*4;
 	u32 sb_bit =  1 << (idu_sb_id%32);
-	u32 func_encode = func |
-			((is_Pf == true ? 1 : 0) << IGU_FID_ENCODE_IS_PF_SHIFT);
+	u32 func_encode = func | (is_Pf ? 1 : 0) << IGU_FID_ENCODE_IS_PF_SHIFT;
 	u32 addr_encode = IGU_CMD_E2_PROD_UPD_BASE + idu_sb_id;
 
 	/* Not supported in BC mode */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
index 29f284f..689e5e1 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.c
@@ -203,7 +203,7 @@ bfa_nw_cee_get_attr(struct bfa_cee *cee, struct bfa_cee_attr *attr,
 	if (!bfa_nw_ioc_is_operational(cee->ioc))
 		return BFA_STATUS_IOC_FAILURE;
 
-	if (cee->get_attr_pending == true)
+	if (cee->get_attr_pending)
 		return  BFA_STATUS_DEVBUSY;
 
 	cee->get_attr_pending = true;
@@ -272,7 +272,7 @@ bfa_cee_notify(void *arg, enum bfa_ioc_event event)
 	switch (event) {
 	case BFA_IOC_E_DISABLED:
 	case BFA_IOC_E_FAILED:
-		if (cee->get_attr_pending == true) {
+		if (cee->get_attr_pending) {
 			cee->get_attr_status = BFA_STATUS_FAILED;
 			cee->get_attr_pending  = false;
 			if (cee->cbfn.get_attr_cbfn) {
@@ -281,7 +281,7 @@ bfa_cee_notify(void *arg, enum bfa_ioc_event event)
 					BFA_STATUS_FAILED);
 			}
 		}
-		if (cee->get_stats_pending == true) {
+		if (cee->get_stats_pending) {
 			cee->get_stats_status = BFA_STATUS_FAILED;
 			cee->get_stats_pending  = false;
 			if (cee->cbfn.get_stats_cbfn) {
@@ -290,7 +290,7 @@ bfa_cee_notify(void *arg, enum bfa_ioc_event event)
 					BFA_STATUS_FAILED);
 			}
 		}
-		if (cee->reset_stats_pending == true) {
+		if (cee->reset_stats_pending) {
 			cee->reset_stats_status = BFA_STATUS_FAILED;
 			cee->reset_stats_pending  = false;
 			if (cee->cbfn.reset_stats_cbfn) {
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index abfad27..77977d7 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -692,7 +692,7 @@ static void
 bfa_iocpf_sm_mismatch_entry(struct bfa_iocpf *iocpf)
 {
 	/* Call only the first time sm enters fwmismatch state. */
-	if (iocpf->fw_mismatch_notified == false)
+	if (!iocpf->fw_mismatch_notified)
 		bfa_ioc_pf_fwmismatch(iocpf->ioc);
 
 	iocpf->fw_mismatch_notified = true;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ee.c b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
index 2ed925f..eca216b 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
@@ -533,10 +533,8 @@ __le16
 ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index)
 {
 
-	if ((index < IXGB_EEPROM_SIZE) &&
-		(ixgb_check_and_get_eeprom_data(hw) == true)) {
-	   return hw->eeprom[index];
-	}
+	if (index < IXGB_EEPROM_SIZE && ixgb_check_and_get_eeprom_data(hw))
+		return hw->eeprom[index];
 
 	return 0;
 }
@@ -558,7 +556,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 
 	ENTER();
 
-	if (ixgb_check_and_get_eeprom_data(hw) == true) {
+	if (ixgb_check_and_get_eeprom_data(hw)) {
 		for (i = 0; i < ETH_ALEN; i++) {
 			mac_addr[i] = ee_map->mac_addr[i];
 		}
@@ -578,7 +576,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 u32
 ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
-	if (ixgb_check_and_get_eeprom_data(hw) == true)
+	if (ixgb_check_and_get_eeprom_data(hw))
 		return le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
 			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16);
 
@@ -599,7 +597,7 @@ ixgb_get_ee_device_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == true)
+	if (ixgb_check_and_get_eeprom_data(hw))
 		return le16_to_cpu(ee_map->device_id);
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index b406c36..752dbe6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -617,7 +617,7 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 				*link_up = false;
 		}
 
-		if (*link_up == false)
+		if (!*link_up)
 			goto out;
 	}
 
@@ -645,7 +645,7 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 	else
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
 
-	if ((hw->device_id == IXGBE_DEV_ID_82598AT2) && (*link_up == true) &&
+	if ((hw->device_id == IXGBE_DEV_ID_82598AT2) && *link_up &&
 	    (ixgbe_validate_link_ready(hw) != 0))
 		*link_up = false;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 8d8cdbc..c20035a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -257,7 +257,7 @@ static void ixgbe_restore_vf_macvlans(struct ixgbe_adapter *adapter)
 
 	list_for_each(pos, &adapter->vf_mvs.l) {
 		entry = list_entry(pos, struct vf_macvlans, l);
-		if (entry->free == false)
+		if (!entry->free)
 			hw->mac.ops.set_rar(hw, entry->rar_entry,
 					    entry->vf_macvlan,
 					    entry->vf, IXGBE_RAH_AV);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index f838a2b..5e9f05f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -760,7 +760,7 @@ static s32 ixgbe_blink_led_start_X540(struct ixgbe_hw *hw, u32 index)
 	 * This will be reversed when we stop the blinking.
 	 */
 	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-	if (link_up == false) {
+	if (!link_up) {
 		macc_reg = IXGBE_READ_REG(hw, IXGBE_MACC);
 		macc_reg |= IXGBE_MACC_FLU | IXGBE_MACC_FSV_10G | IXGBE_MACC_FS;
 		IXGBE_WRITE_REG(hw, IXGBE_MACC, macc_reg);
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index bdbec7e..69a6654 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1224,7 +1224,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 
 	/* When request status is Receive interruption */
 	if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT)) ||
-	    (adapter->rx_stop_flag == true)) {
+	    (adapter->rx_stop_flag)) {
 		if (likely(napi_schedule_prep(&adapter->napi))) {
 			/* Enable only Rx Descriptor empty */
 			atomic_inc(&adapter->irq_sem);
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index e8be47d..60338ff 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -355,8 +355,7 @@ static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 		}
 	}
 
-	if (clk125en == false ||
-	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
+	if (!clk125en || (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
 		val &= ~BCM54XX_SHD_SCR3_DLLAPD_DIS;
 	else
 		val |= BCM54XX_SHD_SCR3_DLLAPD_DIS;
@@ -373,8 +372,7 @@ static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 
 	orig = val;
 
-	if (clk125en == false ||
-	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
+	if (!clk125en || (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
 		val |= BCM54XX_SHD_APD_EN;
 	else
 		val &= ~BCM54XX_SHD_APD_EN;
diff --git a/drivers/net/wireless/ath/ath5k/ani.c b/drivers/net/wireless/ath/ath5k/ani.c
index bf67416..35e9370 100644
--- a/drivers/net/wireless/ath/ath5k/ani.c
+++ b/drivers/net/wireless/ath/ath5k/ani.c
@@ -257,7 +257,7 @@ ath5k_ani_raise_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as,
 				  "beacon RSSI high");
 		/* only OFDM: beacon RSSI is high, we can disable ODFM weak
 		 * signal detection */
-		if (ofdm_trigger && as->ofdm_weak_sig == true) {
+		if (ofdm_trigger && as->ofdm_weak_sig) {
 			ath5k_ani_set_ofdm_weak_signal_detection(ah, false);
 			ath5k_ani_set_spur_immunity_level(ah, 0);
 			return;
@@ -272,7 +272,7 @@ ath5k_ani_raise_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as,
 		 * but can raise firstep level */
 		ATH5K_DBG_UNLIMIT(ah, ATH5K_DEBUG_ANI,
 				  "beacon RSSI mid");
-		if (ofdm_trigger && as->ofdm_weak_sig == false)
+		if (ofdm_trigger && !as->ofdm_weak_sig)
 			ath5k_ani_set_ofdm_weak_signal_detection(ah, true);
 		if (as->firstep_level < ATH5K_ANI_MAX_FIRSTEP_LVL)
 			ath5k_ani_set_firstep_level(ah, as->firstep_level + 1);
@@ -282,7 +282,7 @@ ath5k_ani_raise_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as,
 		 * detect and zero firstep level to maximize CCK sensitivity */
 		ATH5K_DBG_UNLIMIT(ah, ATH5K_DEBUG_ANI,
 				  "beacon RSSI low, 2GHz");
-		if (ofdm_trigger && as->ofdm_weak_sig == true)
+		if (ofdm_trigger && as->ofdm_weak_sig)
 			ath5k_ani_set_ofdm_weak_signal_detection(ah, false);
 		if (as->firstep_level > 0)
 			ath5k_ani_set_firstep_level(ah, 0);
@@ -326,7 +326,7 @@ ath5k_ani_lower_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as)
 		} else if (rssi > ATH5K_ANI_RSSI_THR_LOW) {
 			/* beacon RSSI is mid-range: turn on ODFM weak signal
 			 * detection and next, lower firstep level */
-			if (as->ofdm_weak_sig == false) {
+			if (!as->ofdm_weak_sig) {
 				ath5k_ani_set_ofdm_weak_signal_detection(ah,
 									 true);
 				return;
diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index bc56f57..7e0ea4e 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -407,20 +407,20 @@ static void ath9k_hw_ani_lower_immunity_old(struct ath_hw *ah)
 			if (aniState->ofdmWeakSigDetectOff) {
 				if (ath9k_hw_ani_control(ah,
 					 ATH9K_ANI_OFDM_WEAK_SIGNAL_DETECTION,
-					 true) == true)
+					 true))
 					return;
 			}
 			if (aniState->firstepLevel > 0) {
 				if (ath9k_hw_ani_control(ah,
 					 ATH9K_ANI_FIRSTEP_LEVEL,
-					 aniState->firstepLevel - 1) == true)
+					 aniState->firstepLevel - 1))
 					return;
 			}
 		} else {
 			if (aniState->firstepLevel > 0) {
 				if (ath9k_hw_ani_control(ah,
 					 ATH9K_ANI_FIRSTEP_LEVEL,
-					 aniState->firstepLevel - 1) == true)
+					 aniState->firstepLevel - 1))
 					return;
 			}
 		}
diff --git a/drivers/net/wireless/ath/ath9k/hw-ops.h b/drivers/net/wireless/ath/ath9k/hw-ops.h
index c4ad0b0..265bf77 100644
--- a/drivers/net/wireless/ath/ath9k/hw-ops.h
+++ b/drivers/net/wireless/ath/ath9k/hw-ops.h
@@ -24,7 +24,7 @@
 static inline void ath9k_hw_configpcipowersave(struct ath_hw *ah,
 					       bool power_off)
 {
-	if (ah->aspm_enabled != true)
+	if (!ah->aspm_enabled)
 		return;
 
 	ath9k_hw_ops(ah)->config_pci_powersave(ah, power_off);
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 87db1ee..d0d13d7 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1600,7 +1600,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 		allow_fbs = true;
 
 	if (bChannelChange &&
-	    (ah->chip_fullsleep != true) &&
+	    (!ah->chip_fullsleep) &&
 	    (ah->curchan != NULL) &&
 	    (chan->channel != ah->curchan->channel) &&
 	    (allow_fbs ||
@@ -2038,8 +2038,7 @@ static bool ath9k_hw_set_power_awake(struct ath_hw *ah, int setChip)
 	if (setChip) {
 		if ((REG_READ(ah, AR_RTC_STATUS) &
 		     AR_RTC_STATUS_M) == AR_RTC_STATUS_SHUTDOWN) {
-			if (ath9k_hw_set_reset_reg(ah,
-					   ATH9K_RESET_POWER_ON) != true) {
+			if (!ath9k_hw_set_reset_reg(ah, ATH9K_RESET_POWER_ON)) {
 				return false;
 			}
 			if (!AR_SREV_9300_20_OR_LATER(ah))
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 6e4b5e8..bd2d1dd 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -767,7 +767,7 @@ static int brcmf_sdbrcm_htclk(struct brcmf_sdio *bus, bool on, bool pendok)
 		brcmf_dbg(INFO, "CLKCTL: turned ON\n");
 
 #if defined(DEBUG)
-		if (bus->alp_only != true) {
+		if (!bus->alp_only) {
 			if (SBSDIO_ALPONLY(clkctl))
 				brcmf_dbg(ERROR, "HT Clock should be on\n");
 		}
@@ -2059,8 +2059,7 @@ static void
 brcmf_sdbrcm_wait_for_event(struct brcmf_sdio *bus, bool *lockvar)
 {
 	up(&bus->sdsem);
-	wait_event_interruptible_timeout(bus->ctrl_wait,
-					 (*lockvar == false), HZ * 2);
+	wait_event_interruptible_timeout(bus->ctrl_wait, !*lockvar, HZ * 2);
 	down(&bus->sdsem);
 	return;
 }
@@ -2647,8 +2646,7 @@ static int brcmf_sdbrcm_bus_txdata(struct device *dev, struct sk_buff *pkt)
 
 	/* Priority based enq */
 	spin_lock_bh(&bus->txqlock);
-	if (brcmf_c_prec_enq(bus->sdiodev->dev, &bus->txq, pkt, prec) ==
-	    false) {
+	if (!brcmf_c_prec_enq(bus->sdiodev->dev, &bus->txq, pkt, prec)) {
 		skb_pull(pkt, SDPCM_HDRLEN);
 		brcmf_txcomplete(bus->sdiodev->dev, pkt, false);
 		brcmu_pkt_buf_free_skb(pkt);
@@ -2935,7 +2933,7 @@ brcmf_sdbrcm_bus_txctl(struct device *dev, unsigned char *msg, uint msglen)
 
 		brcmf_sdbrcm_wait_for_event(bus, &bus->ctrl_frame_stat);
 
-		if (bus->ctrl_frame_stat == false) {
+		if (!bus->ctrl_frame_stat) {
 			brcmf_dbg(INFO, "ctrl_frame_stat == false\n");
 			ret = 0;
 		} else {
@@ -2997,7 +2995,7 @@ brcmf_sdbrcm_bus_rxctl(struct device *dev, unsigned char *msg, uint msglen)
 			  rxlen, msglen);
 	} else if (timeleft == 0) {
 		brcmf_dbg(ERROR, "resumed on timeout\n");
-	} else if (pending == true) {
+	} else if (pending) {
 		brcmf_dbg(CTL, "cancelled\n");
 		return -ERESTARTSYS;
 	} else {
@@ -3983,7 +3981,7 @@ void
 brcmf_sdbrcm_wd_timer(struct brcmf_sdio *bus, uint wdtick)
 {
 	/* Totally stop the timer */
-	if (!wdtick && bus->wd_timer_valid == true) {
+	if (!wdtick && bus->wd_timer_valid) {
 		del_timer_sync(&bus->timer);
 		bus->wd_timer_valid = false;
 		bus->save_ms = wdtick;
@@ -3996,7 +3994,7 @@ brcmf_sdbrcm_wd_timer(struct brcmf_sdio *bus, uint wdtick)
 
 	if (wdtick) {
 		if (bus->save_ms != BRCMF_WD_POLL_MS) {
-			if (bus->wd_timer_valid == true)
+			if (bus->wd_timer_valid)
 				/* Stop timer and restart at new value */
 				del_timer_sync(&bus->timer);
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index fb712ca..90331dd 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -3248,7 +3248,7 @@ static void brcms_b_coreinit(struct brcms_c_info *wlc)
 	}
 
 	/* For old ucode, txfifo sizes needs to be modified(increased) */
-	if (fifosz_fixup == true)
+	if (fifosz_fixup)
 		brcms_b_corerev_fifofixup(wlc_hw);
 
 	/* check txfifo allocations match between ucode and driver */
@@ -5427,7 +5427,7 @@ int brcms_c_set_gmode(struct brcms_c_info *wlc, u8 gmode, bool config)
 		return -EINVAL;
 
 	/* update configuration value */
-	if (config == true)
+	if (config)
 		brcms_c_protection_upd(wlc, BRCMS_PROT_G_USER, gmode);
 
 	/* Clear rateset override */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index ec7450d..62eedd8 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -21464,7 +21464,7 @@ void wlc_phy_antsel_init(struct brcms_phy_pub *ppi, bool lut_init)
 	if (NREV_GE(pi->pubpi.phy_rev, 3)) {
 		u16 v0 = 0x211, v1 = 0x222, v2 = 0x144, v3 = 0x188;
 
-		if (lut_init == false)
+		if (!lut_init)
 			return;
 
 		if (pi->srom_fem2g.antswctrllut == 0) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c
index 08e0a7d..a8dfeca 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c
@@ -481,7 +481,7 @@ void iwl_trans_pcie_tx_agg_setup(struct iwl_trans *trans,
 	}
 
 	txq_id = trans_pcie->agg_txq[sta_id][tid];
-	if (WARN_ON_ONCE(is_agg_txqid_valid(trans, txq_id) == false)) {
+	if (WARN_ON_ONCE(!is_agg_txqid_valid(trans, txq_id))) {
 		IWL_ERR(trans,
 			"queue number out of range: %d, must be %d to %d\n",
 			txq_id, IWLAGN_FIRST_AMPDU_QUEUE,
@@ -576,7 +576,7 @@ int iwl_trans_pcie_tx_agg_disable(struct iwl_trans *trans, int sta_id, int tid)
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
 	u8 txq_id = trans_pcie->agg_txq[sta_id][tid];
 
-	if (WARN_ON_ONCE(is_agg_txqid_valid(trans, txq_id) == false)) {
+	if (WARN_ON_ONCE(!is_agg_txqid_valid(trans, txq_id))) {
 		IWL_ERR(trans,
 			"queue number out of range: %d, must be %d to %d\n",
 			txq_id, IWLAGN_FIRST_AMPDU_QUEUE,
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
index f5cb5d3..6041a96 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -1607,7 +1607,7 @@ static void iwl_trans_pcie_free(struct iwl_trans *trans)
 #ifndef CONFIG_IWLWIFI_IDI
 	iwl_trans_pcie_rx_free(trans);
 #endif
-	if (trans_pcie->irq_requested == true) {
+	if (trans_pcie->irq_requested) {
 		free_irq(trans->irq, trans);
 		iwl_free_isr_ict(trans);
 	}
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index ac7c983..b48674b 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1331,7 +1331,7 @@ static int rxq_process(struct ieee80211_hw *hw, int index, int limit)
 								wh->addr1);
 
 			if (mwl8k_vif != NULL &&
-			    mwl8k_vif->is_hw_crypto_enabled == true) {
+			    mwl8k_vif->is_hw_crypto_enabled) {
 				/*
 				 * When MMIC ERROR is encountered
 				 * by the firmware, payload is
@@ -1994,8 +1994,7 @@ mwl8k_txq_xmit(struct ieee80211_hw *hw, int index, struct sk_buff *skb)
 	 */
 
 	if (txq->len >= MWL8K_TX_DESCS - 2) {
-		if (mgmtframe == false ||
-			txq->len == MWL8K_TX_DESCS) {
+		if (!mgmtframe || txq->len == MWL8K_TX_DESCS) {
 			if (start_ba_session) {
 				spin_lock(&priv->stream_lock);
 				mwl8k_remove_stream(hw, stream);
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index b24cbe6..1f14380 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -777,7 +777,7 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 				dataempty = false;
 		}
 
-		if (dataempty == false) {
+		if (!dataempty) {
 			*efuse_addr = *efuse_addr + (tmp_word_cnts * 2) + 1;
 			*write_state = PG_STATE_HEADER;
 		} else {
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 15f86ea..5b9c3b5 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -105,8 +105,7 @@ bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 
 	case ERFOFF:
 
-		if ((changesource == RF_CHANGE_BY_HW)
-		    && (ppsc->hwradiooff == false)) {
+		if ((changesource == RF_CHANGE_BY_HW) && !ppsc->hwradiooff) {
 			ppsc->hwradiooff = true;
 		}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index cb5535c..a644735 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -329,8 +329,8 @@ static void rtl92c_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 	if (mac->opmode == NL80211_IFTYPE_ADHOC)
 		multi_sta = true;
 
-	if ((multi_sta == false) || (dm_digtable.cursta_connectctate !=
-				     DIG_STA_DISCONNECT)) {
+	if (!multi_sta ||
+	    dm_digtable.cursta_connectctate != DIG_STA_DISCONNECT) {
 		initialized = false;
 		dm_digtable.dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 		return;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 22e998d..bfff5fe 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -216,7 +216,7 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "==>\n");
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
 						 BASEBAND_CONFIG_PHY_REG);
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
@@ -229,13 +229,13 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 		rtstatus = rtlpriv->cfg->ops->config_bb_with_pgheaderfile(hw,
 						   BASEBAND_CONFIG_PHY_REG);
 	}
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
 						 BASEBAND_CONFIG_AGC_TAB);
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
@@ -580,7 +580,7 @@ void rtl92c_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtlpriv);
 	u8 cckpowerlevel[2], ofdmpowerlevel[2];
 
-	if (rtlefuse->txpwr_fromeprom == false)
+	if (!rtlefuse->txpwr_fromeprom)
 		return;
 	_rtl92c_get_txpower_index(hw, channel,
 				  &cckpowerlevel[0], &ofdmpowerlevel[0]);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 48c7b5d..5c4d9bc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -693,7 +693,7 @@ static bool _rtl92ce_init_mac(struct ieee80211_hw *hw)
 
 	rtl_write_word(rtlpriv, REG_CR, 0x2ff);
 
-	if (_rtl92ce_llt_table_init(hw) == false)
+	if (!_rtl92ce_llt_table_init(hw))
 		return false;
 
 	rtl_write_dword(rtlpriv, REG_HISR, 0xffffffff);
@@ -906,7 +906,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	rtlpci->being_init_adapter = true;
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus = _rtl92ce_init_mac(hw);
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err = 1;
 		return err;
@@ -1117,7 +1117,7 @@ void rtl92ce_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
 					      (u8 *) (&reg_rcr));
 		_rtl92ce_set_bcn_ctrl_reg(hw, 0, BIT(4));
-	} else if (check_bssid == false) {
+	} else if (!check_bssid) {
 		reg_rcr &= (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
 		_rtl92ce_set_bcn_ctrl_reg(hw, BIT(4), 0);
 		rtlpriv->cfg->ops->set_hw_reg(hw,
@@ -1985,8 +1985,7 @@ bool rtl92ce_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
 		actuallyset = true;
-	} else if ((ppsc->hwradiooff == false)
-		   && (e_rfpowerstate_toset == ERFOFF)) {
+	} else if (!ppsc->hwradiooff && (e_rfpowerstate_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
index c64daf2..88deae6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -522,8 +522,7 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 						 "IPS Set eRf nic enable\n");
 					rtstatus = rtl_ps_enable_nic(hw);
-				} while ((rtstatus != true)
-					 && (InitializeCount < 10));
+				} while (!rtstatus && (InitializeCount < 10));
 				RT_CLEAR_PS_LEVEL(ppsc,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
index 69d720d..54c7614 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
@@ -503,7 +503,7 @@ static bool _rtl92ce_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 			break;
 		}
 
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
index 8ac3bcc..34e5630 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -477,8 +477,7 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
-			} while ((rtstatus != true)
-				 && (InitializeCount < 10));
+			} while (!rtstatus && (InitializeCount < 10));
 			RT_CLEAR_PS_LEVEL(ppsc,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
index 780c0d9..506b9a0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
@@ -479,7 +479,7 @@ static bool _rtl92c_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 				      BRFSI_RFENV << 16, u4_regvalue);
 			break;
 		}
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 				 "Radio[%d] Fail!!", rfpath);
 			goto phy_rf_cfg_fail;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index 9fda1af..4737018 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -405,7 +405,7 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 		de_digtable.last_min_undecorated_pwdb_for_dm =
 				 de_digtable.min_undecorated_pwdb_for_dm;
 	}
-	if (rtlpriv->dm.dm_initialgain_enable == false)
+	if (!rtlpriv->dm.dm_initialgain_enable)
 		return;
 
 	/* because we will send data pkt when scanning
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 7d87712..509f5af 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -707,7 +707,7 @@ static bool _rtl92de_init_mac(struct ieee80211_hw *hw)
 
 	/* System init */
 	/* 18.  LLT_table_init(Adapter);  */
-	if (_rtl92de_llt_table_init(hw) == false)
+	if (!_rtl92de_llt_table_init(hw))
 		return false;
 
 	/* Clear interrupt and enable interrupt */
@@ -920,7 +920,7 @@ int rtl92de_hw_init(struct ieee80211_hw *hw)
 	rtl92d_phy_reset_iqk_result(hw);
 	/* rtlpriv->intf_ops->disable_aspm(hw); */
 	rtstatus = _rtl92de_init_mac(hw);
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err = 1;
 		spin_unlock_irqrestore(&globalmutex_for_power_and_efuse, flags);
@@ -1147,7 +1147,7 @@ void rtl92de_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 		reg_rcr |= (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR, (u8 *)(&reg_rcr));
 		_rtl92de_set_bcn_ctrl_reg(hw, 0, BIT(4));
-	} else if (check_bssid == false) {
+	} else if (!check_bssid) {
 		reg_rcr &= (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
 		_rtl92de_set_bcn_ctrl_reg(hw, BIT(4), 0);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR, (u8 *)(&reg_rcr));
@@ -2151,8 +2151,7 @@ bool rtl92de_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
 		actuallyset = true;
-	} else if ((ppsc->hwradiooff == false)
-		&& (e_rfpowerstate_toset == ERFOFF)) {
+	} else if (!ppsc->hwradiooff && (e_rfpowerstate_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
 		e_rfpowerstate_toset = ERFOFF;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index 9581a19..93eecbd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -859,7 +859,7 @@ static bool _rtl92d_phy_bb_config(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "==>\n");
 	rtstatus = _rtl92d_phy_config_bb_with_headerfile(hw,
 		BASEBAND_CONFIG_PHY_REG);
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
@@ -874,13 +874,13 @@ static bool _rtl92d_phy_bb_config(struct ieee80211_hw *hw)
 		rtstatus = _rtl92d_phy_config_bb_with_pgheaderfile(hw,
 			BASEBAND_CONFIG_PHY_REG);
 	}
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = _rtl92d_phy_config_bb_with_headerfile(hw,
 		BASEBAND_CONFIG_AGC_TAB);
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
@@ -1129,7 +1129,7 @@ void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 cckpowerlevel[2], ofdmpowerlevel[2];
 
-	if (rtlefuse->txpwr_fromeprom == false)
+	if (!rtlefuse->txpwr_fromeprom)
 		return;
 	channel = _rtl92c_phy_get_rightchnlplace(channel);
 	_rtl92d_get_txpower_index(hw, channel, &cckpowerlevel[0],
@@ -3320,8 +3320,7 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
-			} while ((rtstatus != true) &&
-				 (InitializeCount < 10));
+			} while (!rtstatus && (InitializeCount < 10));
 
 			RT_CLEAR_PS_LEVEL(ppsc,
 					  RT_RF_OFF_LEVL_HALT_NIC);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
index ff34d2d..3066a7f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
@@ -601,7 +601,7 @@ bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw)
 				      u4_regvalue);
 			break;
 		}
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 				 "Radio[%d] Fail!!", rfpath);
 			goto phy_rf_cfg_fail;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
index 0d8bf56..380e7d4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
@@ -272,7 +272,7 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 
 		/* Turn On CPU */
 		rtstatus = _rtl92s_firmware_enable_cpu(hw);
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 				 "Enable CPU fail!\n");
 			goto status_check_fail;
@@ -445,14 +445,14 @@ int rtl92s_download_fw(struct ieee80211_hw *hw)
 		rtstatus = _rtl92s_firmware_downloadcode(hw, puc_mappedfile,
 				ul_filelength);
 
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "fail!\n");
 			goto fail;
 		}
 
 		/* <3> Check whether load FW process is ready */
 		rtstatus = _rtl92s_firmware_checkready(hw, fwstatus);
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "fail!\n");
 			goto fail;
 		}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 22098c2..b141c35 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -962,7 +962,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 	rtlhal->fwcmd_ioparam = rtl_read_dword(rtlpriv, LBUS_ADDR_MASK);
 
 	/* 3. Initialize MAC/PHY Config by MACPHY_reg.txt */
-	if (rtl92s_phy_mac_config(hw) != true) {
+	if (!rtl92s_phy_mac_config(hw)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "MAC Config failed\n");
 		return rtstatus;
 	}
@@ -972,7 +972,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, CMDR, 0x37FC);
 
 	/* 4. Initialize BB After MAC Config PHY_reg.txt, AGC_Tab.txt */
-	if (rtl92s_phy_bb_config(hw) != true) {
+	if (!rtl92s_phy_bb_config(hw)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "BB Config failed\n");
 		return rtstatus;
 	}
@@ -1008,7 +1008,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 	else
 		rtl_write_byte(rtlpriv, RF_CTRL, 0x07);
 
-	if (rtl92s_phy_rf_config(hw) != true) {
+	if (!rtl92s_phy_rf_config(hw)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "RF Config failed\n");
 		return rtstatus;
 	}
@@ -1105,7 +1105,7 @@ void rtl92se_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 	if (check_bssid) {
 		reg_rcr |= (RCR_CBSSID);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR, (u8 *)(&reg_rcr));
-	} else if (check_bssid == false) {
+	} else if (!check_bssid) {
 		reg_rcr &= (~RCR_CBSSID);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR, (u8 *)(&reg_rcr));
 	}
@@ -2306,7 +2306,7 @@ bool rtl92se_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		rfpwr_toset = ERFON;
 		ppsc->hwradiooff = false;
 		actuallyset = true;
-	} else if ((ppsc->hwradiooff == false) && (rfpwr_toset == ERFOFF)) {
+	} else if ((!ppsc->hwradiooff) && (rfpwr_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF,
 			 DBG_DMESG, "RFKILL-HW Radio OFF, RF OFF\n");
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index 05b4e27..3bfc411 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -558,8 +558,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 						 "IPS Set eRf nic enable\n");
 					rtstatus = rtl_ps_enable_nic(hw);
-				} while ((rtstatus != true) &&
-					 (InitializeCount < 10));
+				} while (!rtstatus && (InitializeCount < 10));
 
 				RT_CLEAR_PS_LEVEL(ppsc,
 						  RT_RF_OFF_LEVL_HALT_NIC);
@@ -990,7 +989,7 @@ static bool _rtl92s_phy_bb_config_parafile(struct ieee80211_hw *hw)
 		rtstatus = false;
 	}
 
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
 			 "Write BB Reg Fail!!\n");
 		goto phy_BB8190_Config_ParaFile_Fail;
@@ -1004,7 +1003,7 @@ static bool _rtl92s_phy_bb_config_parafile(struct ieee80211_hw *hw)
 		rtstatus = _rtl92s_phy_config_bb_with_pg(hw,
 						 BASEBAND_CONFIG_PHY_REG);
 	}
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
 			 "_rtl92s_phy_bb_config_parafile(): BB_PG Reg Fail!!\n");
 		goto phy_BB8190_Config_ParaFile_Fail;
@@ -1013,7 +1012,7 @@ static bool _rtl92s_phy_bb_config_parafile(struct ieee80211_hw *hw)
 	/* 3. BB AGC table Initialization */
 	rtstatus = _rtl92s_phy_config_bb(hw, BASEBAND_CONFIG_AGC_TAB);
 
-	if (rtstatus != true) {
+	if (!rtstatus) {
 		pr_err("%s(): AGC Table Fail\n", __func__);
 		goto phy_BB8190_Config_ParaFile_Fail;
 	}
@@ -1270,7 +1269,7 @@ void rtl92s_phy_set_txpower(struct ieee80211_hw *hw, u8	channel)
 	/* [0]:RF-A, [1]:RF-B */
 	u8 cckpowerlevel[2], ofdmpowerLevel[2];
 
-	if (rtlefuse->txpwr_fromeprom == false)
+	if (!rtlefuse->txpwr_fromeprom)
 		return;
 
 	/* Mainly we use RF-A Tx Power to write the Tx Power registers,
@@ -1621,7 +1620,7 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 			break;
 		case FW_CMD_HIGH_PWR_ENABLE:
 			if (!(rtlpriv->dm.dm_flag & HAL_DM_HIPWR_DISABLE) &&
-				(rtlpriv->dm.dynamic_txpower_enable != true)) {
+			    !rtlpriv->dm.dynamic_txpower_enable) {
 				fw_cmdmap |= (FW_HIGH_PWR_ENABLE_CTL |
 					      FW_SS_CTL);
 				FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
index ad51906..08c2f56 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
@@ -499,7 +499,7 @@ bool rtl92s_phy_rf6052_config(struct ieee80211_hw *hw)
 			break;
 		}
 
-		if (rtstatus != true) {
+		if (!rtstatus) {
 			pr_err("Radio[%d] Fail!!\n", rfpath);
 			goto fail;
 		}


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
