From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-06-12
Date: Wed, 12 Jun 2013 11:09:26 -0400
Message-ID: <20130612150926.GC11589@tuxdriver.com>
References: <20130606190929.GB18827@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130606190929.GB18827@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

For now I have dropped the mac80211 tree from this request.
We are developing a little backlog of fixes and I would like to
avoid introducing any more uncertainty to this pull request for the
3.10 stream.  All the other bits are the same as what was in the
2013-06-06 request, including the ath9k fixes intended to address
the problems observed by Linus w/ his Pixel, and a CVE fix for a
potential security issue in the b43 driver.

Regarding the wl12xx bits, Luca says:

"Here are three patches that I'd like to get into 3.10.  Two of them, by
me, are related to the firmware version checks in our driver.  Without
them, the firmwares fail to load.  The other one, by Eliad, fixes a typo
bug in our 5GHz scanning code."

And as for the Bluetooth bits, Gustavo says:

"The following patches are important bug fixes for 3.10, plus the
support for a new device. We do have three fixes from Johan. The first
one is a fix to avoid LE-only devices to rely on the (inexistent)
extended features data. The second patch fixes length checks on
incoming L2CAP signalling PDUs so we can discard PDU whose size
doesn't match the one reported in the header.  The last one fixes
the handling of power on failures, we now report proper errors to
mgmt when hci_dev_open()."

Along with that...

Larry Finger corrects an rtlwifi problem that caused some devices to
refuse to connect to non-WPA2 networks if the device had previously
assocated with a WPA2 network.  He also adds a one-line fix to prevent
false reports from kmemleak.

Mark A. Greer fixes an out of bounds array access in mwifiex.

Felix Fietkau reverts an earlier ath9k initval patch that reduced rx
sensitivity in a number of ath9k devices with no corresponding benefit.

Kees Cook fixes a potential uid-0 to ring-0 escalation in b43
(CVE-2013-2852).

Sujith Manoharan turns-off powersave mode by default for ath9k, and
also defaults ath9k to use the minstrel_ht rate control algorithm.
Both of these are believed to contribute to greater stability/usability
of ath9k in real-world situations.

Yijing Wang fixes an iwlegacy build error for il_pm_ops if CONFIG_PM
is set but CONFIG_PM_SLEEP is not set.

Please let me know if there are any problems!

Thanks,

John

---

The following changes since commit b79462a8b9f9a452edc20c64a70a89ba3b0a6a88:

  team: fix checks in team_get_first_port_txable_rcu() (2013-06-12 00:56:27=
 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 42d887a68013b0a04f7b8ebfa4999a8d5df6775c:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-06-12 10:57:04 -0400)

----------------------------------------------------------------

Bing Zhao (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8897

Eliad Peller (1):
      wl12xx/wl18xx: scan all 5ghz channels

Felix Fietkau (1):
      Revert "ath9k_hw: Update rx gain initval to improve rx sensitivity"

Johan Hedberg (3):
      Bluetooth: Fix checks for LE support on LE-only controllers
      Bluetooth: Fix missing length checks for L2CAP signalling PDUs
      Bluetooth: Fix mgmt handling of power on failures

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Kees Cook (1):
      b43: stop format string leaking into error msgs

Larry Finger (2):
      rtlwifi: rtl8192cu: Fix problem in connecting to WEP or WPA(1) networ=
ks
      rtlwifi: Fix a false leak indication for PCI devices

Luciano Coelho (2):
      wl12xx: fix minimum required firmware version for wl127x multirole
      wl12xx: increase minimum singlerole firmware version required

Mark A. Greer (1):
      mwifiex: debugfs: Fix out of bounds array access

Sujith Manoharan (2):
      ath9k: Disable PowerSave by default
      ath9k: Use minstrel rate control by default

Yijing Wang (1):
      net: wireless: iwlegacy: fix build error for il_pm_ops

 drivers/bluetooth/Kconfig                          |   4 +-
 drivers/bluetooth/btmrvl_sdio.c                    |  28 +++++
 drivers/net/wireless/ath/ath9k/Kconfig             |  10 +-
 drivers/net/wireless/ath/ath9k/Makefile            |   2 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  10 +-
 drivers/net/wireless/ath/ath9k/init.c              |   7 +-
 drivers/net/wireless/ath/ath9k/rc.h                |   2 +-
 drivers/net/wireless/b43/main.c                    |   2 +-
 drivers/net/wireless/iwlegacy/common.h             |   6 +-
 drivers/net/wireless/mwifiex/debugfs.c             |  22 +++-
 drivers/net/wireless/rtlwifi/pci.c                 |   1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        | 134 +++++++++++++++--=
----
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |   4 -
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |  18 ++-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h        |   3 +
 drivers/net/wireless/rtlwifi/usb.c                 |  13 ++
 drivers/net/wireless/rtlwifi/wifi.h                |   4 +
 drivers/net/wireless/ti/wl12xx/scan.c              |   2 +-
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |   6 +-
 drivers/net/wireless/ti/wl18xx/scan.c              |   2 +-
 include/net/bluetooth/hci_core.h                   |   1 +
 include/net/bluetooth/mgmt.h                       |   1 +
 net/bluetooth/hci_core.c                           |   6 +-
 net/bluetooth/l2cap_core.c                         |  70 ++++++++---
 net/bluetooth/mgmt.c                               |  23 +++-
 net/bluetooth/smp.c                                |   4 +-
 27 files changed, 294 insertions(+), 95 deletions(-)

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index fdfd61a..11a6104 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -201,7 +201,7 @@ config BT_MRVL
 	  The core driver to support Marvell Bluetooth devices.
=20
 	  This driver is required if you want to support
-	  Marvell Bluetooth devices, such as 8688/8787/8797.
+	  Marvell Bluetooth devices, such as 8688/8787/8797/8897.
=20
 	  Say Y here to compile Marvell Bluetooth driver
 	  into the kernel or say M to compile it as module.
@@ -214,7 +214,7 @@ config BT_MRVL_SDIO
 	  The driver for Marvell Bluetooth chipsets with SDIO interface.
=20
 	  This driver is required if you want to use Marvell Bluetooth
-	  devices with SDIO interface. Currently SD8688/SD8787/SD8797
+	  devices with SDIO interface. Currently SD8688/SD8787/SD8797/SD8897
 	  chipsets are supported.
=20
 	  Say Y here to compile support for Marvell BT-over-SDIO driver
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdi=
o.c
index c63488c..13693b7 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -82,6 +82,23 @@ static const struct btmrvl_sdio_card_reg btmrvl_reg_87xx=
 =3D {
 	.io_port_2 =3D 0x7a,
 };
=20
+static const struct btmrvl_sdio_card_reg btmrvl_reg_88xx =3D {
+	.cfg =3D 0x00,
+	.host_int_mask =3D 0x02,
+	.host_intstatus =3D 0x03,
+	.card_status =3D 0x50,
+	.sq_read_base_addr_a0 =3D 0x60,
+	.sq_read_base_addr_a1 =3D 0x61,
+	.card_revision =3D 0xbc,
+	.card_fw_status0 =3D 0xc0,
+	.card_fw_status1 =3D 0xc1,
+	.card_rx_len =3D 0xc2,
+	.card_rx_unit =3D 0xc3,
+	.io_port_0 =3D 0xd8,
+	.io_port_1 =3D 0xd9,
+	.io_port_2 =3D 0xda,
+};
+
 static const struct btmrvl_sdio_device btmrvl_sdio_sd8688 =3D {
 	.helper		=3D "mrvl/sd8688_helper.bin",
 	.firmware	=3D "mrvl/sd8688.bin",
@@ -103,6 +120,13 @@ static const struct btmrvl_sdio_device btmrvl_sdio_sd8=
797 =3D {
 	.sd_blksz_fw_dl	=3D 256,
 };
=20
+static const struct btmrvl_sdio_device btmrvl_sdio_sd8897 =3D {
+	.helper		=3D NULL,
+	.firmware	=3D "mrvl/sd8897_uapsta.bin",
+	.reg		=3D &btmrvl_reg_88xx,
+	.sd_blksz_fw_dl	=3D 256,
+};
+
 static const struct sdio_device_id btmrvl_sdio_ids[] =3D {
 	/* Marvell SD8688 Bluetooth device */
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x9105),
@@ -116,6 +140,9 @@ static const struct sdio_device_id btmrvl_sdio_ids[] =
=3D {
 	/* Marvell SD8797 Bluetooth device */
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x912A),
 			.driver_data =3D (unsigned long) &btmrvl_sdio_sd8797 },
+	/* Marvell SD8897 Bluetooth device */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x912E),
+			.driver_data =3D (unsigned long) &btmrvl_sdio_sd8897 },
=20
 	{ }	/* Terminating entry */
 };
