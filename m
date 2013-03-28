From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-03-28
Date: Thu, 28 Mar 2013 15:10:58 -0400
Message-ID: <20130328191058.GA27701@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43102 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab3C1TPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 15:15:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please excuse this larger-than-I-would-like pull request intended
for the 3.9 stream.  There are a number of late-breaking fixes,
including a revert...

Regarding the mac80211 bits, Johannes says:

"I have two tracing fixes (one from Vladimir), two fixes for P2P device
crashes, a fix for a BSS memory leak/lost update problem and a fix from
Ben for a scanning issue in mac80211. It's a little on the large side
because one of the P2P device problems required a bit much locking work,
but I've run through all the different scenarios (wext/nl80211,
p2p-device/station interface, ifdown/rfkill) to verify locking with
lockdep."

As for the iwlwifi bits, Johannes says:

"I have three little fixes to the driver from Emmanuel. One addresses a
small bug Ben Hutchings found during the stable review process and two
address some warnings in the driver when RF-Kill is asserted."

Along with those...

Avinash Patil fixes an mwifiex bug cause by failing to process a sleep
command due to bad SKB manipulation when going into power saving mode.

Colin Ian King avoids a null pointer dereference in iwl4965.

Dan Williams officially announces that he has dropped maintainership
of the libertas driver.

Iestyn C. Elfick adds a work-around to avoid b43 DMA transmision
sequence error that would lead to a device reset.

Luis R. Rodriguez avoids an ath9k warning by not queueing a work item
while going to suspend mode.

Rafa=C5=82 Mi=C5=82ecki provides a pair of b43 N-PHY fixes related to RSSI
calibration.

Finally, I revert "brcmsmac: support 4313iPA" because it has been
reported in many places to cause problems with the already supported
4313ePA devices.

Please let me know if there are problems!

Thanks,

John

The following changes since commit 91c5746425aed8f7188a351f1224a26aa232e4b3:

  aoe: reserve enough headroom on skbs (2013-03-28 14:29:47 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 630a216da662ba4197e330118fc55d772a2d7ec9:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-03-28 14:40:06 -0400)

----------------------------------------------------------------

Avinash Patil (1):
      mwifiex: reset skb->data after processing PCIe sleep confirm cmd resp=
ose

Ben Greear (1):
      mac80211: Don't restart sta-timer if not associated.

Colin Ian King (1):
      iwlegacy: 4965-rs: avoid null pointer dereference error

Dan Williams (1):
      libertas: drop maintainership

Emmanuel Grumbach (3):
      iwlwifi: fix length check in multi-TB HCMD
      iwlwifi: set rfkill in internal state of the transport
      iwlwifi: dvm: don't send HCMD in restart flow

Iestyn C. Elfick (1):
      b43: A fix for DMA transmission sequence errors

Johannes Berg (6):
      mac80211: always synchronize_net() during station removal
      cfg80211: fix potential BSS memory leak and update
      mac80211: fix crash with P2P Device returning action frames
      cfg80211: fix wdev tracing crash
      mac80211: fix virtual monitor interface locking
      cfg80211: always check for scan end on P2P device

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Revert "brcmsmac: support 4313iPA"
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Luis R. Rodriguez (1):
      ath9k: avoid queueing hw check work when suspended

Rafa=C5=82 Mi=C5=82ecki (2):
      b43: N-PHY: increase initial value of "mind" in RSSI calibration
      b43: N-PHY: use more bits for offset in RSSI calibration

Vladimir Kondratiev (1):
      cfg80211: fix inconsistency in trace for rdev_set_mac_acl

 MAINTAINERS                                        |   3 +-
 drivers/net/wireless/ath/ath9k/link.c              |   3 +-
 drivers/net/wireless/b43/dma.c                     |  65 +++-
 drivers/net/wireless/b43/phy_n.c                   |   8 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  | 369 ++++++++---------=
----
 .../wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c   |  64 ++--
 drivers/net/wireless/iwlegacy/4965-rs.c            |   3 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   9 +
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |   4 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  13 +
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   2 +-
 drivers/net/wireless/mwifiex/pcie.c                |   1 +
 net/mac80211/iface.c                               |  35 +-
 net/mac80211/mesh.c                                |   3 +-
 net/mac80211/mlme.c                                |   6 +-
 net/mac80211/rx.c                                  |  14 +-
 net/mac80211/sta_info.c                            |  12 +-
 net/wireless/core.c                                |  64 +++-
 net/wireless/core.h                                |   3 +
 net/wireless/nl80211.c                             |  52 +--
 net/wireless/scan.c                                |  24 +-
 net/wireless/sme.c                                 |   6 +-
 net/wireless/trace.h                               |   5 +-
 net/wireless/wext-sme.c                            |   6 +
 24 files changed, 404 insertions(+), 370 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 72b0843..457ff5c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5059,9 +5059,8 @@ S:	Maintained
 F:	drivers/net/ethernet/marvell/sk*
=20
 MARVELL LIBERTAS WIRELESS DRIVER
-M:	Dan Williams <dcbw@redhat.com>
 L:	libertas-dev@lists.infradead.org
-S:	Maintained
+S:	Orphan
 F:	drivers/net/wireless/libertas/
=20
 MARVELL MV643XX ETHERNET DRIVER
diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/a=
th/ath9k/link.c
index 39c84ec..7fdac6c 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -170,7 +170,8 @@ void ath_rx_poll(unsigned long data)
 {
 	struct ath_softc *sc =3D (struct ath_softc *)data;
=20
-	ieee80211_queue_work(sc->hw, &sc->hw_check_work);
+	if (!test_bit(SC_OP_INVALID, &sc->sc_flags))
+		ieee80211_queue_work(sc->hw, &sc->hw_check_work);
 }
=20
 /*
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 38bc5a7..1221469 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -1487,8 +1487,12 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 	const struct b43_dma_ops *ops;
 	struct b43_dmaring *ring;
 	struct b43_dmadesc_meta *meta;
+	static const struct b43_txstatus fake; /* filled with 0 */
+	const struct b43_txstatus *txstat;
 	int slot, firstused;
 	bool frame_succeed;
+	int skip;
+	static u8 err_out1, err_out2;
=20
 	ring =3D parse_cookie(dev, status->cookie, &slot);
 	if (unlikely(!ring))
@@ -1501,13 +1505,36 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 	firstused =3D ring->current_slot - ring->used_slots + 1;
 	if (firstused < 0)
 		firstused =3D ring->nr_slots + firstused;
+
+	skip =3D 0;
 	if (unlikely(slot !=3D firstused)) {
 		/* This possibly is a firmware bug and will result in
-		 * malfunction, memory leaks and/or stall of DMA functionality. */
-		b43dbg(dev->wl, "Out of order TX status report on DMA ring %d. "
-		       "Expected %d, but got %d\n",
-		       ring->index, firstused, slot);
-		return;
+		 * malfunction, memory leaks and/or stall of DMA functionality.
+		 */
+		if (slot =3D=3D next_slot(ring, next_slot(ring, firstused))) {
+			/* If a single header/data pair was missed, skip over
+			 * the first two slots in an attempt to recover.
+			 */
+			slot =3D firstused;
+			skip =3D 2;
+			if (!err_out1) {
+				/* Report the error once. */
+				b43dbg(dev->wl,
+				       "Skip on DMA ring %d slot %d.\n",
+				       ring->index, slot);
+				err_out1 =3D 1;
+			}
+		} else {
+			/* More than a single header/data pair were missed.
+			 * Report this error once.
+			 */
+			if (!err_out2)
+				b43dbg(dev->wl,
+				       "Out of order TX status report on DMA ring %d. Expected %d, but=
 got %d\n",
+				       ring->index, firstused, slot);
+			err_out2 =3D 1;
+			return;
+		}
 	}
=20
 	ops =3D ring->ops;
@@ -1522,11 +1549,13 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 			       slot, firstused, ring->index);
 			break;
 		}
