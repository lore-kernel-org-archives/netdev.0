From: Ralf Baechle <ralf@linux-mips.org>
Subject: [janitor] use netdev_priv() in NET/ROM and ROSE.
Date: Thu, 4 Mar 2004 23:04:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304220421.GA16866@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev_priv-ify two more drivers.

Index: net/netrom/nr_dev.c
===================================================================
RCS file: /home/cvs/linux/net/netrom/nr_dev.c,v
retrieving revision 1.16
diff -u -r1.16 nr_dev.c
--- net/netrom/nr_dev.c	10 Jan 2004 04:59:58 -0000	1.16
+++ net/netrom/nr_dev.c	4 Mar 2004 21:58:28 -0000
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
Index: net/rose/rose_dev.c
===================================================================
RCS file: /home/cvs/linux/net/rose/rose_dev.c,v
retrieving revision 1.17
diff -u -r1.17 rose_dev.c
--- net/rose/rose_dev.c	15 Aug 2003 15:14:41 -0000	1.17
+++ net/rose/rose_dev.c	4 Mar 2004 21:58:28 -0000
@@ -43,7 +43,7 @@
 
 int rose_rx_ip(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 
 #ifdef CONFIG_INET
 	if (!netif_running(dev)) {
@@ -89,7 +89,7 @@
 static int rose_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 	unsigned char *bp = (unsigned char *)skb->data;
 	struct sk_buff *skbn;
 
@@ -149,7 +149,7 @@
 
 static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "ROSE: rose_xmit - called when iface is down\n");
@@ -162,7 +162,7 @@
 
 static struct net_device_stats *rose_get_stats(struct net_device *dev)
 {
-	return (struct net_device_stats *)dev->priv;
+	return netdev_priv(dev);
 }
 
 void rose_setup(struct net_device *dev)
