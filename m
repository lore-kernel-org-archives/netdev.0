From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-11-04
Date: Fri, 4 Nov 2011 15:13:44 -0400
Message-ID: <20111104191343.GB13505@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wzJLGUyc3ArbnUjN"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52994 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1KDTQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 15:16:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 22097fd297c85ec6c2e700d506f231f7cae442e1

Dave,

Here is the first batch of wireless fixes intended for 3.2 -- hooray!

This includes a fix for a race in iwlagn, a number of simple
initialization fixes for ath9k, a couple of mac80211 fixes
related to off-channel work, a carl9170 fix to properly handle the
TX_CTL_REQ_TX_STATUS flag, a TDLS fix for mac80211 (including a memory
leak fix), a libertas fix for cleaning-up properly after a scan,
an iwlwifi fix for working correctly even if MSI is unavailable,
a mac80211 fix to disable powersave for broken APs, the removal of
some log spam from b43, another iwlwifi fix for avoiding a stuck cmd
queue, and a mac80211 fix to reduce log spam about not finding a rate.

Also included is a Bluetooth pull from Gustavo:

	"Some fixes for the 3.2 release, there are four fixes in
	our drivers code by David Hermann. Szymon Janc fixed a bug
	that was making some dongles not work well and a sleep in
	invalid context. And finally a bug fix in the mgmt code by
	Johan Hedberg."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1a67a573b8d9f02211f36fbab50f6265dc49384a:

  Merge git://git.samba.org/sfrench/cifs-2.6 (2011-11-03 21:07:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Andres Salomon (1):
      libertas: ensure we clean up a scan request properly

Christian Lamparter (1):
      carl9170: fix AMPDU TX_CTL_REQ_TX_STATUS handling

David Herrmann (4):
      Bluetooth: ath3k: Use GFP_KERNEL instead of GFP_ATOMIC
      Bluetooth: bcm203x: Fix race condition on disconnect
      Bluetooth: bcm203x: Use GFP_KERNEL in workqueue
      Bluetooth: bfusb: Fix error path on firmware load

Eliad Peller (2):
      mac80211: fix remain_off_channel regression
      mac80211: config hw when going back on-channel

Emmanuel Grumbach (1):
      iwlagn: fix the race in the unmapping of the HCMD

Johan Hedberg (1):
      Bluetooth: Set HCI_MGMT flag only in read_controller_info

Johannes Berg (2):
      mac80211: disable powersave for broken APs
      mac80211: warn only once about not finding a rate

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jouni Malinen (1):
      mac80211: Fix TDLS support validation in add_station handler

Larry Finger (1):
      b43: Remove unneeded message

Rajkumar Manoharan (5):
      ath9k_hw: Fix regression of register offset for AR9003 chips
      ath9k_hw: Fix radio retention for AR9462
      ath9k_hw: Fix regression of register offset of AR9330/AR9340
      ath9k_hw: Update AR9485 initvals to fix system hang issue
      ath9k_hw: Fix noise floor calibration timeout on fast channel change

Szymon Janc (2):
      Bluetooth: rfcomm: Fix sleep in invalid context in rfcomm_security_cfm
      Bluetooth: Increase HCI reset timeout in hci_dev_do_close

Wey-Yi Guy (2):
      iwlwifi: allow pci_enable_msi fail
      iwlwifi: don't perform "echo test" when cmd queue stuck

 drivers/bluetooth/ath3k.c                        |    4 +-
 drivers/bluetooth/bcm203x.c                      |   12 +++++++-
 drivers/bluetooth/bfusb.c                        |   13 ++++----
 drivers/net/wireless/ath/ath9k/ar9002_calib.c    |    4 --
 drivers/net/wireless/ath/ath9k/ar9003_calib.c    |   11 ++++---
 drivers/net/wireless/ath/ath9k/ar9003_phy.h      |   34 +++++++++++-------=
