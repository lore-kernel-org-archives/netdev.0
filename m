From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-09-11
Date: Thu, 11 Sep 2014 14:43:22 -0400
Message-ID: <20140911184322.GB22872@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.17 stream:

For the mac80211 bits, Johannes says:

"Two more fixes for mac80211 - one of them addresses a long-standing
issue that we only found when using vendor events more frequently;
the other addresses some bad information being reported in userspace
that people were starting to actually look at."

For the iwlwifi bits, Emmanuel says:

"I re-enable scheduled scan on firmware that contain the fix for
the bug that Linus reported.  A few trivial fixes: endianity issues,
the same DTIM period fix that I did in mac80211.  Eyal fixes a few
issues we identified with EAPOL, we now send them just as if they were
management frames, this solves interrop issues.  Johannes has another
set of trivial fixes, while Luca fixes the way we configure the filters
in the firmware. Last but not least, a new device is added by Oren."

Emmanuel was traveling, resulting in his pull to be a bit larger than
I would have liked to see at this point.  FWIW, I have asked Emmanuel
to be much more strict for any more pull requests in this cycle.

In addition to the above, Sujith Manoharan reverts an earlier ath9k
patch.  The earlier change was found to allow for the device to sleep
too long and miss beacons.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1bd3fa7b8c9b2936c16c6e6452f9cc991c405872:

  Merge branch 'for-john' of git://git.kernel.org/pub/scm/linux/kernel/git/=
