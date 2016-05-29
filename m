From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 3/3] nl80211:  Various checkpatch.pl fixes
Date: Sat, 28 May 2016 20:31:39 -0700
Message-ID: <5c2861995f05d456b3ce16e29ceae7e578b1456f.1464492195.git.kirtika.ruchandani@gmail.com>
References: <cover.1464492195.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34772 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbcE2Dbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2016 23:31:47 -0400
Content-Disposition: inline
In-Reply-To: <cover.1464492195.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following checkpatch.pl issues -
- space preferred around that <operator>
- no space needed after cast.
- braces {} should be used on all arms of this statement
- Alignment should match open parenthesis
- suspect code indent for conditional statements
- Statements should start on a tabstop
- multiple assignments should be avoided
- prefer ether_addr_copy over memcpy
- correct spelling - 'implementation'
- comparison to NULL could be written as !foo
- prefer kcalloc over kzalloc with multiply

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/nl80211.c | 152 ++++++++++++++++++++++++++-----------------------
 1 file changed, 82 insertions(+), 70 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index cd422bd..9f7eb16 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -39,10 +39,10 @@ static void nl80211_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
 
 /* the netlink family */
 static struct genl_family nl80211_fam = {
-	.id = GENL_ID_GENERATE,		/* don't bother with a hardcoded ID */
-	.name = NL80211_GENL_NAME,	/* have users key off the name instead */
-	.hdrsize = 0,			/* no private header */
-	.version = 1,			/* no particular meaning now */
+	.id = GENL_ID_GENERATE,	    /* don't bother with a hardcoded ID */
+	.name = NL80211_GENL_NAME,  /* have users key off the name instead */
+	.hdrsize = 0,		    /* no private header */
+	.version = 1,		    /* no particular meaning now */
 	.maxattr = NL80211_ATTR_MAX,
 	.netnsok = true,
 	.pre_doit = nl80211_pre_doit,
@@ -213,7 +213,7 @@ cfg80211_get_dev_from_info(struct net *netns, struct genl_info *info)
 static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
-				      .len = 20-1 },
+				      .len = 20 - 1 },
 	[NL80211_ATTR_WIPHY_TXQ_PARAMS] = { .type = NLA_NESTED },
 
 	[NL80211_ATTR_WIPHY_FREQ] = { .type = NLA_U32 },
@@ -231,7 +231,7 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 
 	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
 	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
-	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
+	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
 
 	[NL80211_ATTR_MAC] = { .len = ETH_ALEN },
 	[NL80211_ATTR_PREV_BSSID] = { .len = ETH_ALEN },
@@ -870,8 +870,9 @@ nl80211_parse_connkeys(struct cfg80211_registered_device *rdev,
 			result->def = parse.idx;
 			if (!parse.def_uni || !parse.def_multi)
 				goto error;
-		} else if (parse.defmgmt)
+		} else if (parse.defmgmt) {
 			goto error;
+		}
 		err = cfg80211_validate_key_settings(rdev, &parse.p,
 						     parse.idx, false, NULL);
 		if (err)
@@ -927,7 +928,7 @@ static struct ieee80211_channel *nl80211_get_valid_chan(struct wiphy *wiphy,
 {
 	struct ieee80211_channel *chan;
 
-	if (tb == NULL)
+	if (!tb)
 		return NULL;
 	chan = ieee80211_get_channel(wiphy, nla_get_u32(tb));
 	if (!chan || chan->flags & IEEE80211_CHAN_DISABLED)
@@ -966,7 +967,7 @@ static int nl80211_put_iface_combinations(struct wiphy *wiphy,
 	int i, j;
 
 	nl_combis = nla_nest_start(msg,
-				NL80211_ATTR_INTERFACE_COMBINATIONS);
+				   NL80211_ATTR_INTERFACE_COMBINATIONS);
 	if (!nl_combis)
 		goto nla_put_failure;
 
@@ -1011,9 +1012,9 @@ static int nl80211_put_iface_combinations(struct wiphy *wiphy,
 			goto nla_put_failure;
 		if (large &&
 		    (nla_put_u32(msg, NL80211_IFACE_COMB_RADAR_DETECT_WIDTHS,
-				c->radar_detect_widths) ||
+				 c->radar_detect_widths) ||
 		     nla_put_u32(msg, NL80211_IFACE_COMB_RADAR_DETECT_REGIONS,
-				c->radar_detect_regions)))
+				 c->radar_detect_regions)))
 			goto nla_put_failure;
 
 		nla_nest_end(msg, nl_combi);