----
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h |   10 +++---
 drivers/net/wireless/ath/ath9k/hw.c              |    3 ++
 drivers/net/wireless/ath/carl9170/tx.c           |   11 ++++--
 drivers/net/wireless/b43/xmit.c                  |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.c          |   10 ------
 drivers/net/wireless/iwlwifi/iwl-pci.c           |    8 ++---
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c    |   12 +++++--
 drivers/net/wireless/libertas/cfg.c              |   25 +++++++++++-----
 drivers/net/wireless/libertas/cfg.h              |    1 +
 drivers/net/wireless/libertas/main.c             |    6 +--
 include/net/bluetooth/rfcomm.h                   |    1 +
 include/net/mac80211.h                           |    3 +-
 net/bluetooth/hci_core.c                         |    2 +-
 net/bluetooth/mgmt.c                             |    2 -
 net/bluetooth/rfcomm/core.c                      |    9 ++++-
 net/mac80211/cfg.c                               |   12 ++++----
 net/mac80211/ieee80211_i.h                       |    1 +
 net/mac80211/mlme.c                              |   18 ++++++++++-
 net/mac80211/work.c                              |    7 ++--
 25 files changed, 126 insertions(+), 94 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index db7cb81..106beb1 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -105,7 +105,7 @@ static int ath3k_load_firmware(struct usb_device *udev,
=20
 	pipe =3D usb_sndctrlpipe(udev, 0);
=20
-	send_buf =3D kmalloc(BULK_SIZE, GFP_ATOMIC);
+	send_buf =3D kmalloc(BULK_SIZE, GFP_KERNEL);
 	if (!send_buf) {
 		BT_ERR("Can't allocate memory chunk for firmware");
 		return -ENOMEM;
@@ -176,7 +176,7 @@ static int ath3k_load_fwfile(struct usb_device *udev,
=20
 	count =3D firmware->size;
=20
-	send_buf =3D kmalloc(BULK_SIZE, GFP_ATOMIC);
+	send_buf =3D kmalloc(BULK_SIZE, GFP_KERNEL);
 	if (!send_buf) {
 		BT_ERR("Can't allocate memory chunk for firmware");
 		return -ENOMEM;
diff --git a/drivers/bluetooth/bcm203x.c b/drivers/bluetooth/bcm203x.c
index 8b1b643..54952ab 100644
--- a/drivers/bluetooth/bcm203x.c
+++ b/drivers/bluetooth/bcm203x.c
@@ -24,6 +24,7 @@
=20
 #include <linux/module.h>
=20
+#include <linux/atomic.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -65,6 +66,7 @@ struct bcm203x_data {
 	unsigned long		state;
=20
 	struct work_struct	work;
+	atomic_t		shutdown;
=20
 	struct urb		*urb;
 	unsigned char		*buffer;
@@ -97,6 +99,7 @@ static void bcm203x_complete(struct urb *urb)
=20
 		data->state =3D BCM203X_SELECT_MEMORY;
=20
+		/* use workqueue to have a small delay */
 		schedule_work(&data->work);
 		break;
=20
@@ -155,7 +158,10 @@ static void bcm203x_work(struct work_struct *work)
 	struct bcm203x_data *data =3D
 		container_of(work, struct bcm203x_data, work);
=20
-	if (usb_submit_urb(data->urb, GFP_ATOMIC) < 0)
+	if (atomic_read(&data->shutdown))
+		return;
+
+	if (usb_submit_urb(data->urb, GFP_KERNEL) < 0)
 		BT_ERR("Can't submit URB");
 }
=20
@@ -243,6 +249,7 @@ static int bcm203x_probe(struct usb_interface *intf, co=
nst struct usb_device_id
=20
 	usb_set_intfdata(intf, data);
=20
+	/* use workqueue to have a small delay */
 	schedule_work(&data->work);
=20
 	return 0;
@@ -254,6 +261,9 @@ static void bcm203x_disconnect(struct usb_interface *in=
tf)
=20
 	BT_DBG("intf %p", intf);
=20
+	atomic_inc(&data->shutdown);
+	cancel_work_sync(&data->work);
+
 	usb_kill_urb(data->urb);
=20
 	usb_set_intfdata(intf, NULL);
diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index 005919a..61b5914 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -568,22 +568,23 @@ static int bfusb_load_firmware(struct bfusb_data *dat=
a,
=20
 	BT_INFO("BlueFRITZ! USB loading firmware");
=20
+	buf =3D kmalloc(BFUSB_MAX_BLOCK_SIZE + 3, GFP_KERNEL);
+	if (!buf) {
+		BT_ERR("Can't allocate memory chunk for firmware");
+		return -ENOMEM;
+	}
+
 	pipe =3D usb_sndctrlpipe(data->udev, 0);
=20
 	if (usb_control_msg(data->udev, pipe, USB_REQ_SET_CONFIGURATION,
 				0, 1, 0, NULL, 0, USB_CTRL_SET_TIMEOUT) < 0) {
 		BT_ERR("Can't change to loading configuration");
+		kfree(buf);
 		return -EBUSY;
 	}
=20
 	data->udev->toggle[0] =3D data->udev->toggle[1] =3D 0;
=20
-	buf =3D kmalloc(BFUSB_MAX_BLOCK_SIZE + 3, GFP_ATOMIC);
-	if (!buf) {
-		BT_ERR("Can't allocate memory chunk for firmware");
-		return -ENOMEM;
-	}
-
 	pipe =3D usb_sndbulkpipe(data->udev, data->bulk_out_ep);
=20
 	while (count) {
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wi=
reless/ath/ath9k/ar9002_calib.c
index e0ab065..88279e3 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -868,10 +868,6 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, stru=
ct ath9k_channel *chan)
 	/* Do PA Calibration */
 	ar9002_hw_pa_cal(ah, true);
=20
-	/* Do NF Calibration after DC offset and other calibrations */
-	ath9k_hw_loadnf(ah, chan);
-	ath9k_hw_start_nfcal(ah, true);
-
 	if (ah->caldata)
 		ah->caldata->nfcal_pending =3D true;
=20
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wi=
reless/ath/ath9k/ar9003_calib.c
index 16851cb..12a730d 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -908,12 +908,15 @@ static bool ar9003_hw_rtt_restore(struct ath_hw *ah, =
struct ath9k_channel *chan)
 	int i;
 	bool restore;
=20
-	if (!(ah->caps.hw_caps & ATH9K_HW_CAP_RTT) || !ah->caldata)
+	if (!ah->caldata)
 		return false;
=20
 	hist =3D &ah->caldata->rtt_hist;
+	if (!hist->num_readings)
+		return false;
+
 	ar9003_hw_rtt_enable(ah);
-	ar9003_hw_rtt_set_mask(ah, 0x10);
+	ar9003_hw_rtt_set_mask(ah, 0x00);
 	for (i =3D 0; i < AR9300_MAX_CHAINS; i++) {
 		if (!(ah->rxchainmask & (1 << i)))
 			continue;
@@ -1070,6 +1073,7 @@ skip_tx_iqcal:
 		if (is_reusable && (hist->num_readings < RTT_HIST_MAX)) {
 			u32 *table;
=20
+			hist->num_readings++;
 			for (i =3D 0; i < AR9300_MAX_CHAINS; i++) {
 				if (!(ah->rxchainmask & (1 << i)))
 					continue;
@@ -1081,9 +1085,6 @@ skip_tx_iqcal:
 		ar9003_hw_rtt_disable(ah);
 	}
=20
-	ath9k_hw_loadnf(ah, chan);
-	ath9k_hw_start_nfcal(ah, true);
-
 	/* Initialize list pointers */
 	ah->cal_list =3D ah->cal_list_last =3D ah->cal_list_curr =3D NULL;
 	ah->supp_cals =3D IQ_MISMATCH_CAL;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.h b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.h
index 2f4023e..4114fe7 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.h
@@ -572,14 +572,14 @@
=20
 #define AR_PHY_TXGAIN_TABLE      (AR_SM_BASE + 0x300)
=20
-#define AR_PHY_TX_IQCAL_CONTROL_0   (AR_SM_BASE + AR_SREV_9485(ah) ? \
-						 0x3c4 : 0x444)
-#define AR_PHY_TX_IQCAL_CONTROL_1   (AR_SM_BASE + AR_SREV_9485(ah) ? \
-						 0x3c8 : 0x448)
-#define AR_PHY_TX_IQCAL_START       (AR_SM_BASE + AR_SREV_9485(ah) ? \
-						 0x3c4 : 0x440)
-#define AR_PHY_TX_IQCAL_STATUS_B0   (AR_SM_BASE + AR_SREV_9485(ah) ? \
-						 0x3f0 : 0x48c)
+#define AR_PHY_TX_IQCAL_CONTROL_0   (AR_SM_BASE + (AR_SREV_9485(ah) ? \
+						 0x3c4 : 0x444))
+#define AR_PHY_TX_IQCAL_CONTROL_1   (AR_SM_BASE + (AR_SREV_9485(ah) ? \
+						 0x3c8 : 0x448))
+#define AR_PHY_TX_IQCAL_START       (AR_SM_BASE + (AR_SREV_9485(ah) ? \
+						 0x3c4 : 0x440))
+#define AR_PHY_TX_IQCAL_STATUS_B0   (AR_SM_BASE + (AR_SREV_9485(ah) ? \
+						 0x3f0 : 0x48c))
 #define AR_PHY_TX_IQCAL_CORR_COEFF_B0(_i)    (AR_SM_BASE + \
 					     (AR_SREV_9485(ah) ? \
 					      0x3d0 : 0x450) + ((_i) << 2))
