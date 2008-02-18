From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPV6]: Use BUG_ON instead of if + BUG in fib6_del_route.
Date: Mon, 18 Feb 2008 15:50:11 +0300
Message-ID: <47B97F03.7080105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44906 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbYBRMuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 07:50:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index f93407c..bab72b6 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1151,7 +1151,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 			fn = fn->parent;
 		}
 		/* No more references are possible at this point. */
-		if (atomic_read(&rt->rt6i_ref) != 1) BUG();
+		BUG_ON(atomic_read(&rt->rt6i_ref) != 1);
 	}
 
 	inet6_rt_notify(RTM_DELROUTE, rt, info);
