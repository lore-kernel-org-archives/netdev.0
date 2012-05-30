From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-05-30
Date: Wed, 30 May 2012 13:13:00 -0400
Message-ID: <20120530171300.GA2674@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47992 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532Ab2E3RR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 13:17:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here is a batch of fixes intended for 3.5.  They have spent a little
time in linux-next, and for the most part they are reasonably small
and obvious.

Claudio Pisa gives us a one-line fix to correct a check for QoS
NoAck frames.

Dan Carpenter fixes an integer overflow issue in the NFC code.

Emmanuel Grumbach fixes a WARNING related to management of iwlwifi's
Transmit Frame Descriptor rings.

Eyal Shapira fixes some build breakage in the wlcore module when
CONFIG_PM is not defined.  Eyal also fixes a mac80211 issue where some
block ack state info wasn't getting handle properly across a suspend.

Felix gives us a load of fixes this time.  The ath5k one ensures that
users of multiple virtual interfaces can continue doing so, since
"cfg80211: enforce lack of interface combinations" would otherwise
prevent that.  An ath9k fix stops rx dma when stopping tx, preventing
some "Failed to stop Tx DMA!" messages.  Another ath9k fix prevents
a use-after-free bug.  Felix also updates some ath9k_hw hardware
initialization values, in order to prevent issues with "Tx being
flakey and Rx not working at all" and to avoid stability issues with
AR933X devices.

Grazvydas Ignotas fixes an oops in wl1251 related to enabling irqs.

Hauke Mehrtens provides a brcmfmac fix to avoid a failure to allocate
memory for the device firmware.

Johannes removes some code to support an unavailable batch of firmware
for the iwlwifi devices.  This provides much of the iwlwifi bulk
in this pull request.  Johannes also provides a fix for an iwlwifi
memory leak.

Meenakshi Venkataraman provides a trio of iwlwifi fixes.  One adds a
needed firmware update when BT traffic load changes.  Another removes
the use of shadow registers, which was leading to synchronization
problems between the driver and firmware.  The last avoids a WARNING
that came when the driver inappropriately sent firmware commands even
when a prerequisite command failed.