@@ -651,7 +651,7 @@
 #define AR_SWITCH_TABLE_ALL_S (0)
=20
 #define AR_PHY_65NM_CH0_THERM       (AR_SREV_9300(ah) ? 0x16290 :\
-					(AR_SREV_9485(ah) ? 0x1628c : 0x16294))
+					(AR_SREV_9462(ah) ? 0x16294 : 0x1628c))
=20
 #define AR_PHY_65NM_CH0_THERM_LOCAL   0x80000000
 #define AR_PHY_65NM_CH0_THERM_LOCAL_S 31
@@ -668,12 +668,12 @@
 #define AR_PHY_65NM_CH2_RXTX2       0x16904
=20
 #define AR_CH0_TOP2		(AR_SREV_9300(ah) ? 0x1628c : \
-					(AR_SREV_9485(ah) ? 0x16284 : 0x16290))
+					(AR_SREV_9462(ah) ? 0x16290 : 0x16284))
 #define AR_CH0_TOP2_XPABIASLVL		0xf000
 #define AR_CH0_TOP2_XPABIASLVL_S	12
=20
 #define AR_CH0_XTAL		(AR_SREV_9300(ah) ? 0x16294 : \
-					(AR_SREV_9485(ah) ? 0x16290 : 0x16298))
+					(AR_SREV_9462(ah) ? 0x16298 : 0x16290))
 #define AR_CH0_XTAL_CAPINDAC	0x7f000000
 #define AR_CH0_XTAL_CAPINDAC_S	24
 #define AR_CH0_XTAL_CAPOUTDAC	0x00fe0000