@@ -1401,8 +1402,9 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			break;
 	case 2:
 		if (nl80211_put_iftypes(msg, NL80211_ATTR_SUPPORTED_IFTYPES,
-					rdev->wiphy.interface_modes))
-				goto nla_put_failure;
+					rdev->wiphy.interface_modes)) {
+			goto nla_put_failure;
+		}
 		state->split_start++;
 		if (state->split)
 			break;
@@ -1491,7 +1493,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 
 		i = 0;
 #define CMD(op, n)							\
-		 do {							\
+		do {							\
 			if (rdev->ops->op) {				\
 				i++;					\
 				if (nla_put_u32(msg, i, NL80211_CMD_ ## n)) \
@@ -1733,8 +1735,9 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			       rdev->wiphy.max_num_csa_counters))
 			goto nla_put_failure;
 
-		if (rdev->wiphy.regulatory_flags & REGULATORY_WIPHY_SELF_MANAGED &&
-		    nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))
+		if ((rdev->wiphy.regulatory_flags &
+		     REGULATORY_WIPHY_SELF_MANAGED) &&
+		     nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))
 			goto nla_put_failure;
 
 		if (nla_put(msg, NL80211_ATTR_EXT_FEATURES,
@@ -2155,8 +2158,9 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		wdev = NULL;
 		netdev = NULL;
 		result = 0;
-	} else
+	} else {
 		wdev = netdev->ieee80211_ptr;
+	}
 
 	/* end workaround code, by now the rdev is available
 	 * and locked, and wdev may or may not be NULL.
@@ -2296,7 +2300,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		if (frag_threshold < 256)
 			return -EINVAL;
 
-		if (frag_threshold != (u32) -1) {
+		if (frag_threshold != (u32)-1) {
 			/* Fragments (apart from the last one) are required to
 			 * have even length. Make the fragmentation code
 			 * simpler by stripping LSB should someone try to use
@@ -2403,7 +2407,8 @@ static int nl80211_send_chandef(struct sk_buff *msg,
 	return 0;
 }
 
-static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
+static int nl80211_send_iface(struct sk_buff *msg,
+			      u32 portid, u32 seq, int flags,
 			      struct cfg80211_registered_device *rdev,
 			      struct wireless_dev *wdev, bool removal)
 {
@@ -2467,7 +2472,8 @@ static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flag
 	return -EMSGSIZE;
 }
 
-static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl80211_dump_interface(struct sk_buff *skb,
+				  struct netlink_callback *cb)
 {
 	int wp_idx = 0;
 	int if_idx = 0;
@@ -2554,7 +2560,7 @@ static int parse_monitor_flags(struct nlattr *nla, u32 *mntrflags)
 
 	for (flag = 1; flag <= NL80211_MNTR_FLAG_MAX; flag++)
 		if (flags[flag])
-			*mntrflags |= (1<<flag);
+			*mntrflags |= (1 << flag);
 
 	return 0;
 }
@@ -2597,7 +2603,8 @@ static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)
 
 	memset(&params, 0, sizeof(params));
 
-	otype = ntype = dev->ieee80211_ptr->iftype;
+	otype = dev->ieee80211_ptr->iftype;
+	ntype = dev->ieee80211_ptr->iftype;
 
 	if (info->attrs[NL80211_ATTR_IFTYPE]) {
 		ntype = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
@@ -2719,9 +2726,9 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;
 
 	wdev = rdev_add_virtual_intf(rdev,
-				nla_data(info->attrs[NL80211_ATTR_IFNAME]),
-				NET_NAME_USER, type, err ? NULL : &flags,
-				&params);
+				     nla_data(info->attrs[NL80211_ATTR_IFNAME]),
+				     NET_NAME_USER, type, err ? NULL : &flags,
+				     &params);
 	if (WARN_ON(!wdev)) {
 		nlmsg_free(msg);
 		return -EPROTO;
@@ -2997,7 +3004,7 @@ static int nl80211_set_key(struct sk_buff *skb, struct genl_info *info)
 			goto out;
 
 		err = rdev_set_default_key(rdev, dev, key.idx,
-						 key.def_uni, key.def_multi);
+					   key.def_uni, key.def_multi);
 
 		if (err)
 			goto out;
@@ -3194,7 +3201,7 @@ static struct cfg80211_acl_data *parse_acl_data(struct wiphy *wiphy,
 		return ERR_PTR(-ENOMEM);
 
 	nla_for_each_nested(attr, info->attrs[NL80211_ATTR_MAC_ADDRS], tmp) {
-		memcpy(acl->mac_addrs[i].addr, nla_data(attr), ETH_ALEN);
+		ether_addr_copy(acl->mac_addrs[i].addr, nla_data(attr));
 		i++;
 	}
 
@@ -3403,8 +3410,9 @@ static int nl80211_start_ap(struct sk_buff *skb, struct genl_info *info)
 		if (!nl80211_valid_auth_type(rdev, params.auth_type,
 					     NL80211_CMD_START_AP))
 			return -EINVAL;
-	} else
+	} else {
 		params.auth_type = NL80211_AUTHTYPE_AUTOMATIC;
+	}
 
 	err = nl80211_crypto_settings(rdev, info, &params.crypto,
 				      NL80211_MAX_NR_CIPHER_SUITES);
@@ -3450,8 +3458,9 @@ static int nl80211_start_ap(struct sk_buff *skb, struct genl_info *info)
 			return err;
 	} else if (wdev->preset_chandef.chan) {
 		params.chandef = wdev->preset_chandef;
-	} else if (!nl80211_get_ap_channel(rdev, &params))
+	} else if (!nl80211_get_ap_channel(rdev, &params)) {
 		return -EINVAL;
+	}
 
 	if (!cfg80211_reg_can_beacon_relax(&rdev->wiphy, &params.chandef,
 					   wdev->iftype))
@@ -3616,7 +3625,7 @@ static int parse_station_flags(struct genl_info *info,
 
 	for (flag = 1; flag <= NL80211_STA_FLAG_MAX; flag++) {
 		if (flags[flag]) {
-			params->sta_flags_set |= (1<<flag);
+			params->sta_flags_set |= (1 << flag);
 
 			/* no longer support new API additions in old API */
 			if (flag > NL80211_STA_FLAG_MAX_OLD_API)
@@ -3944,10 +3953,10 @@ static int nl80211_dump_station(struct sk_buff *skb,
 			goto out_err;
 
 		if (nl80211_send_station(skb, NL80211_CMD_NEW_STATION,
-				NETLINK_CB(cb->skb).portid,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				rdev, wdev->netdev, mac_addr,
-				&sinfo) < 0)
+					 NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					 rdev, wdev->netdev, mac_addr,
+					 &sinfo) < 0)
 			goto out;
 
 		sta_idx++;
