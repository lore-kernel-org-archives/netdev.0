From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net/core/dev printk message priority
Date: Fri, 7 Jul 2006 16:41:04 -0700
Message-ID: <20060707164104.32503b6d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51126 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932418AbWGGXlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 19:41:07 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The printk's in the network device interface code should all be tagged with
severity.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- a/net/core/dev.c	2006-07-07 13:02:31.000000000 -0700
+++ b/net/core/dev.c	2006-07-07 16:28:22.000000000 -0700
@@ -1727,7 +1727,7 @@
 	if (dev->qdisc_ingress) {
 		__u32 ttl = (__u32) G_TC_RTTL(skb->tc_verd);
 		if (MAX_RED_LOOP < ttl++) {
-			printk("Redir loop detected Dropping packet (%s->%s)\n",
+			printk(KERN_WARNING "Redir loop detected Dropping packet (%s->%s)\n",
 				skb->input_dev->name, skb->dev->name);
 			return TC_ACT_SHOT;
 		}
@@ -2922,7 +2922,7 @@
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
 	    !(dev->features & NETIF_F_ALL_CSUM)) {
-		printk("%s: Dropping NETIF_F_SG since no checksum feature.\n",
+		printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no checksum feature.\n",
 		       dev->name);
 		dev->features &= ~NETIF_F_SG;
 	}
@@ -2930,7 +2930,7 @@
 	/* TSO requires that SG is present as well. */
 	if ((dev->features & NETIF_F_TSO) &&
 	    !(dev->features & NETIF_F_SG)) {
-		printk("%s: Dropping NETIF_F_TSO since no SG feature.\n",
+		printk(KERN_NOTICE "%s: Dropping NETIF_F_TSO since no SG feature.\n",
 		       dev->name);
 		dev->features &= ~NETIF_F_TSO;
 	}
