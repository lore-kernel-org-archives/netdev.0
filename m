From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 05/10] ipip/rtnl: add IFLA_IPTUN_PMTUDISC on dump
Date: Wed, 14 Nov 2012 16:14:02 +0100
Message-ID: <1352906047-11604-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34747 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964808Ab2KNPQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:12 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This parameter was missing in the dump.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_tunnel.h | 1 +
 net/ipv4/ipip.c                | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index f5ea6b7..5ab0c8d 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -48,6 +48,7 @@ enum {
 	IFLA_IPTUN_FLOWINFO,
 	IFLA_IPTUN_FLAGS,
 	IFLA_IPTUN_PROTO,
+	IFLA_IPTUN_PMTUDISC,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 40984fa..1204da3 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -854,6 +854,8 @@ static size_t ipip_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_IPTUN_TOS */
 		nla_total_size(1) +
+		/* IFLA_IPTUN_PMTUDISC */
+		nla_total_size(1) +
 		0;
 }
 
@@ -866,7 +868,9 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
 	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
-	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos))
+	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
+	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
+		       !!(parm->iph.frag_off & htons(IP_DF))))
 		goto nla_put_failure;
 	return 0;
 
-- 
1.7.12
