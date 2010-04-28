From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/4] bridge: multicast_flood cleanup
Date: Tue, 27 Apr 2010 18:01:07 -0700
Message-ID: <20100428010336.317810041@vyatta.com>
References: <20100428010103.386761596@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46582 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277Ab0D1BHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 21:07:22 -0400
Content-Disposition: inline; filename=br-flood-clean.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move some declarations around to make it clearer which variables
are being used inside loop.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_forward.c	2010-04-27 17:58:25.739592056 -0700
+++ b/net/bridge/br_forward.c	2010-04-27 17:59:17.182654034 -0700
@@ -208,17 +208,15 @@ static void br_multicast_flood(struct ne
 {
 	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
 	struct net_bridge *br = netdev_priv(dev);
-	struct net_bridge_port *port;
-	struct net_bridge_port *lport, *rport;
-	struct net_bridge_port *prev;
+	struct net_bridge_port *prev = NULL;
 	struct net_bridge_port_group *p;
 	struct hlist_node *rp;
 
-	prev = NULL;
-
 	rp = rcu_dereference(br->router_list.first);
 	p = mdst ? rcu_dereference(mdst->ports) : NULL;
 	while (p || rp) {
+		struct net_bridge_port *port, *lport, *rport;
+
 		lport = p ? p->port : NULL;
 		rport = rp ? hlist_entry(rp, struct net_bridge_port, rlist) :
 			     NULL;

-- 

