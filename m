From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/2] ipv6: Compare addresses only bits up to the prefix
 length (RFC6724).
Date: Tue, 11 Sep 2012 13:41:07 +0900
Message-ID: <201209110508.q8B58Min015633@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59723 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab2IKFWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 01:22:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compare bits up to the source address's prefix length only to
allows DNS load balancing to continue to be used as a tie breaker.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1237d5d..5fd8ec8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1070,8 +1070,10 @@ static int ipv6_get_saddr_eval(struct net *net,
 		break;
 	case IPV6_SADDR_RULE_PREFIX:
 		/* Rule 8: Use longest matching prefix */
-		score->matchlen = ret = ipv6_addr_diff(&score->ifa->addr,
-						       dst->addr);
+		ret = ipv6_addr_diff(&score->ifa->addr, dst->addr);
+		if (ret > score->ifa->prefix_len)
+			ret = score->ifa->prefix_len;
+		score->matchlen = ret;
 		break;
 	default:
 		ret = 0;
-- 
1.7.5.4
