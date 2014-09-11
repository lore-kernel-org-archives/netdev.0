From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 2/6] ipv6: no need to bump rt_genid_ipv6 on address change anymore
Date: Fri, 12 Sep 2014 01:21:49 +0200
Message-ID: <d3e8946144bfce1e2d20bc283c9400079d3ec243.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:45148 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbaIKXWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:22:01 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 117D3209A4
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:22:01 -0400 (EDT)
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fn_sernum is now modified on fib6_del events so we don't need to
bump the ipv6 genid anymore.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad4598f..16ce390 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4781,7 +4781,6 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		break;
 	}
 	atomic_inc(&net->ipv6.dev_addr_genid);
-	rt_genid_bump_ipv6(net);
 }
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
-- 
1.9.3
