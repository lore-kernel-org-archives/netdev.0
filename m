From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] wireless: Use const struct ieee80211_channel where possible
Date: Thu, 28 Apr 2011 22:25:08 -0700
Message-ID: <2329e0d2c5febe8ab4fcdfffff4ca29cc19dcb3e.1304054543.git.joe@perches.com>
References: <cover.1304054543.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Samuel Ortiz <samuel.ortiz@intel.com>,
	Dan Williams <dcbw@re
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304054543.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make some structure uses const.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlegacy/iwl-4965-lib.c |    2 +-
 drivers/net/wireless/iwlegacy/iwl3945-base.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c   |    2 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |    4 ++--
 drivers/net/wireless/libertas/cfg.c          |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c      |    9 +++++----
 drivers/net/wireless/orinoco/cfg.c           |    2 +-
 drivers/net/wireless/rndis_wlan.c            |    9 +++++----
 drivers/net/wireless/wl1251/cmd.c            |    2 +-
 drivers/net/wireless/wl1251/cmd.h            |    2 +-
 10 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-lib.c b/drivers/net/wireless/iwlegacy/iwl-4965-lib.c
index 5a8a3cc..41ec864 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-lib.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-lib.c
@@ -741,7 +741,7 @@ static int iwl4965_get_channels_for_scan(struct iwl_priv *priv,
 				     u8 is_active, u8 n_probes,
 				     struct iwl_scan_channel *scan_ch)
 {
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	const struct ieee80211_supported_band *sband;
 	const struct iwl_channel_info *ch_info;
 	u16 passive_dwell = 0;
diff --git a/drivers/net/wireless/iwlegacy/iwl3945-base.c b/drivers/net/wireless/iwlegacy/iwl3945-base.c
index cc7ebce..5bcfaf5 100644
--- a/drivers/net/wireless/iwlegacy/iwl3945-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl3945-base.c
@@ -1811,7 +1811,7 @@ static int iwl3945_get_channels_for_scan(struct iwl_priv *priv,
 				     struct iwl3945_scan_channel *scan_ch,
 				     struct ieee80211_vif *vif)
 {
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	const struct ieee80211_supported_band *sband;
 	const struct iwl_channel_info *ch_info;
 	u16 passive_dwell = 0;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index e202a40..75badb1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1051,7 +1051,7 @@ static int iwl_get_channels_for_scan(struct iwl_priv *priv,
 				     u8 is_active, u8 n_probes,
 				     struct iwl_scan_channel *scan_ch)
 {
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	const struct ieee80211_supported_band *sband;
 	const struct iwl_channel_info *ch_info;
 	u16 passive_dwell = 0;
diff --git a/drivers/net/wireless/iwmc3200wifi/cfg80211.c b/drivers/net/wireless/iwmc3200wifi/cfg80211.c
index ed57e44..a9d1b44 100644
--- a/drivers/net/wireless/iwmc3200wifi/cfg80211.c
+++ b/drivers/net/wireless/iwmc3200wifi/cfg80211.c
@@ -408,7 +408,7 @@ static int iwm_cfg80211_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 				  struct cfg80211_ibss_params *params)
 {
 	struct iwm_priv *iwm = wiphy_to_iwm(wiphy);
-	struct ieee80211_channel *chan = params->channel;
+	const struct ieee80211_channel *chan = params->channel;
 
 	if (!test_bit(IWM_STATUS_READY, &iwm->status))
 		return -EIO;
@@ -549,7 +549,7 @@ static int iwm_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 				 struct cfg80211_connect_params *sme)
 {
 	struct iwm_priv *iwm = wiphy_to_iwm(wiphy);
-	struct ieee80211_channel *chan = sme->channel;
+	const struct ieee80211_channel *chan = sme->channel;
 	struct key_params key_param;
 	int ret;
 
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 5caa2ac..66d6b58 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -431,7 +431,7 @@ static int lbs_add_wpa_tlv(u8 *tlv, const u8 *ie, u8 ie_len)
 
 static int lbs_cfg_set_channel(struct wiphy *wiphy,
 	struct net_device *netdev,
-	struct ieee80211_channel *channel,
+	const struct ieee80211_channel *channel,
 	enum nl80211_channel_type channel_type)
 {
 	struct lbs_private *priv = wiphy_priv(wiphy);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index b99ae26..5508dc0 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -329,7 +329,7 @@ static int mwifiex_reg_notifier(struct wiphy *wiphy,
  */
 static int
 mwifiex_set_rf_channel(struct mwifiex_private *priv,
-		       struct ieee80211_channel *chan,
+		       const struct ieee80211_channel *chan,
 		       enum nl80211_channel_type channel_type)
 {
 	struct mwifiex_chan_freq_power cfp;
@@ -385,7 +385,7 @@ mwifiex_set_rf_channel(struct mwifiex_private *priv,
  */
 static int
 mwifiex_cfg80211_set_channel(struct wiphy *wiphy, struct net_device *dev,
-			     struct ieee80211_channel *chan,
+			     const struct ieee80211_channel *chan,
 			     enum nl80211_channel_type channel_type)
 {
 	struct mwifiex_private *priv = mwifiex_cfg80211_get_priv(wiphy);
@@ -898,7 +898,8 @@ static int mwifiex_inform_bss_from_scan_result(struct mwifiex_private *priv,
  */
 static int
 mwifiex_cfg80211_assoc(struct mwifiex_private *priv, size_t ssid_len, u8 *ssid,
-		       u8 *bssid, int mode, struct ieee80211_channel *channel,
+		       u8 *bssid, int mode,
+		       const struct ieee80211_channel *channel,
 		       struct cfg80211_connect_params *sme, bool privacy)
 {
 	struct mwifiex_802_11_ssid req_ssid;
@@ -1304,7 +1305,7 @@ mwifiex_cfg80211_results(struct work_struct *work)
 		container_of(work, struct mwifiex_private, cfg_workqueue);
 	struct mwifiex_user_scan_cfg *scan_req;
 	int ret = 0, i;
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 
 	if (priv->scan_request) {
 		scan_req = kzalloc(sizeof(struct mwifiex_user_scan_cfg),
diff --git a/drivers/net/wireless/orinoco/cfg.c b/drivers/net/wireless/orinoco/cfg.c
index 736bbb9..975c915 100644
--- a/drivers/net/wireless/orinoco/cfg.c
+++ b/drivers/net/wireless/orinoco/cfg.c
@@ -162,7 +162,7 @@ static int orinoco_scan(struct wiphy *wiphy, struct net_device *dev,
 
 static int orinoco_set_channel(struct wiphy *wiphy,
 			struct net_device *netdev,
-			struct ieee80211_channel *chan,
+			const struct ieee80211_channel *chan,
 			enum nl80211_channel_type channel_type)
 {
 	struct orinoco_private *priv = wiphy_priv(wiphy);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 518542b..c22d516 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -554,7 +554,8 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 static int rndis_leave_ibss(struct wiphy *wiphy, struct net_device *dev);
 
 static int rndis_set_channel(struct wiphy *wiphy, struct net_device *dev,
-	struct ieee80211_channel *chan, enum nl80211_channel_type channel_type);
+			     const struct ieee80211_channel *chan,
+			     enum nl80211_channel_type channel_type);
 
 static int rndis_add_key(struct wiphy *wiphy, struct net_device *netdev,
 			 u8 key_index, bool pairwise, const u8 *mac_addr,
@@ -2143,7 +2144,7 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 {
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
-	struct ieee80211_channel *channel = sme->channel;
+	const struct ieee80211_channel *channel = sme->channel;
 	struct ndis_80211_ssid ssid;
 	int pairwise = RNDIS_WLAN_ALG_NONE;
 	int groupwise = RNDIS_WLAN_ALG_NONE;
@@ -2280,7 +2281,7 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 {
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
-	struct ieee80211_channel *channel = params->channel;
+	const struct ieee80211_channel *channel = params->channel;
 	struct ndis_80211_ssid ssid;
 	enum nl80211_auth_type auth_type;
 	int ret, alg, length, chan = -1;
@@ -2388,7 +2389,7 @@ static int rndis_leave_ibss(struct wiphy *wiphy, struct net_device *dev)
 }
 
 static int rndis_set_channel(struct wiphy *wiphy, struct net_device *netdev,
-	struct ieee80211_channel *chan, enum nl80211_channel_type channel_type)
+	const struct ieee80211_channel *chan, enum nl80211_channel_type channel_type)
 {
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
diff --git a/drivers/net/wireless/wl1251/cmd.c b/drivers/net/wireless/wl1251/cmd.c
index 81f164b..ed5e62a 100644
--- a/drivers/net/wireless/wl1251/cmd.c
+++ b/drivers/net/wireless/wl1251/cmd.c
@@ -413,7 +413,7 @@ out:
 }
 
 int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
-		    struct ieee80211_channel *channels[],
+		    const struct ieee80211_channel *channels[],
 		    unsigned int n_channels, unsigned int n_probes)
 {
 	struct wl1251_cmd_scan *cmd;
diff --git a/drivers/net/wireless/wl1251/cmd.h b/drivers/net/wireless/wl1251/cmd.h
index 79ca527..f1ff4bf 100644
--- a/drivers/net/wireless/wl1251/cmd.h
+++ b/drivers/net/wireless/wl1251/cmd.h
@@ -44,7 +44,7 @@ int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
 int wl1251_cmd_template_set(struct wl1251 *wl, u16 cmd_id,
 			    void *buf, size_t buf_len);
 int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
-		    struct ieee80211_channel *channels[],
+		    const struct ieee80211_channel *channels[],
 		    unsigned int n_channels, unsigned int n_probes);
 int wl1251_cmd_trigger_scan_to(struct wl1251 *wl, u32 timeout);
 
-- 
1.7.5.rc3.dirty
