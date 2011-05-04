From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] ipv4: Use flowi4->{daddr,saddr} in ipip_tunnel_xmit().
Date: Wed, 04 May 2011 13:19:36 -0700 (PDT)
Message-ID: <20110504.131936.28818827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752327Ab1EDUUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:20:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 20BB524C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 13:19:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_{dst,src}

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 88d96bd..bfa0b98 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -550,8 +550,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	iph->frag_off		=	df;
 	iph->protocol		=	IPPROTO_IPIP;
 	iph->tos		=	INET_ECN_encapsulate(tos, old_iph->tos);
-	iph->daddr		=	rt->rt_dst;
-	iph->saddr		=	rt->rt_src;
+	iph->daddr		=	fl4.daddr;
+	iph->saddr		=	fl4.saddr;
 
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	old_iph->ttl;
-- 
1.7.4.5

