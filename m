From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 07/30] appletalk: convert LTPC to net_device_ops
Date: Thu, 26 Mar 2009 18:11:21 -0700
Message-ID: <20090327011255.457092659@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43168 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbZC0BZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:25:07 -0400
Content-Disposition: inline; filename=ltpc-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/appletalk/ltpc.c	2009-03-22 23:12:24.795261968 -0700
+++ b/drivers/net/appletalk/ltpc.c	2009-03-22 23:12:24.809261793 -0700
@@ -1012,6 +1012,12 @@ static int __init ltpc_probe_dma(int bas
 	return (want & 2) ? 3 : 1;
 }
 
+static const struct net_device_ops ltpc_netdev = {
+	.ndo_start_xmit		= ltpc_xmit,
+	.ndo_do_ioctl		= ltpc_ioctl,
+	.ndo_set_multicast_list = set_multicast_list,
+};
+
 struct net_device * __init ltpc_probe(void)
 {
 	struct net_device *dev;
@@ -1118,13 +1124,7 @@ struct net_device * __init ltpc_probe(vo
 	else
 		printk(KERN_INFO "Apple/Farallon LocalTalk-PC card at %03x, DMA%d.  Using polled mode.\n",io,dma);
 
-	/* Fill in the fields of the device structure with ethernet-generic values. */
-	dev->hard_start_xmit = ltpc_xmit;
-
-	/* add the ltpc-specific things */
-	dev->do_ioctl = &ltpc_ioctl;
-
-	dev->set_multicast_list = &set_multicast_list;
+	dev->netdev_ops = &ltpc_netdev;
 	dev->mc_list = NULL;
 	dev->base_addr = io;
 	dev->irq = irq;