@@ -4219,7 +4228,7 @@ static int nl80211_parse_sta_wme(struct genl_info *info,
 }
 
 static int nl80211_parse_sta_channel_info(struct genl_info *info,
-				      struct station_parameters *params)
+					  struct station_parameters *params)
 {
 	if (info->attrs[NL80211_ATTR_STA_SUPPORTED_CHANNELS]) {
 		params->supported_channels =
@@ -4650,9 +4659,9 @@ static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
 }
 
 static int nl80211_send_mpath(struct sk_buff *msg, u32 portid, u32 seq,
-				int flags, struct net_device *dev,
-				u8 *dst, u8 *next_hop,
-				struct mpath_info *pinfo)
+			      int flags, struct net_device *dev,
+			      u8 *dst, u8 *next_hop,
+			      struct mpath_info *pinfo)
 {
 	void *hdr;
 	struct nlattr *pinfoattr;
@@ -4785,7 +4794,7 @@ static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;
 
 	if (nl80211_send_mpath(msg, info->snd_portid, info->snd_seq, 0,
-				 dev, dst, next_hop, &pinfo) < 0) {
+			       dev, dst, next_hop, &pinfo) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
 	}
@@ -5180,7 +5189,8 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 	return -ENOBUFS;
 }
 
-static const struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_ATTR_MAX+1] = {
+static const
+struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_ATTR_MAX + 1] = {
 	[NL80211_MESHCONF_RETRY_TIMEOUT] = { .type = NLA_U16 },
 	[NL80211_MESHCONF_CONFIRM_TIMEOUT] = { .type = NLA_U16 },
 	[NL80211_MESHCONF_HOLDING_TIMEOUT] = { .type = NLA_U16 },
@@ -5212,7 +5222,7 @@ static const struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_A
 };
 
 static const struct nla_policy
