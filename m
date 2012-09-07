From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-09-07
Date: Fri, 7 Sep 2012 14:29:55 -0400
Message-ID: <20120907182955.GA1854@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 861ddac1c4d48b20c0df5c0f23504bf1dc9df8b4

Dave,

Please pull these fixes intended for 3.6.  There are more commits
here than I would like -- I got a bit behind while I was stalking
Steven Rostedt in San Diego last week...  I'll slow it down after this!

There are a couple of pulls here.  One is from Johannes:

"Please pull (according to the below information) to get a few fixes.

 * a fix to properly disconnect in the driver when authentication or
   association fails
 * a fix to prevent invalid information about mesh paths being reported
   to userspace
 * a memory leak fix in an nl80211 error path"

The other comes via Gustavo:

"A few updates for the 3.6 kernel. There are two btusb patches to add
more supported devices through the new USB_VENDOR_AND_INTEFACE_INFO()
macro and another one that add a new device id for a Sony Vaio laptop,
one fix for a user-after-free and, finally, two patches from Vinicius
to fix a issue in SMP pairing."

Along with those...

Arend van Spriel provides a fix for a use-after-free bug in brcmfmac.

Daniel Drake avoids a hang by not trying to touch the libertas hardware
duing suspend if it is already powered-down.

Felix Fietkau provides a batch of ath9k fixes that adress some
potential problems with power settings, as well as a fix to avoid a
potential interrupt storm.

Gertjan van Wingerde provides a register-width fix for rt2x00, and
a rt2x00 fix to prevent incorrectly detecting the rfkill status.
He also provides a device ID patch.

Hante Meuleman gives us three brcmfmac fixes, one that properly
initializes a command structure, one that fixes a race condition that
could lose usb requests, and one that removes some log spam.

Marc Kleine-Budde offers an rt2x00 fix for a voltage setting on some
specific devices.

Mohammed Shafi Shajakhan sent an ath9k fix to avoid a crash related to
using timers that aren't allocated when 2 wire bluetooth coexistence
hardware is in use.

Sergei Poselenov changes rt2800usb to do some validity checking for
received packets, avoiding crashes on an ARM Soc.

Stone Piao gives us an mwifiex fix for an incorrectly set skb length
value for a command buffer.

All of these are localized to their specific drivers, and relatively
small.  The power-related patches from Felix are bigger than I would
like, but I merged them in consideration of their isolation to ath9k
and the sensitive nature of power settings in wireless devices.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b8dfc6a0a7235aed452c0e376b6feff182a86992:

  |PATCH] seeq: Add missing spinlock init (2012-09-07 12:56:00 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 861ddac1c4d48b20c0df5c0f23504bf1dc9df8b4:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-09-07 13:33:27 -0400)

----------------------------------------------------------------

Andre Guedes (1):
      Bluetooth: Fix use-after-free bug in SMP

Arend van Spriel (1):
      brcmfmac: fix use of dev_kfree_skb() in irq context

Daniel Drake (1):
      libertas sdio: fix suspend when interface is down

Eliad Peller (1):
      mac80211: clear bssid on auth/assoc failure

Felix Fietkau (6):
      ath9k_hw: do not enable the MIB interrupt in the interrupt mask regis=
ter
      ath9k_hw: clear the AM2PM predistortion mask on AR933x
      ath9k_hw: calibrate PA input for PA predistortion
      ath9k_hw: disable PA linearization for AR9462
      ath9k: fix PA linearization calibration related crash
      ath9k_hw: enable PA linearization

Gertjan van Wingerde (3):
      rt2x00: Identify ASUS USB-N53 device.
      rt2x00: Fix word size of rt2500usb MAC_CSR19 register.
      rt2x00: Fix rfkill polling prior to interface start.

Gustavo Padovan (1):
      Bluetooth: Use USB_VENDOR_AND_INTERFACE() for Broadcom devices

Hante Meuleman (3):
      brcmfmac: dont use ZERO flag for usb IN
      brcmfmac: fix race condition for rx and tx data.
      brcmfmac: fix get rssi by clearing getvar struct.

Henrik Rydberg (1):
      Bluetooth: Add support for Apple vendor-specific devices

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

LEO Airwarosu Yoichi Shinoda (1):
      mac80211: Various small fixes for cfg.c: mpath_set_pinfo()

Marc Kleine-Budde (1):
      rt2x00: fix voltage setting for RT3572/RT3592

Mohammed Shafi Shajakhan (1):
      ath9k: Fix a crash in 2 WIRE btcoex chipsets

Sergei Poselenov (1):
      rt2800usb: Added rx packet length validity check

Stone Piao (1):
      mwifiex: fix skb length issue when send a command to firmware

Vinicius Costa Gomes (2):
      Bluetooth: Change signature of smp_conn_security()
      Bluetooth: Fix sending a HCI Authorization Request over LE links

Wei Yongjun (1):
      nl80211: fix possible memory leak nl80211_connect()

Yevgeniy Melnichuk (1):
      Bluetooth: Add support for Sony Vaio T-Series

 drivers/bluetooth/ath3k.c                          |   2 +
 drivers/bluetooth/btusb.c                          |  12 ++-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      | 105 +++++++++++++++++=
+++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   4 +
 drivers/net/wireless/ath/ath9k/gpio.c              |   3 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  11 +--
 drivers/net/wireless/ath/ath9k/hw.h                |   1 +
 drivers/net/wireless/ath/ath9k/link.c              |  18 ++--
 drivers/net/wireless/ath/ath9k/xmit.c              |   3 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  30 +++---
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  15 +--
 drivers/net/wireless/libertas/if_sdio.c            |   5 +
 drivers/net/wireless/mwifiex/cmdevt.c              |  15 ++-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   9 ++
 drivers/net/wireless/rt2x00/rt2400pci.h            |   1 +
 drivers/net/wireless/rt2x00/rt2500pci.c            |   9 ++
 drivers/net/wireless/rt2x00/rt2500usb.c            |  11 ++-
 drivers/net/wireless/rt2x00/rt2500usb.h            |  17 ++--
 drivers/net/wireless/rt2x00/rt2800lib.c            |   1 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |   9 ++
 drivers/net/wireless/rt2x00/rt2800usb.c            |  22 ++++-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   2 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   9 ++
 drivers/net/wireless/rt2x00/rt61pci.h              |   1 +
 drivers/net/wireless/rt2x00/rt73usb.c              |   9 ++
 drivers/net/wireless/rt2x00/rt73usb.h              |   3 +
 include/net/bluetooth/smp.h                        |   2 +-
 net/bluetooth/hci_conn.c                           |   4 +
 net/bluetooth/l2cap_core.c                         |  11 ++-
 net/bluetooth/l2cap_sock.c                         |   2 +-
 net/bluetooth/smp.c                                |  10 +-
 net/mac80211/cfg.c                                 |   9 +-
 net/mac80211/mlme.c                                |   4 +
 net/wireless/nl80211.c                             |   4 +-
 34 files changed, 297 insertions(+), 76 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 11f36e5..fc2de55 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -86,6 +86,7 @@ static struct usb_device_id ath3k_table[] =3D {
=20
 	/* Atheros AR5BBU22 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE03C) },
+	{ USB_DEVICE(0x0489, 0xE036) },
=20
 	{ }	/* Terminating entry */
 };