+
 		if (meta->skb) {
 			struct b43_private_tx_info *priv_info =3D
-				b43_get_priv_tx_info(IEEE80211_SKB_CB(meta->skb));
+			     b43_get_priv_tx_info(IEEE80211_SKB_CB(meta->skb));
=20
-			unmap_descbuffer(ring, meta->dmaaddr, meta->skb->len, 1);
+			unmap_descbuffer(ring, meta->dmaaddr,
+					 meta->skb->len, 1);
 			kfree(priv_info->bouncebuffer);
 			priv_info->bouncebuffer =3D NULL;
 		} else {
@@ -1538,8 +1567,9 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 			struct ieee80211_tx_info *info;
=20
 			if (unlikely(!meta->skb)) {
-				/* This is a scatter-gather fragment of a frame, so
-				 * the skb pointer must not be NULL. */
+				/* This is a scatter-gather fragment of a frame,
+				 * so the skb pointer must not be NULL.
+				 */
 				b43dbg(dev->wl, "TX status unexpected NULL skb "
 				       "at slot %d (first=3D%d) on ring %d\n",
 				       slot, firstused, ring->index);
@@ -1550,9 +1580,18 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
=20
 			/*
 			 * Call back to inform the ieee80211 subsystem about
-			 * the status of the transmission.
+			 * the status of the transmission. When skipping over
+			 * a missed TX status report, use a status structure
+			 * filled with zeros to indicate that the frame was not
+			 * sent (frame_count 0) and not acknowledged
 			 */
-			frame_succeed =3D b43_fill_txstatus_report(dev, info, status);
+			if (unlikely(skip))
+				txstat =3D &fake;
+			else
+				txstat =3D status;
+
+			frame_succeed =3D b43_fill_txstatus_report(dev, info,
+								 txstat);
 #ifdef CONFIG_B43_DEBUG
 			if (frame_succeed)
 				ring->nr_succeed_tx_packets++;
@@ -1580,12 +1619,14 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 		/* Everything unmapped and free'd. So it's not used anymore. */
 		ring->used_slots--;
=20
-		if (meta->is_last_fragment) {
+		if (meta->is_last_fragment && !skip) {
 			/* This is the last scatter-gather
 			 * fragment of the frame. We are done. */
 			break;
 		}
 		slot =3D next_slot(ring, slot);
+		if (skip > 0)
+			--skip;
 	}
 	if (ring->stopped) {
 		B43_WARN_ON(free_slots(ring) < TX_SLOTS_PER_FRAME);
diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b43/ph=
y_n.c
index 3c35382..e8486c1 100644
--- a/drivers/net/wireless/b43/phy_n.c
+++ b/drivers/net/wireless/b43/phy_n.c
@@ -1564,7 +1564,7 @@ static void b43_nphy_rev3_rssi_cal(struct b43_wldev *=
dev)
 	u16 clip_off[2] =3D { 0xFFFF, 0xFFFF };
=20
 	u8 vcm_final =3D 0;
-	s8 offset[4];
+	s32 offset[4];
 	s32 results[8][4] =3D { };
 	s32 results_min[4] =3D { };
 	s32 poll_results[4] =3D { };
@@ -1615,7 +1615,7 @@ static void b43_nphy_rev3_rssi_cal(struct b43_wldev *=
dev)
 		}
 		for (i =3D 0; i < 4; i +=3D 2) {
 			s32 curr;
-			s32 mind =3D 40;
+			s32 mind =3D 0x100000;
 			s32 minpoll =3D 249;
 			u8 minvcm =3D 0;
 			if (2 * core !=3D i)
@@ -1732,7 +1732,7 @@ static void b43_nphy_rev2_rssi_cal(struct b43_wldev *=
dev, u8 type)
 	u8 regs_save_radio[2];
 	u16 regs_save_phy[2];
=20
-	s8 offset[4];
+	s32 offset[4];
 	u8 core;
 	u8 rail;
=20
@@ -1799,7 +1799,7 @@ static void b43_nphy_rev2_rssi_cal(struct b43_wldev *=
dev, u8 type)
 	}
=20
 	for (i =3D 0; i < 4; i++) {
-		s32 mind =3D 40;
+		s32 mind =3D 0x100000;
 		u8 minvcm =3D 0;
 		s32 minpoll =3D 249;
 		s32 curr;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/driver=
s/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
index 21a8242..18d3764 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
@@ -1137,9 +1137,8 @@ wlc_lcnphy_set_rx_gain_by_distribution(struct brcms_p=
hy *pi,
 	gain0_15 =3D ((biq1 & 0xf) << 12) |
 		   ((tia & 0xf) << 8) |
 		   ((lna2 & 0x3) << 6) |
-		   ((lna2 & 0x3) << 4) |
-		   ((lna1 & 0x3) << 2) |
-		   ((lna1 & 0x3) << 0);
+		   ((lna2 &
+		     0x3) << 4) | ((lna1 & 0x3) << 2) | ((lna1 & 0x3) << 0);
=20
 	mod_phy_reg(pi, 0x4b6, (0xffff << 0), gain0_15 << 0);
 	mod_phy_reg(pi, 0x4b7, (0xf << 0), gain16_19 << 0);
@@ -1157,8 +1156,6 @@ wlc_lcnphy_set_rx_gain_by_distribution(struct brcms_p=
hy *pi,
 	}
=20
 	mod_phy_reg(pi, 0x44d, (0x1 << 0), (!trsw) << 0);
-	mod_phy_reg(pi, 0x4b1, (0x3 << 11), lna1 << 11);
-	mod_phy_reg(pi, 0x4e6, (0x3 << 3), lna1 << 3);
=20
 }
=20
@@ -1331,43 +1328,6 @@ static u32 wlc_lcnphy_measure_digital_power(struct b=
rcms_phy *pi, u16 nsamples)
 	return (iq_est.i_pwr + iq_est.q_pwr) / nsamples;
 }
=20
-static bool wlc_lcnphy_rx_iq_cal_gain(struct brcms_phy *pi, u16 biq1_gain,
-				      u16 tia_gain, u16 lna2_gain)
-{
-	u32 i_thresh_l, q_thresh_l;
-	u32 i_thresh_h, q_thresh_h;
-	struct lcnphy_iq_est iq_est_h, iq_est_l;
-
-	wlc_lcnphy_set_rx_gain_by_distribution(pi, 0, 0, 0, biq1_gain, tia_gain,
-					       lna2_gain, 0);
-
-	wlc_lcnphy_rx_gain_override_enable(pi, true);
-	wlc_lcnphy_start_tx_tone(pi, 2000, (40 >> 1), 0);
-	udelay(500);
-	write_radio_reg(pi, RADIO_2064_REG112, 0);
-	if (!wlc_lcnphy_rx_iq_est(pi, 1024, 32, &iq_est_l))
-		return false;
-
-	wlc_lcnphy_start_tx_tone(pi, 2000, 40, 0);
-	udelay(500);
-	write_radio_reg(pi, RADIO_2064_REG112, 0);
-	if (!wlc_lcnphy_rx_iq_est(pi, 1024, 32, &iq_est_h))
-		return false;
-
-	i_thresh_l =3D (iq_est_l.i_pwr << 1);
-	i_thresh_h =3D (iq_est_l.i_pwr << 2) + iq_est_l.i_pwr;
-
-	q_thresh_l =3D (iq_est_l.q_pwr << 1);
-	q_thresh_h =3D (iq_est_l.q_pwr << 2) + iq_est_l.q_pwr;
-	if ((iq_est_h.i_pwr > i_thresh_l) &&
-	    (iq_est_h.i_pwr < i_thresh_h) &&
-	    (iq_est_h.q_pwr > q_thresh_l) &&
-	    (iq_est_h.q_pwr < q_thresh_h))
-		return true;
-
-	return false;
-}
-
 static bool
 wlc_lcnphy_rx_iq_cal(struct brcms_phy *pi,
 		     const struct lcnphy_rx_iqcomp *iqcomp,
@@ -1382,8 +1342,8 @@ wlc_lcnphy_rx_iq_cal(struct brcms_phy *pi,
 	    RFOverrideVal0_old, rfoverride2_old, rfoverride2val_old,
 	    rfoverride3_old, rfoverride3val_old, rfoverride4_old,
 	    rfoverride4val_old, afectrlovr_old, afectrlovrval_old;
-	int tia_gain, lna2_gain, biq1_gain;
-	bool set_gain;
+	int tia_gain;
+	u32 received_power, rx_pwr_threshold;
 	u16 old_sslpnCalibClkEnCtrl, old_sslpnRxFeClkEnCtrl;
 	u16 values_to_save[11];
 	s16 *ptr;
@@ -1408,134 +1368,126 @@ wlc_lcnphy_rx_iq_cal(struct brcms_phy *pi,
 		goto cal_done;
 	}
=20
-	WARN_ON(module !=3D 1);
-	tx_pwr_ctrl =3D wlc_lcnphy_get_tx_pwr_ctrl(pi);
-	wlc_lcnphy_set_tx_pwr_ctrl(pi, LCNPHY_TX_PWR_CTRL_OFF);
-
-	for (i =3D 0; i < 11; i++)
-		values_to_save[i] =3D
-			read_radio_reg(pi, rxiq_cal_rf_reg[i]);
-	Core1TxControl_old =3D read_phy_reg(pi, 0x631);
-
-	or_phy_reg(pi, 0x631, 0x0015);
-
-	RFOverride0_old =3D read_phy_reg(pi, 0x44c);
-	RFOverrideVal0_old =3D read_phy_reg(pi, 0x44d);
-	rfoverride2_old =3D read_phy_reg(pi, 0x4b0);
-	rfoverride2val_old =3D read_phy_reg(pi, 0x4b1);
-	rfoverride3_old =3D read_phy_reg(pi, 0x4f9);
-	rfoverride3val_old =3D read_phy_reg(pi, 0x4fa);
-	rfoverride4_old =3D read_phy_reg(pi, 0x938);
-	rfoverride4val_old =3D read_phy_reg(pi, 0x939);
-	afectrlovr_old =3D read_phy_reg(pi, 0x43b);
-	afectrlovrval_old =3D read_phy_reg(pi, 0x43c);
-	old_sslpnCalibClkEnCtrl =3D read_phy_reg(pi, 0x6da);
-	old_sslpnRxFeClkEnCtrl =3D read_phy_reg(pi, 0x6db);
-
-	tx_gain_override_old =3D wlc_lcnphy_tx_gain_override_enabled(pi);
-	if (tx_gain_override_old) {
-		wlc_lcnphy_get_tx_gain(pi, &old_gains);
-		tx_gain_index_old =3D pi_lcn->lcnphy_current_index;
-	}
-
-	wlc_lcnphy_set_tx_pwr_by_index(pi, tx_gain_idx);
+	if (module =3D=3D 1) {
=20
-	mod_phy_reg(pi, 0x4f9, (0x1 << 0), 1 << 0);
-	mod_phy_reg(pi, 0x4fa, (0x1 << 0), 0 << 0);
+		tx_pwr_ctrl =3D wlc_lcnphy_get_tx_pwr_ctrl(pi);
+		wlc_lcnphy_set_tx_pwr_ctrl(pi, LCNPHY_TX_PWR_CTRL_OFF);
=20
-	mod_phy_reg(pi, 0x43b, (0x1 << 1), 1 << 1);
-	mod_phy_reg(pi, 0x43c, (0x1 << 1), 0 << 1);
+		for (i =3D 0; i < 11; i++)
+			values_to_save[i] =3D
+				read_radio_reg(pi, rxiq_cal_rf_reg[i]);
+		Core1TxControl_old =3D read_phy_reg(pi, 0x631);
+
+		or_phy_reg(pi, 0x631, 0x0015);
+
+		RFOverride0_old =3D read_phy_reg(pi, 0x44c);
+		RFOverrideVal0_old =3D read_phy_reg(pi, 0x44d);
+		rfoverride2_old =3D read_phy_reg(pi, 0x4b0);
+		rfoverride2val_old =3D read_phy_reg(pi, 0x4b1);
+		rfoverride3_old =3D read_phy_reg(pi, 0x4f9);
+		rfoverride3val_old =3D read_phy_reg(pi, 0x4fa);
+		rfoverride4_old =3D read_phy_reg(pi, 0x938);
+		rfoverride4val_old =3D read_phy_reg(pi, 0x939);
+		afectrlovr_old =3D read_phy_reg(pi, 0x43b);
+		afectrlovrval_old =3D read_phy_reg(pi, 0x43c);
+		old_sslpnCalibClkEnCtrl =3D read_phy_reg(pi, 0x6da);
+		old_sslpnRxFeClkEnCtrl =3D read_phy_reg(pi, 0x6db);
+
+		tx_gain_override_old =3D wlc_lcnphy_tx_gain_override_enabled(pi);
+		if (tx_gain_override_old) {
+			wlc_lcnphy_get_tx_gain(pi, &old_gains);
+			tx_gain_index_old =3D pi_lcn->lcnphy_current_index;
+		}
=20
-	write_radio_reg(pi, RADIO_2064_REG116, 0x06);
-	write_radio_reg(pi, RADIO_2064_REG12C, 0x07);
-	write_radio_reg(pi, RADIO_2064_REG06A, 0xd3);
-	write_radio_reg(pi, RADIO_2064_REG098, 0x03);
-	write_radio_reg(pi, RADIO_2064_REG00B, 0x7);
-	mod_radio_reg(pi, RADIO_2064_REG113, 1 << 4, 1 << 4);
-	write_radio_reg(pi, RADIO_2064_REG01D, 0x01);
-	write_radio_reg(pi, RADIO_2064_REG114, 0x01);
-	write_radio_reg(pi, RADIO_2064_REG02E, 0x10);
-	write_radio_reg(pi, RADIO_2064_REG12A, 0x08);
-
-	mod_phy_reg(pi, 0x938, (0x1 << 0), 1 << 0);
-	mod_phy_reg(pi, 0x939, (0x1 << 0), 0 << 0);
-	mod_phy_reg(pi, 0x938, (0x1 << 1), 1 << 1);
-	mod_phy_reg(pi, 0x939, (0x1 << 1), 1 << 1);
-	mod_phy_reg(pi, 0x938, (0x1 << 2), 1 << 2);
-	mod_phy_reg(pi, 0x939, (0x1 << 2), 1 << 2);
-	mod_phy_reg(pi, 0x938, (0x1 << 3), 1 << 3);
-	mod_phy_reg(pi, 0x939, (0x1 << 3), 1 << 3);
-	mod_phy_reg(pi, 0x938, (0x1 << 5), 1 << 5);
-	mod_phy_reg(pi, 0x939, (0x1 << 5), 0 << 5);
+		wlc_lcnphy_set_tx_pwr_by_index(pi, tx_gain_idx);
=20
-	mod_phy_reg(pi, 0x43b, (0x1 << 0), 1 << 0);
-	mod_phy_reg(pi, 0x43c, (0x1 << 0), 0 << 0);
+		mod_phy_reg(pi, 0x4f9, (0x1 << 0), 1 << 0);
+		mod_phy_reg(pi, 0x4fa, (0x1 << 0), 0 << 0);
=20
-	write_phy_reg(pi, 0x6da, 0xffff);
-	or_phy_reg(pi, 0x6db, 0x3);
+		mod_phy_reg(pi, 0x43b, (0x1 << 1), 1 << 1);
+		mod_phy_reg(pi, 0x43c, (0x1 << 1), 0 << 1);
=20
-	wlc_lcnphy_set_trsw_override(pi, tx_switch, rx_switch);
-	set_gain =3D false;
-
-	lna2_gain =3D 3;
-	while ((lna2_gain >=3D 0) && !set_gain) {
-		tia_gain =3D 4;
-
-		while ((tia_gain >=3D 0) && !set_gain) {
-			biq1_gain =3D 6;
-
-			while ((biq1_gain >=3D 0) && !set_gain) {
-				set_gain =3D wlc_lcnphy_rx_iq_cal_gain(pi,
-								     (u16)
-								     biq1_gain,
-								     (u16)
-								     tia_gain,
-								     (u16)
-								     lna2_gain);
-				biq1_gain -=3D 1;
-			}
+		write_radio_reg(pi, RADIO_2064_REG116, 0x06);
+		write_radio_reg(pi, RADIO_2064_REG12C, 0x07);
+		write_radio_reg(pi, RADIO_2064_REG06A, 0xd3);
+		write_radio_reg(pi, RADIO_2064_REG098, 0x03);
+		write_radio_reg(pi, RADIO_2064_REG00B, 0x7);
+		mod_radio_reg(pi, RADIO_2064_REG113, 1 << 4, 1 << 4);
+		write_radio_reg(pi, RADIO_2064_REG01D, 0x01);
+		write_radio_reg(pi, RADIO_2064_REG114, 0x01);
+		write_radio_reg(pi, RADIO_2064_REG02E, 0x10);
+		write_radio_reg(pi, RADIO_2064_REG12A, 0x08);
+
+		mod_phy_reg(pi, 0x938, (0x1 << 0), 1 << 0);
+		mod_phy_reg(pi, 0x939, (0x1 << 0), 0 << 0);
+		mod_phy_reg(pi, 0x938, (0x1 << 1), 1 << 1);
+		mod_phy_reg(pi, 0x939, (0x1 << 1), 1 << 1);
+		mod_phy_reg(pi, 0x938, (0x1 << 2), 1 << 2);
+		mod_phy_reg(pi, 0x939, (0x1 << 2), 1 << 2);
+		mod_phy_reg(pi, 0x938, (0x1 << 3), 1 << 3);
+		mod_phy_reg(pi, 0x939, (0x1 << 3), 1 << 3);
+		mod_phy_reg(pi, 0x938, (0x1 << 5), 1 << 5);
+		mod_phy_reg(pi, 0x939, (0x1 << 5), 0 << 5);
+
+		mod_phy_reg(pi, 0x43b, (0x1 << 0), 1 << 0);
+		mod_phy_reg(pi, 0x43c, (0x1 << 0), 0 << 0);
+
+		wlc_lcnphy_start_tx_tone(pi, 2000, 120, 0);
+		write_phy_reg(pi, 0x6da, 0xffff);
+		or_phy_reg(pi, 0x6db, 0x3);
+		wlc_lcnphy_set_trsw_override(pi, tx_switch, rx_switch);
+		wlc_lcnphy_rx_gain_override_enable(pi, true);
+
+		tia_gain =3D 8;
+		rx_pwr_threshold =3D 950;
+		while (tia_gain > 0) {
 			tia_gain -=3D 1;
+			wlc_lcnphy_set_rx_gain_by_distribution(pi,
+							       0, 0, 2, 2,
+							       (u16)
+							       tia_gain, 1, 0);
+			udelay(500);
+
+			received_power =3D
+				wlc_lcnphy_measure_digital_power(pi, 2000);
+			if (received_power < rx_pwr_threshold)
+				break;
 		}
-		lna2_gain -=3D 1;
-	}
+		result =3D wlc_lcnphy_calc_rx_iq_comp(pi, 0xffff);
=20
-	if (set_gain)
-		result =3D wlc_lcnphy_calc_rx_iq_comp(pi, 1024);
-	else
-		result =3D false;
+		wlc_lcnphy_stop_tx_tone(pi);
=20
-	wlc_lcnphy_stop_tx_tone(pi);
+		write_phy_reg(pi, 0x631, Core1TxControl_old);
=20
-	write_phy_reg(pi, 0x631, Core1TxControl_old);
-
-	write_phy_reg(pi, 0x44c, RFOverrideVal0_old);
-	write_phy_reg(pi, 0x44d, RFOverrideVal0_old);
-	write_phy_reg(pi, 0x4b0, rfoverride2_old);
-	write_phy_reg(pi, 0x4b1, rfoverride2val_old);
-	write_phy_reg(pi, 0x4f9, rfoverride3_old);
-	write_phy_reg(pi, 0x4fa, rfoverride3val_old);
-	write_phy_reg(pi, 0x938, rfoverride4_old);
-	write_phy_reg(pi, 0x939, rfoverride4val_old);
-	write_phy_reg(pi, 0x43b, afectrlovr_old);
-	write_phy_reg(pi, 0x43c, afectrlovrval_old);
-	write_phy_reg(pi, 0x6da, old_sslpnCalibClkEnCtrl);
-	write_phy_reg(pi, 0x6db, old_sslpnRxFeClkEnCtrl);
+		write_phy_reg(pi, 0x44c, RFOverrideVal0_old);
+		write_phy_reg(pi, 0x44d, RFOverrideVal0_old);
+		write_phy_reg(pi, 0x4b0, rfoverride2_old);
+		write_phy_reg(pi, 0x4b1, rfoverride2val_old);
+		write_phy_reg(pi, 0x4f9, rfoverride3_old);
+		write_phy_reg(pi, 0x4fa, rfoverride3val_old);
+		write_phy_reg(pi, 0x938, rfoverride4_old);
+		write_phy_reg(pi, 0x939, rfoverride4val_old);
+		write_phy_reg(pi, 0x43b, afectrlovr_old);
+		write_phy_reg(pi, 0x43c, afectrlovrval_old);
+		write_phy_reg(pi, 0x6da, old_sslpnCalibClkEnCtrl);
+		write_phy_reg(pi, 0x6db, old_sslpnRxFeClkEnCtrl);
=20
-	wlc_lcnphy_clear_trsw_override(pi);
+		wlc_lcnphy_clear_trsw_override(pi);
=20
-	mod_phy_reg(pi, 0x44c, (0x1 << 2), 0 << 2);
+		mod_phy_reg(pi, 0x44c, (0x1 << 2), 0 << 2);
=20
-	for (i =3D 0; i < 11; i++)
-		write_radio_reg(pi, rxiq_cal_rf_reg[i],
-				values_to_save[i]);
+		for (i =3D 0; i < 11; i++)
+			write_radio_reg(pi, rxiq_cal_rf_reg[i],
+					values_to_save[i]);
=20
-	if (tx_gain_override_old)
-		wlc_lcnphy_set_tx_pwr_by_index(pi, tx_gain_index_old);
-	else
-		wlc_lcnphy_disable_tx_gain_override(pi);
+		if (tx_gain_override_old)
+			wlc_lcnphy_set_tx_pwr_by_index(pi, tx_gain_index_old);
+		else
+			wlc_lcnphy_disable_tx_gain_override(pi);
=20
-	wlc_lcnphy_set_tx_pwr_ctrl(pi, tx_pwr_ctrl);
-	wlc_lcnphy_rx_gain_override_enable(pi, false);
+		wlc_lcnphy_set_tx_pwr_ctrl(pi, tx_pwr_ctrl);
+		wlc_lcnphy_rx_gain_override_enable(pi, false);
+	}
=20
 cal_done:
 	kfree(ptr);
@@ -1829,17 +1781,6 @@ wlc_lcnphy_radio_2064_channel_tune_4313(struct brcms=
_phy *pi, u8 channel)
 		write_radio_reg(pi, RADIO_2064_REG038, 3);
 		write_radio_reg(pi, RADIO_2064_REG091, 7);
 	}
-
-	if (!(pi->sh->boardflags & BFL_FEM)) {
-		u8 reg038[14] =3D {0xd, 0xe, 0xd, 0xd, 0xd, 0xc,
-			0xa, 0xb, 0xb, 0x3, 0x3, 0x2, 0x0, 0x0};
-
-		write_radio_reg(pi, RADIO_2064_REG02A, 0xf);
-		write_radio_reg(pi, RADIO_2064_REG091, 0x3);
-		write_radio_reg(pi, RADIO_2064_REG038, 0x3);
-
-		write_radio_reg(pi, RADIO_2064_REG038, reg038[channel - 1]);
-	}
 }
=20
 static int
@@ -2034,16 +1975,6 @@ wlc_lcnphy_set_tssi_mux(struct brcms_phy *pi, enum l=
cnphy_tssi_mode pos)
 		} else {
 			mod_radio_reg(pi, RADIO_2064_REG03A, 1, 0x1);
 			mod_radio_reg(pi, RADIO_2064_REG11A, 0x8, 0x8);
-			mod_radio_reg(pi, RADIO_2064_REG028, 0x1, 0x0);
-			mod_radio_reg(pi, RADIO_2064_REG11A, 0x4, 1<<2);
-			mod_radio_reg(pi, RADIO_2064_REG036, 0x10, 0x0);
-			mod_radio_reg(pi, RADIO_2064_REG11A, 0x10, 1<<4);
-			mod_radio_reg(pi, RADIO_2064_REG036, 0x3, 0x0);
-			mod_radio_reg(pi, RADIO_2064_REG035, 0xff, 0x77);
-			mod_radio_reg(pi, RADIO_2064_REG028, 0x1e, 0xe<<1);
-			mod_radio_reg(pi, RADIO_2064_REG112, 0x80, 1<<7);
-			mod_radio_reg(pi, RADIO_2064_REG005, 0x7, 1<<1);
-			mod_radio_reg(pi, RADIO_2064_REG029, 0xf0, 0<<4);
 		}
 	} else {
 		mod_phy_reg(pi, 0x4d9, (0x1 << 2), (0x1) << 2);
@@ -2130,14 +2061,12 @@ static void wlc_lcnphy_pwrctrl_rssiparams(struct br=
cms_phy *pi)
 		    (auxpga_vmid_temp << 0) | (auxpga_gain_temp << 12));
=20
 	mod_radio_reg(pi, RADIO_2064_REG082, (1 << 5), (1 << 5));
-	mod_radio_reg(pi, RADIO_2064_REG07C, (1 << 0), (1 << 0));
 }
