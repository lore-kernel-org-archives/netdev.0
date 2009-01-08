From: Oliver Neukum <oliver@neukum.org>
Subject: [patch]convert pegasus driver to net_device_ops
Date: Thu, 8 Jan 2009 18:16:42 +0100
Message-ID: <200901081816.43102.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	petkan@users.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:58068 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbZAHRQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 12:16:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the pegasus driver to use of the new net_device_ops structure

Signed-off-by: Oliver Neukum<oneukum@suse.de>

	Regards
		Oliver

----

--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -93,6 +93,7 @@ module_param (msg_level, int, 0);
 MODULE_PARM_DESC (msg_level, "Override default message level");
 
 MODULE_DEVICE_TABLE(usb, pegasus_ids);
+static const struct net_device_ops pegasus_netdev_ops;
 
 static int update_eth_regs_async(pegasus_t *);
 /* Aargh!!! I _really_ hate such tweaks */
@@ -1360,14 +1361,10 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->intf = intf;
 	pegasus->usb = dev;
 	pegasus->net = net;
-	net->open = pegasus_open;
-	net->stop = pegasus_close;
+
+
 	net->watchdog_timeo = PEGASUS_TX_TIMEOUT;
-	net->tx_timeout = pegasus_tx_timeout;
-	net->do_ioctl = pegasus_ioctl;
-	net->hard_start_xmit = pegasus_start_xmit;
-	net->set_multicast_list = pegasus_set_multicast;
-	net->get_stats = pegasus_netdev_stats;
+	net->netdev_ops = &pegasus_netdev_ops;
 	SET_ETHTOOL_OPS(net, &ops);
 	pegasus->mii.dev = net;
 	pegasus->mii.mdio_read = mdio_read;
@@ -1482,6 +1479,16 @@ static int pegasus_resume (struct usb_interface *intf)
 	return 0;
 }
 
+static const struct net_device_ops pegasus_netdev_ops = {
+	.ndo_open =			pegasus_open,
+	.ndo_stop =			pegasus_close,
+	.ndo_do_ioctl =			pegasus_ioctl,
+	.ndo_start_xmit =		pegasus_start_xmit,
+	.ndo_set_multicast_list =	pegasus_set_multicast,
+	.ndo_get_stats =		pegasus_netdev_stats,
+	.ndo_tx_timeout =		pegasus_tx_timeout,
+};
+
 static struct usb_driver pegasus_driver = {
 	.name = driver_name,
 	.probe = pegasus_probe,
