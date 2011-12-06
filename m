From: David Miller <davem@davemloft.net>
Subject: ipv6: Make third arg to anycast_dst_alloc() bool.
Date: Tue, 06 Dec 2011 17:20:34 -0500 (EST)
Message-ID: <20111206.172034.888997660594430083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab1LFWUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:20:39 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6MKZLi027378
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 14:20:38 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    2 +-
 net/ipv6/addrconf.c     |    2 +-
 net/ipv6/anycast.c      |    2 +-
 net/ipv6/route.c        |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5e91b72..f9dbf47 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -102,7 +102,7 @@ extern void fib6_force_start_gc(struct net *net);
 
 extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 					   const struct in6_addr *addr,
-					   int anycast);
+					   bool anycast);
 
 extern int			ip6_dst_hoplimit(struct dst_entry *dst);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 058cc22..94f3fd9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -630,7 +630,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 		goto out;
 	}
 
-	rt = addrconf_dst_alloc(idev, addr, 0);
+	rt = addrconf_dst_alloc(idev, addr, false);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto out;
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index fc1cdcd..cc540f9 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -289,7 +289,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
 		goto out;
 	}
 
-	rt = addrconf_dst_alloc(idev, addr, 1);
+	rt = addrconf_dst_alloc(idev, addr, true);
 	if (IS_ERR(rt)) {
 		kfree(aca);
 		err = PTR_ERR(rt);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 09412ba..f0b582b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2056,7 +2056,7 @@ static int ip6_pkt_prohibit_out(struct sk_buff *skb)
 
 struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    const struct in6_addr *addr,
-				    int anycast)
+				    bool anycast)
 {
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-- 
1.7.7.3
