From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-10-28
Date: Tue, 28 Oct 2014 15:05:19 -0400
Message-ID: <20141028190519.GF26283@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.18 stream!

For the mac80211 bits, Johannes says:

"Here are a few fixes for the wireless stack: one fixes the
RTS rate, one for a debugfs file, one to return the correct
channel to userspace, a sanity check for a userspace value
and the remaining two are just documentation fixes."

For the iwlwifi bits, Emmanuel says:

"I revert here a patch that caused interoperability issues.
dvm gets a fix for a bug that was reported by many users.
Two minor fixes for BT Coex and platform power fix that helps
reducing latency when the PCIe link goes to low power states."

In addition...

Felix Fietkau adds a couple of ath code fixes related to regulatory
rule enforcement.

Hauke Mehrtens fixes a build break with bcma when CONFIG_OF_ADDRESS
is not set.

Karsten Wiese provides a trio of minor fixes for rtl8192cu.

Kees Cook prevents a potential information leak in rtlwifi.

Larry Finger also brings a trio of minor fixes for rtlwifi.

Rafa=C5=82 Mi=C5=82ecki adds a device ID to the bcma bus driver.

Rickard Strandqvist offers some strn* -> strl* changes in brcmfmac
to eliminate non-terminated string issues.

Sujith Manoharan avoids some ath9k stalls by enabling HW queue control
only for MCC.

Please let me know if there are problems...

John

---

The following changes since commit 61ed53deb1c6a4386d8710dbbfcee8779c381931:

  Merge tag 'ntb-3.18' of git://github.com/jonmason/ntb (2014-10-19 12:58:2=
2 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-10-27

for you to fetch changes up to 99c814066e75d09e6a38574c6c395f022a04b730:

  Merge tag 'mac80211-for-john-2014-10-23' of git://git.kernel.org/pub/scm/=
linux/kernel/git/jberg/mac80211 (2014-10-27 13:38:15 -0400)

----------------------------------------------------------------

Emmanuel Grumbach (6):
      iwlwifi: configure the LTR
      iwlwifi: mvm: BT Coex - update the MPLUT Boost register value
      iwlwifi: mvm: BT coex - fix BT prio for probe requests
      iwlwifi: dvm: drop non VO frames when flushing
      Revert "iwlwifi: mvm: treat EAPOLs like mgmt frames wrt rate"
      iwlwifi: pcie: fix polling in various places

Fabian Frederick (1):
      net: rfkill: kernel-doc warning fixes

Felix Fietkau (2):
      ath: use CTL region from cfg80211 if unset in EEPROM
      ath9k_common: always update value in ath9k_cmn_update_txpow

Haim Dreyfuss (1):
      iwlwifi: mvm: Add tx power condition to bss_info_changed_ap_ibss

Hauke Mehrtens (1):
      bcma: fix build when CONFIG_OF_ADDRESS is not set

John W. Linville (2):
      Merge tag 'iwlwifi-for-john-2014-10-23' of git://git.kernel.org/.../i=
wlwifi/iwlwifi-fixes
      Merge tag 'mac80211-for-john-2014-10-23' of git://git.kernel.org/.../=
jberg/mac80211

Karl Beldan (2):
      mac80211: fix typo in starting baserate for rts_cts_rate_idx
      mac80211: minstrels: fix buffer overflow in HT debugfs rc_stats

Karsten Wiese (3):
      rtl8192cu: Fix for rtlwifi's bluetooth coexist functionality
      rtl8192cu: Call ieee80211_register_hw from rtl_usb_probe
      rtl8192cu: Prevent Ooops under rtl92c_set_fw_rsvdpagepkt

Kees Cook (1):
      rtlwifi: prevent format string usage from leaking

Larry Finger (3):
      rtlwifi: rtl8192ee: Prevent log spamming for switch statements
      rtlwifi: rtl8821ae: Fix possible array overrun
      rtlwifi: Add check for get_btc_status callback

Liad Kaufman (2):
      mac80211: fix warning on htmldocs for last_tdls_pkt_time
      iwlwifi: 8000: fix string given to MODULE_FIRMWARE

Luciano Coelho (2):
      mac80211: return the vif's chandef in ieee80211_cfg_get_channel()
      nl80211: sanity check the channel switch counter value

Matti Gottlieb (1):
      iwlwifi: mvm: ROC - bug fixes around time events and locking

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: add another PCI ID of device with BCM43228

Rickard Strandqvist (1):
      brcmfmac: dhd_sdio.c: Cleaning up missing null-terminate in conjuncti=
on with strncpy

Sujith Manoharan (1):
      ath9k: Enable HW queue control only for MCC

 drivers/bcma/host_pci.c                            |  5 +-
 drivers/bcma/main.c                                |  2 +-
 drivers/net/wireless/ath/ath.h                     |  1 +
 drivers/net/wireless/ath/ath9k/common.c            |  8 ++--
 drivers/net/wireless/ath/ath9k/init.c              | 55 ++++++++++++------=
----
 drivers/net/wireless/ath/ath9k/main.c              |  3 ++
 drivers/net/wireless/ath/ath9k/xmit.c              | 10 +++-
 drivers/net/wireless/ath/regd.c                    | 14 ++++++
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 25 +++++-----
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        | 24 +++++-----
 drivers/net/wireless/iwlwifi/iwl-8000.c            |  3 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  2 +
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  4 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |  4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    | 35 +++++++++++++-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  1 +
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  9 ++++
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 32 +++++++++----
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  3 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |  8 +---
 drivers/net/wireless/iwlwifi/pcie/trans.c          | 22 +++++----
 drivers/net/wireless/rtlwifi/base.c                |  2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  3 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |  8 +++-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |  4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        | 17 ++++++-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |  1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |  7 +++
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c       | 15 +++---
 drivers/net/wireless/rtlwifi/usb.c                 | 11 +++++
 net/mac80211/cfg.c                                 |  2 +-
 net/mac80211/rate.c                                |  2 +-
 net/mac80211/rc80211_minstrel_debugfs.c            | 12 +++--
 net/mac80211/rc80211_minstrel_ht_debugfs.c         | 13 +++--
 net/mac80211/sta_info.h                            |  1 +
 net/wireless/nl80211.c                             | 10 +++-
 40 files changed, 269 insertions(+), 122 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 1e5ac0a79696..cd9161a8b3a1 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -275,7 +275,7 @@ static SIMPLE_DEV_PM_OPS(bcma_pm_ops, bcma_host_pci_sus=
pend,
 static const struct pci_device_id bcma_pci_bridge_tbl[] =3D {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x0576) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4313) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 43224) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 43224) },	/* 0xa8d8 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4331) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4353) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4357) },
@@ -285,7 +285,8 @@ static const struct pci_device_id bcma_pci_bridge_tbl[]=
 =3D {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x43a9) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x43aa) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4727) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 43227) },	/* 0xA8DB */
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 43227) },	/* 0xa8db, BCM43217 (sic!)=
 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 43228) },	/* 0xa8dc */
 	{ 0, },
 };
 MODULE_DEVICE_TABLE(pci, bcma_pci_bridge_tbl);
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index d1656c2f70af..1000955ce09d 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -132,7 +132,7 @@ static bool bcma_is_core_needed_early(u16 core_id)
 	return false;
 }
