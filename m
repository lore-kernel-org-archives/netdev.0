From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-04-25
Date: Wed, 25 Apr 2012 14:06:39 -0400
Message-ID: <20120425180639.GA16900__2601.91702186621$1335378412$gmane$org@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44302 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851Ab2DYS0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 14:26:42 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
	(envelope-from <linville@tuxdriver.com>)
	id 1SN6vI-0007Lu-V0
	for netdev@vger.kernel.org; Wed, 25 Apr 2012 14:26:41 -0400
Received: from linville-8530p.local (linville-8530p.local [127.0.0.1])
	by linville-8530p.local (8.14.4/8.14.4) with ESMTP id q3PINkjD023539
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 14:23:46 -0400
Received: (from linville@localhost)
	by linville-8530p.local (8.14.4/8.14.4/Submit) id q3PINksa023537
	for netdev@vger.kernel.org; Wed, 25 Apr 2012 14:23:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 395836282f7cf8b1dac9b9c2aa2bacddfa1580b5

Dave,

This is a batch of fixes intended for 3.4.

The brcmsmac patch from Eldad Zack eliminates some log spam.
The mac80211 patch from Eliad Peller fixes a WARNING when removing
an interface.  The two patches from Gabor Juhos combine to address
a regression with some bad tx power settings for an Atheros chip.
Johannes Berg gives us a fix for some bad hardware initializtion in
iwlwifi, which resulted in hardware lockups.  Larry Finger gives us
a fix for an oops when unloading the rtlwifi modules.  Meenakshi
Venkataraman fixes some firmware version values in iwlwifi that
result in attempts to load firmware that does not exist in the wild.
Stanislav Yakovlev fixes a race condition in the ipw2200 driver.
Finally,  Stanislaw Gruszka provides an iwlwifi fix to avoid a NULL
pointer access.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 2a5809499e35b53a6044fd34e72b242688b7a862:

  asix: Fix tx transfer padding for full-speed USB (2012-04-24 04:11:34 -04=
00)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Eldad Zack (1):
      brcmsmac: "INTERMEDIATE but not AMPDU" only when tracing

Eliad Peller (1):
      mac80211: call ieee80211_mgd_stop() on interface stop

Gabor Juhos (2):
      ath9k: add an extra boolean parameter to ath9k_hw_apply_txpower
      ath9k: fix tx power settings for AR9287

Johannes Berg (1):
      iwlwifi: fix hardware queue programming

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: Fix oops on unload

Meenakshi Venkataraman (1):
      iwlwifi: use correct released ucode version

Stanislav Yakovlev (1):
      ipw2200: Fix race condition in the command completion acknowledge

Stanislaw Gruszka (1):
      iwlwifi: do not nulify ctx->vif on reset

 drivers/net/wireless/ath/ath9k/ar5008_phy.c    |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c  |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |    2 +
 drivers/net/wireless/ath/ath9k/hw.c            |    9 ++++---
 drivers/net/wireless/ath/ath9k/hw.h            |    3 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c |    3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c         |   13 ++++++++++-
 drivers/net/wireless/iwlwifi/iwl-1000.c        |    8 +++---
 drivers/net/wireless/iwlwifi/iwl-2000.c        |   16 +++++++-------
 drivers/net/wireless/iwlwifi/iwl-5000.c        |   11 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   10 +++++---
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    3 --
 drivers/net/wireless/iwlwifi/iwl-fh.h          |   22 ++++++++++++++++---
 drivers/net/wireless/iwlwifi/iwl-mac80211.c    |   10 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-prph.h        |   27 ++++++++++++++++++++=
+--
 drivers/net/wireless/rtlwifi/pci.c             |    1 +
 net/mac80211/ieee80211_i.h                     |    2 +-
 net/mac80211/iface.c                           |    4 +-
 net/mac80211/mlme.c                            |    2 +-
 20 files changed, 108 insertions(+), 44 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wire=
