From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 01/10] ip6tnl/rtnl: add IFLA_IPTUN_PROTO on dump
Date: Wed, 14 Nov 2012 16:13:58 +0100
Message-ID: <1352906047-11604-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34720 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964781Ab2KNPQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:10 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 tunnels can have three mode: 4in6, 6in6 and xin6.
This information was missing in the netlink message.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_tunnel.h | 1 +
 net/ipv6/ip6_tunnel.c          | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index c1bf0b5..f5ea6b7 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -47,6 +47,7 @@ enum {
 	IFLA_IPTUN_ENCAP_LIMIT,
 	IFLA_IPTUN_FLOWINFO,
 	IFLA_IPTUN_FLAGS,
+	IFLA_IPTUN_PROTO,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 424ed45..9a7d8c7 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1523,6 +1523,8 @@ static size_t ip6_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_IPTUN_FLAGS */
 		nla_total_size(4) +
+		/* IFLA_IPTUN_PROTO */
+		nla_total_size(1) +
 		0;
 }
 
@@ -1539,7 +1541,8 @@ static int ip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->hop_limit) ||
 	    nla_put_u8(skb, IFLA_IPTUN_ENCAP_LIMIT, parm->encap_limit) ||
 	    nla_put_be32(skb, IFLA_IPTUN_FLOWINFO, parm->flowinfo) ||
-	    nla_put_u32(skb, IFLA_IPTUN_FLAGS, parm->flags))
+	    nla_put_u32(skb, IFLA_IPTUN_FLAGS, parm->flags) ||
+	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->proto))
 		goto nla_put_failure;
 	return 0;
 
-- 
1.7.12
