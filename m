From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] wireless: Make struct ieee80211_channel const where possible
Date: Thu, 28 Apr 2011 22:25:07 -0700
Message-ID: <b953f08a496209fe0fb69166c5175ff270b7efc5.1304054543.git.joe@perches.com>
References: <cover.1304054543.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304054543.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Useful for declarations of static const.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/cfg80211.h  |   34 +++++++++++++++++-----------------
 net/wireless/chan.c     |   10 +++++-----
 net/wireless/core.h     |   14 ++++++++------
 net/wireless/debugfs.c  |    2 +-
 net/wireless/ibss.c     |    6 +++---
 net/wireless/mlme.c     |   15 ++++++++-------
 net/wireless/nl80211.c  |   31 ++++++++++++++++---------------
 net/wireless/nl80211.h  |    9 +++++----
 net/wireless/reg.c      |   11 ++++++-----
 net/wireless/reg.h      |    4 ++--
 net/wireless/scan.c     |    6 +++---
 net/wireless/wext-sme.c |    2 +-
 12 files changed, 75 insertions(+), 69 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index d30eada..0a14bd9 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -789,7 +789,7 @@ struct cfg80211_scan_request {
 	bool aborted;
 
 	/* keep last */
-	struct ieee80211_channel *channels[0];
+	const struct ieee80211_channel *channels[0];
 };
 
 /**
@@ -830,7 +830,7 @@ enum cfg80211_signal_type {
  * @priv: private area for driver use, has at least wiphy->bss_priv_size bytes
  */
 struct cfg80211_bss {
-	struct ieee80211_channel *channel;
+	const struct ieee80211_channel *channel;
 
 	u8 bssid[ETH_ALEN];
 	u64 tsf;
@@ -1002,7 +1002,7 @@ struct cfg80211_disassoc_request {
 struct cfg80211_ibss_params {
 	u8 *ssid;
 	u8 *bssid;
-	struct ieee80211_channel *channel;
+	const struct ieee80211_channel *channel;
 	u8 *ie;
 	u8 ssid_len, ie_len;
 	u16 beacon_interval;
@@ -1034,7 +1034,7 @@ struct cfg80211_ibss_params {
  * @key: WEP key for shared key authentication
  */
 struct cfg80211_connect_params {
-	struct ieee80211_channel *channel;
+	const struct ieee80211_channel *channel;
 	u8 *bssid;
 	u8 *ssid;
 	size_t ssid_len;
@@ -1322,7 +1322,7 @@ struct cfg80211_ops {
 				  struct ieee80211_txq_params *params);
 
 	int	(*set_channel)(struct wiphy *wiphy, struct net_device *dev,
-			       struct ieee80211_channel *chan,
+			       const struct ieee80211_channel *chan,
 			       enum nl80211_channel_type channel_type);
 
 	int	(*scan)(struct wiphy *wiphy, struct net_device *dev,
@@ -1379,7 +1379,7 @@ struct cfg80211_ops {
 
 	int	(*remain_on_channel)(struct wiphy *wiphy,
 				     struct net_device *dev,
-				     struct ieee80211_channel *chan,
+				     const struct ieee80211_channel *chan,
 				     enum nl80211_channel_type channel_type,
 				     unsigned int duration,
 				     u64 *cookie);
@@ -1388,10 +1388,10 @@ struct cfg80211_ops {
 					    u64 cookie);
 
 	int	(*mgmt_tx)(struct wiphy *wiphy, struct net_device *dev,
-			  struct ieee80211_channel *chan, bool offchan,
-			  enum nl80211_channel_type channel_type,
-			  bool channel_type_valid, unsigned int wait,
-			  const u8 *buf, size_t len, u64 *cookie);
+			   const struct ieee80211_channel *chan, bool offchan,
+			   enum nl80211_channel_type channel_type,
+			   bool channel_type_valid, unsigned int wait,
+			   const u8 *buf, size_t len, u64 *cookie);
 	int	(*mgmt_tx_cancel_wait)(struct wiphy *wiphy,
 				       struct net_device *dev,
 				       u64 cookie);
@@ -1804,7 +1804,7 @@ struct wireless_dev {
 	struct cfg80211_internal_bss *authtry_bsses[MAX_AUTH_BSSES];
 	struct cfg80211_internal_bss *auth_bsses[MAX_AUTH_BSSES];
 	struct cfg80211_internal_bss *current_bss; /* associated / joined */
-	struct ieee80211_channel *channel;
+	const struct ieee80211_channel *channel;
 
 	bool ps;
 	int ps_timeout;
@@ -2294,20 +2294,20 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
  */
 struct cfg80211_bss*
 cfg80211_inform_bss(struct wiphy *wiphy,
-		    struct ieee80211_channel *channel,
+		    const struct ieee80211_channel *channel,
 		    const u8 *bssid,
 		    u64 timestamp, u16 capability, u16 beacon_interval,
 		    const u8 *ie, size_t ielen,
 		    s32 signal, gfp_t gfp);
 
 struct cfg80211_bss *cfg80211_get_bss(struct wiphy *wiphy,
-				      struct ieee80211_channel *channel,
+				      const struct ieee80211_channel *channel,
 				      const u8 *bssid,
 				      const u8 *ssid, size_t ssid_len,
 				      u16 capa_mask, u16 capa_val);
 static inline struct cfg80211_bss *
 cfg80211_get_ibss(struct wiphy *wiphy,
-		  struct ieee80211_channel *channel,
+		  const struct ieee80211_channel *channel,
 		  const u8 *ssid, size_t ssid_len)
 {
 	return cfg80211_get_bss(wiphy, channel, NULL, ssid, ssid_len,
@@ -2315,7 +2315,7 @@ cfg80211_get_ibss(struct wiphy *wiphy,
 }
 
 struct cfg80211_bss *cfg80211_get_mesh(struct wiphy *wiphy,
-				       struct ieee80211_channel *channel,
+				       const struct ieee80211_channel *channel,
 				       const u8 *meshid, size_t meshidlen,
 				       const u8 *meshcfg);
 void cfg80211_put_bss(struct cfg80211_bss *bss);
@@ -2695,7 +2695,7 @@ void cfg80211_disconnected(struct net_device *dev, u16 reason,
  * @gfp: allocation flags
  */
 void cfg80211_ready_on_channel(struct net_device *dev, u64 cookie,
-			       struct ieee80211_channel *chan,
+			       const struct ieee80211_channel *chan,
 			       enum nl80211_channel_type channel_type,
 			       unsigned int duration, gfp_t gfp);
 
@@ -2709,7 +2709,7 @@ void cfg80211_ready_on_channel(struct net_device *dev, u64 cookie,
  */
 void cfg80211_remain_on_channel_expired(struct net_device *dev,
 					u64 cookie,
-					struct ieee80211_channel *chan,
+					const struct ieee80211_channel *chan,
 					enum nl80211_channel_type channel_type,
 					gfp_t gfp);
 
diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index 17cd0c0..d2fcf62 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -9,11 +9,11 @@
 #include <net/cfg80211.h>
 #include "core.h"
 
-struct ieee80211_channel *
+const struct ieee80211_channel *
 rdev_freq_to_chan(struct cfg80211_registered_device *rdev,
 		  int freq, enum nl80211_channel_type channel_type)
 {
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	struct ieee80211_sta_ht_cap *ht_cap;
 
 	chan = ieee80211_get_channel(&rdev->wiphy, freq);
@@ -45,10 +45,10 @@ rdev_freq_to_chan(struct cfg80211_registered_device *rdev,
 }
 
 static bool can_beacon_sec_chan(struct wiphy *wiphy,
-				struct ieee80211_channel *chan,
+				const struct ieee80211_channel *chan,
 				enum nl80211_channel_type channel_type)
 {
-	struct ieee80211_channel *sec_chan;
+	const struct ieee80211_channel *sec_chan;
 	int diff;
 
 	switch (channel_type) {
@@ -80,7 +80,7 @@ int cfg80211_set_freq(struct cfg80211_registered_device *rdev,
 		      struct wireless_dev *wdev, int freq,
 		      enum nl80211_channel_type channel_type)
 {
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	int result;
 
 	if (wdev && wdev->iftype == NL80211_IFTYPE_MONITOR)
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 26a0a08..48c79d2 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -302,7 +302,7 @@ int cfg80211_leave_mesh(struct cfg80211_registered_device *rdev,
 /* MLME */
 int __cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 			 struct net_device *dev,
-			 struct ieee80211_channel *chan,
+			 const struct ieee80211_channel *chan,
 			 enum nl80211_auth_type auth_type,
 			 const u8 *bssid,
 			 const u8 *ssid, int ssid_len,
@@ -310,7 +310,8 @@ int __cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 			 const u8 *key, int key_len, int key_idx,
 			 bool local_state_change);
 int cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
-		       struct net_device *dev, struct ieee80211_channel *chan,
+		       struct net_device *dev,
+		       const struct ieee80211_channel *chan,
 		       enum nl80211_auth_type auth_type, const u8 *bssid,
 		       const u8 *ssid, int ssid_len,
 		       const u8 *ie, int ie_len,
@@ -318,13 +319,14 @@ int cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 		       bool local_state_change);
 int __cfg80211_mlme_assoc(struct cfg80211_registered_device *rdev,
 			  struct net_device *dev,
-			  struct ieee80211_channel *chan,
+			  const struct ieee80211_channel *chan,
 			  const u8 *bssid, const u8 *prev_bssid,
 			  const u8 *ssid, int ssid_len,
 			  const u8 *ie, int ie_len, bool use_mfp,
 			  struct cfg80211_crypto_settings *crypt);
 int cfg80211_mlme_assoc(struct cfg80211_registered_device *rdev,
-			struct net_device *dev, struct ieee80211_channel *chan,
+			struct net_device *dev,
+			const struct ieee80211_channel *chan,
 			const u8 *bssid, const u8 *prev_bssid,
 			const u8 *ssid, int ssid_len,
 			const u8 *ie, int ie_len, bool use_mfp,
@@ -355,7 +357,7 @@ void cfg80211_mlme_unregister_socket(struct wireless_dev *wdev, u32 nlpid);
 void cfg80211_mlme_purge_registrations(struct wireless_dev *wdev);
 int cfg80211_mlme_mgmt_tx(struct cfg80211_registered_device *rdev,
 			  struct net_device *dev,
-			  struct ieee80211_channel *chan, bool offchan,
+			  const struct ieee80211_channel *chan, bool offchan,
 			  enum nl80211_channel_type channel_type,
 			  bool channel_type_valid, unsigned int wait,
 			  const u8 *buf, size_t len, u64 *cookie);
@@ -403,7 +405,7 @@ int cfg80211_change_iface(struct cfg80211_registered_device *rdev,
 			  u32 *flags, struct vif_params *params);
 void cfg80211_process_rdev_events(struct cfg80211_registered_device *rdev);
 
-struct ieee80211_channel *
+const struct ieee80211_channel *
 rdev_freq_to_chan(struct cfg80211_registered_device *rdev,
 		  int freq, enum nl80211_channel_type channel_type);
 int cfg80211_set_freq(struct cfg80211_registered_device *rdev,
diff --git a/net/wireless/debugfs.c b/net/wireless/debugfs.c
index 39765bc..9bb06a2 100644
--- a/net/wireless/debugfs.c
+++ b/net/wireless/debugfs.c
@@ -46,7 +46,7 @@ DEBUGFS_READONLY_FILE(short_retry_limit, 20, "%d",
 DEBUGFS_READONLY_FILE(long_retry_limit, 20, "%d",
 		      wiphy->retry_long);
 
-static int ht_print_chan(struct ieee80211_channel *chan,
+static int ht_print_chan(const struct ieee80211_channel *chan,
 			 char *buf, int buf_size, int offset)
 {
 	if (WARN_ON(offset > buf_size))
diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index f33fbb7..92a16a7 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -235,7 +235,7 @@ int cfg80211_ibss_wext_join(struct cfg80211_registered_device *rdev,
 	if (!wdev->wext.ibss.channel) {
 		for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
 			struct ieee80211_supported_band *sband;
-			struct ieee80211_channel *chan;
+			const struct ieee80211_channel *chan;
 
 			sband = rdev->wiphy.bands[band];
 			if (!sband)
@@ -294,7 +294,7 @@ int cfg80211_ibss_wext_siwfreq(struct net_device *dev,
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
-	struct ieee80211_channel *chan = NULL;
+	const struct ieee80211_channel *chan = NULL;
 	int err, freq;
 
 	/* call only for ibss! */
@@ -351,7 +351,7 @@ int cfg80211_ibss_wext_giwfreq(struct net_device *dev,
 			       struct iw_freq *freq, char *extra)
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
-	struct ieee80211_channel *chan = NULL;
+	const struct ieee80211_channel *chan = NULL;
 
 	/* call only for ibss! */
 	if (WARN_ON(wdev->iftype != NL80211_IFTYPE_ADHOC))
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 16881fe..b5fefd0 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -396,7 +396,7 @@ EXPORT_SYMBOL(cfg80211_michael_mic_failure);
 /* some MLME handling for userspace SME */
 int __cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 			 struct net_device *dev,
-			 struct ieee80211_channel *chan,
+			 const struct ieee80211_channel *chan,
 			 enum nl80211_auth_type auth_type,
 			 const u8 *bssid,
 			 const u8 *ssid, int ssid_len,
@@ -481,7 +481,8 @@ int __cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 }
 
 int cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
-		       struct net_device *dev, struct ieee80211_channel *chan,
+		       struct net_device *dev,
+		       const struct ieee80211_channel *chan,
 		       enum nl80211_auth_type auth_type, const u8 *bssid,
 		       const u8 *ssid, int ssid_len,
 		       const u8 *ie, int ie_len,
@@ -501,7 +502,7 @@ int cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 
 int __cfg80211_mlme_assoc(struct cfg80211_registered_device *rdev,
 			  struct net_device *dev,
-			  struct ieee80211_channel *chan,
+			  const struct ieee80211_channel *chan,
 			  const u8 *bssid, const u8 *prev_bssid,
 			  const u8 *ssid, int ssid_len,
 			  const u8 *ie, int ie_len, bool use_mfp,
@@ -568,7 +569,7 @@ int __cfg80211_mlme_assoc(struct cfg80211_registered_device *rdev,
 
 int cfg80211_mlme_assoc(struct cfg80211_registered_device *rdev,
 			struct net_device *dev,
-			struct ieee80211_channel *chan,
+			const struct ieee80211_channel *chan,
 			const u8 *bssid, const u8 *prev_bssid,
 			const u8 *ssid, int ssid_len,
 			const u8 *ie, int ie_len, bool use_mfp,
@@ -734,7 +735,7 @@ void cfg80211_mlme_down(struct cfg80211_registered_device *rdev,
 }
 
 void cfg80211_ready_on_channel(struct net_device *dev, u64 cookie,
-			       struct ieee80211_channel *chan,
+			       const struct ieee80211_channel *chan,
 			       enum nl80211_channel_type channel_type,
 			       unsigned int duration, gfp_t gfp)
 {
@@ -748,7 +749,7 @@ EXPORT_SYMBOL(cfg80211_ready_on_channel);
 
 void cfg80211_remain_on_channel_expired(struct net_device *dev,
 					u64 cookie,
-					struct ieee80211_channel *chan,
+					const struct ieee80211_channel *chan,
 					enum nl80211_channel_type channel_type,
 					gfp_t gfp)
 {
@@ -895,7 +896,7 @@ void cfg80211_mlme_purge_registrations(struct wireless_dev *wdev)
 
 int cfg80211_mlme_mgmt_tx(struct cfg80211_registered_device *rdev,
 			  struct net_device *dev,
-			  struct ieee80211_channel *chan, bool offchan,
+			  const struct ieee80211_channel *chan, bool offchan,
 			  enum nl80211_channel_type channel_type,
 			  bool channel_type_valid, unsigned int wait,
 			  const u8 *buf, size_t len, u64 *cookie)
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 0efa7fd..fcb1c91 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -294,7 +294,7 @@ static inline void *nl80211hdr_put(struct sk_buff *skb, u32 pid, u32 seq,
 }
 
 static int nl80211_msg_put_channel(struct sk_buff *msg,
-				   struct ieee80211_channel *chan)
+				   const struct ieee80211_channel *chan)
 {
 	NLA_PUT_U32(msg, NL80211_FREQUENCY_ATTR_FREQ,
 		    chan->center_freq);
@@ -561,7 +561,7 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u32 pid, u32 seq, int flags,
 	struct nlattr *nl_modes;
 	struct nlattr *nl_cmds;
 	enum ieee80211_band band;
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	struct ieee80211_rate *rate;
 	int i;
 	u16 ifmodes = dev->wiphy.interface_modes;
@@ -3170,7 +3170,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_scan_request *request;
 	struct cfg80211_ssid *ssid;
-	struct ieee80211_channel *channel;
+	const struct ieee80211_channel *channel;
 	struct nlattr *attr;
 	struct wiphy *wiphy;
 	int err, tmp, n_ssids = 0, n_channels, i;
@@ -3237,7 +3237,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_SCAN_FREQUENCIES]) {
 		/* user specified, bail out if channel not found */
 		nla_for_each_nested(attr, info->attrs[NL80211_ATTR_SCAN_FREQUENCIES], tmp) {
-			struct ieee80211_channel *chan;
+			const struct ieee80211_channel *chan;
 
 			chan = ieee80211_get_channel(wiphy, nla_get_u32(attr));
 
@@ -3260,7 +3260,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 			if (!wiphy->bands[band])
 				continue;
 			for (j = 0; j < wiphy->bands[band]->n_channels; j++) {
-				struct ieee80211_channel *chan;
+				const struct ieee80211_channel *chan;
 
 				chan = &wiphy->bands[band]->channels[j];
 
@@ -3572,7 +3572,7 @@ static int nl80211_authenticate(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct net_device *dev = info->user_ptr[1];
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	const u8 *bssid, *ssid, *ie = NULL;
 	int err, ssid_len, ie_len = 0;
 	enum nl80211_auth_type auth_type;
@@ -3745,7 +3745,7 @@ static int nl80211_associate(struct sk_buff *skb, struct genl_info *info)
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_crypto_settings crypto;
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	const u8 *bssid, *ssid, *ie = NULL, *prev_bssid = NULL;
 	int err, ssid_len, ie_len = 0;
 	bool use_mfp = false;
@@ -4322,7 +4322,7 @@ static int nl80211_remain_on_channel(struct sk_buff *skb,
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct net_device *dev = info->user_ptr[1];
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	struct sk_buff *msg;
 	void *hdr;
 	u64 cookie;
@@ -4527,7 +4527,7 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct net_device *dev = info->user_ptr[1];
-	struct ieee80211_channel *chan;
+	const struct ieee80211_channel *chan;
 	enum nl80211_channel_type channel_type = NL80211_CHAN_NO_HT;
 	bool channel_type_valid = false;
 	u32 freq;
@@ -5900,9 +5900,10 @@ void nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
 	nlmsg_free(msg);
 }
 
-void nl80211_send_beacon_hint_event(struct wiphy *wiphy,
-				    struct ieee80211_channel *channel_before,
-				    struct ieee80211_channel *channel_after)
+void
+nl80211_send_beacon_hint_event(struct wiphy *wiphy,
+			       const struct ieee80211_channel *channel_before,
+			       const struct ieee80211_channel *channel_after)
 {
 	struct sk_buff *msg;
 	void *hdr;
@@ -5960,7 +5961,7 @@ nla_put_failure:
 static void nl80211_send_remain_on_chan_event(
 	int cmd, struct cfg80211_registered_device *rdev,
 	struct net_device *netdev, u64 cookie,
-	struct ieee80211_channel *chan,
+	const struct ieee80211_channel *chan,
 	enum nl80211_channel_type channel_type,
 	unsigned int duration, gfp_t gfp)
 {
@@ -6002,7 +6003,7 @@ static void nl80211_send_remain_on_chan_event(
 
 void nl80211_send_remain_on_channel(struct cfg80211_registered_device *rdev,
 				    struct net_device *netdev, u64 cookie,
-				    struct ieee80211_channel *chan,
+				    const struct ieee80211_channel *chan,
 				    enum nl80211_channel_type channel_type,
 				    unsigned int duration, gfp_t gfp)
 {
@@ -6013,7 +6014,7 @@ void nl80211_send_remain_on_channel(struct cfg80211_registered_device *rdev,
 
 void nl80211_send_remain_on_channel_cancel(
 	struct cfg80211_registered_device *rdev, struct net_device *netdev,
-	u64 cookie, struct ieee80211_channel *chan,
+	u64 cookie, const struct ieee80211_channel *chan,
 	enum nl80211_channel_type channel_type, gfp_t gfp)
 {
 	nl80211_send_remain_on_chan_event(NL80211_CMD_CANCEL_REMAIN_ON_CHANNEL,
diff --git a/net/wireless/nl80211.h b/net/wireless/nl80211.h
index f2af695..3039286 100644
--- a/net/wireless/nl80211.h
+++ b/net/wireless/nl80211.h
@@ -62,8 +62,8 @@ nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
 
 void
 nl80211_send_beacon_hint_event(struct wiphy *wiphy,
-			       struct ieee80211_channel *channel_before,
-			       struct ieee80211_channel *channel_after);
+			       const struct ieee80211_channel *channel_before,
+			       const struct ieee80211_channel *channel_after);
 
 void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 			     struct net_device *netdev, const u8 *bssid,
@@ -72,12 +72,13 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 void nl80211_send_remain_on_channel(struct cfg80211_registered_device *rdev,
 				    struct net_device *netdev,
 				    u64 cookie,
-				    struct ieee80211_channel *chan,
+				    const struct ieee80211_channel *chan,
 				    enum nl80211_channel_type channel_type,
 				    unsigned int duration, gfp_t gfp);
 void nl80211_send_remain_on_channel_cancel(
 	struct cfg80211_registered_device *rdev, struct net_device *netdev,
-	u64 cookie, struct ieee80211_channel *chan,
+	u64 cookie,
+	const struct ieee80211_channel *chan,
 	enum nl80211_channel_type channel_type, gfp_t gfp);
 
 void nl80211_send_sta_event(struct cfg80211_registered_device *rdev,
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 1613080..2768846 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -734,7 +734,7 @@ static const char *reg_initiator_name(enum nl80211_reg_initiator initiator)
 	}
 }
 
-static void chan_reg_rule_print_dbg(struct ieee80211_channel *chan,
+static void chan_reg_rule_print_dbg(const struct ieee80211_channel *chan,
 				    u32 desired_bw_khz,
 				    const struct ieee80211_reg_rule *reg_rule)
 {
@@ -762,7 +762,7 @@ static void chan_reg_rule_print_dbg(struct ieee80211_channel *chan,
 		      power_rule->max_eirp);
 }
 #else
-static void chan_reg_rule_print_dbg(struct ieee80211_channel *chan,
+static void chan_reg_rule_print_dbg(const struct ieee80211_channel *chan,
 				    u32 desired_bw_khz,
 				    const struct ieee80211_reg_rule *reg_rule)
 {
@@ -1034,7 +1034,7 @@ static void reg_process_beacons(struct wiphy *wiphy)
 	wiphy_update_beacon_reg(wiphy);
 }
 
-static bool is_ht40_not_allowed(struct ieee80211_channel *chan)
+static bool is_ht40_not_allowed(const struct ieee80211_channel *chan)
 {
 	if (!chan)
 		return true;
@@ -1052,7 +1052,8 @@ static void reg_process_ht_flags_channel(struct wiphy *wiphy,
 {
 	struct ieee80211_supported_band *sband;
 	struct ieee80211_channel *channel;
-	struct ieee80211_channel *channel_before = NULL, *channel_after = NULL;
+	struct ieee80211_channel *channel_before = NULL;
+	struct ieee80211_channel *channel_after = NULL;
 	unsigned int i;
 
 	assert_cfg80211_lock();
@@ -1865,7 +1866,7 @@ static bool freq_is_chan_12_13_14(u16 freq)
 }
 
 int regulatory_hint_found_beacon(struct wiphy *wiphy,
-				 struct ieee80211_channel *beacon_chan,
+				 const struct ieee80211_channel *beacon_chan,
 				 gfp_t gfp)
 {
 	struct reg_beacon *reg_beacon;
diff --git a/net/wireless/reg.h b/net/wireless/reg.h
index b67d1c3..2a4cf5c 100644
--- a/net/wireless/reg.h
+++ b/net/wireless/reg.h
@@ -35,8 +35,8 @@ int set_regdom(const struct ieee80211_regdomain *rd);
  * set the wiphy->disable_beacon_hints to true.
  */
 int regulatory_hint_found_beacon(struct wiphy *wiphy,
-					struct ieee80211_channel *beacon_chan,
-					gfp_t gfp);
+				 const struct ieee80211_channel *beacon_chan,
+				 gfp_t gfp);
 
 /**
  * regulatory_hint_11d - hints a country IE as a regulatory domain
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index fbf6f33..756c8e7 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -275,7 +275,7 @@ static int cmp_bss(struct cfg80211_bss *a,
 }
 
 struct cfg80211_bss *cfg80211_get_bss(struct wiphy *wiphy,
-				      struct ieee80211_channel *channel,
+				      const struct ieee80211_channel *channel,
 				      const u8 *bssid,
 				      const u8 *ssid, size_t ssid_len,
 				      u16 capa_mask, u16 capa_val)
@@ -310,7 +310,7 @@ struct cfg80211_bss *cfg80211_get_bss(struct wiphy *wiphy,
 EXPORT_SYMBOL(cfg80211_get_bss);
 
 struct cfg80211_bss *cfg80211_get_mesh(struct wiphy *wiphy,
-				       struct ieee80211_channel *channel,
+				       const struct ieee80211_channel *channel,
 				       const u8 *meshid, size_t meshidlen,
 				       const u8 *meshcfg)
 {
@@ -524,7 +524,7 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 
 struct cfg80211_bss*
 cfg80211_inform_bss(struct wiphy *wiphy,
-		    struct ieee80211_channel *channel,
+		    const struct ieee80211_channel *channel,
 		    const u8 *bssid,
 		    u64 timestamp, u16 capability, u16 beacon_interval,
 		    const u8 *ie, size_t ielen,
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index 6fffe62..357c9f7 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -125,7 +125,7 @@ int cfg80211_mgd_wext_giwfreq(struct net_device *dev,
 			      struct iw_freq *freq, char *extra)
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
-	struct ieee80211_channel *chan = NULL;
+	const struct ieee80211_channel *chan = NULL;
 
 	/* call only for station! */
 	if (WARN_ON(wdev->iftype != NL80211_IFTYPE_STATION))
-- 
1.7.5.rc3.dirty
