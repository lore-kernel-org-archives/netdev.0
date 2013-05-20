From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-05-20
Date: Mon, 20 May 2013 15:36:44 -0400
Message-ID: <20130520193644.GD11502@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This pull request is intended for the 3.10 series.  It contains a
variety of fixes for problems discovered during the merge window and
after 3.10-rc1.

For the mac80211 bits, Johannes says the following:

"This is what I have:
 * a patch from Felix to fix RCU usage in his rate table code
 * a patch from Ilan to add the wdev id to some notifications so they can
   actually be used by userspace
 * Sasha Levin found an issue in how hwsim handles devices
 * a fix for a bug in the wiphy_register() error path that's been there for=
ever
 * three fixes for WoWLAN
 * AP mode frame matching was erroneously giving frames to all virtual AP
   interfaces (reported by Jouni)
 * a fix for HT handling in my CSA changes, found by Sujith
 * a fix for some locking simplifications gone wrong
 * Ben Greear found more cfg80211/mac80211 state confusion
 * and a fix for another bug found by Jouni: local state changes need to be
   reported by mac80211 to cfg80211 so it disconnects properly."

And for the iwlwifi bits, he says:

"I have fixes for a firmware crash during resume, multicast RX,
aggregation and a workaround for a firmware scanning bug."

Along with those...

Albert Pool adds a USB ID to the rtl8192cu driver.

Arend van Spriel restores a driver option support flag that had been
removed from 3.9 due to a bug in that version of the driver.

Felix Fietkau fixes a trio of ath9k issues with a series of small
patches.