=20
-#ifdef CONFIG_OF
+#if defined(CONFIG_OF) && defined(CONFIG_OF_ADDRESS)
 static struct device_node *bcma_of_find_child_device(struct platform_devic=
e *parent,
 						     struct bcma_device *core)
 {
diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index e5ba6faf3281..86907e5ba6ca 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -80,6 +80,7 @@ struct reg_dmn_pair_mapping {
=20
 struct ath_regulatory {
 	char alpha2[2];
+	enum nl80211_dfs_regions region;
 	u16 country_code;
 	u16 max_power_level;
 	u16 current_rd;
diff --git a/drivers/net/wireless/ath/ath9k/common.c b/drivers/net/wireless=
/ath/ath9k/common.c
index c6dd7f1fed65..33b0c7aef2ea 100644
--- a/drivers/net/wireless/ath/ath9k/common.c
+++ b/drivers/net/wireless/ath/ath9k/common.c
@@ -368,11 +368,11 @@ void ath9k_cmn_update_txpow(struct ath_hw *ah, u16 cu=
r_txpow,
 {
 	struct ath_regulatory *reg =3D ath9k_hw_regulatory(ah);
=20
-	if (reg->power_limit !=3D new_txpow) {
+	if (reg->power_limit !=3D new_txpow)
 		ath9k_hw_set_txpowerlimit(ah, new_txpow, false);
-		/* read back in case value is clamped */
-		*txpower =3D reg->max_power_level;
-	}
+
+	/* read back in case value is clamped */
+	*txpower =3D reg->max_power_level;
 }
 EXPORT_SYMBOL(ath9k_cmn_update_txpow);
=20
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index 156a944134dc..3bd030494986 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -734,6 +734,32 @@ static const struct ieee80211_iface_combination if_com=
b[] =3D {
 #endif
 };
=20
+#ifdef CONFIG_ATH9K_CHANNEL_CONTEXT
+static void ath9k_set_mcc_capab(struct ath_softc *sc, struct ieee80211_hw =
*hw)
+{
+	struct ath_hw *ah =3D sc->sc_ah;
+	struct ath_common *common =3D ath9k_hw_common(ah);
+
+	if (!ath9k_is_chanctx_enabled())
+		return;
+
+	hw->flags |=3D IEEE80211_HW_QUEUE_CONTROL;
+	hw->queues =3D ATH9K_NUM_TX_QUEUES;
+	hw->offchannel_tx_hw_queue =3D hw->queues - 1;
+	hw->wiphy->interface_modes &=3D ~ BIT(NL80211_IFTYPE_WDS);
+	hw->wiphy->iface_combinations =3D if_comb_multi;
+	hw->wiphy->n_iface_combinations =3D ARRAY_SIZE(if_comb_multi);
+	hw->wiphy->max_scan_ssids =3D 255;
+	hw->wiphy->max_scan_ie_len =3D IEEE80211_MAX_DATA_LEN;
+	hw->wiphy->max_remain_on_channel_duration =3D 10000;
+	hw->chanctx_data_size =3D sizeof(void *);
+	hw->extra_beacon_tailroom =3D
+		sizeof(struct ieee80211_p2p_noa_attr) + 9;
+
+	ath_dbg(common, CHAN_CTX, "Use channel contexts\n");
+}
+#endif /* CONFIG_ATH9K_CHANNEL_CONTEXT */
+
 static void ath9k_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *=
hw)
 {
 	struct ath_hw *ah =3D sc->sc_ah;
@@ -746,7 +772,6 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, st=
ruct ieee80211_hw *hw)
 		IEEE80211_HW_SPECTRUM_MGMT |
 		IEEE80211_HW_REPORTS_TX_ACK_STATUS |
 		IEEE80211_HW_SUPPORTS_RC_TABLE |
-		IEEE80211_HW_QUEUE_CONTROL |
 		IEEE80211_HW_SUPPORTS_HT_CCK_RATES;
=20
 	if (ath9k_ps_enable)
@@ -781,24 +806,6 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, s=
truct ieee80211_hw *hw)
 			hw->wiphy->n_iface_combinations =3D ARRAY_SIZE(if_comb);
 	}
=20
-#ifdef CONFIG_ATH9K_CHANNEL_CONTEXT
-
-	if (ath9k_is_chanctx_enabled()) {
-		hw->wiphy->interface_modes &=3D ~ BIT(NL80211_IFTYPE_WDS);
-		hw->wiphy->iface_combinations =3D if_comb_multi;
-		hw->wiphy->n_iface_combinations =3D ARRAY_SIZE(if_comb_multi);
-		hw->wiphy->max_scan_ssids =3D 255;
-		hw->wiphy->max_scan_ie_len =3D IEEE80211_MAX_DATA_LEN;
-		hw->wiphy->max_remain_on_channel_duration =3D 10000;
-		hw->chanctx_data_size =3D sizeof(void *);
-		hw->extra_beacon_tailroom =3D
-			sizeof(struct ieee80211_p2p_noa_attr) + 9;
-
-		ath_dbg(common, CHAN_CTX, "Use channel contexts\n");
-	}
-
-#endif /* CONFIG_ATH9K_CHANNEL_CONTEXT */
-
 	hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
=20
 	hw->wiphy->flags |=3D WIPHY_FLAG_IBSS_RSN;
@@ -808,12 +815,7 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, s=
truct ieee80211_hw *hw)
 	hw->wiphy->flags |=3D WIPHY_FLAG_HAS_CHANNEL_SWITCH;
 	hw->wiphy->flags |=3D WIPHY_FLAG_AP_UAPSD;
=20
-	/* allow 4 queues per channel context +
-	 * 1 cab queue + 1 offchannel tx queue
-	 */
-	hw->queues =3D ATH9K_NUM_TX_QUEUES;
-	/* last queue for offchannel */
-	hw->offchannel_tx_hw_queue =3D hw->queues - 1;
+	hw->queues =3D 4;
 	hw->max_rates =3D 4;
 	hw->max_listen_interval =3D 10;
 	hw->max_rate_tries =3D 10;
@@ -837,6 +839,9 @@ static void ath9k_set_hw_capab(struct ath_softc *sc, st=
ruct ieee80211_hw *hw)
 		hw->wiphy->bands[IEEE80211_BAND_5GHZ] =3D
 			&common->sbands[IEEE80211_BAND_5GHZ];
=20
+#ifdef CONFIG_ATH9K_CHANNEL_CONTEXT
+	ath9k_set_mcc_capab(sc, hw);
+#endif
 	ath9k_init_wow(hw);
 	ath9k_cmn_reload_chainmask(ah);
