From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/16] rtnetlink: Remove ts/tsage args to
 rtnl_put_cacheinfo().
Date: Tue, 10 Jul 2012 08:07:43 -0700 (PDT)
Message-ID: <20120710.080743.1452147583516206217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab2GJPHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:44 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7511B58662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nobody provides non-zero values any longer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/rtnetlink.h |    3 +--
 net/core/rtnetlink.c      |    4 +---
 net/decnet/dn_route.c     |    2 +-
 net/ipv4/route.c          |    3 +--
 net/ipv6/route.c          |    3 +--
 5 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index ea60b08..db71c4a 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -619,8 +619,7 @@ extern void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
 extern void rtnl_set_sk_err(struct net *net, u32 group, int error);
 extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
-			      u32 id, u32 ts, u32 tsage, long expires,
-			      u32 error);
+			      u32 id, long expires, u32 error);
 
 extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2b325c3..64127ee 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -615,7 +615,7 @@ nla_put_failure:
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 
 int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
-		       u32 ts, u32 tsage, long expires, u32 error)
+		       long expires, u32 error)
 {
 	struct rta_cacheinfo ci = {
 		.rta_lastuse = jiffies_to_clock_t(jiffies - dst->lastuse),
@@ -623,8 +623,6 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 		.rta_clntref = atomic_read(&(dst->__refcnt)),
 		.rta_error = error,
 		.rta_id =  id,
-		.rta_ts = ts,
-		.rta_tsage = tsage,
 	};
 
 	if (expires)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 707027f..b5594cc 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1590,7 +1590,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 		goto errout;
 
 	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
-	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0, expires,
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires,
 			       rt->dst.error) < 0)
 		goto errout;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d4834e2..67b0874 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2931,8 +2931,7 @@ static int rt_fill_info(struct net *net,
 				goto nla_put_failure;
 	}
 
-	if (rtnl_put_cacheinfo(skb, &rt->dst, id, 0, 0,
-			       expires, error) < 0)
+	if (rtnl_put_cacheinfo(skb, &rt->dst, id, expires, error) < 0)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b7eb51e..563f12c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2471,8 +2471,7 @@ static int rt6_fill_node(struct net *net,
 	else
 		expires = INT_MAX;
 
-	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0,
-			       expires, rt->dst.error) < 0)
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
-- 
1.7.10.4
