From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 25/77] usbnet: convert hso driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:52 -0700
Message-ID: <20090321053714.437968008@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36581 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760896AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-hso.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/hso.c	2009-03-09 08:23:41.851308905 -0700
+++ b/drivers/net/usb/hso.c	2009-03-20 08:35:11.089026883 -0700
@@ -2428,6 +2428,13 @@ static void hso_free_net_device(struct h
 	kfree(hso_dev);
 }
 
+static const struct net_device_ops hso_netdev_ops = {
+	.ndo_open	= hso_net_open,
+	.ndo_stop	= hso_net_close,
+	.ndo_start_xmit = hso_net_start_xmit,
+	.ndo_tx_timeout = hso_net_tx_timeout,
+};
+
 /* initialize the network interface */
 static void hso_net_init(struct net_device *net)
 {
@@ -2436,10 +2443,7 @@ static void hso_net_init(struct net_devi
 	D1("sizeof hso_net is %d", (int)sizeof(*hso_net));
 
 	/* fill in the other fields */
-	net->open = hso_net_open;
-	net->stop = hso_net_close;
-	net->hard_start_xmit = hso_net_start_xmit;
-	net->tx_timeout = hso_net_tx_timeout;
+	net->netdev_ops = &hso_netdev_ops;
 	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
 	net->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 	net->type = ARPHRD_NONE;

-- 