=20
 static void wlc_lcnphy_tssi_setup(struct brcms_phy *pi)
 {
 	struct phytbl_info tab;
 	u32 rfseq, ind;
-	u8 tssi_sel;
=20
 	tab.tbl_id =3D LCNPHY_TBL_ID_TXPWRCTL;
 	tab.tbl_width =3D 32;
@@ -2159,13 +2088,7 @@ static void wlc_lcnphy_tssi_setup(struct brcms_phy *=
pi)
=20
 	mod_phy_reg(pi, 0x503, (0x1 << 4), (1) << 4);
=20
-	if (pi->sh->boardflags & BFL_FEM) {
-		tssi_sel =3D 0x1;
-		wlc_lcnphy_set_tssi_mux(pi, LCNPHY_TSSI_EXT);
-	} else {
-		tssi_sel =3D 0xe;
-		wlc_lcnphy_set_tssi_mux(pi, LCNPHY_TSSI_POST_PA);
-	}
+	wlc_lcnphy_set_tssi_mux(pi, LCNPHY_TSSI_EXT);
 	mod_phy_reg(pi, 0x4a4, (0x1 << 14), (0) << 14);
=20
 	mod_phy_reg(pi, 0x4a4, (0x1 << 15), (1) << 15);
@@ -2201,10 +2124,9 @@ static void wlc_lcnphy_tssi_setup(struct brcms_phy *=
pi)
 	mod_phy_reg(pi, 0x49a, (0x1ff << 0), (0xff) << 0);
=20
 	if (LCNREV_IS(pi->pubpi.phy_rev, 2)) {
-		mod_radio_reg(pi, RADIO_2064_REG028, 0xf, tssi_sel);
+		mod_radio_reg(pi, RADIO_2064_REG028, 0xf, 0xe);
 		mod_radio_reg(pi, RADIO_2064_REG086, 0x4, 0x4);
 	} else {
-		mod_radio_reg(pi, RADIO_2064_REG028, 0x1e, tssi_sel << 1);
 		mod_radio_reg(pi, RADIO_2064_REG03A, 0x1, 1);
 		mod_radio_reg(pi, RADIO_2064_REG11A, 0x8, 1 << 3);
 	}
@@ -2251,10 +2173,6 @@ static void wlc_lcnphy_tssi_setup(struct brcms_phy *=
pi)
=20
 	mod_phy_reg(pi, 0x4d7, (0xf << 8), (0) << 8);
=20
-	mod_radio_reg(pi, RADIO_2064_REG035, 0xff, 0x0);
-	mod_radio_reg(pi, RADIO_2064_REG036, 0x3, 0x0);
-	mod_radio_reg(pi, RADIO_2064_REG11A, 0x8, 0x8);
-
 	wlc_lcnphy_pwrctrl_rssiparams(pi);
 }
