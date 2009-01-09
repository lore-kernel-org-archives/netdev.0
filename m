From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 08/45] rose: convert to internal net_device_stats
Date: Fri, 09 Jan 2009 15:01:05 -0800
Message-ID: <20090109230137.296645104@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44996 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932827AbZAIXW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:22:57 -0500
Content-Disposition: inline; filename=rose-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/rose/af_rose.c	2009-01-09 13:39:17.000000000 -0800
+++ b/net/rose/af_rose.c	2009-01-09 13:39:34.000000000 -0800
@@ -1587,8 +1587,7 @@ static int __init rose_proto_init(void)
 		char name[IFNAMSIZ];
 
 		sprintf(name, "rose%d", i);
-		dev = alloc_netdev(sizeof(struct net_device_stats),
-				   name, rose_setup);
+		dev = alloc_netdev(0, name, rose_setup);
 		if (!dev) {
 			printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate memory\n");
 			rc = -ENOMEM;
--- a/net/rose/rose_dev.c	2009-01-09 13:39:17.000000000 -0800
+++ b/net/rose/rose_dev.c	2009-01-09 13:52:51.000000000 -0800
@@ -57,7 +57,7 @@ static int rose_rebuild_header(struct sk
 {
 #ifdef CONFIG_INET
 	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
 	unsigned char *bp = (unsigned char *)skb->data;
 	struct sk_buff *skbn;
 	unsigned int len;
@@ -133,7 +133,7 @@ static int rose_close(struct net_device 
 
 static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "ROSE: rose_xmit - called when iface is down\n");
@@ -144,11 +144,6 @@ static int rose_xmit(struct sk_buff *skb
 	return 0;
 }
 
-static struct net_device_stats *rose_get_stats(struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
 static const struct header_ops rose_header_ops = {
 	.create	= rose_header,
 	.rebuild= rose_rebuild_header,
@@ -169,5 +164,4 @@ void rose_setup(struct net_device *dev)
 
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP;
-	dev->get_stats = rose_get_stats;
 }


