From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 01/10] nl80211: Fix checkpatch warnings
Date: Sun, 29 May 2016 19:50:23 -0700
Message-ID: <9986ccdc1da510644148a5868c0bc125d6b806d2.1464576022.git.kirtika.ruchandani@gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Julian.Calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1464576022.git.kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes the following checkpatch.pl warnings about
comments in nl80211.c :
- networking block comments don't use an empty '/*' line
- block comments use a trailing '*/' on a separate line

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/wireless/nl80211.c | 129 +++++++++++++++++--------------------------------
 1 file changed, 45 insertions(+), 84 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d759901..50a0de0 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -196,8 +196,7 @@ __cfg80211_rdev_from_attrs(struct net *netns, struct nlattr **attrs)
 	return rdev;
 }

-/*
- * This function returns a pointer to the driver
+/* This function returns a pointer to the driver
  * that the genl_info item that is passed refers to.
  *
  * The result of this can be a PTR_ERR and hence must
@@ -1624,8 +1623,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			goto nla_put_failure;

 		features = rdev->wiphy.features;
-		/*
-		 * We can only add the per-channel limit information if the
+		/* We can only add the per-channel limit information if the
 		 * dump is split, otherwise it makes it too big. Therefore
 		 * only advertise it in that case.
 		 */
@@ -1646,8 +1644,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 				rdev->wiphy.max_acl_mac_addrs))
 			goto nla_put_failure;

-		/*
-		 * Any information below this point is only available to
+		/* Any information below this point is only available to
 		 * applications that can deal with it being split. This
 		 * helps ensure that newly added capabilities don't break
 		 * older tools by overrunning their buffers.
@@ -1847,8 +1844,7 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
 						 cb->nlh->nlmsg_seq,
 						 NLM_F_MULTI, state);
 			if (ret < 0) {
-				/*
-				 * If sending the wiphy data didn't fit (ENOBUFS
+				/* If sending the wiphy data didn't fit (ENOBUFS
 				 * or EMSGSIZE returned), this SKB is still
 				 * empty (so it's not too big because another
 				 * wiphy dataset is already in the skb) and
@@ -1937,8 +1933,7 @@ static int parse_txq_params(struct nlattr *tb[],

 static bool nl80211_can_set_dev_channel(struct wireless_dev *wdev)
 {
-	/*
-	 * You can only set the channel explicitly for WDS interfaces,
+	/* You can only set the channel explicitly for WDS interfaces,
 	 * all others have their channel managed via their respective
 	 * "establish a connection" command (connect, join, ...)
 	 *
@@ -2131,8 +2126,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)

 	ASSERT_RTNL();

-	/*
-	 * Try to find the wiphy and netdev. Normally this
+	/* Try to find the wiphy and netdev. Normally this
 	 * function shouldn't need the netdev, but this is
 	 * done for backward compatibility -- previously
 	 * setting the channel was done per wiphy, but now
@@ -2162,8 +2156,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 	} else
 		wdev = netdev->ieee80211_ptr;

-	/*
-	 * end workaround code, by now the rdev is available
+	/* end workaround code, by now the rdev is available
 	 * and locked, and wdev may or may not be NULL.
 	 */

@@ -2260,7 +2253,8 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		rx_ant = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_ANTENNA_RX]);

 		/* reject antenna configurations which don't match the
-		 * available antenna masks, except for the "all" mask */
+		 * available antenna masks, except for the "all" mask
+		 */
 		if ((~tx_ant && (tx_ant & ~rdev->wiphy.available_antennas_tx)) ||
 		    (~rx_ant && (rx_ant & ~rdev->wiphy.available_antennas_rx)))
 			return -EINVAL;