iwlwifi/iwlwifi-fixes (2014-09-04 13:12:02 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-09-11

for you to fetch changes up to ae0fd6354134e63aa3e62456e2080c430287144d:

  Revert "ath9k: Calculate sleep duration" (2014-09-11 14:17:20 -0400)

----------------------------------------------------------------
wireless-testing 2014-09-11

----------------------------------------------------------------
Eliad Peller (1):
      iwlwifi: increase DEFAULT_MAX_TX_POWER

Emmanuel Grumbach (5):
      iwlwifi: mvm: enable scheduled scan on newest firmware
      mac80211: use bss_conf->dtim_period instead of conf.ps_dtim_period
      iwlwifi: mvm: fix endianity issues with Smart Fifo commands
      iwlwiwi: mvm: use bss_conf->dtim_period instead of conf.ps_dtim_period
      iwlwifi: dvm: disable power save by default

Eyal Shapira (2):
      iwlwifi: mvm: treat EAPOLs like mgmt frames wrt rate
      iwlwifi: mvm: fix an overflow in iwl_mvm_get_signal_strength

Johannes Berg (4):
      nl80211: clear skb cb before passing to netlink
      iwlwifi: mvm: BT Coex - remove shadowing variable
      iwlwifi: mvm: correctly handle PM/QoS changes from mac80211
      iwlwifi: mvm: BT Coex - always initialize smps_mode

John W. Linville (2):
      Merge tag 'mac80211-for-john-2014-09-08' of git://git.kernel.org/.../=
jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes

Luciano Coelho (1):
      iwlwifi: mvm: set MAC_FILTER_IN_BEACON correctly for STA/P2P client

Oren Givon (1):
      iwlwifi: add PCI IDs and add then new 3165 series

Sujith Manoharan (1):
      Revert "ath9k: Calculate sleep duration"

 drivers/net/wireless/ath/ath9k/common-beacon.c |  5 ++---
 drivers/net/wireless/iwlwifi/dvm/power.c       |  2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c        | 16 ++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-config.h      |  3 +++
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c   |  4 +---
 drivers/net/wireless/iwlwifi/mvm/coex.c        |  9 +++------
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c |  3 +--
 drivers/net/wireless/iwlwifi/mvm/fw-api.h      |  4 ++--
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c    | 10 +++++-----
 drivers/net/wireless/iwlwifi/mvm/mac80211.c    | 25 ++++++++++++++--------=
---
 drivers/net/wireless/iwlwifi/mvm/power.c       |  5 ++---
 drivers/net/wireless/iwlwifi/mvm/rx.c          |  6 +++---
 drivers/net/wireless/iwlwifi/mvm/sf.c          |  2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c          |  8 ++++++--
 drivers/net/wireless/iwlwifi/pcie/drv.c        |  7 +++++++
 net/mac80211/sta_info.c                        |  2 +-
 net/wireless/nl80211.c                         |  6 ++++++
 17 files changed, 74 insertions(+), 43 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/common-beacon.c b/drivers/net/w=
ireless/ath/ath9k/common-beacon.c
index 733be5178481..6ad44470d0f2 100644
--- a/drivers/net/wireless/ath/ath9k/common-beacon.c
+++ b/drivers/net/wireless/ath/ath9k/common-beacon.c
@@ -57,7 +57,7 @@ int ath9k_cmn_beacon_config_sta(struct ath_hw *ah,
 				 struct ath9k_beacon_state *bs)
 {
 	struct ath_common *common =3D ath9k_hw_common(ah);
-	int dtim_intval, sleepduration;
+	int dtim_intval;
 	u64 tsf;
=20
 	/* No need to configure beacon if we are not associated */
@@ -75,7 +75,6 @@ int ath9k_cmn_beacon_config_sta(struct ath_hw *ah,
 	 * last beacon we received (which may be none).
 	 */
 	dtim_intval =3D conf->intval * conf->dtim_period;
-	sleepduration =3D ah->hw->conf.listen_interval * conf->intval;
=20
 	/*
 	 * Pull nexttbtt forward to reflect the current
@@ -113,7 +112,7 @@ int ath9k_cmn_beacon_config_sta(struct ath_hw *ah,
 	 */
=20
 	bs->bs_sleepduration =3D TU_TO_USEC(roundup(IEEE80211_MS_TO_TU(100),
-						  sleepduration));
+						  conf->intval));
 	if (bs->bs_sleepduration > bs->bs_dtimperiod)
 		bs->bs_sleepduration =3D bs->bs_dtimperiod;
=20
diff --git a/drivers/net/wireless/iwlwifi/dvm/power.c b/drivers/net/wireles=
s/iwlwifi/dvm/power.c
index 760c45c34ef3..1513dbc79c14 100644
--- a/drivers/net/wireless/iwlwifi/dvm/power.c
+++ b/drivers/net/wireless/iwlwifi/dvm/power.c
@@ -40,7 +40,7 @@
 #include "commands.h"
 #include "power.h"
=20
-static bool force_cam;
+static bool force_cam =3D true;
 module_param(force_cam, bool, 0644);
 MODULE_PARM_DESC(force_cam, "force continuously aware mode (no power savin=
g at all)");
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-7000.c b/drivers/net/wireless=
/iwlwifi/iwl-7000.c
index d67a37a786aa..d53adc245497 100644
--- a/drivers/net/wireless/iwlwifi/iwl-7000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-7000.c
@@ -83,6 +83,8 @@
 #define IWL7260_TX_POWER_VERSION	0xffff /* meaningless */
 #define IWL3160_NVM_VERSION		0x709
 #define IWL3160_TX_POWER_VERSION	0xffff /* meaningless */
+#define IWL3165_NVM_VERSION		0x709
+#define IWL3165_TX_POWER_VERSION	0xffff /* meaningless */
 #define IWL7265_NVM_VERSION		0x0a1d
 #define IWL7265_TX_POWER_VERSION	0xffff /* meaningless */
=20
@@ -92,6 +94,9 @@
 #define IWL3160_FW_PRE "iwlwifi-3160-"
 #define IWL3160_MODULE_FIRMWARE(api) IWL3160_FW_PRE __stringify(api) ".uco=
de"
=20
+#define IWL3165_FW_PRE "iwlwifi-3165-"
+#define IWL3165_MODULE_FIRMWARE(api) IWL3165_FW_PRE __stringify(api) ".uco=
de"
+
 #define IWL7265_FW_PRE "iwlwifi-7265-"
 #define IWL7265_MODULE_FIRMWARE(api) IWL7265_FW_PRE __stringify(api) ".uco=
de"
=20
@@ -213,6 +218,16 @@ static const struct iwl_pwr_tx_backoff iwl7265_pwr_tx_=
backoffs[] =3D {
 	{0},
 };
=20
+const struct iwl_cfg iwl3165_2ac_cfg =3D {
+	.name =3D "Intel(R) Dual Band Wireless AC 3165",
+	.fw_name_pre =3D IWL3165_FW_PRE,
+	IWL_DEVICE_7000,
+	.ht_params =3D &iwl7000_ht_params,
+	.nvm_ver =3D IWL3165_NVM_VERSION,
+	.nvm_calib_ver =3D IWL3165_TX_POWER_VERSION,
+	.pwr_tx_backoffs =3D iwl7265_pwr_tx_backoffs,
+};
+
 const struct iwl_cfg iwl7265_2ac_cfg =3D {
 	.name =3D "Intel(R) Dual Band Wireless AC 7265",
 	.fw_name_pre =3D IWL7265_FW_PRE,
@@ -245,4 +260,5 @@ const struct iwl_cfg iwl7265_n_cfg =3D {
=20
 MODULE_FIRMWARE(IWL7260_MODULE_FIRMWARE(IWL7260_UCODE_API_OK));
 MODULE_FIRMWARE(IWL3160_MODULE_FIRMWARE(IWL3160_UCODE_API_OK));
+MODULE_FIRMWARE(IWL3165_MODULE_FIRMWARE(IWL3160_UCODE_API_OK));
 MODULE_FIRMWARE(IWL7265_MODULE_FIRMWARE(IWL7260_UCODE_API_OK));
diff --git a/drivers/net/wireless/iwlwifi/iwl-config.h b/drivers/net/wirele=
ss/iwlwifi/iwl-config.h
index 8da596db9abe..3d7cc37420ae 100644
--- a/drivers/net/wireless/iwlwifi/iwl-config.h
+++ b/drivers/net/wireless/iwlwifi/iwl-config.h
@@ -120,6 +120,8 @@ enum iwl_led_mode {
 #define IWL_LONG_WD_TIMEOUT	10000
 #define IWL_MAX_WD_TIMEOUT	120000
=20
+#define IWL_DEFAULT_MAX_TX_POWER 22
+
 /* Antenna presence definitions */
 #define	ANT_NONE	0x0
 #define	ANT_A		BIT(0)
@@ -335,6 +337,7 @@ extern const struct iwl_cfg iwl7260_n_cfg;
 extern const struct iwl_cfg iwl3160_2ac_cfg;
 extern const struct iwl_cfg iwl3160_2n_cfg;
 extern const struct iwl_cfg iwl3160_n_cfg;
+extern const struct iwl_cfg iwl3165_2ac_cfg;
 extern const struct iwl_cfg iwl7265_2ac_cfg;
 extern const struct iwl_cfg iwl7265_2n_cfg;
 extern const struct iwl_cfg iwl7265_n_cfg;
diff --git a/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c b/drivers/net/wir=
eless/iwlwifi/iwl-nvm-parse.c
index 018af2957d3b..354255f08754 100644
--- a/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c
+++ b/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c
@@ -146,8 +146,6 @@ static const u8 iwl_nvm_channels_family_8000[] =3D {
 #define LAST_2GHZ_HT_PLUS		9
 #define LAST_5GHZ_HT			161
=20
-#define DEFAULT_MAX_TX_POWER 16
-
 /* rate data (static) */
 static struct ieee80211_rate iwl_cfg80211_rates[] =3D {
 	{ .bitrate =3D 1 * 10, .hw_value =3D 0, .hw_value_short =3D 0, },
@@ -295,7 +293,7 @@ static int iwl_init_channel_map(struct device *dev, con=
st struct iwl_cfg *cfg,
 		 * Default value - highest tx power value.  max_power
 		 * is not used in mvm, and is used for backwards compatibility
 		 */
-		channel->max_power =3D DEFAULT_MAX_TX_POWER;
+		channel->max_power =3D IWL_DEFAULT_MAX_TX_POWER;
 		is_5ghz =3D channel->band =3D=3D IEEE80211_BAND_5GHZ;
 		IWL_DEBUG_EEPROM(dev,
 				 "Ch. %d [%sGHz] %s%s%s%s%s%s%s(0x%02x %ddBm): Ad-Hoc %ssupported\n",
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex.c b/drivers/net/wireless=
/iwlwifi/mvm/coex.c
index 2291bbcaaeab..ce71625f497f 100644
--- a/drivers/net/wireless/iwlwifi/mvm/coex.c
+++ b/drivers/net/wireless/iwlwifi/mvm/coex.c
@@ -585,8 +585,6 @@ int iwl_send_bt_init_conf(struct iwl_mvm *mvm)
 	lockdep_assert_held(&mvm->mutex);
=20
 	if (unlikely(mvm->bt_force_ant_mode !=3D BT_FORCE_ANT_DIS)) {
-		u32 mode;
-
 		switch (mvm->bt_force_ant_mode) {
 		case BT_FORCE_ANT_BT:
 			mode =3D BT_COEX_BT;
@@ -756,7 +754,8 @@ static void iwl_mvm_bt_notif_iterator(void *_data, u8 *=
mac,
 	struct iwl_bt_iterator_data *data =3D _data;
 	struct iwl_mvm *mvm =3D data->mvm;
 	struct ieee80211_chanctx_conf *chanctx_conf;
-	enum ieee80211_smps_mode smps_mode;
+	/* default smps_mode is AUTOMATIC - only used for client modes */
+	enum ieee80211_smps_mode smps_mode =3D IEEE80211_SMPS_AUTOMATIC;
 	u32 bt_activity_grading;
 	int ave_rssi;
=20
@@ -764,8 +763,6 @@ static void iwl_mvm_bt_notif_iterator(void *_data, u8 *=
mac,
=20
 	switch (vif->type) {
 	case NL80211_IFTYPE_STATION:
-		/* default smps_mode for BSS / P2P client is AUTOMATIC */
-		smps_mode =3D IEEE80211_SMPS_AUTOMATIC;
 		break;
 	case NL80211_IFTYPE_AP:
 		if (!mvmvif->ap_ibss_active)
@@ -797,7 +794,7 @@ static void iwl_mvm_bt_notif_iterator(void *_data, u8 *=
mac,
 	else if (bt_activity_grading >=3D BT_LOW_TRAFFIC)
 		smps_mode =3D IEEE80211_SMPS_DYNAMIC;
=20
-	/* relax SMPS contraints for next association */
+	/* relax SMPS constraints for next association */
 	if (!vif->bss_conf.assoc)
 		smps_mode =3D IEEE80211_SMPS_AUTOMATIC;
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c b/drivers/net/w=
ireless/iwlwifi/mvm/debugfs-vif.c
index 2e90ff795c13..87e517bffedc 100644
--- a/drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c
+++ b/drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c
@@ -74,8 +74,7 @@ static void iwl_dbgfs_update_pm(struct iwl_mvm *mvm,
=20
 	switch (param) {
 	case MVM_DEBUGFS_PM_KEEP_ALIVE: {
-		struct ieee80211_hw *hw =3D mvm->hw;
-		int dtimper =3D hw->conf.ps_dtim_period ?: 1;
+		int dtimper =3D vif->bss_conf.dtim_period ?: 1;
 		int dtimper_msec =3D dtimper * vif->bss_conf.beacon_int;
=20
 		IWL_DEBUG_POWER(mvm, "debugfs: set keep_alive=3D %d sec\n", val);
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api.h b/drivers/net/wirele=
ss/iwlwifi/mvm/fw-api.h
index 95f5b3274efb..9a922f3bd16b 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api.h
@@ -1563,14 +1563,14 @@ enum iwl_sf_scenario {
=20
 /**
  * Smart Fifo configuration command.
- * @state: smart fifo state, types listed in iwl_sf_sate.
+ * @state: smart fifo state, types listed in enum %iwl_sf_sate.
  * @watermark: Minimum allowed availabe free space in RXF for transient st=
ate.
  * @long_delay_timeouts: aging and idle timer values for each scenario
  * in long delay state.
  * @full_on_timeouts: timer values for each scenario in full on state.
  */
 struct iwl_sf_cfg_cmd {
-	enum iwl_sf_state state;
+	__le32 state;
 	__le32 watermark[SF_TRANSIENT_STATES_NUMBER];
 	__le32 long_delay_timeouts[SF_NUM_SCENARIO][SF_NUM_TIMEOUT_TYPES];
 	__le32 full_on_timeouts[SF_NUM_SCENARIO][SF_NUM_TIMEOUT_TYPES];
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c b/drivers/net/wire=
less/iwlwifi/mvm/mac-ctxt.c
index 0e523e28cabf..8242e689ddb1 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
@@ -721,11 +721,6 @@ static int iwl_mvm_mac_ctxt_cmd_sta(struct iwl_mvm *mv=
m,
 	    !force_assoc_off) {
 		u32 dtim_offs;
=20
-		/* Allow beacons to pass through as long as we are not
-		 * associated, or we do not have dtim period information.
-		 */
-		cmd.filter_flags |=3D cpu_to_le32(MAC_FILTER_IN_BEACON);
-
 		/*
 		 * The DTIM count counts down, so when it is N that means N
 		 * more beacon intervals happen until the DTIM TBTT. Therefore
@@ -759,6 +754,11 @@ static int iwl_mvm_mac_ctxt_cmd_sta(struct iwl_mvm *mv=
m,
 		ctxt_sta->is_assoc =3D cpu_to_le32(1);
 	} else {
 		ctxt_sta->is_assoc =3D cpu_to_le32(0);
+
+		/* Allow beacons to pass through as long as we are not
+		 * associated, or we do not have dtim period information.
+		 */
+		cmd.filter_flags |=3D cpu_to_le32(MAC_FILTER_IN_BEACON);
 	}
=20
 	ctxt_sta->bi =3D cpu_to_le32(vif->bss_conf.beacon_int);
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 7c8796584c25..cdc272d776e7 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -396,12 +396,14 @@ int iwl_mvm_mac_setup_register(struct iwl_mvm *mvm)
 	else
 		hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
=20
-	/* TODO: enable that only for firmwares that don't crash */
-	/* hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_SCHED_SCAN; */
-	hw->wiphy->max_sched_scan_ssids =3D PROBE_OPTION_MAX;
-	hw->wiphy->max_match_sets =3D IWL_SCAN_MAX_PROFILES;
-	/* we create the 802.11 header and zero length SSID IE. */
-	hw->wiphy->max_sched_scan_ie_len =3D SCAN_OFFLOAD_PROBE_REQ_SIZE - 24 - 2;
+	if (IWL_UCODE_API(mvm->fw->ucode_ver) >=3D 10) {
+		hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_SCHED_SCAN;
+		hw->wiphy->max_sched_scan_ssids =3D PROBE_OPTION_MAX;
+		hw->wiphy->max_match_sets =3D IWL_SCAN_MAX_PROFILES;
+		/* we create the 802.11 header and zero length SSID IE. */
+		hw->wiphy->max_sched_scan_ie_len =3D
+			SCAN_OFFLOAD_PROBE_REQ_SIZE - 24 - 2;
+	}
=20
 	hw->wiphy->features |=3D NL80211_FEATURE_P2P_GO_CTWIN |
 			       NL80211_FEATURE_LOW_PRIORITY_SCAN |
@@ -1524,11 +1526,6 @@ static void iwl_mvm_bss_info_changed_station(struct =
iwl_mvm *mvm,
 		 */
 		iwl_mvm_remove_time_event(mvm, mvmvif,
 					  &mvmvif->time_event_data);
-	} else if (changes & (BSS_CHANGED_PS | BSS_CHANGED_P2P_PS |
-			      BSS_CHANGED_QOS)) {
-		ret =3D iwl_mvm_power_update_mac(mvm);
-		if (ret)
-			IWL_ERR(mvm, "failed to update power mode\n");
 	}
=20
 	if (changes & BSS_CHANGED_BEACON_INFO) {
@@ -1536,6 +1533,12 @@ static void iwl_mvm_bss_info_changed_station(struct =
iwl_mvm *mvm,
 		WARN_ON(iwl_mvm_enable_beacon_filter(mvm, vif, 0));
 	}
=20
+	if (changes & (BSS_CHANGED_PS | BSS_CHANGED_P2P_PS | BSS_CHANGED_QOS)) {
+		ret =3D iwl_mvm_power_update_mac(mvm);
+		if (ret)
+			IWL_ERR(mvm, "failed to update power mode\n");
+	}
+
 	if (changes & BSS_CHANGED_TXPOWER) {
 		IWL_DEBUG_CALIB(mvm, "Changing TX Power to %d\n",
 				bss_conf->txpower);
diff --git a/drivers/net/wireless/iwlwifi/mvm/power.c b/drivers/net/wireles=
s/iwlwifi/mvm/power.c
index 2b2d10800a55..d9769a23c68b 100644
--- a/drivers/net/wireless/iwlwifi/mvm/power.c
+++ b/drivers/net/wireless/iwlwifi/mvm/power.c
@@ -281,7 +281,6 @@ static void iwl_mvm_power_build_cmd(struct iwl_mvm *mvm,
 				    struct ieee80211_vif *vif,
 				    struct iwl_mac_power_cmd *cmd)
 {
-	struct ieee80211_hw *hw =3D mvm->hw;
 	struct ieee80211_chanctx_conf *chanctx_conf;
 	struct ieee80211_channel *chan;
 	int dtimper, dtimper_msec;
@@ -292,7 +291,7 @@ static void iwl_mvm_power_build_cmd(struct iwl_mvm *mvm,
=20
 	cmd->id_and_color =3D cpu_to_le32(FW_CMD_ID_AND_COLOR(mvmvif->id,
 							    mvmvif->color));
-	dtimper =3D hw->conf.ps_dtim_period ?: 1;
+	dtimper =3D vif->bss_conf.dtim_period;
=20
 	/*
 	 * Regardless of power management state the driver must set
@@ -885,7 +884,7 @@ int iwl_mvm_update_d0i3_power_mode(struct iwl_mvm *mvm,
 	iwl_mvm_power_build_cmd(mvm, vif, &cmd);
 	if (enable) {
 		/* configure skip over dtim up to 300 msec */
-		int dtimper =3D mvm->hw->conf.ps_dtim_period ?: 1;
+		int dtimper =3D vif->bss_conf.dtim_period ?: 1;
 		int dtimper_msec =3D dtimper * vif->bss_conf.beacon_int;
=20
 		if (WARN_ON(!dtimper_msec))
diff --git a/drivers/net/wireless/iwlwifi/mvm/rx.c b/drivers/net/wireless/i=
wlwifi/mvm/rx.c
index 4b98987fc413..bf5cd8c8b0f7 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rx.c
@@ -149,13 +149,13 @@ static void iwl_mvm_get_signal_strength(struct iwl_mv=
m *mvm,
 	    le32_to_cpu(phy_info->non_cfg_phy[IWL_RX_INFO_ENERGY_ANT_ABC_IDX]);
 	energy_a =3D (val & IWL_RX_INFO_ENERGY_ANT_A_MSK) >>
 						IWL_RX_INFO_ENERGY_ANT_A_POS;
-	energy_a =3D energy_a ? -energy_a : -256;
+	energy_a =3D energy_a ? -energy_a : S8_MIN;
 	energy_b =3D (val & IWL_RX_INFO_ENERGY_ANT_B_MSK) >>
 						IWL_RX_INFO_ENERGY_ANT_B_POS;
-	energy_b =3D energy_b ? -energy_b : -256;
+	energy_b =3D energy_b ? -energy_b : S8_MIN;
 	energy_c =3D (val & IWL_RX_INFO_ENERGY_ANT_C_MSK) >>
 						IWL_RX_INFO_ENERGY_ANT_C_POS;
-	energy_c =3D energy_c ? -energy_c : -256;
+	energy_c =3D energy_c ? -energy_c : S8_MIN;
 	max_energy =3D max(energy_a, energy_b);
 	max_energy =3D max(max_energy, energy_c);
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/sf.c b/drivers/net/wireless/i=
wlwifi/mvm/sf.c
index 7edfd15efc9d..e843b67f2201 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sf.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sf.c
@@ -172,7 +172,7 @@ static int iwl_mvm_sf_config(struct iwl_mvm *mvm, u8 st=
a_id,
 			     enum iwl_sf_state new_state)
 {
 	struct iwl_sf_cfg_cmd sf_cmd =3D {
-		.state =3D new_state,
+		.state =3D cpu_to_le32(new_state),
 	};
 	struct ieee80211_sta *sta;
 	int ret =3D 0;
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index dbc870713882..9ee410bf6da2 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -168,10 +168,14 @@ static void iwl_mvm_set_tx_cmd_rate(struct iwl_mvm *m=
vm,
=20
 	/*
 	 * for data packets, rate info comes from the table inside the fw. This
-	 * table is controlled by LINK_QUALITY commands
+	 * table is controlled by LINK_QUALITY commands. Exclude ctrl port
+	 * frames like EAPOLs which should be treated as mgmt frames. This
+	 * avoids them being sent initially in high rates which increases the
+	 * chances for completion of the 4-Way handshake.
 	 */
=20
-	if (ieee80211_is_data(fc) && sta) {
+	if (ieee80211_is_data(fc) && sta &&
+	    !(info->control.flags & IEEE80211_TX_CTRL_PORT_CTRL_PROTO)) {
 		tx_cmd->initial_rate_index =3D 0;
 		tx_cmd->tx_flags |=3D cpu_to_le32(TX_CMD_FLG_STA_RATE);
 		return;
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index f0e722ced080..073a68b97a72 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -352,11 +352,17 @@ static const struct pci_device_id iwl_hw_card_ids[] =
=3D {
 	{IWL_PCI_DEVICE(0x08B3, 0x8060, iwl3160_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8062, iwl3160_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B4, 0x8270, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B4, 0x8370, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B4, 0x8272, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8470, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8570, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x1070, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x1170, iwl3160_2ac_cfg)},
=20
+/* 3165 Series */
+	{IWL_PCI_DEVICE(0x3165, 0x4010, iwl3165_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x3165, 0x4210, iwl3165_2ac_cfg)},
+
 /* 7265 Series */
 	{IWL_PCI_DEVICE(0x095A, 0x5010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5110, iwl7265_2ac_cfg)},
@@ -378,6 +384,7 @@ static const struct pci_device_id iwl_hw_card_ids[] =3D=
 {
 	{IWL_PCI_DEVICE(0x095B, 0x5202, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9012, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x900A, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9110, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9112, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9210, iwl7265_2ac_cfg)},
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 441875f03750..a1e433b88c66 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1822,7 +1822,7 @@ void sta_set_sinfo(struct sta_info *sta, struct stati=
on_info *sinfo)
 		sinfo->bss_param.flags |=3D BSS_PARAM_FLAGS_SHORT_PREAMBLE;
 	if (sdata->vif.bss_conf.use_short_slot)
 		sinfo->bss_param.flags |=3D BSS_PARAM_FLAGS_SHORT_SLOT_TIME;
-	sinfo->bss_param.dtim_period =3D sdata->local->hw.conf.ps_dtim_period;
+	sinfo->bss_param.dtim_period =3D sdata->vif.bss_conf.dtim_period;
 	sinfo->bss_param.beacon_interval =3D sdata->vif.bss_conf.beacon_int;
=20
 	sinfo->sta_flags.set =3D 0;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index df7b1332a1ec..7257164af91b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -6969,6 +6969,9 @@ void __cfg80211_send_event_skb(struct sk_buff *skb, g=
fp_t gfp)
 	struct nlattr *data =3D ((void **)skb->cb)[2];
 	enum nl80211_multicast_groups mcgrp =3D NL80211_MCGRP_TESTMODE;
=20
+	/* clear CB data for netlink core to own from now on */
+	memset(skb->cb, 0, sizeof(skb->cb));
+
 	nla_nest_end(skb, data);
 	genlmsg_end(skb, hdr);
=20
@@ -9294,6 +9297,9 @@ int cfg80211_vendor_cmd_reply(struct sk_buff *skb)
 	void *hdr =3D ((void **)skb->cb)[1];
 	struct nlattr *data =3D ((void **)skb->cb)[2];
=20
+	/* clear CB data for netlink core to own from now on */
+	memset(skb->cb, 0, sizeof(skb->cb));
+
 	if (WARN_ON(!rdev->cur_cmd_info)) {
 		kfree_skb(skb);
 		return -EINVAL;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--DocE+STaALJfprDB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUEe1KAAoJEJctW/TcYTgGopQP/i0vSUhcXdilmEEfehNoEpwQ
ObFlJztMyDRmFAk+28cpexeIszVRlaHwnCVgSoHHYLawbZ0nHc0V8Og3jbJUDIol
pPmYltYWDR1esxTUiZGVPJwLozO8p1joUz2LPJLd3xiylT4eKOTeDAFJWGriKXN6
GR7SKyPieVb3NQ0DSCyBUKlQ1C1K63Fakh9hmoJuQojFqbXAZwgvnxTHqgVCenRI
HYR4hOKrRVY2lpaFDtNSK6NJXJhfv3c8x1oYuSirUcpeeRtHyC3TifmwKTwTU2Jd
Mp3Y4maB5ZJLybG17w2nF0v9trxGvUBMvGcbTsVaEZIUfhxGC0TFjHMXurUd9FIk
WInzaE+EdrJWD78fvvkPCa/SH6rrwt0GTS3aCKjQ4n271gY6lKg3sp7xmjdN4x7C
iFDBWuP8wZor22t6nsrDST/ttfEf1DnM1XffHC7D5yaWyu5CwworIP60QiiWYuVo
V3nNOKyHugwOrB+obCOByUxv/WAWkuhrPpmScPfUu0jUytECEf5wzNIB0MxH++li
jlGSKPeTrVaLggGZx4kXMomPjnD5YEgsJWA7hItG0RDMbBryw6XW0Tw9RGH8tgup
+d8j6kY2/P7x8RiR3PiDBAHQ2IF3YSdjFzZhuknnr00+wE6kcTjXJznkKe9jWkRl
C9MKBgNZHxkD5D8Biaoo
=mCXA
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--
