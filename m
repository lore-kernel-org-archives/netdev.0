From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] net: Remove unused neighbour layer ops.
Date: Tue, 13 Dec 2011 17:38:44 -0500 (EST)
Message-ID: <20111213.173844.2152705529788577968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab1LMWiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 17:38:46 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBDMcioA023089
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 14:38:45 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's simpler to just keep these things out until there is a real user
of them, so we can see what the needs actually are, rather than keep
these things around as useless overhead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 -
 include/net/neighbour.h   |    1 -
 net/core/neighbour.c      |   10 ----------
 3 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6037308..6b9d4ed 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -974,7 +974,6 @@ struct net_device_ops {
 	int			(*ndo_set_features)(struct net_device *dev,
 						    netdev_features_t features);
 	int			(*ndo_neigh_construct)(struct neighbour *n);
-	void			(*ndo_neigh_destroy)(struct neighbour *n);
 };
 
 /*
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index e31f0a8..6814c4d 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -43,7 +43,6 @@ struct neigh_parms {
 #endif
 	struct net_device *dev;
 	struct neigh_parms *next;
-	int	(*neigh_setup)(struct neighbour *);
 	void	(*neigh_cleanup)(struct neighbour *);
 	struct neigh_table *tbl;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 4af151e..d57a40a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -497,13 +497,6 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 		}
 	}
 
-	/* Device specific setup. */
-	if (n->parms->neigh_setup &&
-	    (error = n->parms->neigh_setup(n)) < 0) {
-		rc = ERR_PTR(error);
-		goto out_neigh_release;
-	}
-
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
 	write_lock_bh(&tbl->lock);
@@ -717,9 +710,6 @@ void neigh_destroy(struct neighbour *neigh)
 	skb_queue_purge(&neigh->arp_queue);
 	neigh->arp_queue_len_bytes = 0;
 
-	if (dev->netdev_ops->ndo_neigh_destroy)
-		dev->netdev_ops->ndo_neigh_destroy(neigh);
-
 	dev_put(dev);
 	neigh_parms_put(neigh->parms);
 
-- 
1.7.7.4
