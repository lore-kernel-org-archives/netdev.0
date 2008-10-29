From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-10-29
Date: Wed, 29 Oct 2008 19:18:55 -0400
Message-ID: <20081029231855.GD3485@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another quick round of fixes intended for 2.6.28...

This includes fixes for bugs 11749 and 11845, fixes a reset-related
regression in ath5k, fixes a Kconfig-related error for rt2x00, and
fixes some sparse warnings and a possible buffer overrun in libertas.
Also, it corrects a spelling error and marks Bob Copeland as an
ath5k maintainer.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 882716604ecf388b2ff09bc76eb2a752aa9cc76b:
  Jesse Brandeburg (1):
        pktgen: fix multiple queue warning

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (3):
      ath5k: correct misspelling in debug help
      ath5k: honor FIF_BCN_PRBRESP_PROMISC in STA mode
      ath5k: add self to MAINTAINERS

Elias Oltmanns (1):
      ath5k: Fix reset sequence for AR5212 in general and RF5111 in particular

Holger Schurig (1):
      libertas: remove two libertas sparse warning

Ivo van Doorn (1):
      rt2x00: Fix build error when mac80211=M rt2x00=Y

Johannes Berg (1):
      libertas: fix buffer overrun

Tomas Winkler (1):
      iwlwifi: fix suspend to RAM in iwlwifi

 MAINTAINERS                            |    2 ++
 drivers/net/wireless/ath5k/base.c      |    4 +---
 drivers/net/wireless/ath5k/debug.c     |    2 +-
 drivers/net/wireless/ath5k/initvals.c  |    2 ++
 drivers/net/wireless/ath5k/reset.c     |   22 +++++++---------------
 drivers/net/wireless/iwlwifi/iwl-agn.c |    2 +-
 drivers/net/wireless/libertas/cmd.c    |    4 ++--
 drivers/net/wireless/libertas/scan.c   |    4 ++--
 drivers/net/wireless/rt2x00/Kconfig    |    2 +-
 9 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 16202c8..185b84a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -738,6 +738,8 @@ P:	Nick Kossifidis
 M:	mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
 P:	Luis R. Rodriguez
 M:	mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
+P:	Bob Copeland
+M:	me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
 S:	Maintained
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index cfd4d05..9e47d72 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -2942,10 +2942,8 @@ static void ath5k_configure_filter(struct ieee80211_hw *hw,
 		sc->opmode != NL80211_IFTYPE_MESH_POINT &&
 		test_bit(ATH_STAT_PROMISC, sc->status))
 		rfilt |= AR5K_RX_FILTER_PROM;
-	if (sc->opmode == NL80211_IFTYPE_STATION ||
-		sc->opmode == NL80211_IFTYPE_ADHOC) {
+	if (sc->opmode == NL80211_IFTYPE_ADHOC)
 		rfilt |= AR5K_RX_FILTER_BEACON;
-	}
 
 	/* Set filters */
 	ath5k_hw_set_rx_filter(ah,rfilt);
diff --git a/drivers/net/wireless/ath5k/debug.c b/drivers/net/wireless/ath5k/debug.c
index 8f92d67..19980cb 100644
--- a/drivers/net/wireless/ath5k/debug.c
+++ b/drivers/net/wireless/ath5k/debug.c
@@ -339,7 +339,7 @@ static struct {
 	{ ATH5K_DEBUG_BEACON,	"beacon",	"beacon handling" },
 	{ ATH5K_DEBUG_CALIBRATE, "calib",	"periodic calibration" },
 	{ ATH5K_DEBUG_TXPOWER,	"txpower",	"transmit power setting" },
-	{ ATH5K_DEBUG_LED,	"led",		"LED mamagement" },
+	{ ATH5K_DEBUG_LED,	"led",		"LED management" },
 	{ ATH5K_DEBUG_DUMP_RX,	"dumprx",	"print received skb content" },
 	{ ATH5K_DEBUG_DUMP_TX,	"dumptx",	"print transmit skb content" },
 	{ ATH5K_DEBUG_DUMPBANDS, "dumpbands",	"dump bands" },
diff --git a/drivers/net/wireless/ath5k/initvals.c b/drivers/net/wireless/ath5k/initvals.c
index ea2e1a2..ceaa6c4 100644
--- a/drivers/net/wireless/ath5k/initvals.c
+++ b/drivers/net/wireless/ath5k/initvals.c
@@ -806,6 +806,8 @@ static const struct ath5k_ini_mode ar5212_rf5111_ini_mode_end[] = {
 		{ 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000 } },
 	{ AR5K_PHY(642),
 		{ 0xd03e6788, 0xd03e6788, 0xd03e6788, 0xd03e6788, 0xd03e6788 } },
+	{ 0xa228,
+		{ 0x000001b5, 0x000001b5, 0x000001b5, 0x000001b5, 0x000001b5 } },
 	{ 0xa23c,
 		{ 0x13c889af, 0x13c889af, 0x13c889af, 0x13c889af, 0x13c889af } },
 };
