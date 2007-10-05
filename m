From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.24] fix network compile warnings
Date: Thu, 4 Oct 2007 20:10:36 -0700
Message-ID: <20071004201036.2665f6cc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47199 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753408AbXJEDPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 23:15:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One unused variable warning, and other is failure to check result.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-10-04 17:40:34.000000000 -0700
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-10-04 17:44:33.000000000 -0700
@@ -854,8 +854,8 @@ struct ipoib_neigh *ipoib_neigh_alloc(st
 
 void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct sk_buff *skb;
+
 	*to_ipoib_neigh(neigh->neighbour) = NULL;
 	while ((skb = __skb_dequeue(&neigh->queue))) {
 		++dev->stats.tx_dropped;
--- a/drivers/net/cxgb3/cxgb3_main.c	2007-10-04 17:40:34.000000000 -0700
+++ b/drivers/net/cxgb3/cxgb3_main.c	2007-10-04 17:45:58.000000000 -0700
@@ -933,7 +933,8 @@ static int offload_open(struct net_devic
 	init_smt(adapter);
 
 	/* Never mind if the next step fails */
-	sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group);
+	if (sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group))
+		dev_dbg(&tdev->lldev->dev, "sysfs offload attribute create failed\n");
 
 	/* Call back all registered clients */
 	cxgb3_add_clients(tdev);