@@ -908,8 +908,8 @@
 #define AR_PHY_TPC_5_B1         (AR_SM1_BASE + 0x208)
 #define AR_PHY_TPC_6_B1         (AR_SM1_BASE + 0x20c)
 #define AR_PHY_TPC_11_B1        (AR_SM1_BASE + 0x220)
-#define AR_PHY_PDADC_TAB_1	(AR_SM1_BASE + (AR_SREV_AR9300(ah) ? \
-					0x240 : 0x280))
+#define AR_PHY_PDADC_TAB_1	(AR_SM1_BASE + (AR_SREV_AR9462(ah) ? \
+					0x280 : 0x240))
 #define AR_PHY_TPC_19_B1	(AR_SM1_BASE + 0x240)
 #define AR_PHY_TPC_19_B1_ALPHA_THERM		0xff
 #define AR_PHY_TPC_19_B1_ALPHA_THERM_S		0
@@ -931,10 +931,10 @@
 #define AR_PHY_AIC_SRAM_ADDR_B1	(AR_SM1_BASE + 0x5f0)
 #define AR_PHY_AIC_SRAM_DATA_B1	(AR_SM1_BASE + 0x5f4)
=20
-#define AR_PHY_RTT_TABLE_SW_INTF_B(i)	(0x384 + (i) ? \
-					AR_SM1_BASE : AR_SM_BASE)
-#define AR_PHY_RTT_TABLE_SW_INTF_1_B(i)	(0x388 + (i) ? \
-					AR_SM1_BASE : AR_SM_BASE)
+#define AR_PHY_RTT_TABLE_SW_INTF_B(i)	(0x384 + ((i) ? \
+					AR_SM1_BASE : AR_SM_BASE))
+#define AR_PHY_RTT_TABLE_SW_INTF_1_B(i)	(0x388 + ((i) ? \
+					AR_SM1_BASE : AR_SM_BASE))
 /*
  * Channel 2 Register Map
  */
diff --git a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h b/drivers/net=
/wireless/ath/ath9k/ar9485_initvals.h
index 611ea6c..d16d029 100644
--- a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
@@ -521,7 +521,7 @@ static const u32 ar9485_1_1_radio_postamble[][2] =3D {
 	{0x000160ac, 0x24611800},
 	{0x000160b0, 0x03284f3e},
 	{0x0001610c, 0x00170000},
-	{0x00016140, 0x10804008},
+	{0x00016140, 0x50804008},
 };