=20
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 6f6a974f7fdb..30c66dfcd7a0 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1162,6 +1162,9 @@ static void ath9k_assign_hw_queues(struct ieee80211_h=
w *hw,
 {
 	int i;
=20
+	if (!ath9k_is_chanctx_enabled())
+		return;
+
 	for (i =3D 0; i < IEEE80211_NUM_ACS; i++)
 		vif->hw_queue[i] =3D i;
=20
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 493a183d0aaf..d6e54a3c88f6 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -169,7 +169,10 @@ static void ath_txq_skb_done(struct ath_softc *sc, str=
uct ath_txq *txq,
=20
 	if (txq->stopped &&
 	    txq->pending_frames < sc->tx.txq_max_pending[q]) {
-		ieee80211_wake_queue(sc->hw, info->hw_queue);
+		if (ath9k_is_chanctx_enabled())
+			ieee80211_wake_queue(sc->hw, info->hw_queue);
+		else
+			ieee80211_wake_queue(sc->hw, q);
 		txq->stopped =3D false;
 	}
 }
@@ -2247,7 +2250,10 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_=
buff *skb,
 		fi->txq =3D q;
 		if (++txq->pending_frames > sc->tx.txq_max_pending[q] &&
 		    !txq->stopped) {
-			ieee80211_stop_queue(sc->hw, info->hw_queue);
+			if (ath9k_is_chanctx_enabled())
+				ieee80211_stop_queue(sc->hw, info->hw_queue);
+			else
+				ieee80211_stop_queue(sc->hw, q);
 			txq->stopped =3D true;
 		}
 	}
diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/reg=
d.c
index 415393dfb6fc..06ea6cc9e30a 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -515,6 +515,7 @@ void ath_reg_notifier_apply(struct wiphy *wiphy,
 	if (!request)
 		return;
=20
+	reg->region =3D request->dfs_region;
 	switch (request->initiator) {
 	case NL80211_REGDOM_SET_BY_CORE:
 		/*
@@ -779,6 +780,19 @@ u32 ath_regd_get_band_ctl(struct ath_regulatory *reg,
 		return SD_NO_CTL;
 	}
=20
+	if (ath_regd_get_eepromRD(reg) =3D=3D CTRY_DEFAULT) {
+		switch (reg->region) {
+		case NL80211_DFS_FCC:
+			return CTL_FCC;
+		case NL80211_DFS_ETSI:
+			return CTL_ETSI;
+		case NL80211_DFS_JP:
+			return CTL_MKK;
+		default:
+			break;
+		}
+	}
+
 	switch (band) {
 	case IEEE80211_BAND_2GHZ:
 		return reg->regpair->reg_2ghz_ctl;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index f55f625fd06b..d20d4e6f391a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -670,7 +670,6 @@ static int brcmf_sdio_get_fwnames(struct brcmf_chip *ci,
 				  struct brcmf_sdio_dev *sdiodev)
 {
 	int i;
-	uint fw_len, nv_len;
 	char end;
=20
 	for (i =3D 0; i < ARRAY_SIZE(brcmf_fwname_data); i++) {
@@ -684,25 +683,25 @@ static int brcmf_sdio_get_fwnames(struct brcmf_chip *=
ci,
 		return -ENODEV;
 	}
=20
-	fw_len =3D sizeof(sdiodev->fw_name) - 1;
-	nv_len =3D sizeof(sdiodev->nvram_name) - 1;
 	/* check if firmware path is provided by module parameter */
 	if (brcmf_firmware_path[0] !=3D '\0') {
-		strncpy(sdiodev->fw_name, brcmf_firmware_path, fw_len);
-		strncpy(sdiodev->nvram_name, brcmf_firmware_path, nv_len);
-		fw_len -=3D strlen(sdiodev->fw_name);
-		nv_len -=3D strlen(sdiodev->nvram_name);
+		strlcpy(sdiodev->fw_name, brcmf_firmware_path,
+			sizeof(sdiodev->fw_name));
+		strlcpy(sdiodev->nvram_name, brcmf_firmware_path,
+			sizeof(sdiodev->nvram_name));
=20
 		end =3D brcmf_firmware_path[strlen(brcmf_firmware_path) - 1];
 		if (end !=3D '/') {
-			strncat(sdiodev->fw_name, "/", fw_len);
-			strncat(sdiodev->nvram_name, "/", nv_len);
-			fw_len--;
-			nv_len--;
+			strlcat(sdiodev->fw_name, "/",
+				sizeof(sdiodev->fw_name));
+			strlcat(sdiodev->nvram_name, "/",
+				sizeof(sdiodev->nvram_name));
 		}
 	}
-	strncat(sdiodev->fw_name, brcmf_fwname_data[i].bin, fw_len);
-	strncat(sdiodev->nvram_name, brcmf_fwname_data[i].nv, nv_len);
+	strlcat(sdiodev->fw_name, brcmf_fwname_data[i].bin,
+		sizeof(sdiodev->fw_name));
+	strlcat(sdiodev->nvram_name, brcmf_fwname_data[i].nv,
+		sizeof(sdiodev->nvram_name));
=20
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/dvm/mac80211.c
index 2364a3c09b9e..cae692ff1013 100644
--- a/drivers/net/wireless/iwlwifi/dvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
@@ -1095,6 +1095,7 @@ static void iwlagn_mac_flush(struct ieee80211_hw *hw,=
 struct ieee80211_vif *vif,
 			     u32 queues, bool drop)
 {
 	struct iwl_priv *priv =3D IWL_MAC80211_GET_DVM(hw);
+	u32 scd_queues;
=20
 	mutex_lock(&priv->mutex);
 	IWL_DEBUG_MAC80211(priv, "enter\n");
@@ -1108,18 +1109,19 @@ static void iwlagn_mac_flush(struct ieee80211_hw *h=
w, struct ieee80211_vif *vif,
 		goto done;
 	}
=20
-	/*
-	 * mac80211 will not push any more frames for transmit
-	 * until the flush is completed
-	 */
-	if (drop) {
-		IWL_DEBUG_MAC80211(priv, "send flush command\n");
-		if (iwlagn_txfifo_flush(priv, 0)) {
-			IWL_ERR(priv, "flush request fail\n");
-			goto done;
-		}
+	scd_queues =3D BIT(priv->cfg->base_params->num_of_queues) - 1;
+	scd_queues &=3D ~(BIT(IWL_IPAN_CMD_QUEUE_NUM) |
+			BIT(IWL_DEFAULT_CMD_QUEUE_NUM));
+
+	if (vif)
+		scd_queues &=3D ~BIT(vif->hw_queue[IEEE80211_AC_VO]);
+
+	IWL_DEBUG_TX_QUEUES(priv, "Flushing SCD queues: 0x%x\n", scd_queues);
+	if (iwlagn_txfifo_flush(priv, scd_queues)) {
+		IWL_ERR(priv, "flush request fail\n");
+		goto done;
 	}
-	IWL_DEBUG_MAC80211(priv, "wait transmit/flush all frames\n");
+	IWL_DEBUG_TX_QUEUES(priv, "wait transmit/flush all frames\n");
 	iwl_trans_wait_tx_queue_empty(priv->trans, 0xffffffff);
 done:
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/iwlwifi/iwl-8000.c b/drivers/net/wireless=
/iwlwifi/iwl-8000.c
index e4351487ca72..d2b7234b1c73 100644
--- a/drivers/net/wireless/iwlwifi/iwl-8000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-8000.c
@@ -82,7 +82,8 @@
 #define IWL8000_TX_POWER_VERSION	0xffff /* meaningless */
=20
 #define IWL8000_FW_PRE "iwlwifi-8000"
-#define IWL8000_MODULE_FIRMWARE(api) IWL8000_FW_PRE __stringify(api) ".uco=
de"
+#define IWL8000_MODULE_FIRMWARE(api) \
+	IWL8000_FW_PRE "-" __stringify(api) ".ucode"
=20
 #define NVM_HW_SECTION_NUM_FAMILY_8000		10
 #define DEFAULT_NVM_FILE_FAMILY_8000		"iwl_nvm_8000.bin"
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireles=
s/iwlwifi/iwl-trans.h
index 9eb85249e89c..d8fc548c0d6c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@ -563,6 +563,7 @@ enum iwl_trans_state {
  *	Set during transport allocation.
  * @hw_id_str: a string with info about HW ID. Set during transport alloca=
tion.
  * @pm_support: set to true in start_hw if link pm is supported
+ * @ltr_enabled: set to true if the LTR is enabled
  * @dev_cmd_pool: pool for Tx cmd allocation - for internal use only.
  *	The user should use iwl_trans_{alloc,free}_tx_cmd.
  * @dev_cmd_headroom: room needed for the transport's private use before t=
he
@@ -589,6 +590,7 @@ struct iwl_trans {
 	u8 rx_mpdu_cmd, rx_mpdu_cmd_hdr_size;
=20
 	bool pm_support;
+	bool ltr_enabled;
=20
 	/* The following fields are internal only */
 	struct kmem_cache *dev_cmd_pool;
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex.c b/drivers/net/wireless=
/iwlwifi/mvm/coex.c
index 8df2021f9856..da2ffb785194 100644
--- a/drivers/net/wireless/iwlwifi/mvm/coex.c
+++ b/drivers/net/wireless/iwlwifi/mvm/coex.c
@@ -303,8 +303,8 @@ static const __le64 iwl_ci_mask[][3] =3D {
 };
=20
 static const __le32 iwl_bt_mprio_lut[BT_COEX_MULTI_PRIO_LUT_SIZE] =3D {
-	cpu_to_le32(0x28412201),
-	cpu_to_le32(0x11118451),
+	cpu_to_le32(0x2e402280),
+	cpu_to_le32(0x7711a751),
 };
=20
 struct corunning_block_luts {
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex_legacy.c b/drivers/net/w=
ireless/iwlwifi/mvm/coex_legacy.c
index 585c0ab4a3ec..8a1d2f33d5b7 100644
--- a/drivers/net/wireless/iwlwifi/mvm/coex_legacy.c
+++ b/drivers/net/wireless/iwlwifi/mvm/coex_legacy.c
@@ -291,8 +291,8 @@ static const __le64 iwl_ci_mask[][3] =3D {
 };
=20
 static const __le32 iwl_bt_mprio_lut[BT_COEX_MULTI_PRIO_LUT_SIZE] =3D {
-	cpu_to_le32(0x28412201),
-	cpu_to_le32(0x11118451),
+	cpu_to_le32(0x2e402280),
+	cpu_to_le32(0x7711a751),
 };
=20
 struct corunning_block_luts {
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-power.h b/drivers/net/=
wireless/iwlwifi/mvm/fw-api-power.h
index 27dd86395b39..2fd8ad4633e0 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api-power.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api-power.h
@@ -68,13 +68,46 @@
=20
 /* Power Management Commands, Responses, Notifications */
=20
+/**
+ * enum iwl_ltr_config_flags - masks for LTR config command flags
+ * @LTR_CFG_FLAG_FEATURE_ENABLE: Feature operational status
+ * @LTR_CFG_FLAG_HW_DIS_ON_SHADOW_REG_ACCESS: allow LTR change on shadow
+ *	memory access
+ * @LTR_CFG_FLAG_HW_EN_SHRT_WR_THROUGH: allow LTR msg send on ANY LTR
+ *	reg change
+ * @LTR_CFG_FLAG_HW_DIS_ON_D0_2_D3: allow LTR msg send on transition from
+ *	D0 to D3
+ * @LTR_CFG_FLAG_SW_SET_SHORT: fixed static short LTR register
+ * @LTR_CFG_FLAG_SW_SET_LONG: fixed static short LONG register
+ * @LTR_CFG_FLAG_DENIE_C10_ON_PD: allow going into C10 on PD
+ */
+enum iwl_ltr_config_flags {
+	LTR_CFG_FLAG_FEATURE_ENABLE =3D BIT(0),
+	LTR_CFG_FLAG_HW_DIS_ON_SHADOW_REG_ACCESS =3D BIT(1),
+	LTR_CFG_FLAG_HW_EN_SHRT_WR_THROUGH =3D BIT(2),
+	LTR_CFG_FLAG_HW_DIS_ON_D0_2_D3 =3D BIT(3),
+	LTR_CFG_FLAG_SW_SET_SHORT =3D BIT(4),
+	LTR_CFG_FLAG_SW_SET_LONG =3D BIT(5),
+	LTR_CFG_FLAG_DENIE_C10_ON_PD =3D BIT(6),
+};
+
+/**
+ * struct iwl_ltr_config_cmd - configures the LTR
+ * @flags: See %enum iwl_ltr_config_flags
+ */
+struct iwl_ltr_config_cmd {
+	__le32 flags;
+	__le32 static_long;
+	__le32 static_short;
+} __packed;
+
 /* Radio LP RX Energy Threshold measured in dBm */
 #define POWER_LPRX_RSSI_THRESHOLD	75
 #define POWER_LPRX_RSSI_THRESHOLD_MAX	94
 #define POWER_LPRX_RSSI_THRESHOLD_MIN	30
=20
 /**
- * enum iwl_scan_flags - masks for power table command flags
+ * enum iwl_power_flags - masks for power table command flags
  * @POWER_FLAGS_POWER_SAVE_ENA_MSK: '1' Allow to save power by turning off
  *		receiver and transmitter. '0' - does not allow.
  * @POWER_FLAGS_POWER_MANAGEMENT_ENA_MSK: '0' Driver disables power manage=
ment,
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api.h b/drivers/net/wirele=
ss/iwlwifi/mvm/fw-api.h
index 667a92274c87..c62575d86bcd 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api.h
@@ -157,6 +157,7 @@ enum {
 	/* Power - legacy power table command */
 	POWER_TABLE_CMD =3D 0x77,
 	PSM_UAPSD_AP_MISBEHAVING_NOTIFICATION =3D 0x78,
+	LTR_CONFIG =3D 0xee,
=20
 	/* Thermal Throttling*/
 	REPLY_THERMAL_MNG_BACKOFF =3D 0x7e,
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw.c b/drivers/net/wireless/i=
wlwifi/mvm/fw.c
index 23fd711a67e4..e0d9f19650b0 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/iwlwifi/mvm/fw.c
@@ -480,6 +480,15 @@ int iwl_mvm_up(struct iwl_mvm *mvm)
 	/* Initialize tx backoffs to the minimal possible */
 	iwl_mvm_tt_tx_backoff(mvm, 0);
=20
+	if (mvm->trans->ltr_enabled) {
+		struct iwl_ltr_config_cmd cmd =3D {
+			.flags =3D cpu_to_le32(LTR_CFG_FLAG_FEATURE_ENABLE),
+		};
+
+		WARN_ON(iwl_mvm_send_cmd_pdu(mvm, LTR_CONFIG, 0,
+					     sizeof(cmd), &cmd));
+	}
+
 	ret =3D iwl_mvm_power_update_device(mvm);
 	if (ret)
 		goto error;
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index c7a73c68bdab..585fe5b7100f 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -526,7 +526,8 @@ static void iwl_mvm_mac_tx(struct ieee80211_hw *hw,
 	}
=20
 	if (IEEE80211_SKB_CB(skb)->hw_queue =3D=3D IWL_MVM_OFFCHANNEL_QUEUE &&
-	    !test_bit(IWL_MVM_STATUS_ROC_RUNNING, &mvm->status))
+	    !test_bit(IWL_MVM_STATUS_ROC_RUNNING, &mvm->status) &&
+	    !test_bit(IWL_MVM_STATUS_ROC_AUX_RUNNING, &mvm->status))
 		goto drop;
=20
 	/* treat non-bufferable MMPDUs as broadcast if sta is sleeping */
@@ -1734,6 +1735,13 @@ iwl_mvm_bss_info_changed_ap_ibss(struct iwl_mvm *mvm,
 	if (changes & BSS_CHANGED_BEACON &&
 	    iwl_mvm_mac_ctxt_beacon_changed(mvm, vif))
 		IWL_WARN(mvm, "Failed updating beacon data\n");
+
+	if (changes & BSS_CHANGED_TXPOWER) {
+		IWL_DEBUG_CALIB(mvm, "Changing TX Power to %d\n",
+				bss_conf->txpower);
+		iwl_mvm_set_tx_power(mvm, vif, bss_conf->txpower);
+	}
+
 }
=20
 static void iwl_mvm_bss_info_changed(struct ieee80211_hw *hw,
@@ -2367,14 +2375,19 @@ static int iwl_mvm_send_aux_roc_cmd(struct iwl_mvm =
*mvm,
 	/* Set the node address */
 	memcpy(aux_roc_req.node_addr, vif->addr, ETH_ALEN);
=20
+	lockdep_assert_held(&mvm->mutex);
+
+	spin_lock_bh(&mvm->time_event_lock);
+
+	if (WARN_ON(te_data->id =3D=3D HOT_SPOT_CMD)) {
+		spin_unlock_bh(&mvm->time_event_lock);
+		return -EIO;
+	}
+
 	te_data->vif =3D vif;
 	te_data->duration =3D duration;
 	te_data->id =3D HOT_SPOT_CMD;
=20
-	lockdep_assert_held(&mvm->mutex);
-
-	spin_lock_bh(&mvm->time_event_lock);
-	list_add_tail(&te_data->list, &mvm->time_event_list);
 	spin_unlock_bh(&mvm->time_event_lock);
=20
 	/*
@@ -2430,22 +2443,23 @@ static int iwl_mvm_roc(struct ieee80211_hw *hw,
 	IWL_DEBUG_MAC80211(mvm, "enter (%d, %d, %d)\n", channel->hw_value,
 			   duration, type);
=20
+	mutex_lock(&mvm->mutex);
+
 	switch (vif->type) {
 	case NL80211_IFTYPE_STATION:
 		/* Use aux roc framework (HS20) */
 		ret =3D iwl_mvm_send_aux_roc_cmd(mvm, channel,
 					       vif, duration);
-		return ret;
+		goto out_unlock;
 	case NL80211_IFTYPE_P2P_DEVICE:
 		/* handle below */
 		break;
 	default:
 		IWL_ERR(mvm, "vif isn't P2P_DEVICE: %d\n", vif->type);
-		return -EINVAL;
+		ret =3D -EINVAL;
+		goto out_unlock;
 	}
=20
-	mutex_lock(&mvm->mutex);
-
 	for (i =3D 0; i < NUM_PHY_CTX; i++) {
 		phy_ctxt =3D &mvm->phy_ctxts[i];
 		if (phy_ctxt->ref =3D=3D 0 || mvmvif->phy_ctxt =3D=3D phy_ctxt)
diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c b/drivers/net/wireless/=
iwlwifi/mvm/ops.c
index 15aa298ee79c..48cb25a93591 100644
--- a/drivers/net/wireless/iwlwifi/mvm/ops.c
+++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
@@ -336,6 +336,7 @@ static const char *const iwl_mvm_cmd_strings[REPLY_MAX]=
 =3D {
 	CMD(DTS_MEASUREMENT_NOTIFICATION),
 	CMD(REPLY_THERMAL_MNG_BACKOFF),
 	CMD(MAC_PM_POWER_TABLE),
+	CMD(LTR_CONFIG),
 	CMD(BT_COEX_CI),
 	CMD(BT_COEX_UPDATE_SW_BOOST),
 	CMD(BT_COEX_UPDATE_CORUN_LUT),
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index cb85e63c20aa..b280d5d87127 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -459,7 +459,8 @@ int iwl_mvm_scan_request(struct iwl_mvm *mvm,
 				basic_ssid ? 1 : 0);
=20
 	cmd->tx_cmd.tx_flags =3D cpu_to_le32(TX_CMD_FLG_SEQ_CTL |
-					   TX_CMD_FLG_BT_DIS);
+					   3 << TX_CMD_FLG_BT_PRIO_POS);
+
 	cmd->tx_cmd.sta_id =3D mvm->aux_sta.sta_id;
 	cmd->tx_cmd.life_time =3D cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
 	cmd->tx_cmd.rate_n_flags =3D
diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wi=
reless/iwlwifi/mvm/time-event.c
index b7f9e61d14e2..6dfad230be5e 100644
--- a/drivers/net/wireless/iwlwifi/mvm/time-event.c
+++ b/drivers/net/wireless/iwlwifi/mvm/time-event.c
@@ -305,8 +305,8 @@ static int iwl_mvm_aux_roc_te_handle_notif(struct iwl_m=
vm *mvm,
 		te_data->running =3D false;
 		te_data->vif =3D NULL;
 		te_data->uid =3D 0;
+		te_data->id =3D TE_MAX;
 	} else if (le32_to_cpu(notif->action) =3D=3D TE_V2_NOTIF_HOST_EVENT_START=
) {
-		set_bit(IWL_MVM_STATUS_ROC_RUNNING, &mvm->status);
 		set_bit(IWL_MVM_STATUS_ROC_AUX_RUNNING, &mvm->status);
 		te_data->running =3D true;
 		ieee80211_ready_on_channel(mvm->hw); /* Start TE */
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index 1cb793a498ac..c6a517c771df 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -175,14 +175,10 @@ static void iwl_mvm_set_tx_cmd_rate(struct iwl_mvm *m=
vm,
=20
 	/*
 	 * for data packets, rate info comes from the table inside the fw. This
-	 * table is controlled by LINK_QUALITY commands. Exclude ctrl port
-	 * frames like EAPOLs which should be treated as mgmt frames. This
-	 * avoids them being sent initially in high rates which increases the
-	 * chances for completion of the 4-Way handshake.
+	 * table is controlled by LINK_QUALITY commands
 	 */
=20
-	if (ieee80211_is_data(fc) && sta &&
-	    !(info->control.flags & IEEE80211_TX_CTRL_PORT_CTRL_PROTO)) {
+	if (ieee80211_is_data(fc) && sta) {
 		tx_cmd->initial_rate_index =3D 0;
 		tx_cmd->tx_flags |=3D cpu_to_le32(TX_CMD_FLG_STA_RATE);
 		return;
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 1393bac0025c..3781b029e54a 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -174,6 +174,7 @@ static void iwl_pcie_apm_config(struct iwl_trans *trans)
 {
 	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
 	u16 lctl;
+	u16 cap;
=20
 	/*
 	 * HW bug W/A for instability in PCIe bus L0S->L1 transition.
@@ -184,16 +185,17 @@ static void iwl_pcie_apm_config(struct iwl_trans *tra=
ns)
 	 *    power savings, even without L1.
 	 */
 	pcie_capability_read_word(trans_pcie->pci_dev, PCI_EXP_LNKCTL, &lctl);
-	if (lctl & PCI_EXP_LNKCTL_ASPM_L1) {
-		/* L1-ASPM enabled; disable(!) L0S */
+	if (lctl & PCI_EXP_LNKCTL_ASPM_L1)
 		iwl_set_bit(trans, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
-		dev_info(trans->dev, "L1 Enabled; Disabling L0S\n");
-	} else {
-		/* L1-ASPM disabled; enable(!) L0S */
+	else
 		iwl_clear_bit(trans, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
-		dev_info(trans->dev, "L1 Disabled; Enabling L0S\n");
-	}
 	trans->pm_support =3D !(lctl & PCI_EXP_LNKCTL_ASPM_L0S);
+
+	pcie_capability_read_word(trans_pcie->pci_dev, PCI_EXP_DEVCTL2, &cap);
+	trans->ltr_enabled =3D cap & PCI_EXP_DEVCTL2_LTR_EN;
+	dev_info(trans->dev, "L1 %sabled - LTR %sabled\n",
+		 (lctl & PCI_EXP_LNKCTL_ASPM_L1) ? "En" : "Dis",
+		 trans->ltr_enabled ? "En" : "Dis");
 }
=20
 /*
@@ -428,7 +430,7 @@ static int iwl_pcie_apm_stop_master(struct iwl_trans *t=
rans)
 	ret =3D iwl_poll_bit(trans, CSR_RESET,
 			   CSR_RESET_REG_FLAG_MASTER_DISABLED,
 			   CSR_RESET_REG_FLAG_MASTER_DISABLED, 100);
-	if (ret)
+	if (ret < 0)
 		IWL_WARN(trans, "Master Disable Timed Out, 100 usec\n");
=20
 	IWL_DEBUG_INFO(trans, "stop master\n");
@@ -544,7 +546,7 @@ static int iwl_pcie_prepare_card_hw(struct iwl_trans *t=
rans)
 		msleep(25);
 	}
=20
-	IWL_DEBUG_INFO(trans, "got NIC after %d iterations\n", iter);
+	IWL_ERR(trans, "Couldn't prepare the card\n");
=20
 	return ret;
 }
@@ -1043,7 +1045,7 @@ static int iwl_trans_pcie_d3_resume(struct iwl_trans =
*trans,
 			   CSR_GP_CNTRL_REG_FLAG_MAC_CLOCK_READY,
 			   CSR_GP_CNTRL_REG_FLAG_MAC_CLOCK_READY,
 			   25000);
-	if (ret) {
+	if (ret < 0) {
 		IWL_ERR(trans, "Failed to resume the device (mac ready)\n");
 		return ret;
 	}
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtl=
wifi/base.c
index 58ba71830886..40b6d1d006d7 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -467,7 +467,7 @@ static void _rtl_init_deferred_work(struct ieee80211_hw=
 *hw)
 		    rtl_easy_concurrent_retrytimer_callback, (unsigned long)hw);
 	/* <2> work queue */
 	rtlpriv->works.hw =3D hw;
-	rtlpriv->works.rtl_wq =3D alloc_workqueue(rtlpriv->cfg->name, 0, 0);
+	rtlpriv->works.rtl_wq =3D alloc_workqueue("%s", 0, 0, rtlpriv->cfg->name);
 	INIT_DELAYED_WORK(&rtlpriv->works.watchdog_wq,
 			  (void *)rtl_watchdog_wq_callback);
 	INIT_DELAYED_WORK(&rtlpriv->works.ips_nic_off_wq,
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 667aba81246c..25daa8715219 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1796,7 +1796,8 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 	rtl_pci_reset_trx_ring(hw);
=20
 	rtlpci->driver_is_goingto_unload =3D false;
-	if (rtlpriv->cfg->ops->get_btc_status()) {
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status()) {
 		rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
 		rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/ne=
t/wireless/rtlwifi/rtl8192c/fw_common.c
index a00861b26ece..29983bc96a89 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -656,7 +656,8 @@ static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] =
=3D {
 	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 };
=20
-void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
+void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
+	 bool (*cmd_send_packet)(struct ieee80211_hw *, struct sk_buff *))
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
@@ -722,7 +723,10 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw=
, bool b_dl_finished)
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
=20
-	rtstatus =3D rtl_cmd_send_packet(hw, skb);
+	if (cmd_send_packet)
+		rtstatus =3D cmd_send_packet(hw, skb);
+	else
+		rtstatus =3D rtl_cmd_send_packet(hw, skb);
=20
 	if (rtstatus)
 		b_dlok =3D true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h b/drivers/ne=
t/wireless/rtlwifi/rtl8192c/fw_common.h
index a815bd6273da..b64ae45dc674 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
@@ -109,7 +109,9 @@ void rtl92c_fill_h2c_cmd(struct ieee80211_hw *hw, u8 el=
ement_id,
 			 u32 cmd_len, u8 *p_cmdbuffer);
 void rtl92c_firmware_selfreset(struct ieee80211_hw *hw);
 void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
-void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished=
);
+void rtl92c_set_fw_rsvdpagepkt
+	(struct ieee80211_hw *hw,
+	 bool (*cmd_send_packet)(struct ieee80211_hw *, struct sk_buff *));
 void rtl92c_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
 void usb_writeN_async(struct rtl_priv *rtlpriv, u32 addr, void *data, u16 =
len);
 void rtl92c_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_stat=
e);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/hw.c
index 8ec0f031f48a..55357d69397a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -459,7 +459,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 var=
iable, u8 *val)
 				rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
 					       tmp_reg422 & (~BIT(6)));
=20
-				rtl92c_set_fw_rsvdpagepkt(hw, 0);
+				rtl92c_set_fw_rsvdpagepkt(hw, NULL);
=20
 				_rtl92ce_set_bcn_ctrl_reg(hw, BIT(3), 0);
 				_rtl92ce_set_bcn_ctrl_reg(hw, 0, BIT(4));
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.c
index 04aa0b5f5b3d..873363acbacf 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1592,6 +1592,20 @@ void rtl92cu_get_hw_reg(struct ieee80211_hw *hw, u8 =
variable, u8 *val)
 	}
 }
=20
+bool usb_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb)
+{
+  /* Currently nothing happens here.
+   * Traffic stops after some seconds in WPA2 802.11n mode.
+   * Maybe because rtl8192cu chip should be set from here?
+   * If I understand correctly, the realtek vendor driver sends some urbs
+   * if its "here".
+   *
+   * This is maybe necessary:
+   * rtlpriv->cfg->ops->fill_tx_cmddesc(hw, buffer, 1, 1, skb);
+   */
+	return true;
+}
+
 void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
@@ -1939,7 +1953,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 v=
ariable, u8 *val)
 					recover =3D true;
 				rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
 					       tmp_reg422 & (~BIT(6)));
-				rtl92c_set_fw_rsvdpagepkt(hw, 0);
+				rtl92c_set_fw_rsvdpagepkt(hw,
+							  &usb_cmd_send_packet);
 				_rtl92cu_set_bcn_ctrl_reg(hw, BIT(3), 0);
 				_rtl92cu_set_bcn_ctrl_reg(hw, 0, BIT(4));
 				if (recover)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.h
index 0f7812e0c8aa..c1e33b0228c0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
@@ -104,7 +104,6 @@ bool rtl92cu_gpio_radio_on_off_checking(struct ieee8021=
1_hw *hw, u8 * valid);
 void rtl92cu_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid);
 int rtl92c_download_fw(struct ieee80211_hw *hw);
 void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
-void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished);
 void rtl92c_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
 void rtl92c_fill_h2c_cmd(struct ieee80211_hw *hw,
 			 u8 element_id, u32 cmd_len, u8 *p_cmdbuffer);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index 7c5fbaf5fee0..e06bafee37f9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -101,6 +101,12 @@ static void rtl92cu_deinit_sw_vars(struct ieee80211_hw=
 *hw)
 	}
 }
=20
+/* get bt coexist status */
+static bool rtl92cu_get_btc_status(void)
+{
+	return false;
+}
+
 static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.init_sw_vars =3D rtl92cu_init_sw_vars,
 	.deinit_sw_vars =3D rtl92cu_deinit_sw_vars,
@@ -148,6 +154,7 @@ static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.phy_set_bw_mode_callback =3D rtl92cu_phy_set_bw_mode_callback,
 	.dm_dynamic_txpower =3D rtl92cu_dm_dynamic_txpower,
 	.fill_h2c_cmd =3D rtl92c_fill_h2c_cmd,
+	.get_btc_status =3D rtl92cu_get_btc_status,
 };
=20
 static struct rtl_mod_params rtl92cu_mod_params =3D {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ee/hw.c
index dfdc9b20e4ad..1a87edca2c3f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
@@ -362,7 +362,7 @@ void rtl92ee_get_hw_reg(struct ieee80211_hw *hw, u8 var=
iable, u8 *val)
 		}
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 			 "switch case not process %x\n", variable);
 		break;
 	}
