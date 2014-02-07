From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-02-07
Date: Fri, 7 Feb 2014 14:12:22 -0500
Message-ID: <20140207191222.GH3181@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.14 stream!

For the mac80211 bits, Johannes says:

"This is just a collection of small fixes, the commit logs explain the
details. The only thing that isn't strictly a fix is the 5/10 MHz
enabling, I had forgotten this and there's little point in waiting
longer. The patch simply removes the force-disable code that I put in
when there was a problem with the userspace API (that has long been
fixed.)"

For the iwlwifi bits, Emmanuel says:

"I have an important fix that disables A band in case the driver thought
it was enabled, and the firmware disagreed. We ended up making the
firmware unhappy. I also fix the station table in AP mode and fix the
scan while we have BT working.
Johannes removes a static variable that could potentially lead to to
issues on multi-device setups and disables scheduled scan to avoid
issues with old versions of wpa_supplicant.
A small fix from David on scan and a few new device IDs for 7265."

On top of that...

Oleksij Rempel adds a USB ID to the ar5523 driver and changes the
default powersave setting for ath9k_htc to "off", due to observed
stability issues (based on an equivalent ath9k patch).

Stanislaw Gruszka similarly disables powersave for a couple of rt2x00
drivers.  He also fixes a couple of scheduling while atomic issues
in ath9k_htc.

Sujith Manoharan rounds-out the powersave disables with one for ath9k.
He also fixes a build prolem with ath9k on ARM and fixes an ath9k Tx
power calculation.

Finally, Andrea Merello fixes a couple of lingering DMA mapping
problems in the rtl8180 driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ee262ad827f89e2dc7851ec2986953b5b125c6bc:

  inet: defines IPPROTO_* needed for module alias generation (2014-02-06 21=
:18:06 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 0f96b860bc5e97d4776d0cb375c7ca1f4864f9e9:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-02-07 13:44:14 -0500)

----------------------------------------------------------------

David Spinadel (1):
      iwlwifi: mvm: notify match found without filtering

Eliad Peller (1):
      mac80211: move roc cookie assignment earlier

Emmanuel Grumbach (6):
      iwlwifi: mvm: print the version of the firmware when it asserts
      iwlwifi: mvm: don't leak a station when we drain
      iwlwifi: mvm: BT Coex - disable BT when TXing probe request in scan
      iwlwifi: mvm: don't allow A band if SKU forbids it
      mac80211: avoid deadlock revealed by lockdep
      mac80211: release the channel in error path in start_ap

Johannes Berg (7):
      iwlwifi: mvm: make local pointer non-static
      iwlwifi: mvm: disable scheduled scan
      cfg80211: re-enable 5/10 MHz support
      cfg80211: fix scan done race
      cfg80211: send scan results from work queue
      mac80211: fix fragmentation code, particularly for encryption
      mac80211: fix virtual monitor interface iteration

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Oleksij Rempel (2):
      ath9k_htc: Do not support PowerSave by default
      ar5523: fix usb id for Gigaset.

Oren Givon (1):
      iwlwifi: add more 7265 HW IDs

Pontus Fuchs (1):
      nl80211: Reset split_start when netlink skb is exhausted

Stanislaw Gruszka (4):
      ath9k_htc: make ->sta_rc_update atomic for most calls
      rt2800: disable PS by default on USB
      rt2500: disable PS by default
      ath9k_htc: avoid scheduling while atomic on sta_rc_update

Sujith Manoharan (4):
      ath9k: Fix build error on ARM
      ath9k: Do not support PowerSave by default
      ath9k: Fix TX power calculation
      mac80211: Fix IBSS disconnect

andrea.merello (2):
      rtl8180: Add error check for pci_map_single return value in RX path
      rtl8180: Add error check for pci_map_single return value in TX path

 drivers/net/wireless/ath/ar5523/ar5523.c       |  2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |  4 ++
 drivers/net/wireless/ath/ath9k/htc.h           |  2 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c  |  8 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  | 63 ++++++++++++++--------
 drivers/net/wireless/ath/ath9k/hw.c            |  5 +-
 drivers/net/wireless/ath/ath9k/init.c          |  8 ++-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c   |  5 ++
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h |  4 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c    |  2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c        |  5 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c         |  2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c          | 73 +++++++++++++---------=
----
 drivers/net/wireless/iwlwifi/mvm/utils.c       |  2 +
 drivers/net/wireless/iwlwifi/pcie/drv.c        |  7 ++-
 drivers/net/wireless/rt2x00/rt2500pci.c        |  5 ++
 drivers/net/wireless/rt2x00/rt2500usb.c        |  5 ++
 drivers/net/wireless/rt2x00/rt2800lib.c        |  5 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c     | 23 ++++++--
 net/mac80211/cfg.c                             | 44 ++++++++--------
 net/mac80211/ht.c                              |  4 +-
 net/mac80211/ibss.c                            |  5 +-
 net/mac80211/iface.c                           | 27 +++++++---
 net/mac80211/tx.c                              |  2 +-
 net/wireless/core.c                            | 17 +++---
 net/wireless/core.h                            |  4 +-
 net/wireless/nl80211.c                         | 32 +++++------
 net/wireless/nl80211.h                         |  8 +--
 net/wireless/scan.c                            | 40 ++++++++------
 net/wireless/sme.c                             |  2 +-
 30 files changed, 256 insertions(+), 159 deletions(-)

diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireles=
s/ath/ar5523/ar5523.c
index 8aa20df55e50..507d9a9ee69a 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -1764,7 +1764,7 @@ static struct usb_device_id ar5523_id_table[] =3D {
 	AR5523_DEVICE_UG(0x07d1, 0x3a07),	/* D-Link / WUA-2340 rev A1 */
 	AR5523_DEVICE_UG(0x1690, 0x0712),	/* Gigaset / AR5523 */
 	AR5523_DEVICE_UG(0x1690, 0x0710),	/* Gigaset / SMCWUSBTG */
-	AR5523_DEVICE_UG(0x129b, 0x160c),	/* Gigaset / USB stick 108
+	AR5523_DEVICE_UG(0x129b, 0x160b),	/* Gigaset / USB stick 108
 						   (CyberTAN Technology) */
 	AR5523_DEVICE_UG(0x16ab, 0x7801),	/* Globalsun / AR5523_1 */
 	AR5523_DEVICE_UX(0x16ab, 0x7811),	/* Globalsun / AR5523_2 */
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/w=
ireless/ath/ath9k/ar9003_eeprom.c
index 25243cbc07f0..b8daff78b9d1 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -5065,6 +5065,10 @@ static u16 ar9003_hw_get_max_edge_power(struct ar930=
0_eeprom *eep,
 			break;
 		}
 	}