@@ -1194,3 +1221,4 @@ MODULE_FIRMWARE("mrvl/sd8688_helper.bin");
 MODULE_FIRMWARE("mrvl/sd8688.bin");
 MODULE_FIRMWARE("mrvl/sd8787_uapsta.bin");
 MODULE_FIRMWARE("mrvl/sd8797_uapsta.bin");
+MODULE_FIRMWARE("mrvl/sd8897_uapsta.bin");
diff --git a/drivers/net/wireless/ath/ath9k/Kconfig b/drivers/net/wireless/=
ath/ath9k/Kconfig
index f3dc124..3c2cbc9 100644
--- a/drivers/net/wireless/ath/ath9k/Kconfig
+++ b/drivers/net/wireless/ath/ath9k/Kconfig
@@ -92,13 +92,17 @@ config ATH9K_MAC_DEBUG
 	  This option enables collection of statistics for Rx/Tx status
 	  data and some other MAC related statistics
=20
-config ATH9K_RATE_CONTROL
+config ATH9K_LEGACY_RATE_CONTROL
 	bool "Atheros ath9k rate control"
 	depends on ATH9K
-	default y
+	default n
 	---help---
 	  Say Y, if you want to use the ath9k specific rate control
-	  module instead of minstrel_ht.
+	  module instead of minstrel_ht. Be warned that there are various
+	  issues with the ath9k RC and minstrel is a more robust algorithm.
+	  Note that even if this option is selected, "ath9k_rate_control"
+	  has to be passed to mac80211 using the module parameter,
+	  ieee80211_default_rc_algo.
=20
 config ATH9K_HTC
        tristate "Atheros HTC based wireless cards support"
diff --git a/drivers/net/wireless/ath/ath9k/Makefile b/drivers/net/wireless=
/ath/ath9k/Makefile
index 2ad8f94..75ee9e7 100644
--- a/drivers/net/wireless/ath/ath9k/Makefile
+++ b/drivers/net/wireless/ath/ath9k/Makefile
@@ -8,7 +8,7 @@ ath9k-y +=3D	beacon.o \
 		antenna.o
=20
 ath9k-$(CONFIG_ATH9K_BTCOEX_SUPPORT) +=3D mci.o
-ath9k-$(CONFIG_ATH9K_RATE_CONTROL) +=3D rc.o
+ath9k-$(CONFIG_ATH9K_LEGACY_RATE_CONTROL) +=3D rc.o
 ath9k-$(CONFIG_ATH9K_PCI) +=3D pci.o
 ath9k-$(CONFIG_ATH9K_AHB) +=3D ahb.o
 ath9k-$(CONFIG_ATH9K_DEBUGFS) +=3D debug.o
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h b/drivers=
/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
index db5ffad..7546b9a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
@@ -958,11 +958,11 @@ static const u32 ar9300Common_rx_gain_table_2p2[][2] =
=3D {
 	{0x0000a074, 0x00000000},
 	{0x0000a078, 0x00000000},
 	{0x0000a07c, 0x00000000},
-	{0x0000a080, 0x1a1a1a1a},
-	{0x0000a084, 0x1a1a1a1a},
-	{0x0000a088, 0x1a1a1a1a},
-	{0x0000a08c, 0x1a1a1a1a},
-	{0x0000a090, 0x171a1a1a},
+	{0x0000a080, 0x22222229},
+	{0x0000a084, 0x1d1d1d1d},
+	{0x0000a088, 0x1d1d1d1d},
+	{0x0000a08c, 0x1d1d1d1d},
+	{0x0000a090, 0x171d1d1d},
 	{0x0000a094, 0x11111717},
 	{0x0000a098, 0x00030311},
 	{0x0000a09c, 0x00000000},
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index aba4151..2ba4945 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -787,8 +787,7 @@ void ath9k_set_hw_capab(struct ath_softc *sc, struct ie=
ee80211_hw *hw)
 	hw->wiphy->iface_combinations =3D if_comb;
 	hw->wiphy->n_iface_combinations =3D ARRAY_SIZE(if_comb);
=20
-	if (AR_SREV_5416(sc->sc_ah))
-		hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+	hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
=20
 	hw->wiphy->flags |=3D WIPHY_FLAG_IBSS_RSN;
 	hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_TDLS;
@@ -830,10 +829,6 @@ void ath9k_set_hw_capab(struct ath_softc *sc, struct i=
eee80211_hw *hw)
 	sc->ant_rx =3D hw->wiphy->available_antennas_rx;
 	sc->ant_tx =3D hw->wiphy->available_antennas_tx;
=20
-#ifdef CONFIG_ATH9K_RATE_CONTROL
-	hw->rate_control_algorithm =3D "ath9k_rate_control";
-#endif
-
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_2GHZ)
 		hw->wiphy->bands[IEEE80211_BAND_2GHZ] =3D
 			&sc->sbands[IEEE80211_BAND_2GHZ];