=20
 static const u32 ar9485_1_1_mac_postamble[][5] =3D {
@@ -603,7 +603,7 @@ static const u32 ar9485_1_1_radio_core[][2] =3D {
=20
 static const u32 ar9485_1_1_pcie_phy_pll_on_clkreq_enable_L1[][2] =3D {
 	/* Addr        allmodes */
-	{0x00018c00, 0x10052e5e},
+	{0x00018c00, 0x18052e5e},
 	{0x00018c04, 0x000801d8},
 	{0x00018c08, 0x0000080c},
 };
@@ -776,7 +776,7 @@ static const u32 ar9485_modes_green_ob_db_tx_gain_1_1[]=
[5] =3D {
=20
 static const u32 ar9485_1_1_pcie_phy_clkreq_disable_L1[][2] =3D {
 	/* Addr        allmodes */
-	{0x00018c00, 0x10013e5e},
+	{0x00018c00, 0x18013e5e},
 	{0x00018c04, 0x000801d8},
 	{0x00018c08, 0x0000080c},
 };
@@ -882,7 +882,7 @@ static const u32 ar9485_fast_clock_1_1_baseband_postamb=
le[][3] =3D {
=20
 static const u32 ar9485_1_1_pcie_phy_pll_on_clkreq_disable_L1[][2] =3D {
 	/* Addr        allmodes  */
-	{0x00018c00, 0x10012e5e},
+	{0x00018c00, 0x18012e5e},
 	{0x00018c04, 0x000801d8},
 	{0x00018c08, 0x0000080c},
 };
@@ -1021,7 +1021,7 @@ static const u32 ar9485_common_rx_gain_1_1[][2] =3D {
=20
 static const u32 ar9485_1_1_pcie_phy_clkreq_enable_L1[][2] =3D {
 	/* Addr        allmodes */
-	{0x00018c00, 0x10053e5e},
+	{0x00018c00, 0x18053e5e},
 	{0x00018c04, 0x000801d8},
 	{0x00018c08, 0x0000080c},
 };
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index f16d203..b479160 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1724,6 +1724,9 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_ch=
annel *chan,
 	if (!ath9k_hw_init_cal(ah, chan))
 		return -EIO;
=20
+	ath9k_hw_loadnf(ah, chan);
+	ath9k_hw_start_nfcal(ah, true);
+
 	ENABLE_REGWRITE_BUFFER(ah);
=20
 	ath9k_hw_restore_chainmask(ah);
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/=
ath/carl9170/tx.c
index d209469..59472e1 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -296,7 +296,8 @@ static void carl9170_tx_release(struct kref *ref)
 			super =3D (void *)skb->data;
 			txinfo->status.ampdu_len =3D super->s.rix;
 			txinfo->status.ampdu_ack_len =3D super->s.cnt;
-		} else if (txinfo->flags & IEEE80211_TX_STAT_ACK) {
+		} else if ((txinfo->flags & IEEE80211_TX_STAT_ACK) &&
+			   !(txinfo->flags & IEEE80211_TX_CTL_REQ_TX_STATUS)) {
 			/*
 			 * drop redundant tx_status reports:
 			 *
@@ -308,15 +309,17 @@ static void carl9170_tx_release(struct kref *ref)
 			 *
 			 * 3. minstrel_ht is picky, it only accepts
 			 *    reports of frames with the TX_STATUS_AMPDU flag.
+			 *
+			 * 4. mac80211 is not particularly interested in
+			 *    feedback either [CTL_REQ_TX_STATUS not set]
 			 */
=20
 			dev_kfree_skb_any(skb);
 			return;
 		} else {
 			/*
-			 * Frame has failed, but we want to keep it in
-			 * case it was lost due to a power-state
-			 * transition.
+			 * Either the frame transmission has failed or
+			 * mac80211 requested tx status.
 			 */
 		}
 	}
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmi=
t.c
index c73e860..58ea0e5 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -827,7 +827,6 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb,=
 const void *_rxhdr)
 #endif
 	return;
 drop:
-	b43dbg(dev->wl, "RX: Packet dropped\n");
 	dev_kfree_skb_any(skb);
 }
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless=
/iwlwifi/iwl-core.c
index b247a56..001fdf1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1755,16 +1755,6 @@ static inline int iwl_check_stuck_queue(struct iwl_p=
riv *priv, int txq)
 {
 	if (iwl_trans_check_stuck_queue(trans(priv), txq)) {
 		int ret;
-		if (txq =3D=3D priv->shrd->cmd_queue) {
-			/*
-			 * validate command queue still working
-			 * by sending "ECHO" command
-			 */
-			if (!iwl_cmd_echo_test(priv))
-				return 0;
-			else
-				IWL_DEBUG_HC(priv, "echo testing fail\n");
-		}
 		ret =3D iwl_force_reset(priv, IWL_FW_RESET, false);
 		return (ret =3D=3D -EAGAIN) ? 0 : 1;
 	}
diff --git a/drivers/net/wireless/iwlwifi/iwl-pci.c b/drivers/net/wireless/=
iwlwifi/iwl-pci.c
index 3b6cc66..19cc6a8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-pci.c
+++ b/drivers/net/wireless/iwlwifi/iwl-pci.c
@@ -445,10 +445,9 @@ static int iwl_pci_probe(struct pci_dev *pdev, const s=
truct pci_device_id *ent)
 	pci_write_config_byte(pdev, PCI_CFG_RETRY_TIMEOUT, 0x00);
=20
 	err =3D pci_enable_msi(pdev);
-	if (err) {
-		dev_printk(KERN_ERR, &pdev->dev, "pci_enable_msi failed");
-		goto out_iounmap;
-	}
+	if (err)
+		dev_printk(KERN_ERR, &pdev->dev,
+			"pci_enable_msi failed(0X%x)", err);
=20
 	/* TODO: Move this away, not needed if not MSI */
 	/* enable rfkill interrupt: hw bug w/a */
@@ -469,7 +468,6 @@ static int iwl_pci_probe(struct pci_dev *pdev, const st=
ruct pci_device_id *ent)
=20
 out_disable_msi:
 	pci_disable_msi(pdev);
-out_iounmap:
 	pci_iounmap(pdev, pci_bus->hw_base);
 out_pci_release_regions:
 	pci_set_drvdata(pdev, NULL);
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wi=
reless/iwlwifi/iwl-trans-pcie.c
index 8e8c75c..da34110 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -407,6 +407,7 @@ static void iwl_tx_queue_unmap(struct iwl_trans *trans,=
 int txq_id)
 	struct iwl_queue *q =3D &txq->q;
 	enum dma_data_direction dma_dir;
 	unsigned long flags;
+	spinlock_t *lock;
=20
 	if (!q->n_bd)
 		return;
@@ -414,19 +415,22 @@ static void iwl_tx_queue_unmap(struct iwl_trans *tran=
s, int txq_id)
 	/* In the command queue, all the TBs are mapped as BIDI
 	 * so unmap them as such.
 	 */
-	if (txq_id =3D=3D trans->shrd->cmd_queue)
+	if (txq_id =3D=3D trans->shrd->cmd_queue) {
 		dma_dir =3D DMA_BIDIRECTIONAL;
-	else
+		lock =3D &trans->hcmd_lock;
+	} else {
 		dma_dir =3D DMA_TO_DEVICE;
+		lock =3D &trans->shrd->sta_lock;
+	}
=20
-	spin_lock_irqsave(&trans->shrd->sta_lock, flags);
+	spin_lock_irqsave(lock, flags);
 	while (q->write_ptr !=3D q->read_ptr) {
 		/* The read_ptr needs to bound by q->n_window */
 		iwlagn_txq_free_tfd(trans, txq, get_cmd_index(q, q->read_ptr),
 				    dma_dir);
 		q->read_ptr =3D iwl_queue_inc_wrap(q->read_ptr, q->n_bd);
 	}
-	spin_unlock_irqrestore(&trans->shrd->sta_lock, flags);
+	spin_unlock_irqrestore(lock, flags);
 }
=20
 /**
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/lib=
ertas/cfg.c
index ff63782..4fcd653 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -728,15 +728,9 @@ static void lbs_scan_worker(struct work_struct *work)
 		le16_to_cpu(scan_cmd->hdr.size),
 		lbs_ret_scan, 0);
=20
-	if (priv->scan_channel >=3D priv->scan_req->n_channels) {
+	if (priv->scan_channel >=3D priv->scan_req->n_channels)
 		/* Mark scan done */
-		if (priv->internal_scan)
-			kfree(priv->scan_req);
-		else
-			cfg80211_scan_done(priv->scan_req, false);
-
-		priv->scan_req =3D NULL;
-	}
+		lbs_scan_done(priv);
=20
 	/* Restart network */
 	if (carrier)