Geert Uytterhoeven provides a Kconfig fix for ath9k (which you also
merged, so it isn't in the diff here).

Larry Finger gives us a fix for a build warning on big-endian systems
for rtlwifi.

Rafa=C5=82 Mi=C5=82ecki adds some core IDs to the bcma driver.

Sujith Manoharan fixes a module unloading crash in ath9k, and corrects
some calibration settings for AR9485.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 057cf65e4f715f62acccbd9125cf63eddfe69d30:

  bnx2x: Fix GSO for 57710/57711 chips (2013-05-20 00:56:57 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to ba7c96bec59d1c11cf9eaf6489e70e22f53da31b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-05-20 15:19:01 -0400)

----------------------------------------------------------------

Albert Pool (1):
      rtlwifi: rtl8192cu: Add new USB ID

Alexander Bondar (1):
      iwlwifi: mvm: Prevent setting assoc flag in MAC_CONTEXT_CMD

Arend van Spriel (1):
      brcmfmac: announce P2P_DEVICE support in wiphy structure

Denis Efremov (1):
      iwlegacy: remove inline marking of EXPORT_SYMBOL functions

Emmanuel Grumbach (2):
      iwlwifi: mvm: tell firmware to let multicast frames in
      iwlwifi: mvm: fix aggregation drain flow

Felix Fietkau (4):
      mac80211: fix spurious RCU warning and update documentation
      ath9k: fix aggregation stop/flush handling
      ath9k: fix rate handling/reporting
      ath9k: fix draining aggregation tid buffers

Geert Uytterhoeven (1):
      net/wireless: ATH9K should depend on HAS_DMA

Ilan Peer (2):
      nl80211: Add wdev identifier to some nl80211 notifications
      iwlwifi: mvm: Always use SCAN_TYPE_FORCED

Johannes Berg (9):
      cfg80211: fix wiphy_register error path
      cfg80211: fix WoWLAN wakeup tracing
      mac80211: fix IEEE80211_SDATA_DISCONNECT_RESUME
      mac80211: fix HT beacon-based channel switch handling
      mac80211: use just spin_lock() in ieee80211_get_tkip_p2k()
      mac80211: fix AP-mode frame matching
      cfg80211: fix interface down/disconnect state handling
      mac80211: report deauth to cfg80211 for local state change
      cfg80211: fix sending WoWLAN TCP wakeup settings

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: rtl8188ee: Fix warning when building on big-endian systems

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: add more core IDs

Sasha Levin (1):
      mac80211_hwsim: correctly register the platform driver

Sujith Manoharan (2):
      ath9k: Fix crash on module unload
      ath9k_hw: Enable manual peak calibration for AR9485

 drivers/bcma/scan.c                                |  2 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  2 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |  2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |  4 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  8 +++
 drivers/net/wireless/ath/ath9k/debug.h             |  5 ++
 drivers/net/wireless/ath/ath9k/init.c              | 10 ++-
 drivers/net/wireless/ath/ath9k/main.c              |  8 ++-
 drivers/net/wireless/ath/ath9k/xmit.c              | 74 ++++++++++++++----=
----
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  7 +-
 drivers/net/wireless/iwlegacy/common.c             |  2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          | 27 ++++++++
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        | 12 ++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 17 ++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  1 +
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  6 ++
 drivers/net/wireless/iwlwifi/mvm/sta.c             | 13 +++-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |  2 -
 drivers/net/wireless/iwlwifi/mvm/tx.c              | 48 ++++++++++----
 drivers/net/wireless/mac80211_hwsim.c              | 18 +++---
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |  4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |  1 +
 include/linux/bcma/bcma.h                          |  5 +-
 include/net/mac80211.h                             | 12 ++--
 net/mac80211/ieee80211_i.h                         |  1 +
 net/mac80211/mlme.c                                | 61 +++++++++++++++---
 net/mac80211/rate.c                                |  9 ++-
 net/mac80211/rx.c                                  |  3 +
 net/mac80211/tkip.c                                |  4 +-
 net/mac80211/util.c                                |  7 ++
 net/wireless/core.c                                | 17 +++--
 net/wireless/nl80211.c                             |  4 ++
 net/wireless/sme.c                                 |  3 +-
 net/wireless/trace.h                               | 23 ++++---
 35 files changed, 314 insertions(+), 109 deletions(-)

diff --git a/drivers/bcma/scan.c b/drivers/bcma/scan.c
index bca9c80..8bffa5c 100644
--- a/drivers/bcma/scan.c
+++ b/drivers/bcma/scan.c
@@ -84,6 +84,8 @@ static const struct bcma_device_id_name bcma_bcm_device_n=
ames[] =3D {
 	{ BCMA_CORE_I2S, "I2S" },
 	{ BCMA_CORE_SDR_DDR1_MEM_CTL, "SDR/DDR1 Memory Controller" },
 	{ BCMA_CORE_SHIM, "SHIM" },
+	{ BCMA_CORE_PCIE2, "PCIe Gen2" },
+	{ BCMA_CORE_ARM_CR4, "ARM CR4" },
 	{ BCMA_CORE_DEFAULT, "Default" },
 };
=20
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wi=
reless/ath/ath9k/ar9003_calib.c
index 639ba7d..6988e1d 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -965,7 +965,7 @@ static void ar9003_hw_do_manual_peak_cal(struct ath_hw =
*ah,
 {
 	int i;
=20
-	if (!AR_SREV_9462(ah) && !AR_SREV_9565(ah))
+	if (!AR_SREV_9462(ah) && !AR_SREV_9565(ah) && !AR_SREV_9485(ah))
 		return;
=20
 	for (i =3D 0; i < AR9300_MAX_CHAINS; i++) {
diff --git a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h b/drivers/net=
/wireless/ath/ath9k/ar9485_initvals.h
index 712f415..88ff1d7 100644
--- a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
@@ -1020,7 +1020,7 @@ static const u32 ar9485_1_1_baseband_postamble[][5] =
=3D {
 	{0x0000a284, 0x00000000, 0x00000000, 0x000002a0, 0x000002a0},
 	{0x0000a288, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a28c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
-	{0x0000a2c4, 0x00158d18, 0x00158d18, 0x00158d18, 0x00158d18},
+	{0x0000a2c4, 0x00158d18, 0x00158d18, 0x00058d18, 0x00058d18},
 	{0x0000a2d0, 0x00071981, 0x00071981, 0x00071982, 0x00071982},
 	{0x0000a2d8, 0xf999a83a, 0xf999a83a, 0xf999a83a, 0xf999a83a},
 	{0x0000a358, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index 8a1888d..366002f 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -254,6 +254,7 @@ struct ath_atx_tid {
 	int sched;
 	int paused;
 	u8 state;
+	bool stop_cb;
 };
=20
 struct ath_node {
@@ -351,7 +352,8 @@ void ath_tx_tasklet(struct ath_softc *sc);
 void ath_tx_edma_tasklet(struct ath_softc *sc);
 int ath_tx_aggr_start(struct ath_softc *sc, struct ieee80211_sta *sta,
 		      u16 tid, u16 *ssn);
-void ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid);
+bool ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid,
+		      bool flush);
 void ath_tx_aggr_resume(struct ath_softc *sc, struct ieee80211_sta *sta, u=
16 tid);
=20
 void ath_tx_aggr_wakeup(struct ath_softc *sc, struct ath_node *an);
diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/=
ath/ath9k/debug.c
index e6307b8..b37eb8d 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -2008,6 +2008,14 @@ void ath9k_get_et_stats(struct ieee80211_hw *hw,
 	WARN_ON(i !=3D ATH9K_SSTATS_LEN);
 }
=20
+void ath9k_deinit_debug(struct ath_softc *sc)
+{
+	if (config_enabled(CONFIG_ATH9K_DEBUGFS) && sc->rfs_chan_spec_scan) {
+		relay_close(sc->rfs_chan_spec_scan);
+		sc->rfs_chan_spec_scan =3D NULL;
+	}
+}
+
 int ath9k_init_debug(struct ath_hw *ah)
 {
 	struct ath_common *common =3D ath9k_hw_common(ah);
diff --git a/drivers/net/wireless/ath/ath9k/debug.h b/drivers/net/wireless/=
ath/ath9k/debug.h
index 794a7ec..9d49aab 100644
--- a/drivers/net/wireless/ath/ath9k/debug.h
+++ b/drivers/net/wireless/ath/ath9k/debug.h
@@ -304,6 +304,7 @@ struct ath9k_debug {
 };
=20
 int ath9k_init_debug(struct ath_hw *ah);
+void ath9k_deinit_debug(struct ath_softc *sc);
=20
 void ath_debug_stat_interrupt(struct ath_softc *sc, enum ath9k_int status);
 void ath_debug_stat_tx(struct ath_softc *sc, struct ath_buf *bf,
@@ -339,6 +340,10 @@ static inline int ath9k_init_debug(struct ath_hw *ah)
 	return 0;
 }
=20
+static inline void ath9k_deinit_debug(struct ath_softc *sc)
+{
+}
+
 static inline void ath_debug_stat_interrupt(struct ath_softc *sc,
 					    enum ath9k_int status)
 {
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index 0237b28..aba4151 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -906,7 +906,7 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc,
 	if (!ath_is_world_regd(reg)) {
 		error =3D regulatory_hint(hw->wiphy, reg->alpha2);
 		if (error)
-			goto unregister;
+			goto debug_cleanup;
 	}
=20
 	ath_init_leds(sc);
@@ -914,6 +914,8 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc,
=20
 	return 0;
=20
+debug_cleanup:
+	ath9k_deinit_debug(sc);
 unregister:
 	ieee80211_unregister_hw(hw);
 rx_cleanup:
@@ -942,11 +944,6 @@ static void ath9k_deinit_softc(struct ath_softc *sc)
 		sc->dfs_detector->exit(sc->dfs_detector);
=20
 	ath9k_eeprom_release(sc);
-
-	if (config_enabled(CONFIG_ATH9K_DEBUGFS) && sc->rfs_chan_spec_scan) {
-		relay_close(sc->rfs_chan_spec_scan);
-		sc->rfs_chan_spec_scan =3D NULL;
-	}
 }
=20
 void ath9k_deinit_device(struct ath_softc *sc)
@@ -960,6 +957,7 @@ void ath9k_deinit_device(struct ath_softc *sc)
=20
 	ath9k_ps_restore(sc);
=20
+	ath9k_deinit_debug(sc);
 	ieee80211_unregister_hw(hw);
 	ath_rx_cleanup(sc);
 	ath9k_deinit_softc(sc);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index a18414b..2382d12 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1687,6 +1687,7 @@ static int ath9k_ampdu_action(struct ieee80211_hw *hw,
 			      u16 tid, u16 *ssn, u8 buf_size)
 {
 	struct ath_softc *sc =3D hw->priv;
+	bool flush =3D false;
 	int ret =3D 0;
=20
 	local_bh_disable();
@@ -1703,12 +1704,13 @@ static int ath9k_ampdu_action(struct ieee80211_hw *=
hw,
 			ieee80211_start_tx_ba_cb_irqsafe(vif, sta->addr, tid);
 		ath9k_ps_restore(sc);
 		break;
-	case IEEE80211_AMPDU_TX_STOP_CONT:
 	case IEEE80211_AMPDU_TX_STOP_FLUSH:
 	case IEEE80211_AMPDU_TX_STOP_FLUSH_CONT:
+		flush =3D true;
+	case IEEE80211_AMPDU_TX_STOP_CONT:
 		ath9k_ps_wakeup(sc);
-		ath_tx_aggr_stop(sc, sta, tid);
-		ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
+		if (ath_tx_aggr_stop(sc, sta, tid, flush))
+			ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
 		ath9k_ps_restore(sc);
 		break;
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index eab0fcb..14bb335 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -164,7 +164,20 @@ static void ath_set_rates(struct ieee80211_vif *vif, s=
truct ieee80211_sta *sta,
 			       ARRAY_SIZE(bf->rates));
 }
=20
-static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
+static void ath_tx_clear_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
+{
+	tid->state &=3D ~AGGR_ADDBA_COMPLETE;
+	tid->state &=3D ~AGGR_CLEANUP;
+	if (!tid->stop_cb)
+		return;
+
+	ieee80211_start_tx_ba_cb_irqsafe(tid->an->vif, tid->an->sta->addr,
+					 tid->tidno);
+	tid->stop_cb =3D false;
+}
+
+static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid,
+			     bool flush_packets)
 {
 	struct ath_txq *txq =3D tid->ac->txq;
 	struct sk_buff *skb;
@@ -181,16 +194,15 @@ static void ath_tx_flush_tid(struct ath_softc *sc, st=
ruct ath_atx_tid *tid)
 	while ((skb =3D __skb_dequeue(&tid->buf_q))) {
 		fi =3D get_frame_info(skb);
 		bf =3D fi->bf;
+		if (!bf && !flush_packets)
+			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
=20
 		if (!bf) {
-			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
-			if (!bf) {
-				ieee80211_free_txskb(sc->hw, skb);
-				continue;
-			}
+			ieee80211_free_txskb(sc->hw, skb);
+			continue;
 		}
=20
-		if (fi->retries) {
+		if (fi->retries || flush_packets) {
 			list_add_tail(&bf->list, &bf_head);
 			ath_tx_update_baw(sc, tid, bf->bf_state.seqno);
 			ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
@@ -201,12 +213,10 @@ static void ath_tx_flush_tid(struct ath_softc *sc, st=
ruct ath_atx_tid *tid)
 		}
 	}
=20
-	if (tid->baw_head =3D=3D tid->baw_tail) {
-		tid->state &=3D ~AGGR_ADDBA_COMPLETE;
-		tid->state &=3D ~AGGR_CLEANUP;
-	}
+	if (tid->baw_head =3D=3D tid->baw_tail)
+		ath_tx_clear_tid(sc, tid);
=20
-	if (sendbar) {
+	if (sendbar && !flush_packets) {
 		ath_txq_unlock(sc, txq);
 		ath_send_bar(tid, tid->seq_start);
 		ath_txq_lock(sc, txq);
@@ -277,9 +287,7 @@ static void ath_tid_drain(struct ath_softc *sc, struct =
ath_txq *txq,
=20
 		list_add_tail(&bf->list, &bf_head);
=20
-		if (fi->retries)
-			ath_tx_update_baw(sc, tid, bf->bf_state.seqno);
-
+		ath_tx_update_baw(sc, tid, bf->bf_state.seqno);
 		ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
 	}
=20
@@ -602,7 +610,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, =
struct ath_txq *txq,
 	}
=20
 	if (tid->state & AGGR_CLEANUP)
-		ath_tx_flush_tid(sc, tid);
+		ath_tx_flush_tid(sc, tid, false);
=20
 	rcu_read_unlock();
=20
@@ -620,6 +628,7 @@ static void ath_tx_process_buffer(struct ath_softc *sc,=
 struct ath_txq *txq,
 				  struct ath_tx_status *ts, struct ath_buf *bf,
 				  struct list_head *bf_head)
 {
+	struct ieee80211_tx_info *info;
 	bool txok, flush;
=20
 	txok =3D !(ts->ts_status & ATH9K_TXERR_MASK);
@@ -631,8 +640,12 @@ static void ath_tx_process_buffer(struct ath_softc *sc=
, struct ath_txq *txq,
 		txq->axq_ampdu_depth--;
=20
 	if (!bf_isampdu(bf)) {
-		if (!flush)
+		if (!flush) {
+			info =3D IEEE80211_SKB_CB(bf->bf_mpdu);
+			memcpy(info->control.rates, bf->rates,
+			       sizeof(info->control.rates));
 			ath_tx_rc_status(sc, bf, ts, 1, txok ? 0 : 1, txok);
+		}
 		ath_tx_complete_buf(sc, bf, txq, bf_head, ts, txok);
 	} else
 		ath_tx_complete_aggr(sc, txq, bf, bf_head, ts, txok);
@@ -676,7 +689,7 @@ static u32 ath_lookup_rate(struct ath_softc *sc, struct=
 ath_buf *bf,
=20
 	skb =3D bf->bf_mpdu;
 	tx_info =3D IEEE80211_SKB_CB(skb);
-	rates =3D tx_info->control.rates;
+	rates =3D bf->rates;
=20
 	/*
 	 * Find the lowest frame length among the rate series that will have a
@@ -1256,18 +1269,23 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct =
ieee80211_sta *sta,
 	return 0;
 }
=20
-void ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid)
+bool ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16=
 tid,
+		      bool flush)
 {
 	struct ath_node *an =3D (struct ath_node *)sta->drv_priv;
 	struct ath_atx_tid *txtid =3D ATH_AN_2_TID(an, tid);
 	struct ath_txq *txq =3D txtid->ac->txq;
+	bool ret =3D !flush;
+
+	if (flush)
+		txtid->stop_cb =3D false;
=20
 	if (txtid->state & AGGR_CLEANUP)
-		return;
+		return false;
=20
 	if (!(txtid->state & AGGR_ADDBA_COMPLETE)) {
 		txtid->state &=3D ~AGGR_ADDBA_PROGRESS;
-		return;
+		return ret;
 	}
=20
 	ath_txq_lock(sc, txq);
@@ -1279,13 +1297,17 @@ void ath_tx_aggr_stop(struct ath_softc *sc, struct =
ieee80211_sta *sta, u16 tid)
 	 * TID can only be reused after all in-progress subframes have been
 	 * completed.
 	 */
-	if (txtid->baw_head !=3D txtid->baw_tail)
+	if (txtid->baw_head !=3D txtid->baw_tail) {
 		txtid->state |=3D AGGR_CLEANUP;
-	else
+		ret =3D false;
+		txtid->stop_cb =3D !flush;
+	} else {
 		txtid->state &=3D ~AGGR_ADDBA_COMPLETE;
+	}
=20
-	ath_tx_flush_tid(sc, txtid);
+	ath_tx_flush_tid(sc, txtid, flush);
 	ath_txq_unlock_complete(sc, txq);
+	return ret;
 }
=20
 void ath_tx_aggr_sleep(struct ieee80211_sta *sta, struct ath_softc *sc,
@@ -2415,6 +2437,7 @@ void ath_tx_node_init(struct ath_softc *sc, struct at=
h_node *an)
 		tid->ac =3D &an->ac[acno];
 		tid->state &=3D ~AGGR_ADDBA_COMPLETE;
 		tid->state &=3D ~AGGR_ADDBA_PROGRESS;
+		tid->stop_cb =3D false;
 	}
=20
 	for (acno =3D 0, ac =3D &an->ac[acno];
@@ -2451,8 +2474,7 @@ void ath_tx_node_cleanup(struct ath_softc *sc, struct=
 ath_node *an)
 		}
=20
 		ath_tid_drain(sc, txq, tid);
-		tid->state &=3D ~AGGR_ADDBA_COMPLETE;
-		tid->state &=3D ~AGGR_CLEANUP;
+		ath_tx_clear_tid(sc, tid);
=20
 		ath_txq_unlock(sc, txq);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 6d758f2..761f501 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -4140,6 +4140,10 @@ static const struct ieee80211_iface_limit brcmf_ifac=
e_limits[] =3D {
 		.types =3D BIT(NL80211_IFTYPE_P2P_CLIENT) |
 			 BIT(NL80211_IFTYPE_P2P_GO)
 	},
+	{
+		.max =3D 1,
+		.types =3D BIT(NL80211_IFTYPE_P2P_DEVICE)
+	}
 };
 static const struct ieee80211_iface_combination brcmf_iface_combos[] =3D {
 	{
@@ -4197,7 +4201,8 @@ static struct wiphy *brcmf_setup_wiphy(struct device =
*phydev)
 				 BIT(NL80211_IFTYPE_ADHOC) |
 				 BIT(NL80211_IFTYPE_AP) |
 				 BIT(NL80211_IFTYPE_P2P_CLIENT) |
-				 BIT(NL80211_IFTYPE_P2P_GO);
+				 BIT(NL80211_IFTYPE_P2P_GO) |
+				 BIT(NL80211_IFTYPE_P2P_DEVICE);
 	wiphy->iface_combinations =3D brcmf_iface_combos;
 	wiphy->n_iface_combinations =3D ARRAY_SIZE(brcmf_iface_combos);
 	wiphy->bands[IEEE80211_BAND_2GHZ] =3D &__wl_band_2ghz;
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/=
iwlegacy/common.c
index 592d0aa..e9a3cbc 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -1423,7 +1423,7 @@ il_setup_rx_scan_handlers(struct il_priv *il)
 }
 EXPORT_SYMBOL(il_setup_rx_scan_handlers);
=20
-inline u16
+u16
 il_get_active_dwell_time(struct il_priv *il, enum ieee80211_band band,
 			 u8 n_probes)
 {
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api.h b/drivers/net/wirele=
ss/iwlwifi/mvm/fw-api.h
index 191dcae..c638455 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api.h
@@ -173,6 +173,8 @@ enum {
 	REPLY_DEBUG_CMD =3D 0xf0,
 	DEBUG_LOG_MSG =3D 0xf7,
=20
+	MCAST_FILTER_CMD =3D 0xd0,
+
 	/* D3 commands/notifications */
 	D3_CONFIG_CMD =3D 0xd3,
 	PROT_OFFLOAD_CONFIG_CMD =3D 0xd4,
@@ -948,4 +950,29 @@ struct iwl_set_calib_default_cmd {
 	u8 data[0];
 } __packed; /* PHY_CALIB_OVERRIDE_VALUES_S */
=20
+#define MAX_PORT_ID_NUM	2
+
+/**
+ * struct iwl_mcast_filter_cmd - configure multicast filter.
+ * @filter_own: Set 1 to filter out multicast packets sent by station itse=
lf
+ * @port_id:	Multicast MAC addresses array specifier. This is a strange way
+ *		to identify network interface adopted in host-device IF.
+ *		It is used by FW as index in array of addresses. This array has
+ *		MAX_PORT_ID_NUM members.
+ * @count:	Number of MAC addresses in the array
+ * @pass_all:	Set 1 to pass all multicast packets.
+ * @bssid:	current association BSSID.
+ * @addr_list:	Place holder for array of MAC addresses.
+ *		IMPORTANT: add padding if necessary to ensure DWORD alignment.
+ */
+struct iwl_mcast_filter_cmd {
+	u8 filter_own;
+	u8 port_id;
+	u8 count;
+	u8 pass_all;
+	u8 bssid[6];
+	u8 reserved[2];
+	u8 addr_list[0];
+} __packed; /* MCAST_FILTERING_CMD_API_S_VER_1 */
+
 #endif /* __fw_api_h__ */
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c b/drivers/net/wire=
less/iwlwifi/mvm/mac-ctxt.c
index e6eca4d..b2cc3d9 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
@@ -586,10 +586,12 @@ static int iwl_mvm_mac_ctxt_send_cmd(struct iwl_mvm *=
mvm,
  */
 static void iwl_mvm_mac_ctxt_cmd_fill_sta(struct iwl_mvm *mvm,
 					  struct ieee80211_vif *vif,
-					  struct iwl_mac_data_sta *ctxt_sta)
+					  struct iwl_mac_data_sta *ctxt_sta,
+					  bool force_assoc_off)
 {
 	/* We need the dtim_period to set the MAC as associated */
-	if (vif->bss_conf.assoc && vif->bss_conf.dtim_period) {
+	if (vif->bss_conf.assoc && vif->bss_conf.dtim_period &&
+	    !force_assoc_off) {
 		u32 dtim_offs;
=20
 		/*
@@ -659,7 +661,8 @@ static int iwl_mvm_mac_ctxt_cmd_station(struct iwl_mvm =
*mvm,
 		cmd.filter_flags &=3D ~cpu_to_le32(MAC_FILTER_IN_BEACON);
=20
 	/* Fill the data specific for station mode */
-	iwl_mvm_mac_ctxt_cmd_fill_sta(mvm, vif, &cmd.sta);
+	iwl_mvm_mac_ctxt_cmd_fill_sta(mvm, vif, &cmd.sta,
+				      action =3D=3D FW_CTXT_ACTION_ADD);
=20
 	return iwl_mvm_mac_ctxt_send_cmd(mvm, &cmd);
 }
@@ -677,7 +680,8 @@ static int iwl_mvm_mac_ctxt_cmd_p2p_client(struct iwl_m=
vm *mvm,
 	iwl_mvm_mac_ctxt_cmd_common(mvm, vif, &cmd, action);
=20
 	/* Fill the data specific for station mode */
-	iwl_mvm_mac_ctxt_cmd_fill_sta(mvm, vif, &cmd.p2p_sta.sta);
+	iwl_mvm_mac_ctxt_cmd_fill_sta(mvm, vif, &cmd.p2p_sta.sta,
+				      action =3D=3D FW_CTXT_ACTION_ADD);
=20
 	cmd.p2p_sta.ctwin =3D cpu_to_le32(noa->oppps_ctwindow &
 					IEEE80211_P2P_OPPPS_CTWINDOW_MASK);
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index dd158ec..a5eb8c8 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -701,6 +701,20 @@ static void iwl_mvm_configure_filter(struct ieee80211_=
hw *hw,
 	*total_flags =3D 0;
 }
=20
+static int iwl_mvm_configure_mcast_filter(struct iwl_mvm *mvm,
+					  struct ieee80211_vif *vif)
+{
+	struct iwl_mcast_filter_cmd mcast_filter_cmd =3D {
+		.pass_all =3D 1,
+	};
+
+	memcpy(mcast_filter_cmd.bssid, vif->bss_conf.bssid, ETH_ALEN);
+
+	return iwl_mvm_send_cmd_pdu(mvm, MCAST_FILTER_CMD, CMD_SYNC,
+				    sizeof(mcast_filter_cmd),
+				    &mcast_filter_cmd);
+}
+
 static void iwl_mvm_bss_info_changed_station(struct iwl_mvm *mvm,
 					     struct ieee80211_vif *vif,
 					     struct ieee80211_bss_conf *bss_conf,
@@ -722,6 +736,7 @@ static void iwl_mvm_bss_info_changed_station(struct iwl=
_mvm *mvm,
 				return;
 			}
 			iwl_mvm_bt_coex_vif_assoc(mvm, vif);
+			iwl_mvm_configure_mcast_filter(mvm, vif);
 		} else if (mvmvif->ap_sta_id !=3D IWL_MVM_STATION_COUNT) {
 			/* remove AP station now that the MAC is unassoc */
 			ret =3D iwl_mvm_rm_sta_id(mvm, vif, mvmvif->ap_sta_id);
@@ -931,7 +946,7 @@ static void iwl_mvm_mac_sta_notify(struct ieee80211_hw =
*hw,
=20
 	switch (cmd) {
 	case STA_NOTIFY_SLEEP:
-		if (atomic_read(&mvmsta->pending_frames) > 0)
+		if (atomic_read(&mvm->pending_frames[mvmsta->sta_id]) > 0)
 			ieee80211_sta_block_awake(hw, sta, true);
 		/*
 		 * The fw updates the STA to be asleep. Tx packets on the Tx
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/=
iwlwifi/mvm/mvm.h
index 8269bc5..9f46b23 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -292,6 +292,7 @@ struct iwl_mvm {
 	struct ieee80211_sta __rcu *fw_id_to_mac_id[IWL_MVM_STATION_COUNT];
 	struct work_struct sta_drained_wk;
 	unsigned long sta_drained[BITS_TO_LONGS(IWL_MVM_STATION_COUNT)];
+	atomic_t pending_frames[IWL_MVM_STATION_COUNT];
=20
 	/* configured by mac80211 */
 	u32 rts_threshold;
diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c b/drivers/net/wireless/=
iwlwifi/mvm/ops.c
index fe031d3..b29c31a 100644
--- a/drivers/net/wireless/iwlwifi/mvm/ops.c
+++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
@@ -292,6 +292,7 @@ static const char *iwl_mvm_cmd_strings[REPLY_MAX] =3D {
 	CMD(BT_COEX_PROT_ENV),
 	CMD(BT_PROFILE_NOTIFICATION),
 	CMD(BT_CONFIG),
+	CMD(MCAST_FILTER_CMD),
 };
 #undef CMD
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index 2157b0f..2476e43 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -298,6 +298,12 @@ int iwl_mvm_scan_request(struct iwl_mvm *mvm,
 	else
 		cmd->type =3D cpu_to_le32(SCAN_TYPE_FORCED);
=20
+	/*
+	 * TODO: This is a WA due to a bug in the FW AUX framework that does not
+	 * properly handle time events that fail to be scheduled
+	 */
+	cmd->type =3D cpu_to_le32(SCAN_TYPE_FORCED);
+
 	cmd->repeats =3D cpu_to_le32(1);
=20
 	/*
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/=
iwlwifi/mvm/sta.c
index 0fd96e4..5c664ed 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -219,7 +219,7 @@ int iwl_mvm_add_sta(struct iwl_mvm *mvm,
 	mvm_sta->max_agg_bufsize =3D LINK_QUAL_AGG_FRAME_LIMIT_DEF;
=20
 	/* HW restart, don't assume the memory has been zeroed */
-	atomic_set(&mvm_sta->pending_frames, 0);
+	atomic_set(&mvm->pending_frames[sta_id], 0);
 	mvm_sta->tid_disable_agg =3D 0;
 	mvm_sta->tfd_queue_msk =3D 0;
 	for (i =3D 0; i < IEEE80211_NUM_ACS; i++)
@@ -407,14 +407,21 @@ int iwl_mvm_rm_sta(struct iwl_mvm *mvm,
 	}
=20
 	/*
+	 * Make sure that the tx response code sees the station as -EBUSY and
+	 * calls the drain worker.
+	 */
+	spin_lock_bh(&mvm_sta->lock);
+	/*
 	 * There are frames pending on the AC queues for this station.
 	 * We need to wait until all the frames are drained...
 	 */
-	if (atomic_read(&mvm_sta->pending_frames)) {
-		ret =3D iwl_mvm_drain_sta(mvm, mvm_sta, true);
+	if (atomic_read(&mvm->pending_frames[mvm_sta->sta_id])) {
 		rcu_assign_pointer(mvm->fw_id_to_mac_id[mvm_sta->sta_id],
 				   ERR_PTR(-EBUSY));
+		spin_unlock_bh(&mvm_sta->lock);
+		ret =3D iwl_mvm_drain_sta(mvm, mvm_sta, true);
 	} else {
+		spin_unlock_bh(&mvm_sta->lock);
 		ret =3D iwl_mvm_rm_sta_common(mvm, mvm_sta->sta_id);
 		rcu_assign_pointer(mvm->fw_id_to_mac_id[mvm_sta->sta_id], NULL);
 	}
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.h b/drivers/net/wireless/=
iwlwifi/mvm/sta.h
index 12abd2d..a4ddce7 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.h
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.h
@@ -274,7 +274,6 @@ struct iwl_mvm_tid_data {
  * @bt_reduced_txpower: is reduced tx power enabled for this station
  * @lock: lock to protect the whole struct. Since %tid_data is access from=
 Tx
  * and from Tx response flow, it needs a spinlock.
- * @pending_frames: number of frames for this STA on the shared Tx queues.
  * @tid_data: per tid data. Look at %iwl_mvm_tid_data.
  *
  * When mac80211 creates a station it reserves some space (hw->sta_data_si=
ze)
@@ -290,7 +289,6 @@ struct iwl_mvm_sta {
 	u8 max_agg_bufsize;
 	bool bt_reduced_txpower;
 	spinlock_t lock;
-	atomic_t pending_frames;
 	struct iwl_mvm_tid_data tid_data[IWL_MAX_TID_COUNT];
 	struct iwl_lq_sta lq_sta;
 	struct ieee80211_vif *vif;
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index 4790743..f212f16 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -416,9 +416,8 @@ int iwl_mvm_tx_skb(struct iwl_mvm *mvm, struct sk_buff =
*skb,
=20
 	spin_unlock(&mvmsta->lock);
=20
-	if (mvmsta->vif->type =3D=3D NL80211_IFTYPE_AP &&
-	    txq_id < IWL_MVM_FIRST_AGG_QUEUE)
-		atomic_inc(&mvmsta->pending_frames);
+	if (txq_id < IWL_MVM_FIRST_AGG_QUEUE)
+		atomic_inc(&mvm->pending_frames[mvmsta->sta_id]);
=20
 	return 0;
=20
@@ -680,16 +679,41 @@ static void iwl_mvm_rx_tx_cmd_single(struct iwl_mvm *=
mvm,
 	/*
 	 * If the txq is not an AMPDU queue, there is no chance we freed
 	 * several skbs. Check that out...
-	 * If there are no pending frames for this STA, notify mac80211 that
-	 * this station can go to sleep in its STA table.
 	 */
-	if (txq_id < IWL_MVM_FIRST_AGG_QUEUE && mvmsta &&
-	    !WARN_ON(skb_freed > 1) &&
-	    mvmsta->vif->type =3D=3D NL80211_IFTYPE_AP &&
-	    atomic_sub_and_test(skb_freed, &mvmsta->pending_frames)) {
-		ieee80211_sta_block_awake(mvm->hw, sta, false);
-		set_bit(sta_id, mvm->sta_drained);
-		schedule_work(&mvm->sta_drained_wk);
+	if (txq_id < IWL_MVM_FIRST_AGG_QUEUE && !WARN_ON(skb_freed > 1) &&
+	    atomic_sub_and_test(skb_freed, &mvm->pending_frames[sta_id])) {
+		if (mvmsta) {
+			/*
+			 * If there are no pending frames for this STA, notify
+			 * mac80211 that this station can go to sleep in its
+			 * STA table.
+			 */
+			if (mvmsta->vif->type =3D=3D NL80211_IFTYPE_AP)
+				ieee80211_sta_block_awake(mvm->hw, sta, false);
+			/*
+			 * We might very well have taken mvmsta pointer while
+			 * the station was being removed. The remove flow might
+			 * have seen a pending_frame (because we didn't take
+			 * the lock) even if now the queues are drained. So make
+			 * really sure now that this the station is not being
+			 * removed. If it is, run the drain worker to remove it.
+			 */
+			spin_lock_bh(&mvmsta->lock);
+			sta =3D rcu_dereference(mvm->fw_id_to_mac_id[sta_id]);
+			if (IS_ERR_OR_NULL(sta)) {
+				/*
+				 * Station disappeared in the meantime:
+				 * so we are draining.
+				 */
+				set_bit(sta_id, mvm->sta_drained);
+				schedule_work(&mvm->sta_drained_wk);
+			}
+			spin_unlock_bh(&mvmsta->lock);
+		} else if (!mvmsta) {
+			/* Tx response without STA, so we are draining */
+			set_bit(sta_id, mvm->sta_drained);
+			schedule_work(&mvm->sta_drained_wk);
+		}
 	}
=20
 	rcu_read_unlock();
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/m=
ac80211_hwsim.c
index b878a32..cb34c78 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1723,11 +1723,11 @@ static void mac80211_hwsim_free(void)
 	class_destroy(hwsim_class);
 }
=20
-
-static struct device_driver mac80211_hwsim_driver =3D {
-	.name =3D "mac80211_hwsim",
-	.bus =3D &platform_bus_type,
-	.owner =3D THIS_MODULE,
+static struct platform_driver mac80211_hwsim_driver =3D {
+	.driver =3D {
+		.name =3D "mac80211_hwsim",
+		.owner =3D THIS_MODULE,
+	},
 };
=20
 static const struct net_device_ops hwsim_netdev_ops =3D {
@@ -2219,7 +2219,7 @@ static int __init init_mac80211_hwsim(void)
 	spin_lock_init(&hwsim_radio_lock);
 	INIT_LIST_HEAD(&hwsim_radios);
=20
-	err =3D driver_register(&mac80211_hwsim_driver);
+	err =3D platform_driver_register(&mac80211_hwsim_driver);
 	if (err)
 		return err;
=20
@@ -2254,7 +2254,7 @@ static int __init init_mac80211_hwsim(void)
 			err =3D -ENOMEM;
 			goto failed_drvdata;
 		}
-		data->dev->driver =3D &mac80211_hwsim_driver;
+		data->dev->driver =3D &mac80211_hwsim_driver.driver;
 		err =3D device_bind_driver(data->dev);
 		if (err !=3D 0) {
 			printk(KERN_DEBUG
@@ -2564,7 +2564,7 @@ failed_drvdata:
 failed:
 	mac80211_hwsim_free();
 failed_unregister_driver:
-	driver_unregister(&mac80211_hwsim_driver);
+	platform_driver_unregister(&mac80211_hwsim_driver);
 	return err;
 }
 module_init(init_mac80211_hwsim);
@@ -2577,6 +2577,6 @@ static void __exit exit_mac80211_hwsim(void)
=20
 	mac80211_hwsim_free();
 	unregister_netdev(hwsim_mon);
-	driver_unregister(&mac80211_hwsim_driver);
+	platform_driver_unregister(&mac80211_hwsim_driver);
 }
 module_exit(exit_mac80211_hwsim);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h b/drivers/net/wir=
eless/rtlwifi/rtl8188ee/trx.h
index d3a02e7..21ca33a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
@@ -550,7 +550,7 @@ do {								\
 	 rxmcs =3D=3D DESC92C_RATE11M)
=20
 struct phy_rx_agc_info_t {
-	#if __LITTLE_ENDIAN
+	#ifdef __LITTLE_ENDIAN
 		u8	gain:7, trsw:1;
 	#else
 		u8	trsw:1, gain:7;
@@ -574,7 +574,7 @@ struct phy_status_rpt {
 	u8	stream_target_csi[2];
 	u8	sig_evm;
 	u8	rsvd_3;
-#if __LITTLE_ENDIAN
+#ifdef __LITTLE_ENDIAN
 	u8	antsel_rx_keep_2:1;	/*ex_intf_flg:1;*/
 	u8	sgi_en:1;
 	u8	rxsc:2;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index 23d640a..938b1e6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -349,6 +349,7 @@ static struct usb_device_id rtl8192c_usb_ids[] =3D {
 	{RTL_USB_DEVICE(0x07aa, 0x0056, rtl92cu_hal_cfg)}, /*ATKK-Gemtek*/
 	{RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Funai -Abocom*/
 	{RTL_USB_DEVICE(0x0846, 0x9021, rtl92cu_hal_cfg)}, /*Netgear-Sercomm*/
+	{RTL_USB_DEVICE(0x0846, 0xf001, rtl92cu_hal_cfg)}, /*On Netwrks N300MA*/
 	{RTL_USB_DEVICE(0x0b05, 0x17ab, rtl92cu_hal_cfg)}, /*ASUS-Edimax*/
 	{RTL_USB_DEVICE(0x0bda, 0x8186, rtl92cu_hal_cfg)}, /*Realtek 92CE-VAU*/
 	{RTL_USB_DEVICE(0x0df6, 0x0061, rtl92cu_hal_cfg)}, /*Sitecom-Edimax*/
diff --git a/include/linux/bcma/bcma.h b/include/linux/bcma/bcma.h
index f14a98a..2e34db8 100644
--- a/include/linux/bcma/bcma.h
+++ b/include/linux/bcma/bcma.h
@@ -134,7 +134,10 @@ struct bcma_host_ops {
 #define BCMA_CORE_I2S			0x834
 #define BCMA_CORE_SDR_DDR1_MEM_CTL	0x835	/* SDR/DDR1 memory controller cor=
e */
 #define BCMA_CORE_SHIM			0x837	/* SHIM component in ubus/6362 */
-#define BCMA_CORE_ARM_CR4		0x83e
+#define BCMA_CORE_PHY_AC		0x83B
+#define BCMA_CORE_PCIE2			0x83C	/* PCI Express Gen2 */
+#define BCMA_CORE_USB30_DEV		0x83D
+#define BCMA_CORE_ARM_CR4		0x83E
 #define BCMA_CORE_DEFAULT		0xFFF
=20
 #define BCMA_MAX_NR_CORES		16
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 04c2d46..885898a 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -3043,7 +3043,8 @@ void ieee80211_napi_complete(struct ieee80211_hw *hw);
  * This function may not be called in IRQ context. Calls to this function
  * for a single hardware must be synchronized against each other. Calls to
  * this function, ieee80211_rx_ni() and ieee80211_rx_irqsafe() may not be
- * mixed for a single hardware.
+ * mixed for a single hardware. Must not run concurrently with
+ * ieee80211_tx_status() or ieee80211_tx_status_ni().
  *
  * In process context use instead ieee80211_rx_ni().
  *
@@ -3059,7 +3060,8 @@ void ieee80211_rx(struct ieee80211_hw *hw, struct sk_=
buff *skb);
  * (internally defers to a tasklet.)
  *
  * Calls to this function, ieee80211_rx() or ieee80211_rx_ni() may not
- * be mixed for a single hardware.
+ * be mixed for a single hardware.Must not run concurrently with
+ * ieee80211_tx_status() or ieee80211_tx_status_ni().
  *
  * @hw: the hardware this frame came in on
  * @skb: the buffer to receive, owned by mac80211 after this call
@@ -3073,7 +3075,8 @@ void ieee80211_rx_irqsafe(struct ieee80211_hw *hw, st=
ruct sk_buff *skb);
  * (internally disables bottom halves).
  *
  * Calls to this function, ieee80211_rx() and ieee80211_rx_irqsafe() may
- * not be mixed for a single hardware.
+ * not be mixed for a single hardware. Must not run concurrently with
+ * ieee80211_tx_status() or ieee80211_tx_status_ni().
  *
  * @hw: the hardware this frame came in on
  * @skb: the buffer to receive, owned by mac80211 after this call
@@ -3196,7 +3199,8 @@ void ieee80211_get_tx_rates(struct ieee80211_vif *vif,
  * This function may not be called in IRQ context. Calls to this function
  * for a single hardware must be synchronized against each other. Calls
  * to this function, ieee80211_tx_status_ni() and ieee80211_tx_status_irqs=
afe()
- * may not be mixed for a single hardware.
+ * may not be mixed for a single hardware. Must not run concurrently with
+ * ieee80211_rx() or ieee80211_rx_ni().
  *
  * @hw: the hardware the frame was transmitted by
  * @skb: the frame that was transmitted, owned by mac80211 after this call
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 158e6eb..44be28c 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1267,6 +1267,7 @@ void ieee80211_sta_reset_conn_monitor(struct ieee8021=
1_sub_if_data *sdata);
 void ieee80211_mgd_stop(struct ieee80211_sub_if_data *sdata);
 void ieee80211_mgd_conn_tx_status(struct ieee80211_sub_if_data *sdata,
 				  __le16 fc, bool acked);
+void ieee80211_sta_restart(struct ieee80211_sub_if_data *sdata);
=20
 /* IBSS code */
 void ieee80211_ibss_notify_scan_completed(struct ieee80211_local *local);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 29620bf..a46e490 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1015,7 +1015,8 @@ static void ieee80211_chswitch_timer(unsigned long da=
ta)
=20
 static void
 ieee80211_sta_process_chanswitch(struct ieee80211_sub_if_data *sdata,
-				 u64 timestamp, struct ieee802_11_elems *elems)
+				 u64 timestamp, struct ieee802_11_elems *elems,
+				 bool beacon)
 {
 	struct ieee80211_local *local =3D sdata->local;
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
@@ -1032,6 +1033,7 @@ ieee80211_sta_process_chanswitch(struct ieee80211_sub=
_if_data *sdata,
 	struct cfg80211_chan_def new_vht_chandef =3D {};
 	const struct ieee80211_sec_chan_offs_ie *sec_chan_offs;
 	const struct ieee80211_wide_bw_chansw_ie *wide_bw_chansw_ie;
+	const struct ieee80211_ht_operation *ht_oper;
 	int secondary_channel_offset =3D -1;
=20
 	ASSERT_MGD_MTX(ifmgd);
@@ -1048,11 +1050,14 @@ ieee80211_sta_process_chanswitch(struct ieee80211_s=
ub_if_data *sdata,
=20
 	sec_chan_offs =3D elems->sec_chan_offs;
 	wide_bw_chansw_ie =3D elems->wide_bw_chansw_ie;
+	ht_oper =3D elems->ht_operation;
=20
 	if (ifmgd->flags & (IEEE80211_STA_DISABLE_HT |
 			    IEEE80211_STA_DISABLE_40MHZ)) {
 		sec_chan_offs =3D NULL;
 		wide_bw_chansw_ie =3D NULL;
+		/* only used for bandwidth here */
+		ht_oper =3D NULL;
 	}
=20
 	if (ifmgd->flags & IEEE80211_STA_DISABLE_VHT)
@@ -1094,10 +1099,20 @@ ieee80211_sta_process_chanswitch(struct ieee80211_s=
ub_if_data *sdata,
 		return;
 	}
=20
-	if (sec_chan_offs) {
+	if (!beacon && sec_chan_offs) {
 		secondary_channel_offset =3D sec_chan_offs->sec_chan_offs;
+	} else if (beacon && ht_oper) {
+		secondary_channel_offset =3D
+			ht_oper->ht_param & IEEE80211_HT_PARAM_CHA_SEC_OFFSET;
 	} else if (!(ifmgd->flags & IEEE80211_STA_DISABLE_HT)) {
-		/* if HT is enabled and the IE not present, it's still HT */
+		/*
+		 * If it's not a beacon, HT is enabled and the IE not present,
+		 * it's 20 MHz, 802.11-2012 8.5.2.6:
+		 *	This element [the Secondary Channel Offset Element] is
+		 *	present when switching to a 40 MHz channel. It may be
+		 *	present when switching to a 20 MHz channel (in which
+		 *	case the secondary channel offset is set to SCN).
+		 */
 		secondary_channel_offset =3D IEEE80211_HT_PARAM_CHA_SEC_NONE;
 	}
=20
@@ -2796,7 +2811,8 @@ static void ieee80211_rx_bss_info(struct ieee80211_su=
b_if_data *sdata,
 		mutex_unlock(&local->iflist_mtx);
 	}
=20
-	ieee80211_sta_process_chanswitch(sdata, rx_status->mactime, elems);
+	ieee80211_sta_process_chanswitch(sdata, rx_status->mactime,
+					 elems, true);
=20
 }
=20
@@ -3210,7 +3226,7 @@ void ieee80211_sta_rx_queued_mgmt(struct ieee80211_su=
b_if_data *sdata,
=20
 			ieee80211_sta_process_chanswitch(sdata,
 							 rx_status->mactime,
-							 &elems);
+							 &elems, false);
 		} else if (mgmt->u.action.category =3D=3D WLAN_CATEGORY_PUBLIC) {
 			ies_len =3D skb->len -
 				  offsetof(struct ieee80211_mgmt,
@@ -3232,7 +3248,7 @@ void ieee80211_sta_rx_queued_mgmt(struct ieee80211_su=
b_if_data *sdata,
=20
 			ieee80211_sta_process_chanswitch(sdata,
 							 rx_status->mactime,
-							 &elems);
+							 &elems, false);
 		}
 		break;
 	}
@@ -3623,6 +3639,31 @@ static void ieee80211_restart_sta_timer(struct ieee8=
0211_sub_if_data *sdata)
 	}
 }
=20
+#ifdef CONFIG_PM
+void ieee80211_sta_restart(struct ieee80211_sub_if_data *sdata)
+{
+	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
+
+	mutex_lock(&ifmgd->mtx);
+	if (!ifmgd->associated) {
+		mutex_unlock(&ifmgd->mtx);
+		return;
+	}
+
+	if (sdata->flags & IEEE80211_SDATA_DISCONNECT_RESUME) {
+		sdata->flags &=3D ~IEEE80211_SDATA_DISCONNECT_RESUME;
+		mlme_dbg(sdata, "driver requested disconnect after resume\n");
+		ieee80211_sta_connection_lost(sdata,
+					      ifmgd->associated->bssid,
+					      WLAN_REASON_UNSPECIFIED,
+					      true);
+		mutex_unlock(&ifmgd->mtx);
+		return;
+	}
+	mutex_unlock(&ifmgd->mtx);
+}
+#endif
+
 /* interface setup */
 void ieee80211_sta_setup_sdata(struct ieee80211_sub_if_data *sdata)
 {
@@ -4329,7 +4370,7 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data=
 *sdata,
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
 	u8 frame_buf[IEEE80211_DEAUTH_FRAME_LEN];
 	bool tx =3D !req->local_state_change;
-	bool sent_frame =3D false;
+	bool report_frame =3D false;
=20
 	mutex_lock(&ifmgd->mtx);
=20
@@ -4346,7 +4387,7 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data=
 *sdata,
 		ieee80211_destroy_auth_data(sdata, false);
 		mutex_unlock(&ifmgd->mtx);
=20
-		sent_frame =3D tx;
+		report_frame =3D true;
 		goto out;
 	}
=20
@@ -4354,12 +4395,12 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_da=
ta *sdata,
 	    ether_addr_equal(ifmgd->associated->bssid, req->bssid)) {
 		ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DEAUTH,
 				       req->reason_code, tx, frame_buf);
-		sent_frame =3D tx;
+		report_frame =3D true;
 	}
 	mutex_unlock(&ifmgd->mtx);
=20
  out:
-	if (sent_frame)
+	if (report_frame)
 		__cfg80211_send_deauth(sdata->dev, frame_buf,
 				       IEEE80211_DEAUTH_FRAME_LEN);
=20
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 0d51877..d3f414f 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -688,8 +688,15 @@ int rate_control_set_rates(struct ieee80211_hw *hw,
 			   struct ieee80211_sta *pubsta,
 			   struct ieee80211_sta_rates *rates)
 {
-	struct ieee80211_sta_rates *old =3D rcu_dereference(pubsta->rates);
+	struct ieee80211_sta_rates *old;
=20
+	/*
+	 * mac80211 guarantees that this function will not be called
+	 * concurrently, so the following RCU access is safe, even without
+	 * extra locking. This can not be checked easily, so we just set
+	 * the condition to true.
+	 */
+	old =3D rcu_dereference_protected(pubsta->rates, true);
 	rcu_assign_pointer(pubsta->rates, rates);
 	if (old)
 		kfree_rcu(old, rcu_head);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index c8447af..8e29526 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -3036,6 +3036,9 @@ static int prepare_for_handlers(struct ieee80211_rx_d=
ata *rx,
 			 * and location updates. Note that mac80211
 			 * itself never looks at these frames.
 			 */
+			if (!multicast &&
+			    !ether_addr_equal(sdata->vif.addr, hdr->addr1))
+				return 0;
 			if (ieee80211_is_public_action(hdr, skb->len))
 				return 1;
 			if (!ieee80211_is_beacon(hdr->frame_control))
diff --git a/net/mac80211/tkip.c b/net/mac80211/tkip.c
index 3ed801d..124b1fd 100644
--- a/net/mac80211/tkip.c
+++ b/net/mac80211/tkip.c
@@ -208,10 +208,10 @@ void ieee80211_get_tkip_p2k(struct ieee80211_key_conf=
 *keyconf,
 	u32 iv32 =3D get_unaligned_le32(&data[4]);
 	u16 iv16 =3D data[2] | (data[0] << 8);
=20
-	spin_lock_bh(&key->u.tkip.txlock);
+	spin_lock(&key->u.tkip.txlock);
 	ieee80211_compute_tkip_p1k(key, iv32);
 	tkip_mixing_phase2(tk, ctx, iv16, p2k);
-	spin_unlock_bh(&key->u.tkip.txlock);
+	spin_unlock(&key->u.tkip.txlock);
 }
 EXPORT_SYMBOL(ieee80211_get_tkip_p2k);
=20
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 3f87fa4..27e0715 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1740,6 +1740,13 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 	mb();
 	local->resuming =3D false;
=20
+	list_for_each_entry(sdata, &local->interfaces, list) {
+		if (!ieee80211_sdata_running(sdata))
+			continue;
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION)
+			ieee80211_sta_restart(sdata);
+	}
+
 	mod_timer(&local->sta_cleanup, jiffies + 1);
 #else
 	WARN_ON(1);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 84c9ad7..73405e0 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -638,17 +638,21 @@ int wiphy_register(struct wiphy *wiphy)
 	 * cfg80211_mutex lock
 	 */
 	res =3D rfkill_register(rdev->rfkill);
-	if (res)
-		goto out_rm_dev;
+	if (res) {
+		device_del(&rdev->wiphy.dev);
+
+		mutex_lock(&cfg80211_mutex);
+		debugfs_remove_recursive(rdev->wiphy.debugfsdir);
+		list_del_rcu(&rdev->list);
+		wiphy_regulatory_deregister(wiphy);
+		mutex_unlock(&cfg80211_mutex);
+		return res;
+	}
=20
 	rtnl_lock();
 	rdev->wiphy.registered =3D true;
 	rtnl_unlock();
 	return 0;
-
-out_rm_dev:
-	device_del(&rdev->wiphy.dev);
-	return res;
 }
 EXPORT_SYMBOL(wiphy_register);
=20
@@ -866,7 +870,6 @@ void cfg80211_leave(struct cfg80211_registered_device *=
rdev,
 #endif
 		__cfg80211_disconnect(rdev, dev,
 				      WLAN_REASON_DEAUTH_LEAVING, true);
-		cfg80211_mlme_down(rdev, dev);
 		wdev_unlock(wdev);
 		break;
 	case NL80211_IFTYPE_MESH_POINT:
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index afa2838..dfdb5e6 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -7577,6 +7577,8 @@ static int nl80211_send_wowlan_tcp(struct sk_buff *ms=
g,
 		    &tcp->payload_tok))
 		return -ENOBUFS;
=20
+	nla_nest_end(msg, nl_tcp);
+
 	return 0;
 }
=20
@@ -9970,6 +9972,7 @@ int nl80211_send_mgmt(struct cfg80211_registered_devi=
ce *rdev,
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    (netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
 					netdev->ifindex)) ||
+	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)) ||
 	    nla_put_u32(msg, NL80211_ATTR_WIPHY_FREQ, freq) ||
 	    (sig_dbm &&
 	     nla_put_u32(msg, NL80211_ATTR_RX_SIGNAL_DBM, sig_dbm)) ||
@@ -10010,6 +10013,7 @@ void cfg80211_mgmt_tx_status(struct wireless_dev *w=
dev, u64 cookie,
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    (netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
 				   netdev->ifindex)) ||
+	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)) ||
 	    nla_put(msg, NL80211_ATTR_FRAME, len, buf) ||
 	    nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie) ||
 	    (ack && nla_put_flag(msg, NL80211_ATTR_ACK)))
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index a9dc5c7..8b5eddf 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -961,7 +961,7 @@ int __cfg80211_disconnect(struct cfg80211_registered_de=
vice *rdev,
 		/* was it connected by userspace SME? */
 		if (!wdev->conn) {
 			cfg80211_mlme_down(rdev, dev);
-			return 0;
+			goto disconnect;
 		}
=20
 		if (wdev->sme_state =3D=3D CFG80211_SME_CONNECTING &&
@@ -987,6 +987,7 @@ int __cfg80211_disconnect(struct cfg80211_registered_de=
vice *rdev,
 			return err;
 	}
=20
+ disconnect:
 	if (wdev->sme_state =3D=3D CFG80211_SME_CONNECTED)
 		__cfg80211_disconnected(dev, NULL, 0, 0, false);
 	else if (wdev->sme_state =3D=3D CFG80211_SME_CONNECTING)
diff --git a/net/wireless/trace.h b/net/wireless/trace.h
index ecd4fce..5755bc1 100644
--- a/net/wireless/trace.h
+++ b/net/wireless/trace.h
@@ -2441,6 +2441,7 @@ TRACE_EVENT(cfg80211_report_wowlan_wakeup,
 	TP_STRUCT__entry(
 		WIPHY_ENTRY
 		WDEV_ENTRY
+		__field(bool, non_wireless)
 		__field(bool, disconnect)
 		__field(bool, magic_pkt)
 		__field(bool, gtk_rekey_failure)
@@ -2449,20 +2450,22 @@ TRACE_EVENT(cfg80211_report_wowlan_wakeup,
 		__field(bool, rfkill_release)
 		__field(s32, pattern_idx)
 		__field(u32, packet_len)
-		__dynamic_array(u8, packet, wakeup->packet_present_len)
+		__dynamic_array(u8, packet,
+				wakeup ? wakeup->packet_present_len : 0)
 	),
 	TP_fast_assign(
 		WIPHY_ASSIGN;
 		WDEV_ASSIGN;
-		__entry->disconnect =3D wakeup->disconnect;
-		__entry->magic_pkt =3D wakeup->magic_pkt;
-		__entry->gtk_rekey_failure =3D wakeup->gtk_rekey_failure;
-		__entry->eap_identity_req =3D wakeup->eap_identity_req;
-		__entry->four_way_handshake =3D wakeup->four_way_handshake;
-		__entry->rfkill_release =3D wakeup->rfkill_release;
-		__entry->pattern_idx =3D wakeup->pattern_idx;
-		__entry->packet_len =3D wakeup->packet_len;
-		if (wakeup->packet && wakeup->packet_present_len)
+		__entry->non_wireless =3D !wakeup;
+		__entry->disconnect =3D wakeup ? wakeup->disconnect : false;
+		__entry->magic_pkt =3D wakeup ? wakeup->magic_pkt : false;
+		__entry->gtk_rekey_failure =3D wakeup ? wakeup->gtk_rekey_failure : fals=
e;
+		__entry->eap_identity_req =3D wakeup ? wakeup->eap_identity_req : false;
+		__entry->four_way_handshake =3D wakeup ? wakeup->four_way_handshake : fa=
lse;
+		__entry->rfkill_release =3D wakeup ? wakeup->rfkill_release : false;
+		__entry->pattern_idx =3D wakeup ? wakeup->pattern_idx : false;
+		__entry->packet_len =3D wakeup ? wakeup->packet_len : false;
+		if (wakeup && wakeup->packet && wakeup->packet_present_len)
 			memcpy(__get_dynamic_array(packet), wakeup->packet,
 			       wakeup->packet_present_len);
 	),
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRmntLAAoJEJctW/TcYTgGV/YP/1WzPQo4P5GdqcOa6HNLkNSu
t628wo4WtLpsNlPr9idni6+T/BDJUyh5k9VDUCJhRcLSuonwQQCM01zEryvXP5SV
s/xa0p1JaXzZEYmCI1MLvpYG6cDIr3Zd+Sy+SumxB2ajbirQ2O2JuW/IoDT6lzoN
xIxf2BOh0Ja5+qgg+heIeMouqSJjntAEiC3qtWQbs896juA6u6eL1LFc3jahnT3/
bSTiLwWtSyuxwcwMRthI+zLz7E9Xfxw6npPLbFEM/UM5mL9WgzptJs4k+FkGHCqz
nDmvP8ip3YnnWoI/MYwxrZqOcHUNVQePcwUrzXINa/5PwLngQykw5fGoXO9VwL1M
Ul77wjxztomOse5QcJWrZ8p3K+Dkt8Tql+rq2UXK1TXgk7BNVsjFVq+dDx79F6Ca
/X4axUqFXpFmmF7+mEN7KSXJayGJC2Kf8X5pZy5jgSq8YKx9xdDybieJtOl4U4rR
bS1ojZAhkT35klXMJL6hXZkZrzOC0BAni+vFo81/cig7ltpty+ZGW6SKD924b376
pA2d7lPH7PILkx5EnaEn+L3oWMFZcq4Yv/lw6XL20wkupokfSz1L0LlEPi8CnbpF
k2Q6CfZEJTZzh219BhF95e2gXEgmMENpSlcjRTud6S3gea0KHaYbfVNdFn+0pzYB
4RznGCs8bN6xRefODvbl
=M0yT
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--