diff --git a/drivers/net/wireless/ath/ath9k/rc.h b/drivers/net/wireless/ath=
/ath9k/rc.h
index 267dbfc..b9a8738 100644
--- a/drivers/net/wireless/ath/ath9k/rc.h
+++ b/drivers/net/wireless/ath/ath9k/rc.h
@@ -231,7 +231,7 @@ static inline void ath_debug_stat_retries(struct ath_ra=
te_priv *rc, int rix,
 }
 #endif
=20
-#ifdef CONFIG_ATH9K_RATE_CONTROL
+#ifdef CONFIG_ATH9K_LEGACY_RATE_CONTROL
 int ath_rate_control_register(void);
 void ath_rate_control_unregister(void);
 #else
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index 6dd07e2..a95b77a 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2458,7 +2458,7 @@ static void b43_request_firmware(struct work_struct *=
work)
 	for (i =3D 0; i < B43_NR_FWTYPES; i++) {
 		errmsg =3D ctx->errors[i];
 		if (strlen(errmsg))
-			b43err(dev->wl, errmsg);
+			b43err(dev->wl, "%s", errmsg);
 	}
 	b43_print_fw_helptext(dev->wl, 1);
 	goto out;
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/=
iwlegacy/common.h
index f8246f2..4caaf52 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -1832,16 +1832,16 @@ u32 il_usecs_to_beacons(struct il_priv *il, u32 use=
c, u32 beacon_interval);
 __le32 il_add_beacon_time(struct il_priv *il, u32 base, u32 addon,
 			  u32 beacon_interval);
=20
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 extern const struct dev_pm_ops il_pm_ops;
=20
 #define IL_LEGACY_PM_OPS	(&il_pm_ops)
=20
-#else /* !CONFIG_PM */
+#else /* !CONFIG_PM_SLEEP */
=20
 #define IL_LEGACY_PM_OPS	NULL
=20
-#endif /* !CONFIG_PM */
+#endif /* !CONFIG_PM_SLEEP */
=20
 /*****************************************************
 *  Error Handling Debugging
diff --git a/drivers/net/wireless/mwifiex/debugfs.c b/drivers/net/wireless/=
mwifiex/debugfs.c
index 753b568..a5f9875 100644
--- a/drivers/net/wireless/mwifiex/debugfs.c
+++ b/drivers/net/wireless/mwifiex/debugfs.c
@@ -26,10 +26,17 @@
 static struct dentry *mwifiex_dfs_dir;
=20
 static char *bss_modes[] =3D {
-	"Unknown",
-	"Ad-hoc",
-	"Managed",
-	"Auto"
+	"UNSPECIFIED",
+	"ADHOC",
+	"STATION",
+	"AP",
+	"AP_VLAN",
+	"WDS",
+	"MONITOR",
+	"MESH_POINT",
+	"P2P_CLIENT",
+	"P2P_GO",
+	"P2P_DEVICE",
 };
=20
 /* size/addr for mwifiex_debug_info */
@@ -200,7 +207,12 @@ mwifiex_info_read(struct file *file, char __user *ubuf,
 	p +=3D sprintf(p, "driver_version =3D %s", fmt);
 	p +=3D sprintf(p, "\nverext =3D %s", priv->version_str);
 	p +=3D sprintf(p, "\ninterface_name=3D\"%s\"\n", netdev->name);
-	p +=3D sprintf(p, "bss_mode=3D\"%s\"\n", bss_modes[info.bss_mode]);
+
+	if (info.bss_mode >=3D ARRAY_SIZE(bss_modes))
+		p +=3D sprintf(p, "bss_mode=3D\"%d\"\n", info.bss_mode);
+	else
+		p +=3D sprintf(p, "bss_mode=3D\"%s\"\n", bss_modes[info.bss_mode]);
+
 	p +=3D sprintf(p, "media_state=3D\"%s\"\n",
 		     (!priv->media_connected ? "Disconnected" : "Connected"));
 	p +=3D sprintf(p, "mac_address=3D\"%pM\"\n", netdev->dev_addr);
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 999ffc1..c97e9d3 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -764,6 +764,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *=
hw)
 				 "can't alloc skb for rx\n");
 			goto done;
 		}
+		kmemleak_not_leak(new_skb);
=20
 		pci_unmap_single(rtlpci->pdev,
 				 *((dma_addr_t *) skb->cb),
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.c
index 3d0498e..189ba12 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1973,26 +1973,35 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8=
 variable, u8 *val)
 	}
 }
=20
-void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
-				   struct ieee80211_sta *sta,
-				   u8 rssi_level)
+static void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
+					  struct ieee80211_sta *sta)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_phy *rtlphy =3D &(rtlpriv->phy);
 	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
-	u32 ratr_value =3D (u32) mac->basic_rates;
-	u8 *mcsrate =3D mac->mcs;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u32 ratr_value;
 	u8 ratr_index =3D 0;
 	u8 nmode =3D mac->ht_enable;
-	u8 mimo_ps =3D 1;
-	u16 shortgi_rate =3D 0;
-	u32 tmp_ratr_value =3D 0;
+	u8 mimo_ps =3D IEEE80211_SMPS_OFF;
+	u16 shortgi_rate;
+	u32 tmp_ratr_value;
 	u8 curtxbw_40mhz =3D mac->bw_40;
-	u8 curshortgi_40mhz =3D mac->sgi_40;
-	u8 curshortgi_20mhz =3D mac->sgi_20;
+	u8 curshortgi_40mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+			       1 : 0;
+	u8 curshortgi_20mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+			       1 : 0;
 	enum wireless_mode wirelessmode =3D mac->mode;
