From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Remove unused argument to addrconf_dad_start().
Date: Sat, 14 Apr 2012 21:38:25 -0400 (EDT)
Message-ID: <20120414.213825.1028304401601935512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab2DOBi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 21:38:29 -0400
Received: from localhost (cpe-66-108-118-54.nyc.res.rr.com [66.108.118.54])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q3F1cQLF011495
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 14 Apr 2012 18:38:28 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next.

 net/ipv6/addrconf.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fcd230a..5c031c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -149,7 +149,7 @@ static void addrconf_type_change(struct net_device *dev,
 				 unsigned long event);
 static int addrconf_ifdown(struct net_device *dev, int how);
 
-static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
+static void addrconf_dad_start(struct inet6_ifaddr *ifp);
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_dad_run(struct inet6_dev *idev);
@@ -929,7 +929,7 @@ retry:
 	ift->tstamp = tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
 
-	addrconf_dad_start(ift, 0);
+	addrconf_dad_start(ift);
 	in6_ifa_put(ift);
 	in6_dev_put(idev);
 out:
@@ -1959,7 +1959,7 @@ ok:
 
 			update_lft = create = 1;
 			ifp->cstamp = jiffies;
-			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
+			addrconf_dad_start(ifp);
 		}
 
 		if (ifp) {
@@ -2238,7 +2238,7 @@ static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *p
 		 * that the Optimistic flag should not be set for
 		 * manually configured addresses
 		 */
-		addrconf_dad_start(ifp, 0);
+		addrconf_dad_start(ifp);
 		in6_ifa_put(ifp);
 		addrconf_verify(0);
 		return 0;
@@ -2425,7 +2425,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
-		addrconf_dad_start(ifp, 0);
+		addrconf_dad_start(ifp);
 		in6_ifa_put(ifp);
 	}
 }
@@ -2920,7 +2920,7 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 	addrconf_mod_timer(ifp, AC_DAD, rand_num);
 }
 
-static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
-- 
1.7.7.6
