From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/2] net/rtnetlink: add IFLA_GSO_MAX_SEGS and IFLA_GSO_MAX_SIZE attributes
Date: Mon, 21 Mar 2016 09:55:10 -0700
Message-ID: <1458579311-17699-2-git-send-email-edumazet@google.com>
References: <1458579311-17699-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Petri Gynther <pgynther@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34448 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088AbcCUQz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 12:55:28 -0400
Received: by mail-pf0-f173.google.com with SMTP id x3so270993224pfb.1
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 09:55:22 -0700 (PDT)
In-Reply-To: <1458579311-17699-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be useful to report dev->gso_max_segs and dev->gso_max_size
so that "ip -d link" can display them to help debugging.

For the moment, these attributes are read-only.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Petri Gynther <pgynther@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 include/uapi/linux/if_link.h | 2 ++
 net/core/rtnetlink.c         | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8e3f88fa5b59..76d315ca597d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -153,6 +153,8 @@ enum {
 	IFLA_LINK_NETNSID,
 	IFLA_PHYS_PORT_NAME,
 	IFLA_PROTO_DOWN,
+	IFLA_GSO_MAX_SEGS,
+	IFLA_GSO_MAX_SIZE,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d2d9e5ebf58e..a69cd0c097b5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -895,6 +895,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_PROMISCUITY */
 	       + nla_total_size(4) /* IFLA_NUM_TX_QUEUES */
 	       + nla_total_size(4) /* IFLA_NUM_RX_QUEUES */
+	       + nla_total_size(4) /* IFLA_MAX_GSO_SEGS */
+	       + nla_total_size(4) /* IFLA_MAX_GSO_SIZE */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
@@ -1223,6 +1225,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u32(skb, IFLA_GROUP, dev->group) ||
 	    nla_put_u32(skb, IFLA_PROMISCUITY, dev->promiscuity) ||
 	    nla_put_u32(skb, IFLA_NUM_TX_QUEUES, dev->num_tx_queues) ||
+	    nla_put_u32(skb, IFLA_GSO_MAX_SEGS, dev->gso_max_segs) ||
+	    nla_put_u32(skb, IFLA_GSO_MAX_SIZE, dev->gso_max_size) ||
 #ifdef CONFIG_RPS
 	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
 #endif
-- 
2.8.0.rc3.226.g39d4020
