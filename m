From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: send unsolicited neighbour advertisements to all-nodes
Date: Wed, 7 Nov 2012 03:18:41 +0100
Message-ID: <20121107021841.GC26398@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38128 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab2KGCSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 21:18:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As documented in RFC4861 (Neighbor Discovery for IP version 6) 7.2.6.,
unsolicited neighbour advertisements should be sent to the all-nodes
multicast address.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ndisc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 61b3354..8271db6 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -535,7 +535,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 {
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa;
-	struct in6_addr mcaddr;
+	struct in6_addr mcaddr = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
 
 	idev = in6_dev_get(dev);
 	if (!idev)
@@ -543,7 +543,6 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		addrconf_addr_solict_mult(&ifa->addr, &mcaddr);
 		ndisc_send_na(dev, NULL, &mcaddr, &ifa->addr,
 			      /*router=*/ !!idev->cnf.forwarding,
 			      /*solicited=*/ false, /*override=*/ true,
