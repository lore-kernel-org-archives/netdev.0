From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] iph: use default get_stats
Date: Wed, 8 Jun 2011 11:09:13 -0700
Message-ID: <20110608110913.54becfba@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39265 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab1FHSJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 14:09:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver keeps stats in net_device stats therefore it
does not need to define it's own get_stats hook.

Also, use standard format for net_device_ops (without &).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/usb/ipheth.c	2011-05-12 08:39:09.000000000 -0700
+++ b/drivers/net/usb/ipheth.c	2011-06-08 11:03:50.011606145 -0700
@@ -409,12 +409,6 @@ static void ipheth_tx_timeout(struct net
 	usb_unlink_urb(dev->tx_urb);
 }
 
-static struct net_device_stats *ipheth_stats(struct net_device *net)
-{
-	struct ipheth_device *dev = netdev_priv(net);
-	return &dev->net->stats;
-}
-
 static u32 ipheth_ethtool_op_get_link(struct net_device *net)
 {
 	struct ipheth_device *dev = netdev_priv(net);
@@ -426,11 +420,10 @@ static struct ethtool_ops ops = {
 };
 
 static const struct net_device_ops ipheth_netdev_ops = {
-	.ndo_open = &ipheth_open,
-	.ndo_stop = &ipheth_close,
-	.ndo_start_xmit = &ipheth_tx,
-	.ndo_tx_timeout = &ipheth_tx_timeout,
-	.ndo_get_stats = &ipheth_stats,
+	.ndo_open = ipheth_open,
+	.ndo_stop = ipheth_close,
+	.ndo_start_xmit = ipheth_tx,
+	.ndo_tx_timeout = ipheth_tx_timeout,
 };
 
 static int ipheth_probe(struct usb_interface *intf,