=20
-	ratr_value |=3D ((*(u16 *) (mcsrate))) << 12;
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_5G)
+		ratr_value =3D sta->supp_rates[1] << 4;
+	else
+		ratr_value =3D sta->supp_rates[0];
+	if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		ratr_value =3D 0xfff;
+
+	ratr_value |=3D (sta->ht_cap.mcs.rx_mask[1] << 20 |
+			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
 	case WIRELESS_MODE_B:
 		if (ratr_value & 0x0000000c)
@@ -2006,7 +2015,7 @@ void rtl92cu_update_hal_rate_table(struct ieee80211_h=
w *hw,
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		nmode =3D 1;
-		if (mimo_ps =3D=3D 0) {
+		if (mimo_ps =3D=3D IEEE80211_SMPS_STATIC) {
 			ratr_value &=3D 0x0007F005;
 		} else {
 			u32 ratr_mask;
@@ -2016,8 +2025,7 @@ void rtl92cu_update_hal_rate_table(struct ieee80211_h=
w *hw,
 				ratr_mask =3D 0x000ff005;
 			else
 				ratr_mask =3D 0x0f0ff005;
-			if (curtxbw_40mhz)
-				ratr_mask |=3D 0x00000010;
+
 			ratr_value &=3D ratr_mask;
 		}
 		break;
@@ -2026,41 +2034,74 @@ void rtl92cu_update_hal_rate_table(struct ieee80211=
_hw *hw,
 			ratr_value &=3D 0x000ff0ff;
 		else
 			ratr_value &=3D 0x0f0ff0ff;
+
 		break;
 	}
+
 	ratr_value &=3D 0x0FFFFFFF;
-	if (nmode && ((curtxbw_40mhz && curshortgi_40mhz) ||
-	    (!curtxbw_40mhz && curshortgi_20mhz))) {
+
+	if (nmode && ((curtxbw_40mhz &&
+			 curshortgi_40mhz) || (!curtxbw_40mhz &&
+					       curshortgi_20mhz))) {
+
 		ratr_value |=3D 0x10000000;
 		tmp_ratr_value =3D (ratr_value >> 12);
+
 		for (shortgi_rate =3D 15; shortgi_rate > 0; shortgi_rate--) {
 			if ((1 << shortgi_rate) & tmp_ratr_value)
 				break;
 		}
+
 		shortgi_rate =3D (shortgi_rate << 12) | (shortgi_rate << 8) |
-			       (shortgi_rate << 4) | (shortgi_rate);
+		    (shortgi_rate << 4) | (shortgi_rate);
 	}
+
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
+		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
=20
-void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
+static void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw,
+					 struct ieee80211_sta *sta,
+					 u8 rssi_level)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_phy *rtlphy =3D &(rtlpriv->phy);
 	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
-	u32 ratr_bitmap =3D (u32) mac->basic_rates;
-	u8 *p_mcsrate =3D mac->mcs;
-	u8 ratr_index =3D 0;
-	u8 curtxbw_40mhz =3D mac->bw_40;
-	u8 curshortgi_40mhz =3D mac->sgi_40;
-	u8 curshortgi_20mhz =3D mac->sgi_20;
-	enum wireless_mode wirelessmode =3D mac->mode;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_sta_info *sta_entry =3D NULL;
+	u32 ratr_bitmap;
+	u8 ratr_index;
+	u8 curtxbw_40mhz =3D (sta->bandwidth >=3D IEEE80211_STA_RX_BW_40) ? 1 : 0;
+	u8 curshortgi_40mhz =3D curtxbw_40mhz &&
+			      (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+				1 : 0;
+	u8 curshortgi_20mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+				1 : 0;
+	enum wireless_mode wirelessmode =3D 0;
 	bool shortgi =3D false;
 	u8 rate_mask[5];
 	u8 macid =3D 0;
-	u8 mimops =3D 1;
-
-	ratr_bitmap |=3D (p_mcsrate[1] << 20) | (p_mcsrate[0] << 12);
+	u8 mimo_ps =3D IEEE80211_SMPS_OFF;
+
+	sta_entry =3D (struct rtl_sta_info *) sta->drv_priv;
+	wirelessmode =3D sta_entry->wireless_mode;
+	if (mac->opmode =3D=3D NL80211_IFTYPE_STATION ||
+	    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT)
+		curtxbw_40mhz =3D mac->bw_40;
+	else if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+		mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		macid =3D sta->aid + 1;
+
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_5G)
+		ratr_bitmap =3D sta->supp_rates[1] << 4;
+	else
+		ratr_bitmap =3D sta->supp_rates[0];
+	if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		ratr_bitmap =3D 0xfff;
+	ratr_bitmap |=3D (sta->ht_cap.mcs.rx_mask[1] << 20 |
+			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
 	case WIRELESS_MODE_B:
 		ratr_index =3D RATR_INX_WIRELESS_B;
@@ -2071,6 +2112,7 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw=
 *hw, u8 rssi_level)
 		break;
 	case WIRELESS_MODE_G:
 		ratr_index =3D RATR_INX_WIRELESS_GB;
+
 		if (rssi_level =3D=3D 1)
 			ratr_bitmap &=3D 0x00000f00;
 		else if (rssi_level =3D=3D 2)
@@ -2085,7 +2127,8 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw=
 *hw, u8 rssi_level)
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		ratr_index =3D RATR_INX_WIRELESS_NGB;
-		if (mimops =3D=3D 0) {
+
+		if (mimo_ps =3D=3D IEEE80211_SMPS_STATIC) {
 			if (rssi_level =3D=3D 1)
 				ratr_bitmap &=3D 0x00070000;
 			else if (rssi_level =3D=3D 2)
@@ -2128,8 +2171,10 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_h=
w *hw, u8 rssi_level)
 				}
 			}
 		}
+
 		if ((curtxbw_40mhz && curshortgi_40mhz) ||
 		    (!curtxbw_40mhz && curshortgi_20mhz)) {
+
 			if (macid =3D=3D 0)
 				shortgi =3D true;
 			else if (macid =3D=3D 1)
@@ -2138,21 +2183,42 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_=
hw *hw, u8 rssi_level)
 		break;
 	default:
 		ratr_index =3D RATR_INX_WIRELESS_NGB;
+
 		if (rtlphy->rf_type =3D=3D RF_1T2R)
 			ratr_bitmap &=3D 0x000ff0ff;
 		else
 			ratr_bitmap &=3D 0x0f0ff0ff;
 		break;
 	}
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "ratr_bitmap :%x\n",
-		 ratr_bitmap);
-	*(u32 *)&rate_mask =3D ((ratr_bitmap & 0x0fffffff) |
-				      ratr_index << 28);
+	sta_entry->ratr_index =3D ratr_index;
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
+		 "ratr_bitmap :%x\n", ratr_bitmap);
+	*(u32 *)&rate_mask =3D (ratr_bitmap & 0x0fffffff) |
+				     (ratr_index << 28);
 	rate_mask[4] =3D macid | (shortgi ? 0x20 : 0x00) | 0x80;
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "Rate_index:%x, ratr_val:%x, %5phC\n",
 		 ratr_index, ratr_bitmap, rate_mask);
