From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 5/5] ndisc: Make several arguments for ndisc_send_na()
 boolean.
Date: Mon, 21 Jan 2013 02:39:18 +0900
Message-ID: <50FC2BC6.7030006@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48886 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752371Ab3ATRjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 12:39:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 903191a..067a0d2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -490,7 +490,7 @@ static void __ndisc_send(struct net_device *dev,
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 			  const struct in6_addr *daddr,
 			  const struct in6_addr *solicited_addr,
-			  int router, int solicited, int override, int inc_opt)
+			  bool router, bool solicited, bool override, bool inc_opt)
 {
 	struct in6_addr tmpaddr;
 	struct inet6_ifaddr *ifp;
@@ -776,11 +776,11 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	}
 
 	if (is_router < 0)
-		is_router = !!idev->cnf.forwarding;
+		is_router = idev->cnf.forwarding;
 
 	if (dad) {
 		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &msg->target,
-			      is_router, 0, (ifp != NULL), 1);
+			      !!is_router, false, (ifp != NULL), true);
 		goto out;
 	}
 
@@ -801,8 +801,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			     NEIGH_UPDATE_F_OVERRIDE);
 	if (neigh || !dev->header_ops) {
 		ndisc_send_na(dev, neigh, saddr, &msg->target,
-			      is_router,
-			      1, (ifp != NULL && inc), inc);
+			      !!is_router,
+			      true, (ifp != NULL && inc), inc);
 		if (neigh)
 			neigh_release(neigh);
 	}
-- 
1.7.9.5
