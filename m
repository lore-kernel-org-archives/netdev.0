From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH 1/9] Use netdev_priv in NETROM and ROSE
Date: Sun, 30 Jan 2005 21:21:47 +0000
Message-ID: <20050130212147.GA6399__48858.5897641771$1107121580$gmane$org@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <200501302140.j0ULecjx006991@dea.linux-mips.net>
To: linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert the NETROM and ROSE protocol stacks to use netdev_priv().

 netrom/nr_dev.c |    8 ++++----
 rose/rose_dev.c |    6 +++---
 2 files changed, 7 insertions(+), 7 deletions(-)

Index: bk-afu/net/netrom/nr_dev.c
===================================================================
--- bk-afu.orig/net/netrom/nr_dev.c
+++ bk-afu/net/netrom/nr_dev.c
@@ -46,7 +46,7 @@
 
 int nr_rx_ip(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 
 	if (!netif_running(dev)) {
 		stats->rx_errors++;
@@ -73,7 +73,7 @@
 static int nr_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 	struct sk_buff *skbn;
 	unsigned char *bp = skb->data;
 	int len;
@@ -186,7 +186,7 @@
 
 static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 	dev_kfree_skb(skb);
 	stats->tx_errors++;
 	return 0;
@@ -194,7 +194,7 @@
 
 static struct net_device_stats *nr_get_stats(struct net_device *dev)
 {
-	return (struct net_device_stats *)dev->priv;
+	return netdev_priv(dev);
 }
 
 void nr_setup(struct net_device *dev)
Index: bk-afu/net/rose/rose_dev.c
===================================================================
--- bk-afu.orig/net/rose/rose_dev.c
+++ bk-afu/net/rose/rose_dev.c
@@ -57,7 +57,7 @@
 static int rose_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 	unsigned char *bp = (unsigned char *)skb->data;
 	struct sk_buff *skbn;
 
@@ -117,7 +117,7 @@
 
 static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "ROSE: rose_xmit - called when iface is down\n");
@@ -130,7 +130,7 @@
 
 static struct net_device_stats *rose_get_stats(struct net_device *dev)
 {
-	return (struct net_device_stats *)dev->priv;
+	return netdev_priv(dev);
 }
 
 void rose_setup(struct net_device *dev)