-	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
+	memcpy(rtlpriv->rate_mask, rate_mask, 5);
+	/* rtl92c_fill_h2c_cmd() does USB I/O and will result in a
+	 * "scheduled while atomic" if called directly */
+	schedule_work(&rtlpriv->works.fill_h2c_cmd);
+
+	if (macid !=3D 0)
+		sta_entry->ratr_index =3D ratr_index;
+}
+
+void rtl92cu_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta,
+				 u8 rssi_level)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (rtlpriv->dm.useramask)
+		rtl92cu_update_hal_rate_mask(hw, sta, rssi_level);
+	else
+		rtl92cu_update_hal_rate_table(hw, sta);
 }
=20
 void rtl92cu_update_channel_access_setting(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.h
index f41a3aa..8e3ec1e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
@@ -98,10 +98,6 @@ void rtl92cu_update_interrupt_mask(struct ieee80211_hw *=
hw,
 				   u32 add_msr, u32 rm_msr);
 void rtl92cu_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
 void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
-void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
-				   struct ieee80211_sta *sta,
-				   u8 rssi_level);
-void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level);
=20
 void rtl92cu_update_channel_access_setting(struct ieee80211_hw *hw);
 bool rtl92cu_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 * vali=
d);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/mac.c
index 85b6bdb..da4f587 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -289,14 +289,30 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_=
index,
 				macaddr =3D cam_const_broad;
 				entry_id =3D key_index;
 			} else {
+				if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+				    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT) {
+					entry_id =3D rtl_cam_get_free_entry(hw,
+								 p_macaddr);
+					if (entry_id >=3D  TOTAL_CAM_ENTRY) {
+						RT_TRACE(rtlpriv, COMP_SEC,
+							 DBG_EMERG,
+							 "Can not find free hw security cam entry\n");
+						return;
+					}
+				} else {
+					entry_id =3D CAM_PAIRWISE_KEY_POSITION;
+				}
+
 				key_index =3D PAIRWISE_KEYIDX;
-				entry_id =3D CAM_PAIRWISE_KEY_POSITION;
 				is_pairwise =3D true;
 			}
 		}
 		if (rtlpriv->sec.key_len[key_index] =3D=3D 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "delete one entry\n");
+			if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+			    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT)
+				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index 938b1e6..826f085 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -106,8 +106,7 @@ static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.update_interrupt_mask =3D rtl92cu_update_interrupt_mask,
 	.get_hw_reg =3D rtl92cu_get_hw_reg,
 	.set_hw_reg =3D rtl92cu_set_hw_reg,
-	.update_rate_tbl =3D rtl92cu_update_hal_rate_table,
-	.update_rate_mask =3D rtl92cu_update_hal_rate_mask,
+	.update_rate_tbl =3D rtl92cu_update_hal_rate_tbl,
 	.fill_tx_desc =3D rtl92cu_tx_fill_desc,
 	.fill_fake_txdesc =3D rtl92cu_fill_fake_txdesc,
 	.fill_tx_cmddesc =3D rtl92cu_tx_fill_cmddesc,
@@ -137,6 +136,7 @@ static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.phy_lc_calibrate =3D _rtl92cu_phy_lc_calibrate,
 	.phy_set_bw_mode_callback =3D rtl92cu_phy_set_bw_mode_callback,
 	.dm_dynamic_txpower =3D rtl92cu_dm_dynamic_txpower,
+	.fill_h2c_cmd =3D rtl92c_fill_h2c_cmd,
 };
=20
 static struct rtl_mod_params rtl92cu_mod_params =3D {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.h b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.h
index a1310ab..262e1e4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.h
@@ -49,5 +49,8 @@ bool rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *=
hw,
 u32 rtl92cu_phy_query_rf_reg(struct ieee80211_hw *hw,
 			    enum radio_path rfpath, u32 regaddr, u32 bitmask);
 void rtl92cu_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+void rtl92cu_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta,
+				 u8 rssi_level);
=20
 #endif
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 76732b0..a3532e0 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -824,6 +824,7 @@ static void rtl_usb_stop(struct ieee80211_hw *hw)
=20
 	/* should after adapter start and interrupt enable. */
 	set_hal_stop(rtlhal);
+	cancel_work_sync(&rtlpriv->works.fill_h2c_cmd);
 	/* Enable software */
 	SET_USB_STOP(rtlusb);
 	rtl_usb_deinit(hw);
@@ -1026,6 +1027,16 @@ static bool rtl_usb_tx_chk_waitq_insert(struct ieee8=
0211_hw *hw,
 	return false;
 }
