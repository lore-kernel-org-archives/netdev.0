From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-11-14
Date: Thu, 14 Nov 2013 14:11:20 -0500
Message-ID: <20131114191119.GB17693@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.13 stream!

Amitkumar Karwar offers a quartet of mwifiex fixes, including an
endian fix and three fixes for invalid memory access.

Avinash Patil trims the packet length value for packets received from
an SDIO interface.

Colin Ian King fixes a NULL pointer dereference in the rtlwifi
efuse code.

Dan Carpenter cleans-up an mwifiex integer underflow, a potential
libertas oops, a memory corrupion bug in wcn36xx, and a locking issue
also in wcn36xx.

Dan Williams helps prism54 devices to avoid being misclassified as
Ethernet devices.

Felipe Pena fixes a couple of typo errors, one in rt2x00 and the
other in rtlwifi.

Janusz Dziedzic corrects a pair of DFS-related problems in ath9k.

Larry Finger patches three rtlwifi drivers to correctly report signal
strength even for an unassociated AP.

Mark Cave-Ayland rewrites some endian-illiterate packet type extraction
code in rtlwifi.

Stanislaw Gruszka addresses an rt2x00 regression related to setting
HT station WCID and AMPDU density parameters.

Sujith Manoharan corrects the initvals settings for AR9485.

Ujjal Roy patches an obscure bit of code in mwifiex that was using
the wrong definition of eth_hdr when briding patches in AP mode.

Wei Yongjun fixes a couple of bugs: one is a return code handling
bug in libertas; and, the other is a locking issue in wcn36xx.

Please let me know if there are problems!

John

---

The following changes since commit 6115c11fe1a5a636ac99fc823b00df4ff3c0674e:

  net: mv643xx_eth: potential NULL dereference in probe() (2013-11-14 03:11=
:36 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to d8ec5a5d4c63e308beb20b09a05bb8ea3093bedb:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-11-14 13:42:17 -0500)

----------------------------------------------------------------

Amitkumar Karwar (4):
      mwifiex: replace u16 with __le16 in struct mwifiex_types_power_group
      mwifiex: fix invalid memory access in mwifiex_get_power_level()
      mwifiex: fix invalid memory access in mwifiex_ret_tx_rate_cfg()
      mwifiex: fix invalid memory access in mwifiex_update_autoindex_ies()

Avinash Patil (1):
      mwifiex: correct packet length for packets from SDIO interface

Colin Ian King (1):
      rtlwifi: fix null dereference on efuse_word on kmalloc fail returns N=
ULL

Dan Carpenter (4):
      mwifiex: potential integer underflow in mwifiex_ret_wmm_get_status()
      libertas: potential oops in debugfs
      wcn36xx: harmless memory corruption bug in debugfs
      wcn36xx: missing unlocks on error paths

Dan Williams (1):
      prism54: set netdev type to "wlan"

Felipe Pena (2):
      wireless: rt2800lib: Fix typo on checking
      rtlwifi: rtl8192se: Fix wrong assignment

Janusz Dziedzic (2):
      ath9k: DFS radar use correct width enum
      ath9k: dfs_debug fix possible NULL dereference

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (3):
      rtlwifi: rtl8192se: Fix incorrect signal strength for unassociated AP
      rtlwifi: rtl8192cu: Fix incorrect signal strength for unassociated AP
      rtlwifi: rtl8192de: Fix incorrect signal strength for unassociated AP

Mark Cave-Ayland (1):
      rtlwifi: Fix endian error in extracting packet type

Stanislaw Gruszka (1):
      rt2x00: fix HT TX descriptor settings regression

Sujith Manoharan (1):
      ath9k: Use correct PCIE initvals for AR9485

Ujjal Roy (1):
      mwifiex: fix wrong eth_hdr usage for bridged packets in AP mode

Wei Yongjun (2):
      libertas: fix error return code in if_cs_probe()
      wcn36xx: Add missing unlock before return

 drivers/net/wireless/ath/ath9k/ar9003_hw.c       | 22 +++---
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h | 42 ++++-------
 drivers/net/wireless/ath/ath9k/ath9k.h           | 19 ++---
 drivers/net/wireless/ath/ath9k/dfs_debug.c       | 13 +++-
 drivers/net/wireless/ath/ath9k/hw.h              |  1 +
 drivers/net/wireless/ath/ath9k/init.c            |  9 ++-
 drivers/net/wireless/ath/ath9k/pci.c             | 87 ++++++++++++++++++++=
++
 drivers/net/wireless/ath/wcn36xx/debug.c         |  2 +-
 drivers/net/wireless/ath/wcn36xx/smd.c           |  9 ++-
 drivers/net/wireless/libertas/debugfs.c          |  6 +-
 drivers/net/wireless/libertas/if_cs.c            |  1 +
 drivers/net/wireless/mwifiex/fw.h                |  4 +-
 drivers/net/wireless/mwifiex/ie.c                | 11 ++-
 drivers/net/wireless/mwifiex/sdio.c              |  3 +
 drivers/net/wireless/mwifiex/sta_cmd.c           |  4 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c       | 46 ++++++------
 drivers/net/wireless/mwifiex/sta_ioctl.c         |  5 +-
 drivers/net/wireless/mwifiex/uap_txrx.c          | 29 +++++++-
 drivers/net/wireless/mwifiex/wmm.c               |  3 +
 drivers/net/wireless/prism54/islpci_dev.c        |  7 +-
 drivers/net/wireless/rt2x00/rt2800lib.c          |  2 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h          |  2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |  4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c        |  4 +-
 drivers/net/wireless/rtlwifi/base.c              | 93 +++++++++++---------=
----
 drivers/net/wireless/rtlwifi/efuse.c             |  5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c     |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c     |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c      |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c     |  2 +-
 drivers/net/wireless/rtlwifi/wifi.h              |  6 +-
 31 files changed, 284 insertions(+), 163 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_hw.c b/drivers/net/wirel=
