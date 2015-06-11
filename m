From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V1] net/ethtool: Add current supported tunable options
Date: Thu, 11 Jun 2015 10:28:16 +0300
Message-ID: <1434007696-59156-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, _govind@gmx.com,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:50408 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751404AbbFKH30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 03:29:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add strings array of the current supported tunable options.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Amir Vadai <amirv@mellanox.com>
---
Changes from V0:
- s/ETHTOOL_TUNABLE_COUNT/__ETHTOOL_TUNABLE_COUNT/

 include/uapi/linux/ethtool.h |  6 ++++++
 net/core/ethtool.c           | 12 ++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 0594933..cd67aec 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -215,6 +215,11 @@ enum tunable_id {
 	ETHTOOL_ID_UNSPEC,
 	ETHTOOL_RX_COPYBREAK,
 	ETHTOOL_TX_COPYBREAK,
+	/*
+	 * Add your fresh new tubale attribute above and remember to update
+	 * tunable_strings[] in net/core/ethtool.c
+	 */
+	__ETHTOOL_TUNABLE_COUNT,
 };
 
 enum tunable_type_id {
@@ -545,6 +550,7 @@ enum ethtool_stringset {
 	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 	ETH_SS_RSS_HASH_FUNCS,
+	ETH_SS_TUNABLES,
 };
 
 /**
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index eb0c3ac..b495ab1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -106,6 +106,13 @@ rss_hash_func_strings[ETH_RSS_HASH_FUNCS_COUNT][ETH_GSTRING_LEN] = {
 	[ETH_RSS_HASH_XOR_BIT] =	"xor",
 };
 
+static const char
+tunable_strings[__ETHTOOL_TUNABLE_COUNT][ETH_GSTRING_LEN] = {
+	[ETHTOOL_ID_UNSPEC]     = "Unspec",
+	[ETHTOOL_RX_COPYBREAK]	= "rx-copybreak",
+	[ETHTOOL_TX_COPYBREAK]	= "tx-copybreak",
+};
+
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_gfeatures cmd = {
@@ -194,6 +201,9 @@ static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 	if (sset == ETH_SS_RSS_HASH_FUNCS)
 		return ARRAY_SIZE(rss_hash_func_strings);
 
+	if (sset == ETH_SS_TUNABLES)
+		return ARRAY_SIZE(tunable_strings);
+
 	if (ops->get_sset_count && ops->get_strings)
 		return ops->get_sset_count(dev, sset);
 	else
@@ -211,6 +221,8 @@ static void __ethtool_get_strings(struct net_device *dev,
 	else if (stringset == ETH_SS_RSS_HASH_FUNCS)
 		memcpy(data, rss_hash_func_strings,
 		       sizeof(rss_hash_func_strings));
+	else if (stringset == ETH_SS_TUNABLES)
+		memcpy(data, tunable_strings, sizeof(tunable_strings));
 	else
 		/* ops->get_strings is valid because checked earlier */
 		ops->get_strings(dev, stringset, data);
-- 
1.8.3.1
