From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-11-11
Date: Wed, 11 Nov 2009 12:22:55 -0500
Message-ID: <20091111172255.GH4392@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757989AbZKKRaT@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch of small fixes intended for 2.6.32.  Along with a
number of simple fixes, there is also a MAINTAINERS update, some LED
handling quirks for ath5k, a libertas beautification that is a prereq
for a libertas fix, and an iwlwifi fix that was already sent for
net-next-2.6 but which is needed to support an iwlwifi regression fix.

My personal favorite is the ath5k mcast filtering fix.  The problem
only revealed itself when using IP autoconf w/ multicast DNS... :-)

Please let me know if there are problems!

Thanks,

John

P.S.  Due to the aformentioned iwlwifi fix, this will cause -next
conflicts for sfr.  You may want to pull net-2.6 into net-next-2.6 after
pulling this.  The iwlwifi conflicts can be resolved by taking the bigger
hunks...

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 2606289779cb297320a185db5997729d29b6700b:
  Sebastian Siewior (1):
        net/fsl_pq_mdio: add module license GPL

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bing Zhao (2):
      Libertas: coding style cleanup in ethtool.c
      Libertas: fix issues while configuring host sleep using ethtool wol

Bob Copeland (3):
      ath5k: don't reset mcast filter when configuring the mode
      ath5k: add LED support for HP Compaq CQ60
      ath5k: add LED definition for BenQ Joybook R55v

Felix Fietkau (1):
      b43: work around a locking issue in ->set_tim()

Ivo van Doorn (1):
      rt2x00: update MAINTAINERS

Larry Finger (1):
      rtl8187: Fix sparse warnings

Martin Fuzzey (1):
      ssb-pcmcia: Fix 32bit register access in early bus scanning

Wey-Yi Guy (2):
      iwlwifi: Use RTS/CTS as the preferred protection mechanism for 6000 series
      iwlwifi: Fix issue on file transfer stalled in HT mode

 MAINTAINERS                                   |    1 +
 drivers/net/wireless/ath/ath5k/base.c         |    1 -
 drivers/net/wireless/ath/ath5k/led.c          |    4 ++++
 drivers/net/wireless/b43/main.c               |    3 +--
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-6000.c       |    5 +++++
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |    9 +++++++++
 drivers/net/wireless/iwlwifi/iwl-agn.c        |   10 +++++++---
 drivers/net/wireless/iwlwifi/iwl-core.h       |    2 ++
 drivers/net/wireless/libertas/ethtool.c       |   17 ++++++++++-------
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c |    1 +
 drivers/ssb/scan.c                            |    6 +++++-
 12 files changed, 46 insertions(+), 14 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c856aee..b37e0cd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4280,6 +4280,7 @@ F:	drivers/video/aty/aty128fb.c
 
 RALINK RT2X00 WIRELESS LAN DRIVER
 P:	rt2x00 project
+M:	Ivo van Doorn <IvDoorn@gmail.com>
 L:	linux-wireless@vger.kernel.org
 L:	users@rt2x00.serialmonkey.com (moderated for non-subscribers)
 W:	http://rt2x00.serialmonkey.com/
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 9c6ab53..95a8e23 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1125,7 +1125,6 @@ ath5k_mode_setup(struct ath5k_softc *sc)
 	/* configure operational mode */
 	ath5k_hw_set_opmode(ah);
 
