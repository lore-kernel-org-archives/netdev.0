From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-05-01
Date: Thu, 1 May 2014 13:06:15 -0400
Message-ID: <20140501170615.GD3687@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4bRzO86E/ozDv8r1"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4bRzO86E/ozDv8r1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull the following batch of fixes intended for the 3.15 stream!

For the Bluetooth bits, Gustavo says:

"Some fixes for 3.15. There is a revert for the intel driver, a new
device id, and two important SSP fixes from Johan."

On top of that...

Ben Hutchings gives us a fix for an unbalanced irq enable in an
rtl8192cu error path.

Colin Ian King provides an rtlwifi fix for an uninitialized variable.

Felix Fietkau brings a pair of ath9k fixes, one that corrects a
hardware initialization value and another that removes an (unnecessary)
flag that was being used in a way that led to a software tx queue
hang in ath9k.

Gertjan van Wingerde pushes a MAINTAINERS change to remove himself
=66rom the rt2x00 maintainer team.

Hans de Goede fixes a brcmfmac firmware load hang.

Larry Finger changes rtlwifi to use the correct queue for V0 traffic
on rtl8192se.

Rajkumar Manoharan corrects a race in ath9k driver initialization.

Stanislaw Gruszka fixes an rt2x00 bug in which disabling beaconing
once on USB devices led to permanently disabling beaconing for those
devices.

Tim Harvey provides fixes for a pair of ath9k issues that can lead
to soft lockups in that driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 22041fb05b66387b2854f789d1e1f55c7d07b4f4:

  hyperv: Properly handle checksum offload (2014-04-30 16:12:23 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 812e4dafa42c18bb5d2f810dc1dcf57284a15717:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-05-01 11:23:21 -0400)

----------------------------------------------------------------

Ben Hutchings (1):
      rtl8192cu: Fix unbalanced irq enable in error path of rtl92cu_hw_init=
()

Colin Ian King (1):
      rtlwifi: rtl8188ee: initialize packet_beacon

Felix Fietkau (2):
      ath9k_hw: do not lower ANI setting below default on AR913x
      ath9k: remove tid->paused flag

Gertjan van Wingerde (1):
      rt2x00: Remove myself as maintainer.

Hans de Goede (1):
      brcmfmac: Fix brcmf_chip_ai_coredisable not applying reset bits to BC=
MA_IOCTL

Johan Hedberg (2):
      Bluetooth: Fix triggering BR/EDR L2CAP Connect too early
      Bluetooth: Fix redundant encryption request for reauthentication

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: rtl8192se: Fix regression due to commit 1bf4bbb

Marcel Holtmann (1):
      Revert "Bluetooth: Enable autosuspend for Intel Bluetooth device"

Mohammed Habibulla (1):
      Bluetooth: Add support for Lite-on [04ca:3007]

Rajkumar Manoharan (1):
      ath9k: fix race in setting ATH_OP_INVALID

Stanislaw Gruszka (1):
      rt2x00: fix beaconing on USB

Tim Harvey (2):
      ath9k: fix possible hang on flush
      ath9k: add a recv budget

 MAINTAINERS                                    |  1 -
 drivers/bluetooth/ath3k.c                      |  2 ++
 drivers/bluetooth/btusb.c                      |  5 ++---
 drivers/net/wireless/ath/ath9k/ahb.c           |  4 ----
 drivers/net/wireless/ath/ath9k/ani.c           |  6 ++++++
 drivers/net/wireless/ath/ath9k/ath9k.h         |  1 -
 drivers/net/wireless/ath/ath9k/debug_sta.c     |  5 ++---
 drivers/net/wireless/ath/ath9k/init.c          |  3 +++
 drivers/net/wireless/ath/ath9k/pci.c           |  5 -----
 drivers/net/wireless/ath/ath9k/recv.c          |  9 ++++++---
 drivers/net/wireless/ath/ath9k/xmit.c          | 14 +-------------
 drivers/net/wireless/brcm80211/brcmfmac/chip.c |  5 +++--
 drivers/net/wireless/rt2x00/rt2x00mac.c        | 22 ++++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c   |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c    |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c   |  6 ++++++
 net/bluetooth/hci_conn.c                       |  9 ++++++---
 net/bluetooth/hci_event.c                      |  6 ++++++
 18 files changed, 57 insertions(+), 50 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1241a73cc230..db5971f401ec 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7277,7 +7277,6 @@ F:	drivers/video/aty/aty128fb.c
 RALINK RT2X00 WIRELESS LAN DRIVER
 P:	rt2x00 project
 M:	Ivo van Doorn <IvDoorn@gmail.com>