-	nl80211_mesh_setup_params_policy[NL80211_MESH_SETUP_ATTR_MAX+1] = {
+	nl80211_mesh_setup_params_policy[NL80211_MESH_SETUP_ATTR_MAX + 1] = {
 	[NL80211_MESH_SETUP_ENABLE_VENDOR_SYNC] = { .type = NLA_U8 },
 	[NL80211_MESH_SETUP_ENABLE_VENDOR_PATH_SEL] = { .type = NLA_U8 },
 	[NL80211_MESH_SETUP_ENABLE_VENDOR_METRIC] = { .type = NLA_U8 },
@@ -5358,7 +5368,7 @@ do {									    \
 }
 
 static int nl80211_parse_mesh_setup(struct genl_info *info,
-				     struct mesh_setup *setup)
+				    struct mesh_setup *setup)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct nlattr *tb[NL80211_MESH_SETUP_ATTR_MAX + 1];
@@ -5667,7 +5677,7 @@ static const struct nla_policy reg_rule_policy[NL80211_REG_RULE_ATTR_MAX + 1] =
 };
 
 static int parse_reg_rule(struct nlattr *tb[],
-	struct ieee80211_reg_rule *reg_rule)
+			  struct ieee80211_reg_rule *reg_rule)
 {
 	struct ieee80211_freq_range *freq_range = &reg_rule->freq_range;
 	struct ieee80211_power_rule *power_rule = &reg_rule->power_rule;
@@ -5892,8 +5902,8 @@ static int nl80211_parse_random_mac(struct nlattr **attrs,
 	if (!attrs[NL80211_ATTR_MAC] || !attrs[NL80211_ATTR_MAC_MASK])
 		return -EINVAL;
 
-	memcpy(mac_addr, nla_data(attrs[NL80211_ATTR_MAC]), ETH_ALEN);
-	memcpy(mac_addr_mask, nla_data(attrs[NL80211_ATTR_MAC_MASK]), ETH_ALEN);
+	ether_addr_copy(mac_addr, nla_data(attrs[NL80211_ATTR_MAC]));
+	ether_addr_copy(mac_addr_mask, nla_data(attrs[NL80211_ATTR_MAC_MASK]));
 
 	/* don't allow or configure an mcast address */
 	if (!is_multicast_ether_addr(mac_addr_mask) ||
@@ -6482,7 +6492,7 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 				       nla_data(ssid), nla_len(ssid));
 				request->match_sets[i].ssid.ssid_len =
 					nla_len(ssid);
-				/* special attribute - old implemenation w/a */
+				/* special attribute - old implementation w/a */
 				request->match_sets[i].rssi_thold =
 					default_match_rssi;
 				rssi = tb[NL80211_SCHED_SCAN_MATCH_ATTR_RSSI];
@@ -6681,7 +6691,7 @@ static int nl80211_channel_switch(struct sk_buff *skb, struct genl_info *info)
 	/* csa_attrs is defined static to avoid waste of stack size - this
 	 * function is called under RTNL lock, so this should not be a problem.
 	 */
-	static struct nlattr *csa_attrs[NL80211_ATTR_MAX+1];
+	static struct nlattr *csa_attrs[NL80211_ATTR_MAX + 1];
 	int err;
 	bool need_new_beacon = false;
 	int len, i;
@@ -6977,8 +6987,8 @@ static int nl80211_dump_scan(struct sk_buff *skb, struct netlink_callback *cb)
 		if (++idx <= start)
 			continue;
 		if (nl80211_send_bss(skb, cb,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				rdev, wdev, scan) < 0) {
+				     cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				     rdev, wdev, scan) < 0) {
 			idx--;
 			break;
 		}
@@ -7030,7 +7040,7 @@ static int nl80211_send_survey(struct sk_buff *msg, u32 portid, u32 seq,
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME) &&
 	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME,
-			survey->time, NL80211_SURVEY_INFO_PAD))
+			      survey->time, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_BUSY) &&
 	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_BUSY,
