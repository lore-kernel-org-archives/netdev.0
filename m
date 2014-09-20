From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 6/8] ipv6: no need to bump rt_genid_ipv6 on address addition
Date: Sun, 21 Sep 2014 00:05:23 +0200
Message-ID: <90e7cea137e2ae927ebf598eb3996b2270839e76.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:57195 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751103AbaITWFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 18:05:39 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 155C020780
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:05:39 -0400 (EDT)
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fn_sernum takes care that on address insertion the sockets throw away
their cached dst_entries and do a relookup.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 39d3335..a2d2626 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4781,10 +4781,11 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 		if (ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->dst);
+
+		rt_genid_bump_ipv6(net);
 		break;
 	}
 	atomic_inc(&net->ipv6.dev_addr_genid);
-	rt_genid_bump_ipv6(net);
 }
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
-- 
1.9.3
