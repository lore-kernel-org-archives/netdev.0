From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Remove rose_rx_ip
Date: Wed, 2 Mar 2005 22:00:04 +0100
Message-ID: <20050302210003.GA5997@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rose_rx_ip is unused and seems it's always been since it made it into the
kernel in 2.3.19.  Probably directly calling ip_rcv from a non-IP stack
is no longer a good idea anyway, so this should be solved differently.

Index: bk-afu/net/rose/rose_dev.c
===================================================================
--- bk-afu.orig/net/rose/rose_dev.c	2005-03-01 01:03:14.857307048 +0000
+++ bk-afu/net/rose/rose_dev.c	2005-03-01 01:06:30.364585424 +0000
@@ -37,38 +37,6 @@
 #include <net/ax25.h>
 #include <net/rose.h>
 
-/*
- *	Only allow IP over ROSE frames through if the netrom device is up.
- */
-
-int rose_rx_ip(struct sk_buff *skb, struct net_device *dev)
-{
-	struct net_device_stats *stats = netdev_priv(dev);
-
-#ifdef CONFIG_INET
-	if (!netif_running(dev)) {
-		stats->rx_errors++;
-		return 0;
-	}
-
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-
-	skb->protocol = htons(ETH_P_IP);
-
-	/* Spoof incoming device */
-	skb->dev      = dev;
-	skb->h.raw    = skb->data;
-	skb->nh.raw   = skb->data;
-	skb->pkt_type = PACKET_HOST;
-
-	ip_rcv(skb, skb->dev, NULL);
-#else
-	kfree_skb(skb);
-#endif
-	return 1;
-}
-
 static int rose_header(struct sk_buff *skb, struct net_device *dev, unsigned short type,
 	void *daddr, void *saddr, unsigned len)
 {