@@ -7104,9 +7114,9 @@ static int nl80211_dump_survey(struct sk_buff *skb, struct netlink_callback *cb)
 		}
 
 		if (nl80211_send_survey(skb,
-				NETLINK_CB(cb->skb).portid,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				wdev->netdev, radio_stats, &survey) < 0)
+					NETLINK_CB(cb->skb).portid,
+					cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					wdev->netdev, radio_stats, &survey) < 0)
 			goto out;
 		survey_idx++;
 	}
@@ -7262,8 +7272,9 @@ static int nl80211_crypto_settings(struct cfg80211_registered_device *rdev,
 			return -EINVAL;
 		if (info->attrs[NL80211_ATTR_CONTROL_PORT_NO_ENCRYPT])
 			settings->control_port_no_encrypt = true;
-	} else
+	} else {
 		settings->control_port_ethertype = cpu_to_be16(ETH_P_PAE);
+	}
 
 	if (info->attrs[NL80211_ATTR_CIPHER_SUITES_PAIRWISE]) {
 		void *data;
@@ -7668,8 +7679,8 @@ static int nl80211_join_ibss(struct sk_buff *skb, struct genl_info *info)
 		bool no_ht = false;
 
 		connkeys = nl80211_parse_connkeys(rdev,
-					  info->attrs[NL80211_ATTR_KEYS],
-					  &no_ht);
+						  info->attrs[NL80211_ATTR_KEYS],
+						  &no_ht);
 		if (IS_ERR(connkeys))
 			return PTR_ERR(connkeys);
 
@@ -7997,8 +8008,9 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
 		if (!nl80211_valid_auth_type(rdev, connect.auth_type,
 					     NL80211_CMD_CONNECT))
 			return -EINVAL;
-	} else
+	} else {
 		connect.auth_type = NL80211_AUTHTYPE_AUTOMATIC;
+	}
 
 	connect.privacy = info->attrs[NL80211_ATTR_PRIVACY];
 
@@ -8015,7 +8027,7 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
 
 	connect.bg_scan_period = -1;
 	if (info->attrs[NL80211_ATTR_BG_SCAN_PERIOD] &&
-		(wiphy->flags & WIPHY_FLAG_SUPPORTS_FW_ROAM)) {
+	    (wiphy->flags & WIPHY_FLAG_SUPPORTS_FW_ROAM)) {
 		connect.bg_scan_period =
 			nla_get_u16(info->attrs[NL80211_ATTR_BG_SCAN_PERIOD]);
 	}
@@ -8060,7 +8072,8 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
 
 	if (connect.privacy && info->attrs[NL80211_ATTR_KEYS]) {
 		connkeys = nl80211_parse_connkeys(rdev,
-					  info->attrs[NL80211_ATTR_KEYS], NULL);
+						  info->attrs[NL80211_ATTR_KEYS],
+						  NULL);
 		if (IS_ERR(connkeys))
 			return PTR_ERR(connkeys);
 	}
@@ -8560,7 +8573,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 	/* The nested attribute uses enum nl80211_band as the index. This maps
 	 * directly to the enum nl80211_band values used in cfg80211.
 	 */