-M:	Gertjan van Wingerde <gwingerde@gmail.com>
 M:	Helmut Schaa <helmut.schaa@googlemail.com>
 L:	linux-wireless@vger.kernel.org
 L:	users@rt2x00.serialmonkey.com (moderated for non-subscribers)
diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index be571fef185d..a83b57e57b63 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -82,6 +82,7 @@ static const struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x04CA, 0x3004) },
 	{ USB_DEVICE(0x04CA, 0x3005) },
 	{ USB_DEVICE(0x04CA, 0x3006) },
+	{ USB_DEVICE(0x04CA, 0x3007) },
 	{ USB_DEVICE(0x04CA, 0x3008) },
 	{ USB_DEVICE(0x04CA, 0x300b) },
 	{ USB_DEVICE(0x0930, 0x0219) },
@@ -131,6 +132,7 @@ static const struct usb_device_id ath3k_blist_tbl[] =3D=
 {
 	{ USB_DEVICE(0x04ca, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3006), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3007), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x300b), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index f338b0c5a8de..a7dfbf9a3afb 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -152,6 +152,7 @@ static const struct usb_device_id blacklist_table[] =3D=
 {
 	{ USB_DEVICE(0x04ca, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3006), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3007), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x300b), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
@@ -1485,10 +1486,8 @@ static int btusb_probe(struct usb_interface *intf,
 	if (id->driver_info & BTUSB_BCM92035)
 		hdev->setup =3D btusb_setup_bcm92035;
=20
-	if (id->driver_info & BTUSB_INTEL) {
-		usb_enable_autosuspend(data->udev);
+	if (id->driver_info & BTUSB_INTEL)
 		hdev->setup =3D btusb_setup_intel;
-	}
=20
 	/* Interface numbers are hardcoded in the specification */
 	data->isoc =3D usb_ifnum_to_if(data->udev, 1);
diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/at=
h/ath9k/ahb.c
index a0398fe3eb28..be3eb2a8d602 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -86,7 +86,6 @@ static int ath_ahb_probe(struct platform_device *pdev)
 	int irq;
 	int ret =3D 0;
 	struct ath_hw *ah;
-	struct ath_common *common;
 	char hw_name[64];
=20
 	if (!dev_get_platdata(&pdev->dev)) {
@@ -146,9 +145,6 @@ static int ath_ahb_probe(struct platform_device *pdev)
 	wiphy_info(hw->wiphy, "%s mem=3D0x%lx, irq=3D%d\n",
 		   hw_name, (unsigned long)mem, irq);
=20
-	common =3D ath9k_hw_common(sc->sc_ah);
-	/* Will be cleared in ath9k_start() */
-	set_bit(ATH_OP_INVALID, &common->op_flags);
 	return 0;
=20
  err_irq:
diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/at=
h/ath9k/ani.c
index 6d47783f2e5b..ba502a2d199b 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -155,6 +155,9 @@ static void ath9k_hw_set_ofdm_nil(struct ath_hw *ah, u8=
 immunityLevel,
 		ATH9K_ANI_RSSI_THR_LOW,
 		ATH9K_ANI_RSSI_THR_HIGH);
=20
+	if (AR_SREV_9100(ah) && immunityLevel < ATH9K_ANI_OFDM_DEF_LEVEL)
+		immunityLevel =3D ATH9K_ANI_OFDM_DEF_LEVEL;
+
 	if (!scan)
 		aniState->ofdmNoiseImmunityLevel =3D immunityLevel;
=20
@@ -235,6 +238,9 @@ static void ath9k_hw_set_cck_nil(struct ath_hw *ah, u_i=
nt8_t immunityLevel,
 		BEACON_RSSI(ah), ATH9K_ANI_RSSI_THR_LOW,
 		ATH9K_ANI_RSSI_THR_HIGH);
=20
+	if (AR_SREV_9100(ah) && immunityLevel < ATH9K_ANI_CCK_DEF_LEVEL)
+		immunityLevel =3D ATH9K_ANI_CCK_DEF_LEVEL;
+
 	if (ah->opmode =3D=3D NL80211_IFTYPE_STATION &&
 	    BEACON_RSSI(ah) <=3D ATH9K_ANI_RSSI_THR_LOW &&
 	    immunityLevel > ATH9K_ANI_CCK_MAX_LEVEL_LOW_RSSI)
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index 44d74495c4de..3ba03dde4215 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -251,7 +251,6 @@ struct ath_atx_tid {
=20
 	s8 bar_index;
 	bool sched;
-	bool paused;
 	bool active;
 };
=20
diff --git a/drivers/net/wireless/ath/ath9k/debug_sta.c b/drivers/net/wirel=
ess/ath/ath9k/debug_sta.c
index d76e6e0120d2..ffca918ff16a 100644
--- a/drivers/net/wireless/ath/ath9k/debug_sta.c
+++ b/drivers/net/wireless/ath/ath9k/debug_sta.c
@@ -72,7 +72,7 @@ static ssize_t read_file_node_aggr(struct file *file, cha=
r __user *user_buf,
 		ath_txq_lock(sc, txq);
 		if (tid->active) {
 			len +=3D scnprintf(buf + len, size - len,
-					 "%3d%11d%10d%10d%10d%10d%9d%6d%8d\n",
+					 "%3d%11d%10d%10d%10d%10d%9d%6d\n",
 					 tid->tidno,
 					 tid->seq_start,
 					 tid->seq_next,
@@ -80,8 +80,7 @@ static ssize_t read_file_node_aggr(struct file *file, cha=
r __user *user_buf,
 					 tid->baw_head,
 					 tid->baw_tail,
 					 tid->bar_index,
-					 tid->sched,
-					 tid->paused);
+					 tid->sched);
 		}
 		ath_txq_unlock(sc, txq);
 	}
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index cbbb02a6b13b..36ae6490e554 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -783,6 +783,9 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc,
 	common =3D ath9k_hw_common(ah);
 	ath9k_set_hw_capab(sc, hw);
=20
+	/* Will be cleared in ath9k_start() */
+	set_bit(ATH_OP_INVALID, &common->op_flags);
+
 	/* Initialize regulatory */
 	error =3D ath_regd_init(&common->regulatory, sc->hw->wiphy,
 			      ath9k_reg_notifier);
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/at=
h/ath9k/pci.c
index 25304adece57..914dbc6b1720 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -784,7 +784,6 @@ static int ath_pci_probe(struct pci_dev *pdev, const st=
ruct pci_device_id *id)
 {
 	struct ath_softc *sc;
 	struct ieee80211_hw *hw;
-	struct ath_common *common;
 	u8 csz;
 	u32 val;
 	int ret =3D 0;
@@ -877,10 +876,6 @@ static int ath_pci_probe(struct pci_dev *pdev, const s=
truct pci_device_id *id)
 	wiphy_info(hw->wiphy, "%s mem=3D0x%lx, irq=3D%d\n",
 		   hw_name, (unsigned long)sc->mem, pdev->irq);
=20
-	/* Will be cleared in ath9k_start() */
-	common =3D ath9k_hw_common(sc->sc_ah);
-	set_bit(ATH_OP_INVALID, &common->op_flags);
-
 	return 0;
=20
 err_init:
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/a=
th/ath9k/recv.c
index 6c9accdb52e4..19df969ec909 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -975,6 +975,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, boo=
l hp)
 	u64 tsf =3D 0;
 	unsigned long flags;
 	dma_addr_t new_buf_addr;
+	unsigned int budget =3D 512;
=20
 	if (edma)
 		dma_type =3D DMA_BIDIRECTIONAL;
@@ -1113,15 +1114,17 @@ requeue_drop_frag:
 		}
 requeue:
 		list_add_tail(&bf->list, &sc->rx.rxbuf);
-		if (flush)
-			continue;
=20
 		if (edma) {
 			ath_rx_edma_buf_link(sc, qtype);
 		} else {
 			ath_rx_buf_relink(sc, bf);
-			ath9k_hw_rxena(ah);
+			if (!flush)
+				ath9k_hw_rxena(ah);
 		}
+
+		if (!budget--)
+			break;
 	} while (1);
