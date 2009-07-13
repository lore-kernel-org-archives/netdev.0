From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH] net: Rename lookup_neigh_params function
Date: Mon, 13 Jul 2009 10:53:40 +0200
Message-ID: <1247475220-20518-1-git-send-email-klto@zhaw.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <klto@zhaw.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:33146 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824AbZGMJAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2009 05:00:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename lookup_neigh_params to lookup_neigh_parms as the struct is named
neigh_parms and all other functions dealing with the struct carry
neigh_parms in their names.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 net/core/neighbour.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 163b4f5..c6f9ad8 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1316,7 +1316,7 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 }
 EXPORT_SYMBOL(pneigh_enqueue);
 
-static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
+static inline struct neigh_parms *lookup_neigh_parms(struct neigh_table *tbl,
 						      struct net *net, int ifindex)
 {
 	struct neigh_parms *p;
@@ -1337,7 +1337,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 	struct net *net = dev_net(dev);
 	const struct net_device_ops *ops = dev->netdev_ops;
 
-	ref = lookup_neigh_params(tbl, net, 0);
+	ref = lookup_neigh_parms(tbl, net, 0);
 	if (!ref)
 		return NULL;
 
@@ -1906,7 +1906,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		if (tbp[NDTPA_IFINDEX])
 			ifindex = nla_get_u32(tbp[NDTPA_IFINDEX]);
 
-		p = lookup_neigh_params(tbl, net, ifindex);
+		p = lookup_neigh_parms(tbl, net, ifindex);
 		if (p == NULL) {
 			err = -ENOENT;
 			goto errout_tbl_lock;
-- 
1.6.0.4