@@ -109,6 +110,7 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
=20
 	/* Atheros AR5BBU22 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE03C), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xE036), .driver_info =3D BTUSB_ATH3012 },
=20
 	{ }	/* Terminating entry */
 };
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index cef3bac..654e248 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -52,6 +52,9 @@ static struct usb_device_id btusb_table[] =3D {
 	/* Generic Bluetooth USB device */
 	{ USB_DEVICE_INFO(0xe0, 0x01, 0x01) },
=20
+	/* Apple-specific (Broadcom) devices */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x05ac, 0xff, 0x01, 0x01) },
+
 	/* Broadcom SoftSailing reporting vendor specific */
 	{ USB_DEVICE(0x0a5c, 0x21e1) },
=20
@@ -94,16 +97,14 @@ static struct usb_device_id btusb_table[] =3D {
=20
 	/* Broadcom BCM20702A0 */
 	{ USB_DEVICE(0x0489, 0xe042) },
-	{ USB_DEVICE(0x0a5c, 0x21e3) },
-	{ USB_DEVICE(0x0a5c, 0x21e6) },
-	{ USB_DEVICE(0x0a5c, 0x21e8) },
-	{ USB_DEVICE(0x0a5c, 0x21f3) },
-	{ USB_DEVICE(0x0a5c, 0x21f4) },
 	{ USB_DEVICE(0x413c, 0x8197) },
=20
 	/* Foxconn - Hon Hai */
 	{ USB_DEVICE(0x0489, 0xe033) },
=20
+	/*Broadcom devices with vendor specific id */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x0a5c, 0xff, 0x01, 0x01) },
+
 	{ }	/* Terminating entry */
 };
=20
@@ -141,6 +142,7 @@ static struct usb_device_id blacklist_table[] =3D {
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe03c), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe036), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Broadcom BCM2035 */
 	{ USB_DEVICE(0x0a5c, 0x2035), .driver_info =3D BTUSB_WRONG_SCO_MTU },
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c b/drivers/net/wi=
reless/ath/ath9k/ar9003_paprd.c
index 2c9f7d7..0ed3846 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
@@ -142,6 +142,7 @@ static int ar9003_paprd_setup_single_table(struct ath_h=
w *ah)
 	};
 	int training_power;
 	int i, val;
+	u32 am2pm_mask =3D ah->paprd_ratemask;
=20
 	if (IS_CHAN_2GHZ(ah->curchan))
 		training_power =3D ar9003_get_training_power_2g(ah);
@@ -158,10 +159,13 @@ static int ar9003_paprd_setup_single_table(struct ath=
_hw *ah)
 	}
 	ah->paprd_training_power =3D training_power;
=20
+	if (AR_SREV_9330(ah))
+		am2pm_mask =3D 0;
+
 	REG_RMW_FIELD(ah, AR_PHY_PAPRD_AM2AM, AR_PHY_PAPRD_AM2AM_MASK,
 		      ah->paprd_ratemask);
 	REG_RMW_FIELD(ah, AR_PHY_PAPRD_AM2PM, AR_PHY_PAPRD_AM2PM_MASK,
-		      ah->paprd_ratemask);
+		      am2pm_mask);
 	REG_RMW_FIELD(ah, AR_PHY_PAPRD_HT40, AR_PHY_PAPRD_HT40_MASK,
 		      ah->paprd_ratemask_ht40);
=20
@@ -782,6 +786,102 @@ int ar9003_paprd_setup_gain_table(struct ath_hw *ah, =
int chain)
 }
 EXPORT_SYMBOL(ar9003_paprd_setup_gain_table);