Last but not least, Soumik Das provides a mac80211 fix for a race
that resulted in a timeout and a disconnection.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3fdcbd453152329002f12dfda0be90b714458164:

  drop_monitor: Add module alias to enable automatic module loading (2012-0=
5-29 22:33:56 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Claudio Pisa (1):
      mac80211: fix flag check for QoS NOACK frames

Dan Carpenter (1):
      NFC: potential integer overflow problem in check_crc()

Emmanuel Grumbach (1):
      iwlwifi: fix the Transmit Frame Descriptor rings

Eyal Shapira (2):
      wlcore: fix undefined symbols when CONFIG_PM is not defined
      mac80211: fix ADDBA declined after suspend with wowlan

Felix Fietkau (5):
      ath5k: add possible wiphy interface combinations
      ath9k: stop rx dma before stopping tx
      ath9k: fix a use-after-free-bug when ath_tx_setup_buffer() fails
      ath9k_hw: update AR933x initvals to fix issues with high power devices
      ath9k_hw: apply internal regulator settings on AR933x

Grazvydas Ignotas (1):
      wl1251: fix oops on early interrupt

Hauke Mehrtens (1):
      brcmfmac: use vmalloc to allocate mem for the firmware

Johannes Berg (2):
      iwlwifi: remove ucode16 option
      iwlwifi: fix memory leak if opmode fails to init

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Meenakshi Venkataraman (3):
      iwlwifi: update BT traffic load states correctly
      iwlwifi: do not use shadow registers by default
      iwlwifi: do not send lq cmd when station add fails

Soumik Das (1):
      mac80211: Fix race in checking AP status by sending null frame

 drivers/net/wireless/ath/ath5k/base.c              |   19 ++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    3 +
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |  178 ++++++------
 drivers/net/wireless/ath/ath9k/hw.c                |    3 +
 drivers/net/wireless/ath/ath9k/main.c              |    7 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   16 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    5 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    8 -
 drivers/net/wireless/iwlwifi/Makefile              |    1 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   18 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |  288 ----------------=
----
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |  129 ---------
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   22 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    4 +-
 drivers/net/wireless/ti/wl1251/sdio.c              |    2 +-
 drivers/net/wireless/ti/wl1251/spi.c               |    3 +-
 drivers/net/wireless/ti/wlcore/acx.c               |    2 +
 drivers/net/wireless/ti/wlcore/acx.h               |    4 +-
 drivers/net/wireless/ti/wlcore/rx.c                |    2 +
 drivers/nfc/pn544_hci.c                            |    2 +-
 net/mac80211/mlme.c                                |    3 +-
 net/mac80211/tx.c                                  |    2 +-
 net/mac80211/util.c                                |   12 +-
 29 files changed, 184 insertions(+), 566 deletions(-)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-phy-db.h

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/a=
th/ath5k/base.c
index 0ba81a6..fbaa309 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -2415,6 +2415,22 @@ ath5k_tx_complete_poll_work(struct work_struct *work)
 * Initialization routines *
 \*************************/
=20
+static const struct ieee80211_iface_limit if_limits[] =3D {
+	{ .max =3D 2048,	.types =3D BIT(NL80211_IFTYPE_STATION) },
+	{ .max =3D 4,	.types =3D
+#ifdef CONFIG_MAC80211_MESH
+				 BIT(NL80211_IFTYPE_MESH_POINT) |
+#endif
+				 BIT(NL80211_IFTYPE_AP) },
+};
+
+static const struct ieee80211_iface_combination if_comb =3D {
+	.limits =3D if_limits,
+	.n_limits =3D ARRAY_SIZE(if_limits),
+	.max_interfaces =3D 2048,
+	.num_different_channels =3D 1,
+};
+
 int __devinit
 ath5k_init_ah(struct ath5k_hw *ah, const struct ath_bus_ops *bus_ops)
 {
@@ -2436,6 +2452,9 @@ ath5k_init_ah(struct ath5k_hw *ah, const struct ath_b=
us_ops *bus_ops)
 		BIT(NL80211_IFTYPE_ADHOC) |
 		BIT(NL80211_IFTYPE_MESH_POINT);
=20
+	hw->wiphy->iface_combinations =3D &if_comb;
+	hw->wiphy->n_iface_combinations =3D 1;
+
 	/* SW support for IBSS_RSN is provided by mac80211 */
 	hw->wiphy->flags |=3D WIPHY_FLAG_IBSS_RSN;
=20
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/w=
ireless/ath/ath9k/ar9003_eeprom.c
index ac53d90..dfb0441 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -3809,7 +3809,7 @@ static bool is_pmu_set(struct ath_hw *ah, u32 pmu_reg=
, int pmu_set)
 	return true;
 }
=20
-static void ar9003_hw_internal_regulator_apply(struct ath_hw *ah)
+void ar9003_hw_internal_regulator_apply(struct ath_hw *ah)
 {
 	int internal_regulator =3D
 		ath9k_hw_ar9300_get_eeprom(ah, EEP_INTERNAL_REGULATOR);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h b/drivers/net/w=
ireless/ath/ath9k/ar9003_eeprom.h
index 2505ac4..8396d15 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
@@ -334,4 +334,7 @@ u8 *ar9003_get_spur_chan_ptr(struct ath_hw *ah, bool is=
_2ghz);
=20
 unsigned int ar9003_get_paprd_scale_factor(struct ath_hw *ah,
 					   struct ath9k_channel *chan);
+
+void ar9003_hw_internal_regulator_apply(struct ath_hw *ah);
+
 #endif
diff --git a/drivers/net/wireless/ath/ath9k/ar9330_1p1_initvals.h b/drivers=
/net/wireless/ath/ath9k/ar9330_1p1_initvals.h
index f11d9b2..1bd3a3d 100644
--- a/drivers/net/wireless/ath/ath9k/ar9330_1p1_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9330_1p1_initvals.h
@@ -1,5 +1,6 @@
 /*
- * Copyright (c) 2011 Atheros Communications Inc.
+ * Copyright (c) 2010-2011 Atheros Communications Inc.
+ * Copyright (c) 2011-2012 Qualcomm Atheros Inc.
  *
  * Permission to use, copy, modify, and/or distribute this software for any
  * purpose with or without fee is hereby granted, provided that the above
@@ -18,7 +19,7 @@
 #define INITVALS_9330_1P1_H
=20
 static const u32 ar9331_1p1_baseband_postamble[][5] =3D {
-	/*  Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x00009810, 0xd00a8005, 0xd00a8005, 0xd00a8005, 0xd00a8005},
 	{0x00009820, 0x206a002e, 0x206a002e, 0x206a002e, 0x206a002e},
 	{0x00009824, 0x5ac640d0, 0x5ac640d0, 0x5ac640d0, 0x5ac640d0},
@@ -27,10 +28,10 @@ static const u32 ar9331_1p1_baseband_postamble[][5] =3D=
 {
 	{0x00009830, 0x0000059c, 0x0000059c, 0x0000059c, 0x0000059c},
 	{0x00009c00, 0x00000044, 0x00000044, 0x00000044, 0x00000044},
 	{0x00009e00, 0x0372161e, 0x0372161e, 0x037216a4, 0x037216a4},
-	{0x00009e04, 0x00182020, 0x00182020, 0x00182020, 0x00182020},
+	{0x00009e04, 0x00202020, 0x00202020, 0x00202020, 0x00202020},
 	{0x00009e0c, 0x6c4000e2, 0x6d4000e2, 0x6d4000e2, 0x6c4000e2},
 	{0x00009e10, 0x7ec80d2e, 0x7ec80d2e, 0x7ec80d2e, 0x7ec80d2e},
-	{0x00009e14, 0x31395d5e, 0x3139605e, 0x3139605e, 0x31395d5e},
+	{0x00009e14, 0x31365d5e, 0x3136605e, 0x3136605e, 0x31365d5e},
 	{0x00009e18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00009e1c, 0x0001cf9c, 0x0001cf9c, 0x00021f9c, 0x00021f9c},
 	{0x00009e20, 0x000003b5, 0x000003b5, 0x000003ce, 0x000003ce},
@@ -55,7 +56,7 @@ static const u32 ar9331_1p1_baseband_postamble[][5] =3D {
 	{0x0000a288, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a28c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a2c4, 0x00158d18, 0x00158d18, 0x00158d18, 0x00158d18},
-	{0x0000a2d0, 0x00071981, 0x00071981, 0x00071981, 0x00071981},
+	{0x0000a2d0, 0x00071982, 0x00071982, 0x00071982, 0x00071982},
 	{0x0000a2d8, 0xf999a83a, 0xf999a83a, 0xf999a83a, 0xf999a83a},
 	{0x0000a358, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000ae04, 0x00802020, 0x00802020, 0x00802020, 0x00802020},
@@ -63,7 +64,7 @@ static const u32 ar9331_1p1_baseband_postamble[][5] =3D {
 };
=20
 static const u32 ar9331_modes_lowest_ob_db_tx_gain_1p1[][5] =3D {
-	/*   Addr     5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x0000a2d8, 0x7999a83a, 0x7999a83a, 0x7999a83a, 0x7999a83a},
 	{0x0000a2dc, 0xffff2a52, 0xffff2a52, 0xffff2a52, 0xffff2a52},
 	{0x0000a2e0, 0xffffcc84, 0xffffcc84, 0xffffcc84, 0xffffcc84},
@@ -155,7 +156,7 @@ static const u32 ar9331_modes_lowest_ob_db_tx_gain_1p1[=
][5] =3D {
 };
=20
 static const u32 ar9331_modes_high_ob_db_tx_gain_1p1[][5] =3D {
-	/*   Addr     5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x0000a2d8, 0x7999a83a, 0x7999a83a, 0x7999a83a, 0x7999a83a},
 	{0x0000a2dc, 0xffaa9a52, 0xffaa9a52, 0xffaa9a52, 0xffaa9a52},
 	{0x0000a2e0, 0xffb31c84, 0xffb31c84, 0xffb31c84, 0xffb31c84},
@@ -245,7 +246,7 @@ static const u32 ar9331_modes_high_ob_db_tx_gain_1p1[][=
5] =3D {
 };
=20
 static const u32 ar9331_modes_low_ob_db_tx_gain_1p1[][5] =3D {
-	/*   Addr     5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x0000a2d8, 0x7999a83a, 0x7999a83a, 0x7999a83a, 0x7999a83a},
 	{0x0000a2dc, 0xffff2a52, 0xffff2a52, 0xffff2a52, 0xffff2a52},
 	{0x0000a2e0, 0xffffcc84, 0xffffcc84, 0xffffcc84, 0xffffcc84},
@@ -377,14 +378,14 @@ static const u32 ar9331_1p1_radio_core[][2] =3D {
 	{0x000160b4, 0x92480040},
 	{0x000160c0, 0x006db6db},
 	{0x000160c4, 0x0186db60},
-	{0x000160c8, 0x6db6db6c},
+	{0x000160c8, 0x6db4db6c},
 	{0x000160cc, 0x6de6c300},
 	{0x000160d0, 0x14500820},
 	{0x00016100, 0x04cb0001},
 	{0x00016104, 0xfff80015},
 	{0x00016108, 0x00080010},
 	{0x0001610c, 0x00170000},
-	{0x00016140, 0x10804000},
+	{0x00016140, 0x10800000},
 	{0x00016144, 0x01884080},
 	{0x00016148, 0x000080c0},
 	{0x00016280, 0x01000015},
@@ -417,7 +418,7 @@ static const u32 ar9331_1p1_radio_core[][2] =3D {
 };
=20
 static const u32 ar9331_1p1_soc_postamble[][5] =3D {
-	/*  Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x00007010, 0x00000022, 0x00000022, 0x00000022, 0x00000022},
 };
=20
@@ -691,7 +692,7 @@ static const u32 ar9331_1p1_baseband_core[][2] =3D {
 };
=20
 static const u32 ar9331_modes_high_power_tx_gain_1p1[][5] =3D {
-	/*  Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x0000a2d8, 0x7999a83a, 0x7999a83a, 0x7999a83a, 0x7999a83a},
 	{0x0000a2dc, 0xffff2a52, 0xffff2a52, 0xffff2a52, 0xffff2a52},
 	{0x0000a2e0, 0xffffcc84, 0xffffcc84, 0xffffcc84, 0xffffcc84},
@@ -783,7 +784,7 @@ static const u32 ar9331_modes_high_power_tx_gain_1p1[][=
5] =3D {
 };
=20
 static const u32 ar9331_1p1_mac_postamble[][5] =3D {
-	/*  Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20  */
+	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
 	{0x00001030, 0x00000230, 0x00000460, 0x000002c0, 0x00000160},
 	{0x00001070, 0x00000168, 0x000002d0, 0x00000318, 0x0000018c},
 	{0x000010b0, 0x00000e60, 0x00001cc0, 0x00007c70, 0x00003e38},
@@ -973,26 +974,27 @@ static const u32 ar9331_1p1_mac_core[][2] =3D {
=20
 static const u32 ar9331_common_rx_gain_1p1[][2] =3D {
 	/* Addr      allmodes  */
-	{0x0000a000, 0x00010000},
-	{0x0000a004, 0x00030002},
-	{0x0000a008, 0x00050004},
-	{0x0000a00c, 0x00810080},
-	{0x0000a010, 0x00830082},
-	{0x0000a014, 0x01810180},
-	{0x0000a018, 0x01830182},
-	{0x0000a01c, 0x01850184},
-	{0x0000a020, 0x01890188},
-	{0x0000a024, 0x018b018a},
-	{0x0000a028, 0x018d018c},
-	{0x0000a02c, 0x01910190},
-	{0x0000a030, 0x01930192},
-	{0x0000a034, 0x01950194},
-	{0x0000a038, 0x038a0196},
-	{0x0000a03c, 0x038c038b},
-	{0x0000a040, 0x0390038d},
-	{0x0000a044, 0x03920391},
-	{0x0000a048, 0x03940393},
-	{0x0000a04c, 0x03960395},
+	{0x00009e18, 0x05000000},
+	{0x0000a000, 0x00060005},
+	{0x0000a004, 0x00810080},
+	{0x0000a008, 0x00830082},
+	{0x0000a00c, 0x00850084},
+	{0x0000a010, 0x01820181},
+	{0x0000a014, 0x01840183},
+	{0x0000a018, 0x01880185},
+	{0x0000a01c, 0x018a0189},
+	{0x0000a020, 0x02850284},
+	{0x0000a024, 0x02890288},
+	{0x0000a028, 0x028b028a},
+	{0x0000a02c, 0x03850384},
+	{0x0000a030, 0x03890388},
+	{0x0000a034, 0x038b038a},
+	{0x0000a038, 0x038d038c},
+	{0x0000a03c, 0x03910390},
+	{0x0000a040, 0x03930392},
+	{0x0000a044, 0x03950394},
+	{0x0000a048, 0x00000396},
+	{0x0000a04c, 0x00000000},
 	{0x0000a050, 0x00000000},
 	{0x0000a054, 0x00000000},
 	{0x0000a058, 0x00000000},
@@ -1005,15 +1007,15 @@ static const u32 ar9331_common_rx_gain_1p1[][2] =3D=
 {
 	{0x0000a074, 0x00000000},
 	{0x0000a078, 0x00000000},
 	{0x0000a07c, 0x00000000},
-	{0x0000a080, 0x22222229},
-	{0x0000a084, 0x1d1d1d1d},
-	{0x0000a088, 0x1d1d1d1d},
-	{0x0000a08c, 0x1d1d1d1d},
-	{0x0000a090, 0x171d1d1d},
-	{0x0000a094, 0x11111717},
-	{0x0000a098, 0x00030311},
-	{0x0000a09c, 0x00000000},
-	{0x0000a0a0, 0x00000000},
+	{0x0000a080, 0x28282828},
+	{0x0000a084, 0x28282828},
+	{0x0000a088, 0x28282828},
+	{0x0000a08c, 0x28282828},
+	{0x0000a090, 0x28282828},
+	{0x0000a094, 0x24242428},
+	{0x0000a098, 0x171e1e1e},
+	{0x0000a09c, 0x02020b0b},
+	{0x0000a0a0, 0x02020202},
 	{0x0000a0a4, 0x00000000},
 	{0x0000a0a8, 0x00000000},
 	{0x0000a0ac, 0x00000000},
@@ -1021,27 +1023,27 @@ static const u32 ar9331_common_rx_gain_1p1[][2] =3D=
 {
 	{0x0000a0b4, 0x00000000},
 	{0x0000a0b8, 0x00000000},
 	{0x0000a0bc, 0x00000000},
-	{0x0000a0c0, 0x001f0000},
-	{0x0000a0c4, 0x01000101},
-	{0x0000a0c8, 0x011e011f},
-	{0x0000a0cc, 0x011c011d},
-	{0x0000a0d0, 0x02030204},
-	{0x0000a0d4, 0x02010202},
-	{0x0000a0d8, 0x021f0200},
-	{0x0000a0dc, 0x0302021e},
-	{0x0000a0e0, 0x03000301},
-	{0x0000a0e4, 0x031e031f},
-	{0x0000a0e8, 0x0402031d},
-	{0x0000a0ec, 0x04000401},
-	{0x0000a0f0, 0x041e041f},
-	{0x0000a0f4, 0x0502041d},
-	{0x0000a0f8, 0x05000501},
-	{0x0000a0fc, 0x051e051f},
-	{0x0000a100, 0x06010602},
-	{0x0000a104, 0x061f0600},
-	{0x0000a108, 0x061d061e},
-	{0x0000a10c, 0x07020703},
-	{0x0000a110, 0x07000701},
+	{0x0000a0c0, 0x22072208},
+	{0x0000a0c4, 0x22052206},
+	{0x0000a0c8, 0x22032204},
+	{0x0000a0cc, 0x22012202},
+	{0x0000a0d0, 0x221f2200},
+	{0x0000a0d4, 0x221d221e},
+	{0x0000a0d8, 0x33023303},
+	{0x0000a0dc, 0x33003301},
+	{0x0000a0e0, 0x331e331f},
+	{0x0000a0e4, 0x4402331d},
+	{0x0000a0e8, 0x44004401},
+	{0x0000a0ec, 0x441e441f},
+	{0x0000a0f0, 0x55025503},
+	{0x0000a0f4, 0x55005501},
+	{0x0000a0f8, 0x551e551f},
+	{0x0000a0fc, 0x6602551d},
+	{0x0000a100, 0x66006601},
+	{0x0000a104, 0x661e661f},
+	{0x0000a108, 0x7703661d},
+	{0x0000a10c, 0x77017702},
+	{0x0000a110, 0x00007700},
 	{0x0000a114, 0x00000000},
 	{0x0000a118, 0x00000000},
 	{0x0000a11c, 0x00000000},
@@ -1054,26 +1056,26 @@ static const u32 ar9331_common_rx_gain_1p1[][2] =3D=
 {
 	{0x0000a138, 0x00000000},
 	{0x0000a13c, 0x00000000},
 	{0x0000a140, 0x001f0000},
-	{0x0000a144, 0x01000101},
-	{0x0000a148, 0x011e011f},
-	{0x0000a14c, 0x011c011d},
-	{0x0000a150, 0x02030204},
-	{0x0000a154, 0x02010202},
-	{0x0000a158, 0x021f0200},
-	{0x0000a15c, 0x0302021e},
-	{0x0000a160, 0x03000301},
-	{0x0000a164, 0x031e031f},
-	{0x0000a168, 0x0402031d},
-	{0x0000a16c, 0x04000401},
-	{0x0000a170, 0x041e041f},
-	{0x0000a174, 0x0502041d},
-	{0x0000a178, 0x05000501},
-	{0x0000a17c, 0x051e051f},
-	{0x0000a180, 0x06010602},
-	{0x0000a184, 0x061f0600},
-	{0x0000a188, 0x061d061e},
-	{0x0000a18c, 0x07020703},
-	{0x0000a190, 0x07000701},
+	{0x0000a144, 0x111f1100},
+	{0x0000a148, 0x111d111e},
+	{0x0000a14c, 0x111b111c},
+	{0x0000a150, 0x22032204},
+	{0x0000a154, 0x22012202},
+	{0x0000a158, 0x221f2200},
+	{0x0000a15c, 0x221d221e},
+	{0x0000a160, 0x33013302},
+	{0x0000a164, 0x331f3300},
+	{0x0000a168, 0x4402331e},
+	{0x0000a16c, 0x44004401},
+	{0x0000a170, 0x441e441f},
+	{0x0000a174, 0x55015502},
+	{0x0000a178, 0x551f5500},
+	{0x0000a17c, 0x6602551e},
+	{0x0000a180, 0x66006601},
+	{0x0000a184, 0x661e661f},
+	{0x0000a188, 0x7703661d},
+	{0x0000a18c, 0x77017702},
+	{0x0000a190, 0x00007700},
 	{0x0000a194, 0x00000000},
 	{0x0000a198, 0x00000000},
 	{0x0000a19c, 0x00000000},
@@ -1100,14 +1102,14 @@ static const u32 ar9331_common_rx_gain_1p1[][2] =3D=
 {
 	{0x0000a1f0, 0x00000396},
 	{0x0000a1f4, 0x00000396},
 	{0x0000a1f8, 0x00000396},
-	{0x0000a1fc, 0x00000196},
+	{0x0000a1fc, 0x00000296},
 };
=20
 static const u32 ar9331_common_tx_gain_offset1_1[][1] =3D {
-	{0},
-	{3},
-	{0},
-	{0},
+	{0x00000000},
+	{0x00000003},
+	{0x00000000},
+	{0x00000000},
 };
=20
 static const u32 ar9331_1p1_chansel_xtal_25M[] =3D {
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index abe05ec..7db1890 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1468,6 +1468,9 @@ static bool ath9k_hw_chip_reset(struct ath_hw *ah,
 		return false;
=20
 	ah->chip_fullsleep =3D false;
+
+	if (AR_SREV_9330(ah))
+		ar9003_hw_internal_regulator_apply(ah);
 	ath9k_hw_init_pll(ah, chan);
 	ath9k_hw_set_rfmode(ah, chan);
=20
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index dfa78e8..4de4473 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -239,7 +239,7 @@ static bool ath_prepare_reset(struct ath_softc *sc, boo=
l retry_tx, bool flush)
 {
 	struct ath_hw *ah =3D sc->sc_ah;
 	struct ath_common *common =3D ath9k_hw_common(ah);
-	bool ret;
+	bool ret =3D true;
=20
 	ieee80211_stop_queues(sc->hw);
=20
@@ -250,11 +250,12 @@ static bool ath_prepare_reset(struct ath_softc *sc, b=
ool retry_tx, bool flush)
 	ath9k_debug_samp_bb_mac(sc);
 	ath9k_hw_disable_interrupts(ah);
=20
-	ret =3D ath_drain_all_txq(sc, retry_tx);
-
 	if (!ath_stoprecv(sc))
 		ret =3D false;
=20
+	if (!ath_drain_all_txq(sc, retry_tx))
+		ret =3D false;
+
 	if (!flush) {
 		if (ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
 			ath_rx_tasklet(sc, 1, true);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 23eaa1b..d59dd01 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -64,7 +64,8 @@ static void ath_tx_update_baw(struct ath_softc *sc, struc=
t ath_atx_tid *tid,
 static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
 					   struct ath_txq *txq,
 					   struct ath_atx_tid *tid,
-					   struct sk_buff *skb);
+					   struct sk_buff *skb,
+					   bool dequeue);
=20
 enum {
 	MCS_HT20,
@@ -811,7 +812,7 @@ static enum ATH_AGGR_STATUS ath_tx_form_aggr(struct ath=
_softc *sc,
 		fi =3D get_frame_info(skb);
 		bf =3D fi->bf;
 		if (!fi->bf)
-			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
+			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb, true);
=20
 		if (!bf)
 			continue;
@@ -1726,7 +1727,7 @@ static void ath_tx_send_ampdu(struct ath_softc *sc, s=
truct ath_atx_tid *tid,
 		return;
 	}
=20
-	bf =3D ath_tx_setup_buffer(sc, txctl->txq, tid, skb);
+	bf =3D ath_tx_setup_buffer(sc, txctl->txq, tid, skb, false);
 	if (!bf)
 		return;
=20
@@ -1753,7 +1754,7 @@ static void ath_tx_send_normal(struct ath_softc *sc, =
struct ath_txq *txq,
=20
 	bf =3D fi->bf;
 	if (!bf)
-		bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
+		bf =3D ath_tx_setup_buffer(sc, txq, tid, skb, false);
=20
 	if (!bf)
 		return;
@@ -1814,7 +1815,8 @@ u8 ath_txchainmask_reduction(struct ath_softc *sc, u8=
 chainmask, u32 rate)
 static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
 					   struct ath_txq *txq,
 					   struct ath_atx_tid *tid,
-					   struct sk_buff *skb)
+					   struct sk_buff *skb,
+					   bool dequeue)
 {
 	struct ath_common *common =3D ath9k_hw_common(sc->sc_ah);
 	struct ath_frame_info *fi =3D get_frame_info(skb);
@@ -1863,6 +1865,8 @@ static struct ath_buf *ath_tx_setup_buffer(struct ath=
_softc *sc,
 	return bf;
=20
 error:
+	if (dequeue)
+		__skb_unlink(skb, &tid->buf_q);
 	dev_kfree_skb_any(skb);
 	return NULL;
 }
@@ -1893,7 +1897,7 @@ static void ath_tx_start_dma(struct ath_softc *sc, st=
ruct sk_buff *skb,
 		 */
 		ath_tx_send_ampdu(sc, tid, skb, txctl);
 	} else {
-		bf =3D ath_tx_setup_buffer(sc, txctl->txq, tid, skb);
+		bf =3D ath_tx_setup_buffer(sc, txctl->txq, tid, skb, false);
 		if (!bf)
 			return;
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index c5a34ff..a299d42 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -28,6 +28,7 @@
 #include <linux/uaccess.h>
 #include <linux/firmware.h>
 #include <linux/usb.h>
+#include <linux/vmalloc.h>
 #include <net/cfg80211.h>
=20
 #include <defs.h>
@@ -1239,7 +1240,7 @@ static int brcmf_usb_get_fw(struct brcmf_usbdev_info =
*devinfo)
 		return -EINVAL;
 	}
=20
-	devinfo->image =3D kmalloc(fw->size, GFP_ATOMIC); /* plus nvram */
+	devinfo->image =3D vmalloc(fw->size); /* plus nvram */
 	if (!devinfo->image)
 		return -ENOMEM;
=20
@@ -1603,7 +1604,7 @@ static struct usb_driver brcmf_usbdrvr =3D {
 void brcmf_usb_exit(void)
 {
 	usb_deregister(&brcmf_usbdrvr);
-	kfree(g_image.data);
+	vfree(g_image.data);
 	g_image.data =3D NULL;
 	g_image.len =3D 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iw=
lwifi/Kconfig
index db6c6e5..2463c06 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -137,11 +137,3 @@ config IWLWIFI_EXPERIMENTAL_MFP
 	  even if the microcode doesn't advertise it.
=20
 	  Say Y only if you want to experiment with MFP.
-
-config IWLWIFI_UCODE16
-	bool "support uCode 16.0"
-	depends on IWLWIFI
-	help
-	  This option enables support for uCode version 16.0.
-
-	  Say Y if you want to use 16.0 microcode.
diff --git a/drivers/net/wireless/iwlwifi/Makefile b/drivers/net/wireless/i=
wlwifi/Makefile
index 406f297..d615eac 100644
--- a/drivers/net/wireless/iwlwifi/Makefile
+++ b/drivers/net/wireless/iwlwifi/Makefile
@@ -18,7 +18,6 @@ iwlwifi-objs		+=3D iwl-notif-wait.o
 iwlwifi-objs		+=3D iwl-trans-pcie.o iwl-trans-pcie-rx.o iwl-trans-pcie-tx.o
=20
=20
-iwlwifi-$(CONFIG_IWLWIFI_UCODE16) +=3D iwl-phy-db.o
 iwlwifi-$(CONFIG_IWLWIFI_DEBUGFS) +=3D iwl-debugfs.o
 iwlwifi-$(CONFIG_IWLWIFI_DEVICE_TRACING) +=3D iwl-devtrace.o
 iwlwifi-$(CONFIG_IWLWIFI_DEVICE_TESTMODE) +=3D iwl-testmode.o
diff --git a/drivers/net/wireless/iwlwifi/iwl-2000.c b/drivers/net/wireless=
/iwlwifi/iwl-2000.c
index 7f79341..8133105 100644
--- a/drivers/net/wireless/iwlwifi/iwl-2000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-2000.c
@@ -79,7 +79,7 @@ static const struct iwl_base_params iwl2000_base_params =
=3D {
 	.chain_noise_scale =3D 1000,
 	.wd_timeout =3D IWL_DEF_WD_TIMEOUT,
 	.max_event_log_size =3D 512,
-	.shadow_reg_enable =3D true,
+	.shadow_reg_enable =3D false, /* TODO: fix bugs using this feature */
 	.hd_v2 =3D true,
 };
=20
@@ -97,7 +97,7 @@ static const struct iwl_base_params iwl2030_base_params =
=3D {
 	.chain_noise_scale =3D 1000,
 	.wd_timeout =3D IWL_LONG_WD_TIMEOUT,
 	.max_event_log_size =3D 512,
-	.shadow_reg_enable =3D true,
+	.shadow_reg_enable =3D false, /* TODO: fix bugs using this feature */
 	.hd_v2 =3D true,
 };
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless=
/iwlwifi/iwl-6000.c
index 381b02c..19f7ee8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -86,7 +86,7 @@ static const struct iwl_base_params iwl6000_base_params =
=3D {
 	.chain_noise_scale =3D 1000,
 	.wd_timeout =3D IWL_DEF_WD_TIMEOUT,
 	.max_event_log_size =3D 512,
-	.shadow_reg_enable =3D true,
+	.shadow_reg_enable =3D false, /* TODO: fix bugs using this feature */
 };
=20
 static const struct iwl_base_params iwl6050_base_params =3D {
@@ -102,7 +102,7 @@ static const struct iwl_base_params iwl6050_base_params=
 =3D {
 	.chain_noise_scale =3D 1500,
 	.wd_timeout =3D IWL_DEF_WD_TIMEOUT,
 	.max_event_log_size =3D 1024,
-	.shadow_reg_enable =3D true,
+	.shadow_reg_enable =3D false, /* TODO: fix bugs using this feature */
 };
=20
 static const struct iwl_base_params iwl6000_g2_base_params =3D {
@@ -118,7 +118,7 @@ static const struct iwl_base_params iwl6000_g2_base_par=
ams =3D {
 	.chain_noise_scale =3D 1000,
 	.wd_timeout =3D IWL_LONG_WD_TIMEOUT,
 	.max_event_log_size =3D 512,
-	.shadow_reg_enable =3D true,
+	.shadow_reg_enable =3D false, /* TODO: fix bugs using this feature */
 };
=20
 static const struct iwl_ht_params iwl6000_ht_params =3D {
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wirele=
ss/iwlwifi/iwl-agn-rs.c
index 51e1a69..8cebd7c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -884,6 +884,7 @@ static void rs_bt_update_lq(struct iwl_priv *priv, stru=
ct iwl_rxon_context *ctx,
 	if ((priv->bt_traffic_load !=3D priv->last_bt_traffic_load) ||
 	    (priv->bt_full_concurrent !=3D full_concurrent)) {
 		priv->bt_full_concurrent =3D full_concurrent;
+		priv->last_bt_traffic_load =3D priv->bt_traffic_load;
=20
 		/* Update uCode's rate table. */
 		tbl =3D &(lq_sta->lq_info[lq_sta->active_tbl]);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c b/drivers/net/wirel=
ess/iwlwifi/iwl-agn-sta.c
index b31584e..aea07aa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
@@ -772,7 +772,7 @@ void iwl_restore_stations(struct iwl_priv *priv, struct=
 iwl_rxon_context *ctx)
 						~IWL_STA_DRIVER_ACTIVE;
 				priv->stations[i].used &=3D
 						~IWL_STA_UCODE_INPROGRESS;
-				spin_unlock_bh(&priv->sta_lock);
+				continue;
 			}
 			/*
 			 * Rate scaling has already been initialized, send
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/=
iwlwifi/iwl-drv.c
index 3c72bad..d742900 100644
--- a/drivers/net/wireless/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/iwlwifi/iwl-drv.c
@@ -657,17 +657,17 @@ static int iwl_parse_tlv_firmware(struct iwl_drv *drv,
 	return -EINVAL;
 }
=20
-static int alloc_pci_desc(struct iwl_drv *drv,
-			  struct iwl_firmware_pieces *pieces,
-			  enum iwl_ucode_type type)
+static int iwl_alloc_ucode(struct iwl_drv *drv,
+			   struct iwl_firmware_pieces *pieces,
+			   enum iwl_ucode_type type)
 {
 	int i;
 	for (i =3D 0;
 	     i < IWL_UCODE_SECTION_MAX && get_sec_size(pieces, type, i);
 	     i++)
 		if (iwl_alloc_fw_desc(drv, &(drv->fw.img[type].sec[i]),
-						get_sec(pieces, type, i)))
-			return -1;
+				      get_sec(pieces, type, i)))
+			return -ENOMEM;
 	return 0;
 }
=20
@@ -825,8 +825,8 @@ static void iwl_ucode_callback(const struct firmware *u=
code_raw, void *context)
 	 * 1) unmodified from disk
 	 * 2) backup cache for save/restore during power-downs */
 	for (i =3D 0; i < IWL_UCODE_TYPE_MAX; i++)
-		if (alloc_pci_desc(drv, &pieces, i))
-			goto err_pci_alloc;
+		if (iwl_alloc_ucode(drv, &pieces, i))
+			goto out_free_fw;
=20
 	/* Now that we can no longer fail, copy information */
=20
@@ -866,7 +866,7 @@ static void iwl_ucode_callback(const struct firmware *u=
code_raw, void *context)
 	drv->op_mode =3D iwl_dvm_ops.start(drv->trans, drv->cfg, &drv->fw);
=20
 	if (!drv->op_mode)
-		goto out_unbind;
+		goto out_free_fw;
=20
 	return;
=20
@@ -877,7 +877,7 @@ static void iwl_ucode_callback(const struct firmware *u=
code_raw, void *context)
 		goto out_unbind;
 	return;
=20
- err_pci_alloc:
+ out_free_fw:
 	IWL_ERR(drv, "failed to allocate pci memory\n");
 	iwl_dealloc_ucode(drv);
 	release_firmware(ucode_raw);
diff --git a/drivers/net/wireless/iwlwifi/iwl-phy-db.c b/drivers/net/wirele=
ss/iwlwifi/iwl-phy-db.c
deleted file mode 100644
index f166955..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-phy-db.c
+++ /dev/null
@@ -1,288 +0,0 @@
-/*************************************************************************=
*****
- *
- * This file is provided under a dual BSD/GPLv2 license.  When using or
- * redistributing this file, you may do so under either license.
- *
- * GPL LICENSE SUMMARY
- *
- * Copyright(c) 2007 - 2012 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110,
- * USA
- *
- * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.GPL.
- *
- * Contact Information:
- *  Intel Linux Wireless <ilw@linux.intel.com>
- * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-64=
97
- *
- * BSD LICENSE
- *
- * Copyright(c) 2005 - 2012 Intel Corporation. All rights reserved.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- *  * Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- *  * Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in
- *    the documentation and/or other materials provided with the
- *    distribution.
- *  * Neither the name Intel Corporation nor the names of its
- *    contributors may be used to endorse or promote products derived
- *    from this software without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- *************************************************************************=
****/
-
-#include <linux/slab.h>
-#include <linux/string.h>
-
-#include "iwl-debug.h"
-#include "iwl-dev.h"
-
-#include "iwl-phy-db.h"
-
-#define CHANNEL_NUM_SIZE	4	/* num of channels in calib_ch size */
-
-struct iwl_phy_db *iwl_phy_db_init(struct device *dev)
-{
-	struct iwl_phy_db *phy_db =3D kzalloc(sizeof(struct iwl_phy_db),
-					    GFP_KERNEL);
-
-	if (!phy_db)
-		return phy_db;
-
-	phy_db->dev =3D dev;
-
-	/* TODO: add default values of the phy db. */
-	return phy_db;
-}
-
-/*
- * get phy db section: returns a pointer to a phy db section specified by
- * type and channel group id.
- */
-static struct iwl_phy_db_entry *
-iwl_phy_db_get_section(struct iwl_phy_db *phy_db,
-		       enum iwl_phy_db_section_type type,
-		       u16 chg_id)
-{
-	if (!phy_db || type < 0 || type >=3D IWL_PHY_DB_MAX)
-		return NULL;
-
-	switch (type) {
-	case IWL_PHY_DB_CFG:
-		return &phy_db->cfg;
-	case IWL_PHY_DB_CALIB_NCH:
-		return &phy_db->calib_nch;
-	case IWL_PHY_DB_CALIB_CH:
-		return &phy_db->calib_ch;
-	case IWL_PHY_DB_CALIB_CHG_PAPD:
-		if (chg_id < 0 || chg_id >=3D IWL_NUM_PAPD_CH_GROUPS)
-			return NULL;
-		return &phy_db->calib_ch_group_papd[chg_id];
-	case IWL_PHY_DB_CALIB_CHG_TXP:
-		if (chg_id < 0 || chg_id >=3D IWL_NUM_TXP_CH_GROUPS)
-			return NULL;
-		return &phy_db->calib_ch_group_txp[chg_id];
-	default:
-		return NULL;
-	}
-	return NULL;
-}
-
-static void iwl_phy_db_free_section(struct iwl_phy_db *phy_db,
-				    enum iwl_phy_db_section_type type,
-				    u16 chg_id)
-{
-	struct iwl_phy_db_entry *entry =3D
-				iwl_phy_db_get_section(phy_db, type, chg_id);
-	if (!entry)
-		return;
-
-	kfree(entry->data);
-	entry->data =3D NULL;
-	entry->size =3D 0;
-}
-
-void iwl_phy_db_free(struct iwl_phy_db *phy_db)
-{
-	int i;
-
-	if (!phy_db)
-		return;
-
-	iwl_phy_db_free_section(phy_db, IWL_PHY_DB_CFG, 0);
-	iwl_phy_db_free_section(phy_db, IWL_PHY_DB_CALIB_NCH, 0);
-	iwl_phy_db_free_section(phy_db, IWL_PHY_DB_CALIB_CH, 0);
-	for (i =3D 0; i < IWL_NUM_PAPD_CH_GROUPS; i++)
-		iwl_phy_db_free_section(phy_db, IWL_PHY_DB_CALIB_CHG_PAPD, i);
-	for (i =3D 0; i < IWL_NUM_TXP_CH_GROUPS; i++)
-		iwl_phy_db_free_section(phy_db, IWL_PHY_DB_CALIB_CHG_TXP, i);
-
-	kfree(phy_db);
-}
-
-int iwl_phy_db_set_section(struct iwl_phy_db *phy_db,
-			   enum iwl_phy_db_section_type type, u8 *data,
-			   u16 size, gfp_t alloc_ctx)
-{
-	struct iwl_phy_db_entry *entry;
-	u16 chg_id =3D 0;
-
-	if (!phy_db)
-		return -EINVAL;
-
-	if (type =3D=3D IWL_PHY_DB_CALIB_CHG_PAPD ||
-	    type =3D=3D IWL_PHY_DB_CALIB_CHG_TXP)
-		chg_id =3D le16_to_cpup((__le16 *)data);
-
-	entry =3D iwl_phy_db_get_section(phy_db, type, chg_id);
-	if (!entry)
-		return -EINVAL;
-
-	kfree(entry->data);
-	entry->data =3D kmemdup(data, size, alloc_ctx);
-	if (!entry->data) {
-		entry->size =3D 0;
-		return -ENOMEM;
-	}
-
-	entry->size =3D size;
-
-	if (type =3D=3D IWL_PHY_DB_CALIB_CH) {
-		phy_db->channel_num =3D le32_to_cpup((__le32 *)data);
-		phy_db->channel_size =3D
-		      (size - CHANNEL_NUM_SIZE) / phy_db->channel_num;
-	}
-
-	return 0;
-}
-
-static int is_valid_channel(u16 ch_id)
-{
-	if (ch_id <=3D 14 ||
-	    (36 <=3D ch_id && ch_id <=3D 64 && ch_id % 4 =3D=3D 0) ||
-	    (100 <=3D ch_id && ch_id <=3D 140 && ch_id % 4 =3D=3D 0) ||
-	    (145 <=3D ch_id && ch_id <=3D 165 && ch_id % 4 =3D=3D 1))
-		return 1;
-	return 0;
-}
-
-static u8 ch_id_to_ch_index(u16 ch_id)
-{
-	if (WARN_ON(!is_valid_channel(ch_id)))
-		return 0xff;
-
-	if (ch_id <=3D 14)
-		return ch_id - 1;
-	if (ch_id <=3D 64)
-		return (ch_id + 20) / 4;
-	if (ch_id <=3D 140)
-		return (ch_id - 12) / 4;
-	return (ch_id - 13) / 4;
-}
-
-
-static u16 channel_id_to_papd(u16 ch_id)
-{
-	if (WARN_ON(!is_valid_channel(ch_id)))
-		return 0xff;
-
-	if (1 <=3D ch_id && ch_id <=3D 14)
-		return 0;
-	if (36 <=3D ch_id && ch_id <=3D 64)
-		return 1;
-	if (100 <=3D ch_id && ch_id <=3D 140)
-		return 2;
-	return 3;
-}
-
-static u16 channel_id_to_txp(struct iwl_phy_db *phy_db, u16 ch_id)
-{
-	struct iwl_phy_db_chg_txp *txp_chg;
-	int i;
-	u8 ch_index =3D ch_id_to_ch_index(ch_id);
-	if (ch_index =3D=3D 0xff)
-		return 0xff;
-
-	for (i =3D 0; i < IWL_NUM_TXP_CH_GROUPS; i++) {
-		txp_chg =3D (void *)phy_db->calib_ch_group_txp[i].data;
-		if (!txp_chg)
-			return 0xff;
-		/*
-		 * Looking for the first channel group that its max channel is
-		 * higher then wanted channel.
-		 */
-		if (le16_to_cpu(txp_chg->max_channel_idx) >=3D ch_index)
-			return i;
-	}
-	return 0xff;
-}
-
-int iwl_phy_db_get_section_data(struct iwl_phy_db *phy_db,
-				enum iwl_phy_db_section_type type, u8 **data,
-				u16 *size, u16 ch_id)
-{
-	struct iwl_phy_db_entry *entry;
-	u32 channel_num;
-	u32 channel_size;
-	u16 ch_group_id =3D 0;
-	u16 index;
-
-	if (!phy_db)
-		return -EINVAL;
-
-	/* find wanted channel group */
-	if (type =3D=3D IWL_PHY_DB_CALIB_CHG_PAPD)
-		ch_group_id =3D channel_id_to_papd(ch_id);
-	else if (type =3D=3D IWL_PHY_DB_CALIB_CHG_TXP)
-		ch_group_id =3D channel_id_to_txp(phy_db, ch_id);
-
-	entry =3D iwl_phy_db_get_section(phy_db, type, ch_group_id);
-	if (!entry)
-		return -EINVAL;
-
-	if (type =3D=3D IWL_PHY_DB_CALIB_CH) {
-		index =3D ch_id_to_ch_index(ch_id);
-		channel_num =3D phy_db->channel_num;
-		channel_size =3D phy_db->channel_size;
-		if (index >=3D channel_num) {
-			IWL_ERR(phy_db, "Wrong channel number %d", ch_id);
-			return -EINVAL;
-		}
-		*data =3D entry->data + CHANNEL_NUM_SIZE + index * channel_size;
-		*size =3D channel_size;
-	} else {
-		*data =3D entry->data;
-		*size =3D entry->size;
-	}
-	return 0;
-}
diff --git a/drivers/net/wireless/iwlwifi/iwl-phy-db.h b/drivers/net/wirele=
ss/iwlwifi/iwl-phy-db.h
deleted file mode 100644
index c34c6a9..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-phy-db.h
+++ /dev/null
@@ -1,129 +0,0 @@
-/*************************************************************************=
*****
- *
- * This file is provided under a dual BSD/GPLv2 license.  When using or
- * redistributing this file, you may do so under either license.
- *
- * GPL LICENSE SUMMARY
- *
- * Copyright(c) 2007 - 2012 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110,
- * USA
- *
- * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.GPL.
- *
- * Contact Information:
- *  Intel Linux Wireless <ilw@linux.intel.com>
- * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-64=
97
- *
- * BSD LICENSE
- *
- * Copyright(c) 2005 - 2012 Intel Corporation. All rights reserved.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- *  * Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- *  * Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in
- *    the documentation and/or other materials provided with the
- *    distribution.
- *  * Neither the name Intel Corporation nor the names of its
- *    contributors may be used to endorse or promote products derived
- *    from this software without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- *************************************************************************=
****/
-
-#ifndef __IWL_PHYDB_H__
-#define __IWL_PHYDB_H__
-
-#include <linux/types.h>
-
-#define IWL_NUM_PAPD_CH_GROUPS	4
-#define IWL_NUM_TXP_CH_GROUPS	8
-
-struct iwl_phy_db_entry {
-	u16	size;
-	u8	*data;
-};
-
-struct iwl_shared;
-
-/**
- * struct iwl_phy_db - stores phy configuration and calibration data.
- *
- * @cfg: phy configuration.
- * @calib_nch: non channel specific calibration data.
- * @calib_ch: channel specific calibration data.
- * @calib_ch_group_papd: calibration data related to papd channel group.
- * @calib_ch_group_txp: calibration data related to tx power chanel group.
- */
-struct iwl_phy_db {
-	struct iwl_phy_db_entry	cfg;
-	struct iwl_phy_db_entry	calib_nch;
-	struct iwl_phy_db_entry	calib_ch;
-	struct iwl_phy_db_entry	calib_ch_group_papd[IWL_NUM_PAPD_CH_GROUPS];
-	struct iwl_phy_db_entry	calib_ch_group_txp[IWL_NUM_TXP_CH_GROUPS];
-
-	u32 channel_num;
-	u32 channel_size;
-
-	/* for an access to the logger */
-	struct device *dev;
-};
-
-enum iwl_phy_db_section_type {
-	IWL_PHY_DB_CFG =3D 1,
-	IWL_PHY_DB_CALIB_NCH,
-	IWL_PHY_DB_CALIB_CH,
-	IWL_PHY_DB_CALIB_CHG_PAPD,
-	IWL_PHY_DB_CALIB_CHG_TXP,
-	IWL_PHY_DB_MAX
-};
-
-/* for parsing of tx power channel group data that comes from the firmware=
*/
-struct iwl_phy_db_chg_txp {
-	__le32 space;
-	__le16 max_channel_idx;
-} __packed;
-
-struct iwl_phy_db *iwl_phy_db_init(struct device *dev);
-
-void iwl_phy_db_free(struct iwl_phy_db *phy_db);
-
-int iwl_phy_db_set_section(struct iwl_phy_db *phy_db,
-			   enum iwl_phy_db_section_type type, u8 *data,
-			   u16 size, gfp_t alloc_ctx);
-
-int iwl_phy_db_get_section_data(struct iwl_phy_db *phy_db,
-				enum iwl_phy_db_section_type type, u8 **data,
-				u16 *size, u16 ch_id);
-
-#endif /* __IWL_PHYDB_H__ */
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h b/drivers/ne=
t/wireless/iwlwifi/iwl-trans-pcie-int.h
index 6213c05..e959207 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h
@@ -347,7 +347,7 @@ void iwl_trans_tx_queue_set_status(struct iwl_trans *tr=
ans,
 void iwl_trans_pcie_tx_agg_setup(struct iwl_trans *trans, int queue, int f=
ifo,
 				 int sta_id, int tid, int frame_limit, u16 ssn);
 void iwlagn_txq_free_tfd(struct iwl_trans *trans, struct iwl_tx_queue *txq,
-	int index, enum dma_data_direction dma_dir);
+			 enum dma_data_direction dma_dir);
 int iwl_tx_queue_reclaim(struct iwl_trans *trans, int txq_id, int index,
 			 struct sk_buff_head *skbs);
 int iwl_queue_space(const struct iwl_queue *q);
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c b/drivers/net=
/wireless/iwlwifi/iwl-trans-pcie-tx.c
index 21a8a67..a875023 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c
@@ -204,33 +204,39 @@ static void iwlagn_unmap_tfd(struct iwl_trans *trans,=
 struct iwl_cmd_meta *meta,
 	for (i =3D 1; i < num_tbs; i++)
 		dma_unmap_single(trans->dev, iwl_tfd_tb_get_addr(tfd, i),
 				iwl_tfd_tb_get_len(tfd, i), dma_dir);
+
+	tfd->num_tbs =3D 0;
 }
=20
 /**
  * iwlagn_txq_free_tfd - Free all chunks referenced by TFD [txq->q.read_pt=
r]
  * @trans - transport private data
  * @txq - tx queue
- * @index - the index of the TFD to be freed
- *@dma_dir - the direction of the DMA mapping
+ * @dma_dir - the direction of the DMA mapping
  *
  * Does NOT advance any TFD circular buffer read/write indexes
  * Does NOT free the TFD itself (which is within circular buffer)
  */
 void iwlagn_txq_free_tfd(struct iwl_trans *trans, struct iwl_tx_queue *txq,
-	int index, enum dma_data_direction dma_dir)
+			 enum dma_data_direction dma_dir)
 {
 	struct iwl_tfd *tfd_tmp =3D txq->tfds;
=20
+	/* rd_ptr is bounded by n_bd and idx is bounded by n_window */
+	int rd_ptr =3D txq->q.read_ptr;
+	int idx =3D get_cmd_index(&txq->q, rd_ptr);
+
 	lockdep_assert_held(&txq->lock);
=20
-	iwlagn_unmap_tfd(trans, &txq->entries[index].meta,
-			 &tfd_tmp[index], dma_dir);
+	/* We have only q->n_window txq->entries, but we use q->n_bd tfds */
+	iwlagn_unmap_tfd(trans, &txq->entries[idx].meta,
+			 &tfd_tmp[rd_ptr], dma_dir);
=20
 	/* free SKB */
 	if (txq->entries) {
 		struct sk_buff *skb;
=20
-		skb =3D txq->entries[index].skb;
+		skb =3D txq->entries[idx].skb;
=20
 		/* Can be called from irqs-disabled context
 		 * If skb is not NULL, it means that the whole queue is being
@@ -238,7 +244,7 @@ void iwlagn_txq_free_tfd(struct iwl_trans *trans, struc=
t iwl_tx_queue *txq,
 		 */
 		if (skb) {
 			iwl_op_mode_free_skb(trans->op_mode, skb);
-			txq->entries[index].skb =3D NULL;
+			txq->entries[idx].skb =3D NULL;
 		}
 	}
 }
@@ -973,7 +979,7 @@ int iwl_tx_queue_reclaim(struct iwl_trans *trans, int t=
xq_id, int index,
=20
 		iwlagn_txq_inval_byte_cnt_tbl(trans, txq);
=20
-		iwlagn_txq_free_tfd(trans, txq, txq->q.read_ptr, DMA_TO_DEVICE);
+		iwlagn_txq_free_tfd(trans, txq, DMA_TO_DEVICE);
 		freed++;
 	}
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wi=
reless/iwlwifi/iwl-trans-pcie.c
index 2e57161..ec6fb39 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -435,9 +435,7 @@ static void iwl_tx_queue_unmap(struct iwl_trans *trans,=
 int txq_id)
=20
 	spin_lock_bh(&txq->lock);
 	while (q->write_ptr !=3D q->read_ptr) {
-		/* The read_ptr needs to bound by q->n_window */
-		iwlagn_txq_free_tfd(trans, txq, get_cmd_index(q, q->read_ptr),
-				    dma_dir);
+		iwlagn_txq_free_tfd(trans, txq, dma_dir);
 		q->read_ptr =3D iwl_queue_inc_wrap(q->read_ptr, q->n_bd);
 	}
 	spin_unlock_bh(&txq->lock);
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/t=
i/wl1251/sdio.c
index 1b851f6..e2750a1 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -260,6 +260,7 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 	}
=20
 	if (wl->irq) {
+		irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 		ret =3D request_irq(wl->irq, wl1251_line_irq, 0, "wl1251", wl);
 		if (ret < 0) {
 			wl1251_error("request_irq() failed: %d", ret);
@@ -267,7 +268,6 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 		}
=20
 		irq_set_irq_type(wl->irq, IRQ_TYPE_EDGE_RISING);
-		disable_irq(wl->irq);
=20
 		wl1251_sdio_ops.enable_irq =3D wl1251_enable_line_irq;
 		wl1251_sdio_ops.disable_irq =3D wl1251_disable_line_irq;
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti=
/wl1251/spi.c
index 6248c35..87f6305 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -281,6 +281,7 @@ static int __devinit wl1251_spi_probe(struct spi_device=
 *spi)
=20
 	wl->use_eeprom =3D pdata->use_eeprom;
=20
+	irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 	ret =3D request_irq(wl->irq, wl1251_irq, 0, DRIVER_NAME, wl);
 	if (ret < 0) {
 		wl1251_error("request_irq() failed: %d", ret);
@@ -289,8 +290,6 @@ static int __devinit wl1251_spi_probe(struct spi_device=
 *spi)
=20
 	irq_set_irq_type(wl->irq, IRQ_TYPE_EDGE_RISING);
=20
-	disable_irq(wl->irq);
-
 	ret =3D wl1251_init_ieee80211(wl);
 	if (ret)
 		goto out_irq;
diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti=
/wlcore/acx.c
index 509aa88..f3d6fa5 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -1715,6 +1715,7 @@ out:
=20
 }
=20
+#ifdef CONFIG_PM
 /* Set the global behaviour of RX filters - On/Off + default action */
 int wl1271_acx_default_rx_filter_enable(struct wl1271 *wl, bool enable,
 					enum rx_filter_action action)
@@ -1794,3 +1795,4 @@ out:
 	kfree(acx);
 	return ret;
 }
+#endif /* CONFIG_PM */
diff --git a/drivers/net/wireless/ti/wlcore/acx.h b/drivers/net/wireless/ti=
/wlcore/acx.h
index 8106b2e..e6a7486 100644
--- a/drivers/net/wireless/ti/wlcore/acx.h
+++ b/drivers/net/wireless/ti/wlcore/acx.h
@@ -1330,9 +1330,11 @@ int wl1271_acx_set_inconnection_sta(struct wl1271 *w=
l, u8 *addr);
 int wl1271_acx_fm_coex(struct wl1271 *wl);
 int wl12xx_acx_set_rate_mgmt_params(struct wl1271 *wl);
 int wl12xx_acx_config_hangover(struct wl1271 *wl);
+
+#ifdef CONFIG_PM
 int wl1271_acx_default_rx_filter_enable(struct wl1271 *wl, bool enable,
 					enum rx_filter_action action);
 int wl1271_acx_set_rx_filter(struct wl1271 *wl, u8 index, bool enable,
 			     struct wl12xx_rx_filter *filter);
-
+#endif /* CONFIG_PM */
 #endif /* __WL1271_ACX_H__ */
diff --git a/drivers/net/wireless/ti/wlcore/rx.c b/drivers/net/wireless/ti/=
wlcore/rx.c
index 1f1d948..d6a3c6b 100644
--- a/drivers/net/wireless/ti/wlcore/rx.c
+++ b/drivers/net/wireless/ti/wlcore/rx.c
@@ -279,6 +279,7 @@ void wl12xx_rx(struct wl1271 *wl, struct wl_fw_status *=
status)
 	wl12xx_rearm_rx_streaming(wl, active_hlids);
 }
=20
+#ifdef CONFIG_PM
 int wl1271_rx_filter_enable(struct wl1271 *wl,
 			    int index, bool enable,
 			    struct wl12xx_rx_filter *filter)
@@ -314,3 +315,4 @@ void wl1271_rx_filter_clear_all(struct wl1271 *wl)
 		wl1271_rx_filter_enable(wl, i, 0, NULL);
 	}
 }
+#endif /* CONFIG_PM */
diff --git a/drivers/nfc/pn544_hci.c b/drivers/nfc/pn544_hci.c
index 46f4a9f..281f18c 100644
--- a/drivers/nfc/pn544_hci.c
+++ b/drivers/nfc/pn544_hci.c
@@ -232,7 +232,7 @@ static int pn544_hci_i2c_write(struct i2c_client *clien=
t, u8 *buf, int len)
=20
 static int check_crc(u8 *buf, int buflen)
 {
-	u8 len;
+	int len;
 	u16 crc;
=20
 	len =3D buf[0] + 1;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index b3b3c26..04c3063 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1522,6 +1522,8 @@ static void ieee80211_mgd_probe_ap_send(struct ieee80=
211_sub_if_data *sdata)
 	 * anymore. The timeout will be reset if the frame is ACKed by
 	 * the AP.
 	 */
+	ifmgd->probe_send_count++;
+
 	if (sdata->local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS) {
 		ifmgd->nullfunc_failed =3D false;
 		ieee80211_send_nullfunc(sdata->local, sdata, 0);
@@ -1538,7 +1540,6 @@ static void ieee80211_mgd_probe_ap_send(struct ieee80=
211_sub_if_data *sdata)
 					 0, (u32) -1, true, false);
 	}
=20
-	ifmgd->probe_send_count++;
 	ifmgd->probe_timeout =3D jiffies + msecs_to_jiffies(probe_wait_ms);
 	run_again(ifmgd, ifmgd->probe_timeout);
 	if (sdata->local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS)
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 5f827a6..847215b 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -153,7 +153,7 @@ static __le16 ieee80211_duration(struct ieee80211_tx_da=
ta *tx,
=20
 	/* Don't calculate ACKs for QoS Frames with NoAck Policy set */
 	if (ieee80211_is_data_qos(hdr->frame_control) &&
-	    *(ieee80211_get_qos_ctl(hdr)) | IEEE80211_QOS_CTL_ACK_POLICY_NOACK)
+	    *(ieee80211_get_qos_ctl(hdr)) & IEEE80211_QOS_CTL_ACK_POLICY_NOACK)
 		dur =3D 0;
 	else
 		/* Time needed to transmit ACK
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 22f2216..a44c680 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1371,6 +1371,12 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		}
 	}
=20
+	/* add back keys */
+	list_for_each_entry(sdata, &local->interfaces, list)
+		if (ieee80211_sdata_running(sdata))
+			ieee80211_enable_keys(sdata);
+
+ wake_up:
 	/*
 	 * Clear the WLAN_STA_BLOCK_BA flag so new aggregation
 	 * sessions can be established after a resume.
@@ -1392,12 +1398,6 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		mutex_unlock(&local->sta_mtx);
 	}
=20
-	/* add back keys */
-	list_for_each_entry(sdata, &local->interfaces, list)
-		if (ieee80211_sdata_running(sdata))
-			ieee80211_enable_keys(sdata);
-
- wake_up:
 	ieee80211_wake_queues_by_reason(hw,
 			IEEE80211_QUEUE_STOP_REASON_SUSPEND);
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJPxlUbAAoJEJctW/TcYTgGAIkP/RZmHlub/5jyaYzUBPvuasQW
QBOve2F14vrpmaRTWLTg+gQZp0tJrGMRtCoMQIMal2DQJcUK98MuQ9gcXvSKBQEt
si5eSeTcwSdxFCW48x67sdWEBu6VBm8ZBM3N3TTIPlE6Y3IwObK29aMDFWblIuAo
awyw0KUXHrdY98Xnbxp5XgxbsFPqwdJRrbf0ER5rk04Gt5M2iZMRYg89lY8EYy/y
kExfnKIkS7rywWvgxK7lmC+jKNV0wh0200aPiqW+3gV6Y29p+2Lazpi97OsDniPF
u4VJUoN4rBOluhf0vgta8VM1NjfxOXPPILKdxv57Hmmzoask6E4okx7/fveQ4U1U
GN5Ag5QoFKGTFb+KhEqd4tHVj7AvFArO5N85l3BwsPdpBEMTDMMshYSBtNf2avpt
z0lG9QFkQCspzOxYyLcxYk5GlHuo8iLjyluEgpApMmAzddrb9KCIuU1eRWM5le5l
2jAKqikyFif4Y8ppyJmJDN+9v1jFTm5+0a8jxkWRt4JeELcU7qpcjZVQfq/5rBuh
T5JeEIy6YqOgPfHAQ/jIL13VfGtVSISNA9CQ3fLQP9o3/jT4n3cMKx6IbzAZXvKj
wt++ukElVR++I2K7w2m0SxkloOK/psBOFPFvFdVtWQZkA12ym40AGCmxs4VuO0w7
W6D+ZgKp+ig5c0R5M3w8
=oPeD
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
