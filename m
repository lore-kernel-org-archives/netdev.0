From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6 ndisc: Use pre-defined in6addr_linklocal_allnodes.
Date: Tue, 13 Nov 2012 02:50:17 +0900
Message-ID: <201211121750.qACHoHYE012220@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:43246 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab2KLRua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:50:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 4f47aa5..6ba4b54 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -535,7 +535,6 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 {
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa;
-	struct in6_addr mcaddr = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
 
 	idev = in6_dev_get(dev);
 	if (!idev)
@@ -543,7 +542,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		ndisc_send_na(dev, NULL, &mcaddr, &ifa->addr,
+		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &ifa->addr,
 			      /*router=*/ !!idev->cnf.forwarding,
 			      /*solicited=*/ false, /*override=*/ true,
 			      /*inc_opt=*/ true);
-- 
1.7.9.5
