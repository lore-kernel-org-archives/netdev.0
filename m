From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 06/45] netrom: convert to internal net_device_stats
Date: Fri, 09 Jan 2009 15:01:03 -0800
Message-ID: <20090109230137.149310736@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44993 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932824AbZAIXW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:22:57 -0500
Content-Disposition: inline; filename=netrom-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/netrom.h   |    4 ----
 net/netrom/af_netrom.c |    2 +-
 net/netrom/nr_dev.c    |   14 ++------------
 3 files changed, 3 insertions(+), 17 deletions(-)

--- a/net/netrom/af_netrom.c	2009-01-09 13:37:29.000000000 -0800
+++ b/net/netrom/af_netrom.c	2009-01-09 13:37:46.000000000 -0800
@@ -1432,7 +1432,7 @@ static int __init nr_proto_init(void)
 		struct net_device *dev;
 
 		sprintf(name, "nr%d", i);
-		dev = alloc_netdev(sizeof(struct nr_private), name, nr_setup);
+		dev = alloc_netdev(0, name, nr_setup);
 		if (!dev) {
 			printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device structure\n");
 			goto fail;
--- a/include/net/netrom.h	2009-01-09 13:37:29.000000000 -0800
+++ b/include/net/netrom.h	2009-01-09 13:37:31.000000000 -0800
@@ -59,10 +59,6 @@ enum {
 #define NR_MAX_WINDOW_SIZE		127			/* Maximum Window Allowable - 127 */
 #define	NR_MAX_PACKET_SIZE		236			/* Maximum Packet Length - 236 */
 
-struct nr_private {
-	struct net_device_stats	stats;
-};
-
 struct nr_sock {
 	struct sock		sock;
 	ax25_address		user_addr, source_addr, dest_addr;
--- a/net/netrom/nr_dev.c	2009-01-09 13:37:29.000000000 -0800
+++ b/net/netrom/nr_dev.c	2009-01-09 13:52:57.000000000 -0800
@@ -42,7 +42,7 @@
 
 int nr_rx_ip(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
 
 	if (!netif_running(dev)) {
 		stats->rx_dropped++;
@@ -171,8 +171,7 @@ static int nr_close(struct net_device *d
 
 static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct nr_private *nr = netdev_priv(dev);
-	struct net_device_stats *stats = &nr->stats;
+	struct net_device_stats *stats = &dev->stats;
 	unsigned int len = skb->len;
 
 	if (!nr_route_frame(skb, NULL)) {
@@ -187,13 +186,6 @@ static int nr_xmit(struct sk_buff *skb, 
 	return 0;
 }
 
-static struct net_device_stats *nr_get_stats(struct net_device *dev)
-{
-	struct nr_private *nr = netdev_priv(dev);
-
-	return &nr->stats;
-}
-
 static const struct header_ops nr_header_ops = {
 	.create	= nr_header,
 	.rebuild= nr_rebuild_header,
@@ -215,6 +207,4 @@ void nr_setup(struct net_device *dev)
 
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP;
-
-	dev->get_stats 		= nr_get_stats;
 }


