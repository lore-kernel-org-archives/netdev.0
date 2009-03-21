From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 26/77] usbnet: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:35:53 -0700
Message-ID: <20090321053714.509353403@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36587 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760898AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usbnet-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default handler for net_device_stats already does same thing.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/usb/usbnet.c	2009-03-20 09:38:00.950964064 -0700
+++ b/drivers/net/usb/usbnet.c	2009-03-20 09:38:46.383715245 -0700
@@ -249,14 +249,6 @@ static int usbnet_change_mtu (struct net
 
 /*-------------------------------------------------------------------------*/
 
-static struct net_device_stats *usbnet_get_stats (struct net_device *net)
-{
-	struct usbnet	*dev = netdev_priv(net);
-	return &dev->stats;
-}
-
-/*-------------------------------------------------------------------------*/
-
 /* some LK 2.4 HCDs oopsed if we freed or resubmitted urbs from
  * completion callbacks.  2.5 should have fixed those bugs...
  */
@@ -1180,7 +1172,6 @@ usbnet_probe (struct usb_interface *udev
 #endif
 
 	net->change_mtu = usbnet_change_mtu;
-	net->get_stats = usbnet_get_stats;
 	net->hard_start_xmit = usbnet_start_xmit;
 	net->open = usbnet_open;
 	net->stop = usbnet_stop;

-- 