@@ -774,6 +768,21 @@ static void _internal_start_scan(struct lbs_private *p=
riv, bool internal,
 	lbs_deb_leave(LBS_DEB_CFG80211);
 }
=20
+/*
+ * Clean up priv->scan_req.  Should be used to handle the allocation detai=
ls.
+ */
+void lbs_scan_done(struct lbs_private *priv)
+{
+	WARN_ON(!priv->scan_req);
+
+	if (priv->internal_scan)
+		kfree(priv->scan_req);
+	else
+		cfg80211_scan_done(priv->scan_req, false);
+
+	priv->scan_req =3D NULL;
+}
+
 static int lbs_cfg_scan(struct wiphy *wiphy,
 	struct net_device *dev,
 	struct cfg80211_scan_request *request)
diff --git a/drivers/net/wireless/libertas/cfg.h b/drivers/net/wireless/lib=
ertas/cfg.h
index a02ee15..558168c 100644
--- a/drivers/net/wireless/libertas/cfg.h
+++ b/drivers/net/wireless/libertas/cfg.h
@@ -16,6 +16,7 @@ int lbs_reg_notifier(struct wiphy *wiphy,
 void lbs_send_disconnect_notification(struct lbs_private *priv);
 void lbs_send_mic_failureevent(struct lbs_private *priv, u32 event);
=20
+void lbs_scan_done(struct lbs_private *priv);
 void lbs_scan_deinit(struct lbs_private *priv);
 int lbs_disconnect(struct lbs_private *priv, u16 reason);
=20
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/li=
bertas/main.c
index b03779b..39a6a7a 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -255,10 +255,8 @@ static int lbs_eth_stop(struct net_device *dev)
=20
 	lbs_update_mcast(priv);
 	cancel_delayed_work_sync(&priv->scan_work);
-	if (priv->scan_req) {
-		cfg80211_scan_done(priv->scan_req, false);
-		priv->scan_req =3D NULL;
-	}
+	if (priv->scan_req)
+		lbs_scan_done(priv);
=20
 	netif_carrier_off(priv->dev);
=20
diff --git a/include/net/bluetooth/rfcomm.h b/include/net/bluetooth/rfcomm.h
index d5eee20..e2e3eca 100644
--- a/include/net/bluetooth/rfcomm.h
+++ b/include/net/bluetooth/rfcomm.h
@@ -211,6 +211,7 @@ struct rfcomm_dlc {
 #define RFCOMM_AUTH_ACCEPT  6
 #define RFCOMM_AUTH_REJECT  7
 #define RFCOMM_DEFER_SETUP  8
+#define RFCOMM_ENC_DROP     9
=20
 /* Scheduling flags and events */
 #define RFCOMM_SCHED_WAKEUP 31
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index dc1123a..72eddd1 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -3567,8 +3567,9 @@ rate_lowest_index(struct ieee80211_supported_band *sb=
and,
 			return i;
=20
 	/* warn when we cannot find a rate. */
-	WARN_ON(1);
+	WARN_ON_ONCE(1);
=20
+	/* and return 0 (the lowest index) */
 	return 0;
 }
=20
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index b84458d..be84ae3 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -613,7 +613,7 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	if (!test_bit(HCI_RAW, &hdev->flags)) {
 		set_bit(HCI_INIT, &hdev->flags);
 		__hci_request(hdev, hci_reset_req, 0,
-					msecs_to_jiffies(250));
+					msecs_to_jiffies(HCI_INIT_TIMEOUT));
 		clear_bit(HCI_INIT, &hdev->flags);
 	}
=20
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 5a94eec..5caff4d 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -147,8 +147,6 @@ static int read_index_list(struct sock *sk)
=20
 		hci_del_off_timer(d);
=20
-		set_bit(HCI_MGMT, &d->flags);
-
 		if (test_bit(HCI_SETUP, &d->flags))
 			continue;
=20
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 38b618c..4e32e18 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1802,6 +1802,11 @@ static inline void rfcomm_process_dlcs(struct rfcomm=
_session *s)
 			continue;
 		}