=20
+static void rtl_fill_h2c_cmd_work_callback(struct work_struct *work)
+{
+	struct rtl_works *rtlworks =3D
+	    container_of(work, struct rtl_works, fill_h2c_cmd);
+	struct ieee80211_hw *hw =3D rtlworks->hw;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtlpriv->cfg->ops->fill_h2c_cmd(hw, H2C_RA_MASK, 5, rtlpriv->rate_mask);
+}
+
 static struct rtl_intf_ops rtl_usb_ops =3D {
 	.adapter_start =3D rtl_usb_start,
 	.adapter_stop =3D rtl_usb_stop,
@@ -1057,6 +1068,8 @@ int rtl_usb_probe(struct usb_interface *intf,
=20
 	/* this spin lock must be initialized early */
 	spin_lock_init(&rtlpriv->locks.usb_lock);
+	INIT_WORK(&rtlpriv->works.fill_h2c_cmd,
+		  rtl_fill_h2c_cmd_work_callback);
=20
 	rtlpriv->usb_data_index =3D 0;
 	init_completion(&rtlpriv->firmware_loading_complete);
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtl=
wifi/wifi.h
index 44328ba..cc03e7c 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1736,6 +1736,8 @@ struct rtl_hal_ops {
 	void (*bt_wifi_media_status_notify) (struct ieee80211_hw *hw,
 					     bool mstate);
 	void (*bt_coex_off_before_lps) (struct ieee80211_hw *hw);
+	void (*fill_h2c_cmd) (struct ieee80211_hw *hw, u8 element_id,
+			      u32 cmd_len, u8 *p_cmdbuffer);
 };
=20
 struct rtl_intf_ops {
@@ -1869,6 +1871,7 @@ struct rtl_works {
 	struct delayed_work fwevt_wq;
=20
 	struct work_struct lps_change_work;
+	struct work_struct fill_h2c_cmd;
 };
=20
 struct rtl_debug {
@@ -2048,6 +2051,7 @@ struct rtl_priv {
 		};
 	};
 	bool enter_ps;	/* true when entering PS */
+	u8 rate_mask[5];
=20
 	/*This must be the last item so
 	   that it points to the data allocated
diff --git a/drivers/net/wireless/ti/wl12xx/scan.c b/drivers/net/wireless/t=
i/wl12xx/scan.c
index affdb3e..4a0bbb1 100644
--- a/drivers/net/wireless/ti/wl12xx/scan.c
+++ b/drivers/net/wireless/ti/wl12xx/scan.c
@@ -310,7 +310,7 @@ static void wl12xx_adjust_channels(struct wl1271_cmd_sc=
hed_scan_config *cmd,
 	memcpy(cmd->channels_2, cmd_channels->channels_2,
 	       sizeof(cmd->channels_2));
 	memcpy(cmd->channels_5, cmd_channels->channels_5,
-	       sizeof(cmd->channels_2));
+	       sizeof(cmd->channels_5));
 	/* channels_4 are not supported, so no need to copy them */
 }
=20
diff --git a/drivers/net/wireless/ti/wl12xx/wl12xx.h b/drivers/net/wireless=
/ti/wl12xx/wl12xx.h
index 222d035..9e5484a 100644
--- a/drivers/net/wireless/ti/wl12xx/wl12xx.h
+++ b/drivers/net/wireless/ti/wl12xx/wl12xx.h
@@ -36,12 +36,12 @@
 #define WL127X_IFTYPE_SR_VER	3
 #define WL127X_MAJOR_SR_VER	10
 #define WL127X_SUBTYPE_SR_VER	WLCORE_FW_VER_IGNORE
-#define WL127X_MINOR_SR_VER	115
+#define WL127X_MINOR_SR_VER	133
 /* minimum multi-role FW version for wl127x */
 #define WL127X_IFTYPE_MR_VER	5
 #define WL127X_MAJOR_MR_VER	7
 #define WL127X_SUBTYPE_MR_VER	WLCORE_FW_VER_IGNORE
-#define WL127X_MINOR_MR_VER	115
+#define WL127X_MINOR_MR_VER	42
=20
 /* FW chip version for wl128x */
 #define WL128X_CHIP_VER		7
@@ -49,7 +49,7 @@
 #define WL128X_IFTYPE_SR_VER	3
 #define WL128X_MAJOR_SR_VER	10
 #define WL128X_SUBTYPE_SR_VER	WLCORE_FW_VER_IGNORE
-#define WL128X_MINOR_SR_VER	115
+#define WL128X_MINOR_SR_VER	133
 /* minimum multi-role FW version for wl128x */
 #define WL128X_IFTYPE_MR_VER	5
 #define WL128X_MAJOR_MR_VER	7
diff --git a/drivers/net/wireless/ti/wl18xx/scan.c b/drivers/net/wireless/t=
i/wl18xx/scan.c
index 09d9445..2b642f8 100644
--- a/drivers/net/wireless/ti/wl18xx/scan.c
+++ b/drivers/net/wireless/ti/wl18xx/scan.c
@@ -34,7 +34,7 @@ static void wl18xx_adjust_channels(struct wl18xx_cmd_scan=
_params *cmd,
 	memcpy(cmd->channels_2, cmd_channels->channels_2,
 	       sizeof(cmd->channels_2));
 	memcpy(cmd->channels_5, cmd_channels->channels_5,
-	       sizeof(cmd->channels_2));
+	       sizeof(cmd->channels_5));
 	/* channels_4 are not supported, so no need to copy them */
 }
=20
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index 35a57cd..7cb6d36 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -1117,6 +1117,7 @@ void hci_sock_dev_event(struct hci_dev *hdev, int eve=
nt);
 int mgmt_control(struct sock *sk, struct msghdr *msg, size_t len);
 int mgmt_index_added(struct hci_dev *hdev);
 int mgmt_index_removed(struct hci_dev *hdev);
+int mgmt_set_powered_failed(struct hci_dev *hdev, int err);
 int mgmt_powered(struct hci_dev *hdev, u8 powered);
 int mgmt_discoverable(struct hci_dev *hdev, u8 discoverable);
 int mgmt_connectable(struct hci_dev *hdev, u8 connectable);
diff --git a/include/net/bluetooth/mgmt.h b/include/net/bluetooth/mgmt.h
index 22980a7..9944c3e 100644
--- a/include/net/bluetooth/mgmt.h
+++ b/include/net/bluetooth/mgmt.h
@@ -42,6 +42,7 @@
 #define MGMT_STATUS_NOT_POWERED		0x0f
 #define MGMT_STATUS_CANCELLED		0x10
 #define MGMT_STATUS_INVALID_INDEX	0x11
+#define MGMT_STATUS_RFKILLED		0x12
=20
 struct mgmt_hdr {
 	__le16	opcode;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 33843c5..d817c93 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1555,11 +1555,15 @@ static const struct rfkill_ops hci_rfkill_ops =3D {
 static void hci_power_on(struct work_struct *work)
 {
 	struct hci_dev *hdev =3D container_of(work, struct hci_dev, power_on);
+	int err;
=20
 	BT_DBG("%s", hdev->name);
=20
-	if (hci_dev_open(hdev->id) < 0)
+	err =3D hci_dev_open(hdev->id);
+	if (err < 0) {
+		mgmt_set_powered_failed(hdev, err);
 		return;
+	}
=20
 	if (test_bit(HCI_AUTO_OFF, &hdev->dev_flags))
 		queue_delayed_work(hdev->req_workqueue, &hdev->power_off,
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index a76d1ac..24bee07 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -3677,10 +3677,14 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *c=
han, void *rsp, int len)
 }
=20
 static inline int l2cap_command_rej(struct l2cap_conn *conn,
-				    struct l2cap_cmd_hdr *cmd, u8 *data)
+				    struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				    u8 *data)
 {
 	struct l2cap_cmd_rej_unk *rej =3D (struct l2cap_cmd_rej_unk *) data;
=20
+	if (cmd_len < sizeof(*rej))
+		return -EPROTO;
+
 	if (rej->reason !=3D L2CAP_REJ_NOT_UNDERSTOOD)
 		return 0;
=20
@@ -3829,11 +3833,14 @@ sendresp:
 }
=20
 static int l2cap_connect_req(struct l2cap_conn *conn,
-			     struct l2cap_cmd_hdr *cmd, u8 *data)
+			     struct l2cap_cmd_hdr *cmd, u16 cmd_len, u8 *data)
 {
 	struct hci_dev *hdev =3D conn->hcon->hdev;
 	struct hci_conn *hcon =3D conn->hcon;
=20
+	if (cmd_len < sizeof(struct l2cap_conn_req))
+		return -EPROTO;
+
 	hci_dev_lock(hdev);
 	if (test_bit(HCI_MGMT, &hdev->dev_flags) &&
 	    !test_and_set_bit(HCI_CONN_MGMT_CONNECTED, &hcon->flags))
@@ -3847,7 +3854,8 @@ static int l2cap_connect_req(struct l2cap_conn *conn,
 }
=20
 static int l2cap_connect_create_rsp(struct l2cap_conn *conn,
-				    struct l2cap_cmd_hdr *cmd, u8 *data)
+				    struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				    u8 *data)
 {
 	struct l2cap_conn_rsp *rsp =3D (struct l2cap_conn_rsp *) data;
 	u16 scid, dcid, result, status;
@@ -3855,6 +3863,9 @@ static int l2cap_connect_create_rsp(struct l2cap_conn=
 *conn,
 	u8 req[128];
 	int err;
=20
+	if (cmd_len < sizeof(*rsp))
+		return -EPROTO;
+
 	scid   =3D __le16_to_cpu(rsp->scid);
 	dcid   =3D __le16_to_cpu(rsp->dcid);
 	result =3D __le16_to_cpu(rsp->result);
@@ -3952,6 +3963,9 @@ static inline int l2cap_config_req(struct l2cap_conn =
*conn,
 	struct l2cap_chan *chan;
 	int len, err =3D 0;
=20
+	if (cmd_len < sizeof(*req))
+		return -EPROTO;
+
 	dcid  =3D __le16_to_cpu(req->dcid);
 	flags =3D __le16_to_cpu(req->flags);
=20
@@ -3975,7 +3989,7 @@ static inline int l2cap_config_req(struct l2cap_conn =
*conn,
=20
 	/* Reject if config buffer is too small. */
 	len =3D cmd_len - sizeof(*req);
-	if (len < 0 || chan->conf_len + len > sizeof(chan->conf_req)) {
+	if (chan->conf_len + len > sizeof(chan->conf_req)) {
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_CONF_RSP,
 			       l2cap_build_conf_rsp(chan, rsp,
 			       L2CAP_CONF_REJECT, flags), rsp);
@@ -4053,14 +4067,18 @@ unlock:
 }
=20
 static inline int l2cap_config_rsp(struct l2cap_conn *conn,
-				   struct l2cap_cmd_hdr *cmd, u8 *data)
+				   struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				   u8 *data)
 {
 	struct l2cap_conf_rsp *rsp =3D (struct l2cap_conf_rsp *)data;
 	u16 scid, flags, result;
 	struct l2cap_chan *chan;
-	int len =3D le16_to_cpu(cmd->len) - sizeof(*rsp);
+	int len =3D cmd_len - sizeof(*rsp);
 	int err =3D 0;
=20
+	if (cmd_len < sizeof(*rsp))
+		return -EPROTO;
+
 	scid   =3D __le16_to_cpu(rsp->scid);
 	flags  =3D __le16_to_cpu(rsp->flags);
 	result =3D __le16_to_cpu(rsp->result);
@@ -4161,7 +4179,8 @@ done:
 }
=20
 static inline int l2cap_disconnect_req(struct l2cap_conn *conn,
-				       struct l2cap_cmd_hdr *cmd, u8 *data)
+				       struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				       u8 *data)
 {
 	struct l2cap_disconn_req *req =3D (struct l2cap_disconn_req *) data;
 	struct l2cap_disconn_rsp rsp;
@@ -4169,6 +4188,9 @@ static inline int l2cap_disconnect_req(struct l2cap_c=
onn *conn,
 	struct l2cap_chan *chan;
 	struct sock *sk;
=20
+	if (cmd_len !=3D sizeof(*req))
+		return -EPROTO;
+
 	scid =3D __le16_to_cpu(req->scid);
 	dcid =3D __le16_to_cpu(req->dcid);
=20
@@ -4208,12 +4230,16 @@ static inline int l2cap_disconnect_req(struct l2cap=
_conn *conn,
 }
=20
 static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn,
-				       struct l2cap_cmd_hdr *cmd, u8 *data)
+				       struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				       u8 *data)
 {
 	struct l2cap_disconn_rsp *rsp =3D (struct l2cap_disconn_rsp *) data;
 	u16 dcid, scid;
 	struct l2cap_chan *chan;
=20
+	if (cmd_len !=3D sizeof(*rsp))
+		return -EPROTO;
+
 	scid =3D __le16_to_cpu(rsp->scid);
 	dcid =3D __le16_to_cpu(rsp->dcid);
=20
@@ -4243,11 +4269,15 @@ static inline int l2cap_disconnect_rsp(struct l2cap=
_conn *conn,
 }
=20
 static inline int l2cap_information_req(struct l2cap_conn *conn,
-					struct l2cap_cmd_hdr *cmd, u8 *data)
+					struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+					u8 *data)
 {
 	struct l2cap_info_req *req =3D (struct l2cap_info_req *) data;
 	u16 type;
=20
+	if (cmd_len !=3D sizeof(*req))
+		return -EPROTO;
+
 	type =3D __le16_to_cpu(req->type);
=20
 	BT_DBG("type 0x%4.4x", type);
@@ -4294,11 +4324,15 @@ static inline int l2cap_information_req(struct l2ca=
p_conn *conn,
 }
=20
 static inline int l2cap_information_rsp(struct l2cap_conn *conn,
-					struct l2cap_cmd_hdr *cmd, u8 *data)
+					struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+					u8 *data)
 {
 	struct l2cap_info_rsp *rsp =3D (struct l2cap_info_rsp *) data;
 	u16 type, result;
=20
+	if (cmd_len !=3D sizeof(*rsp))
+		return -EPROTO;
+
 	type   =3D __le16_to_cpu(rsp->type);
 	result =3D __le16_to_cpu(rsp->result);
=20
@@ -5164,16 +5198,16 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_=
conn *conn,
=20
 	switch (cmd->code) {
 	case L2CAP_COMMAND_REJ:
-		l2cap_command_rej(conn, cmd, data);
+		l2cap_command_rej(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CONN_REQ:
-		err =3D l2cap_connect_req(conn, cmd, data);
+		err =3D l2cap_connect_req(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CONN_RSP:
 	case L2CAP_CREATE_CHAN_RSP:
-		err =3D l2cap_connect_create_rsp(conn, cmd, data);
+		err =3D l2cap_connect_create_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CONF_REQ:
@@ -5181,15 +5215,15 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_=
conn *conn,
 		break;
=20
 	case L2CAP_CONF_RSP:
-		err =3D l2cap_config_rsp(conn, cmd, data);
+		err =3D l2cap_config_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_DISCONN_REQ:
-		err =3D l2cap_disconnect_req(conn, cmd, data);
+		err =3D l2cap_disconnect_req(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_DISCONN_RSP:
-		err =3D l2cap_disconnect_rsp(conn, cmd, data);
+		err =3D l2cap_disconnect_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_ECHO_REQ:
@@ -5200,11 +5234,11 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_=
conn *conn,
 		break;
=20
 	case L2CAP_INFO_REQ:
-		err =3D l2cap_information_req(conn, cmd, data);
+		err =3D l2cap_information_req(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_INFO_RSP:
-		err =3D l2cap_information_rsp(conn, cmd, data);
+		err =3D l2cap_information_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CREATE_CHAN_REQ:
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 35fef22..f8ecbc7 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -2700,7 +2700,7 @@ static int start_discovery(struct sock *sk, struct hc=
i_dev *hdev,
 		break;
=20
 	case DISCOV_TYPE_LE:
-		if (!lmp_host_le_capable(hdev)) {
+		if (!test_bit(HCI_LE_ENABLED, &hdev->dev_flags)) {
 			err =3D cmd_status(sk, hdev->id, MGMT_OP_START_DISCOVERY,
 					 MGMT_STATUS_NOT_SUPPORTED);
 			mgmt_pending_remove(cmd);
@@ -3418,6 +3418,27 @@ new_settings:
 	return err;
 }
=20
+int mgmt_set_powered_failed(struct hci_dev *hdev, int err)
+{
+	struct pending_cmd *cmd;
+	u8 status;
+
+	cmd =3D mgmt_pending_find(MGMT_OP_SET_POWERED, hdev);
+	if (!cmd)
+		return -ENOENT;
+
+	if (err =3D=3D -ERFKILL)
+		status =3D MGMT_STATUS_RFKILLED;
+	else
+		status =3D MGMT_STATUS_FAILED;
+
+	err =3D cmd_status(cmd->sk, hdev->id, MGMT_OP_SET_POWERED, status);
+
+	mgmt_pending_remove(cmd);
+
+	return err;
+}
+
 int mgmt_discoverable(struct hci_dev *hdev, u8 discoverable)
 {
 	struct cmd_lookup match =3D { NULL, hdev };
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index b2296d3..b5562ab 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -770,7 +770,7 @@ int smp_conn_security(struct hci_conn *hcon, __u8 sec_l=
evel)
=20
 	BT_DBG("conn %p hcon %p level 0x%2.2x", conn, hcon, sec_level);
=20
-	if (!lmp_host_le_capable(hcon->hdev))
+	if (!test_bit(HCI_LE_ENABLED, &hcon->hdev->dev_flags))
 		return 1;
=20
 	if (sec_level =3D=3D BT_SECURITY_LOW)
@@ -851,7 +851,7 @@ int smp_sig_channel(struct l2cap_conn *conn, struct sk_=
buff *skb)
 	__u8 reason;
 	int err =3D 0;
=20
-	if (!lmp_host_le_capable(conn->hcon->hdev)) {
+	if (!test_bit(HCI_LE_ENABLED, &conn->hcon->hdev->dev_flags)) {
 		err =3D -ENOTSUPP;
 		reason =3D SMP_PAIRING_NOTSUPP;
 		goto done;

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRuI8mAAoJEJctW/TcYTgGKxYP+gIaK4r4wQAalK/uwr5mZkV+
fx4Kpg/rkOlhczPeFfK/WRLuaHJAA1HlWG//uPcnY0pJHc64Dvkc/ixMS3idefgn
hU2uawQfrfa2vgCqTeYGNmKo8Y0Q7+k9uFjG7iLrd7bRUD+2vYg5PrgEer0i+061
YprNSAl9JUNH2tpG1XE0Ljf2gYHwG8TyjG22iLoUNpT3NDoHFuLM5HqzIG9zOp0p
kVKUgpU6PYLq372DKG4nxOyo5NFy2RNcmnqO0hjxJjd2ISN4jxj9l3pceop6JpVl
bU8dRdzcp1jXAcNFWPYYIC8UVbgr76oRRTpPo8E3XzSKyhCvJNoxQPnHM5ZR2Ipc
OffXztVgzxymsXXOyo22mOr3WcrCFrL+f+c7FNmVmpqq6yN+dmPDg8NEMGzGfAUs
1GPJla3FN1wx+Be5Jfg3iiLx02KvIq8aOGY/u7C5kb/f6cz+0kcKEPBAH01c/nFN
rAWpv15GqmThFnGEJX7xGgz15ugsIn7vns6p0gR9lIS4misDAfR9BpBkDRUbeV5Y
g7cVml2o6GWIi2x4W2obNcsYhLaF15HoQSkbJ4E+J2hQznAjV8RMFuuEDB6RSXnm
xIfAKAwdU+TRKh/FRcpFeWmipicOOtNiUPpKUZju1IoHAPCuaF/gifdxMVk5xvHn
kxrPA8T9lc05O94hqNAS
=2M0Z
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--
