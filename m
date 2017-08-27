From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/4] net/core: Add violation counters to VF statisctics
Date: Sun, 27 Aug 2017 14:06:17 +0300
Message-ID: <20170827110618.20599-4-saeedm@mellanox.com>
References: <20170827110618.20599-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37294 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751130AbdH0LV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 07:21:29 -0400
In-Reply-To: <20170827110618.20599-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Add receive and transmit violation counters to be
displayed in iproute2 VF statistics.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/if_link.h      |  2 ++
 include/uapi/linux/if_link.h |  2 ++
 net/core/rtnetlink.c         | 10 +++++++++-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index da70af27e42e..ebf3448acb5b 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -12,6 +12,8 @@ struct ifla_vf_stats {
 	__u64 tx_bytes;
 	__u64 broadcast;
 	__u64 multicast;
+	__u64 rx_dropped;
+	__u64 tx_dropped;
 };
 
 struct ifla_vf_info {
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 3aa895c5fbc1..68cd31b281a1 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -743,6 +743,8 @@ enum {
 	IFLA_VF_STATS_BROADCAST,
 	IFLA_VF_STATS_MULTICAST,
 	IFLA_VF_STATS_PAD,
+	IFLA_VF_STATS_RX_DROPPED,
+	IFLA_VF_STATS_TX_DROPPED,
 	__IFLA_VF_STATS_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 56909f11d88e..1a653bb00d6e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -845,6 +845,10 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size_64bit(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_MULTICAST */
 			 nla_total_size_64bit(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_RX_DROPPED */
+			 nla_total_size_64bit(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_TX_DROPPED */
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 nla_total_size(sizeof(struct ifla_vf_trust)));
 		return size;
 	} else
@@ -1214,7 +1218,11 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	    nla_put_u64_64bit(skb, IFLA_VF_STATS_BROADCAST,
 			      vf_stats.broadcast, IFLA_VF_STATS_PAD) ||
 	    nla_put_u64_64bit(skb, IFLA_VF_STATS_MULTICAST,
-			      vf_stats.multicast, IFLA_VF_STATS_PAD)) {
+			      vf_stats.multicast, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_RX_DROPPED,
+			      vf_stats.rx_dropped, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_TX_DROPPED,
+			      vf_stats.tx_dropped, IFLA_VF_STATS_PAD)) {
 		nla_nest_cancel(skb, vfstats);
 		goto nla_put_vf_failure;
 	}
-- 
2.13.0
