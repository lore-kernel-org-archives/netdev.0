From: Patrick McHardy <kaber@trash.net>
Subject: [DUMMY 04/18]: Use dev->stats
Date: Wed, 13 Jun 2007 18:50:47 +0200 (MEST)
Message-ID: <20070613165044.7780.18805.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35936 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758821AbXFMQut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:49 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[DUMMY]: Use dev->stats

Use dev->stats instead of netdev_priv().

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit af03e9fd45eb64f27bcc2ac79d0d615e563100a9
tree 9a1aa56016d17805dd2b41e955fbb41d46d9c3f5
parent 8a4171f86c516a43a7ed07f198c6cad2273ce2a7
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:02 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:29 +0200

 drivers/net/dummy.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 60673bc..91b474c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -38,7 +38,6 @@
 static int numdummies = 1;
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *dummy_get_stats(struct net_device *dev);
 
 static int dummy_set_address(struct net_device *dev, void *p)
 {
@@ -59,7 +58,6 @@ static void set_multicast_list(struct net_device *dev)
 static void __init dummy_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
-	dev->get_stats = dummy_get_stats;
 	dev->hard_start_xmit = dummy_xmit;
 	dev->set_multicast_list = set_multicast_list;
 	dev->set_mac_address = dummy_set_address;
@@ -76,20 +74,13 @@ static void __init dummy_setup(struct net_device *dev)
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = netdev_priv(dev);
-
-	stats->tx_packets++;
-	stats->tx_bytes+=skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	dev_kfree_skb(skb);
 	return 0;
 }
 
-static struct net_device_stats *dummy_get_stats(struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
 static struct net_device **dummies;
 
 /* Number of dummy devices to be set up by this module. */
@@ -101,8 +92,7 @@ static int __init dummy_init_one(int index)
 	struct net_device *dev_dummy;
 	int err;
 
-	dev_dummy = alloc_netdev(sizeof(struct net_device_stats),
-				 "dummy%d", dummy_setup);
+	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
 
 	if (!dev_dummy)
 		return -ENOMEM;
