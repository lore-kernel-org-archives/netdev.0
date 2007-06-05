From: Patrick McHardy <kaber@trash.net>
Subject: [RFC DUMMY 05/09]: Use dev->stats
Date: Tue,  5 Jun 2007 16:12:59 +0200 (MEST)
Message-ID: <20070605141258.15650.44308.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63919 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763615AbXFEONA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:13:00 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[DUMMY]: Use dev->stats

Use dev->stats instead of netdev_priv().

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c5178079b5d191e34a516dc111be862e3382e32b
tree 339bf81b1270b51272a1e9ebc643188dc755a2ee
parent 0323e7d1e7d5042492684264cfcba6d7ff55c473
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:28 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:28 +0200

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