ess/ath/ath9k/ar9003_hw.c
index b07f164d65cf..20e49095db2a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_hw.c
@@ -187,17 +187,17 @@ static void ar9003_hw_init_mode_regs(struct ath_hw *a=
h)
 		INIT_INI_ARRAY(&ah->iniCckfirJapan2484,
 			       ar9485_1_1_baseband_core_txfir_coeff_japan_2484);
=20
-		/* Load PCIE SERDES settings from INI */
-
-		/* Awake Setting */
-
-		INIT_INI_ARRAY(&ah->iniPcieSerdes,
-				ar9485_1_1_pcie_phy_clkreq_disable_L1);
-
-		/* Sleep Setting */
-
-		INIT_INI_ARRAY(&ah->iniPcieSerdesLowPower,
-				ar9485_1_1_pcie_phy_clkreq_disable_L1);
+		if (ah->config.no_pll_pwrsave) {
+			INIT_INI_ARRAY(&ah->iniPcieSerdes,
+				       ar9485_1_1_pcie_phy_clkreq_disable_L1);
+			INIT_INI_ARRAY(&ah->iniPcieSerdesLowPower,
+				       ar9485_1_1_pcie_phy_clkreq_disable_L1);
+		} else {
+			INIT_INI_ARRAY(&ah->iniPcieSerdes,
+				       ar9485_1_1_pll_on_cdr_on_clkreq_disable_L1);
+			INIT_INI_ARRAY(&ah->iniPcieSerdesLowPower,
+				       ar9485_1_1_pll_on_cdr_on_clkreq_disable_L1);
+		}
 	} else if (AR_SREV_9462_21(ah)) {
 		INIT_INI_ARRAY(&ah->iniMac[ATH_INI_CORE],
 			       ar9462_2p1_mac_core);
diff --git a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h b/drivers/net=
/wireless/ath/ath9k/ar9485_initvals.h
index 6f899c692647..7c1845221e1c 100644
--- a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
@@ -32,13 +32,6 @@ static const u32 ar9485_1_1_mac_postamble[][5] =3D {
 	{0x00008318, 0x00003e80, 0x00007d00, 0x00006880, 0x00003440},
 };
=20
-static const u32 ar9485_1_1_pcie_phy_pll_on_clkreq_disable_L1[][2] =3D {
-	/* Addr      allmodes  */
-	{0x00018c00, 0x18012e5e},
-	{0x00018c04, 0x000801d8},
-	{0x00018c08, 0x0000080c},
-};
-
 static const u32 ar9485Common_wo_xlna_rx_gain_1_1[][2] =3D {
 	/* Addr      allmodes  */
 	{0x00009e00, 0x037216a0},
@@ -1101,20 +1094,6 @@ static const u32 ar9485_common_rx_gain_1_1[][2] =3D {
 	{0x0000a1fc, 0x00000296},
 };
=20
-static const u32 ar9485_1_1_pcie_phy_pll_on_clkreq_enable_L1[][2] =3D {
-	/* Addr      allmodes  */
-	{0x00018c00, 0x18052e5e},
-	{0x00018c04, 0x000801d8},
-	{0x00018c08, 0x0000080c},
-};
-
-static const u32 ar9485_1_1_pcie_phy_clkreq_enable_L1[][2] =3D {
-	/* Addr      allmodes  */
-	{0x00018c00, 0x18053e5e},
-	{0x00018c04, 0x000801d8},
-	{0x00018c08, 0x0000080c},
-};
-
 static const u32 ar9485_1_1_soc_preamble[][2] =3D {
 	/* Addr      allmodes  */
 	{0x00004014, 0xba280400},
@@ -1173,13 +1152,6 @@ static const u32 ar9485_1_1_baseband_postamble[][5] =
=3D {
 	{0x0000be18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 };
=20
-static const u32 ar9485_1_1_pcie_phy_clkreq_disable_L1[][2] =3D {
-	/* Addr      allmodes  */
-	{0x00018c00, 0x18013e5e},
-	{0x00018c04, 0x000801d8},
-	{0x00018c08, 0x0000080c},
-};
-
 static const u32 ar9485_1_1_radio_postamble[][2] =3D {
 	/* Addr      allmodes  */
 	{0x0001609c, 0x0b283f31},
@@ -1358,4 +1330,18 @@ static const u32 ar9485_1_1_baseband_core_txfir_coef=
f_japan_2484[][2] =3D {
 	{0x0000a3a0, 0xca9228ee},
 };
=20
+static const u32 ar9485_1_1_pcie_phy_clkreq_disable_L1[][2] =3D {
+	/* Addr      allmodes  */
+	{0x00018c00, 0x18013e5e},
+	{0x00018c04, 0x000801d8},
+	{0x00018c08, 0x0000080c},
+};
+
+static const u32 ar9485_1_1_pll_on_cdr_on_clkreq_disable_L1[][2] =3D {
+	/* Addr      allmodes  */
+	{0x00018c00, 0x1801265e},
+	{0x00018c04, 0x000801d8},
+	{0x00018c08, 0x0000080c},
+};
+
 #endif /* INITVALS_9485_H */
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index e7a38d844a6a..60a5da53668f 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -632,15 +632,16 @@ void ath_ant_comb_scan(struct ath_softc *sc, struct a=
th_rx_status *rs);
 /* Main driver core */
 /********************/
=20
-#define ATH9K_PCI_CUS198      0x0001
-#define ATH9K_PCI_CUS230      0x0002
-#define ATH9K_PCI_CUS217      0x0004
-#define ATH9K_PCI_CUS252      0x0008
-#define ATH9K_PCI_WOW         0x0010
-#define ATH9K_PCI_BT_ANT_DIV  0x0020
-#define ATH9K_PCI_D3_L1_WAR   0x0040
-#define ATH9K_PCI_AR9565_1ANT 0x0080
-#define ATH9K_PCI_AR9565_2ANT 0x0100
+#define ATH9K_PCI_CUS198          0x0001
+#define ATH9K_PCI_CUS230          0x0002
+#define ATH9K_PCI_CUS217          0x0004
+#define ATH9K_PCI_CUS252          0x0008
+#define ATH9K_PCI_WOW             0x0010
+#define ATH9K_PCI_BT_ANT_DIV      0x0020
+#define ATH9K_PCI_D3_L1_WAR       0x0040
+#define ATH9K_PCI_AR9565_1ANT     0x0080
+#define ATH9K_PCI_AR9565_2ANT     0x0100
+#define ATH9K_PCI_NO_PLL_PWRSAVE  0x0200
=20
 /*
  * Default cache line size, in bytes.
diff --git a/drivers/net/wireless/ath/ath9k/dfs_debug.c b/drivers/net/wirel=
ess/ath/ath9k/dfs_debug.c
index 90b8342d1ed4..8824610c21fb 100644
--- a/drivers/net/wireless/ath/ath9k/dfs_debug.c
+++ b/drivers/net/wireless/ath/ath9k/dfs_debug.c
@@ -44,14 +44,20 @@ static ssize_t read_file_dfs(struct file *file, char __=
user *user_buf,
 	if (buf =3D=3D NULL)
 		return -ENOMEM;
=20
-	if (sc->dfs_detector)
-		dfs_pool_stats =3D sc->dfs_detector->get_stats(sc->dfs_detector);
-
 	len +=3D scnprintf(buf + len, size - len, "DFS support for "
 			 "macVersion =3D 0x%x, macRev =3D 0x%x: %s\n",
 			 hw_ver->macVersion, hw_ver->macRev,
 			 (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_DFS) ?
 					"enabled" : "disabled");
+
+	if (!sc->dfs_detector) {
+		len +=3D scnprintf(buf + len, size - len,
+				 "DFS detector not enabled\n");
+		goto exit;
+	}
+
+	dfs_pool_stats =3D sc->dfs_detector->get_stats(sc->dfs_detector);
+
 	len +=3D scnprintf(buf + len, size - len, "Pulse detector statistics:\n");
 	ATH9K_DFS_STAT("pulse events reported   ", pulses_total);
 	ATH9K_DFS_STAT("invalid pulse events    ", pulses_no_dfs);
@@ -76,6 +82,7 @@ static ssize_t read_file_dfs(struct file *file, char __us=
er *user_buf,
 	ATH9K_DFS_POOL_STAT("Seqs. alloc error       ", pseq_alloc_error);
 	ATH9K_DFS_POOL_STAT("Seqs. in use            ", pseq_used);
=20
+exit:
 	if (len > size)
 		len =3D size;
=20
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index 9ea24f1cba73..a2c9a5dbac6b 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -316,6 +316,7 @@ struct ath9k_ops_config {
 	u32 ant_ctrl_comm2g_switch_enable;
 	bool xatten_margin_cfg;
 	bool alt_mingainidx;
+	bool no_pll_pwrsave;
 };
=20
 enum ath9k_int {
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index d8643ebabd30..710192ed27ed 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -609,6 +609,11 @@ static void ath9k_init_platform(struct ath_softc *sc)
 		ah->config.pcie_waen =3D 0x0040473b;
 		ath_info(common, "Enable WAR for ASPM D3/L1\n");
 	}
+
+	if (sc->driver_data & ATH9K_PCI_NO_PLL_PWRSAVE) {
+		ah->config.no_pll_pwrsave =3D true;
+		ath_info(common, "Disable PLL PowerSave\n");
+	}
 }
=20
 static void ath9k_eeprom_request_cb(const struct firmware *eeprom_blob,
@@ -863,8 +868,8 @@ static const struct ieee80211_iface_combination if_comb=
[] =3D {
 		.max_interfaces =3D 1,
 		.num_different_channels =3D 1,
 		.beacon_int_infra_match =3D true,
-		.radar_detect_widths =3D	BIT(NL80211_CHAN_NO_HT) |
-					BIT(NL80211_CHAN_HT20),
+		.radar_detect_widths =3D	BIT(NL80211_CHAN_WIDTH_20_NOHT) |
+					BIT(NL80211_CHAN_WIDTH_20),
 	}
 };
=20
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/at=
h/ath9k/pci.c
index 7e4c2524b630..b5656fce4ff5 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -195,6 +195,93 @@ static DEFINE_PCI_DEVICE_TABLE(ath_pci_id_table) =3D {
 			 0x3219),
 	  .driver_data =3D ATH9K_PCI_BT_ANT_DIV },
=20
+	/* AR9485 cards with PLL power-save disabled by default. */
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_AZWAVE,
+			 0x2C97),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_AZWAVE,
+			 0x2100),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x1C56, /* ASKEY */
+			 0x4001),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x11AD, /* LITEON */
+			 0x6627),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x11AD, /* LITEON */
+			 0x6628),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_FOXCONN,
+			 0xE04E),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_FOXCONN,
+			 0xE04F),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x144F, /* ASKEY */
+			 0x7197),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x1B9A, /* XAVI */
+			 0x2000),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x1B9A, /* XAVI */
+			 0x2001),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_AZWAVE,
+			 0x1186),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_AZWAVE,
+			 0x1F86),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_AZWAVE,
+			 0x1195),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_AZWAVE,
+			 0x1F95),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x1B9A, /* XAVI */
+			 0x1C00),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 0x1B9A, /* XAVI */
+			 0x1C01),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_ATHEROS,
+			 0x0032,
+			 PCI_VENDOR_ID_ASUSTEK,
+			 0x850D),
+	  .driver_data =3D ATH9K_PCI_NO_PLL_PWRSAVE },
+
 	{ PCI_VDEVICE(ATHEROS, 0x0032) }, /* PCI-E  AR9485 */
 	{ PCI_VDEVICE(ATHEROS, 0x0033) }, /* PCI-E  AR9580 */