=20
+static bool ar9003_paprd_retrain_pa_in(struct ath_hw *ah,
+				       struct ath9k_hw_cal_data *caldata,
+				       int chain)
+{
+	u32 *pa_in =3D caldata->pa_table[chain];
+	int capdiv_offset, quick_drop_offset;
+	int capdiv2g, quick_drop;
+	int count =3D 0;
+	int i;
+
+	if (!AR_SREV_9485(ah) && !AR_SREV_9330(ah))
+		return false;
+
+	capdiv2g =3D REG_READ_FIELD(ah, AR_PHY_65NM_CH0_TXRF3,
+				  AR_PHY_65NM_CH0_TXRF3_CAPDIV2G);
+
+	quick_drop =3D REG_READ_FIELD(ah, AR_PHY_PAPRD_TRAINER_CNTL3,
+				    AR_PHY_PAPRD_TRAINER_CNTL3_CF_PAPRD_QUICK_DROP);
+
+	if (quick_drop)
+		quick_drop -=3D 0x40;
+
+	for (i =3D 0; i < NUM_BIN + 1; i++) {
+		if (pa_in[i] =3D=3D 1400)
+			count++;
+	}
+
+	if (AR_SREV_9485(ah)) {
+		if (pa_in[23] < 800) {
+			capdiv_offset =3D (int)((1000 - pa_in[23] + 75) / 150);
+			capdiv2g +=3D capdiv_offset;
+			if (capdiv2g > 7) {
+				capdiv2g =3D 7;
+				if (pa_in[23] < 600) {
+					quick_drop++;
+					if (quick_drop > 0)
+						quick_drop =3D 0;
+				}
+			}
+		} else if (pa_in[23] =3D=3D 1400) {
+			quick_drop_offset =3D min_t(int, count / 3, 2);
+			quick_drop +=3D quick_drop_offset;
+			capdiv2g +=3D quick_drop_offset / 2;
+
+			if (capdiv2g > 7)
+				capdiv2g =3D 7;
+
+			if (quick_drop > 0) {
+				quick_drop =3D 0;
+				capdiv2g -=3D quick_drop_offset;
+				if (capdiv2g < 0)
+					capdiv2g =3D 0;
+			}
+		} else {
+			return false;
+		}
+	} else if (AR_SREV_9330(ah)) {
+		if (pa_in[23] < 1000) {
+			capdiv_offset =3D (1000 - pa_in[23]) / 100;
+			capdiv2g +=3D capdiv_offset;
+			if (capdiv_offset > 3) {
+				capdiv_offset =3D 1;
+				quick_drop--;
+			}
+
+			capdiv2g +=3D capdiv_offset;
+			if (capdiv2g > 6)
+				capdiv2g =3D 6;
+			if (quick_drop < -4)
+				quick_drop =3D -4;
+		} else if (pa_in[23] =3D=3D 1400) {
+			if (count > 3) {
+				quick_drop++;
+				capdiv2g -=3D count / 4;
+				if (quick_drop > -2)
+					quick_drop =3D -2;
+			} else {
+				capdiv2g--;
+			}
+
+			if (capdiv2g < 0)
+				capdiv2g =3D 0;
+		} else {
+			return false;
+		}
+	}
+
+	REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_TXRF3,
+		      AR_PHY_65NM_CH0_TXRF3_CAPDIV2G, capdiv2g);
+	REG_RMW_FIELD(ah, AR_PHY_PAPRD_TRAINER_CNTL3,
+		      AR_PHY_PAPRD_TRAINER_CNTL3_CF_PAPRD_QUICK_DROP,
+		      quick_drop);
+
+	return true;
+}
+
 int ar9003_paprd_create_curve(struct ath_hw *ah,
 			      struct ath9k_hw_cal_data *caldata, int chain)
 {
@@ -817,6 +917,9 @@ int ar9003_paprd_create_curve(struct ath_hw *ah,
 	if (!create_pa_curve(data_L, data_U, pa_table, small_signal_gain))
 		status =3D -2;
=20
+	if (ar9003_paprd_retrain_pa_in(ah, caldata, chain))
+		status =3D -EINPROGRESS;
+
 	REG_CLR_BIT(ah, AR_PHY_PAPRD_TRAINER_STAT1,
 		    AR_PHY_PAPRD_TRAINER_STAT1_PAPRD_TRAIN_DONE);
=20
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.h b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.h
index 7bfbaf0..84d3d49 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.h
@@ -625,6 +625,10 @@
 #define AR_PHY_AIC_CTRL_4_B0	(AR_SM_BASE + 0x4c0)
 #define AR_PHY_AIC_STAT_2_B0	(AR_SM_BASE + 0x4cc)
=20
+#define AR_PHY_65NM_CH0_TXRF3       0x16048
+#define AR_PHY_65NM_CH0_TXRF3_CAPDIV2G		0x0000001e
+#define AR_PHY_65NM_CH0_TXRF3_CAPDIV2G_S	1
+
 #define AR_PHY_65NM_CH0_SYNTH4      0x1608c
 #define AR_PHY_SYNTH4_LONG_SHIFT_SELECT   (AR_SREV_9462(ah) ? 0x00000001 :=
 0x00000002)
 #define AR_PHY_SYNTH4_LONG_SHIFT_SELECT_S (AR_SREV_9462(ah) ? 0 : 1)
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/a=
th/ath9k/gpio.c
index bacdb8f..9f83f71 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -341,7 +341,8 @@ void ath9k_btcoex_stop_gen_timer(struct ath_softc *sc)
 {
 	struct ath_btcoex *btcoex =3D &sc->btcoex;
=20
-	ath9k_gen_timer_stop(sc->sc_ah, btcoex->no_stomp_timer);
+	if (btcoex->hw_timer_enabled)
+		ath9k_gen_timer_stop(sc->sc_ah, btcoex->no_stomp_timer);
 }
=20
 u16 ath9k_btcoex_aggr_limit(struct ath_softc *sc, u32 max_4ms_framelen)
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 60b6a9d..48af401 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -463,9 +463,6 @@ static void ath9k_hw_init_config(struct ath_hw *ah)
 		ah->config.spurchans[i][1] =3D AR_NO_SPUR;
 	}
=20
-	/* PAPRD needs some more work to be enabled */
-	ah->config.paprd_disable =3D 1;
-
 	ah->config.rx_intr_mitigation =3D true;
 	ah->config.pcieSerDesWrite =3D true;
=20
@@ -978,9 +975,6 @@ static void ath9k_hw_init_interrupt_masks(struct ath_hw=
 *ah,
 	else
 		imr_reg |=3D AR_IMR_TXOK;
=20
-	if (opmode =3D=3D NL80211_IFTYPE_AP)
-		imr_reg |=3D AR_IMR_MIB;
-
 	ENABLE_REGWRITE_BUFFER(ah);
=20
 	REG_WRITE(ah, AR_IMR, imr_reg);
@@ -1778,6 +1772,8 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_ch=
annel *chan,
 		/* Operating channel changed, reset channel calibration data */
 		memset(caldata, 0, sizeof(*caldata));
 		ath9k_init_nfcal_hist_buffer(ah, chan);
+	} else if (caldata) {
+		caldata->paprd_packet_sent =3D false;
 	}
 	ah->noise =3D ath9k_hw_getchan_noise(ah, chan);
