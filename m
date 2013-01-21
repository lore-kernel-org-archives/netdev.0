From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ndisc: Do not try to update "updated" time if neighbour
 has already gone.
Date: Tue, 22 Jan 2013 04:58:50 +0900
Message-ID: <50FD9DFA.6090001@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50591 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756544Ab3AUT6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 14:58:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2152caea ("ipv6: Do not depend on rt->n in rt6_probe().")
introduce a bug to try to update "updated" time in neighbour
structure.
Update the "updated" time only if neighbour is available.

Bug was found by Dan Carpenter <dan.carpenter@oracle.com>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2d94d5a..f3328bc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -492,10 +492,10 @@ static void rt6_probe(struct rt6_info *rt)
 		struct in6_addr mcaddr;
 		struct in6_addr *target;
 
-		neigh->updated = jiffies;
-
-		if (neigh)
+		if (neigh) {
+			neigh->updated = jiffies;
 			write_unlock(&neigh->lock);
+		}
 
 		target = (struct in6_addr *)&rt->rt6i_gateway;
 		addrconf_addr_solict_mult(target, &mcaddr);
-- 
1.7.9.5
