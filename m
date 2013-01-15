From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 10/13] ipv6: Do not depend on rt->n in ip6_pol_route().
Date: Wed, 16 Jan 2013 01:46:18 +0900
Message-ID: <50F587DA.5030904@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41322 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757061Ab3AOQqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:46:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ffdc8a6..e30a2aa 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -936,9 +936,10 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY))) {
+		BUG_ON(rt->n != NULL);
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST))
+	} else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
-- 
1.7.9.5