diff --git a/drivers/net/wireless/ath5k/reset.c b/drivers/net/wireless/ath5k/reset.c
index 8f18868..1b6d45b 100644
--- a/drivers/net/wireless/ath5k/reset.c
+++ b/drivers/net/wireless/ath5k/reset.c
@@ -537,9 +537,10 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum nl80211_iftype op_mode,
 		mdelay(1);
 
 		/*
-		 * Write some more initial register settings
+		 * Write some more initial register settings for revised chips
 		 */
-		if (ah->ah_version == AR5K_AR5212) {
+		if (ah->ah_version == AR5K_AR5212 &&
+		    ah->ah_phy_revision > 0x41) {
 			ath5k_hw_reg_write(ah, 0x0002a002, 0x982c);
 
 			if (channel->hw_value == CHANNEL_G)
@@ -558,19 +559,10 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum nl80211_iftype op_mode,
 			else
 				ath5k_hw_reg_write(ah, 0x00000000, 0x994c);
 
-			/* Some bits are disabled here, we know nothing about
-			 * register 0xa228 yet, most of the times this ends up
-			 * with a value 0x9b5 -haven't seen any dump with
-			 * a different value- */
-			/* Got this from decompiling binary HAL */
-			data = ath5k_hw_reg_read(ah, 0xa228);
-			data &= 0xfffffdff;
-			ath5k_hw_reg_write(ah, data, 0xa228);
-
-			data = ath5k_hw_reg_read(ah, 0xa228);
-			data &= 0xfffe03ff;
-			ath5k_hw_reg_write(ah, data, 0xa228);
-			data = 0;
+			/* Got this from legacy-hal */
+			AR5K_REG_DISABLE_BITS(ah, 0xa228, 0x200);
+
+			AR5K_REG_MASKED_BITS(ah, 0xa228, 0x800, 0xfffe03ff);
 
 			/* Just write 0x9b5 ? */
 			/* ath5k_hw_reg_write(ah, 0x000009b5, 0xa228); */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 24a1aeb..321dbc8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2090,7 +2090,6 @@ static void iwl_alive_start(struct iwl_priv *priv)
 		iwl4965_error_recovery(priv);
 
 	iwl_power_update_mode(priv, 1);
-	ieee80211_notify_mac(priv->hw, IEEE80211_NOTIFY_RE_ASSOC);
 
 	if (test_and_clear_bit(STATUS_MODE_PENDING, &priv->status))
 		iwl4965_set_mode(priv, priv->iw_mode);
@@ -2342,6 +2341,7 @@ static void iwl_bg_alive_start(struct work_struct *data)
 	mutex_lock(&priv->mutex);
 	iwl_alive_start(priv);
 	mutex_unlock(&priv->mutex);
+	ieee80211_notify_mac(priv->hw, IEEE80211_NOTIFY_RE_ASSOC);
 }
 
 static void iwl4965_bg_rf_kill(struct work_struct *work)
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 297696d..8265c7d 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -605,9 +605,9 @@ int lbs_get_tx_power(struct lbs_private *priv, s16 *curlevel, s16 *minlevel,
 	if (ret == 0) {
 		*curlevel = le16_to_cpu(cmd.curlevel);
 		if (minlevel)
-			*minlevel = le16_to_cpu(cmd.minlevel);
+			*minlevel = cmd.minlevel;
 		if (maxlevel)
-			*maxlevel = le16_to_cpu(cmd.maxlevel);
+			*maxlevel = cmd.maxlevel;
 	}
 
 	lbs_deb_leave(LBS_DEB_CMD);
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index 8f66903..22c4c61 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -598,8 +598,8 @@ static int lbs_process_bss(struct bss_descriptor *bss,
 
 		switch (elem->id) {
 		case MFIE_TYPE_SSID:
-			bss->ssid_len = elem->len;
-			memcpy(bss->ssid, elem->data, elem->len);
+			bss->ssid_len = min_t(int, 32, elem->len);
+			memcpy(bss->ssid, elem->data, bss->ssid_len);
 			lbs_deb_scan("got SSID IE: '%s', len %u\n",
 			             escape_essid(bss->ssid, bss->ssid_len),
 			             bss->ssid_len);
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index f839ce0..95511ac 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -1,5 +1,5 @@
 menuconfig RT2X00
-	bool "Ralink driver support"
+	tristate "Ralink driver support"
 	depends on MAC80211 && WLAN_80211 && EXPERIMENTAL
 	---help---
 	  This will enable the experimental support for the Ralink drivers,
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