@@ -2300,8 +2294,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 			return -EINVAL;

 		if (frag_threshold != (u32) -1) {
-			/*
-			 * Fragments (apart from the last one) are required to
+			/* Fragments (apart from the last one) are required to
 			 * have even length. Make the fragmentation code
 			 * simpler by stripping LSB should someone try to use
 			 * odd threshold value.
@@ -2751,8 +2744,7 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 		wdev_unlock(wdev);
 		break;
 	case NL80211_IFTYPE_P2P_DEVICE:
-		/*
-		 * P2P Device doesn't have a netdev, so doesn't go
+		/* P2P Device doesn't have a netdev, so doesn't go
 		 * through the netdev notifier and must be added here
 		 */
 		mutex_init(&wdev->mtx);
@@ -2808,8 +2800,7 @@ static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
 		msg = NULL;
 	}

-	/*
-	 * If we remove a wireless device without a netdev then clear
+	/* If we remove a wireless device without a netdev then clear
 	 * user_ptr[1] so that nl80211_post_doit won't dereference it
 	 * to check if it needs to do dev_put(). Otherwise it crashes
 	 * since the wdev has been freed, unlike with a netdev where
@@ -3160,8 +3151,7 @@ static int validate_acl_mac_addrs(struct nlattr *nl_attr)
 	return n_entries;
 }

-/*
- * This function parses ACL information and allocates memory for ACL data.
+/* This function parses ACL information and allocates memory for ACL data.
  * On successful return, the calling function is responsible to free the
  * ACL buffer returned by this function.
  */
@@ -3377,8 +3367,7 @@ static int nl80211_start_ap(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;

-	/*
-	 * In theory, some of these attributes should be required here
+	/* In theory, some of these attributes should be required here
 	 * but since they were not used when the command was originally
 	 * added, keep them optional for old user space programs to let
 	 * them continue to work with drivers that do not need the
@@ -3567,8 +3556,7 @@ static int parse_station_flags(struct genl_info *info,
 	struct nlattr *nla;
 	int flag;

-	/*
-	 * Try parsing the new attribute first so userspace
+	/* Try parsing the new attribute first so userspace
 	 * can specify both for older kernels.
 	 */
 	nla = info->attrs[NL80211_ATTR_STA_FLAGS2];
@@ -3595,8 +3583,7 @@ static int parse_station_flags(struct genl_info *info,
 			     nla, sta_flags_policy))
 		return -EINVAL;

-	/*
-	 * Only allow certain flags for interface types so that
+	/* Only allow certain flags for interface types so that
 	 * other attributes are silently ignored. Remember that
 	 * this is backward compatibility code with old userspace
 	 * and shouldn't be hit in other cases anyway.
@@ -4032,8 +4019,7 @@ int cfg80211_check_station_change(struct wiphy *wiphy,
 	switch (statype) {
 	case CFG80211_STA_MESH_PEER_KERNEL:
 	case CFG80211_STA_MESH_PEER_USER:
-		/*
-		 * No ignoring the TDLS flag here -- the userspace mesh
+		/* No ignoring the TDLS flag here -- the userspace mesh
 		 * code doesn't have the bug of including TDLS in the
 		 * mask everywhere.
 		 */