=20
@@ -2502,7 +2498,8 @@ int ath9k_hw_fill_cap_info(struct ath_hw *ah)
 		pCap->tx_desc_len =3D sizeof(struct ar9003_txc);
 		pCap->txs_len =3D sizeof(struct ar9003_txs);
 		if (!ah->config.paprd_disable &&
-		    ah->eep_ops->get_eeprom(ah, EEP_PAPRD))
+		    ah->eep_ops->get_eeprom(ah, EEP_PAPRD) &&
+		    !AR_SREV_9462(ah))
 			pCap->hw_caps |=3D ATH9K_HW_CAP_PAPRD;
 	} else {
 		pCap->tx_desc_len =3D sizeof(struct ath_desc);
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index ce7332c..6599a75 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -405,6 +405,7 @@ struct ath9k_hw_cal_data {
 	int8_t iCoff;
 	int8_t qCoff;
 	bool rtt_done;
+	bool paprd_packet_sent;
 	bool paprd_done;
 	bool nfcal_pending;
 	bool nfcal_interference;
diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/a=
th/ath9k/link.c
index d4549e9..825a29c 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -254,8 +254,9 @@ void ath_paprd_calibrate(struct work_struct *work)
 	int chain_ok =3D 0;
 	int chain;
 	int len =3D 1800;
+	int ret;
=20
-	if (!caldata)
+	if (!caldata || !caldata->paprd_packet_sent || caldata->paprd_done)
 		return;
=20
 	ath9k_ps_wakeup(sc);
@@ -282,13 +283,6 @@ void ath_paprd_calibrate(struct work_struct *work)
 			continue;
=20
 		chain_ok =3D 0;
-
-		ath_dbg(common, CALIBRATE,
-			"Sending PAPRD frame for thermal measurement on chain %d\n",
-			chain);
-		if (!ath_paprd_send_frame(sc, skb, chain))
-			goto fail_paprd;
-
 		ar9003_paprd_setup_gain_table(ah, chain);
=20
 		ath_dbg(common, CALIBRATE,
@@ -302,7 +296,13 @@ void ath_paprd_calibrate(struct work_struct *work)
 			break;
 		}
=20
-		if (ar9003_paprd_create_curve(ah, caldata, chain)) {
+		ret =3D ar9003_paprd_create_curve(ah, caldata, chain);
+		if (ret =3D=3D -EINPROGRESS) {
+			ath_dbg(common, CALIBRATE,
+				"PAPRD curve on chain %d needs to be re-trained\n",
+				chain);
+			break;
+		} else if (ret) {
 			ath_dbg(common, CALIBRATE,
 				"PAPRD create curve failed on chain %d\n",
 				chain);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 2c9da6b..0d4155a 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2018,6 +2018,9 @@ static void ath_tx_complete(struct ath_softc *sc, str=
uct sk_buff *skb,
=20
 	ath_dbg(common, XMIT, "TX complete: skb: %p\n", skb);
=20
+	if (sc->sc_ah->caldata)
+		sc->sc_ah->caldata->paprd_packet_sent =3D true;
+
 	if (!(tx_flags & ATH_TX_ERROR))
 		/* Frame was ACKed */
 		tx_info->flags |=3D IEEE80211_TX_STAT_ACK;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index a299d42..58f89fa 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -519,7 +519,7 @@ static void brcmf_usb_tx_complete(struct urb *urb)
 	else
 		devinfo->bus_pub.bus->dstats.tx_errors++;
=20
-	dev_kfree_skb(req->skb);
+	brcmu_pkt_buf_free_skb(req->skb);
 	req->skb =3D NULL;
 	brcmf_usb_enq(devinfo, &devinfo->tx_freeq, req);
=20
@@ -540,7 +540,7 @@ static void brcmf_usb_rx_complete(struct urb *urb)
 		devinfo->bus_pub.bus->dstats.rx_packets++;
 	} else {
 		devinfo->bus_pub.bus->dstats.rx_errors++;
-		dev_kfree_skb(skb);
+		brcmu_pkt_buf_free_skb(skb);
 		brcmf_usb_enq(devinfo, &devinfo->rx_freeq, req);
 		return;
 	}
@@ -550,13 +550,15 @@ static void brcmf_usb_rx_complete(struct urb *urb)
 		if (brcmf_proto_hdrpull(devinfo->dev, &ifidx, skb) !=3D 0) {
 			brcmf_dbg(ERROR, "rx protocol error\n");
 			brcmu_pkt_buf_free_skb(skb);
+			brcmf_usb_enq(devinfo, &devinfo->rx_freeq, req);
 			devinfo->bus_pub.bus->dstats.rx_errors++;
 		} else {
 			brcmf_rx_packet(devinfo->dev, ifidx, skb);
 			brcmf_usb_rx_refill(devinfo, req);
 		}
 	} else {
-		dev_kfree_skb(skb);
+		brcmu_pkt_buf_free_skb(skb);
+		brcmf_usb_enq(devinfo, &devinfo->rx_freeq, req);
 	}
 	return;
=20
@@ -581,14 +583,13 @@ static void brcmf_usb_rx_refill(struct brcmf_usbdev_i=
nfo *devinfo,
 	usb_fill_bulk_urb(req->urb, devinfo->usbdev, devinfo->rx_pipe,
 			  skb->data, skb_tailroom(skb), brcmf_usb_rx_complete,
 			  req);
-	req->urb->transfer_flags |=3D URB_ZERO_PACKET;
 	req->devinfo =3D devinfo;
+	brcmf_usb_enq(devinfo, &devinfo->rx_postq, req);
=20
 	ret =3D usb_submit_urb(req->urb, GFP_ATOMIC);
-	if (ret =3D=3D 0) {
-		brcmf_usb_enq(devinfo, &devinfo->rx_postq, req);
-	} else {
-		dev_kfree_skb(req->skb);
+	if (ret) {
+		brcmf_usb_del_fromq(devinfo, req);
+		brcmu_pkt_buf_free_skb(req->skb);
 		req->skb =3D NULL;
 		brcmf_usb_enq(devinfo, &devinfo->rx_freeq, req);
 	}
@@ -683,23 +684,22 @@ static int brcmf_usb_tx(struct device *dev, struct sk=
_buff *skb)
=20
 	req =3D brcmf_usb_deq(devinfo, &devinfo->tx_freeq);
 	if (!req) {
+		brcmu_pkt_buf_free_skb(skb);
 		brcmf_dbg(ERROR, "no req to send\n");
 		return -ENOMEM;
 	}
-	if (!req->urb) {
-		brcmf_dbg(ERROR, "no urb for req %p\n", req);
-		return -ENOBUFS;
-	}
=20
 	req->skb =3D skb;
 	req->devinfo =3D devinfo;
 	usb_fill_bulk_urb(req->urb, devinfo->usbdev, devinfo->tx_pipe,
 			  skb->data, skb->len, brcmf_usb_tx_complete, req);
 	req->urb->transfer_flags |=3D URB_ZERO_PACKET;
+	brcmf_usb_enq(devinfo, &devinfo->tx_postq, req);
 	ret =3D usb_submit_urb(req->urb, GFP_ATOMIC);
-	if (!ret) {
-		brcmf_usb_enq(devinfo, &devinfo->tx_postq, req);
-	} else {
+	if (ret) {
+		brcmf_dbg(ERROR, "brcmf_usb_tx usb_submit_urb FAILED\n");
+		brcmf_usb_del_fromq(devinfo, req);
+		brcmu_pkt_buf_free_skb(req->skb);
 		req->skb =3D NULL;
 		brcmf_usb_enq(devinfo, &devinfo->tx_freeq, req);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 28c5fbb..c36e923 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -1876,16 +1876,17 @@ brcmf_cfg80211_get_station(struct wiphy *wiphy, str=
uct net_device *ndev,
 	}
=20
 	if (test_bit(WL_STATUS_CONNECTED, &cfg_priv->status)) {
-		scb_val.val =3D cpu_to_le32(0);
+		memset(&scb_val, 0, sizeof(scb_val));
 		err =3D brcmf_exec_dcmd(ndev, BRCMF_C_GET_RSSI, &scb_val,
 				      sizeof(struct brcmf_scb_val_le));
-		if (err)
+		if (err) {
 			WL_ERR("Could not get rssi (%d)\n", err);
-
-		rssi =3D le32_to_cpu(scb_val.val);
-		sinfo->filled |=3D STATION_INFO_SIGNAL;
-		sinfo->signal =3D rssi;
-		WL_CONN("RSSI %d dBm\n", rssi);
+		} else {
+			rssi =3D le32_to_cpu(scb_val.val);
+			sinfo->filled |=3D STATION_INFO_SIGNAL;
+			sinfo->signal =3D rssi;
+			WL_CONN("RSSI %d dBm\n", rssi);
+		}
 	}
=20
 done:
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless=
/libertas/if_sdio.c
index e970897..4cb2343 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -1326,6 +1326,11 @@ static int if_sdio_suspend(struct device *dev)
=20
 	mmc_pm_flag_t flags =3D sdio_get_host_pm_caps(func);
=20
+	/* If we're powered off anyway, just let the mmc layer remove the
+	 * card. */
+	if (!lbs_iface_active(card->priv))
+		return -ENOSYS;
+
 	dev_info(dev, "%s: suspend: PM flags =3D 0x%x\n",
 		 sdio_func_id(func), flags);
=20
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index c68adec..565527a 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -170,7 +170,20 @@ static int mwifiex_dnld_cmd_to_fw(struct mwifiex_priva=
te *priv,
 	cmd_code =3D le16_to_cpu(host_cmd->command);
 	cmd_size =3D le16_to_cpu(host_cmd->size);
=20
-	skb_trim(cmd_node->cmd_skb, cmd_size);
+	/* Adjust skb length */
+	if (cmd_node->cmd_skb->len > cmd_size)
+		/*
+		 * cmd_size is less than sizeof(struct host_cmd_ds_command).
+		 * Trim off the unused portion.
+		 */
+		skb_trim(cmd_node->cmd_skb, cmd_size);
+	else if (cmd_node->cmd_skb->len < cmd_size)
+		/*
+		 * cmd_size is larger than sizeof(struct host_cmd_ds_command)
+		 * because we have appended custom IE TLV. Increase skb length
+		 * accordingly.
+		 */
+		skb_put(cmd_node->cmd_skb, cmd_size - cmd_node->cmd_skb->len);
=20
 	do_gettimeofday(&tstamp);
 	dev_dbg(adapter->dev, "cmd: DNLD_CMD: (%lu.%lu): %#x, act %#x, len %d,"
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless=
/rt2x00/rt2400pci.c
index 8b9dbd7..64328af 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1611,6 +1611,7 @@ static int rt2400pci_probe_hw_mode(struct rt2x00_dev =
*rt2x00dev)
 static int rt2400pci_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u32 reg;
=20
 	/*
 	 * Allocate eeprom data.
@@ -1624,6 +1625,14 @@ static int rt2400pci_probe_hw(struct rt2x00_dev *rt2=
x00dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2x00pci_register_read(rt2x00dev, GPIOCSR, &reg);
+	rt2x00_set_field32(&reg, GPIOCSR_BIT8, 1);
+	rt2x00pci_register_write(rt2x00dev, GPIOCSR, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt2400pci_probe_hw_mode(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.h b/drivers/net/wireless=
/rt2x00/rt2400pci.h
index d3a4a68..7564ae9 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.h
+++ b/drivers/net/wireless/rt2x00/rt2400pci.h
@@ -670,6 +670,7 @@
 #define GPIOCSR_BIT5			FIELD32(0x00000020)
 #define GPIOCSR_BIT6			FIELD32(0x00000040)
 #define GPIOCSR_BIT7			FIELD32(0x00000080)
+#define GPIOCSR_BIT8			FIELD32(0x00000100)
=20
 /*
  * BBPPCSR: BBP Pin control register.
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless=
/rt2x00/rt2500pci.c
index d2cf8a4..3de0406 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1929,6 +1929,7 @@ static int rt2500pci_probe_hw_mode(struct rt2x00_dev =
*rt2x00dev)
 static int rt2500pci_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u32 reg;
=20
 	/*
 	 * Allocate eeprom data.
@@ -1942,6 +1943,14 @@ static int rt2500pci_probe_hw(struct rt2x00_dev *rt2=
x00dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2x00pci_register_read(rt2x00dev, GPIOCSR, &reg);
+	rt2x00_set_field32(&reg, GPIOCSR_DIR0, 1);
+	rt2x00pci_register_write(rt2x00dev, GPIOCSR, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt2500pci_probe_hw_mode(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless=
/rt2x00/rt2500usb.c
index 3aae36b..89fee31 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -283,7 +283,7 @@ static int rt2500usb_rfkill_poll(struct rt2x00_dev *rt2=
x00dev)
 	u16 reg;
=20
 	rt2500usb_register_read(rt2x00dev, MAC_CSR19, &reg);
-	return rt2x00_get_field32(reg, MAC_CSR19_BIT7);
+	return rt2x00_get_field16(reg, MAC_CSR19_BIT7);
 }
=20
 #ifdef CONFIG_RT2X00_LIB_LEDS
@@ -1768,6 +1768,7 @@ static int rt2500usb_probe_hw_mode(struct rt2x00_dev =
*rt2x00dev)
 static int rt2500usb_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u16 reg;
=20
 	/*
 	 * Allocate eeprom data.
@@ -1781,6 +1782,14 @@ static int rt2500usb_probe_hw(struct rt2x00_dev *rt2=
x00dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2500usb_register_read(rt2x00dev, MAC_CSR19, &reg);
+	rt2x00_set_field16(&reg, MAC_CSR19_BIT8, 0);
+	rt2500usb_register_write(rt2x00dev, MAC_CSR19, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt2500usb_probe_hw_mode(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.h b/drivers/net/wireless=
/rt2x00/rt2500usb.h
index b493306..196bd51 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.h
+++ b/drivers/net/wireless/rt2x00/rt2500usb.h
@@ -189,14 +189,15 @@
  * MAC_CSR19: GPIO control register.
  */
 #define MAC_CSR19			0x0426
-#define MAC_CSR19_BIT0			FIELD32(0x0001)
-#define MAC_CSR19_BIT1			FIELD32(0x0002)
-#define MAC_CSR19_BIT2			FIELD32(0x0004)
-#define MAC_CSR19_BIT3			FIELD32(0x0008)
-#define MAC_CSR19_BIT4			FIELD32(0x0010)
-#define MAC_CSR19_BIT5			FIELD32(0x0020)
-#define MAC_CSR19_BIT6			FIELD32(0x0040)
-#define MAC_CSR19_BIT7			FIELD32(0x0080)
+#define MAC_CSR19_BIT0			FIELD16(0x0001)
+#define MAC_CSR19_BIT1			FIELD16(0x0002)
+#define MAC_CSR19_BIT2			FIELD16(0x0004)
+#define MAC_CSR19_BIT3			FIELD16(0x0008)
+#define MAC_CSR19_BIT4			FIELD16(0x0010)
+#define MAC_CSR19_BIT5			FIELD16(0x0020)
+#define MAC_CSR19_BIT6			FIELD16(0x0040)
+#define MAC_CSR19_BIT7			FIELD16(0x0080)
+#define MAC_CSR19_BIT8			FIELD16(0x0100)
=20
 /*
  * MAC_CSR20: LED control register.
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index cb8c2ac..b93516d 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -4089,6 +4089,7 @@ static int rt2800_init_rfcsr(struct rt2x00_dev *rt2x0=
0dev)
 		rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
 		msleep(1);
 		rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+		rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL, 0);
 		rt2x00_set_field32(&reg, LDO_CFG0_BGSEL, 1);
 		rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless=
/rt2x00/rt2800pci.c
index 98aa426..4765bbd 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -983,6 +983,7 @@ static int rt2800pci_validate_eeprom(struct rt2x00_dev =
*rt2x00dev)
 static int rt2800pci_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u32 reg;
=20
 	/*
 	 * Allocate eeprom data.
@@ -996,6 +997,14 @@ static int rt2800pci_probe_hw(struct rt2x00_dev *rt2x0=
0dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2x00pci_register_read(rt2x00dev, GPIO_CTRL_CFG, &reg);
+	rt2x00_set_field32(&reg, GPIO_CTRL_CFG_GPIOD_BIT2, 1);
+	rt2x00pci_register_write(rt2x00dev, GPIO_CTRL_CFG, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt2800_probe_hw_mode(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index 6cf3365..6b4226b 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -667,8 +667,16 @@ static void rt2800usb_fill_rxdone(struct queue_entry *=
entry,
 	skb_pull(entry->skb, RXINFO_DESC_SIZE);
=20
 	/*
-	 * FIXME: we need to check for rx_pkt_len validity
+	 * Check for rx_pkt_len validity. Return if invalid, leaving
+	 * rxdesc->size zeroed out by the upper level.
 	 */
+	if (unlikely(rx_pkt_len =3D=3D 0 ||
+			rx_pkt_len > entry->queue->data_size)) {
+		ERROR(entry->queue->rt2x00dev,
+			"Bad frame size %d, forcing to 0\n", rx_pkt_len);
+		return;
+	}
+
 	rxd =3D (__le32 *)(entry->skb->data + rx_pkt_len);
=20
 	/*
@@ -736,6 +744,7 @@ static int rt2800usb_validate_eeprom(struct rt2x00_dev =
*rt2x00dev)
 static int rt2800usb_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u32 reg;
=20
 	/*
 	 * Allocate eeprom data.
@@ -749,6 +758,14 @@ static int rt2800usb_probe_hw(struct rt2x00_dev *rt2x0=
0dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2x00usb_register_read(rt2x00dev, GPIO_CTRL_CFG, &reg);
+	rt2x00_set_field32(&reg, GPIO_CTRL_CFG_GPIOD_BIT2, 1);
+	rt2x00usb_register_write(rt2x00dev, GPIO_CTRL_CFG, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt2800_probe_hw_mode(rt2x00dev);
@@ -1157,6 +1174,8 @@ static struct usb_device_id rt2800usb_device_table[] =
=3D {
 	{ USB_DEVICE(0x1690, 0x0744) },
 	{ USB_DEVICE(0x1690, 0x0761) },
 	{ USB_DEVICE(0x1690, 0x0764) },
+	/* ASUS */
+	{ USB_DEVICE(0x0b05, 0x179d) },
 	/* Cisco */
 	{ USB_DEVICE(0x167b, 0x4001) },
 	/* EnGenius */
@@ -1222,7 +1241,6 @@ static struct usb_device_id rt2800usb_device_table[] =
=3D {
 	{ USB_DEVICE(0x0b05, 0x1760) },
 	{ USB_DEVICE(0x0b05, 0x1761) },
 	{ USB_DEVICE(0x0b05, 0x1790) },
-	{ USB_DEVICE(0x0b05, 0x179d) },
 	/* AzureWave */
 	{ USB_DEVICE(0x13d3, 0x3262) },
 	{ USB_DEVICE(0x13d3, 0x3284) },
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index a6b88bd..3f07e36 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -629,7 +629,7 @@ void rt2x00lib_rxdone(struct queue_entry *entry, gfp_t =
gfp)
 	 */
 	if (unlikely(rxdesc.size =3D=3D 0 ||
 		     rxdesc.size > entry->queue->data_size)) {
-		WARNING(rt2x00dev, "Wrong frame size %d max %d.\n",
+		ERROR(rt2x00dev, "Wrong frame size %d max %d.\n",
 			rxdesc.size, entry->queue->data_size);
 		dev_kfree_skb(entry->skb);
 		goto renew_skb;
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/r=
t2x00/rt61pci.c
index 3f7bc5c..b8ec961 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2832,6 +2832,7 @@ static int rt61pci_probe_hw_mode(struct rt2x00_dev *r=
t2x00dev)
 static int rt61pci_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u32 reg;
=20
 	/*
 	 * Disable power saving.
@@ -2850,6 +2851,14 @@ static int rt61pci_probe_hw(struct rt2x00_dev *rt2x0=
0dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2x00pci_register_read(rt2x00dev, MAC_CSR13, &reg);
+	rt2x00_set_field32(&reg, MAC_CSR13_BIT13, 1);
+	rt2x00pci_register_write(rt2x00dev, MAC_CSR13, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt61pci_probe_hw_mode(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt61pci.h b/drivers/net/wireless/r=
t2x00/rt61pci.h
index e3cd6db..8f3da5a 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.h
+++ b/drivers/net/wireless/rt2x00/rt61pci.h
@@ -372,6 +372,7 @@ struct hw_pairwise_ta_entry {
 #define MAC_CSR13_BIT10			FIELD32(0x00000400)
 #define MAC_CSR13_BIT11			FIELD32(0x00000800)
 #define MAC_CSR13_BIT12			FIELD32(0x00001000)
+#define MAC_CSR13_BIT13			FIELD32(0x00002000)
=20
 /*
  * MAC_CSR14: LED control register.
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/r=
t2x00/rt73usb.c
index ba6e434..248436c 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2177,6 +2177,7 @@ static int rt73usb_probe_hw_mode(struct rt2x00_dev *r=
t2x00dev)
 static int rt73usb_probe_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
+	u32 reg;
=20
 	/*
 	 * Allocate eeprom data.
@@ -2190,6 +2191,14 @@ static int rt73usb_probe_hw(struct rt2x00_dev *rt2x0=
0dev)
 		return retval;
=20
 	/*
+	 * Enable rfkill polling by setting GPIO direction of the
+	 * rfkill switch GPIO pin correctly.
+	 */
+	rt2x00usb_register_read(rt2x00dev, MAC_CSR13, &reg);
+	rt2x00_set_field32(&reg, MAC_CSR13_BIT15, 0);
+	rt2x00usb_register_write(rt2x00dev, MAC_CSR13, reg);
+
+	/*
 	 * Initialize hw specifications.
 	 */
 	retval =3D rt73usb_probe_hw_mode(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt73usb.h b/drivers/net/wireless/r=
t2x00/rt73usb.h
index 9f6b470..df1cc11 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.h
+++ b/drivers/net/wireless/rt2x00/rt73usb.h
@@ -282,6 +282,9 @@ struct hw_pairwise_ta_entry {
 #define MAC_CSR13_BIT10			FIELD32(0x00000400)
 #define MAC_CSR13_BIT11			FIELD32(0x00000800)
 #define MAC_CSR13_BIT12			FIELD32(0x00001000)
+#define MAC_CSR13_BIT13			FIELD32(0x00002000)
+#define MAC_CSR13_BIT14			FIELD32(0x00004000)
+#define MAC_CSR13_BIT15			FIELD32(0x00008000)
=20
 /*
  * MAC_CSR14: LED control register.
diff --git a/include/net/bluetooth/smp.h b/include/net/bluetooth/smp.h
index ca356a7..8b27927 100644
--- a/include/net/bluetooth/smp.h
+++ b/include/net/bluetooth/smp.h
@@ -136,7 +136,7 @@ struct smp_chan {
 };
=20
 /* SMP Commands */
-int smp_conn_security(struct l2cap_conn *conn, __u8 sec_level);
+int smp_conn_security(struct hci_conn *hcon, __u8 sec_level);
 int smp_sig_channel(struct l2cap_conn *conn, struct sk_buff *skb);
 int smp_distribute_keys(struct l2cap_conn *conn, __u8 force);
 int smp_user_confirm_reply(struct hci_conn *conn, u16 mgmt_op, __le32 pass=
key);
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 5ad7da2..3c094e7 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -29,6 +29,7 @@
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 #include <net/bluetooth/a2mp.h>
+#include <net/bluetooth/smp.h>
=20
 static void hci_le_connect(struct hci_conn *conn)
 {
@@ -619,6 +620,9 @@ int hci_conn_security(struct hci_conn *conn, __u8 sec_l=
evel, __u8 auth_type)
 {
 	BT_DBG("hcon %p", conn);
=20
+	if (conn->type =3D=3D LE_LINK)
+		return smp_conn_security(conn, sec_level);
+
 	/* For sdp we don't need the link key. */
 	if (sec_level =3D=3D BT_SECURITY_SDP)
 		return 1;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index daa149b..4ea1710 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1199,14 +1199,15 @@ clean:
 static void l2cap_conn_ready(struct l2cap_conn *conn)
 {
 	struct l2cap_chan *chan;
+	struct hci_conn *hcon =3D conn->hcon;
=20
 	BT_DBG("conn %p", conn);
=20
-	if (!conn->hcon->out && conn->hcon->type =3D=3D LE_LINK)
+	if (!hcon->out && hcon->type =3D=3D LE_LINK)
 		l2cap_le_conn_ready(conn);
=20
-	if (conn->hcon->out && conn->hcon->type =3D=3D LE_LINK)
-		smp_conn_security(conn, conn->hcon->pending_sec_level);
+	if (hcon->out && hcon->type =3D=3D LE_LINK)
+		smp_conn_security(hcon, hcon->pending_sec_level);
=20
 	mutex_lock(&conn->chan_lock);
=20
@@ -1219,8 +1220,8 @@ static void l2cap_conn_ready(struct l2cap_conn *conn)
 			continue;
 		}
=20
-		if (conn->hcon->type =3D=3D LE_LINK) {
-			if (smp_conn_security(conn, chan->sec_level))
+		if (hcon->type =3D=3D LE_LINK) {
+			if (smp_conn_security(hcon, chan->sec_level))
 				l2cap_chan_ready(chan);
=20
 		} else if (chan->chan_type !=3D L2CAP_CHAN_CONN_ORIENTED) {
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 1497edd..34bbe1c 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -616,7 +616,7 @@ static int l2cap_sock_setsockopt(struct socket *sock, i=
nt level, int optname, ch
 				break;
 			}
=20
-			if (smp_conn_security(conn, sec.level))
+			if (smp_conn_security(conn->hcon, sec.level))
 				break;
 			sk->sk_state =3D BT_CONFIG;
 			chan->state =3D BT_CONFIG;
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 901a616..8c225ef 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -267,10 +267,10 @@ static void smp_failure(struct l2cap_conn *conn, u8 r=
eason, u8 send)
 	mgmt_auth_failed(conn->hcon->hdev, conn->dst, hcon->type,
 			 hcon->dst_type, reason);
=20
-	if (test_and_clear_bit(HCI_CONN_LE_SMP_PEND, &conn->hcon->flags)) {
-		cancel_delayed_work_sync(&conn->security_timer);
+	cancel_delayed_work_sync(&conn->security_timer);
+
+	if (test_and_clear_bit(HCI_CONN_LE_SMP_PEND, &conn->hcon->flags))
 		smp_chan_destroy(conn);
-	}
 }
=20
 #define JUST_WORKS	0x00
@@ -760,9 +760,9 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn,=
 struct sk_buff *skb)
 	return 0;
 }
=20
-int smp_conn_security(struct l2cap_conn *conn, __u8 sec_level)
+int smp_conn_security(struct hci_conn *hcon, __u8 sec_level)
 {
-	struct hci_conn *hcon =3D conn->hcon;
+	struct l2cap_conn *conn =3D hcon->l2cap_data;
 	struct smp_chan *smp =3D conn->smp_chan;
 	__u8 authreq;
=20
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index d41974a..a58c0b6 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1378,6 +1378,8 @@ static void mpath_set_pinfo(struct mesh_path *mpath, =
u8 *next_hop,
 	else
 		memset(next_hop, 0, ETH_ALEN);
=20
+	memset(pinfo, 0, sizeof(*pinfo));
+
 	pinfo->generation =3D mesh_paths_generation;
=20
 	pinfo->filled =3D MPATH_INFO_FRAME_QLEN |
@@ -1396,7 +1398,6 @@ static void mpath_set_pinfo(struct mesh_path *mpath, =
u8 *next_hop,
 	pinfo->discovery_timeout =3D
 			jiffies_to_msecs(mpath->discovery_timeout);
 	pinfo->discovery_retries =3D mpath->discovery_retries;
-	pinfo->flags =3D 0;
 	if (mpath->flags & MESH_PATH_ACTIVE)
 		pinfo->flags |=3D NL80211_MPATH_FLAG_ACTIVE;
 	if (mpath->flags & MESH_PATH_RESOLVING)
@@ -1405,10 +1406,8 @@ static void mpath_set_pinfo(struct mesh_path *mpath,=
 u8 *next_hop,
 		pinfo->flags |=3D NL80211_MPATH_FLAG_SN_VALID;
 	if (mpath->flags & MESH_PATH_FIXED)
 		pinfo->flags |=3D NL80211_MPATH_FLAG_FIXED;
-	if (mpath->flags & MESH_PATH_RESOLVING)
-		pinfo->flags |=3D NL80211_MPATH_FLAG_RESOLVING;
-
-	pinfo->flags =3D mpath->flags;
+	if (mpath->flags & MESH_PATH_RESOLVED)
+		pinfo->flags |=3D NL80211_MPATH_FLAG_RESOLVED;
 }
=20
 static int ieee80211_get_mpath(struct wiphy *wiphy, struct net_device *dev,
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a4a5acd..f76b833 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3248,6 +3248,8 @@ int ieee80211_mgd_auth(struct ieee80211_sub_if_data *=
sdata,
 	goto out_unlock;
=20
  err_clear:
+	memset(ifmgd->bssid, 0, ETH_ALEN);
+	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BSSID);
 	ifmgd->auth_data =3D NULL;
  err_free:
 	kfree(auth_data);
@@ -3439,6 +3441,8 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data =
*sdata,
 	err =3D 0;
 	goto out;
  err_clear:
+	memset(ifmgd->bssid, 0, ETH_ALEN);
+	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BSSID);
 	ifmgd->assoc_data =3D NULL;
  err_free:
 	kfree(assoc_data);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 97026f3..1e37dbf 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -5633,8 +5633,10 @@ static int nl80211_connect(struct sk_buff *skb, stru=
ct genl_info *info)
 		       sizeof(connect.ht_capa_mask));
=20
 	if (info->attrs[NL80211_ATTR_HT_CAPABILITY]) {
-		if (!info->attrs[NL80211_ATTR_HT_CAPABILITY_MASK])
+		if (!info->attrs[NL80211_ATTR_HT_CAPABILITY_MASK]) {
+			kfree(connkeys);
 			return -EINVAL;
+		}
 		memcpy(&connect.ht_capa,
 		       nla_data(info->attrs[NL80211_ATTR_HT_CAPABILITY]),
 		       sizeof(connect.ht_capa));
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQSj0jAAoJEJctW/TcYTgGA+gP/2Dprhuq5Q/MFl7jEOvSiuHf
ZCtnHHmTe0kD5IgM0IN6evrTlebMa7NIsS0Hwnxgqu6NfWsuOxWL0eVV0GlG0kBC
FckQHSHqyPJurBFyAwPbUxm3GZM7RqqA4DaIuOLWVc6iIu0qMsU4Nd3X9wckFk90
gygbEcF4cqYixz2OcSL5CFEAx+oRRW4ImSbsJqUVcYsayITiqNC4x77Ux1voOJLz
sXVMzRumOqj04pB5XrDLGcU8e8rprIxvgD6A8B3LRJO8faI8xrJoEqREHzFJ1Pwj
Bcd3pytmo+c09JaMVotAqbhEL+VFFDZDTdEeGUXbpc0Lqw8OdgfxReAaqtluqBcO
TRhgjUvF7Di0iTN26goxyT+oZ6iqoO6B/ho1ioE4IfykGaAt3UmKY3uojRuWxnUr
LyjYkncZ2XUJnk8IOlftJ6bMPdjp7WHm18wnAWap5RIkhszJWT09tDEnZH6suB/f
kmGG4ShUTt1oHoM5KSsTCRrKzFKgEssuqE8b8Sccbvs0YTEgjJMgAmNj3fgVmsdG
4k+Q7voN5T865zg5X+/XbBBT2ca4z3ZIP6tER/AO4Ib0cEnGM5cfM1I+TuzjvwZP
K/yptRX3Wsq30motEzSncZ5lA3lx2UXSfqrKnDzYLjrUYkej0yaADp+gKE4mu9pN
Q+sCv7h1Uqrff8R1mYJ4
=z5Z9
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