=20
+		if (test_bit(RFCOMM_ENC_DROP, &d->flags)) {
+			__rfcomm_dlc_close(d, ECONNREFUSED);
+			continue;
+		}
+
 		if (test_and_clear_bit(RFCOMM_AUTH_ACCEPT, &d->flags)) {
 			rfcomm_dlc_clear_timer(d);
 			if (d->out) {
@@ -2077,7 +2082,7 @@ static void rfcomm_security_cfm(struct hci_conn *conn=
, u8 status, u8 encrypt)
 		if (test_and_clear_bit(RFCOMM_SEC_PENDING, &d->flags)) {
 			rfcomm_dlc_clear_timer(d);
 			if (status || encrypt =3D=3D 0x00) {
-				__rfcomm_dlc_close(d, ECONNREFUSED);
+				set_bit(RFCOMM_ENC_DROP, &d->flags);
 				continue;
 			}
 		}
@@ -2088,7 +2093,7 @@ static void rfcomm_security_cfm(struct hci_conn *conn=
, u8 status, u8 encrypt)
 				rfcomm_dlc_set_timer(d, RFCOMM_AUTH_TIMEOUT);
 				continue;
 			} else if (d->sec_level =3D=3D BT_SECURITY_HIGH) {
-				__rfcomm_dlc_close(d, ECONNREFUSED);
+				set_bit(RFCOMM_ENC_DROP, &d->flags);
 				continue;
 			}
 		}
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index ebd7fb1..d06c65f 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -832,6 +832,12 @@ static int ieee80211_add_station(struct wiphy *wiphy, =
struct net_device *dev,
 	if (is_multicast_ether_addr(mac))
 		return -EINVAL;
=20
+	/* Only TDLS-supporting stations can add TDLS peers */
+	if ((params->sta_flags_set & BIT(NL80211_STA_FLAG_TDLS_PEER)) &&
+	    !((wiphy->flags & WIPHY_FLAG_SUPPORTS_TDLS) &&
+	      sdata->vif.type =3D=3D NL80211_IFTYPE_STATION))
+		return -ENOTSUPP;
+
 	sta =3D sta_info_alloc(sdata, mac, GFP_KERNEL);
 	if (!sta)
 		return -ENOMEM;
@@ -841,12 +847,6 @@ static int ieee80211_add_station(struct wiphy *wiphy, =
struct net_device *dev,
=20
 	sta_apply_parameters(local, sta, params);
=20
-	/* Only TDLS-supporting stations can add TDLS peers */
-	if (test_sta_flag(sta, WLAN_STA_TDLS_PEER) &&
-	    !((wiphy->flags & WIPHY_FLAG_SUPPORTS_TDLS) &&
-	      sdata->vif.type =3D=3D NL80211_IFTYPE_STATION))
-		return -ENOTSUPP;
-
 	rate_control_rate_init(sta);
=20
 	layer2_update =3D sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN ||
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 4c3d1f5..ea10a51 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -389,6 +389,7 @@ struct ieee80211_if_managed {
=20
 	unsigned long timers_running; /* used for quiesce/restart */
 	bool powersave; /* powersave requested for this iface */
+	bool broken_ap; /* AP is broken -- turn off powersave */
 	enum ieee80211_smps_mode req_smps, /* requested smps mode */
 				 ap_smps, /* smps mode AP thinks we're in */
 				 driver_smps_mode; /* smps mode request */
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index ba2da11..17258fe 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -637,6 +637,9 @@ static bool ieee80211_powersave_allowed(struct ieee8021=
1_sub_if_data *sdata)
 	if (!mgd->powersave)
 		return false;
=20
+	if (mgd->broken_ap)
+		return false;
+
 	if (!mgd->associated)
 		return false;
=20
@@ -1489,10 +1492,21 @@ static bool ieee80211_assoc_success(struct ieee8021=
1_work *wk,
 	capab_info =3D le16_to_cpu(mgmt->u.assoc_resp.capab_info);
=20
 	if ((aid & (BIT(15) | BIT(14))) !=3D (BIT(15) | BIT(14)))
-		printk(KERN_DEBUG "%s: invalid aid value %d; bits 15:14 not "
-		       "set\n", sdata->name, aid);
+		printk(KERN_DEBUG
+		       "%s: invalid AID value 0x%x; bits 15:14 not set\n",
+		       sdata->name, aid);
 	aid &=3D ~(BIT(15) | BIT(14));
=20
+	ifmgd->broken_ap =3D false;
+
+	if (aid =3D=3D 0 || aid > IEEE80211_MAX_AID) {
+		printk(KERN_DEBUG
+		       "%s: invalid AID value %d (out of range), turn off PS\n",
+		       sdata->name, aid);
+		aid =3D 0;
+		ifmgd->broken_ap =3D true;
+	}
+
 	pos =3D mgmt->u.assoc_resp.variable;
 	ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems);
=20
diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index 94472eb..6c53b6d 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -1084,14 +1084,13 @@ static void ieee80211_work_work(struct work_struct =
*work)
 			continue;
 		if (wk->chan !=3D local->tmp_channel)
 			continue;
-		if (ieee80211_work_ct_coexists(wk->chan_type,
-					       local->tmp_channel_type))
+		if (!ieee80211_work_ct_coexists(wk->chan_type,
+						local->tmp_channel_type))
 			continue;
 		remain_off_channel =3D true;
 	}
=20
 	if (!remain_off_channel && local->tmp_channel) {
-		bool on_oper_chan =3D ieee80211_cfg_on_oper_channel(local);
 		local->tmp_channel =3D NULL;
 		/* If tmp_channel wasn't operating channel, then
 		 * we need to go back on-channel.
@@ -1101,7 +1100,7 @@ static void ieee80211_work_work(struct work_struct *w=
ork)
 		 * we still need to do a hardware config.  Currently,
 		 * we cannot be here while scanning, however.
 		 */
-		if (ieee80211_cfg_on_oper_channel(local) && !on_oper_chan)
+		if (!ieee80211_cfg_on_oper_channel(local))
 			ieee80211_hw_config(local, 0);
=20
 		/* At the least, we need to disable offchannel_ps,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--wzJLGUyc3ArbnUjN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOtDlnAAoJEJctW/TcYTgGbGEP/RvEOO5qivtGyFhmshk3Owdz
XysBiQJWgzrVAu7DC79V5/xMLYeYVI9Z7WA4iM54xadh29ex7tvwY51o3dQMNsZF
pPD5feU7Fw3hx8B9k7tbiK11FDG3RnI42ZfZJ7um0EhBZfkwsXP82YBoPaUDiEKi
04o0cYUS9PZ+0aOpM1osAPwFn40088yo9T2fxMgpUWEt3+gOPaNhKk3IrKpq26lF
2TUlUaqiaBRtdut43WFNuRDjU4DIE4ndDNhzOALeVHfWjtwWGdE+G544YkFFodY7
yyOdT5pum4OYI2WwoXB/Qm4q6VhROpnsn8d50VQzb597RUex3R0/ilXUpYGPZ+kj
YxKXW8SVLY1eaxFlnX22AEZjcajwaTnxGq/Pe96LLYSiYUL9MsCNNS58ZZ607bUy
1LFQNMcyyVbdeFNocO9Bwdc7u19xrYka3Gicyb6dIOqCSA6inPay8QogEk5IKOE4
L8wBNkELVcSp1mjnz9aw4/JK2ZRZxqlxcSLm8uONdSISR2IuHrTfNlYg+Xco5YHn
VW0KqoThN1hzHWEq76HUFlv/N4Q7vfA5Iozgjh4gIzT5fNfXamwatGuhBUkMd/o0
HHXJhaxQiM+ilYGWuARd5u3akRNyR508rGrgIxpxoPt7TxwygEyTEhTiejyq1Ngd
7BCbmA9mcm+HyZtLikzG
=s8yb
-----END PGP SIGNATURE-----

--wzJLGUyc3ArbnUjN--
