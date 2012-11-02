From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RESEND PATCH net-next] ipv6/multipath: remove flag NLM_F_EXCL after the first nexthop
Date: Fri,  2 Nov 2012 09:58:22 +0100
Message-ID: <1351846702-4982-1-git-send-email-nicolas.dichtel@6wind.com>
References: <50896D47.7030500@6wind.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, joe@perches.com,
	bernat@luffy.cx, eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48870 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab2KBIsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 04:48:03 -0400
In-Reply-To: <50896D47.7030500@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib6_add_rt2node() will reject the nexthop if this flag is set, so
we perform the check only for the first nexthop.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c42650c..9c7b5d8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2449,6 +2449,12 @@ beginning:
 				goto beginning;
 			}
 		}
+		/* Because each route is added like a single route we remove
+		 * this flag after the first nexthop (if there is a collision,
+		 * we have already fail to add the first nexthop:
+		 * fib6_add_rt2node() has reject it).
+		 */
+		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~NLM_F_EXCL;
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
-- 
1.7.12
