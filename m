From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/25] ipv4: Use flowi4 in ipmr code.
Date: Sat, 12 Mar 2011 15:28:23 -0800 (PST)
Message-ID: <20110312.152823.232746241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756176Ab1CLX1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:27:45 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 348ED24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:28:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipmr.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 3b72b0a..1f62eae 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -148,14 +148,15 @@ static struct mr_table *ipmr_get_table(struct net *net, u32 id)
 	return NULL;
 }
 
-static int ipmr_fib_lookup(struct net *net, struct flowi *flp,
+static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 			   struct mr_table **mrt)
 {
 	struct ipmr_result res;
 	struct fib_lookup_arg arg = { .result = &res, };
 	int err;
 
-	err = fib_rules_lookup(net->ipv4.mr_rules_ops, flp, 0, &arg);
+	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
+			       flowi4_to_flowi(flp4), 0, &arg);
 	if (err < 0)
 		return err;
 	*mrt = res.mrt;
@@ -283,7 +284,7 @@ static struct mr_table *ipmr_get_table(struct net *net, u32 id)
 	return net->ipv4.mrt;
 }
 
-static int ipmr_fib_lookup(struct net *net, struct flowi *flp,
+static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 			   struct mr_table **mrt)
 {
 	*mrt = net->ipv4.mrt;
@@ -435,14 +436,14 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 	struct mr_table *mrt;
-	struct flowi fl = {
-		.flowi_oif	= dev->ifindex,
-		.flowi_iif	= skb->skb_iif,
-		.flowi_mark	= skb->mark,
+	struct flowi4 fl4 = {
+		.flowi4_oif	= dev->ifindex,
+		.flowi4_iif	= skb->skb_iif,
+		.flowi4_mark	= skb->mark,
 	};
 	int err;
 
-	err = ipmr_fib_lookup(net, &fl, &mrt);
+	err = ipmr_fib_lookup(net, &fl4, &mrt);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
@@ -1789,18 +1790,18 @@ dont_forward:
 
 static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct rtable *rt)
 {
-	struct flowi fl = {
-		.fl4_dst = rt->rt_key_dst,
-		.fl4_src = rt->rt_key_src,
-		.fl4_tos = rt->rt_tos,
-		.flowi_oif = rt->rt_oif,
-		.flowi_iif = rt->rt_iif,
-		.flowi_mark = rt->rt_mark,
+	struct flowi4 fl4 = {
+		.daddr = rt->rt_key_dst,
+		.saddr = rt->rt_key_src,
+		.flowi4_tos = rt->rt_tos,
+		.flowi4_oif = rt->rt_oif,
+		.flowi4_iif = rt->rt_iif,
+		.flowi4_mark = rt->rt_mark,
 	};
 	struct mr_table *mrt;
 	int err;
 
-	err = ipmr_fib_lookup(net, &fl, &mrt);
+	err = ipmr_fib_lookup(net, &fl4, &mrt);
 	if (err)
 		return ERR_PTR(err);
 	return mrt;
-- 
1.7.4.1