@@ -591,7 +591,7 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 var=
iable, u8 *val)
 				acm_ctrl &=3D (~ACMHW_BEQEN);
 				break;
 			default:
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 					 "switch case not process\n");
 				break;
 			}
@@ -710,7 +710,7 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 var=
iable, u8 *val)
 		}
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 			 "switch case not process %x\n", variable);
 		break;
 	}
@@ -2424,7 +2424,7 @@ void rtl92ee_set_key(struct ieee80211_hw *hw, u32 key=
_index,
 			enc_algo =3D CAM_AES;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 				 "switch case not process\n");
 			enc_algo =3D CAM_TKIP;
 			break;
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8821ae/phy.c
index 9786313dc62f..1e9570fa874f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
@@ -1889,15 +1889,18 @@ static void _rtl8821ae_store_tx_power_by_rate(struc=
t ieee80211_hw *hw,
 	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
 	u8 rate_section =3D _rtl8821ae_get_rate_section_index(regaddr);
=20
-	if (band !=3D BAND_ON_2_4G && band !=3D BAND_ON_5G)
+	if (band !=3D BAND_ON_2_4G && band !=3D BAND_ON_5G) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid Band %d\n", band);
-
-	if (rfpath >=3D MAX_RF_PATH)
+		band =3D BAND_ON_2_4G;
+	}
+	if (rfpath >=3D MAX_RF_PATH) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid RfPath %d\n", rfpath);
-
-	if (txnum >=3D MAX_RF_PATH)
+		rfpath =3D MAX_RF_PATH - 1;
+	}
+	if (txnum >=3D MAX_RF_PATH) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid TxNum %d\n", txnum);
-
+		txnum =3D MAX_RF_PATH - 1;
+	}
 	rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][rate_section] =3D da=
