From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 2/3] nl80211: Fix checkpatch warnings about blank lines
Date: Sat, 28 May 2016 20:31:18 -0700
Message-ID: <c43ff6b2b17a64219f34abb9d88ba61b18ec4394.1464492195.git.kirtika.ruchandani@gmail.com>
References: <cover.1464492195.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34747 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbcE2Db1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2016 23:31:27 -0400
Content-Disposition: inline
In-Reply-To: <cover.1464492195.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following checkpatch.pl issues -
- Please don't use multiple blank lines
- Blank lines aren't necessary before a close brace
- Missing a blank line after declarations

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/nl80211.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 50a0de0..cd422bd 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -167,6 +167,7 @@ __cfg80211_rdev_from_attrs(struct net *netns, struct nlattr **attrs)
 
 	if (attrs[NL80211_ATTR_IFINDEX]) {
 		int ifindex = nla_get_u32(attrs[NL80211_ATTR_IFINDEX]);
+
 		netdev = __dev_get_by_index(netns, ifindex);
 		if (netdev) {
 			if (netdev->ieee80211_ptr)
@@ -730,6 +731,7 @@ static int nl80211_parse_key_new(struct nlattr *key, struct key_parse *k)
 
 	if (tb[NL80211_KEY_DEFAULT_TYPES]) {
 		struct nlattr *kdt[NUM_NL80211_KEY_DEFAULT_TYPES];
+
 		err = nla_parse_nested(kdt, NUM_NL80211_KEY_DEFAULT_TYPES - 1,
 				       tb[NL80211_KEY_DEFAULT_TYPES],
 				       nl80211_key_default_policy);
@@ -1381,6 +1383,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		    rdev->ops->get_antenna) {
 			u32 tx_ant = 0, rx_ant = 0;
 			int res;
+
 			res = rdev_get_antenna(rdev, &tx_ant, &rx_ant);
 			if (!res) {
 				if (nla_put_u32(msg,
@@ -2111,7 +2114,6 @@ static int nl80211_set_wds_peer(struct sk_buff *skb, struct genl_info *info)
 	return rdev_set_wds_peer(rdev, dev, bssid);
 }
 
-
 static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev;
@@ -2244,6 +2246,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_WIPHY_ANTENNA_TX] &&
 	    info->attrs[NL80211_ATTR_WIPHY_ANTENNA_RX]) {
 		u32 tx_ant, rx_ant;
+
 		if ((!rdev->wiphy.available_antennas_tx &&
 		     !rdev->wiphy.available_antennas_rx) ||
 		    !rdev->ops->set_antenna)
@@ -2910,6 +2913,7 @@ static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
 	pairwise = !!mac_addr;
 	if (info->attrs[NL80211_ATTR_KEY_TYPE]) {
 		u32 kt = nla_get_u32(info->attrs[NL80211_ATTR_KEY_TYPE]);
+
 		if (kt >= NUM_NL80211_KEYTYPES)
 			return -EINVAL;
 		if (kt != NL80211_KEYTYPE_GROUP &&
@@ -3949,7 +3953,6 @@ static int nl80211_dump_station(struct sk_buff *skb,
 		sta_idx++;
 	}
 
-
  out:
 	cb->args[2] = sta_idx;
 	err = skb->len;
@@ -4742,7 +4745,6 @@ static int nl80211_dump_mpath(struct sk_buff *skb,
 		path_idx++;
 	}
 
-
  out:
 	cb->args[2] = path_idx;
 	err = skb->len;
@@ -5032,7 +5034,6 @@ static int nl80211_req_set_reg(struct sk_buff *skb, struct genl_info *info)
 	enum nl80211_user_reg_hint_type user_reg_hint_type;
 	u32 owner_nlportid;
 
-
 	/* You should only get this when cfg80211 hasn't yet initialized
 	 * completely when built-in to the kernel right between the time
 	 * window between nl80211_init() and regulatory_init(), if that is
@@ -5240,7 +5241,6 @@ do {									    \
 	}								    \
 } while (0)
 
-
 	if (!info->attrs[NL80211_ATTR_MESH_CONFIG])
 		return -EINVAL;
 	if (nla_parse_nested(tb, NL80211_MESHCONF_ATTR_MAX,
@@ -5388,7 +5388,6 @@ static int nl80211_parse_mesh_setup(struct genl_info *info,
 		 IEEE80211_PATH_METRIC_VENDOR :
 		 IEEE80211_PATH_METRIC_AIRTIME;
 
-
 	if (tb[NL80211_MESH_SETUP_IE]) {
 		struct nlattr *ieattr =
 			tb[NL80211_MESH_SETUP_IE];
@@ -6009,6 +6008,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 		/* all channels */
 		for (band = 0; band < NUM_NL80211_BANDS; band++) {
 			int j;
+
 			if (!wiphy->bands[band])
 				continue;
 			for (j = 0; j < wiphy->bands[band]->n_channels; j++) {
@@ -6412,6 +6412,7 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 		/* all channels */
 		for (band = 0; band < NUM_NL80211_BANDS; band++) {
 			int j;
+
 			if (!wiphy->bands[band])
 				continue;
 			for (j = 0; j < wiphy->bands[band]->n_channels; j++) {
@@ -7174,6 +7175,7 @@ static int nl80211_authenticate(struct sk_buff *skb, struct genl_info *info)
 	if (key.idx >= 0) {
 		int i;
 		bool ok = false;
+
 		for (i = 0; i < rdev->wiphy.n_cipher_suites; i++) {
 			if (key.p.cipher == rdev->wiphy.cipher_suites[i]) {
 				ok = true;
@@ -7251,6 +7253,7 @@ static int nl80211_crypto_settings(struct cfg80211_registered_device *rdev,
 
 	if (info->attrs[NL80211_ATTR_CONTROL_PORT_ETHERTYPE]) {
 		u16 proto;
+
 		proto = nla_get_u16(
 			info->attrs[NL80211_ATTR_CONTROL_PORT_ETHERTYPE]);
 		settings->control_port_ethertype = cpu_to_be16(proto);
@@ -8402,6 +8405,7 @@ static u32 rateset_to_mask(struct ieee80211_supported_band *sband,
 	for (i = 0; i < rates_len; i++) {
 		int rate = (rates[i] & 0x7f) * 5;
 		int ridx;
+
 		for (ridx = 0; ridx < sband->n_bitrates; ridx++) {
 			struct ieee80211_rate *srate =
 				&sband->bitrates[ridx];
@@ -8708,7 +8712,6 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 		if (params.wait < NL80211_MIN_REMAIN_ON_CHANNEL_TIME ||
 		    params.wait > rdev->wiphy.max_remain_on_channel_duration)
 			return -EINVAL;
-
 	}
 
 	params.offchan = info->attrs[NL80211_ATTR_OFFCHANNEL_TX_OK];
@@ -10555,7 +10558,6 @@ int cfg80211_vendor_cmd_reply(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(cfg80211_vendor_cmd_reply);
 
-
 static int nl80211_set_qos_map(struct sk_buff *skb,
 			       struct genl_info *info)
 {
@@ -12089,7 +12091,6 @@ void nl80211_send_connect_result(struct cfg80211_registered_device *rdev,
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
 	nlmsg_free(msg);
-
 }
 
 void nl80211_send_roamed(struct cfg80211_registered_device *rdev,
@@ -12128,7 +12129,6 @@ void nl80211_send_roamed(struct cfg80211_registered_device *rdev,
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
 	nlmsg_free(msg);
-
 }
 
 void nl80211_send_disconnected(struct cfg80211_registered_device *rdev,
@@ -12166,7 +12166,6 @@ void nl80211_send_disconnected(struct cfg80211_registered_device *rdev,
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
 	nlmsg_free(msg);
-
 }
 
 void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
@@ -13506,7 +13505,6 @@ void cfg80211_crit_proto_stopped(struct wireless_dev *wdev, gfp_t gfp)
 	if (hdr)
 		genlmsg_cancel(msg, hdr);
 	nlmsg_free(msg);
-
 }
 EXPORT_SYMBOL(cfg80211_crit_proto_stopped);
 
-- 
2.8.0.rc3.226.g39d4020