=20
@@ -2873,8 +2791,6 @@ static void wlc_lcnphy_idle_tssi_est(struct brcms_phy=
_pub *ppi)
 		read_radio_reg(pi, RADIO_2064_REG007) & 1;
 	u16 SAVE_jtag_auxpga =3D read_radio_reg(pi, RADIO_2064_REG0FF) & 0x10;
 	u16 SAVE_iqadc_aux_en =3D read_radio_reg(pi, RADIO_2064_REG11F) & 4;
-	u8 SAVE_bbmult =3D wlc_lcnphy_get_bbmult(pi);
-
 	idleTssi =3D read_phy_reg(pi, 0x4ab);
 	suspend =3D (0 =3D=3D (bcma_read32(pi->d11core, D11REGOFFS(maccontrol)) &
 			 MCTL_EN_MAC));
@@ -2892,12 +2808,6 @@ static void wlc_lcnphy_idle_tssi_est(struct brcms_ph=
y_pub *ppi)
 	mod_radio_reg(pi, RADIO_2064_REG0FF, 0x10, 1 << 4);
 	mod_radio_reg(pi, RADIO_2064_REG11F, 0x4, 1 << 2);
 	wlc_lcnphy_tssi_setup(pi);
-
-	mod_phy_reg(pi, 0x4d7, (0x1 << 0), (1 << 0));
-	mod_phy_reg(pi, 0x4d7, (0x1 << 6), (1 << 6));
-
-	wlc_lcnphy_set_bbmult(pi, 0x0);
-
 	wlc_phy_do_dummy_tx(pi, true, OFF);
 	idleTssi =3D ((read_phy_reg(pi, 0x4ab) & (0x1ff << 0))
 		    >> 0);
@@ -2919,7 +2829,6 @@ static void wlc_lcnphy_idle_tssi_est(struct brcms_phy=
_pub *ppi)
=20
 	mod_phy_reg(pi, 0x44c, (0x1 << 12), (0) << 12);
=20
-	wlc_lcnphy_set_bbmult(pi, SAVE_bbmult);
 	wlc_lcnphy_set_tx_gain_override(pi, tx_gain_override_old);
 	wlc_lcnphy_set_tx_gain(pi, &old_gains);
 	wlc_lcnphy_set_tx_pwr_ctrl(pi, SAVE_txpwrctrl);
@@ -3133,11 +3042,6 @@ static void wlc_lcnphy_tx_pwr_ctrl_init(struct brcms=
_phy_pub *ppi)
 			wlc_lcnphy_write_table(pi, &tab);
 			tab.tbl_offset++;
 		}
-		mod_phy_reg(pi, 0x4d0, (0x1 << 0), (0) << 0);
-		mod_phy_reg(pi, 0x4d3, (0xff << 0), (0) << 0);
-		mod_phy_reg(pi, 0x4d3, (0xff << 8), (0) << 8);
-		mod_phy_reg(pi, 0x4d0, (0x1 << 4), (0) << 4);
-		mod_phy_reg(pi, 0x4d0, (0x1 << 2), (0) << 2);
=20
 		mod_phy_reg(pi, 0x410, (0x1 << 7), (0) << 7);
=20
@@ -3939,6 +3843,7 @@ static void wlc_lcnphy_txpwrtbl_iqlo_cal(struct brcms=
_phy *pi)
 	target_gains.pad_gain =3D 21;
 	target_gains.dac_gain =3D 0;
 	wlc_lcnphy_set_tx_gain(pi, &target_gains);
+	wlc_lcnphy_set_tx_pwr_by_index(pi, 16);
=20
 	if (LCNREV_IS(pi->pubpi.phy_rev, 1) || pi_lcn->lcnphy_hw_iqcal_en) {
=20
@@ -3949,7 +3854,6 @@ static void wlc_lcnphy_txpwrtbl_iqlo_cal(struct brcms=
_phy *pi)
 					lcnphy_recal ? LCNPHY_CAL_RECAL :
 					LCNPHY_CAL_FULL), false);
 	} else {
-		wlc_lcnphy_set_tx_pwr_by_index(pi, 16);
 		wlc_lcnphy_tx_iqlo_soft_cal_full(pi);
 	}