ta;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "TxPwrByRateOffset[Band %d][RfPath %d][TxNum %d][RateSection %d] =3D 0x=
%x\n",
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 10cf69c4bc42..46ee956d0235 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -1117,7 +1117,18 @@ int rtl_usb_probe(struct usb_interface *intf,
 	}
 	rtlpriv->cfg->ops->init_sw_leds(hw);
=20
+	err =3D ieee80211_register_hw(hw);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Can't register mac80211 hw.\n");
+		err =3D -ENODEV;
+		goto error_out;
+	}
+	rtlpriv->mac80211.mac80211_registered =3D 1;
+
+	set_bit(RTL_STATUS_INTERFACE_START, &rtlpriv->status);
 	return 0;
+
 error_out:
 	rtl_deinit_core(hw);
 	_rtl_usb_io_handler_release(hw);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index fb6a1502b6df..343da1e35025 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -3458,7 +3458,7 @@ static int ieee80211_cfg_get_channel(struct wiphy *wi=
phy,
 	rcu_read_lock();
 	chanctx_conf =3D rcu_dereference(sdata->vif.chanctx_conf);
 	if (chanctx_conf) {
-		*chandef =3D chanctx_conf->def;
+		*chandef =3D sdata->vif.bss_conf.chandef;
 		ret =3D 0;
 	} else if (local->open_count > 0 &&
 		   local->open_count =3D=3D local->monitors &&
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 8fdadfd94ba8..6081329784dd 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -448,7 +448,7 @@ static void rate_fixup_ratelist(struct ieee80211_vif *v=
if,
 	 */
 	if (!(rates[0].flags & IEEE80211_TX_RC_MCS)) {
 		u32 basic_rates =3D vif->bss_conf.basic_rates;
-		s8 baserate =3D basic_rates ? ffs(basic_rates - 1) : 0;
+		s8 baserate =3D basic_rates ? ffs(basic_rates) - 1 : 0;
=20
 		rate =3D &sband->bitrates[rates[0].idx];
=20
diff --git a/net/mac80211/rc80211_minstrel_debugfs.c b/net/mac80211/rc80211=
_minstrel_debugfs.c
index edde723f9f00..2acab1bcaa4b 100644
--- a/net/mac80211/rc80211_minstrel_debugfs.c
+++ b/net/mac80211/rc80211_minstrel_debugfs.c
@@ -62,14 +62,14 @@ minstrel_stats_open(struct inode *inode, struct file *f=
ile)
 	unsigned int i, tp, prob, eprob;
 	char *p;
=20
-	ms =3D kmalloc(sizeof(*ms) + 4096, GFP_KERNEL);
+	ms =3D kmalloc(2048, GFP_KERNEL);
 	if (!ms)
 		return -ENOMEM;
=20
 	file->private_data =3D ms;
 	p =3D ms->buf;
-	p +=3D sprintf(p, "rate      throughput  ewma prob  this prob  "
-			"this succ/attempt   success    attempts\n");
+	p +=3D sprintf(p, "rate          tpt eprob *prob"
+			"  *ok(*cum)        ok(      cum)\n");
 	for (i =3D 0; i < mi->n_rates; i++) {
 		struct minstrel_rate *mr =3D &mi->r[i];
 		struct minstrel_rate_stats *mrs =3D &mi->r[i].stats;
@@ -86,8 +86,8 @@ minstrel_stats_open(struct inode *inode, struct file *fil=
e)
 		prob =3D MINSTREL_TRUNC(mrs->cur_prob * 1000);
 		eprob =3D MINSTREL_TRUNC(mrs->probability * 1000);
=20
-		p +=3D sprintf(p, "  %6u.%1u   %6u.%1u   %6u.%1u        "
-				"   %3u(%3u)  %8llu    %8llu\n",
+		p +=3D sprintf(p, " %4u.%1u %3u.%1u %3u.%1u"
+				" %4u(%4u) %9llu(%9llu)\n",
 				tp / 10, tp % 10,
 				eprob / 10, eprob % 10,
 				prob / 10, prob % 10,
@@ -102,6 +102,8 @@ minstrel_stats_open(struct inode *inode, struct file *f=
ile)
 			mi->sample_packets);
 	ms->len =3D p - ms->buf;
=20
+	WARN_ON(ms->len + sizeof(*ms) > 2048);
+
 	return 0;
 }
=20
diff --git a/net/mac80211/rc80211_minstrel_ht_debugfs.c b/net/mac80211/rc80=
211_minstrel_ht_debugfs.c
index a72ad46f2a04..d537bec93754 100644
--- a/net/mac80211/rc80211_minstrel_ht_debugfs.c
+++ b/net/mac80211/rc80211_minstrel_ht_debugfs.c
@@ -63,8 +63,8 @@ minstrel_ht_stats_dump(struct minstrel_ht_sta *mi, int i,=
 char *p)
 		prob =3D MINSTREL_TRUNC(mr->cur_prob * 1000);
 		eprob =3D MINSTREL_TRUNC(mr->probability * 1000);
=20
-		p +=3D sprintf(p, "      %6u.%1u   %6u.%1u    %6u.%1u    "
-				"%3u            %3u(%3u)  %8llu    %8llu\n",
+		p +=3D sprintf(p, " %4u.%1u %3u.%1u %3u.%1u "
+				"%3u %4u(%4u) %9llu(%9llu)\n",
 				tp / 10, tp % 10,
 				eprob / 10, eprob % 10,
 				prob / 10, prob % 10,
@@ -96,14 +96,15 @@ minstrel_ht_stats_open(struct inode *inode, struct file=
 *file)
 		return ret;
 	}
=20
-	ms =3D kmalloc(sizeof(*ms) + 8192, GFP_KERNEL);
+	ms =3D kmalloc(8192, GFP_KERNEL);
 	if (!ms)
 		return -ENOMEM;
=20
 	file->private_data =3D ms;
 	p =3D ms->buf;
-	p +=3D sprintf(p, "type           rate     throughput  ewma prob   "
-		     "this prob  retry   this succ/attempt   success    attempts\n");
+	p +=3D sprintf(p, "type           rate     tpt eprob *prob "
+			"ret  *ok(*cum)        ok(      cum)\n");
+
=20
 	p =3D minstrel_ht_stats_dump(mi, max_mcs, p);
 	for (i =3D 0; i < max_mcs; i++)
@@ -118,6 +119,8 @@ minstrel_ht_stats_open(struct inode *inode, struct file=
 *file)
 		MINSTREL_TRUNC(mi->avg_ampdu_len * 10) % 10);
 	ms->len =3D p - ms->buf;
=20
+	WARN_ON(ms->len + sizeof(*ms) > 8192);
+
 	return nonseekable_open(inode, file);
 }
=20
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 42f68cb8957e..bcda2ac7d844 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -336,6 +336,7 @@ struct ieee80211_tx_latency_stat {
  * @known_smps_mode: the smps_mode the client thinks we are in. Relevant f=
or
  *	AP only.
  * @cipher_scheme: optional cipher scheme for this station
+ * @last_tdls_pkt_time: holds the time in jiffies of last TDLS pkt ACKed
  */
 struct sta_info {
 	/* General information, mostly static */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index cb9f5a44ffad..5839c85075f1 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -5927,6 +5927,7 @@ static int nl80211_channel_switch(struct sk_buff *skb=
, struct genl_info *info)
 	int err;
 	bool need_new_beacon =3D false;
 	int len, i;
+	u32 cs_count;
=20
 	if (!rdev->ops->channel_switch ||
 	    !(rdev->wiphy.flags & WIPHY_FLAG_HAS_CHANNEL_SWITCH))
@@ -5963,7 +5964,14 @@ static int nl80211_channel_switch(struct sk_buff *sk=
b, struct genl_info *info)
 	if (need_new_beacon && !info->attrs[NL80211_ATTR_CSA_IES])
 		return -EINVAL;
=20
-	params.count =3D nla_get_u32(info->attrs[NL80211_ATTR_CH_SWITCH_COUNT]);
+	/* Even though the attribute is u32, the specification says
+	 * u8, so let's make sure we don't overflow.
+	 */
+	cs_count =3D nla_get_u32(info->attrs[NL80211_ATTR_CH_SWITCH_COUNT]);
+	if (cs_count > 255)
+		return -EINVAL;
+
+	params.count =3D cs_count;
=20
 	if (!need_new_beacon)
 		goto skip_beacons;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUT+jvAAoJEJctW/TcYTgGPPYP/1fLTUFlgRdNJMStl6qLIvDf
HNcrEh+VdLuzNL2PUfkSa4mhc1kT+UwHZNbhXSE2oBum/sEHnYI37XakcV9UFyEP
C/M3HfWh+Qcaota755wDlJ73+0YLsUrocNSRuxgATVVwl/FVXb/CORiMyeumb78t
dEjVmFdWCH+MeycDQyw5RtYSX26Ui2Ei+irP6O3Xs1/Kucg8wmUg6d2uq97HeEup
7At1OoYSg9Q0vTFLZE7JTecIqJG8LQIDMNZxTeKhD95f7yKC+NNPEyJ3EsP8LjNG
lqu2QDHwtRc0H38hQPcWYoSAqXzCgLNM7SwP+a1lSGNfedX2lxcZTbZeMXpH1bdX
QKV2TOYyhBWySSWF6l8kA3LyKLFZ1flpa2BOyJ6UJEYjAS5rFThace31DD6jH+ef
Zie1bO05/K3szsCrRJDZrhmo9ZmyPc+Uj3LZq+VniOQS9D3lv5zfT+o+zw3CL7Eo
ObZgeX9N08PTqjJE4ml8DPK3FibPQmHYnXuNa+1lhD2IA3VjelSQVnxqce7jC18D
g5eqrWoCgSft4bDbRxHZ4VWosKVW/l4pq67XN7vDGI1d/BK30ZF8lBKnwyZPn8jg
hA848uYA0S0XOVyz8UYSIsuzt0kRgqjYEoyR8/8PEaMtbn3QJ+tPMC6fJ8VbvWOv
kY59+gwfKOjZdunXNDZM
=ceLO
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
