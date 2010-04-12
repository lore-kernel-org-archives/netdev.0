From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/4] ipv6: additional ref count for hash list unnecessary
Date: Mon, 12 Apr 2010 08:41:33 -0700
Message-ID: <20100412154255.811051512@vyatta.com>
References: <20100412154130.397252857@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47333 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540Ab0DLPqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 11:46:47 -0400
Content-Disposition: inline; filename=ipv6-addrconf3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since an address in hash list has to already have a ref count,
no additional ref count is needed. 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/addrconf.c	2010-04-11 12:25:32.609002374 -0700
+++ b/net/ipv6/addrconf.c	2010-04-11 12:26:52.715246164 -0700
@@ -675,7 +675,6 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	hash = ipv6_addr_hash(addr);
 
 	hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
-	in6_ifa_hold(ifa);
 	spin_unlock(&addrconf_hash_lock);
 
 	write_lock(&idev->lock);
@@ -723,7 +722,6 @@ static void ipv6_del_addr(struct inet6_i
 
 	spin_lock_bh(&addrconf_hash_lock);
 	hlist_del_init_rcu(&ifp->addr_lst);
-	__in6_ifa_put(ifp);
 	spin_unlock_bh(&addrconf_hash_lock);
 
 	write_lock_bh(&idev->lock);
@@ -2712,7 +2710,6 @@ static int addrconf_ifdown(struct net_de
 			/* clear hash table */
 			spin_lock_bh(&addrconf_hash_lock);
 			hlist_del_init_rcu(&ifa->addr_lst);
-			__in6_ifa_put(ifa);
 			spin_unlock_bh(&addrconf_hash_lock);
 		}
 

-- 