=20
@@ -4374,22 +4278,17 @@ wlc_lcnphy_load_tx_gain_table(struct brcms_phy *pi,
 	if (CHSPEC_IS5G(pi->radio_chanspec))
 		pa_gain =3D 0x70;
 	else
-		pa_gain =3D 0x60;
+		pa_gain =3D 0x70;
=20
 	if (pi->sh->boardflags & BFL_FEM)
 		pa_gain =3D 0x10;
-
 	tab.tbl_id =3D LCNPHY_TBL_ID_TXPWRCTL;
 	tab.tbl_width =3D 32;
 	tab.tbl_len =3D 1;
 	tab.tbl_ptr =3D &val;
=20
 	for (j =3D 0; j < 128; j++) {
-		if (pi->sh->boardflags & BFL_FEM)
-			gm_gain =3D gain_table[j].gm;
-		else
-			gm_gain =3D 15;
-
+		gm_gain =3D gain_table[j].gm;
 		val =3D (((u32) pa_gain << 24) |
 		       (gain_table[j].pad << 16) |
 		       (gain_table[j].pga << 8) | gm_gain);
@@ -4600,10 +4499,7 @@ static void wlc_radio_2064_init(struct brcms_phy *pi)
=20
 	write_phy_reg(pi, 0x4ea, 0x4688);
=20
-	if (pi->sh->boardflags & BFL_FEM)
-		mod_phy_reg(pi, 0x4eb, (0x7 << 0), 2 << 0);
-	else
-		mod_phy_reg(pi, 0x4eb, (0x7 << 0), 3 << 0);
+	mod_phy_reg(pi, 0x4eb, (0x7 << 0), 2 << 0);
=20
 	mod_phy_reg(pi, 0x4eb, (0x7 << 6), 0 << 6);
=20
@@ -4614,13 +4510,6 @@ static void wlc_radio_2064_init(struct brcms_phy *pi)
 	wlc_lcnphy_rcal(pi);
=20
 	wlc_lcnphy_rc_cal(pi);
-
-	if (!(pi->sh->boardflags & BFL_FEM)) {
-		write_radio_reg(pi, RADIO_2064_REG032, 0x6f);
-		write_radio_reg(pi, RADIO_2064_REG033, 0x19);
-		write_radio_reg(pi, RADIO_2064_REG039, 0xe);
-	}
-
 }
=20
 static void wlc_lcnphy_radio_init(struct brcms_phy *pi)
@@ -4650,20 +4539,22 @@ static void wlc_lcnphy_tbl_init(struct brcms_phy *p=
i)
 		wlc_lcnphy_write_table(pi, &tab);
 	}
=20
-	if (!(pi->sh->boardflags & BFL_FEM)) {
-		tab.tbl_id =3D LCNPHY_TBL_ID_RFSEQ;
-		tab.tbl_width =3D 16;
-		tab.tbl_ptr =3D &val;
-		tab.tbl_len =3D 1;
+	tab.tbl_id =3D LCNPHY_TBL_ID_RFSEQ;
+	tab.tbl_width =3D 16;
+	tab.tbl_ptr =3D &val;
+	tab.tbl_len =3D 1;
=20
-		val =3D 150;
-		tab.tbl_offset =3D 0;
-		wlc_lcnphy_write_table(pi, &tab);
+	val =3D 114;
+	tab.tbl_offset =3D 0;
+	wlc_lcnphy_write_table(pi, &tab);
=20
-		val =3D 220;
-		tab.tbl_offset =3D 1;
-		wlc_lcnphy_write_table(pi, &tab);
-	}
+	val =3D 130;
+	tab.tbl_offset =3D 1;
+	wlc_lcnphy_write_table(pi, &tab);
+
+	val =3D 6;
+	tab.tbl_offset =3D 8;
+	wlc_lcnphy_write_table(pi, &tab);
=20
 	if (CHSPEC_IS2G(pi->radio_chanspec)) {
 		if (pi->sh->boardflags & BFL_FEM)
@@ -5055,7 +4946,6 @@ void wlc_phy_chanspec_set_lcnphy(struct brcms_phy *pi=
, u16 chanspec)
 		wlc_lcnphy_load_tx_iir_filter(pi, true, 3);
=20
 	mod_phy_reg(pi, 0x4eb, (0x7 << 3), (1) << 3);
-	wlc_lcnphy_tssi_setup(pi);
 }
=20
 void wlc_phy_detach_lcnphy(struct brcms_phy *pi)
@@ -5094,7 +4984,8 @@ bool wlc_phy_attach_lcnphy(struct brcms_phy *pi)
 	if (!wlc_phy_txpwr_srom_read_lcnphy(pi))
 		return false;