less/ath/ath9k/ar5008_phy.c
index d7d8e91..aba0880 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -869,7 +869,7 @@ static int ar5008_hw_process_ini(struct ath_hw *ah,
 	ar5008_hw_set_channel_regs(ah, chan);
 	ar5008_hw_init_chain_masks(ah);
 	ath9k_olc_init(ah);
-	ath9k_hw_apply_txpower(ah, chan);
+	ath9k_hw_apply_txpower(ah, chan, false);
=20
 	/* Write analog registers */
 	if (!ath9k_hw_set_rf_regs(ah, chan, freqIndex)) {
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c b/drivers/net/wi=
reless/ath/ath9k/ar9003_paprd.c
index 59647a3..3d400e8 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
@@ -54,7 +54,7 @@ void ar9003_paprd_enable(struct ath_hw *ah, bool val)
=20
 	if (val) {
 		ah->paprd_table_write_done =3D true;
-		ath9k_hw_apply_txpower(ah, chan);
+		ath9k_hw_apply_txpower(ah, chan, false);
 	}
=20
 	REG_RMW_FIELD(ah, AR_PHY_PAPRD_CTRL0_B0,
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.c
index bc992b2..deb6cfb 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -694,7 +694,7 @@ static int ar9003_hw_process_ini(struct ath_hw *ah,
 	ar9003_hw_override_ini(ah);
 	ar9003_hw_set_channel_regs(ah, chan);
 	ar9003_hw_set_chain_masks(ah, ah->rxchainmask, ah->txchainmask);
-	ath9k_hw_apply_txpower(ah, chan);
+	ath9k_hw_apply_txpower(ah, chan, false);
=20
 	if (AR_SREV_9462(ah)) {
 		if (REG_READ_FIELD(ah, AR_PHY_TX_IQCAL_CONTROL_0,
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wir=
eless/ath/ath9k/eeprom_9287.c
index f272236..b34e8b2 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -824,6 +824,8 @@ static void ath9k_hw_ar9287_set_txpower(struct ath_hw *=
ah,
 			regulatory->max_power_level =3D ratesArray[i];
 	}
=20
+	ath9k_hw_update_regulatory_maxpower(ah);
+
 	if (test)
 		return;
=20
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 6c69e4e..fa84e37 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1454,7 +1454,7 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 		return false;
 	}
 	ath9k_hw_set_clockrate(ah);
-	ath9k_hw_apply_txpower(ah, chan);
+	ath9k_hw_apply_txpower(ah, chan, false);
 	ath9k_hw_rfbus_done(ah);
=20
 	if (IS_CHAN_OFDM(chan) || IS_CHAN_HT(chan))
@@ -2652,7 +2652,8 @@ static int get_antenna_gain(struct ath_hw *ah, struct=
 ath9k_channel *chan)
 	return ah->eep_ops->get_eeprom(ah, gain_param);
 }
=20
-void ath9k_hw_apply_txpower(struct ath_hw *ah, struct ath9k_channel *chan)
+void ath9k_hw_apply_txpower(struct ath_hw *ah, struct ath9k_channel *chan,
+			    bool test)
 {
 	struct ath_regulatory *reg =3D ath9k_hw_regulatory(ah);
 	struct ieee80211_channel *channel;
@@ -2673,7 +2674,7 @@ void ath9k_hw_apply_txpower(struct ath_hw *ah, struct=
 ath9k_channel *chan)
=20
 	ah->eep_ops->set_txpower(ah, chan,
 				 ath9k_regd_get_ctl(reg, chan),
-				 ant_reduction, new_pwr, false);
+				 ant_reduction, new_pwr, test);
 }
=20
 void ath9k_hw_set_txpowerlimit(struct ath_hw *ah, u32 limit, bool test)
@@ -2686,7 +2687,7 @@ void ath9k_hw_set_txpowerlimit(struct ath_hw *ah, u32=
 limit, bool test)
 	if (test)
 		channel->max_power =3D MAX_RATE_POWER / 2;
=20
-	ath9k_hw_apply_txpower(ah, chan);
+	ath9k_hw_apply_txpower(ah, chan, test);
=20
 	if (test)
 		channel->max_power =3D DIV_ROUND_UP(reg->max_power_level, 2);
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index aa1680a..e88f182 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -985,7 +985,8 @@ void ath9k_hw_name(struct ath_hw *ah, char *hw_name, si=
ze_t len);
 /* PHY */
 void ath9k_hw_get_delta_slope_vals(struct ath_hw *ah, u32 coef_scaled,
 				   u32 *coef_mantissa, u32 *coef_exponent);
-void ath9k_hw_apply_txpower(struct ath_hw *ah, struct ath9k_channel *chan);
+void ath9k_hw_apply_txpower(struct ath_hw *ah, struct ath9k_channel *chan,
+			    bool test);
=20
 /*
  * Code Specific to AR5008, AR9001 or AR9002,
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index 7083db7..b4d9279 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -847,8 +847,7 @@ brcms_c_dotxstatus(struct brcms_c_info *wlc, struct tx_=
status *txs)
 	 */
 	if (!(txs->status & TX_STATUS_AMPDU)
 	    && (txs->status & TX_STATUS_INTERMEDIATE)) {
-		wiphy_err(wlc->wiphy, "%s: INTERMEDIATE but not AMPDU\n",
-			  __func__);
+		BCMMSG(wlc->wiphy, "INTERMEDIATE but not AMPDU\n");
 		return false;
 	}
=20
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/=
ipw2x00/ipw2200.c
index 2b02257..1779db3 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -2191,6 +2191,7 @@ static int __ipw_send_cmd(struct ipw_priv *priv, stru=
ct host_cmd *cmd)
 {
 	int rc =3D 0;
 	unsigned long flags;
+	unsigned long now, end;
=20
 	spin_lock_irqsave(&priv->lock, flags);
 	if (priv->status & STATUS_HCMD_ACTIVE) {
@@ -2232,10 +2233,20 @@ static int __ipw_send_cmd(struct ipw_priv *priv, st=
ruct host_cmd *cmd)
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
=20
+	now =3D jiffies;
+	end =3D now + HOST_COMPLETE_TIMEOUT;
+again:
 	rc =3D wait_event_interruptible_timeout(priv->wait_command_queue,
 					      !(priv->
 						status & STATUS_HCMD_ACTIVE),
-					      HOST_COMPLETE_TIMEOUT);
+					      end - now);
+	if (rc < 0) {
+		now =3D jiffies;
+		if (time_before(now, end))
+			goto again;
+		rc =3D 0;
+	}
+
 	if (rc =3D=3D 0) {
 		spin_lock_irqsave(&priv->lock, flags);
 		if (priv->status & STATUS_HCMD_ACTIVE) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless=
/iwlwifi/iwl-1000.c
index 5b0d888..8d80e23 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -46,8 +46,8 @@
 #include "iwl-prph.h"
=20
 /* Highest firmware API version supported */
-#define IWL1000_UCODE_API_MAX 6
-#define IWL100_UCODE_API_MAX 6
+#define IWL1000_UCODE_API_MAX 5
+#define IWL100_UCODE_API_MAX 5
=20
 /* Oldest version we won't warn about */
 #define IWL1000_UCODE_API_OK 5
@@ -226,5 +226,5 @@ const struct iwl_cfg iwl100_bg_cfg =3D {
 	IWL_DEVICE_100,
 };
=20
-MODULE_FIRMWARE(IWL1000_MODULE_FIRMWARE(IWL1000_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL100_MODULE_FIRMWARE(IWL100_UCODE_API_MAX));
+MODULE_FIRMWARE(IWL1000_MODULE_FIRMWARE(IWL1000_UCODE_API_OK));
+MODULE_FIRMWARE(IWL100_MODULE_FIRMWARE(IWL100_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/iwl-2000.c b/drivers/net/wireless=
/iwlwifi/iwl-2000.c
index 5635b9e..ea10862 100644
--- a/drivers/net/wireless/iwlwifi/iwl-2000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-2000.c
@@ -51,10 +51,10 @@
 #define IWL135_UCODE_API_MAX 6
=20
 /* Oldest version we won't warn about */
-#define IWL2030_UCODE_API_OK 5
-#define IWL2000_UCODE_API_OK 5
-#define IWL105_UCODE_API_OK 5
-#define IWL135_UCODE_API_OK 5
+#define IWL2030_UCODE_API_OK 6
+#define IWL2000_UCODE_API_OK 6
+#define IWL105_UCODE_API_OK 6
+#define IWL135_UCODE_API_OK 6
=20
 /* Lowest firmware API version supported */
 #define IWL2030_UCODE_API_MIN 5
@@ -328,7 +328,7 @@ const struct iwl_cfg iwl135_bgn_cfg =3D {
 	.ht_params =3D &iwl2000_ht_params,
 };
=20
-MODULE_FIRMWARE(IWL2000_MODULE_FIRMWARE(IWL2000_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL2030_MODULE_FIRMWARE(IWL2030_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL105_MODULE_FIRMWARE(IWL105_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL135_MODULE_FIRMWARE(IWL135_UCODE_API_MAX));
+MODULE_FIRMWARE(IWL2000_MODULE_FIRMWARE(IWL2000_UCODE_API_OK));
+MODULE_FIRMWARE(IWL2030_MODULE_FIRMWARE(IWL2030_UCODE_API_OK));
+MODULE_FIRMWARE(IWL105_MODULE_FIRMWARE(IWL105_UCODE_API_OK));
+MODULE_FIRMWARE(IWL135_MODULE_FIRMWARE(IWL135_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless=
/iwlwifi/iwl-5000.c
index a805e97..de0920c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -51,6 +51,10 @@
 #define IWL5000_UCODE_API_MAX 5
 #define IWL5150_UCODE_API_MAX 2
=20
+/* Oldest version we won't warn about */
+#define IWL5000_UCODE_API_OK 5
+#define IWL5150_UCODE_API_OK 2
+
 /* Lowest firmware API version supported */
 #define IWL5000_UCODE_API_MIN 1
 #define IWL5150_UCODE_API_MIN 1
@@ -326,6 +330,7 @@ static const struct iwl_ht_params iwl5000_ht_params =3D=
 {
 #define IWL_DEVICE_5000						\
 	.fw_name_pre =3D IWL5000_FW_PRE,				\
 	.ucode_api_max =3D IWL5000_UCODE_API_MAX,			\
+	.ucode_api_ok =3D IWL5000_UCODE_API_OK,			\
 	.ucode_api_min =3D IWL5000_UCODE_API_MIN,			\
 	.max_inst_size =3D IWLAGN_RTC_INST_SIZE,			\
 	.max_data_size =3D IWLAGN_RTC_DATA_SIZE,			\
@@ -371,6 +376,7 @@ const struct iwl_cfg iwl5350_agn_cfg =3D {
 	.name =3D "Intel(R) WiMAX/WiFi Link 5350 AGN",
 	.fw_name_pre =3D IWL5000_FW_PRE,
 	.ucode_api_max =3D IWL5000_UCODE_API_MAX,
+	.ucode_api_ok =3D IWL5000_UCODE_API_OK,
 	.ucode_api_min =3D IWL5000_UCODE_API_MIN,
 	.max_inst_size =3D IWLAGN_RTC_INST_SIZE,
 	.max_data_size =3D IWLAGN_RTC_DATA_SIZE,
@@ -386,6 +392,7 @@ const struct iwl_cfg iwl5350_agn_cfg =3D {
 #define IWL_DEVICE_5150						\
 	.fw_name_pre =3D IWL5150_FW_PRE,				\
 	.ucode_api_max =3D IWL5150_UCODE_API_MAX,			\
+	.ucode_api_ok =3D IWL5150_UCODE_API_OK,			\
 	.ucode_api_min =3D IWL5150_UCODE_API_MIN,			\
 	.max_inst_size =3D IWLAGN_RTC_INST_SIZE,			\
 	.max_data_size =3D IWLAGN_RTC_DATA_SIZE,			\
@@ -409,5 +416,5 @@ const struct iwl_cfg iwl5150_abg_cfg =3D {
 	IWL_DEVICE_5150,
 };
=20
-MODULE_FIRMWARE(IWL5000_MODULE_FIRMWARE(IWL5000_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL5150_MODULE_FIRMWARE(IWL5150_UCODE_API_MAX));
+MODULE_FIRMWARE(IWL5000_MODULE_FIRMWARE(IWL5000_UCODE_API_OK));
+MODULE_FIRMWARE(IWL5150_MODULE_FIRMWARE(IWL5150_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless=
/iwlwifi/iwl-6000.c
index 64060cd..b1b6951 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -53,6 +53,8 @@
 /* Oldest version we won't warn about */
 #define IWL6000_UCODE_API_OK 4
 #define IWL6000G2_UCODE_API_OK 5
+#define IWL6050_UCODE_API_OK 5
+#define IWL6000G2B_UCODE_API_OK 6
=20
 /* Lowest firmware API version supported */
 #define IWL6000_UCODE_API_MIN 4
@@ -334,7 +336,7 @@ static const struct iwl_bt_params iwl6000_bt_params =3D=
 {
 #define IWL_DEVICE_6005						\
 	.fw_name_pre =3D IWL6005_FW_PRE,				\
 	.ucode_api_max =3D IWL6000G2_UCODE_API_MAX,		\
-	.ucode_api_ok =3D IWL6000G2_UCODE_API_OK,			\
+	.ucode_api_ok =3D IWL6000G2B_UCODE_API_OK,		\
 	.ucode_api_min =3D IWL6000G2_UCODE_API_MIN,		\
 	.max_inst_size =3D IWL60_RTC_INST_SIZE,			\
 	.max_data_size =3D IWL60_RTC_DATA_SIZE,			\
@@ -557,6 +559,6 @@ const struct iwl_cfg iwl6000_3agn_cfg =3D {
 };
=20
 MODULE_FIRMWARE(IWL6000_MODULE_FIRMWARE(IWL6000_UCODE_API_OK));
-MODULE_FIRMWARE(IWL6050_MODULE_FIRMWARE(IWL6050_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL6005_MODULE_FIRMWARE(IWL6000G2_UCODE_API_MAX));
-MODULE_FIRMWARE(IWL6030_MODULE_FIRMWARE(IWL6000G2_UCODE_API_MAX));
+MODULE_FIRMWARE(IWL6050_MODULE_FIRMWARE(IWL6050_UCODE_API_OK));
+MODULE_FIRMWARE(IWL6005_MODULE_FIRMWARE(IWL6000G2_UCODE_API_OK));
+MODULE_FIRMWARE(IWL6030_MODULE_FIRMWARE(IWL6000G2B_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/=
iwlwifi/iwl-agn.c
index f1226db..2a9a16f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -863,7 +863,6 @@ static void iwl_bg_run_time_calib_work(struct work_stru=
ct *work)
=20
 void iwlagn_prepare_restart(struct iwl_priv *priv)
 {
-	struct iwl_rxon_context *ctx;
 	bool bt_full_concurrent;
 	u8 bt_ci_compliance;
 	u8 bt_load;
@@ -872,8 +871,6 @@ void iwlagn_prepare_restart(struct iwl_priv *priv)
=20
 	lockdep_assert_held(&priv->mutex);
=20
-	for_each_context(priv, ctx)
-		ctx->vif =3D NULL;
 	priv->is_open =3D 0;
=20
 	/*
diff --git a/drivers/net/wireless/iwlwifi/iwl-fh.h b/drivers/net/wireless/i=
wlwifi/iwl-fh.h
index 9020809..74bce97 100644
--- a/drivers/net/wireless/iwlwifi/iwl-fh.h
+++ b/drivers/net/wireless/iwlwifi/iwl-fh.h
@@ -104,15 +104,29 @@
  * (see struct iwl_tfd_frame).  These 16 pointer registers are offset by 0=
x04
  * bytes from one another.  Each TFD circular buffer in DRAM must be 256-b=
yte
  * aligned (address bits 0-7 must be 0).
+ * Later devices have 20 (5000 series) or 30 (higher) queues, but the regi=
sters
+ * for them are in different places.
  *
  * Bit fields in each pointer register:
  *  27-0: TFD CB physical base address [35:8], must be 256-byte aligned
  */
-#define FH_MEM_CBBC_LOWER_BOUND          (FH_MEM_LOWER_BOUND + 0x9D0)
-#define FH_MEM_CBBC_UPPER_BOUND          (FH_MEM_LOWER_BOUND + 0xA10)
-
-/* Find TFD CB base pointer for given queue (range 0-15). */
-#define FH_MEM_CBBC_QUEUE(x)  (FH_MEM_CBBC_LOWER_BOUND + (x) * 0x4)
+#define FH_MEM_CBBC_0_15_LOWER_BOUND		(FH_MEM_LOWER_BOUND + 0x9D0)
+#define FH_MEM_CBBC_0_15_UPPER_BOUND		(FH_MEM_LOWER_BOUND + 0xA10)
+#define FH_MEM_CBBC_16_19_LOWER_BOUND		(FH_MEM_LOWER_BOUND + 0xBF0)
+#define FH_MEM_CBBC_16_19_UPPER_BOUND		(FH_MEM_LOWER_BOUND + 0xC00)
+#define FH_MEM_CBBC_20_31_LOWER_BOUND		(FH_MEM_LOWER_BOUND + 0xB20)
+#define FH_MEM_CBBC_20_31_UPPER_BOUND		(FH_MEM_LOWER_BOUND + 0xB80)
+
+/* Find TFD CB base pointer for given queue */
+static inline unsigned int FH_MEM_CBBC_QUEUE(unsigned int chnl)
+{
+	if (chnl < 16)
+		return FH_MEM_CBBC_0_15_LOWER_BOUND + 4 * chnl;
+	if (chnl < 20)
+		return FH_MEM_CBBC_16_19_LOWER_BOUND + 4 * (chnl - 16);
+	WARN_ON_ONCE(chnl >=3D 32);
+	return FH_MEM_CBBC_20_31_LOWER_BOUND + 4 * (chnl - 20);
+}
=20
=20
 /**
diff --git a/drivers/net/wireless/iwlwifi/iwl-mac80211.c b/drivers/net/wire=
less/iwlwifi/iwl-mac80211.c
index b6805f8..c24a713 100644
--- a/drivers/net/wireless/iwlwifi/iwl-mac80211.c
+++ b/drivers/net/wireless/iwlwifi/iwl-mac80211.c
@@ -1244,6 +1244,7 @@ static int iwlagn_mac_add_interface(struct ieee80211_=
hw *hw,
 	struct iwl_rxon_context *tmp, *ctx =3D NULL;
 	int err;
 	enum nl80211_iftype viftype =3D ieee80211_vif_type_p2p(vif);
+	bool reset =3D false;
=20
 	IWL_DEBUG_MAC80211(priv, "enter: type %d, addr %pM\n",
 			   viftype, vif->addr);
@@ -1265,6 +1266,13 @@ static int iwlagn_mac_add_interface(struct ieee80211=
_hw *hw,
 			tmp->interface_modes | tmp->exclusive_interface_modes;
=20
 		if (tmp->vif) {
+			/* On reset we need to add the same interface again */
+			if (tmp->vif =3D=3D vif) {
+				reset =3D true;
+				ctx =3D tmp;
+				break;
+			}
+
 			/* check if this busy context is exclusive */
 			if (tmp->exclusive_interface_modes &
 						BIT(tmp->vif->type)) {
@@ -1291,7 +1299,7 @@ static int iwlagn_mac_add_interface(struct ieee80211_=
hw *hw,
 	ctx->vif =3D vif;
=20
 	err =3D iwl_setup_interface(priv, ctx);
-	if (!err)
+	if (!err || reset)
 		goto out;
=20
 	ctx->vif =3D NULL;
diff --git a/drivers/net/wireless/iwlwifi/iwl-prph.h b/drivers/net/wireless=
/iwlwifi/iwl-prph.h
index 75dc20b..3b10692 100644
--- a/drivers/net/wireless/iwlwifi/iwl-prph.h
+++ b/drivers/net/wireless/iwlwifi/iwl-prph.h
@@ -223,12 +223,33 @@
 #define SCD_AIT			(SCD_BASE + 0x0c)
 #define SCD_TXFACT		(SCD_BASE + 0x10)
 #define SCD_ACTIVE		(SCD_BASE + 0x14)
-#define SCD_QUEUE_WRPTR(x)	(SCD_BASE + 0x18 + (x) * 4)
-#define SCD_QUEUE_RDPTR(x)	(SCD_BASE + 0x68 + (x) * 4)
 #define SCD_QUEUECHAIN_SEL	(SCD_BASE + 0xe8)
 #define SCD_AGGR_SEL		(SCD_BASE + 0x248)
 #define SCD_INTERRUPT_MASK	(SCD_BASE + 0x108)
-#define SCD_QUEUE_STATUS_BITS(x)	(SCD_BASE + 0x10c + (x) * 4)
+
+static inline unsigned int SCD_QUEUE_WRPTR(unsigned int chnl)
+{
+	if (chnl < 20)
+		return SCD_BASE + 0x18 + chnl * 4;
+	WARN_ON_ONCE(chnl >=3D 32);
+	return SCD_BASE + 0x284 + (chnl - 20) * 4;
+}
+
+static inline unsigned int SCD_QUEUE_RDPTR(unsigned int chnl)
+{
+	if (chnl < 20)
+		return SCD_BASE + 0x68 + chnl * 4;
+	WARN_ON_ONCE(chnl >=3D 32);
+	return SCD_BASE + 0x2B4 + (chnl - 20) * 4;
+}
+
+static inline unsigned int SCD_QUEUE_STATUS_BITS(unsigned int chnl)
+{
+	if (chnl < 20)
+		return SCD_BASE + 0x10c + chnl * 4;
+	WARN_ON_ONCE(chnl >=3D 32);
+	return SCD_BASE + 0x384 + (chnl - 20) * 4;
+}
=20
 /*********************** END TX SCHEDULER ********************************=
*****/
=20
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 288b035..cc15fdb 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1941,6 +1941,7 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 		rtl_deinit_deferred_work(hw);
 		rtlpriv->intf_ops->adapter_stop(hw);
 	}
+	rtlpriv->cfg->ops->disable_interrupt(hw);
=20
 	/*deinit rfkill */
 	rtl_deinit_rfkill(hw);
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index d9798a3..db8fae5 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1210,7 +1210,7 @@ void ieee80211_sta_rx_queued_mgmt(struct ieee80211_su=
b_if_data *sdata,
 				  struct sk_buff *skb);
 void ieee80211_sta_reset_beacon_monitor(struct ieee80211_sub_if_data *sdat=
a);
 void ieee80211_sta_reset_conn_monitor(struct ieee80211_sub_if_data *sdata);
-void ieee80211_mgd_teardown(struct ieee80211_sub_if_data *sdata);
+void ieee80211_mgd_stop(struct ieee80211_sub_if_data *sdata);
=20
 /* IBSS code */
 void ieee80211_ibss_notify_scan_completed(struct ieee80211_local *local);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 401c01f..c20051b 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -486,6 +486,8 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_d=
ata *sdata,
 		/* free all potentially still buffered bcast frames */
 		local->total_ps_buffered -=3D skb_queue_len(&sdata->u.ap.ps_bc_buf);
 		skb_queue_purge(&sdata->u.ap.ps_bc_buf);
+	} else if (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION) {
+		ieee80211_mgd_stop(sdata);
 	}
=20
 	if (going_down)
@@ -644,8 +646,6 @@ static void ieee80211_teardown_sdata(struct net_device =
*dev)
=20
 	if (ieee80211_vif_is_mesh(&sdata->vif))
 		mesh_rmc_free(sdata);
-	else if (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION)
-		ieee80211_mgd_teardown(sdata);
=20
 	flushed =3D sta_info_flush(local, sdata);
 	WARN_ON(flushed);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index f76da5b..20c680b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3497,7 +3497,7 @@ int ieee80211_mgd_disassoc(struct ieee80211_sub_if_da=
ta *sdata,
 	return 0;
 }
=20
-void ieee80211_mgd_teardown(struct ieee80211_sub_if_data *sdata)
+void ieee80211_mgd_stop(struct ieee80211_sub_if_data *sdata)
 {
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPmD0vAAoJEJctW/TcYTgGop8P/R8CuAktFlyGTqli8Zd2rYhj
J/9+2PYpcPzbxeQBDvHsxR0ewUmxcewooXSrbWY8uoL668LsU505i58H51uFsgXr
MoHbFFAwV/HX4Xp9b2cZh3tZymNyIp+asRQgEOkd4RN95mUYNUcnA5Y6EPXvuGN0
Kio1AEU/psS527UpItNarLXPfTmbFKYjUEouNPY+Yy6nK0RB8noSbiPjiE/CdrYg
ZydiWPYyjK/mt4ERm6guqCOk6JJY7v63vNzNwCuiE91+mWjfg5+HW9dxSrp3ZeL1
9T0uQy70CSA2d9syP7VhVUHs+7RScyNH2gYVwFT2aJBxOAR9zmh8lK8smiGdCccv
8Hkh+0j35drNIYo108KXcn4eya0zDMW9+4jvXYnJCG3j+DHfXY2BYfjuBxkQqn6q
R6ybCUZqbOSOUsrLmbt3s1EQqA0nxwI+5utnzCbEWgcRq7257Xc0KoCmny2Bii9e
CgPjva2wI0ovdcfLmjh5RWzG+TAaeL8xZZBg2SaEda+kxSL51dyguL3jodnGSwhs
wK9ebv5GLjlvK+2qQS88TWQBe8aTSNn4/riC17A0Lblr9rXf3/F1EcrqeupD+goS
k3V1CHvV5M2icSbCZoJFULpY0sOfDF1PSXhTuj1HZP/jqQBH5OUKrByBXTLSQRNY
k1wBHqjkCL4e4Og9udO8
=Ks/Q
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--