-	ath5k_hw_set_mcast_filter(ah, 0, 0);
 	ATH5K_DBG(sc, ATH5K_DEBUG_MODE, "RX filter 0x%x\n", rfilt);
 }
 
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index b767c3b..b548c8e 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -63,12 +63,16 @@ static const struct pci_device_id ath5k_led_devices[] = {
 	{ ATH_SDEVICE(PCI_VENDOR_ID_AMBIT, 0x0422), ATH_LED(1, 1) },
 	/* E-machines E510 (tuliom@gmail.com) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_AMBIT, 0x0428), ATH_LED(3, 0) },
+	/* BenQ Joybook R55v (nowymarluk@wp.pl) */
+	{ ATH_SDEVICE(PCI_VENDOR_ID_QMI, 0x0100), ATH_LED(1, 0) },
 	/* Acer Extensa 5620z (nekoreeve@gmail.com) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_QMI, 0x0105), ATH_LED(3, 0) },
 	/* Fukato Datacask Jupiter 1014a (mrb74@gmx.at) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_AZWAVE, 0x1026), ATH_LED(3, 0) },
 	/* IBM ThinkPad AR5BXB6 (legovini@spiro.fisica.unipd.it) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_IBM, 0x058a), ATH_LED(1, 0) },
+	/* HP Compaq CQ60-206US (ddreggors@jumptv.com) */
+	{ ATH_SDEVICE(PCI_VENDOR_ID_HP, 0x0137a), ATH_LED(3, 1) },
 	/* HP Compaq C700 (nitrousnrg@gmail.com) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_HP, 0x0137b), ATH_LED(3, 1) },
 	/* IBM-specific AR5212 (all others) */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 86f3582..098dda1 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4521,9 +4521,8 @@ static int b43_op_beacon_set_tim(struct ieee80211_hw *hw,
 {
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 
-	mutex_lock(&wl->mutex);
+	/* FIXME: add locking */
 	b43_update_templates(wl);
-	mutex_unlock(&wl->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index 2716b91..950267a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -161,5 +161,6 @@ struct iwl_cfg iwl1000_bgn_cfg = {
 	.max_ll_items = OTP_MAX_LL_ITEMS_1000,
 	.shadow_ram_support = false,
 	.ht_greenfield_support = true,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 };
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index c295b8e..1473452 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -175,6 +175,7 @@ struct iwl_cfg iwl6000h_2agn_cfg = {
 	.max_ll_items = OTP_MAX_LL_ITEMS_6x00,
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 };
 
 /*
@@ -198,6 +199,7 @@ struct iwl_cfg iwl6000i_2agn_cfg = {
 	.max_ll_items = OTP_MAX_LL_ITEMS_6x00,
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 };
 
 struct iwl_cfg iwl6050_2agn_cfg = {
@@ -218,6 +220,7 @@ struct iwl_cfg iwl6050_2agn_cfg = {
 	.max_ll_items = OTP_MAX_LL_ITEMS_6x00,
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 };
 
 struct iwl_cfg iwl6000_3agn_cfg = {
@@ -238,6 +241,7 @@ struct iwl_cfg iwl6000_3agn_cfg = {
 	.max_ll_items = OTP_MAX_LL_ITEMS_6x00,
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 };
 
 struct iwl_cfg iwl6050_3agn_cfg = {
@@ -258,6 +262,7 @@ struct iwl_cfg iwl6050_3agn_cfg = {
 	.max_ll_items = OTP_MAX_LL_ITEMS_6x00,
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 };
 
 MODULE_FIRMWARE(IWL6000_MODULE_FIRMWARE(IWL6000_UCODE_API_MAX));
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 346dc06..81726ee 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -418,6 +418,15 @@ static void rs_tl_turn_on_agg(struct iwl_priv *priv, u8 tid,
 	else if (tid == IWL_AGG_ALL_TID)
 		for (tid = 0; tid < TID_MAX_LOAD_COUNT; tid++)
 			rs_tl_turn_on_agg_for_tid(priv, lq_data, tid, sta);
+	if (priv->cfg->use_rts_for_ht) {
+		/*
+		 * switch to RTS/CTS if it is the prefer protection method
+		 * for HT traffic
+		 */
+		IWL_DEBUG_HT(priv, "use RTS/CTS protection for HT\n");
+		priv->staging_rxon.flags &= ~RXON_FLG_SELF_CTS_EN;
+		iwlcore_commit_rxon(priv);
+	}
 }
 
 static inline int get_num_of_ant_from_rate(u32 rate_n_flags)
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 9b5ea8b..877af44 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -115,9 +115,6 @@ int iwl_commit_rxon(struct iwl_priv *priv)
 
 	/* always get timestamp with Rx frame */
 	priv->staging_rxon.flags |= RXON_FLG_TSF2HOST_MSK;
-	/* allow CTS-to-self if possible. this is relevant only for
-	 * 5000, but will not damage 4965 */
-	priv->staging_rxon.flags |= RXON_FLG_SELF_CTS_EN;
 
 	ret = iwl_check_rxon_cmd(priv);
 	if (ret) {
@@ -217,6 +214,13 @@ int iwl_commit_rxon(struct iwl_priv *priv)
 					"Could not send WEP static key.\n");
 		}
 
+		/*
+		 * allow CTS-to-self if possible for new association.
+		 * this is relevant only for 5000 series and up,
+		 * but will not damage 4965
+		 */
+		priv->staging_rxon.flags |= RXON_FLG_SELF_CTS_EN;
+
 		/* Apply the new configuration
 		 * RXON assoc doesn't clear the station table in uCode,
 		 */
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index e50103a..7754538 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -213,6 +213,7 @@ struct iwl_mod_params {
  * @pa_type: used by 6000 series only to identify the type of Power Amplifier
  * @max_ll_items: max number of OTP blocks
  * @shadow_ram_support: shadow support for OTP memory
+ * @use_rts_for_ht: use rts/cts protection for HT traffic
  *
  * We enable the driver to be backward compatible wrt API version. The
  * driver specifies which APIs it supports (with @ucode_api_max being the
@@ -255,6 +256,7 @@ struct iwl_cfg {
 	const bool shadow_ram_support;
 	const bool ht_greenfield_support;
 	const bool broken_powersave;
+	bool use_rts_for_ht;
 };
 
 /***************************
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index 039b555..53d56ab 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -169,16 +169,19 @@ static int lbs_ethtool_set_wol(struct net_device *dev,
 	struct lbs_private *priv = dev->ml_priv;
 	uint32_t criteria = 0;
 
-	if (priv->wol_criteria == 0xffffffff && wol->wolopts)
-		return -EOPNOTSUPP;
-
 	if (wol->wolopts & ~(WAKE_UCAST|WAKE_MCAST|WAKE_BCAST|WAKE_PHY))
 		return -EOPNOTSUPP;
 
-	if (wol->wolopts & WAKE_UCAST) criteria |= EHS_WAKE_ON_UNICAST_DATA;
-	if (wol->wolopts & WAKE_MCAST) criteria |= EHS_WAKE_ON_MULTICAST_DATA;
-	if (wol->wolopts & WAKE_BCAST) criteria |= EHS_WAKE_ON_BROADCAST_DATA;
-	if (wol->wolopts & WAKE_PHY)   criteria |= EHS_WAKE_ON_MAC_EVENT;
+	if (wol->wolopts & WAKE_UCAST)
+		criteria |= EHS_WAKE_ON_UNICAST_DATA;
+	if (wol->wolopts & WAKE_MCAST)
+		criteria |= EHS_WAKE_ON_MULTICAST_DATA;
+	if (wol->wolopts & WAKE_BCAST)
+		criteria |= EHS_WAKE_ON_BROADCAST_DATA;
+	if (wol->wolopts & WAKE_PHY)
+		criteria |= EHS_WAKE_ON_MAC_EVENT;
+	if (wol->wolopts == 0)
+		criteria |= EHS_REMOVE_WAKEUP;
 
 	return lbs_host_sleep_cfg(priv, criteria, (struct wol_config *)NULL);
 }
diff --git a/drivers/net/wireless/rtl818x/rtl8187_rfkill.c b/drivers/net/wireless/rtl818x/rtl8187_rfkill.c
index 9fab13e..cad8037 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_rfkill.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_rfkill.c
@@ -18,6 +18,7 @@
 #include <net/mac80211.h>
 
 #include "rtl8187.h"
+#include "rtl8187_rfkill.h"
 
 static bool rtl8187_is_radio_enabled(struct rtl8187_priv *priv)
 {
diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
index b74212d..e8b89e8 100644
--- a/drivers/ssb/scan.c
+++ b/drivers/ssb/scan.c
@@ -162,6 +162,8 @@ static u8 chipid_to_nrcores(u16 chipid)
 static u32 scan_read32(struct ssb_bus *bus, u8 current_coreidx,
 		       u16 offset)
 {
+	u32 lo, hi;
+
 	switch (bus->bustype) {
 	case SSB_BUSTYPE_SSB:
 		offset += current_coreidx * SSB_CORE_SIZE;
@@ -174,7 +176,9 @@ static u32 scan_read32(struct ssb_bus *bus, u8 current_coreidx,
 			offset -= 0x800;
 		} else
 			ssb_pcmcia_switch_segment(bus, 0);
-		break;
+		lo = readw(bus->mmio + offset);
+		hi = readw(bus->mmio + offset + 2);
+		return lo | (hi << 16);
 	case SSB_BUSTYPE_SDIO:
 		offset += current_coreidx * SSB_CORE_SIZE;
 		return ssb_sdio_scan_read32(bus, offset);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