+
+	if (is2GHz && !twiceMaxEdgePower)
+		twiceMaxEdgePower =3D 60;
+
 	return twiceMaxEdgePower;
 }
=20
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/at=
h/ath9k/htc.h
index 58da3468d1f0..99a203174f45 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -262,6 +262,8 @@ enum tid_aggr_state {
 struct ath9k_htc_sta {
 	u8 index;
 	enum tid_aggr_state tid_state[ATH9K_HTC_MAX_TID];
+	struct work_struct rc_update_work;
+	struct ath9k_htc_priv *htc_priv;
 };
=20
 #define ATH9K_HTC_RXBUF 256
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_init.c
index f4e1de20d99c..c57d6b859c04 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -34,6 +34,10 @@ static int ath9k_htc_btcoex_enable;
 module_param_named(btcoex_enable, ath9k_htc_btcoex_enable, int, 0444);
 MODULE_PARM_DESC(btcoex_enable, "Enable wifi-BT coexistence");
=20
+static int ath9k_ps_enable;
+module_param_named(ps_enable, ath9k_ps_enable, int, 0444);
+MODULE_PARM_DESC(ps_enable, "Enable WLAN PowerSave");
+
 #define CHAN2G(_freq, _idx)  { \
 	.center_freq =3D (_freq), \
 	.hw_value =3D (_idx), \
@@ -725,12 +729,14 @@ static void ath9k_set_hw_capab(struct ath9k_htc_priv =
*priv,
 		IEEE80211_HW_SPECTRUM_MGMT |
 		IEEE80211_HW_HAS_RATE_CONTROL |
 		IEEE80211_HW_RX_INCLUDES_FCS |
-		IEEE80211_HW_SUPPORTS_PS |
 		IEEE80211_HW_PS_NULLFUNC_STACK |
 		IEEE80211_HW_REPORTS_TX_ACK_STATUS |
 		IEEE80211_HW_MFP_CAPABLE |
 		IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING;
=20
+	if (ath9k_ps_enable)
+		hw->flags |=3D IEEE80211_HW_SUPPORTS_PS;
+
 	hw->wiphy->interface_modes =3D
 		BIT(NL80211_IFTYPE_STATION) |
 		BIT(NL80211_IFTYPE_ADHOC) |
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_main.c
index 608d739d1378..c9254a61ca52 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -1270,18 +1270,50 @@ static void ath9k_htc_configure_filter(struct ieee8=
0211_hw *hw,
 	mutex_unlock(&priv->mutex);
 }
=20
+static void ath9k_htc_sta_rc_update_work(struct work_struct *work)
+{
+	struct ath9k_htc_sta *ista =3D
+	    container_of(work, struct ath9k_htc_sta, rc_update_work);
+	struct ieee80211_sta *sta =3D
+	    container_of((void *)ista, struct ieee80211_sta, drv_priv);
+	struct ath9k_htc_priv *priv =3D ista->htc_priv;
+	struct ath_common *common =3D ath9k_hw_common(priv->ah);
+	struct ath9k_htc_target_rate trate;
+
+	mutex_lock(&priv->mutex);
+	ath9k_htc_ps_wakeup(priv);
+
+	memset(&trate, 0, sizeof(struct ath9k_htc_target_rate));
+	ath9k_htc_setup_rate(priv, sta, &trate);
+	if (!ath9k_htc_send_rate_cmd(priv, &trate))
+		ath_dbg(common, CONFIG,
+			"Supported rates for sta: %pM updated, rate caps: 0x%X\n",
+			sta->addr, be32_to_cpu(trate.capflags));
+	else
+		ath_dbg(common, CONFIG,
+			"Unable to update supported rates for sta: %pM\n",
+			sta->addr);
+
+	ath9k_htc_ps_restore(priv);
+	mutex_unlock(&priv->mutex);
+}
+
 static int ath9k_htc_sta_add(struct ieee80211_hw *hw,
 			     struct ieee80211_vif *vif,
 			     struct ieee80211_sta *sta)
 {
 	struct ath9k_htc_priv *priv =3D hw->priv;
+	struct ath9k_htc_sta *ista =3D (struct ath9k_htc_sta *) sta->drv_priv;
 	int ret;
=20
 	mutex_lock(&priv->mutex);
 	ath9k_htc_ps_wakeup(priv);
 	ret =3D ath9k_htc_add_station(priv, vif, sta);
-	if (!ret)
+	if (!ret) {
+		INIT_WORK(&ista->rc_update_work, ath9k_htc_sta_rc_update_work);
+		ista->htc_priv =3D priv;
 		ath9k_htc_init_rate(priv, sta);
+	}
 	ath9k_htc_ps_restore(priv);
 	mutex_unlock(&priv->mutex);
=20
@@ -1293,12 +1325,13 @@ static int ath9k_htc_sta_remove(struct ieee80211_hw=
 *hw,
 				struct ieee80211_sta *sta)
 {
 	struct ath9k_htc_priv *priv =3D hw->priv;
-	struct ath9k_htc_sta *ista;
+	struct ath9k_htc_sta *ista =3D (struct ath9k_htc_sta *) sta->drv_priv;
 	int ret;
=20
+	cancel_work_sync(&ista->rc_update_work);
+
 	mutex_lock(&priv->mutex);
 	ath9k_htc_ps_wakeup(priv);
-	ista =3D (struct ath9k_htc_sta *) sta->drv_priv;
 	htc_sta_drain(priv->htc, ista->index);
 	ret =3D ath9k_htc_remove_station(priv, vif, sta);
 	ath9k_htc_ps_restore(priv);
@@ -1311,28 +1344,12 @@ static void ath9k_htc_sta_rc_update(struct ieee8021=
1_hw *hw,
 				    struct ieee80211_vif *vif,
 				    struct ieee80211_sta *sta, u32 changed)
 {
-	struct ath9k_htc_priv *priv =3D hw->priv;
-	struct ath_common *common =3D ath9k_hw_common(priv->ah);
-	struct ath9k_htc_target_rate trate;
-
-	mutex_lock(&priv->mutex);
-	ath9k_htc_ps_wakeup(priv);
+	struct ath9k_htc_sta *ista =3D (struct ath9k_htc_sta *) sta->drv_priv;
=20
-	if (changed & IEEE80211_RC_SUPP_RATES_CHANGED) {
-		memset(&trate, 0, sizeof(struct ath9k_htc_target_rate));
-		ath9k_htc_setup_rate(priv, sta, &trate);
-		if (!ath9k_htc_send_rate_cmd(priv, &trate))
-			ath_dbg(common, CONFIG,
-				"Supported rates for sta: %pM updated, rate caps: 0x%X\n",
-				sta->addr, be32_to_cpu(trate.capflags));
-		else
-			ath_dbg(common, CONFIG,
-				"Unable to update supported rates for sta: %pM\n",
-				sta->addr);
-	}
+	if (!(changed & IEEE80211_RC_SUPP_RATES_CHANGED))
+		return;
=20
-	ath9k_htc_ps_restore(priv);
-	mutex_unlock(&priv->mutex);
+	schedule_work(&ista->rc_update_work);
 }
=20
 static int ath9k_htc_conf_tx(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index fbf43c05713f..11eab9f01fd8 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1316,7 +1316,7 @@ static bool ath9k_hw_set_reset(struct ath_hw *ah, int=
 type)
 	if (AR_SREV_9300_20_OR_LATER(ah))
 		udelay(50);
 	else if (AR_SREV_9100(ah))
-		udelay(10000);
+		mdelay(10);
 	else
 		udelay(100);
=20
@@ -2051,9 +2051,8 @@ static bool ath9k_hw_set_power_awake(struct ath_hw *a=
h)
=20
 	REG_SET_BIT(ah, AR_RTC_FORCE_WAKE,
 		    AR_RTC_FORCE_WAKE_EN);
-
 	if (AR_SREV_9100(ah))
-		udelay(10000);
+		mdelay(10);
 	else
 		udelay(50);
=20
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index c36de303c8f3..1fc2e5a26b52 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -57,6 +57,10 @@ static int ath9k_bt_ant_diversity;
 module_param_named(bt_ant_diversity, ath9k_bt_ant_diversity, int, 0444);
 MODULE_PARM_DESC(bt_ant_diversity, "Enable WLAN/BT RX antenna diversity");
=20
+static int ath9k_ps_enable;
+module_param_named(ps_enable, ath9k_ps_enable, int, 0444);
+MODULE_PARM_DESC(ps_enable, "Enable WLAN PowerSave");
+
 bool is_ath9k_unloaded;
 /* We use the hw_value as an index into our private channel structure */
=20
@@ -903,13 +907,15 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, =
struct ieee80211_hw *hw)
 	hw->flags =3D IEEE80211_HW_RX_INCLUDES_FCS |
 		IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
 		IEEE80211_HW_SIGNAL_DBM |
-		IEEE80211_HW_SUPPORTS_PS |
 		IEEE80211_HW_PS_NULLFUNC_STACK |
 		IEEE80211_HW_SPECTRUM_MGMT |
 		IEEE80211_HW_REPORTS_TX_ACK_STATUS |
 		IEEE80211_HW_SUPPORTS_RC_TABLE |
 		IEEE80211_HW_SUPPORTS_HT_CCK_RATES;
=20
+	if (ath9k_ps_enable)
+		hw->flags |=3D IEEE80211_HW_SUPPORTS_PS;
+
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT) {
 		hw->flags |=3D IEEE80211_HW_AMPDU_AGGREGATION;
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c b/drivers/net/wir=
eless/iwlwifi/iwl-nvm-parse.c
index f06f4cbe1317..725e954d8475 100644
--- a/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c
+++ b/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c
@@ -182,6 +182,11 @@ static int iwl_init_channel_map(struct device *dev, co=
nst struct iwl_cfg *cfg,
=20
 	for (ch_idx =3D 0; ch_idx < IWL_NUM_CHANNELS; ch_idx++) {
 		ch_flags =3D __le16_to_cpup(nvm_ch_flags + ch_idx);
+
+		if (ch_idx >=3D NUM_2GHZ_CHANNELS &&
+		    !data->sku_cap_band_52GHz_enable)
+			ch_flags &=3D ~NVM_CHANNEL_VALID;
+
 		if (!(ch_flags & NVM_CHANNEL_VALID)) {
 			IWL_DEBUG_EEPROM(dev,
 					 "Ch. %d Flags %x [%sGHz] - No traffic\n",
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h b/drivers/net/w=
ireless/iwlwifi/mvm/fw-api-scan.h
index 73cbba7424f2..9426905de6b2 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
@@ -504,6 +504,7 @@ struct iwl_scan_offload_profile {
  * @match_notify:	clients waiting for match found notification
  * @pass_match:		clients waiting for the results
  * @active_clients:	active clients bitmap - enum scan_framework_client
+ * @any_beacon_notify:	clients waiting for match notification without match
  */
 struct iwl_scan_offload_profile_cfg {
 	struct iwl_scan_offload_profile profiles[IWL_SCAN_MAX_PROFILES];
@@ -512,7 +513,8 @@ struct iwl_scan_offload_profile_cfg {
 	u8 match_notify;
 	u8 pass_match;
 	u8 active_clients;
-	u8 reserved[3];
+	u8 any_beacon_notify;
+	u8 reserved[2];
 } __packed;
=20
 /**
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index c49b5073c251..6bf9766e5982 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -246,7 +246,7 @@ int iwl_mvm_mac_setup_register(struct iwl_mvm *mvm)
 	else
 		hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
=20
-	if (mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_SCHED_SCAN) {
+	if (0 && mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_SCHED_SCAN) {
 		hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_SCHED_SCAN;
 		hw->wiphy->max_sched_scan_ssids =3D PROBE_OPTION_MAX;
 		hw->wiphy->max_match_sets =3D IWL_SCAN_MAX_PROFILES;
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index 0e0007960612..742afc429c94 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -344,7 +344,8 @@ int iwl_mvm_scan_request(struct iwl_mvm *mvm,
=20
 	iwl_mvm_scan_fill_ssids(cmd, req, basic_ssid ? 1 : 0);
=20
-	cmd->tx_cmd.tx_flags =3D cpu_to_le32(TX_CMD_FLG_SEQ_CTL);
+	cmd->tx_cmd.tx_flags =3D cpu_to_le32(TX_CMD_FLG_SEQ_CTL |
+					   TX_CMD_FLG_BT_DIS);
 	cmd->tx_cmd.sta_id =3D mvm->aux_sta.sta_id;
 	cmd->tx_cmd.life_time =3D cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
 	cmd->tx_cmd.rate_n_flags =3D
@@ -807,6 +808,8 @@ int iwl_mvm_config_sched_scan_profiles(struct iwl_mvm *=
mvm,
 	profile_cfg->active_clients =3D SCAN_CLIENT_SCHED_SCAN;
 	profile_cfg->pass_match =3D SCAN_CLIENT_SCHED_SCAN;
 	profile_cfg->match_notify =3D SCAN_CLIENT_SCHED_SCAN;
+	if (!req->n_match_sets || !req->match_sets[0].ssid.ssid_len)
+		profile_cfg->any_beacon_notify =3D SCAN_CLIENT_SCHED_SCAN;
=20
 	for (i =3D 0; i < req->n_match_sets; i++) {
 		profile =3D &profile_cfg->profiles[i];
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/=
iwlwifi/mvm/sta.c
index ec1812133235..3397f59cd4e4 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -652,7 +652,7 @@ int iwl_mvm_send_bcast_sta(struct iwl_mvm *mvm, struct =
ieee80211_vif *vif,
 {
 	struct iwl_mvm_vif *mvmvif =3D iwl_mvm_vif_from_mac80211(vif);
 	static const u8 _baddr[] =3D {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
-	static const u8 *baddr =3D _baddr;
+	const u8 *baddr =3D _baddr;
=20
 	lockdep_assert_held(&mvm->mutex);
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index 90378c217bc7..4df12fa9d336 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -659,8 +659,14 @@ static void iwl_mvm_rx_tx_cmd_single(struct iwl_mvm *m=
vm,
 	rcu_read_lock();
=20
 	sta =3D rcu_dereference(mvm->fw_id_to_mac_id[sta_id]);
+	/*
+	 * sta can't be NULL otherwise it'd mean that the sta has been freed in
+	 * the firmware while we still have packets for it in the Tx queues.
+	 */
+	if (WARN_ON_ONCE(!sta))
+		goto out;
=20
-	if (!IS_ERR_OR_NULL(sta)) {
+	if (!IS_ERR(sta)) {
 		mvmsta =3D iwl_mvm_sta_from_mac80211(sta);
=20
 		if (tid !=3D IWL_TID_NON_QOS) {
@@ -675,7 +681,6 @@ static void iwl_mvm_rx_tx_cmd_single(struct iwl_mvm *mv=
m,
 			spin_unlock_bh(&mvmsta->lock);
 		}
 	} else {
-		sta =3D NULL;
 		mvmsta =3D NULL;
 	}
=20
@@ -683,42 +688,38 @@ static void iwl_mvm_rx_tx_cmd_single(struct iwl_mvm *=
mvm,
 	 * If the txq is not an AMPDU queue, there is no chance we freed
 	 * several skbs. Check that out...
 	 */
-	if (txq_id < mvm->first_agg_queue && !WARN_ON(skb_freed > 1) &&
-	    atomic_sub_and_test(skb_freed, &mvm->pending_frames[sta_id])) {
-		if (mvmsta) {
-			/*
-			 * If there are no pending frames for this STA, notify
-			 * mac80211 that this station can go to sleep in its
-			 * STA table.
-			 */
-			if (mvmsta->vif->type =3D=3D NL80211_IFTYPE_AP)
-				ieee80211_sta_block_awake(mvm->hw, sta, false);
-			/*
-			 * We might very well have taken mvmsta pointer while
-			 * the station was being removed. The remove flow might
-			 * have seen a pending_frame (because we didn't take
-			 * the lock) even if now the queues are drained. So make
-			 * really sure now that this the station is not being
-			 * removed. If it is, run the drain worker to remove it.
-			 */
-			spin_lock_bh(&mvmsta->lock);
-			sta =3D rcu_dereference(mvm->fw_id_to_mac_id[sta_id]);
-			if (!sta || PTR_ERR(sta) =3D=3D -EBUSY) {
-				/*
-				 * Station disappeared in the meantime:
-				 * so we are draining.
-				 */
-				set_bit(sta_id, mvm->sta_drained);
-				schedule_work(&mvm->sta_drained_wk);
-			}
-			spin_unlock_bh(&mvmsta->lock);
-		} else if (!mvmsta && PTR_ERR(sta) =3D=3D -EBUSY) {
-			/* Tx response without STA, so we are draining */
-			set_bit(sta_id, mvm->sta_drained);
-			schedule_work(&mvm->sta_drained_wk);
-		}
+	if (txq_id >=3D mvm->first_agg_queue)
+		goto out;
+
+	/* We can't free more than one frame at once on a shared queue */
+	WARN_ON(skb_freed > 1);
+
+	/* If we have still frames from this STA nothing to do here */
+	if (!atomic_sub_and_test(skb_freed, &mvm->pending_frames[sta_id]))
+		goto out;
+
+	if (mvmsta && mvmsta->vif->type =3D=3D NL80211_IFTYPE_AP) {
+		/*
+		 * If there are no pending frames for this STA, notify
+		 * mac80211 that this station can go to sleep in its
+		 * STA table.
+		 * If mvmsta is not NULL, sta is valid.
+		 */
+		ieee80211_sta_block_awake(mvm->hw, sta, false);
+	}
+
+	if (PTR_ERR(sta) =3D=3D -EBUSY || PTR_ERR(sta) =3D=3D -ENOENT) {
+		/*
+		 * We are draining and this was the last packet - pre_rcu_remove
+		 * has been called already. We might be after the
+		 * synchronize_net already.
+		 * Don't rely on iwl_mvm_rm_sta to see the empty Tx queues.
+		 */
+		set_bit(sta_id, mvm->sta_drained);
+		schedule_work(&mvm->sta_drained_wk);
 	}
=20
+out:
 	rcu_read_unlock();
 }
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/utils.c b/drivers/net/wireles=
s/iwlwifi/mvm/utils.c
index a4a5e25623c3..86989df69356 100644
--- a/drivers/net/wireless/iwlwifi/mvm/utils.c
+++ b/drivers/net/wireless/iwlwifi/mvm/utils.c
@@ -411,6 +411,8 @@ void iwl_mvm_dump_nic_error_log(struct iwl_mvm *mvm)
 			mvm->status, table.valid);
 	}
=20
+	IWL_ERR(mvm, "Loaded firmware version: %s\n", mvm->fw->fw_version);
+
 	trace_iwlwifi_dev_ucode_error(trans->dev, table.error_id, table.tsf_low,
 				      table.data1, table.data2, table.data3,
 				      table.blink1, table.blink2, table.ilink1,
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index 3040924f5f3c..f47bcbe2945a 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -359,20 +359,25 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 /* 7265 Series */
 	{IWL_PCI_DEVICE(0x095A, 0x5010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5110, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5112, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5100, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x510A, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5310, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5302, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5210, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5012, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095A, 0x500A, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5410, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5400, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x1010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5000, iwl7265_2n_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x500A, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5200, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5002, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5202, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9010, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9012, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9110, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9112, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9210, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9510, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9310, iwl7265_2ac_cfg)},
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless=
/rt2x00/rt2500pci.c
index abc5f56f29fe..2f1cd929c6f6 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1877,6 +1877,11 @@ static int rt2500pci_probe_hw_mode(struct rt2x00_dev=
 *rt2x00dev)
 						   EEPROM_MAC_ADDR_0));
=20
 	/*
+	 * Disable powersaving as default.
+	 */
+	rt2x00dev->hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+
+	/*
 	 * Initialize hw_mode information.
 	 */
 	spec->supported_bands =3D SUPPORT_BAND_2GHZ;
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless=
/rt2x00/rt2500usb.c
index 9f16824cd1bc..d849d590de25 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1706,6 +1706,11 @@ static int rt2500usb_probe_hw_mode(struct rt2x00_dev=
 *rt2x00dev)
 	    IEEE80211_HW_SUPPORTS_PS |
 	    IEEE80211_HW_PS_NULLFUNC_STACK;
=20
+	/*
+	 * Disable powersaving as default.
+	 */
+	rt2x00dev->hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+
 	SET_IEEE80211_DEV(rt2x00dev->hw, rt2x00dev->dev);
 	SET_IEEE80211_PERM_ADDR(rt2x00dev->hw,
 				rt2x00_eeprom_addr(rt2x00dev,
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index b8f5b06006c4..7f8b5d156c8c 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -7458,10 +7458,9 @@ static int rt2800_probe_hw_mode(struct rt2x00_dev *r=
t2x00dev)
 	u32 reg;
=20
 	/*
-	 * Disable powersaving as default on PCI devices.
+	 * Disable powersaving as default.
 	 */
-	if (rt2x00_is_pci(rt2x00dev) || rt2x00_is_soc(rt2x00dev))
-		rt2x00dev->hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+	rt2x00dev->hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
=20
 	/*
 	 * Initialize all hw fields.
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wirel=
ess/rtl818x/rtl8180/dev.c
index 8ec17aad0e52..3867d1470b36 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -107,6 +107,7 @@ static void rtl8180_handle_rx(struct ieee80211_hw *dev)
 	struct rtl8180_priv *priv =3D dev->priv;
 	unsigned int count =3D 32;
 	u8 signal, agc, sq;
+	dma_addr_t mapping;
=20
 	while (count--) {
 		struct rtl8180_rx_desc *entry =3D &priv->rx_ring[priv->rx_idx];
@@ -128,6 +129,17 @@ static void rtl8180_handle_rx(struct ieee80211_hw *dev)
 			if (unlikely(!new_skb))
 				goto done;
=20
+			mapping =3D pci_map_single(priv->pdev,
+					       skb_tail_pointer(new_skb),
+					       MAX_RX_SIZE, PCI_DMA_FROMDEVICE);
+
+			if (pci_dma_mapping_error(priv->pdev, mapping)) {
+				kfree_skb(new_skb);
+				dev_err(&priv->pdev->dev, "RX DMA map error\n");
+
+				goto done;
+			}
+
 			pci_unmap_single(priv->pdev,
 					 *((dma_addr_t *)skb->cb),
 					 MAX_RX_SIZE, PCI_DMA_FROMDEVICE);
@@ -158,9 +170,7 @@ static void rtl8180_handle_rx(struct ieee80211_hw *dev)
=20
 			skb =3D new_skb;
 			priv->rx_buf[priv->rx_idx] =3D skb;
-			*((dma_addr_t *) skb->cb) =3D
-				pci_map_single(priv->pdev, skb_tail_pointer(skb),
-					       MAX_RX_SIZE, PCI_DMA_FROMDEVICE);
+			*((dma_addr_t *) skb->cb) =3D mapping;
 		}
=20
 	done:
@@ -266,6 +276,13 @@ static void rtl8180_tx(struct ieee80211_hw *dev,
 	mapping =3D pci_map_single(priv->pdev, skb->data,
 				 skb->len, PCI_DMA_TODEVICE);
=20
+	if (pci_dma_mapping_error(priv->pdev, mapping)) {
+		kfree_skb(skb);
+		dev_err(&priv->pdev->dev, "TX DMA mapping error\n");
+		return;
+
+	}
+
 	tx_flags =3D RTL818X_TX_DESC_FLAG_OWN | RTL818X_TX_DESC_FLAG_FS |
 		   RTL818X_TX_DESC_FLAG_LS |
 		   (ieee80211_get_tx_rate(dev, info)->hw_value << 24) |
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index f9ae9b85d4c1..453e974287d1 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1021,8 +1021,10 @@ static int ieee80211_start_ap(struct wiphy *wiphy, s=
truct net_device *dev,
 					IEEE80211_P2P_OPPPS_ENABLE_BIT;
=20
 	err =3D ieee80211_assign_beacon(sdata, &params->beacon);
-	if (err < 0)
+	if (err < 0) {
+		ieee80211_vif_release_channel(sdata);
 		return err;
+	}
 	changed |=3D err;
=20
 	err =3D drv_start_ap(sdata->local, sdata);
@@ -1032,6 +1034,7 @@ static int ieee80211_start_ap(struct wiphy *wiphy, st=
ruct net_device *dev,
 		if (old)
 			kfree_rcu(old, rcu_head);
 		RCU_INIT_POINTER(sdata->u.ap.beacon, NULL);
+		ieee80211_vif_release_channel(sdata);
 		return err;
 	}
=20
@@ -1090,8 +1093,6 @@ static int ieee80211_stop_ap(struct wiphy *wiphy, str=
uct net_device *dev)
 	kfree(sdata->u.ap.next_beacon);
 	sdata->u.ap.next_beacon =3D NULL;
=20
-	cancel_work_sync(&sdata->u.ap.request_smps_work);
-
 	/* turn off carrier for this interface and dependent VLANs */
 	list_for_each_entry(vlan, &sdata->u.ap.vlans, u.vlan.list)
 		netif_carrier_off(vlan->dev);
@@ -1103,6 +1104,7 @@ static int ieee80211_stop_ap(struct wiphy *wiphy, str=
uct net_device *dev)
 	kfree_rcu(old_beacon, rcu_head);
 	if (old_probe_resp)
 		kfree_rcu(old_probe_resp, rcu_head);
+	sdata->u.ap.driver_smps_mode =3D IEEE80211_SMPS_OFF;
=20
 	__sta_info_flush(sdata, true);
 	ieee80211_free_keys(sdata, true);
@@ -2638,6 +2640,24 @@ static int ieee80211_start_roc_work(struct ieee80211=
_local *local,
 	INIT_DELAYED_WORK(&roc->work, ieee80211_sw_roc_work);
 	INIT_LIST_HEAD(&roc->dependents);
=20
+	/*
+	 * cookie is either the roc cookie (for normal roc)
+	 * or the SKB (for mgmt TX)
+	 */
+	if (!txskb) {
+		/* local->mtx protects this */
+		local->roc_cookie_counter++;
+		roc->cookie =3D local->roc_cookie_counter;
+		/* wow, you wrapped 64 bits ... more likely a bug */
+		if (WARN_ON(roc->cookie =3D=3D 0)) {
+			roc->cookie =3D 1;
+			local->roc_cookie_counter++;
+		}
+		*cookie =3D roc->cookie;
+	} else {
+		*cookie =3D (unsigned long)txskb;
+	}
+
 	/* if there's one pending or we're scanning, queue this one */
 	if (!list_empty(&local->roc_list) ||
 	    local->scanning || local->radar_detect_enabled)
@@ -2772,24 +2792,6 @@ static int ieee80211_start_roc_work(struct ieee80211=
_local *local,
 	if (!queued)
 		list_add_tail(&roc->list, &local->roc_list);
=20
-	/*
-	 * cookie is either the roc cookie (for normal roc)
-	 * or the SKB (for mgmt TX)
-	 */
-	if (!txskb) {
-		/* local->mtx protects this */
-		local->roc_cookie_counter++;
-		roc->cookie =3D local->roc_cookie_counter;
-		/* wow, you wrapped 64 bits ... more likely a bug */
-		if (WARN_ON(roc->cookie =3D=3D 0)) {
-			roc->cookie =3D 1;
-			local->roc_cookie_counter++;
-		}
-		*cookie =3D roc->cookie;
-	} else {
-		*cookie =3D (unsigned long)txskb;
-	}
-
 	return 0;
 }
=20
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index fab7b91923e0..70dd013de836 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -466,7 +466,9 @@ void ieee80211_request_smps_ap_work(struct work_struct =
*work)
 			     u.ap.request_smps_work);
=20
 	sdata_lock(sdata);
-	__ieee80211_request_smps_ap(sdata, sdata->u.ap.driver_smps_mode);
+	if (sdata_dereference(sdata->u.ap.beacon, sdata))
+		__ieee80211_request_smps_ap(sdata,
+					    sdata->u.ap.driver_smps_mode);
 	sdata_unlock(sdata);
 }
=20
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 771080ec7212..2796a198728f 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -695,12 +695,9 @@ static void ieee80211_ibss_disconnect(struct ieee80211=
_sub_if_data *sdata)
 	struct cfg80211_bss *cbss;
 	struct beacon_data *presp;
 	struct sta_info *sta;
-	int active_ibss;
 	u16 capability;
=20
-	active_ibss =3D ieee80211_sta_active_ibss(sdata);
-
-	if (!active_ibss && !is_zero_ether_addr(ifibss->bssid)) {
+	if (!is_zero_ether_addr(ifibss->bssid)) {
 		capability =3D WLAN_CAPABILITY_IBSS;
=20
 		if (ifibss->privacy)
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 3dfd20a453ab..d6d1f1df9119 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -418,20 +418,24 @@ int ieee80211_add_virtual_monitor(struct ieee80211_lo=
cal *local)
 		return ret;
 	}
=20
+	mutex_lock(&local->iflist_mtx);
+	rcu_assign_pointer(local->monitor_sdata, sdata);
+	mutex_unlock(&local->iflist_mtx);
+
 	mutex_lock(&local->mtx);
 	ret =3D ieee80211_vif_use_channel(sdata, &local->monitor_chandef,
 					IEEE80211_CHANCTX_EXCLUSIVE);
 	mutex_unlock(&local->mtx);
 	if (ret) {
+		mutex_lock(&local->iflist_mtx);
+		rcu_assign_pointer(local->monitor_sdata, NULL);
+		mutex_unlock(&local->iflist_mtx);
+		synchronize_net();
 		drv_remove_interface(local, sdata);
 		kfree(sdata);
 		return ret;
 	}
=20
-	mutex_lock(&local->iflist_mtx);
-	rcu_assign_pointer(local->monitor_sdata, sdata);
-	mutex_unlock(&local->iflist_mtx);
-
 	return 0;
 }
=20
@@ -770,12 +774,19 @@ static void ieee80211_do_stop(struct ieee80211_sub_if=
_data *sdata,
=20
 	ieee80211_roc_purge(local, sdata);
=20
-	if (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION)
+	switch (sdata->vif.type) {
+	case NL80211_IFTYPE_STATION:
 		ieee80211_mgd_stop(sdata);
-
-	if (sdata->vif.type =3D=3D NL80211_IFTYPE_ADHOC)
+		break;
+	case NL80211_IFTYPE_ADHOC:
 		ieee80211_ibss_stop(sdata);
-
+		break;
+	case NL80211_IFTYPE_AP:
+		cancel_work_sync(&sdata->u.ap.request_smps_work);
+		break;
+	default:
+		break;
+	}
=20
 	/*
 	 * Remove all stations associated with this interface.
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 27c990bf2320..97a02d3f7d87 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -878,7 +878,7 @@ static int ieee80211_fragment(struct ieee80211_tx_data =
*tx,
 	}
=20
 	/* adjust first fragment's length */
-	skb->len =3D hdrlen + per_fragm;
+	skb_trim(skb, hdrlen + per_fragm);
 	return 0;
 }
=20
diff --git a/net/wireless/core.c b/net/wireless/core.c
index d89dee2259b5..010892b81a06 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -203,8 +203,11 @@ void cfg80211_stop_p2p_device(struct cfg80211_register=
ed_device *rdev,
=20
 	rdev->opencount--;
=20
-	WARN_ON(rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev &&
-		!rdev->scan_req->notified);
+	if (rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev) {
+		if (WARN_ON(!rdev->scan_req->notified))
+			rdev->scan_req->aborted =3D true;
+		___cfg80211_scan_done(rdev, false);
+	}
 }
=20
 static int cfg80211_rfkill_set_block(void *data, bool blocked)
@@ -440,9 +443,6 @@ int wiphy_register(struct wiphy *wiphy)
 	int i;
 	u16 ifmodes =3D wiphy->interface_modes;
=20
-	/* support for 5/10 MHz is broken due to nl80211 API mess - disable */
-	wiphy->flags &=3D ~WIPHY_FLAG_SUPPORTS_5_10_MHZ;
-
 	/*
 	 * There are major locking problems in nl80211/mac80211 for CSA,
 	 * disable for all drivers until this has been reworked.
@@ -859,8 +859,11 @@ static int cfg80211_netdev_notifier_call(struct notifi=
er_block *nb,
 		break;
 	case NETDEV_DOWN:
 		cfg80211_update_iface_num(rdev, wdev->iftype, -1);
-		WARN_ON(rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev &&
-			!rdev->scan_req->notified);
+		if (rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev) {
+			if (WARN_ON(!rdev->scan_req->notified))
+				rdev->scan_req->aborted =3D true;
+			___cfg80211_scan_done(rdev, false);
+		}
=20
 		if (WARN_ON(rdev->sched_scan_req &&
 			    rdev->sched_scan_req->dev =3D=3D wdev->netdev)) {
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 37ec16d7bb1a..f1d193b557b6 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -62,6 +62,7 @@ struct cfg80211_registered_device {
 	struct rb_root bss_tree;
 	u32 bss_generation;
 	struct cfg80211_scan_request *scan_req; /* protected by RTNL */
+	struct sk_buff *scan_msg;
 	struct cfg80211_sched_scan_request *sched_scan_req;
 	unsigned long suspend_at;
 	struct work_struct scan_done_wk;
@@ -361,7 +362,8 @@ int cfg80211_validate_key_settings(struct cfg80211_regi=
stered_device *rdev,
 				   struct key_params *params, int key_idx,
 				   bool pairwise, const u8 *mac_addr);
 void __cfg80211_scan_done(struct work_struct *wk);
-void ___cfg80211_scan_done(struct cfg80211_registered_device *rdev);
+void ___cfg80211_scan_done(struct cfg80211_registered_device *rdev,
+			   bool send_message);
 void __cfg80211_sched_scan_results(struct work_struct *wk);
 int __cfg80211_stop_sched_scan(struct cfg80211_registered_device *rdev,
 			       bool driver_initiated);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 7a742594916e..4fe2e6e2bc76 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1719,9 +1719,10 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, s=
truct netlink_callback *cb)
 				 * We can then retry with the larger buffer.
 				 */
 				if ((ret =3D=3D -ENOBUFS || ret =3D=3D -EMSGSIZE) &&
-				    !skb->len &&
+				    !skb->len && !state->split &&
 				    cb->min_dump_alloc < 4096) {
 					cb->min_dump_alloc =3D 4096;
+					state->split_start =3D 0;
 					rtnl_unlock();
 					return 1;
 				}
@@ -5244,7 +5245,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, =
struct genl_info *info)
 	if (!rdev->ops->scan)
 		return -EOPNOTSUPP;
=20
-	if (rdev->scan_req) {
+	if (rdev->scan_req || rdev->scan_msg) {
 		err =3D -EBUSY;
 		goto unlock;
 	}
@@ -10011,40 +10012,31 @@ void nl80211_send_scan_start(struct cfg80211_regi=
stered_device *rdev,
 				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
=20
-void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
-			    struct wireless_dev *wdev)
+struct sk_buff *nl80211_build_scan_msg(struct cfg80211_registered_device *=
rdev,
+				       struct wireless_dev *wdev, bool aborted)
 {
 	struct sk_buff *msg;
=20
 	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
-		return;
+		return NULL;
=20
 	if (nl80211_send_scan_msg(msg, rdev, wdev, 0, 0, 0,
-				  NL80211_CMD_NEW_SCAN_RESULTS) < 0) {
+				  aborted ? NL80211_CMD_SCAN_ABORTED :
+					    NL80211_CMD_NEW_SCAN_RESULTS) < 0) {
 		nlmsg_free(msg);
-		return;
+		return NULL;
 	}
=20
-	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
-				NL80211_MCGRP_SCAN, GFP_KERNEL);
+	return msg;
 }
=20
-void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
-			       struct wireless_dev *wdev)
+void nl80211_send_scan_result(struct cfg80211_registered_device *rdev,
+			      struct sk_buff *msg)
 {
-	struct sk_buff *msg;
-
-	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return;
=20
-	if (nl80211_send_scan_msg(msg, rdev, wdev, 0, 0, 0,
-				  NL80211_CMD_SCAN_ABORTED) < 0) {
-		nlmsg_free(msg);
-		return;
-	}
-
 	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				NL80211_MCGRP_SCAN, GFP_KERNEL);
 }
diff --git a/net/wireless/nl80211.h b/net/wireless/nl80211.h
index b1b231324e10..75799746d845 100644
--- a/net/wireless/nl80211.h
+++ b/net/wireless/nl80211.h
@@ -8,10 +8,10 @@ void nl80211_exit(void);
 void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev);
 void nl80211_send_scan_start(struct cfg80211_registered_device *rdev,
 			     struct wireless_dev *wdev);
-void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
-			    struct wireless_dev *wdev);
-void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
-			       struct wireless_dev *wdev);
+struct sk_buff *nl80211_build_scan_msg(struct cfg80211_registered_device *=
rdev,
+				       struct wireless_dev *wdev, bool aborted);
+void nl80211_send_scan_result(struct cfg80211_registered_device *rdev,
+			      struct sk_buff *msg);
 void nl80211_send_sched_scan(struct cfg80211_registered_device *rdev,
 			     struct net_device *netdev, u32 cmd);
 void nl80211_send_sched_scan_results(struct cfg80211_registered_device *rd=
ev,
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index b528e31da2cf..d1ed4aebbbb7 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -161,18 +161,25 @@ static void __cfg80211_bss_expire(struct cfg80211_reg=
istered_device *dev,
 		dev->bss_generation++;
 }
=20
-void ___cfg80211_scan_done(struct cfg80211_registered_device *rdev)
+void ___cfg80211_scan_done(struct cfg80211_registered_device *rdev,
+			   bool send_message)
 {
 	struct cfg80211_scan_request *request;
 	struct wireless_dev *wdev;
+	struct sk_buff *msg;
 #ifdef CONFIG_CFG80211_WEXT
 	union iwreq_data wrqu;
 #endif
=20
 	ASSERT_RTNL();
=20
-	request =3D rdev->scan_req;
+	if (rdev->scan_msg) {
+		nl80211_send_scan_result(rdev, rdev->scan_msg);
+		rdev->scan_msg =3D NULL;
+		return;
+	}
=20
+	request =3D rdev->scan_req;
 	if (!request)
 		return;
=20
@@ -186,18 +193,16 @@ void ___cfg80211_scan_done(struct cfg80211_registered=
_device *rdev)
 	if (wdev->netdev)
 		cfg80211_sme_scan_done(wdev->netdev);
=20
-	if (request->aborted) {
-		nl80211_send_scan_aborted(rdev, wdev);
-	} else {
-		if (request->flags & NL80211_SCAN_FLAG_FLUSH) {
-			/* flush entries from previous scans */
-			spin_lock_bh(&rdev->bss_lock);
-			__cfg80211_bss_expire(rdev, request->scan_start);
-			spin_unlock_bh(&rdev->bss_lock);
-		}
-		nl80211_send_scan_done(rdev, wdev);
+	if (!request->aborted &&
+	    request->flags & NL80211_SCAN_FLAG_FLUSH) {
+		/* flush entries from previous scans */
+		spin_lock_bh(&rdev->bss_lock);
+		__cfg80211_bss_expire(rdev, request->scan_start);
+		spin_unlock_bh(&rdev->bss_lock);
 	}
=20
+	msg =3D nl80211_build_scan_msg(rdev, wdev, request->aborted);
+
 #ifdef CONFIG_CFG80211_WEXT
 	if (wdev->netdev && !request->aborted) {
 		memset(&wrqu, 0, sizeof(wrqu));
@@ -211,6 +216,11 @@ void ___cfg80211_scan_done(struct cfg80211_registered_=
device *rdev)
=20
 	rdev->scan_req =3D NULL;
 	kfree(request);
+
+	if (!send_message)
+		rdev->scan_msg =3D msg;
+	else
+		nl80211_send_scan_result(rdev, msg);
 }
=20
 void __cfg80211_scan_done(struct work_struct *wk)
@@ -221,7 +231,7 @@ void __cfg80211_scan_done(struct work_struct *wk)
 			    scan_done_wk);
=20
 	rtnl_lock();
-	___cfg80211_scan_done(rdev);
+	___cfg80211_scan_done(rdev, true);
 	rtnl_unlock();
 }
=20
@@ -1079,7 +1089,7 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 	if (IS_ERR(rdev))
 		return PTR_ERR(rdev);
=20
-	if (rdev->scan_req) {
+	if (rdev->scan_req || rdev->scan_msg) {
 		err =3D -EBUSY;
 		goto out;
 	}
@@ -1481,7 +1491,7 @@ int cfg80211_wext_giwscan(struct net_device *dev,
 	if (IS_ERR(rdev))
 		return PTR_ERR(rdev);
=20
-	if (rdev->scan_req)
+	if (rdev->scan_req || rdev->scan_msg)
 		return -EAGAIN;
=20
 	res =3D ieee80211_scan_results(rdev, info, extra, data->length);
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index a63509118508..f04d4c32e96e 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -67,7 +67,7 @@ static int cfg80211_conn_scan(struct wireless_dev *wdev)
 	ASSERT_RDEV_LOCK(rdev);
 	ASSERT_WDEV_LOCK(wdev);
=20
-	if (rdev->scan_req)
+	if (rdev->scan_req || rdev->scan_msg)
 		return -EBUSY;
=20
 	if (wdev->conn->params.channel)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJS9TAWAAoJEJctW/TcYTgGkawQAJgKYaElPo9IaxVBYd9K0Pru
Fczd5UzR9auJ8eNv8cDM45fmrwzksyPwqFmCuzExxlpsrhh/NftElOXEfm/d7ZR8
ZDR1l8gAvpy5pP0yXMZVa38bPmqtHlETWWrF00PEypSmsUM9sBRoxkTw2A2C9Y2U
RlfMt9i64VpMDOpU2H2GrMuVvMxVgyOxmwbH6bkqR7VWu04mfaNRvKuLyLR0PGDT
9ajsuB3LzTwx/RHX55NL5SYh8Laib9wvyfwep/o53ce/DVXmwhmwaDe6rq9VtMJD
eHRSMC+mOuSQ/A0d7RWBsy92aukktq045gBRrb6F79UPmfsPkNwKakQHkewF3C/r
+l0AsjsjEXVmS+OPTDmt6tCPub+jSg93p0mXUH0s5sizk9i2dks5YPzgiK8BL5xD
F4+JJ2OOc9MbB3NTh9DgiqQGmoZXmDxeWecWuY06x+mKJ2kIbizIh6k5+JKVdsWL
BT6QHaMz+8EU9fBG+1hId92WLGki6SaD/DJoQja9ehEwCx08Br/3n3l9wsnAuCNa
f9pTGx3E+ja9VAG6wX4yupqTvAzb9NKx6tDptUPTeaJQAI94j4aauFb6B3llXNt6
vK0uGgUCJHFYmBuKtPOEsB6Yeep0Ssuqjldhdk++mA1AMm+9QtGSIH37xT4rNwUZ
ejKr0Pn4nOQdJMSdb5VI
=tUeY
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