=20
diff --git a/drivers/net/wireless/ath/wcn36xx/debug.c b/drivers/net/wireles=
s/ath/wcn36xx/debug.c
index 5b84f7ae0b1e..ef44a2da644d 100644
--- a/drivers/net/wireless/ath/wcn36xx/debug.c
+++ b/drivers/net/wireless/ath/wcn36xx/debug.c
@@ -126,7 +126,7 @@ static ssize_t write_file_dump(struct file *file,
 		if (begin =3D=3D NULL)
 			break;
=20
-		if (kstrtoul(begin, 0, (unsigned long *)(arg + i)) !=3D 0)
+		if (kstrtou32(begin, 0, &arg[i]) !=3D 0)
 			break;
 	}
=20
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/=
ath/wcn36xx/smd.c
index f8c3a10510c2..de9eb2cfbf4b 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1286,7 +1286,8 @@ int wcn36xx_smd_send_beacon(struct wcn36xx *wcn, stru=
ct ieee80211_vif *vif,
 	} else {
 		wcn36xx_err("Beacon is to big: beacon size=3D%d\n",
 			      msg_body.beacon_length);
-		return -ENOMEM;
+		ret =3D -ENOMEM;
+		goto out;
 	}
 	memcpy(msg_body.bssid, vif->addr, ETH_ALEN);
