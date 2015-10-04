From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 17/20] bridge: netlink: add support for multicast_startup_query_count
Date: Sun,  4 Oct 2015 14:23:44 +0200
Message-ID: <1443961427-15085-18-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36167 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbJDMYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:25 -0400
Received: by wicgb1 with SMTP id gb1so85081287wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:24 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_STARTUP_QUERY_CNT to allow setting/getting
br->multicast_startup_query_count via netlink. Also align the ifla
comments.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 22 ++++++++++++++++------
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5409a461e47e..fd841b5269c1 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -252,6 +252,7 @@ enum {
 	IFLA_BR_MCAST_HASH_ELASTICITY,
 	IFLA_BR_MCAST_HASH_MAX,
 	IFLA_BR_MCAST_LAST_MEMBER_CNT,
+	IFLA_BR_MCAST_STARTUP_QUERY_CNT,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index cf6ccaea8180..6744e30120af 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -774,6 +774,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_HASH_ELASTICITY] = { .type = NLA_U32 },
 	[IFLA_BR_MCAST_HASH_MAX] = { .type = NLA_U32 },
 	[IFLA_BR_MCAST_LAST_MEMBER_CNT] = { .type = NLA_U32 },
+	[IFLA_BR_MCAST_STARTUP_QUERY_CNT] = { .type = NLA_U32 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -920,6 +921,12 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 
 		br->multicast_last_member_count = val;
 	}
+
+	if (data[IFLA_BR_MCAST_STARTUP_QUERY_CNT]) {
+		u32 val = nla_get_u32(data[IFLA_BR_MCAST_STARTUP_QUERY_CNT]);
+
+		br->multicast_startup_query_count = val;
+	}
 #endif
 
 	return 0;
@@ -942,8 +949,8 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_BRIDGE_ID */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_ROOT_PORT */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_ROOT_PATH_COST */
-	       nla_total_size(sizeof(u8)) +    /* IFLA_BR_TOPOLOGY_CHANGE */
-	       nla_total_size(sizeof(u8)) +    /* IFLA_BR_TOPOLOGY_CHANGE_DETECTED */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_TOPOLOGY_CHANGE */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_TOPOLOGY_CHANGE_DETECTED */
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_HELLO_TIMER */
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TCN_TIMER */
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TOPOLOGY_CHANGE_TIMER */
@@ -954,9 +961,10 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_SNOOPING */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERY_USE_IFADDR */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERIER */
-	       nla_total_size(sizeof(u32)) +     /* IFLA_BR_MCAST_HASH_ELASTICITY */
-	       nla_total_size(sizeof(u32)) +     /* IFLA_BR_MCAST_HASH_MAX */
-	       nla_total_size(sizeof(u32)) +     /* IFLA_BR_MCAST_LAST_MEMBER_CNT */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_HASH_ELASTICITY */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_HASH_MAX */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_LAST_MEMBER_CNT */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_STARTUP_QUERY_CNT */
 #endif
 	       0;
 }
@@ -1024,7 +1032,9 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 			br->hash_elasticity) ||
 	    nla_put_u32(skb, IFLA_BR_MCAST_HASH_MAX, br->hash_max) ||
 	    nla_put_u32(skb, IFLA_BR_MCAST_LAST_MEMBER_CNT,
-			br->multicast_last_member_count))
+			br->multicast_last_member_count) ||
+	    nla_put_u32(skb, IFLA_BR_MCAST_STARTUP_QUERY_CNT,
+			br->multicast_startup_query_count))
 		return -EMSGSIZE;
 #endif
 
-- 
2.4.3
