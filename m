From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip6_tunnels: raddr and laddr are inverted in nl msg
Date: Mon, 16 Sep 2013 11:31:15 +0200
Message-ID: <1379323875-3794-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Ding Zhi <zhi.ding@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49003 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507Ab3IPJbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 05:31:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Zhi <zhi.ding@6wind.com>

IFLA_IPTUN_LOCAL and IFLA_IPTUN_REMOTE were inverted.

Introduced by c075b13098b3 (ip6tnl: advertise tunnel param via rtnl).

Signed-off-by: Ding Zhi <zhi.ding@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61355f7f4da5..2d8f4829575b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1656,9 +1656,9 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
 	    nla_put(skb, IFLA_IPTUN_LOCAL, sizeof(struct in6_addr),
-		    &parm->raddr) ||
-	    nla_put(skb, IFLA_IPTUN_REMOTE, sizeof(struct in6_addr),
 		    &parm->laddr) ||
+	    nla_put(skb, IFLA_IPTUN_REMOTE, sizeof(struct in6_addr),
+		    &parm->raddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->hop_limit) ||
 	    nla_put_u8(skb, IFLA_IPTUN_ENCAP_LIMIT, parm->encap_limit) ||
 	    nla_put_be32(skb, IFLA_IPTUN_FLOWINFO, parm->flowinfo) ||
-- 
1.8.2.1