=20
@@ -1327,7 +1328,8 @@ int wcn36xx_smd_update_proberesp_tmpl(struct wcn36xx =
*wcn,
 	if (skb->len > BEACON_TEMPLATE_SIZE) {
 		wcn36xx_warn("probe response template is too big: %d\n",
 			     skb->len);
-		return -E2BIG;
+		ret =3D -E2BIG;
+		goto out;
 	}
=20
 	msg.probe_resp_template_len =3D skb->len;
@@ -1606,7 +1608,8 @@ int wcn36xx_smd_keep_alive_req(struct wcn36xx *wcn,
 		/* TODO: it also support ARP response type */
 	} else {
 		wcn36xx_warn("unknow keep alive packet type %d\n", packet_type);
-		return -EINVAL;
+		ret =3D -EINVAL;
+		goto out;
 	}
=20
 	PREPARE_HAL_BUF(wcn->hal_buf, msg_body);
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless=
/libertas/debugfs.c
index 668dd27616a0..cc6a0a586f0b 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -913,7 +913,10 @@ static ssize_t lbs_debugfs_write(struct file *f, const=
 char __user *buf,
 	char *p2;
 	struct debug_data *d =3D f->private_data;
=20
-	pdata =3D kmalloc(cnt, GFP_KERNEL);
+	if (cnt =3D=3D 0)
+		return 0;
+
+	pdata =3D kmalloc(cnt + 1, GFP_KERNEL);
 	if (pdata =3D=3D NULL)
 		return 0;
=20
@@ -922,6 +925,7 @@ static ssize_t lbs_debugfs_write(struct file *f, const =
char __user *buf,
 		kfree(pdata);
 		return 0;
 	}
+	pdata[cnt] =3D '\0';
=20
 	p0 =3D pdata;
 	for (i =3D 0; i < num_of_items; i++) {
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/l=
ibertas/if_cs.c
index ef8c98e21098..f499efc6abcf 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -902,6 +902,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	if (card->model =3D=3D MODEL_UNKNOWN) {
 		pr_err("unsupported manf_id 0x%04x / card_id 0x%04x\n",
 		       p_dev->manf_id, p_dev->card_id);
+		ret =3D -ENODEV;
 		goto out2;
 	}
=20
diff --git a/drivers/net/wireless/mwifiex/fw.h b/drivers/net/wireless/mwifi=
ex/fw.h
index f80f30b6160e..c8385ec77a86 100644
--- a/drivers/net/wireless/mwifiex/fw.h
+++ b/drivers/net/wireless/mwifiex/fw.h
@@ -1020,8 +1020,8 @@ struct mwifiex_power_group {
 } __packed;
=20
 struct mwifiex_types_power_group {
-	u16 type;
-	u16 length;
+	__le16 type;
+	__le16 length;
 } __packed;
=20
 struct host_cmd_ds_txpwr_cfg {
diff --git a/drivers/net/wireless/mwifiex/ie.c b/drivers/net/wireless/mwifi=
ex/ie.c
index 220af4fe0fc6..81ac001ee741 100644
--- a/drivers/net/wireless/mwifiex/ie.c
+++ b/drivers/net/wireless/mwifiex/ie.c
@@ -82,7 +82,7 @@ mwifiex_update_autoindex_ies(struct mwifiex_private *priv,
 			     struct mwifiex_ie_list *ie_list)
 {
 	u16 travel_len, index, mask;
-	s16 input_len;
+	s16 input_len, tlv_len;
 	struct mwifiex_ie *ie;
 	u8 *tmp;
=20
@@ -91,11 +91,13 @@ mwifiex_update_autoindex_ies(struct mwifiex_private *pr=
iv,
=20
 	ie_list->len =3D 0;
=20
-	while (input_len > 0) {
+	while (input_len >=3D sizeof(struct mwifiex_ie_types_header)) {
 		ie =3D (struct mwifiex_ie *)(((u8 *)ie_list) + travel_len);
-		input_len -=3D le16_to_cpu(ie->ie_length) + MWIFIEX_IE_HDR_SIZE;
-		travel_len +=3D le16_to_cpu(ie->ie_length) + MWIFIEX_IE_HDR_SIZE;
+		tlv_len =3D le16_to_cpu(ie->ie_length);
+		travel_len +=3D tlv_len + MWIFIEX_IE_HDR_SIZE;
=20
+		if (input_len < tlv_len + MWIFIEX_IE_HDR_SIZE)
+			return -1;
 		index =3D le16_to_cpu(ie->ie_index);
 		mask =3D le16_to_cpu(ie->mgmt_subtype_mask);
=20
@@ -132,6 +134,7 @@ mwifiex_update_autoindex_ies(struct mwifiex_private *pr=
iv,
 		le16_add_cpu(&ie_list->len,
 			     le16_to_cpu(priv->mgmt_ie[index].ie_length) +
 			     MWIFIEX_IE_HDR_SIZE);
+		input_len -=3D tlv_len + MWIFIEX_IE_HDR_SIZE;
 	}
=20
 	if (GET_BSS_ROLE(priv) =3D=3D MWIFIEX_BSS_ROLE_UAP)
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwi=
fiex/sdio.c
index 1576104e3d95..9bf8898743ab 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -1029,7 +1029,10 @@ static int mwifiex_decode_rx_packet(struct mwifiex_a=
dapter *adapter,
 				    struct sk_buff *skb, u32 upld_typ)
 {
 	u8 *cmd_buf;
+	__le16 *curr_ptr =3D (__le16 *)skb->data;
+	u16 pkt_len =3D le16_to_cpu(*curr_ptr);
=20
+	skb_trim(skb, pkt_len);
 	skb_pull(skb, INTF_HEADER_LEN);
=20
 	switch (upld_typ) {
diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/=
mwifiex/sta_cmd.c
index 7d66018a2e33..2181ee283d82 100644
--- a/drivers/net/wireless/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/mwifiex/sta_cmd.c
@@ -239,14 +239,14 @@ static int mwifiex_cmd_tx_power_cfg(struct host_cmd_d=
s_command *cmd,
 			memmove(cmd_txp_cfg, txp,
 				sizeof(struct host_cmd_ds_txpwr_cfg) +
 				sizeof(struct mwifiex_types_power_group) +
-				pg_tlv->length);
+				le16_to_cpu(pg_tlv->length));
=20
 			pg_tlv =3D (struct mwifiex_types_power_group *) ((u8 *)
 				  cmd_txp_cfg +
 				  sizeof(struct host_cmd_ds_txpwr_cfg));
 			cmd->size =3D cpu_to_le16(le16_to_cpu(cmd->size) +
 				  sizeof(struct mwifiex_types_power_group) +
-				  pg_tlv->length);
+				  le16_to_cpu(pg_tlv->length));
 		} else {
 			memmove(cmd_txp_cfg, txp, sizeof(*txp));
 		}
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wirel=
ess/mwifiex/sta_cmdresp.c
index 58a6013712d2..2675ca7f8d14 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -274,17 +274,20 @@ static int mwifiex_ret_tx_rate_cfg(struct mwifiex_pri=
vate *priv,
 	struct host_cmd_ds_tx_rate_cfg *rate_cfg =3D &resp->params.tx_rate_cfg;
 	struct mwifiex_rate_scope *rate_scope;
 	struct mwifiex_ie_types_header *head;
-	u16 tlv, tlv_buf_len;
+	u16 tlv, tlv_buf_len, tlv_buf_left;
 	u8 *tlv_buf;
 	u32 i;
=20
-	tlv_buf =3D ((u8 *)rate_cfg) +
-			sizeof(struct host_cmd_ds_tx_rate_cfg);
-	tlv_buf_len =3D le16_to_cpu(*(__le16 *) (tlv_buf + sizeof(u16)));
+	tlv_buf =3D ((u8 *)rate_cfg) + sizeof(struct host_cmd_ds_tx_rate_cfg);
+	tlv_buf_left =3D le16_to_cpu(resp->size) - S_DS_GEN - sizeof(*rate_cfg);
=20
-	while (tlv_buf && tlv_buf_len > 0) {
-		tlv =3D (*tlv_buf);
-		tlv =3D tlv | (*(tlv_buf + 1) << 8);
+	while (tlv_buf_left >=3D sizeof(*head)) {
+		head =3D (struct mwifiex_ie_types_header *)tlv_buf;
+		tlv =3D le16_to_cpu(head->type);
+		tlv_buf_len =3D le16_to_cpu(head->len);
+
+		if (tlv_buf_left < (sizeof(*head) + tlv_buf_len))
+			break;
=20
 		switch (tlv) {
 		case TLV_TYPE_RATE_SCOPE:
@@ -304,9 +307,8 @@ static int mwifiex_ret_tx_rate_cfg(struct mwifiex_priva=
te *priv,
 			/* Add RATE_DROP tlv here */
 		}
=20
-		head =3D (struct mwifiex_ie_types_header *) tlv_buf;
-		tlv_buf +=3D le16_to_cpu(head->len) + sizeof(*head);
-		tlv_buf_len -=3D le16_to_cpu(head->len);
+		tlv_buf +=3D (sizeof(*head) + tlv_buf_len);
+		tlv_buf_left -=3D (sizeof(*head) + tlv_buf_len);
 	}
=20
 	priv->is_data_rate_auto =3D mwifiex_is_rate_auto(priv);
@@ -340,13 +342,17 @@ static int mwifiex_get_power_level(struct mwifiex_pri=
vate *priv, void *data_buf)
 		((u8 *) data_buf + sizeof(struct host_cmd_ds_txpwr_cfg));
 	pg =3D (struct mwifiex_power_group *)
 		((u8 *) pg_tlv_hdr + sizeof(struct mwifiex_types_power_group));
-	length =3D pg_tlv_hdr->length;
-	if (length > 0) {
-		max_power =3D pg->power_max;
-		min_power =3D pg->power_min;
-		length -=3D sizeof(struct mwifiex_power_group);
-	}
-	while (length) {
+	length =3D le16_to_cpu(pg_tlv_hdr->length);
+
+	/* At least one structure required to update power */
+	if (length < sizeof(struct mwifiex_power_group))
+		return 0;
+
+	max_power =3D pg->power_max;
+	min_power =3D pg->power_min;
+	length -=3D sizeof(struct mwifiex_power_group);
+
+	while (length >=3D sizeof(struct mwifiex_power_group)) {
 		pg++;
 		if (max_power < pg->power_max)
 			max_power =3D pg->power_max;
@@ -356,10 +362,8 @@ static int mwifiex_get_power_level(struct mwifiex_priv=
ate *priv, void *data_buf)
=20
 		length -=3D sizeof(struct mwifiex_power_group);
 	}
-	if (pg_tlv_hdr->length > 0) {
-		priv->min_tx_power_level =3D (u8) min_power;
-		priv->max_tx_power_level =3D (u8) max_power;
-	}
+	priv->min_tx_power_level =3D (u8) min_power;
+	priv->max_tx_power_level =3D (u8) max_power;
=20
 	return 0;
 }
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index f084412eee0b..c8e029df770e 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -638,8 +638,9 @@ int mwifiex_set_tx_power(struct mwifiex_private *priv,
 		txp_cfg->mode =3D cpu_to_le32(1);
 		pg_tlv =3D (struct mwifiex_types_power_group *)
 			 (buf + sizeof(struct host_cmd_ds_txpwr_cfg));
-		pg_tlv->type =3D TLV_TYPE_POWER_GROUP;
-		pg_tlv->length =3D 4 * sizeof(struct mwifiex_power_group);
+		pg_tlv->type =3D cpu_to_le16(TLV_TYPE_POWER_GROUP);
+		pg_tlv->length =3D
+			cpu_to_le16(4 * sizeof(struct mwifiex_power_group));
 		pg =3D (struct mwifiex_power_group *)
 		     (buf + sizeof(struct host_cmd_ds_txpwr_cfg)
 		      + sizeof(struct mwifiex_types_power_group));
diff --git a/drivers/net/wireless/mwifiex/uap_txrx.c b/drivers/net/wireless=
/mwifiex/uap_txrx.c
index 1cfe5a738c47..92f76d655e6c 100644
--- a/drivers/net/wireless/mwifiex/uap_txrx.c
+++ b/drivers/net/wireless/mwifiex/uap_txrx.c
@@ -97,6 +97,7 @@ static void mwifiex_uap_queue_bridged_pkt(struct mwifiex_=
private *priv,
 	struct mwifiex_txinfo *tx_info;
 	int hdr_chop;
 	struct timeval tv;
+	struct ethhdr *p_ethhdr;
 	u8 rfc1042_eth_hdr[ETH_ALEN] =3D { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
=20
 	uap_rx_pd =3D (struct uap_rxpd *)(skb->data);
@@ -112,14 +113,36 @@ static void mwifiex_uap_queue_bridged_pkt(struct mwif=
iex_private *priv,
 	}
=20
 	if (!memcmp(&rx_pkt_hdr->rfc1042_hdr,
-		    rfc1042_eth_hdr, sizeof(rfc1042_eth_hdr)))
+		    rfc1042_eth_hdr, sizeof(rfc1042_eth_hdr))) {
+		/* Replace the 803 header and rfc1042 header (llc/snap) with
+		 * an Ethernet II header, keep the src/dst and snap_type
+		 * (ethertype).
+		 *
+		 * The firmware only passes up SNAP frames converting all RX
+		 * data from 802.11 to 802.2/LLC/SNAP frames.
+		 *
+		 * To create the Ethernet II, just move the src, dst address
+		 * right before the snap_type.
+		 */
+		p_ethhdr =3D (struct ethhdr *)
+			((u8 *)(&rx_pkt_hdr->eth803_hdr)
+			 + sizeof(rx_pkt_hdr->eth803_hdr)
+			 + sizeof(rx_pkt_hdr->rfc1042_hdr)
+			 - sizeof(rx_pkt_hdr->eth803_hdr.h_dest)
+			 - sizeof(rx_pkt_hdr->eth803_hdr.h_source)
+			 - sizeof(rx_pkt_hdr->rfc1042_hdr.snap_type));
+		memcpy(p_ethhdr->h_source, rx_pkt_hdr->eth803_hdr.h_source,
+		       sizeof(p_ethhdr->h_source));
+		memcpy(p_ethhdr->h_dest, rx_pkt_hdr->eth803_hdr.h_dest,
+		       sizeof(p_ethhdr->h_dest));
 		/* Chop off the rxpd + the excess memory from
 		 * 802.2/llc/snap header that was removed.
 		 */
-		hdr_chop =3D (u8 *)eth_hdr - (u8 *)uap_rx_pd;
-	else
+		hdr_chop =3D (u8 *)p_ethhdr - (u8 *)uap_rx_pd;
+	} else {
 		/* Chop off the rxpd */
 		hdr_chop =3D (u8 *)&rx_pkt_hdr->eth803_hdr - (u8 *)uap_rx_pd;
+	}
=20
 	/* Chop off the leading header bytes so the it points
 	 * to the start of either the reconstructed EthII frame
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwif=
iex/wmm.c
index 5dd0ccc70b86..13eaeed03898 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -722,6 +722,9 @@ int mwifiex_ret_wmm_get_status(struct mwifiex_private *=
priv,
 		tlv_hdr =3D (struct mwifiex_ie_types_data *) curr;
 		tlv_len =3D le16_to_cpu(tlv_hdr->header.len);
=20
+		if (resp_len < tlv_len + sizeof(tlv_hdr->header))
+			break;
+
 		switch (le16_to_cpu(tlv_hdr->header.type)) {
 		case TLV_TYPE_WMMQSTATUS:
 			tlv_wmm_qstatus =3D
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wirele=
ss/prism54/islpci_dev.c
index 41a16d30c79c..e05d9b4c8317 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -811,6 +811,10 @@ static const struct net_device_ops islpci_netdev_ops =
=3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 };
=20
+static struct device_type wlan_type =3D {
+	.name	=3D "wlan",
+};
+
 struct net_device *
 islpci_setup(struct pci_dev *pdev)
 {
@@ -821,9 +825,8 @@ islpci_setup(struct pci_dev *pdev)
 		return ndev;
=20
 	pci_set_drvdata(pdev, ndev);
-#if defined(SET_NETDEV_DEV)
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-#endif
+	SET_NETDEV_DEVTYPE(ndev, &wlan_type);
=20
 	/* setup the structure members */
 	ndev->base_addr =3D pci_resource_start(pdev, 0);
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index c5738f14c4ba..776aff3678ff 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2640,7 +2640,7 @@ static void rt2800_config_channel_rf53xx(struct rt2x0=
0_dev *rt2x00dev,
=20
 	if (rt2x00_rt(rt2x00dev, RT5392)) {
 		rt2800_rfcsr_read(rt2x00dev, 50, &rfcsr);
-		if (info->default_power1 > POWER_BOUND)
+		if (info->default_power2 > POWER_BOUND)
 			rt2x00_set_field8(&rfcsr, RFCSR50_TX, POWER_BOUND);
 		else
 			rt2x00_set_field8(&rfcsr, RFCSR50_TX,
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless=
/rt2x00/rt2x00lib.h
index a0935987fa3a..7f40ab8e1bd8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -146,7 +146,7 @@ void rt2x00queue_remove_l2pad(struct sk_buff *skb, unsi=
gned int header_length);
  * @local: frame is not from mac80211
  */
 int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *s=
kb,
-			       bool local);
+			       struct ieee80211_sta *sta, bool local);
=20
 /**
  * rt2x00queue_update_beacon - Send new beacon from mac80211
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless=
/rt2x00/rt2x00mac.c
index 7c157857f5ce..2183e7978399 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -90,7 +90,7 @@ static int rt2x00mac_tx_rts_cts(struct rt2x00_dev *rt2x00=
dev,
 				  frag_skb->data, data_length, tx_info,
 				  (struct ieee80211_rts *)(skb->data));
=20
-	retval =3D rt2x00queue_write_tx_frame(queue, skb, true);
+	retval =3D rt2x00queue_write_tx_frame(queue, skb, NULL, true);
 	if (retval) {
 		dev_kfree_skb_any(skb);
 		rt2x00_warn(rt2x00dev, "Failed to send RTS/CTS frame\n");
@@ -151,7 +151,7 @@ void rt2x00mac_tx(struct ieee80211_hw *hw,
 			goto exit_fail;
 	}
=20
-	if (unlikely(rt2x00queue_write_tx_frame(queue, skb, false)))
+	if (unlikely(rt2x00queue_write_tx_frame(queue, skb, control->sta, false)))
 		goto exit_fail;
=20
 	/*
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wirele=
ss/rt2x00/rt2x00queue.c
index 50590b1420a5..a5d38e8ad9e4 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -635,7 +635,7 @@ static void rt2x00queue_bar_check(struct queue_entry *e=
ntry)
 }
=20
 int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *s=
kb,
-			       bool local)
+			       struct ieee80211_sta *sta, bool local)
 {
 	struct ieee80211_tx_info *tx_info;
 	struct queue_entry *entry;
@@ -649,7 +649,7 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue=
, struct sk_buff *skb,
 	 * after that we are free to use the skb->cb array
 	 * for our information.
 	 */
-	rt2x00queue_create_tx_descriptor(queue->rt2x00dev, skb, &txdesc, NULL);
+	rt2x00queue_create_tx_descriptor(queue->rt2x00dev, skb, &txdesc, sta);
=20
 	/*
 	 * All information is retrieved from the skb->cb array,
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtl=
wifi/base.c
index 9a78e3daf742..ff784072fb42 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -37,6 +37,7 @@
=20
 #include <linux/ip.h>
 #include <linux/module.h>
+#include <linux/udp.h>
=20
 /*
  *NOTICE!!!: This file will be very big, we should
@@ -1074,64 +1075,52 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, str=
uct sk_buff *skb, u8 is_tx)
 	if (!ieee80211_is_data(fc))
 		return false;
=20
+	ip =3D (const struct iphdr *)(skb->data + mac_hdr_len +
+				    SNAP_SIZE + PROTOC_TYPE_SIZE);
+	ether_type =3D be16_to_cpup((__be16 *)
+				  (skb->data + mac_hdr_len + SNAP_SIZE));
=20
-	ip =3D (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
-			      SNAP_SIZE + PROTOC_TYPE_SIZE);
-	ether_type =3D *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZE);
-	/*	ether_type =3D ntohs(ether_type); */
-
-	if (ETH_P_IP =3D=3D ether_type) {
-		if (IPPROTO_UDP =3D=3D ip->protocol) {
-			struct udphdr *udp =3D (struct udphdr *)((u8 *) ip +
-							       (ip->ihl << 2));
-			if (((((u8 *) udp)[1] =3D=3D 68) &&
-			     (((u8 *) udp)[3] =3D=3D 67)) ||
-			    ((((u8 *) udp)[1] =3D=3D 67) &&
-			     (((u8 *) udp)[3] =3D=3D 68))) {
-				/*
-				 * 68 : UDP BOOTP client
-				 * 67 : UDP BOOTP server
-				 */
-				RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV),
-					 DBG_DMESG, "dhcp %s !!\n",
-					 is_tx ? "Tx" : "Rx");
-
-				if (is_tx) {
-					rtlpriv->enter_ps =3D false;
-					schedule_work(&rtlpriv->
-						      works.lps_change_work);
-					ppsc->last_delaylps_stamp_jiffies =3D
-					    jiffies;
-				}
+	switch (ether_type) {
+	case ETH_P_IP: {
+		struct udphdr *udp;
+		u16 src;
+		u16 dst;
=20
-				return true;
-			}
-		}
-	} else if (ETH_P_ARP =3D=3D ether_type) {
-		if (is_tx) {
-			rtlpriv->enter_ps =3D false;
-			schedule_work(&rtlpriv->works.lps_change_work);
-			ppsc->last_delaylps_stamp_jiffies =3D jiffies;
-		}
+		if (ip->protocol !=3D IPPROTO_UDP)
+			return false;
+		udp =3D (struct udphdr *)((u8 *)ip + (ip->ihl << 2));
+		src =3D be16_to_cpu(udp->source);
+		dst =3D be16_to_cpu(udp->dest);
=20
-		return true;
-	} else if (ETH_P_PAE =3D=3D ether_type) {
+		/* If this case involves port 68 (UDP BOOTP client) connecting
+		 * with port 67 (UDP BOOTP server), then return true so that
+		 * the lowest speed is used.
+		 */
+		if (!((src =3D=3D 68 && dst =3D=3D 67) || (src =3D=3D 67 && dst =3D=3D 6=
8)))
+			return false;
+
+		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
+			 "dhcp %s !!\n", is_tx ? "Tx" : "Rx");
+		break;
+	}
+	case ETH_P_ARP:
+		break;
+	case ETH_P_PAE:
 		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
 			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
-
-		if (is_tx) {
-			rtlpriv->enter_ps =3D false;
-			schedule_work(&rtlpriv->works.lps_change_work);
-			ppsc->last_delaylps_stamp_jiffies =3D jiffies;
-		}
-
-		return true;
-	} else if (ETH_P_IPV6 =3D=3D ether_type) {
-		/* IPv6 */
-		return true;
+		break;
+	case ETH_P_IPV6:
+		/* TODO: Is this right? */
+		return false;
+	default:
+		return false;
 	}
-
-	return false;
+	if (is_tx) {
+		rtlpriv->enter_ps =3D false;
+		schedule_work(&rtlpriv->works.lps_change_work);
+		ppsc->last_delaylps_stamp_jiffies =3D jiffies;
+	}
+	return true;
 }
 EXPORT_SYMBOL_GPL(rtl_is_special_data);
=20
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rt=
lwifi/efuse.c
index ae13fb94b2e8..2ffc7298f686 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -262,9 +262,9 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u=
16 _size_byte, u8 *pbuf)
 			    sizeof(u8), GFP_ATOMIC);
 	if (!efuse_tbl)
 		return;
-	efuse_word =3D kmalloc(EFUSE_MAX_WORD_UNIT * sizeof(u16 *), GFP_ATOMIC);
+	efuse_word =3D kzalloc(EFUSE_MAX_WORD_UNIT * sizeof(u16 *), GFP_ATOMIC);
 	if (!efuse_word)
-		goto done;
+		goto out;
 	for (i =3D 0; i < EFUSE_MAX_WORD_UNIT; i++) {
 		efuse_word[i] =3D kmalloc(efuse_max_section * sizeof(u16),
 					GFP_ATOMIC);
@@ -378,6 +378,7 @@ done:
 	for (i =3D 0; i < EFUSE_MAX_WORD_UNIT; i++)
 		kfree(efuse_word[i]);
 	kfree(efuse_word);
+out:
 	kfree(efuse_tbl);
 }
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/trx.c
index 25e50ffc44ec..b0c346a9e4b8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -349,7 +349,7 @@ bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
 						 p_drvinfo);
 	}
 	/*rx_status->qual =3D stats->signal; */
-	rx_status->signal =3D stats->rssi + 10;
+	rx_status->signal =3D stats->recvsignalpower + 10;
 	return true;
 }
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192de/trx.c
index 945ddecf90c9..0eb0f4ae5920 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -525,7 +525,7 @@ bool rtl92de_rx_query_desc(struct ieee80211_hw *hw,	str=
uct rtl_stats *stats,
 						   p_drvinfo);
 	}
 	/*rx_status->qual =3D stats->signal; */
-	rx_status->signal =3D stats->rssi + 10;
+	rx_status->signal =3D stats->recvsignalpower + 10;
 	return true;
 }
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wire=
less/rtlwifi/rtl8192se/rf.c
index 5061f1db3f02..92d38ab3c60e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
@@ -265,7 +265,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(s=
truct ieee80211_hw *hw,
 				    rtlefuse->pwrgroup_ht40
 				    [RF90_PATH_A][chnl - 1]) {
 					pwrdiff_limit[i] =3D
-					  rtlefuse->pwrgroup_ht20
+					  rtlefuse->pwrgroup_ht40
 					  [RF90_PATH_A][chnl - 1];
 				}
 			} else {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192se/trx.c
index 222d2e792ca6..27efbcdac6a9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -329,7 +329,7 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, str=
uct rtl_stats *stats,
 	}
=20
 	/*rx_status->qual =3D stats->signal; */
-	rx_status->signal =3D stats->rssi + 10;
+	rx_status->signal =3D stats->recvsignalpower + 10;
=20
 	return true;
 }
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtl=
wifi/wifi.h
index d224dc3bb092..0c65386fa30d 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -77,11 +77,7 @@
 #define RTL_SLOT_TIME_9				9
 #define RTL_SLOT_TIME_20			20
=20
-/*related with tcp/ip. */
-/*if_ehther.h*/
-#define ETH_P_PAE		0x888E	/*Port Access Entity (IEEE 802.1X) */
-#define ETH_P_IP		0x0800	/*Internet Protocol packet */
-#define ETH_P_ARP		0x0806	/*Address Resolution packet */
+/*related to tcp/ip. */
 #define SNAP_SIZE		6
 #define PROTOC_TYPE_SIZE	2
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJShSBXAAoJEJctW/TcYTgGVrUQAIAyRE16NyjjXEv5p+sx9Sl4
covYfVO1+kmTafLrF4VdG+SZq8EMgCasN07JP/xpjvOqMwHCgvy+Lg1CibKWENg0
q0fvDr/nLcb0D0TUNc4u07DBr33VvSsilGz9Dn3fAVE59m0qVeBT/OQiRkXTQBAH
tRxBUt55nuKTDhixMp6NRHGIKD3XYxg613ajjyfX6MFxdVO8vPMc8PzVaBQEl9Gm
XZsFESo1kHQqDJzfaqMkkyFvxJjFy186uHCmiQ6qF6zDIN5V8qBbX2e3sadUE6lH
7R3gDLaNE8MFj4qNLQ+uS8iHBBPDlWHTrpJpO5nslcw/4NvwLpe/i4Iiu86mVjsb
Ww8sTBJkcCtBXm2X9JPLyB10k9xKPSWKDWSJKhKsg+USt/u8FjFOD8aLHJHEjb/5
LQcgwMtpuig0vFsAzW6T1w+KUKt1ez1Nae4jjtWxybwkee2EaIG/G4tziqtOmD2C
zrReP6PyvpJUXrOxGeSfXL9HdryjfJmQt8dUt3N9S/18P2U6935XRPD7mSIK3wmD
IeUeQKeQslMhpTJ35bWDat9tzGxfdgjQeNJO+YBLi+Mmea++GIVbNJVzSUQ+kml2
xTHNpS95hAusE8l1tDYCr0N1Sn9TJvhcCc4kQ9fKEazNfa4HrDqexL2NSARH1Ir7
Gv43rH7TpGnM4UF77hOH
=hND4
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
