From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 18/20] bridge: netlink: add support for igmp's intervals
Date: Sun,  4 Oct 2015 14:23:45 +0200
Message-ID: <1443961427-15085-19-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37243 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbbJDMY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:26 -0400
Received: by wicfx3 with SMTP id fx3so80982535wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:25 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add support to set/get all of the igmp's configurable intervals via
netlink. These currently are:
IFLA_BR_MCAST_LAST_MEMBER_INTVL
IFLA_BR_MCAST_MEMBERSHIP_INTVL
IFLA_BR_MCAST_QUERIER_INTVL
IFLA_BR_MCAST_QUERY_INTVL
IFLA_BR_MCAST_QUERY_RESPONSE_INTVL
IFLA_BR_MCAST_STARTUP_QUERY_INTVL

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  6 ++++
 net/bridge/br_netlink.c      | 70 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index fd841b5269c1..b8c88aa19fef 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -253,6 +253,12 @@ enum {
 	IFLA_BR_MCAST_HASH_MAX,
 	IFLA_BR_MCAST_LAST_MEMBER_CNT,
 	IFLA_BR_MCAST_STARTUP_QUERY_CNT,
+	IFLA_BR_MCAST_LAST_MEMBER_INTVL,
+	IFLA_BR_MCAST_MEMBERSHIP_INTVL,
+	IFLA_BR_MCAST_QUERIER_INTVL,
+	IFLA_BR_MCAST_QUERY_INTVL,
+	IFLA_BR_MCAST_QUERY_RESPONSE_INTVL,
+	IFLA_BR_MCAST_STARTUP_QUERY_INTVL,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6744e30120af..30def4fb5901 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -775,6 +775,12 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_HASH_MAX] = { .type = NLA_U32 },
 	[IFLA_BR_MCAST_LAST_MEMBER_CNT] = { .type = NLA_U32 },
 	[IFLA_BR_MCAST_STARTUP_QUERY_CNT] = { .type = NLA_U32 },
+	[IFLA_BR_MCAST_LAST_MEMBER_INTVL] = { .type = NLA_U64 },
+	[IFLA_BR_MCAST_MEMBERSHIP_INTVL] = { .type = NLA_U64 },
+	[IFLA_BR_MCAST_QUERIER_INTVL] = { .type = NLA_U64 },
+	[IFLA_BR_MCAST_QUERY_INTVL] = { .type = NLA_U64 },
+	[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL] = { .type = NLA_U64 },
+	[IFLA_BR_MCAST_STARTUP_QUERY_INTVL] = { .type = NLA_U64 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -927,6 +933,42 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 
 		br->multicast_startup_query_count = val;
 	}
+
+	if (data[IFLA_BR_MCAST_LAST_MEMBER_INTVL]) {
+		u64 val = nla_get_u64(data[IFLA_BR_MCAST_LAST_MEMBER_INTVL]);
+
+		br->multicast_last_member_interval = clock_t_to_jiffies(val);
+	}
+
+	if (data[IFLA_BR_MCAST_MEMBERSHIP_INTVL]) {
+		u64 val = nla_get_u64(data[IFLA_BR_MCAST_MEMBERSHIP_INTVL]);
+
+		br->multicast_membership_interval = clock_t_to_jiffies(val);
+	}
+
+	if (data[IFLA_BR_MCAST_QUERIER_INTVL]) {
+		u64 val = nla_get_u64(data[IFLA_BR_MCAST_QUERIER_INTVL]);
+
+		br->multicast_querier_interval = clock_t_to_jiffies(val);
+	}
+
+	if (data[IFLA_BR_MCAST_QUERY_INTVL]) {
+		u64 val = nla_get_u64(data[IFLA_BR_MCAST_QUERY_INTVL]);
+
+		br->multicast_query_interval = clock_t_to_jiffies(val);
+	}
+
+	if (data[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL]) {
+		u64 val = nla_get_u64(data[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL]);
+
+		br->multicast_query_response_interval = clock_t_to_jiffies(val);
+	}
+
+	if (data[IFLA_BR_MCAST_STARTUP_QUERY_INTVL]) {
+		u64 val = nla_get_u64(data[IFLA_BR_MCAST_STARTUP_QUERY_INTVL]);
+
+		br->multicast_startup_query_interval = clock_t_to_jiffies(val);
+	}
 #endif
 
 	return 0;
@@ -965,6 +1007,12 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_HASH_MAX */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_LAST_MEMBER_CNT */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_STARTUP_QUERY_CNT */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_LAST_MEMBER_INTVL */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_MEMBERSHIP_INTVL */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERIER_INTVL */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERY_INTVL */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERY_RESPONSE_INTVL */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_STARTUP_QUERY_INTVL */
 #endif
 	       0;
 }
@@ -972,7 +1020,7 @@ static size_t br_get_size(const struct net_device *brdev)
 static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 {
 	struct net_bridge *br = netdev_priv(brdev);
-	u64 hello_timer, tcn_timer, topology_change_timer, gc_timer;
+	u64 hello_timer, tcn_timer, topology_change_timer, gc_timer, clockval;
 	u32 forward_delay = jiffies_to_clock_t(br->forward_delay);
 	u32 hello_time = jiffies_to_clock_t(br->hello_time);
 	u32 age_time = jiffies_to_clock_t(br->max_age);
@@ -993,6 +1041,7 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	tcn_timer = br_timer_value(&br->tcn_timer);
 	topology_change_timer = br_timer_value(&br->topology_change_timer);
 	gc_timer = br_timer_value(&br->gc_timer);
+	clockval = 0;
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
@@ -1036,6 +1085,25 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_MCAST_STARTUP_QUERY_CNT,
 			br->multicast_startup_query_count))
 		return -EMSGSIZE;
+
+	clockval = jiffies_to_clock_t(br->multicast_last_member_interval);
+	if (nla_put_u64(skb, IFLA_BR_MCAST_LAST_MEMBER_INTVL, clockval))
+		return -EMSGSIZE;
+	clockval = jiffies_to_clock_t(br->multicast_membership_interval);
+	if (nla_put_u64(skb, IFLA_BR_MCAST_MEMBERSHIP_INTVL, clockval))
+		return -EMSGSIZE;
+	clockval = jiffies_to_clock_t(br->multicast_querier_interval);
+	if (nla_put_u64(skb, IFLA_BR_MCAST_QUERIER_INTVL, clockval))
+		return -EMSGSIZE;
+	clockval = jiffies_to_clock_t(br->multicast_query_interval);
+	if (nla_put_u64(skb, IFLA_BR_MCAST_QUERY_INTVL, clockval))
+		return -EMSGSIZE;
+	clockval = jiffies_to_clock_t(br->multicast_query_response_interval);
+	if (nla_put_u64(skb, IFLA_BR_MCAST_QUERY_RESPONSE_INTVL, clockval))
+		return -EMSGSIZE;
+	clockval = jiffies_to_clock_t(br->multicast_startup_query_interval);
+	if (nla_put_u64(skb, IFLA_BR_MCAST_STARTUP_QUERY_INTVL, clockval))
+		return -EMSGSIZE;
 #endif
 
 	return 0;
-- 
2.4.3