=20
 	if (!(ah->imask & ATH9K_INT_RXEOL)) {
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 87cbec47fb48..66acb2cbd9df 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -107,9 +107,6 @@ static void ath_tx_queue_tid(struct ath_txq *txq, struc=
t ath_atx_tid *tid)
 {
 	struct ath_atx_ac *ac =3D tid->ac;
=20
-	if (tid->paused)
-		return;
-
 	if (tid->sched)
 		return;
=20
@@ -1407,7 +1404,6 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ie=
ee80211_sta *sta,
 	ath_tx_tid_change_state(sc, txtid);
=20
 	txtid->active =3D true;
-	txtid->paused =3D true;
 	*ssn =3D txtid->seq_start =3D txtid->seq_next;
 	txtid->bar_index =3D -1;
=20
@@ -1427,7 +1423,6 @@ void ath_tx_aggr_stop(struct ath_softc *sc, struct ie=
ee80211_sta *sta, u16 tid)
=20
 	ath_txq_lock(sc, txq);
 	txtid->active =3D false;
-	txtid->paused =3D false;
 	ath_tx_flush_tid(sc, txtid);
 	ath_tx_tid_change_state(sc, txtid);
 	ath_txq_unlock_complete(sc, txq);
@@ -1487,7 +1482,7 @@ void ath_tx_aggr_wakeup(struct ath_softc *sc, struct =
ath_node *an)
 		ath_txq_lock(sc, txq);
 		ac->clear_ps_filter =3D true;
=20
-		if (!tid->paused && ath_tid_has_buffered(tid)) {
+		if (ath_tid_has_buffered(tid)) {
 			ath_tx_queue_tid(txq, tid);
 			ath_txq_schedule(sc, txq);
 		}
@@ -1510,7 +1505,6 @@ void ath_tx_aggr_resume(struct ath_softc *sc, struct =
ieee80211_sta *sta,
 	ath_txq_lock(sc, txq);
=20
 	tid->baw_size =3D IEEE80211_MIN_AMPDU_BUF << sta->ht_cap.ampdu_factor;
-	tid->paused =3D false;
=20
 	if (ath_tid_has_buffered(tid)) {
 		ath_tx_queue_tid(txq, tid);
@@ -1544,8 +1538,6 @@ void ath9k_release_buffered_frames(struct ieee80211_h=
w *hw,
 			continue;
=20
 		tid =3D ATH_AN_2_TID(an, i);
-		if (tid->paused)
-			continue;
=20
 		ath_txq_lock(sc, tid->ac->txq);
 		while (nframes > 0) {
@@ -1844,9 +1836,6 @@ void ath_txq_schedule(struct ath_softc *sc, struct at=
h_txq *txq)
 			list_del(&tid->list);
 			tid->sched =3D false;
=20
-			if (tid->paused)
-				continue;
-
 			if (ath_tx_sched_aggr(sc, txq, tid, &stop))
 				sent =3D true;
=20
@@ -2698,7 +2687,6 @@ void ath_tx_node_init(struct ath_softc *sc, struct at=
h_node *an)
 		tid->baw_size  =3D WME_MAX_BA;
 		tid->baw_head  =3D tid->baw_tail =3D 0;
 		tid->sched     =3D false;
-		tid->paused    =3D false;
 		tid->active	   =3D false;
 		__skb_queue_head_init(&tid->buf_q);
 		__skb_queue_head_init(&tid->retry_q);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/chip.c b/drivers/net/w=
ireless/brcm80211/brcmfmac/chip.c
index df130ef53d1c..c7c9f15c0fe0 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/chip.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/chip.c
@@ -303,10 +303,10 @@ static void brcmf_chip_ai_coredisable(struct brcmf_co=
re_priv *core,
=20
 	ci =3D core->chip;
=20
-	/* if core is already in reset, just return */
+	/* if core is already in reset, skip reset */
 	regdata =3D ci->ops->read32(ci->ctx, core->wrapbase + BCMA_RESET_CTL);
 	if ((regdata & BCMA_RESET_CTL_RESET) !=3D 0)
-		return;
+		goto in_reset_configure;
=20
 	/* configure reset */
 	ci->ops->write32(ci->ctx, core->wrapbase + BCMA_IOCTL,
@@ -322,6 +322,7 @@ static void brcmf_chip_ai_coredisable(struct brcmf_core=
_priv *core,
 	SPINWAIT(ci->ops->read32(ci->ctx, core->wrapbase + BCMA_RESET_CTL) !=3D
 		 BCMA_RESET_CTL_RESET, 300);
=20
+in_reset_configure:
 	/* in-reset configure */
 	ci->ops->write32(ci->ctx, core->wrapbase + BCMA_IOCTL,
 			 reset | BCMA_IOCTL_FGC | BCMA_IOCTL_CLK);
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless=
/rt2x00/rt2x00mac.c
index ddeb5a709aa3..a87ee9b6585a 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -621,20 +621,18 @@ void rt2x00mac_bss_info_changed(struct ieee80211_hw *=
hw,
 				      bss_conf->bssid);
=20
 	/*
-	 * Update the beacon. This is only required on USB devices. PCI
-	 * devices fetch beacons periodically.
-	 */
-	if (changes & BSS_CHANGED_BEACON && rt2x00_is_usb(rt2x00dev))
-		rt2x00queue_update_beacon(rt2x00dev, vif);
-
-	/*
 	 * Start/stop beaconing.
 	 */
 	if (changes & BSS_CHANGED_BEACON_ENABLED) {
 		if (!bss_conf->enable_beacon && intf->enable_beacon) {
-			rt2x00queue_clear_beacon(rt2x00dev, vif);
 			rt2x00dev->intf_beaconing--;
 			intf->enable_beacon =3D false;
+			/*
+			 * Clear beacon in the H/W for this vif. This is needed
+			 * to disable beaconing on this particular interface
+			 * and keep it running on other interfaces.
+			 */
+			rt2x00queue_clear_beacon(rt2x00dev, vif);
=20
 			if (rt2x00dev->intf_beaconing =3D=3D 0) {
 				/*
@@ -645,11 +643,15 @@ void rt2x00mac_bss_info_changed(struct ieee80211_hw *=
hw,
 				rt2x00queue_stop_queue(rt2x00dev->bcn);
 				mutex_unlock(&intf->beacon_skb_mutex);
 			}
-
-
 		} else if (bss_conf->enable_beacon && !intf->enable_beacon) {
 			rt2x00dev->intf_beaconing++;
 			intf->enable_beacon =3D true;
+			/*
+			 * Upload beacon to the H/W. This is only required on
+			 * USB devices. PCI devices fetch beacons periodically.
+			 */
+			if (rt2x00_is_usb(rt2x00dev))
+				rt2x00queue_update_beacon(rt2x00dev, vif);
=20
 			if (rt2x00dev->intf_beaconing =3D=3D 1) {
 				/*
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8188ee/trx.c
index 06ef47cd6203..5b4c225396f2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -293,7 +293,7 @@ static void _rtl88ee_translate_rx_signal_stuff(struct i=
eee80211_hw *hw,
 	u8 *psaddr;
 	__le16 fc;
 	u16 type, ufc;
-	bool match_bssid, packet_toself, packet_beacon, addr;
+	bool match_bssid, packet_toself, packet_beacon =3D false, addr;
=20
 	tmp_buf =3D skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.c
index 68b5c7e92cfb..07cb06da6729 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1001,7 +1001,7 @@ int rtl92cu_hw_init(struct ieee80211_hw *hw)
 	err =3D _rtl92cu_init_mac(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "init mac failed!\n");
-		return err;
+		goto exit;
 	}
 	err =3D rtl92c_download_fw(hw);
 	if (err) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192se/trx.c
index 36b48be8329c..2b3c78baa9f8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -49,6 +49,12 @@ static u8 _rtl92se_map_hwqueue_to_fwqueue(struct sk_buff=
 *skb,	u8 skb_queue)
 	if (ieee80211_is_nullfunc(fc))
 		return QSLT_HIGH;
=20
+	/* Kernel commit 1bf4bbb4024dcdab changed EAPOL packets to use
+	 * queue V0 at priority 7; however, the RTL8192SE appears to have
+	 * that queue at priority 6
+	 */
+	if (skb->priority =3D=3D 7)
+		return QSLT_VO;
 	return skb->priority;
 }
=20
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index d958e2dca52f..521fd4f3985e 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -819,14 +819,17 @@ static int hci_conn_auth(struct hci_conn *conn, __u8 =
sec_level, __u8 auth_type)
 	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->flags)) {
 		struct hci_cp_auth_requested cp;
=20
-		/* encrypt must be pending if auth is also pending */
-		set_bit(HCI_CONN_ENCRYPT_PEND, &conn->flags);
-
 		cp.handle =3D cpu_to_le16(conn->handle);
 		hci_send_cmd(conn->hdev, HCI_OP_AUTH_REQUESTED,
 			     sizeof(cp), &cp);
+
+		/* If we're already encrypted set the REAUTH_PEND flag,
+		 * otherwise set the ENCRYPT_PEND.
+		 */
 		if (conn->key_type !=3D 0xff)
 			set_bit(HCI_CONN_REAUTH_PEND, &conn->flags);
+		else
+			set_bit(HCI_CONN_ENCRYPT_PEND, &conn->flags);
 	}
=20
 	return 0;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 49774912cb01..15010a230b6d 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -3330,6 +3330,12 @@ static void hci_key_refresh_complete_evt(struct hci_=
dev *hdev,
 	if (!conn)
 		goto unlock;
=20
+	/* For BR/EDR the necessary steps are taken through the
+	 * auth_complete event.
+	 */
+	if (conn->type !=3D LE_LINK)
+		goto unlock;
+
 	if (!ev->status)
 		conn->sec_level =3D conn->pending_sec_level;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--4bRzO86E/ozDv8r1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTYn8HAAoJEJctW/TcYTgGsXcQAIt+wg+z2VellnubELiuzsJb
MtjbCzbiEHyTyUYR5L1MNmkl8wOFvoBbxkAhAOribUKBoT3pU2jerKlMHsxwRCHq
Sqja1AjieamTZpEOZnJHmzaGHYkHZC7xylOaPD0tNkaTY5zyZS+vuGnVPd3h6Qil
ISRJ4oEaKRKHLxPhW/dvvGravh79UzZWh4/Bdm6qWtEj47RCUjW30nxsu5f57UkV
W+Jz1q4yNfbpKMdPpZSdP+aOtVa+BG3tRO3Wi7yIz5rXpapDFwKeYLcZG0e8Ru4g
S8iFNPPIyurj6yymO9d7mMH9GqEK54M6srCt+q6G2Tn1pmd88w81psvIBUqAcfRK
pEhY6uy1SXalvUpWzn8ooDCKDqCkgtYN8PWItDdOqGrTywmS+1lpi7VqxAd0tR9k
i6XyAdcfi7PJPuDl0f1qU99wEqQhiL1u/m45irOBMoShEqmNu9azNZCu+eMiC1RD
IIw1XFv98HRRvK5IX7MBPKPxMG5kVxc/k8xmZK1Aa92/Gak9Qw5R86JWN+qK7Wls
nWf/J+I3waXFk5z2gMFt50fQZNJ7KD7Hd3y3ANnCYOoaf8Jc9SNU37OWuarqdpzC
Uo7FDZdq5uyvOI+As+fJPPQMYpvXdpXRwvpw+B+j7xBrFnbMpO+tcuRchjStB7pD
OcZEvdDWr7r23jgFnYTx
=DWei
-----END PGP SIGNATURE-----

--4bRzO86E/ozDv8r1--
