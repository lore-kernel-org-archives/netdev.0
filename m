From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-02-27
Date: Thu, 27 Feb 2014 15:45:09 -0500
Message-ID: <20140227204508.GA12296@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.14 stream...

Regarding the mac80211 bits, Johannes says:

"This time, I have a fix from Arik for scheduled scan recovery (something
that only recently went into the tree), a memory leak fix from Eytan and
a small regulatory bugfix from Inbal. The EAPOL change from Felix makes
rekeying more stable while lots of traffic is flowing, and there's
Emmanuel's and my fixes for a race in the code handling powersaving
clients."

Regarding the NFC bits, Samuel says:

"We only have one candidate for 3.14 fixes, and this is a NCI NULL
pointer dereference introduced during the 3.14 merge window."

Regarding the iwlwifi bits, Emmanuel says:

"This should fix an issue raised in iwldvm when we have lots of
association failures.  There is a bugzilla for this bug - it hasn't
been validated by the user, but I hope it will do the trick."

Beyond that...

Amitkumar Karwar brings two mwifiex fixes, one to avoid a NULL pointer
dereference and another to address an improperly timed interrupt.

Arend van Spriel gives us a brcmfmac fix to avoid a crash during
scatter-gather packet transfers.

Avinash Patila offers an mwifiex to avoid an invalid memory access
when a device is removed.

Bing Zhao delivers a simple fix to avoid a naming conflict between
libertas and mwifiex.

Felix Fietkau provides a trio of ath9k fixes that properly account
for sequence numbering in ps-poll frames, reduce the rate for false
positives during baseband hang detection, and fix a regression related
to rx descriptor handling.

James Cameron shows us a libertas fix to ignore zero-length IEs when
processing scan results.

Kirill Tkhai brings a hostap fix to avoid prematurely freeing a timer.

Stanislaw Gruszka fixes an ath9k locking problem.

Sujith Manoharan addresses ETSI compliance for a device handled by
ath9k by adjusting the minimum CCA power threshold values.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 724b9e1d75ab3401aaa081bd4efb440c1b3509db:

  sch_tbf: Fix potential memory leak in tbf_change(). (2014-02-27 12:53:50 =
-0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 8e2a89c5151d4645b9649ab9a9498f3445d48868:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-02-27 15:05:51 -0500)

----------------------------------------------------------------

Amitkumar Karwar (3):
      mwifiex: add NULL check for PCIe Rx skb
      mwifiex: fix cmd and Tx data timeout issue for PCIe cards
      NFC: NCI: Fix NULL pointer dereference

Arend van Spriel (1):
      brcmfmac: fix txglomming scatter-gather packet transfers

Arik Nemtsov (1):
      mac80211: fix sched_scan restart on recovery

Avinash Patil (1):
      mwifiex: clean pcie ring only when device is present

Bing Zhao (1):
      mwifiex: rename usb driver name registerring to usb core

Emmanuel Grumbach (2):
      mac80211: fix AP powersave TX vs. wakeup race
      iwlwifi: dvm: clear IWL_STA_UCODE_INPROGRESS when assoc fails

Eytan Lifshitz (1):
      mac80211: fix memory leak

Felix Fietkau (4):
      mac80211: send control port protocol frames to the VO queue
      ath9k: fix ps-poll responses under a-mpdu sessions
      ath9k: reduce baseband hang detection false positive rate
      ath9k: fix invalid descriptor discarding

Inbal Hacohen (1):
      cfg80211: bugfix in regulatory user hint process

James Cameron (1):
      libertas: fix scan result loss if SSID IE len 0

Johannes Berg (2):
      mac80211: insert stations before adding to driver
      mac80211: fix station wakeup powersave race

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fix=
es
      Merge tag 'nfc-fixes-3.14-1' of git://git.kernel.org/.../sameo/nfc-fi=
xes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Kirill Tkhai (1):
      hostap: Do not free priv until timer handler has actually stopped usi=
ng it

Stanislaw Gruszka (1):
      ath9k: protect tid->sched check

Sujith Manoharan (1):
      ath9k: Fix ETSI compliance for AR9462 2.0

 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |  4 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  8 ++-
 drivers/net/wireless/ath/ath9k/recv.c              | 70 +++++++++++-------=
----
 drivers/net/wireless/ath/ath9k/xmit.c              | 13 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 14 ++---
 drivers/net/wireless/hostap/hostap_ap.c            |  2 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |  1 +
 drivers/net/wireless/libertas/cfg.c                |  2 +-
 drivers/net/wireless/mwifiex/pcie.c                | 34 +++++------
 drivers/net/wireless/mwifiex/usb.c                 |  4 +-
 drivers/net/wireless/mwifiex/wmm.c                 |  3 +-
 net/mac80211/ieee80211_i.h                         | 10 +---
 net/mac80211/mlme.c                                |  1 +
 net/mac80211/rx.c                                  |  7 +++
 net/mac80211/sta_info.c                            | 66 ++++++++++++------=
--
 net/mac80211/sta_info.h                            |  7 +--
 net/mac80211/tx.c                                  | 15 +++++
 net/mac80211/util.c                                | 48 +++++++--------
 net/mac80211/wme.c                                 |  5 ++
 net/nfc/nci/core.c                                 |  2 +-
 net/wireless/reg.c                                 |  2 +-
 21 files changed, 178 insertions(+), 140 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9462_2p0_initvals.h b/drivers=
