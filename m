From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7] ipv6: Add rt6_get_peer() helper.
Date: Thu, 02 Dec 2010 12:42:14 -0800 (PST)
Message-ID: <20101202.124214.183044954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757917Ab0LBUlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:41:47 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0A45824C088
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:42:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To go along side ipv4's rt_get_peer().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 23fed28..67d154a 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -59,6 +59,15 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
 extern void			rt6_bind_peer(struct rt6_info *rt,
 					      int create);
 
+static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
+{
+	if (rt->rt6i_peer)
+		return rt->rt6i_peer;
+
+	rt6_bind_peer(rt, 0);
+	return rt->rt6i_peer;
+}
+
 extern void			ip6_route_input(struct sk_buff *skb);
 
 extern struct dst_entry *	ip6_route_output(struct net *net,
-- 
1.7.3.2

