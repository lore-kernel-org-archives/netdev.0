From: Fan Du <fan.du@windriver.com>
Subject: [RESEND PATCH net-next] net ipv6: Remove rebundant rt6i_nsiblings initialization
Date: Mon, 22 Jul 2013 14:20:12 +0800
Message-ID: <1374474012-22640-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nicolas.dichtel@6wind.com>, <yoshfuji@linux-ipv6.org>,
	<jmorris@namei.org>, <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40754 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab3GVGUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 02:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seting rt->rt6i_nsiblings to zero is rebundant, because above memset
zeroed the rest of rt excluding the first dst memember.

Signed-off-by: Fan Du <fan.du@windriver.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: James Morris <jmorris@namei.org>
---
 net/ipv6/route.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 45ca9af..ce96163 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -285,7 +285,6 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 		rt->rt6i_genid = rt_genid_ipv6(net);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
-		rt->rt6i_nsiblings = 0;
 	}
 	return rt;
 }
-- 
1.7.9.5