/net/wireless/ath/ath9k/ar9462_2p0_initvals.h
index 1cc13569b17b..1b6b4d0cfa97 100644
--- a/drivers/net/wireless/ath/ath9k/ar9462_2p0_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9462_2p0_initvals.h
@@ -57,7 +57,7 @@ static const u32 ar9462_2p0_baseband_postamble[][5] =3D {
 	{0x00009e14, 0x37b95d5e, 0x37b9605e, 0x3236605e, 0x32365a5e},
 	{0x00009e18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00009e1c, 0x0001cf9c, 0x0001cf9c, 0x00021f9c, 0x00021f9c},
-	{0x00009e20, 0x000003b5, 0x000003b5, 0x000003ce, 0x000003ce},
+	{0x00009e20, 0x000003a5, 0x000003a5, 0x000003a5, 0x000003a5},
 	{0x00009e2c, 0x0000001c, 0x0000001c, 0x00000021, 0x00000021},
 	{0x00009e3c, 0xcf946220, 0xcf946220, 0xcfd5c782, 0xcfd5c282},
 	{0x00009e44, 0x62321e27, 0x62321e27, 0xfe291e27, 0xfe291e27},
@@ -96,7 +96,7 @@ static const u32 ar9462_2p0_baseband_postamble[][5] =3D {
 	{0x0000ae04, 0x001c0000, 0x001c0000, 0x001c0000, 0x00100000},
 	{0x0000ae18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000ae1c, 0x0000019c, 0x0000019c, 0x0000019c, 0x0000019c},
-	{0x0000ae20, 0x000001b5, 0x000001b5, 0x000001ce, 0x000001ce},
+	{0x0000ae20, 0x000001a6, 0x000001a6, 0x000001aa, 0x000001aa},
 	{0x0000b284, 0x00000000, 0x00000000, 0x00000550, 0x00000550},
 };
=20
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 11eab9f01fd8..303ce27964c1 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1534,7 +1534,7 @@ EXPORT_SYMBOL(ath9k_hw_check_nav);
 bool ath9k_hw_check_alive(struct ath_hw *ah)
 {
 	int count =3D 50;
-	u32 reg;
+	u32 reg, last_val;
=20
 	if (AR_SREV_9300(ah))
 		return !ath9k_hw_detect_mac_hang(ah);
@@ -1542,9 +1542,13 @@ bool ath9k_hw_check_alive(struct ath_hw *ah)
 	if (AR_SREV_9285_12_OR_LATER(ah))
 		return true;
=20
+	last_val =3D REG_READ(ah, AR_OBS_BUS_1);
 	do {
 		reg =3D REG_READ(ah, AR_OBS_BUS_1);
+		if (reg !=3D last_val)
+			return true;
=20
+		last_val =3D reg;
 		if ((reg & 0x7E7FFFEF) =3D=3D 0x00702400)
 			continue;
=20
@@ -1556,6 +1560,8 @@ bool ath9k_hw_check_alive(struct ath_hw *ah)
 		default:
 			return true;
 		}
+
+		udelay(1);
 	} while (count-- > 0);
=20
 	return false;
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/a=
th/ath9k/recv.c
index a0ebdd000fc2..82e340d3ec60 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -732,11 +732,18 @@ static struct ath_rxbuf *ath_get_next_rx_buf(struct a=
th_softc *sc,
 			return NULL;
=20
 		/*
-		 * mark descriptor as zero-length and set the 'more'
-		 * flag to ensure that both buffers get discarded
+		 * Re-check previous descriptor, in case it has been filled
+		 * in the mean time.
 		 */
-		rs->rs_datalen =3D 0;
-		rs->rs_more =3D true;
+		ret =3D ath9k_hw_rxprocdesc(ah, ds, rs);
+		if (ret =3D=3D -EINPROGRESS) {
+			/*
+			 * mark descriptor as zero-length and set the 'more'
+			 * flag to ensure that both buffers get discarded
+			 */
+			rs->rs_datalen =3D 0;
+			rs->rs_more =3D true;
+		}
 	}
=20
 	list_del(&bf->list);
@@ -985,32 +992,32 @@ static int ath9k_rx_skb_preprocess(struct ath_softc *=
sc,
 	struct ath_common *common =3D ath9k_hw_common(ah);
 	struct ieee80211_hdr *hdr;
 	bool discard_current =3D sc->rx.discard_next;
-	int ret =3D 0;
=20
 	/*
 	 * Discard corrupt descriptors which are marked in
 	 * ath_get_next_rx_buf().
 	 */
-	sc->rx.discard_next =3D rx_stats->rs_more;
 	if (discard_current)
-		return -EINVAL;
+		goto corrupt;
+
+	sc->rx.discard_next =3D false;
=20
 	/*
 	 * Discard zero-length packets.
 	 */
 	if (!rx_stats->rs_datalen) {
 		RX_STAT_INC(rx_len_err);
-		return -EINVAL;
+		goto corrupt;
 	}
=20
-        /*
-         * rs_status follows rs_datalen so if rs_datalen is too large
-         * we can take a hint that hardware corrupted it, so ignore
-         * those frames.
-         */
+	/*
+	 * rs_status follows rs_datalen so if rs_datalen is too large
+	 * we can take a hint that hardware corrupted it, so ignore
+	 * those frames.
+	 */
 	if (rx_stats->rs_datalen > (common->rx_bufsize - ah->caps.rx_status_len))=
 {
 		RX_STAT_INC(rx_len_err);
-		return -EINVAL;
+		goto corrupt;
 	}
=20
 	/* Only use status info from the last fragment */
@@ -1024,10 +1031,8 @@ static int ath9k_rx_skb_preprocess(struct ath_softc =
*sc,
 	 * This is different from the other corrupt descriptor
 	 * condition handled above.
 	 */
-	if (rx_stats->rs_status & ATH9K_RXERR_CORRUPT_DESC) {
-		ret =3D -EINVAL;
-		goto exit;
-	}
+	if (rx_stats->rs_status & ATH9K_RXERR_CORRUPT_DESC)
+		goto corrupt;
=20
 	hdr =3D (struct ieee80211_hdr *) (skb->data + ah->caps.rx_status_len);
=20
@@ -1043,18 +1048,15 @@ static int ath9k_rx_skb_preprocess(struct ath_softc=
 *sc,
 		if (ath_process_fft(sc, hdr, rx_stats, rx_status->mactime))
 			RX_STAT_INC(rx_spectral);
=20
-		ret =3D -EINVAL;
-		goto exit;
+		return -EINVAL;
 	}
=20
 	/*
 	 * everything but the rate is checked here, the rate check is done
 	 * separately to avoid doing two lookups for a rate for each frame.
 	 */
-	if (!ath9k_rx_accept(common, hdr, rx_status, rx_stats, decrypt_error)) {
-		ret =3D -EINVAL;
-		goto exit;
-	}
+	if (!ath9k_rx_accept(common, hdr, rx_status, rx_stats, decrypt_error))
+		return -EINVAL;
=20
 	if (ath_is_mybeacon(common, hdr)) {
 		RX_STAT_INC(rx_beacons);
@@ -1064,15 +1066,11 @@ static int ath9k_rx_skb_preprocess(struct ath_softc=
 *sc,
 	/*
 	 * This shouldn't happen, but have a safety check anyway.
 	 */
-	if (WARN_ON(!ah->curchan)) {
-		ret =3D -EINVAL;
-		goto exit;
-	}
+	if (WARN_ON(!ah->curchan))
+		return -EINVAL;
=20
-	if (ath9k_process_rate(common, hw, rx_stats, rx_status)) {
-		ret =3D-EINVAL;
-		goto exit;
-	}
+	if (ath9k_process_rate(common, hw, rx_stats, rx_status))
+		return -EINVAL;
=20
 	ath9k_process_rssi(common, hw, rx_stats, rx_status);
=20
@@ -1087,9 +1085,11 @@ static int ath9k_rx_skb_preprocess(struct ath_softc =
*sc,
 		sc->rx.num_pkts++;
 #endif
=20
-exit:
-	sc->rx.discard_next =3D false;
-	return ret;
+	return 0;
+
+corrupt:
+	sc->rx.discard_next =3D rx_stats->rs_more;
+	return -EINVAL;
 }
=20
 static void ath9k_rx_skb_postprocess(struct ath_common *common,
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 0a75e2f68c9d..f042a18c8495 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1444,14 +1444,16 @@ void ath_tx_aggr_sleep(struct ieee80211_sta *sta, s=
truct ath_softc *sc,
 	for (tidno =3D 0, tid =3D &an->tid[tidno];
 	     tidno < IEEE80211_NUM_TIDS; tidno++, tid++) {
=20
-		if (!tid->sched)
-			continue;
-
 		ac =3D tid->ac;
 		txq =3D ac->txq;
=20
 		ath_txq_lock(sc, txq);
=20
+		if (!tid->sched) {
+			ath_txq_unlock(sc, txq);
+			continue;
+		}
+
 		buffered =3D ath_tid_has_buffered(tid);
=20
 		tid->sched =3D false;
@@ -2184,14 +2186,15 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk=
_buff *skb,
 		txq->stopped =3D true;
 	}
=20
+	if (txctl->an)
+		tid =3D ath_get_skb_tid(sc, txctl->an, skb);
+
 	if (info->flags & IEEE80211_TX_CTL_PS_RESPONSE) {
 		ath_txq_unlock(sc, txq);
 		txq =3D sc->tx.uapsdq;
 		ath_txq_lock(sc, txq);
 	} else if (txctl->an &&
 		   ieee80211_is_data_present(hdr->frame_control)) {
-		tid =3D ath_get_skb_tid(sc, txctl->an, skb);
-
 		WARN_ON(tid->ac->txq !=3D txctl->txq);
=20
 		if (info->flags & IEEE80211_TX_CTL_CLEAR_PS_FILT)
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 3e991897d7ca..119ee6eaf1c3 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -457,7 +457,6 @@ struct brcmf_sdio {
=20
 	u8 tx_hdrlen;		/* sdio bus header length for tx packet */
 	bool txglom;		/* host tx glomming enable flag */
-	struct sk_buff *txglom_sgpad;	/* scatter-gather padding buffer */
 	u16 head_align;		/* buffer pointer alignment */
 	u16 sgentry_align;	/* scatter-gather buffer alignment */
 };
@@ -1944,9 +1943,8 @@ static int brcmf_sdio_txpkt_prep_sg(struct brcmf_sdio=
 *bus,
 	if (lastfrm && chain_pad)
 		tail_pad +=3D blksize - chain_pad;
 	if (skb_tailroom(pkt) < tail_pad && pkt->len > blksize) {
-		pkt_pad =3D bus->txglom_sgpad;
-		if (pkt_pad =3D=3D NULL)
-			  brcmu_pkt_buf_get_skb(tail_pad + tail_chop);
+		pkt_pad =3D brcmu_pkt_buf_get_skb(tail_pad + tail_chop +
+						bus->head_align);
 		if (pkt_pad =3D=3D NULL)
 			return -ENOMEM;
 		ret =3D brcmf_sdio_txpkt_hdalign(bus, pkt_pad);
@@ -1957,6 +1955,7 @@ static int brcmf_sdio_txpkt_prep_sg(struct brcmf_sdio=
 *bus,
 		       tail_chop);
 		*(u32 *)(pkt_pad->cb) =3D ALIGN_SKB_FLAG + tail_chop;
 		skb_trim(pkt, pkt->len - tail_chop);
+		skb_trim(pkt_pad, tail_pad + tail_chop);
 		__skb_queue_after(pktq, pkt, pkt_pad);
 	} else {
 		ntail =3D pkt->data_len + tail_pad -
@@ -2011,7 +2010,7 @@ brcmf_sdio_txpkt_prep(struct brcmf_sdio *bus, struct =
sk_buff_head *pktq,
 			return ret;
 		head_pad =3D (u16)ret;
 		if (head_pad)
-			memset(pkt_next->data, 0, head_pad + bus->tx_hdrlen);
+			memset(pkt_next->data + bus->tx_hdrlen, 0, head_pad);
=20
 		total_len +=3D pkt_next->len;
=20
@@ -3486,10 +3485,6 @@ static int brcmf_sdio_bus_preinit(struct device *dev)
 		bus->txglom =3D false;
 		value =3D 1;
 		pad_size =3D bus->sdiodev->func[2]->cur_blksize << 1;
-		bus->txglom_sgpad =3D brcmu_pkt_buf_get_skb(pad_size);
-		if (!bus->txglom_sgpad)
-			brcmf_err("allocating txglom padding skb failed, reduced performance\n"=
);
-
 		err =3D brcmf_iovar_data_set(bus->sdiodev->dev, "bus:rxglom",
 					   &value, sizeof(u32));
 		if (err < 0) {
@@ -4053,7 +4048,6 @@ void brcmf_sdio_remove(struct brcmf_sdio *bus)
 			brcmf_sdio_chip_detach(&bus->ci);
 		}
=20
-		brcmu_pkt_buf_free_skb(bus->txglom_sgpad);
 		kfree(bus->rxbuf);
 		kfree(bus->hdrbuf);
 		kfree(bus);
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless=
/hostap/hostap_ap.c
index d36e252d2ccb..596525528f50 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -147,7 +147,7 @@ static void ap_free_sta(struct ap_data *ap, struct sta_=
info *sta)
=20
 	if (!sta->ap && sta->u.sta.challenge)
 		kfree(sta->u.sta.challenge);
-	del_timer(&sta->timer);
+	del_timer_sync(&sta->timer);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
=20
 	kfree(sta);
diff --git a/drivers/net/wireless/iwlwifi/dvm/sta.c b/drivers/net/wireless/=
iwlwifi/dvm/sta.c
index c0d070c5df5e..9cdd91cdf661 100644
--- a/drivers/net/wireless/iwlwifi/dvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/dvm/sta.c
@@ -590,6 +590,7 @@ void iwl_deactivate_station(struct iwl_priv *priv, cons=
t u8 sta_id,
 			sizeof(priv->tid_data[sta_id][tid]));
=20
 	priv->stations[sta_id].used &=3D ~IWL_STA_DRIVER_ACTIVE;
+	priv->stations[sta_id].used &=3D ~IWL_STA_UCODE_INPROGRESS;
=20
 	priv->num_stations--;
=20
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/lib=
ertas/cfg.c
index 32f75007a825..cb6d189bc3e6 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -621,7 +621,7 @@ static int lbs_ret_scan(struct lbs_private *priv, unsig=
ned long dummy,
 			id =3D *pos++;
 			elen =3D *pos++;
 			left -=3D 2;
-			if (elen > left || elen =3D=3D 0) {
+			if (elen > left) {
 				lbs_deb_scan("scan response: invalid IE fmt\n");
 				goto done;
 			}
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwi=
fiex/pcie.c
index 03688aa14e8a..7fe7b53fb17a 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -1211,6 +1211,12 @@ static int mwifiex_pcie_process_recv_data(struct mwi=
fiex_adapter *adapter)
 		rd_index =3D card->rxbd_rdptr & reg->rx_mask;
 		skb_data =3D card->rx_buf_list[rd_index];
=20
+		/* If skb allocation was failed earlier for Rx packet,
+		 * rx_buf_list[rd_index] would have been left with a NULL.
+		 */
+		if (!skb_data)
+			return -ENOMEM;
+
 		MWIFIEX_SKB_PACB(skb_data, &buf_pa);
 		pci_unmap_single(card->dev, buf_pa, MWIFIEX_RX_DATA_BUF_SIZE,
 				 PCI_DMA_FROMDEVICE);
@@ -1525,6 +1531,14 @@ static int mwifiex_pcie_process_cmd_complete(struct =
mwifiex_adapter *adapter)
 		if (adapter->ps_state =3D=3D PS_STATE_SLEEP_CFM) {
 			mwifiex_process_sleep_confirm_resp(adapter, skb->data,
 							   skb->len);
+			mwifiex_pcie_enable_host_int(adapter);
+			if (mwifiex_write_reg(adapter,
+					      PCIE_CPU_INT_EVENT,
+					      CPU_INTR_SLEEP_CFM_DONE)) {
+				dev_warn(adapter->dev,
+					 "Write register failed\n");
+				return -1;
+			}
 			while (reg->sleep_cookie && (count++ < 10) &&
 			       mwifiex_pcie_ok_to_access_hw(adapter))
 				usleep_range(50, 60);
@@ -1993,23 +2007,9 @@ static void mwifiex_interrupt_status(struct mwifiex_=
adapter *adapter)
 		adapter->int_status |=3D pcie_ireg;
 		spin_unlock_irqrestore(&adapter->int_lock, flags);
=20
-		if (pcie_ireg & HOST_INTR_CMD_DONE) {
-			if ((adapter->ps_state =3D=3D PS_STATE_SLEEP_CFM) ||
-			    (adapter->ps_state =3D=3D PS_STATE_SLEEP)) {
-				mwifiex_pcie_enable_host_int(adapter);
-				if (mwifiex_write_reg(adapter,
-						      PCIE_CPU_INT_EVENT,
-						      CPU_INTR_SLEEP_CFM_DONE)
-						      ) {
-					dev_warn(adapter->dev,
-						 "Write register failed\n");
-					return;
-
-				}
-			}
-		} else if (!adapter->pps_uapsd_mode &&
-			   adapter->ps_state =3D=3D PS_STATE_SLEEP &&
-			   mwifiex_pcie_ok_to_access_hw(adapter)) {
+		if (!adapter->pps_uapsd_mode &&
+		    adapter->ps_state =3D=3D PS_STATE_SLEEP &&
+		    mwifiex_pcie_ok_to_access_hw(adapter)) {
 				/* Potentially for PCIe we could get other
 				 * interrupts like shared. Don't change power
 				 * state until cookie is set */
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwif=
iex/usb.c
index e8ebbd4bc3cd..cb6b70a1b34d 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -22,8 +22,6 @@
=20
 #define USB_VERSION	"1.0"
=20
-static const char usbdriver_name[] =3D "usb8xxx";
-
 static struct mwifiex_if_ops usb_ops;
 static struct semaphore add_remove_card_sem;
 static struct usb_card_rec *usb_card;
@@ -567,7 +565,7 @@ static void mwifiex_usb_disconnect(struct usb_interface=
 *intf)
 }
=20
 static struct usb_driver mwifiex_usb_driver =3D {
-	.name =3D usbdriver_name,
+	.name =3D "mwifiex_usb",
 	.probe =3D mwifiex_usb_probe,
 	.disconnect =3D mwifiex_usb_disconnect,
 	.id_table =3D mwifiex_usb_table,
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwif=
iex/wmm.c
index 13eaeed03898..981cf6e7c73b 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -559,7 +559,8 @@ mwifiex_clean_txrx(struct mwifiex_private *priv)
 	mwifiex_wmm_delete_all_ralist(priv);
 	memcpy(tos_to_tid, ac_to_tid, sizeof(tos_to_tid));
=20
-	if (priv->adapter->if_ops.clean_pcie_ring)
+	if (priv->adapter->if_ops.clean_pcie_ring &&
+	    !priv->adapter->surprise_removed)
 		priv->adapter->if_ops.clean_pcie_ring(priv->adapter);
 	spin_unlock_irqrestore(&priv->wmm.ra_list_spinlock, flags);
 }
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 3701930c6649..5e44e3179e02 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1692,14 +1692,8 @@ void ieee80211_stop_queue_by_reason(struct ieee80211=
_hw *hw, int queue,
 void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int que=
ue);
 void ieee80211_add_pending_skb(struct ieee80211_local *local,
 			       struct sk_buff *skb);
-void ieee80211_add_pending_skbs_fn(struct ieee80211_local *local,
-				   struct sk_buff_head *skbs,
-				   void (*fn)(void *data), void *data);
-static inline void ieee80211_add_pending_skbs(struct ieee80211_local *loca=
l,
-					      struct sk_buff_head *skbs)
-{
-	ieee80211_add_pending_skbs_fn(local, skbs, NULL, NULL);
-}
+void ieee80211_add_pending_skbs(struct ieee80211_local *local,
+				struct sk_buff_head *skbs);
 void ieee80211_flush_queues(struct ieee80211_local *local,
 			    struct ieee80211_sub_if_data *sdata);
=20
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index fc1d82465b3c..57d5482b10fa 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3753,6 +3753,7 @@ static int ieee80211_prep_connection(struct ieee80211=
_sub_if_data *sdata,
 		chanctx_conf =3D rcu_dereference(sdata->vif.chanctx_conf);
 		if (WARN_ON(!chanctx_conf)) {
 			rcu_read_unlock();
+			sta_info_free(local, new_sta);
 			return -EINVAL;
 		}
 		rate_flags =3D ieee80211_chandef_rate_flags(&chanctx_conf->def);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index c24ca0d0f469..3e57f96c9666 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1128,6 +1128,13 @@ static void sta_ps_end(struct sta_info *sta)
 	       sta->sta.addr, sta->sta.aid);
=20
 	if (test_sta_flag(sta, WLAN_STA_PS_DRIVER)) {
+		/*
+		 * Clear the flag only if the other one is still set
+		 * so that the TX path won't start TX'ing new frames
+		 * directly ... In the case that the driver flag isn't
+		 * set ieee80211_sta_ps_deliver_wakeup() will clear it.
+		 */
+		clear_sta_flag(sta, WLAN_STA_PS_STA);
 		ps_dbg(sta->sdata, "STA %pM aid %d driver-ps-blocked\n",
 		       sta->sta.addr, sta->sta.aid);
 		return;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index decd30c1e290..a023b432143b 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -91,7 +91,7 @@ static int sta_info_hash_del(struct ieee80211_local *loca=
l,
 	return -ENOENT;
 }
=20
-static void cleanup_single_sta(struct sta_info *sta)
+static void __cleanup_single_sta(struct sta_info *sta)
 {
 	int ac, i;
 	struct tid_ampdu_tx *tid_tx;
@@ -99,7 +99,8 @@ static void cleanup_single_sta(struct sta_info *sta)
 	struct ieee80211_local *local =3D sdata->local;
 	struct ps_data *ps;
=20
-	if (test_sta_flag(sta, WLAN_STA_PS_STA)) {
+	if (test_sta_flag(sta, WLAN_STA_PS_STA) ||
+	    test_sta_flag(sta, WLAN_STA_PS_DRIVER)) {
 		if (sta->sdata->vif.type =3D=3D NL80211_IFTYPE_AP ||
 		    sta->sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
 			ps =3D &sdata->bss->ps;
@@ -109,6 +110,7 @@ static void cleanup_single_sta(struct sta_info *sta)
 			return;
=20
 		clear_sta_flag(sta, WLAN_STA_PS_STA);
+		clear_sta_flag(sta, WLAN_STA_PS_DRIVER);
=20
 		atomic_dec(&ps->num_sta_ps);
 		sta_info_recalc_tim(sta);
@@ -139,7 +141,14 @@ static void cleanup_single_sta(struct sta_info *sta)
 		ieee80211_purge_tx_queue(&local->hw, &tid_tx->pending);
 		kfree(tid_tx);
 	}
+}
=20
+static void cleanup_single_sta(struct sta_info *sta)
+{
+	struct ieee80211_sub_if_data *sdata =3D sta->sdata;
+	struct ieee80211_local *local =3D sdata->local;
+
+	__cleanup_single_sta(sta);
 	sta_info_free(local, sta);
 }
=20
@@ -330,6 +339,7 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if=
_data *sdata,
 	rcu_read_unlock();
=20
 	spin_lock_init(&sta->lock);
+	spin_lock_init(&sta->ps_lock);
 	INIT_WORK(&sta->drv_unblock_wk, sta_unblock);
 	INIT_WORK(&sta->ampdu_mlme.work, ieee80211_ba_session_work);
 	mutex_init(&sta->ampdu_mlme.mtx);
@@ -487,21 +497,26 @@ static int sta_info_insert_finish(struct sta_info *st=
a) __acquires(RCU)
 		goto out_err;
 	}
=20
-	/* notify driver */
-	err =3D sta_info_insert_drv_state(local, sdata, sta);
-	if (err)
-		goto out_err;
-
 	local->num_sta++;
 	local->sta_generation++;
 	smp_mb();
=20
+	/* simplify things and don't accept BA sessions yet */
+	set_sta_flag(sta, WLAN_STA_BLOCK_BA);
+
 	/* make the station visible */
 	sta_info_hash_add(local, sta);
=20
 	list_add_rcu(&sta->list, &local->sta_list);
=20
+	/* notify driver */
+	err =3D sta_info_insert_drv_state(local, sdata, sta);
+	if (err)
+		goto out_remove;
+
 	set_sta_flag(sta, WLAN_STA_INSERTED);
+	/* accept BA sessions now */
+	clear_sta_flag(sta, WLAN_STA_BLOCK_BA);
=20
 	ieee80211_recalc_min_chandef(sdata);
 	ieee80211_sta_debugfs_add(sta);
@@ -522,6 +537,12 @@ static int sta_info_insert_finish(struct sta_info *sta=
) __acquires(RCU)
 		mesh_accept_plinks_update(sdata);
=20
 	return 0;
+ out_remove:
+	sta_info_hash_del(local, sta);
+	list_del_rcu(&sta->list);
+	local->num_sta--;
+	synchronize_net();
+	__cleanup_single_sta(sta);
  out_err:
 	mutex_unlock(&local->sta_mtx);
 	rcu_read_lock();
@@ -1071,10 +1092,14 @@ struct ieee80211_sta *ieee80211_find_sta(struct iee=
e80211_vif *vif,
 }
 EXPORT_SYMBOL(ieee80211_find_sta);
=20
-static void clear_sta_ps_flags(void *_sta)
+/* powersave support code */
+void ieee80211_sta_ps_deliver_wakeup(struct sta_info *sta)
 {
-	struct sta_info *sta =3D _sta;
 	struct ieee80211_sub_if_data *sdata =3D sta->sdata;
+	struct ieee80211_local *local =3D sdata->local;
+	struct sk_buff_head pending;
+	int filtered =3D 0, buffered =3D 0, ac;
+	unsigned long flags;
 	struct ps_data *ps;
=20
 	if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP ||
@@ -1085,20 +1110,6 @@ static void clear_sta_ps_flags(void *_sta)
 	else
 		return;
=20
-	clear_sta_flag(sta, WLAN_STA_PS_DRIVER);
-	if (test_and_clear_sta_flag(sta, WLAN_STA_PS_STA))
-		atomic_dec(&ps->num_sta_ps);
-}
-
-/* powersave support code */
-void ieee80211_sta_ps_deliver_wakeup(struct sta_info *sta)
-{
-	struct ieee80211_sub_if_data *sdata =3D sta->sdata;
-	struct ieee80211_local *local =3D sdata->local;
-	struct sk_buff_head pending;
-	int filtered =3D 0, buffered =3D 0, ac;
-	unsigned long flags;
-
 	clear_sta_flag(sta, WLAN_STA_SP);
=20
 	BUILD_BUG_ON(BITS_TO_LONGS(IEEE80211_NUM_TIDS) > 1);
@@ -1109,6 +1120,8 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info =
*sta)
=20
 	skb_queue_head_init(&pending);
=20
+	/* sync with ieee80211_tx_h_unicast_ps_buf */
+	spin_lock(&sta->ps_lock);
 	/* Send all buffered frames to the station */
 	for (ac =3D 0; ac < IEEE80211_NUM_ACS; ac++) {
 		int count =3D skb_queue_len(&pending), tmp;
@@ -1127,7 +1140,12 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info=
 *sta)
 		buffered +=3D tmp - count;
 	}
=20
-	ieee80211_add_pending_skbs_fn(local, &pending, clear_sta_ps_flags, sta);
+	ieee80211_add_pending_skbs(local, &pending);
+	clear_sta_flag(sta, WLAN_STA_PS_DRIVER);
+	clear_sta_flag(sta, WLAN_STA_PS_STA);
+	spin_unlock(&sta->ps_lock);
+
+	atomic_dec(&ps->num_sta_ps);
=20
 	/* This station just woke up and isn't aware of our SMPS state */
 	if (!ieee80211_smps_is_restrictive(sta->known_smps_mode,
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index d77ff7090630..d3a6d8208f2f 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -267,6 +267,7 @@ struct ieee80211_tx_latency_stat {
  * @drv_unblock_wk: used for driver PS unblocking
  * @listen_interval: listen interval of this station, when we're acting as=
 AP
  * @_flags: STA flags, see &enum ieee80211_sta_info_flags, do not use dire=
ctly
+ * @ps_lock: used for powersave (when mac80211 is the AP) related locking
  * @ps_tx_buf: buffers (per AC) of frames to transmit to this station
  *	when it leaves power saving state or polls
  * @tx_filtered: buffers (per AC) of frames we already tried to
@@ -356,10 +357,8 @@ struct sta_info {
 	/* use the accessors defined below */
 	unsigned long _flags;
=20
-	/*
-	 * STA powersave frame queues, no more than the internal
-	 * locking required.
-	 */
+	/* STA powersave lock and frame queues */
+	spinlock_t ps_lock;
 	struct sk_buff_head ps_tx_buf[IEEE80211_NUM_ACS];
 	struct sk_buff_head tx_filtered[IEEE80211_NUM_ACS];
 	unsigned long driver_buffered_tids;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 97a02d3f7d87..4080c615636f 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -478,6 +478,20 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data=
 *tx)
 		       sta->sta.addr, sta->sta.aid, ac);
 		if (tx->local->total_ps_buffered >=3D TOTAL_MAX_TX_BUFFER)
 			purge_old_ps_buffers(tx->local);
+
+		/* sync with ieee80211_sta_ps_deliver_wakeup */
+		spin_lock(&sta->ps_lock);
+		/*
+		 * STA woke up the meantime and all the frames on ps_tx_buf have
+		 * been queued to pending queue. No reordering can happen, go
+		 * ahead and Tx the packet.
+		 */
+		if (!test_sta_flag(sta, WLAN_STA_PS_STA) &&
+		    !test_sta_flag(sta, WLAN_STA_PS_DRIVER)) {
+			spin_unlock(&sta->ps_lock);
+			return TX_CONTINUE;
+		}
+
 		if (skb_queue_len(&sta->ps_tx_buf[ac]) >=3D STA_MAX_TX_BUFFER) {
 			struct sk_buff *old =3D skb_dequeue(&sta->ps_tx_buf[ac]);
 			ps_dbg(tx->sdata,
@@ -492,6 +506,7 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data =
*tx)
 		info->flags |=3D IEEE80211_TX_INTFL_NEED_TXPROCESSING;
 		info->flags &=3D ~IEEE80211_TX_TEMPORARY_FLAGS;
 		skb_queue_tail(&sta->ps_tx_buf[ac], tx->skb);
+		spin_unlock(&sta->ps_lock);
=20
 		if (!timer_pending(&local->sta_cleanup))
 			mod_timer(&local->sta_cleanup,
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 676dc0967f37..b8700d417a9c 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -435,9 +435,8 @@ void ieee80211_add_pending_skb(struct ieee80211_local *=
local,
 	spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
 }
=20
-void ieee80211_add_pending_skbs_fn(struct ieee80211_local *local,
-				   struct sk_buff_head *skbs,
-				   void (*fn)(void *data), void *data)
+void ieee80211_add_pending_skbs(struct ieee80211_local *local,
+				struct sk_buff_head *skbs)
 {
 	struct ieee80211_hw *hw =3D &local->hw;
 	struct sk_buff *skb;
@@ -461,9 +460,6 @@ void ieee80211_add_pending_skbs_fn(struct ieee80211_loc=
al *local,
 		__skb_queue_tail(&local->pending[queue], skb);
 	}
=20
-	if (fn)
-		fn(data);
-
 	for (i =3D 0; i < hw->queues; i++)
 		__ieee80211_wake_queue(hw, i,
 			IEEE80211_QUEUE_STOP_REASON_SKB_ADD);
@@ -1741,6 +1737,26 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 					IEEE80211_QUEUE_STOP_REASON_SUSPEND);
=20
 	/*
+	 * Reconfigure sched scan if it was interrupted by FW restart or
+	 * suspend.
+	 */
+	mutex_lock(&local->mtx);
+	sched_scan_sdata =3D rcu_dereference_protected(local->sched_scan_sdata,
+						lockdep_is_held(&local->mtx));
+	if (sched_scan_sdata && local->sched_scan_req)
+		/*
+		 * Sched scan stopped, but we don't want to report it. Instead,
+		 * we're trying to reschedule.
+		 */
+		if (__ieee80211_request_sched_scan_start(sched_scan_sdata,
+							 local->sched_scan_req))
+			sched_scan_stopped =3D true;
+	mutex_unlock(&local->mtx);
+
+	if (sched_scan_stopped)
+		cfg80211_sched_scan_stopped(local->hw.wiphy);
+
+	/*
 	 * If this is for hw restart things are still running.
 	 * We may want to change that later, however.
 	 */
@@ -1768,26 +1784,6 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 	WARN_ON(1);
 #endif
=20
-	/*
-	 * Reconfigure sched scan if it was interrupted by FW restart or
-	 * suspend.
-	 */
-	mutex_lock(&local->mtx);
-	sched_scan_sdata =3D rcu_dereference_protected(local->sched_scan_sdata,
-						lockdep_is_held(&local->mtx));
-	if (sched_scan_sdata && local->sched_scan_req)
-		/*
-		 * Sched scan stopped, but we don't want to report it. Instead,
-		 * we're trying to reschedule.
-		 */
-		if (__ieee80211_request_sched_scan_start(sched_scan_sdata,
-							 local->sched_scan_req))
-			sched_scan_stopped =3D true;
-	mutex_unlock(&local->mtx);
-
-	if (sched_scan_stopped)
-		cfg80211_sched_scan_stopped(local->hw.wiphy);
-
 	return 0;
 }
=20
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 21211c60ca98..d51422c778de 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -154,6 +154,11 @@ u16 ieee80211_select_queue(struct ieee80211_sub_if_dat=
a *sdata,
 		return IEEE80211_AC_BE;
 	}
=20
+	if (skb->protocol =3D=3D sdata->control_port_protocol) {
+		skb->priority =3D 7;
+		return ieee80211_downgrade_queue(sdata, skb);
+	}
+
 	/* use the data classifier to determine what 802.1d tag the
 	 * data frame has */
 	rcu_read_lock();
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 46bda010bf11..56db888b1cd5 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -301,7 +301,7 @@ static int nci_open_device(struct nci_dev *ndev)
 	rc =3D __nci_request(ndev, nci_reset_req, 0,
 			   msecs_to_jiffies(NCI_RESET_TIMEOUT));
=20
-	if (ndev->ops->setup(ndev))
+	if (ndev->ops->setup)
 		ndev->ops->setup(ndev);
=20
 	if (!rc) {
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 9b897fca7487..4c50c21d6f52 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1700,7 +1700,7 @@ static void reg_process_hint(struct regulatory_reques=
t *reg_request)
 		return;
 	case NL80211_REGDOM_SET_BY_USER:
 		treatment =3D reg_process_hint_user(reg_request);
-		if (treatment =3D=3D REG_REQ_OK ||
+		if (treatment =3D=3D REG_REQ_IGNORE ||
 		    treatment =3D=3D REG_REQ_ALREADY_SET)
 			return;
 		schedule_delayed_work(&reg_timeout, msecs_to_jiffies(3142));
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTD6PUAAoJEJctW/TcYTgGMk4P/jTqnxDPiIVBJvNx3nbQfsRT
XL+7G0uDYkZk/IbDKQMQrHdwlUwT6dxJ02Gz+gXAEGpknFu+V0oR6Sc+8yFvLwCA
yNoXjjL/IXuuYIAYZme20QKe8DIAUP4nyDIp9fMHQpxTyJliguwD7sd3HRIWvZNA
dXa0lWo6lgudAUfCxb18dbsBNAzy5Xne5HQxbS3Ilw5O7+OMraG0GekF4NI8SBXT
OVpaW+/BYfoGkmrbdyFjqWWVkmZ5auPS+rVpEoeMWNpvhcFMcCEQWA85DaTtl6JJ
5zy00QOQP6bWIsnHt3M9dJya8sG1xzxZ6aycBspuHAZ9QSGQtcyO7mVJ7upg2KJc
RC3V1JBt2kOOUF7b13NVUTvJBAk5RpAMYOPmDG3EEHvZpen2PorFTsUGSI7YF0t5
hu3thKJ5AqaVS5a7AaIsBjoCyuQGcCs3CFK9Ud/hwwZRRYsYn33uGhqvLJqd+tkU
XlXVsDs0ZkkYea3y/h74y7gEFfsU58H4NDzMBFsmwo6ZJ4x43lfUCvLgHZ6Zi/8h
0WaPNb4Psa8zPIvts+eL53Adg7Qg147mh3D5QrCAS0C23/+77gnBfR82Oy8Tb+i1
/n3zNHIgtntpbEGgr8bL6HVjWYwwG7fLMkdlWlPaXzOHoKZF3ktoy71BPTruRTAs
CPAXJgXwJml/2tiJBcqZ
=Uj67
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--