@@ -4065,8 +4051,7 @@ int cfg80211_check_station_change(struct wiphy *wiphy,
 		/* TDLS can't be set, ... */
 		if (params->sta_flags_set & BIT(NL80211_STA_FLAG_TDLS_PEER))
 			return -EINVAL;
-		/*
-		 * ... but don't bother the driver with it. This works around
+		/* ... but don't bother the driver with it. This works around
 		 * a hostapd/wpa_supplicant issue -- it always includes the
 		 * TLDS_PEER flag in the mask even for AP mode.
 		 */
@@ -4151,8 +4136,7 @@ int cfg80211_check_station_change(struct wiphy *wiphy,
 }
 EXPORT_SYMBOL(cfg80211_check_station_change);

-/*
- * Get vlan interface making sure it is running and on the right wiphy.
+/* Get vlan interface making sure it is running and on the right wiphy.
  */
 static struct net_device *get_vlan(struct genl_info *info,
 				   struct cfg80211_registered_device *rdev)
@@ -4239,8 +4223,7 @@ static int nl80211_parse_sta_channel_info(struct genl_info *info,
 		     nla_data(info->attrs[NL80211_ATTR_STA_SUPPORTED_CHANNELS]);
 		params->supported_channels_len =
 		     nla_len(info->attrs[NL80211_ATTR_STA_SUPPORTED_CHANNELS]);
-		/*
-		 * Need to include at least one (first channel, number of
+		/* Need to include at least one (first channel, number of
 		 * channels) tuple for each subband, and must have proper
 		 * tuples for the rest of the data as well.
 		 */
@@ -4255,8 +4238,7 @@ static int nl80211_parse_sta_channel_info(struct genl_info *info,
 		 nla_data(info->attrs[NL80211_ATTR_STA_SUPPORTED_OPER_CLASSES]);
 		params->supported_oper_classes_len =
 		  nla_len(info->attrs[NL80211_ATTR_STA_SUPPORTED_OPER_CLASSES]);
-		/*
-		 * The value of the Length field of the Supported Operating
+		/* The value of the Length field of the Supported Operating
 		 * Classes element is between 2 and 253.
 		 */
 		if (params->supported_oper_classes_len < 2 ||
@@ -4300,8 +4282,7 @@ static int nl80211_set_station(struct sk_buff *skb, struct genl_info *info)
 	if (!rdev->ops->change_station)
 		return -EOPNOTSUPP;

-	/*
-	 * AID and listen_interval properties can be set only for unassociated
+	/* AID and listen_interval properties can be set only for unassociated
 	 * station. Include these parameters here and will check them in
 	 * cfg80211_check_station_change().
 	 */
@@ -4458,8 +4439,7 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)

 		params.support_p2p_ps = tmp;
 	} else {
-		/*
-		 * if not specified, assume it's supported for P2P GO interface,
+		/* if not specified, assume it's supported for P2P GO interface,
 		 * and is NOT supported for AP interface
 		 */
 		params.support_p2p_ps =
@@ -4604,8 +4584,7 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 		/* ... with external setup is supported */
 		if (!(rdev->wiphy.flags & WIPHY_FLAG_TDLS_EXTERNAL_SETUP))
 			return -EOPNOTSUPP;
-		/*
-		 * Older wpa_supplicant versions always mark the TDLS peer
+		/* Older wpa_supplicant versions always mark the TDLS peer
 		 * as authorized, but it shouldn't yet be.
 		 */
 		params.sta_flags_mask &= ~BIT(NL80211_STA_FLAG_AUTHORIZED);
@@ -5054,8 +5033,7 @@ static int nl80211_req_set_reg(struct sk_buff *skb, struct genl_info *info)
 	u32 owner_nlportid;


-	/*
-	 * You should only get this when cfg80211 hasn't yet initialized
+	/* You should only get this when cfg80211 hasn't yet initialized
 	 * completely when built-in to the kernel right between the time
 	 * window between nl80211_init() and regulatory_init(), if that is
 	 * even possible.
@@ -5271,7 +5249,8 @@ do {									    \
 		return -EINVAL;

 	/* This makes sure that there aren't more than 32 mesh config
-	 * parameters (otherwise our bitfield scheme would not work.) */
+	 * parameters (otherwise our bitfield scheme would not work.)
+	 */
 	BUILD_BUG_ON(NL80211_MESHCONF_ATTR_MAX > 32);

 	/* Fill in the params struct */
@@ -5770,8 +5749,7 @@ static int nl80211_set_reg(struct sk_buff *skb, struct genl_info *info)
 	rd->alpha2[0] = alpha2[0];
 	rd->alpha2[1] = alpha2[1];

-	/*
-	 * Disable DFS master mode if the DFS region was
+	/* Disable DFS master mode if the DFS region was
 	 * not supported or known on this kernel.
 	 */
 	if (reg_supported_dfs_region(dfs_region))
@@ -5813,8 +5791,7 @@ static int validate_scan_freqs(struct nlattr *freqs)

 	nla_for_each_nested(attr1, freqs, tmp1) {
 		n_channels++;
-		/*
-		 * Some hardware has a limited channel list for
+		/* Some hardware has a limited channel list for
 		 * scanning, and it is pretty much nonsensical
 		 * to scan for a channel twice, so disallow that
 		 * and don't require drivers to check that the
@@ -5924,8 +5901,7 @@ static int nl80211_parse_random_mac(struct nlattr **attrs,
 	    is_multicast_ether_addr(mac_addr))
 		return -EINVAL;

-	/*
-	 * allow users to pass a MAC address that has bits set outside
+	/* allow users to pass a MAC address that has bits set outside
 	 * of the mask, but don't bother drivers with having to deal
 	 * with such bits
 	 */
@@ -6192,8 +6168,7 @@ nl80211_parse_sched_scan_plans(struct wiphy *wiphy, int n_plans,
 	if (!attrs[NL80211_ATTR_SCHED_SCAN_PLANS]) {
 		u32 interval;

-		/*
-		 * If scan plans are not specified,
+		/* If scan plans are not specified,
 		 * %NL80211_ATTR_SCHED_SCAN_INTERVAL must be specified. In this
 		 * case one scan plan will be set with the specified scan
 		 * interval and infinite number of iterations.
@@ -6248,8 +6223,7 @@ nl80211_parse_sched_scan_plans(struct wiphy *wiphy, int n_plans,
 			     wiphy->max_sched_scan_plan_iterations))
 				return -EINVAL;
 		} else if (i < n_plans - 1) {
-			/*
-			 * All scan plans but the last one must specify
+			/* All scan plans but the last one must specify
 			 * a finite number of iterations
 			 */
 			return -EINVAL;
@@ -6258,8 +6232,7 @@ nl80211_parse_sched_scan_plans(struct wiphy *wiphy, int n_plans,
 		i++;
 	}

-	/*
-	 * The last scan plan must not specify the number of
+	/* The last scan plan must not specify the number of
 	 * iterations, it is supposed to run infinitely
 	 */
 	if (request->scan_plans[n_plans - 1].iterations)
@@ -6300,8 +6273,7 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 	if (n_ssids > wiphy->max_sched_scan_ssids)
 		return ERR_PTR(-EINVAL);

-	/*
-	 * First, count the number of 'real' matchsets. Due to an issue with
+	/* First, count the number of 'real' matchsets. Due to an issue with
 	 * the old implementation, matchsets containing only the RSSI attribute
 	 * (NL80211_SCHED_SCAN_MATCH_ATTR_RSSI) are considered as the 'default'
 	 * RSSI for all matchsets, rather than their own matchset for reporting
@@ -6347,8 +6319,7 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 		return ERR_PTR(-EINVAL);

 	if (attrs[NL80211_ATTR_SCHED_SCAN_PLANS]) {
-		/*
-		 * NL80211_ATTR_SCHED_SCAN_INTERVAL must not be specified since
+		/* NL80211_ATTR_SCHED_SCAN_INTERVAL must not be specified since
 		 * each scan plan already specifies its own interval
 		 */
 		if (attrs[NL80211_ATTR_SCHED_SCAN_INTERVAL])
@@ -6358,8 +6329,7 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 				    attrs[NL80211_ATTR_SCHED_SCAN_PLANS], tmp)
 			n_plans++;
 	} else {
-		/*
-		 * The scan interval attribute is kept for backward
+		/* The scan interval attribute is kept for backward
 		 * compatibility. If no scan plans are specified and sched scan
 		 * interval is specified, one scan plan will be set with this
 		 * scan interval and infinite number of iterations.
@@ -7255,8 +7225,7 @@ static int nl80211_authenticate(struct sk_buff *skb, struct genl_info *info)

 	local_state_change = !!info->attrs[NL80211_ATTR_LOCAL_STATE_CHANGE];

-	/*
-	 * Since we no longer track auth state, ignore
+	/* Since we no longer track auth state, ignore
 	 * requests to only change local state.
 	 */
 	if (local_state_change)
@@ -7918,8 +7887,7 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 	rtnl_lock();

 	if (cb->args[0]) {
-		/*
-		 * 0 is a valid index, but not valid for args[0],
+		/* 0 is a valid index, but not valid for args[0],
 		 * so we need to offset by 1.
 		 */
 		phy_idx = cb->args[0] - 1;
@@ -8364,8 +8332,7 @@ static int nl80211_remain_on_channel(struct sk_buff *skb,
 	    !(rdev->wiphy.flags & WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL))
 		return -EOPNOTSUPP;

-	/*
-	 * We should be on that channel for at least a minimum amount of
+	/* We should be on that channel for at least a minimum amount of
 	 * time (10ms) but no longer than the driver supports.
 	 */
 	if (duration < NL80211_MIN_REMAIN_ON_CHANNEL_TIME ||
@@ -8586,8 +8553,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 	if (!info->attrs[NL80211_ATTR_TX_RATES])
 		goto out;

-	/*
-	 * The nested attribute uses enum nl80211_band as the index. This maps
+	/* The nested attribute uses enum nl80211_band as the index. This maps
 	 * directly to the enum nl80211_band values used in cfg80211.
 	 */
 	BUILD_BUG_ON(NL80211_MAX_SUPP_HT_RATES > IEEE80211_HT_MCS_MASK_LEN * 8);
@@ -8736,8 +8702,7 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 			return -EINVAL;
 		params.wait = nla_get_u32(info->attrs[NL80211_ATTR_DURATION]);

-		/*
-		 * We should wait on the channel for at least a minimum amount
+		/* We should wait on the channel for at least a minimum amount
 		 * of time (10ms) but no longer than the driver supports.
 		 */
 		if (params.wait < NL80211_MIN_REMAIN_ON_CHANNEL_TIME ||
@@ -10758,8 +10723,7 @@ static int nl80211_tdls_channel_switch(struct sk_buff *skb,
 	if (err)
 		return err;

-	/*
-	 * Don't allow wide channels on the 2.4Ghz band, as per IEEE802.11-2012
+	/* Don't allow wide channels on the 2.4Ghz band, as per IEEE802.11-2012
 	 * section 10.22.6.2.1. Disallow 5/10Mhz channels as well for now, the
 	 * specification is not defined for them.
 	 */
@@ -11899,8 +11863,7 @@ nla_put_failure:
 	return false;
 }

-/*
- * This can happen on global regulatory changes or device specific settings
+/* This can happen on global regulatory changes or device specific settings
  * based on custom regulatory domains.
  */
 void nl80211_common_reg_change_event(enum nl80211_commands cmd_id,
@@ -12337,8 +12300,7 @@ void nl80211_send_beacon_hint_event(struct wiphy *wiphy,
 		return;
 	}

-	/*
-	 * Since we are applying the beacon hint to a wiphy we know its
+	/* Since we are applying the beacon hint to a wiphy we know its
 	 * wiphy_idx is valid
 	 */
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, get_wiphy_idx(wiphy)))
@@ -13453,8 +13415,7 @@ static int nl80211_netlink_notify(struct notifier_block * nb,

 	rcu_read_unlock();

-	/*
-	 * It is possible that the user space process that is controlling the
+	/* It is possible that the user space process that is controlling the
 	 * indoor setting disappeared, so notify the regulatory core.
 	 */
 	regulatory_netlink_notify(notify->portid);
--
2.8.0.rc3.226.g39d4020

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