-	BUILD_BUG_ON(NL80211_MAX_SUPP_HT_RATES > IEEE80211_HT_MCS_MASK_LEN * 8);
+	BUILD_BUG_ON(IEEE80211_HT_MCS_MASK_LEN * 8 < NL80211_MAX_SUPP_HT_RATES);
 	nla_for_each_nested(tx_rates, info->attrs[NL80211_ATTR_TX_RATES], rem) {
 		enum nl80211_band band = nla_type(tx_rates);
 		int err;
@@ -8568,7 +8581,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 		if (band < 0 || band >= NUM_NL80211_BANDS)
 			return -EINVAL;
 		sband = rdev->wiphy.bands[band];
-		if (sband == NULL)
+		if (!sband)
 			return -EINVAL;
 		err = nla_parse(tb, NL80211_TXRATE_MAX, nla_data(tx_rates),
 				nla_len(tx_rates), nl80211_txattr_policy);
@@ -9039,7 +9052,7 @@ static int nl80211_join_mesh(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MCAST_RATE] &&
 	    !nl80211_parse_mcast_rate(rdev, setup.mcast_rate,
 			    nla_get_u32(info->attrs[NL80211_ATTR_MCAST_RATE])))
-			return -EINVAL;
+		return -EINVAL;
 
 	if (info->attrs[NL80211_ATTR_BEACON_INTERVAL]) {
 		setup.beacon_interval =
@@ -9405,8 +9418,7 @@ static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
 		return -ENOMEM;
 	cfg->src = nla_get_in_addr(tb[NL80211_WOWLAN_TCP_SRC_IPV4]);
 	cfg->dst = nla_get_in_addr(tb[NL80211_WOWLAN_TCP_DST_IPV4]);
-	memcpy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]),
-	       ETH_ALEN);
+	ether_addr_copy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]));
 	if (tb[NL80211_WOWLAN_TCP_SRC_PORT])
 		port = nla_get_u16(tb[NL80211_WOWLAN_TCP_SRC_PORT]);
 	else
@@ -9470,7 +9482,7 @@ static int nl80211_parse_wowlan_nd(struct cfg80211_registered_device *rdev,
 	struct nlattr **tb;
 	int err;
 
-	tb = kzalloc(NUM_NL80211_ATTR * sizeof(*tb), GFP_KERNEL);
+	tb = kcalloc(NUM_NL80211_ATTR, sizeof(*tb), GFP_KERNEL);
 	if (!tb)
 		return -ENOMEM;
 
@@ -12202,7 +12214,7 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 }
 
 void cfg80211_notify_new_peer_candidate(struct net_device *dev, const u8 *addr,
-					const u8* ie, u8 ie_len, gfp_t gfp)
+					const u8 *ie, u8 ie_len, gfp_t gfp)
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct cfg80211_registered_device *rdev = wiphy_to_rdev(wdev->wiphy);
@@ -12228,7 +12240,7 @@ void cfg80211_notify_new_peer_candidate(struct net_device *dev, const u8 *addr,
 	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
 	    nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, addr) ||
 	    (ie_len && ie &&
-	     nla_put(msg, NL80211_ATTR_IE, ie_len , ie)))
+	     nla_put(msg, NL80211_ATTR_IE, ie_len, ie)))
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
@@ -12952,7 +12964,7 @@ static void nl80211_ch_switch_notify(struct cfg80211_registered_device *rdev,
 
 	if ((notif == NL80211_CMD_CH_SWITCH_STARTED_NOTIFY) &&
 	    (nla_put_u32(msg, NL80211_ATTR_CH_SWITCH_COUNT, count)))
-			goto nla_put_failure;
+		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
 
@@ -13291,7 +13303,7 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,
 
 		if (wakeup->net_detect &&
 		    cfg80211_net_detect_results(msg, wakeup))
-				goto free_msg;
+			goto free_msg;
 
 		nla_nest_end(msg, reasons);
 	}
@@ -13350,7 +13362,7 @@ void cfg80211_tdls_oper_request(struct net_device *dev, const u8 *peer,
 }
 EXPORT_SYMBOL(cfg80211_tdls_oper_request);
 
-static int nl80211_netlink_notify(struct notifier_block * nb,
+static int nl80211_netlink_notify(struct notifier_block *nb,
 				  unsigned long state,
 				  void *_notify)
 {
-- 
2.8.0.rc3.226.g39d4020