=20
-	if (LCNREV_IS(pi->pubpi.phy_rev, 1)) {
+	if ((pi->sh->boardflags & BFL_FEM) &&
+	    (LCNREV_IS(pi->pubpi.phy_rev, 1))) {
 		if (pi_lcn->lcnphy_tempsense_option =3D=3D 3) {
 			pi->hwpwrctrl =3D true;
 			pi->hwpwrctrl_capable =3D true;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c b/dri=
vers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c
index b7e95ac..622c01c 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c
@@ -1992,70 +1992,70 @@ static const u16 dot11lcn_sw_ctrl_tbl_4313_epa_rev0=
[] =3D {
 };
=20
 static const u16 dot11lcn_sw_ctrl_tbl_4313_rev0[] =3D {
-	0x0009,
 	0x000a,
-	0x0005,
-	0x0006,
 	0x0009,
-	0x000a,
-	0x0005,
 	0x0006,
-	0x0009,
-	0x000a,
 	0x0005,
-	0x0006,
-	0x0009,
 	0x000a,
-	0x0005,
-	0x0006,
 	0x0009,
-	0x000a,
-	0x0005,
 	0x0006,
-	0x0009,
-	0x000a,
 	0x0005,
-	0x0006,
-	0x0009,
 	0x000a,
-	0x0005,
-	0x0006,
 	0x0009,
-	0x000a,
-	0x0005,
 	0x0006,
-	0x0009,
-	0x000a,
 	0x0005,
-	0x0006,
-	0x0009,
 	0x000a,
-	0x0005,
-	0x0006,
 	0x0009,
-	0x000a,
-	0x0005,
 	0x0006,
-	0x0009,
-	0x000a,
 	0x0005,
-	0x0006,
+	0x000a,
 	0x0009,
+	0x0006,
+	0x0005,
 	0x000a,
+	0x0009,
+	0x0006,
 	0x0005,
+	0x000a,
+	0x0009,
 	0x0006,
+	0x0005,
+	0x000a,
 	0x0009,
+	0x0006,
+	0x0005,
 	0x000a,
+	0x0009,
+	0x0006,
 	0x0005,
+	0x000a,
+	0x0009,
 	0x0006,
+	0x0005,
+	0x000a,
 	0x0009,
+	0x0006,
+	0x0005,
 	0x000a,
+	0x0009,
+	0x0006,
 	0x0005,
+	0x000a,
+	0x0009,
 	0x0006,
+	0x0005,
+	0x000a,
 	0x0009,
+	0x0006,
+	0x0005,
 	0x000a,
+	0x0009,
+	0x0006,
 	0x0005,
+	0x000a,
+	0x0009,
 	0x0006,
+	0x0005,
 };
=20
 static const u16 dot11lcn_sw_ctrl_tbl_rev0[] =3D {
diff --git a/drivers/net/wireless/iwlegacy/4965-rs.c b/drivers/net/wireless=
/iwlegacy/4965-rs.c
index e8324b5..6c7493c 100644
--- a/drivers/net/wireless/iwlegacy/4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/4965-rs.c
@@ -2152,7 +2152,7 @@ il4965_rs_initialize_lq(struct il_priv *il, struct ie=
ee80211_conf *conf,
 	int rate_idx;
 	int i;
 	u32 rate;
-	u8 use_green =3D il4965_rs_use_green(il, sta);
+	u8 use_green;
 	u8 active_tbl =3D 0;
 	u8 valid_tx_ant;
 	struct il_station_priv *sta_priv;
@@ -2160,6 +2160,7 @@ il4965_rs_initialize_lq(struct il_priv *il, struct ie=
ee80211_conf *conf,
 	if (!sta || !lq_sta)
 		return;
=20
+	use_green =3D il4965_rs_use_green(il, sta);
 	sta_priv =3D (void *)sta->drv_priv;
=20
 	i =3D lq_sta->last_txrate_idx;
diff --git a/drivers/net/wireless/iwlwifi/dvm/lib.c b/drivers/net/wireless/=
iwlwifi/dvm/lib.c
index 86ea5f4..44ca0e5 100644
--- a/drivers/net/wireless/iwlwifi/dvm/lib.c
+++ b/drivers/net/wireless/iwlwifi/dvm/lib.c
@@ -1262,6 +1262,15 @@ int iwl_dvm_send_cmd(struct iwl_priv *priv, struct i=
wl_host_cmd *cmd)
 	}
=20
 	/*
+	 * This can happen upon FW ASSERT: we clear the STATUS_FW_ERROR flag
+	 * in iwl_down but cancel the workers only later.
+	 */
+	if (!priv->ucode_loaded) {
+		IWL_ERR(priv, "Fw not loaded - dropping CMD: %x\n", cmd->id);
+		return -EIO;
+	}
+
+	/*
 	 * Synchronous commands from this op-mode must hold
 	 * the mutex, this ensures we don't try to send two
 	 * (or more) synchronous commands at a time.
diff --git a/drivers/net/wireless/iwlwifi/dvm/ucode.c b/drivers/net/wireles=
s/iwlwifi/dvm/ucode.c
index 736fe9b..1a4ac92 100644
--- a/drivers/net/wireless/iwlwifi/dvm/ucode.c
+++ b/drivers/net/wireless/iwlwifi/dvm/ucode.c
@@ -367,6 +367,8 @@ int iwl_load_ucode_wait_alive(struct iwl_priv *priv,
 		return -EIO;
 	}
=20
+	priv->ucode_loaded =3D true;
+
 	if (ucode_type !=3D IWL_UCODE_WOWLAN) {
 		/* delay a bit to give rfkill time to run */
 		msleep(5);
@@ -380,8 +382,6 @@ int iwl_load_ucode_wait_alive(struct iwl_priv *priv,
 		return ret;
 	}
=20
-	priv->ucode_loaded =3D true;
-
 	return 0;
 }
=20
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 17bedc5..12c4f31 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -475,6 +475,10 @@ static int iwl_trans_pcie_start_fw(struct iwl_trans *t=
rans,
=20
 	/* If platform's RF_KILL switch is NOT set to KILL */
 	hw_rfkill =3D iwl_is_rfkill_set(trans);
+	if (hw_rfkill)
+		set_bit(STATUS_RFKILL, &trans_pcie->status);
+	else
+		clear_bit(STATUS_RFKILL, &trans_pcie->status);
 	iwl_op_mode_hw_rf_kill(trans->op_mode, hw_rfkill);
 	if (hw_rfkill && !run_in_rfkill)
 		return -ERFKILL;
@@ -641,6 +645,7 @@ static int iwl_trans_pcie_d3_resume(struct iwl_trans *t=
rans,
=20
 static int iwl_trans_pcie_start_hw(struct iwl_trans *trans)
 {
+	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
 	bool hw_rfkill;
 	int err;
=20
@@ -656,6 +661,10 @@ static int iwl_trans_pcie_start_hw(struct iwl_trans *t=
rans)
 	iwl_enable_rfkill_int(trans);
=20
 	hw_rfkill =3D iwl_is_rfkill_set(trans);
+	if (hw_rfkill)
+		set_bit(STATUS_RFKILL, &trans_pcie->status);
+	else
+		clear_bit(STATUS_RFKILL, &trans_pcie->status);
 	iwl_op_mode_hw_rf_kill(trans->op_mode, hw_rfkill);
=20
 	return 0;
@@ -694,6 +703,10 @@ static void iwl_trans_pcie_stop_hw(struct iwl_trans *t=
rans,
 		 * op_mode.
 		 */
 		hw_rfkill =3D iwl_is_rfkill_set(trans);
+		if (hw_rfkill)
+			set_bit(STATUS_RFKILL, &trans_pcie->status);
+		else
+			clear_bit(STATUS_RFKILL, &trans_pcie->status);
 		iwl_op_mode_hw_rf_kill(trans->op_mode, hw_rfkill);
 	}
 }
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/=
iwlwifi/pcie/tx.c
index 8595c16..cb5c679 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -1264,7 +1264,7 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *tr=
ans,
 	for (i =3D 0; i < IWL_MAX_CMD_TBS_PER_TFD; i++) {
 		int copy =3D 0;
=20
-		if (!cmd->len)
+		if (!cmd->len[i])
 			continue;
=20
 		/* need at least IWL_HCMD_SCRATCHBUF_SIZE copied */
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwi=
fiex/pcie.c
index 5c395e2..feb2046 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -1508,6 +1508,7 @@ static int mwifiex_pcie_process_cmd_complete(struct m=
wifiex_adapter *adapter)
 		}
 		memcpy(adapter->upld_buf, skb->data,
 		       min_t(u32, MWIFIEX_SIZE_OF_CMD_BUFFER, skb->len));
+		skb_push(skb, INTF_HEADER_LEN);
 		if (mwifiex_map_pci_memory(adapter, skb, MWIFIEX_UPLD_SIZE,
 					   PCI_DMA_FROMDEVICE))
 			return -1;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index baaa860..3bfe261 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -349,21 +349,19 @@ static void ieee80211_set_default_queues(struct ieee8=
0211_sub_if_data *sdata)
 static int ieee80211_add_virtual_monitor(struct ieee80211_local *local)
 {
 	struct ieee80211_sub_if_data *sdata;
-	int ret =3D 0;
+	int ret;
=20
 	if (!(local->hw.flags & IEEE80211_HW_WANT_MONITOR_VIF))
 		return 0;
=20
-	mutex_lock(&local->iflist_mtx);
+	ASSERT_RTNL();
=20
 	if (local->monitor_sdata)
-		goto out_unlock;
+		return 0;
=20
 	sdata =3D kzalloc(sizeof(*sdata) + local->hw.vif_data_size, GFP_KERNEL);
-	if (!sdata) {
-		ret =3D -ENOMEM;
-		goto out_unlock;
-	}
+	if (!sdata)
+		return -ENOMEM;
=20
 	/* set up data */
 	sdata->local =3D local;
@@ -377,13 +375,13 @@ static int ieee80211_add_virtual_monitor(struct ieee8=
0211_local *local)
 	if (WARN_ON(ret)) {
 		/* ok .. stupid driver, it asked for this! */
 		kfree(sdata);
-		goto out_unlock;
+		return ret;
 	}
=20
 	ret =3D ieee80211_check_queues(sdata);
 	if (ret) {
 		kfree(sdata);
-		goto out_unlock;
+		return ret;
 	}
=20
 	ret =3D ieee80211_vif_use_channel(sdata, &local->monitor_chandef,
@@ -391,13 +389,14 @@ static int ieee80211_add_virtual_monitor(struct ieee8=
0211_local *local)
 	if (ret) {
 		drv_remove_interface(local, sdata);
 		kfree(sdata);
-		goto out_unlock;
+		return ret;
 	}
=20
+	mutex_lock(&local->iflist_mtx);
 	rcu_assign_pointer(local->monitor_sdata, sdata);
- out_unlock:
 	mutex_unlock(&local->iflist_mtx);
-	return ret;
+
+	return 0;
 }
=20
 static void ieee80211_del_virtual_monitor(struct ieee80211_local *local)
@@ -407,14 +406,20 @@ static void ieee80211_del_virtual_monitor(struct ieee=
80211_local *local)
 	if (!(local->hw.flags & IEEE80211_HW_WANT_MONITOR_VIF))
 		return;
=20
+	ASSERT_RTNL();
+
 	mutex_lock(&local->iflist_mtx);
=20
 	sdata =3D rcu_dereference_protected(local->monitor_sdata,
 					  lockdep_is_held(&local->iflist_mtx));
-	if (!sdata)
-		goto out_unlock;
+	if (!sdata) {
+		mutex_unlock(&local->iflist_mtx);
+		return;
+	}
=20
 	rcu_assign_pointer(local->monitor_sdata, NULL);
+	mutex_unlock(&local->iflist_mtx);
+
 	synchronize_net();
=20
 	ieee80211_vif_release_channel(sdata);
@@ -422,8 +427,6 @@ static void ieee80211_del_virtual_monitor(struct ieee80=
211_local *local)
 	drv_remove_interface(local, sdata);
=20
 	kfree(sdata);
- out_unlock:
-	mutex_unlock(&local->iflist_mtx);
 }
=20
 /*
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 29ce2aa..4749b38 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -1060,7 +1060,8 @@ void ieee80211_mesh_notify_scan_completed(struct ieee=
80211_local *local)
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &local->interfaces, list)
-		if (ieee80211_vif_is_mesh(&sdata->vif))
+		if (ieee80211_vif_is_mesh(&sdata->vif) &&
+		    ieee80211_sdata_running(sdata))
 			ieee80211_queue_work(&local->hw, &sdata->work);
 	rcu_read_unlock();
 }
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 1415774..82cc303 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3608,8 +3608,10 @@ void ieee80211_mlme_notify_scan_completed(struct iee=
e80211_local *local)
=20
 	/* Restart STA timers */
 	rcu_read_lock();
-	list_for_each_entry_rcu(sdata, &local->interfaces, list)
-		ieee80211_restart_sta_timer(sdata);
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
+		if (ieee80211_sdata_running(sdata))
+			ieee80211_restart_sta_timer(sdata);
+	}
 	rcu_read_unlock();
 }
=20
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index bb73ed2d..c6844ad 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2675,7 +2675,19 @@ ieee80211_rx_h_action_return(struct ieee80211_rx_dat=
a *rx)
=20
 		memset(nskb->cb, 0, sizeof(nskb->cb));
=20
-		ieee80211_tx_skb(rx->sdata, nskb);
+		if (rx->sdata->vif.type =3D=3D NL80211_IFTYPE_P2P_DEVICE) {
+			struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(nskb);
+
+			info->flags =3D IEEE80211_TX_CTL_TX_OFFCHAN |
+				      IEEE80211_TX_INTFL_OFFCHAN_TX_OK |
+				      IEEE80211_TX_CTL_NO_CCK_RATE;
+			if (local->hw.flags & IEEE80211_HW_QUEUE_CONTROL)
+				info->hw_queue =3D
+					local->hw.offchannel_tx_hw_queue;
+		}
+
+		__ieee80211_tx_skb_tid_band(rx->sdata, nskb, 7,
+					    status->band);
 	}
 	dev_kfree_skb(rx->skb);
 	return RX_QUEUED;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index a79ce82..238a0cc 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -766,6 +766,7 @@ int __must_check __sta_info_destroy(struct sta_info *st=
a)
 	struct ieee80211_local *local;
 	struct ieee80211_sub_if_data *sdata;
 	int ret, i;
+	bool have_key =3D false;
=20
 	might_sleep();
=20
@@ -793,12 +794,19 @@ int __must_check __sta_info_destroy(struct sta_info *=
sta)
 	list_del_rcu(&sta->list);
=20
 	mutex_lock(&local->key_mtx);
-	for (i =3D 0; i < NUM_DEFAULT_KEYS; i++)
+	for (i =3D 0; i < NUM_DEFAULT_KEYS; i++) {
 		__ieee80211_key_free(key_mtx_dereference(local, sta->gtk[i]));
-	if (sta->ptk)
+		have_key =3D true;
+	}
+	if (sta->ptk) {
 		__ieee80211_key_free(key_mtx_dereference(local, sta->ptk));
+		have_key =3D true;
+	}
 	mutex_unlock(&local->key_mtx);
=20
+	if (!have_key)
+		synchronize_net();
+
 	sta->dead =3D true;
=20
 	local->num_sta--;
diff --git a/net/wireless/core.c b/net/wireless/core.c
index ea4155f..6ddf74f 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -212,6 +212,39 @@ static void cfg80211_rfkill_poll(struct rfkill *rfkill=
, void *data)
 	rdev_rfkill_poll(rdev);
 }
=20
+void cfg80211_stop_p2p_device(struct cfg80211_registered_device *rdev,
+			      struct wireless_dev *wdev)
+{
+	lockdep_assert_held(&rdev->devlist_mtx);
+	lockdep_assert_held(&rdev->sched_scan_mtx);
+
+	if (WARN_ON(wdev->iftype !=3D NL80211_IFTYPE_P2P_DEVICE))
+		return;
+
+	if (!wdev->p2p_started)
+		return;
+
+	rdev_stop_p2p_device(rdev, wdev);
+	wdev->p2p_started =3D false;
+
+	rdev->opencount--;
+
+	if (rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev) {
+		bool busy =3D work_busy(&rdev->scan_done_wk);
+
+		/*
+		 * If the work isn't pending or running (in which case it would
+		 * be waiting for the lock we hold) the driver didn't properly
+		 * cancel the scan when the interface was removed. In this case
+		 * warn and leak the scan request object to not crash later.
+		 */
+		WARN_ON(!busy);
+
+		rdev->scan_req->aborted =3D true;
+		___cfg80211_scan_done(rdev, !busy);
+	}
+}
+
 static int cfg80211_rfkill_set_block(void *data, bool blocked)
 {
 	struct cfg80211_registered_device *rdev =3D data;
@@ -221,7 +254,8 @@ static int cfg80211_rfkill_set_block(void *data, bool b=
locked)
 		return 0;
=20
 	rtnl_lock();
-	mutex_lock(&rdev->devlist_mtx);
+
+	/* read-only iteration need not hold the devlist_mtx */
=20
 	list_for_each_entry(wdev, &rdev->wdev_list, list) {
 		if (wdev->netdev) {
@@ -231,18 +265,18 @@ static int cfg80211_rfkill_set_block(void *data, bool=
 blocked)
 		/* otherwise, check iftype */
 		switch (wdev->iftype) {
 		case NL80211_IFTYPE_P2P_DEVICE:
-			if (!wdev->p2p_started)
-				break;
-			rdev_stop_p2p_device(rdev, wdev);
-			wdev->p2p_started =3D false;
-			rdev->opencount--;
+			/* but this requires it */
+			mutex_lock(&rdev->devlist_mtx);
+			mutex_lock(&rdev->sched_scan_mtx);
+			cfg80211_stop_p2p_device(rdev, wdev);
+			mutex_unlock(&rdev->sched_scan_mtx);
+			mutex_unlock(&rdev->devlist_mtx);
 			break;
 		default:
 			break;
 		}
 	}
=20
-	mutex_unlock(&rdev->devlist_mtx);
 	rtnl_unlock();
=20
 	return 0;
@@ -745,17 +779,13 @@ static void wdev_cleanup_work(struct work_struct *wor=
k)
 	wdev =3D container_of(work, struct wireless_dev, cleanup_work);
 	rdev =3D wiphy_to_dev(wdev->wiphy);
=20
-	cfg80211_lock_rdev(rdev);
+	mutex_lock(&rdev->sched_scan_mtx);
=20
 	if (WARN_ON(rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev)) {
 		rdev->scan_req->aborted =3D true;
 		___cfg80211_scan_done(rdev, true);
 	}
=20
-	cfg80211_unlock_rdev(rdev);
-
-	mutex_lock(&rdev->sched_scan_mtx);
-
 	if (WARN_ON(rdev->sched_scan_req &&
 		    rdev->sched_scan_req->dev =3D=3D wdev->netdev)) {
 		__cfg80211_stop_sched_scan(rdev, false);
@@ -781,21 +811,19 @@ void cfg80211_unregister_wdev(struct wireless_dev *wd=
ev)
 		return;
=20
 	mutex_lock(&rdev->devlist_mtx);
+	mutex_lock(&rdev->sched_scan_mtx);
 	list_del_rcu(&wdev->list);
 	rdev->devlist_generation++;
=20
 	switch (wdev->iftype) {
 	case NL80211_IFTYPE_P2P_DEVICE:
-		if (!wdev->p2p_started)
-			break;
-		rdev_stop_p2p_device(rdev, wdev);
-		wdev->p2p_started =3D false;
-		rdev->opencount--;
+		cfg80211_stop_p2p_device(rdev, wdev);
 		break;
 	default:
 		WARN_ON_ONCE(1);
 		break;
 	}
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
 }
 EXPORT_SYMBOL(cfg80211_unregister_wdev);
@@ -936,6 +964,7 @@ static int cfg80211_netdev_notifier_call(struct notifie=
r_block *nb,
 		cfg80211_update_iface_num(rdev, wdev->iftype, 1);
 		cfg80211_lock_rdev(rdev);
 		mutex_lock(&rdev->devlist_mtx);
+		mutex_lock(&rdev->sched_scan_mtx);
 		wdev_lock(wdev);
 		switch (wdev->iftype) {
 #ifdef CONFIG_CFG80211_WEXT
@@ -967,6 +996,7 @@ static int cfg80211_netdev_notifier_call(struct notifie=
r_block *nb,
 			break;
 		}
 		wdev_unlock(wdev);
+		mutex_unlock(&rdev->sched_scan_mtx);
 		rdev->opencount++;
 		mutex_unlock(&rdev->devlist_mtx);
 		cfg80211_unlock_rdev(rdev);
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 3aec0e4..5845c2b 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -503,6 +503,9 @@ int cfg80211_validate_beacon_int(struct cfg80211_regist=
ered_device *rdev,
 void cfg80211_update_iface_num(struct cfg80211_registered_device *rdev,
 			       enum nl80211_iftype iftype, int num);
=20
+void cfg80211_stop_p2p_device(struct cfg80211_registered_device *rdev,
+			      struct wireless_dev *wdev);
+
 #define CFG80211_MAX_NUM_DIFFERENT_CHANNELS 10
=20
 #ifdef CONFIG_CFG80211_DEVELOPER_WARNINGS
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d44ab21..58e13a8 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4702,14 +4702,19 @@ static int nl80211_trigger_scan(struct sk_buff *skb=
, struct genl_info *info)
 	if (!rdev->ops->scan)
 		return -EOPNOTSUPP;
=20
-	if (rdev->scan_req)
-		return -EBUSY;
+	mutex_lock(&rdev->sched_scan_mtx);
+	if (rdev->scan_req) {
+		err =3D -EBUSY;
+		goto unlock;
+	}
=20
 	if (info->attrs[NL80211_ATTR_SCAN_FREQUENCIES]) {
 		n_channels =3D validate_scan_freqs(
 				info->attrs[NL80211_ATTR_SCAN_FREQUENCIES]);
-		if (!n_channels)
-			return -EINVAL;
+		if (!n_channels) {
+			err =3D -EINVAL;
+			goto unlock;
+		}
 	} else {
 		enum ieee80211_band band;
 		n_channels =3D 0;
@@ -4723,23 +4728,29 @@ static int nl80211_trigger_scan(struct sk_buff *skb=
, struct genl_info *info)
 		nla_for_each_nested(attr, info->attrs[NL80211_ATTR_SCAN_SSIDS], tmp)
 			n_ssids++;
=20
-	if (n_ssids > wiphy->max_scan_ssids)
-		return -EINVAL;
+	if (n_ssids > wiphy->max_scan_ssids) {
+		err =3D -EINVAL;
+		goto unlock;
+	}
=20
 	if (info->attrs[NL80211_ATTR_IE])
 		ie_len =3D nla_len(info->attrs[NL80211_ATTR_IE]);
 	else
 		ie_len =3D 0;
=20
-	if (ie_len > wiphy->max_scan_ie_len)
-		return -EINVAL;
+	if (ie_len > wiphy->max_scan_ie_len) {
+		err =3D -EINVAL;
+		goto unlock;
+	}
=20
 	request =3D kzalloc(sizeof(*request)
 			+ sizeof(*request->ssids) * n_ssids
 			+ sizeof(*request->channels) * n_channels
 			+ ie_len, GFP_KERNEL);
-	if (!request)
-		return -ENOMEM;
+	if (!request) {
+		err =3D -ENOMEM;
+		goto unlock;
+	}
=20
 	if (n_ssids)
 		request->ssids =3D (void *)&request->channels[n_channels];
@@ -4876,6 +4887,8 @@ static int nl80211_trigger_scan(struct sk_buff *skb, =
struct genl_info *info)
 		kfree(request);
 	}
=20
+ unlock:
+	mutex_unlock(&rdev->sched_scan_mtx);
 	return err;
 }
=20
@@ -7749,20 +7762,9 @@ static int nl80211_stop_p2p_device(struct sk_buff *s=
kb, struct genl_info *info)
 	if (!rdev->ops->stop_p2p_device)
 		return -EOPNOTSUPP;
=20
-	if (!wdev->p2p_started)
-		return 0;
-
-	rdev_stop_p2p_device(rdev, wdev);
-	wdev->p2p_started =3D false;
-
-	mutex_lock(&rdev->devlist_mtx);
-	rdev->opencount--;
-	mutex_unlock(&rdev->devlist_mtx);
-
-	if (WARN_ON(rdev->scan_req && rdev->scan_req->wdev =3D=3D wdev)) {
-		rdev->scan_req->aborted =3D true;
-		___cfg80211_scan_done(rdev, true);
-	}
+	mutex_lock(&rdev->sched_scan_mtx);
+	cfg80211_stop_p2p_device(rdev, wdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
=20
 	return 0;
 }
@@ -8486,7 +8488,7 @@ static int nl80211_add_scan_req(struct sk_buff *msg,
 	struct nlattr *nest;
 	int i;
=20
-	ASSERT_RDEV_LOCK(rdev);
+	lockdep_assert_held(&rdev->sched_scan_mtx);
=20
 	if (WARN_ON(!req))
 		return 0;
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 674aadc..fd99ea4 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -169,7 +169,7 @@ void ___cfg80211_scan_done(struct cfg80211_registered_d=
evice *rdev, bool leak)
 	union iwreq_data wrqu;
 #endif
=20
-	ASSERT_RDEV_LOCK(rdev);
+	lockdep_assert_held(&rdev->sched_scan_mtx);
=20
 	request =3D rdev->scan_req;
=20
@@ -230,9 +230,9 @@ void __cfg80211_scan_done(struct work_struct *wk)
 	rdev =3D container_of(wk, struct cfg80211_registered_device,
 			    scan_done_wk);
=20
-	cfg80211_lock_rdev(rdev);
+	mutex_lock(&rdev->sched_scan_mtx);
 	___cfg80211_scan_done(rdev, false);
-	cfg80211_unlock_rdev(rdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
 }
=20
 void cfg80211_scan_done(struct cfg80211_scan_request *request, bool aborte=
d)
@@ -698,11 +698,6 @@ cfg80211_bss_update(struct cfg80211_registered_device =
*dev,
 	found =3D rb_find_bss(dev, tmp, BSS_CMP_REGULAR);
=20
 	if (found) {
-		found->pub.beacon_interval =3D tmp->pub.beacon_interval;
-		found->pub.signal =3D tmp->pub.signal;
-		found->pub.capability =3D tmp->pub.capability;
-		found->ts =3D tmp->ts;
-
 		/* Update IEs */
 		if (rcu_access_pointer(tmp->pub.proberesp_ies)) {
 			const struct cfg80211_bss_ies *old;
@@ -723,6 +718,8 @@ cfg80211_bss_update(struct cfg80211_registered_device *=
dev,
=20
 			if (found->pub.hidden_beacon_bss &&
 			    !list_empty(&found->hidden_list)) {
+				const struct cfg80211_bss_ies *f;
+
 				/*
 				 * The found BSS struct is one of the probe
 				 * response members of a group, but we're
@@ -732,6 +729,10 @@ cfg80211_bss_update(struct cfg80211_registered_device =
*dev,
 				 * SSID to showing it, which is confusing so
 				 * drop this information.
 				 */
+
+				f =3D rcu_access_pointer(tmp->pub.beacon_ies);
+				kfree_rcu((struct cfg80211_bss_ies *)f,
+					  rcu_head);
 				goto drop;
 			}
=20
@@ -761,6 +762,11 @@ cfg80211_bss_update(struct cfg80211_registered_device =
*dev,
 				kfree_rcu((struct cfg80211_bss_ies *)old,
 					  rcu_head);
 		}
+
+		found->pub.beacon_interval =3D tmp->pub.beacon_interval;
+		found->pub.signal =3D tmp->pub.signal;
+		found->pub.capability =3D tmp->pub.capability;
+		found->ts =3D tmp->ts;
 	} else {
 		struct cfg80211_internal_bss *new;
 		struct cfg80211_internal_bss *hidden;
@@ -1056,6 +1062,7 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 	if (IS_ERR(rdev))
 		return PTR_ERR(rdev);
=20
+	mutex_lock(&rdev->sched_scan_mtx);
 	if (rdev->scan_req) {
 		err =3D -EBUSY;
 		goto out;
@@ -1162,6 +1169,7 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 		dev_hold(dev);
 	}
  out:
+	mutex_unlock(&rdev->sched_scan_mtx);
 	kfree(creq);
 	cfg80211_unlock_rdev(rdev);
 	return err;
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index f432bd3..09d994d 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -85,6 +85,7 @@ static int cfg80211_conn_scan(struct wireless_dev *wdev)
 	ASSERT_RTNL();
 	ASSERT_RDEV_LOCK(rdev);
 	ASSERT_WDEV_LOCK(wdev);
+	lockdep_assert_held(&rdev->sched_scan_mtx);
=20
 	if (rdev->scan_req)
 		return -EBUSY;
@@ -320,11 +321,9 @@ void cfg80211_sme_scan_done(struct net_device *dev)
 {
 	struct wireless_dev *wdev =3D dev->ieee80211_ptr;
=20
-	mutex_lock(&wiphy_to_dev(wdev->wiphy)->devlist_mtx);
 	wdev_lock(wdev);
 	__cfg80211_sme_scan_done(dev);
 	wdev_unlock(wdev);
-	mutex_unlock(&wiphy_to_dev(wdev->wiphy)->devlist_mtx);
 }
=20
 void cfg80211_sme_rx_auth(struct net_device *dev,
@@ -924,9 +923,12 @@ int cfg80211_connect(struct cfg80211_registered_device=
 *rdev,
 	int err;
=20
 	mutex_lock(&rdev->devlist_mtx);
+	/* might request scan - scan_mtx -> wdev_mtx dependency */
+	mutex_lock(&rdev->sched_scan_mtx);
 	wdev_lock(dev->ieee80211_ptr);
 	err =3D __cfg80211_connect(rdev, dev, connect, connkeys, NULL);
 	wdev_unlock(dev->ieee80211_ptr);
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
=20
 	return err;
diff --git a/net/wireless/trace.h b/net/wireless/trace.h
index b7a5313..7586de7 100644
--- a/net/wireless/trace.h
+++ b/net/wireless/trace.h
@@ -27,7 +27,8 @@
 #define WIPHY_PR_ARG	__entry->wiphy_name
=20
 #define WDEV_ENTRY	__field(u32, id)
-#define WDEV_ASSIGN	(__entry->id) =3D (wdev ? wdev->identifier : 0)
+#define WDEV_ASSIGN	(__entry->id) =3D (!IS_ERR_OR_NULL(wdev)	\
+					 ? wdev->identifier : 0)
 #define WDEV_PR_FMT	"wdev(%u)"
 #define WDEV_PR_ARG	(__entry->id)
=20
@@ -1778,7 +1779,7 @@ TRACE_EVENT(rdev_set_mac_acl,
 	),
 	TP_fast_assign(
 		WIPHY_ASSIGN;
-		WIPHY_ASSIGN;
+		NETDEV_ASSIGN;
 		__entry->acl_policy =3D params->acl_policy;
 	),
 	TP_printk(WIPHY_PR_FMT ", " NETDEV_PR_FMT ", acl policy: %d",
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index fb9622f..e79cb5c 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -89,6 +89,7 @@ int cfg80211_mgd_wext_siwfreq(struct net_device *dev,
=20
 	cfg80211_lock_rdev(rdev);
 	mutex_lock(&rdev->devlist_mtx);
+	mutex_lock(&rdev->sched_scan_mtx);
 	wdev_lock(wdev);
=20
 	if (wdev->sme_state !=3D CFG80211_SME_IDLE) {
@@ -135,6 +136,7 @@ int cfg80211_mgd_wext_siwfreq(struct net_device *dev,
 	err =3D cfg80211_mgd_wext_connect(rdev, wdev);
  out:
 	wdev_unlock(wdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
 	cfg80211_unlock_rdev(rdev);
 	return err;
@@ -190,6 +192,7 @@ int cfg80211_mgd_wext_siwessid(struct net_device *dev,
=20
 	cfg80211_lock_rdev(rdev);
 	mutex_lock(&rdev->devlist_mtx);
+	mutex_lock(&rdev->sched_scan_mtx);
 	wdev_lock(wdev);
=20
 	err =3D 0;
@@ -223,6 +226,7 @@ int cfg80211_mgd_wext_siwessid(struct net_device *dev,
 	err =3D cfg80211_mgd_wext_connect(rdev, wdev);
  out:
 	wdev_unlock(wdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
 	cfg80211_unlock_rdev(rdev);
 	return err;
@@ -285,6 +289,7 @@ int cfg80211_mgd_wext_siwap(struct net_device *dev,
=20
 	cfg80211_lock_rdev(rdev);
 	mutex_lock(&rdev->devlist_mtx);
+	mutex_lock(&rdev->sched_scan_mtx);
 	wdev_lock(wdev);
=20
 	if (wdev->sme_state !=3D CFG80211_SME_IDLE) {
@@ -313,6 +318,7 @@ int cfg80211_mgd_wext_siwap(struct net_device *dev,
 	err =3D cfg80211_mgd_wext_connect(rdev, wdev);
  out:
 	wdev_unlock(wdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
 	cfg80211_unlock_rdev(rdev);
 	return err;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRVJXCAAoJEJctW/TcYTgGvtQP/0a2t1gwJWx4EAl8j0RfC11J
koyfOhGaeROAzU/F/tvSoMHu72ogHH0Sx1jTfZjMLk4o4V/XoIiJSitw2rODRo7C
w3VkdnVvv9f2rXCc3V8s7eVM1kPMmvwj3gkFAdbEJOsSw+dcoNhJ71JjUVWhOQZq
v5lu7i3oct+NoAOgfchUXawLfyWBt5JbHVO3qXyrHpcqyof5PSux0MkNQKMg7gIE
OUjo5W1/yU/5oPUzZv/jUU3WD7B4O4yvPE45Ha5aWBKzlCt+AWNVFo+qWj3brv55
pgl6K5td5N9CsFrVUA4tkTX+21tYY7uEcmOECBijsMUpOFERaGuKQ7iaVxL3V4qO
l1/xIfpyg39k2Gn0rnUKOAsZWbLQQkZjHn4Hwl970Kymg6paHCKxg09g/A+EOKDQ
wIwNl6h2Xhcy4Mua2i2xmjoeXvgabQ8sB42kBiGdXIXiOaAKPPdnajSqUGaE4uvI
ar6H9N5TYpSApCdIURUVRA5XCUQ3D0vMQjKmEaRMsOjIjVgVCG5+tKMor5hVU41F
Mss/IYAVRdD3vjvVXKvu1qffBQPasXqY2/NoKopMFLvWAbjLrhbT/dfe/6lsVKyP
uRQ/EnqRESUSq/PTy+ckwNIEgRKozQM+QoixZSPuSYpRkpefSHDBQwY31x7Uf2dy
pKGwLnMKvzHjOva60GxL
=D4XN
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
