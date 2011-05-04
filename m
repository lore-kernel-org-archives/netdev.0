From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] ipv6: Use flowi4->{daddr,saddr} in ipip6_tunnel_xmit().
Date: Wed, 04 May 2011 13:19:43 -0700 (PDT)
Message-ID: <20110504.131943.70188860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755544Ab1EDUUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:20:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E66E124C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 13:19:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_{dst,src}

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/sit.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a24fb14..c53abcf 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -828,8 +828,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	iph->frag_off		=	df;
 	iph->protocol		=	IPPROTO_IPV6;
 	iph->tos		=	INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
-	iph->daddr		=	rt->rt_dst;
-	iph->saddr		=	rt->rt_src;
+	iph->daddr		=	fl4.daddr;
+	iph->saddr		=	fl4.saddr;
 
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	iph6->hop_limit;
-- 
1.7.4.5

