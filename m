From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6 -stable] ipvs: Maintain all DSCP and ECN bits for ipv6 tun forwarding
Date: Fri, 26 Sep 2014 13:43:41 +0200
Message-ID: <1411731824-15051-4-git-send-email-pablo@netfilter.org>
References: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36245 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754144AbaIZLmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 07:42:45 -0400
In-Reply-To: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>

[ upstream commit 76f084bc10004b3050b2cff9cfac29148f1f6088 ]

Previously, only the four high bits of the tclass were maintained in the
ipv6 case.  This matches the behavior of ipv4, though whether or not we
should reflect ECN bits may be up for debate.

Cc: <stable@vger.kernel.org> # 3.16.x
Cc: <stable@vger.kernel.org> # 3.14.x
Cc: <stable@vger.kernel.org> # 3.12.x
Cc: <stable@vger.kernel.org> # 3.10.x
Cc: <stable@vger.kernel.org> # 3.4.x
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 73ba1cc..6f70bdd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -967,8 +967,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->nexthdr		=	IPPROTO_IPV6;
 	iph->payload_len	=	old_iph->payload_len;
 	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
-	iph->priority		=	old_iph->priority;
 	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
+	ipv6_change_dsfield(iph, 0, ipv6_get_dsfield(old_iph));
 	iph->daddr = cp->daddr.in6;
 	iph->saddr = saddr;
 	iph->hop_limit		=	old_iph->hop_limit;
-- 
1.7.10.4
