From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 2/4] [IPV6] ROUTE: Fix lifetime in netlink.
Date: Thu, 15 May 2008 18:18:02 +0900 (JST)
Message-ID: <20080515.181802.13113123.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44222 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYEOJRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We could not see appropriate lifetime if the route had been scheduled
to expired at 0 (in jiffies).  We should check rt6i_flags instead of
rt6i_expires to determine whether lifetime is valid or not.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 98aa50c..b45a7c0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2200,7 +2200,9 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 
 	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
 
-	expires = rt->rt6i_expires ? rt->rt6i_expires - jiffies : 0;
+	expires = (rt->rt6i_flags & RTF_EXPIRES) ?
+			rt->rt6i_expires - jiffies : 0;
+
 	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0,
 			       expires, rt->u.dst.error) < 0)
 		goto nla_put_failure;
-- 
1.4.4.4


