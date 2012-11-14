From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 08/10] sit/rtnl: add missing parameters on dump
Date: Wed, 14 Nov 2012 16:14:05 +0100
Message-ID: <1352906047-11604-9-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34749 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964811Ab2KNPQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:12 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_IPTUN_FLAGS and IFLA_IPTUN_PMTUDISC were missing.
There is only one possible flag in i_flag: SIT_ISATAP.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b2cfdda..28f56ee 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1229,6 +1229,10 @@ static size_t sit_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_IPTUN_TOS */
 		nla_total_size(1) +
+		/* IFLA_IPTUN_PMTUDISC */
+		nla_total_size(1) +
+		/* IFLA_IPTUN_FLAGS */
+		nla_total_size(2) +
 		0;
 }
 
@@ -1241,7 +1245,10 @@ static int sit_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
 	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
-	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos))
+	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
+	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
+		       !!(parm->iph.frag_off & htons(IP_DF))) ||
+	    nla_put_u16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
 		goto nla_put_failure;
 	return 0;
 
-- 
1.7.12
