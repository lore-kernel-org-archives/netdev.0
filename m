From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 56/77] strip: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:23 -0700
Message-ID: <20090321053716.812675897@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=strip.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

--- a/drivers/net/wireless/strip.c	2009-03-20 22:14:24.337964494 -0700
+++ b/drivers/net/wireless/strip.c	2009-03-20 22:16:04.157965087 -0700
@@ -2477,6 +2477,16 @@ static const struct header_ops strip_hea
 	.rebuild = strip_rebuild_header,
 };
 
+
+static const struct net_device_ops strip_netdev_ops = {
+	.ndo_open 	= strip_open_low,
+	.ndo_stop 	= strip_close_low,
+	.ndo_start_xmit = strip_xmit,
+	.ndo_set_mac_address = strip_set_mac_address,
+	.ndo_get_stats	= strip_get_stats,
+	.ndo_change_mtu = strip_change_mtu,
+};
+
 /*
  * This routine is called by DDI when the
  * (dynamically assigned) device is registered
@@ -2503,18 +2513,8 @@ static void strip_dev_setup(struct net_d
 	dev->dev_addr[0] = 0;
 	dev->addr_len = sizeof(MetricomAddress);
 
-	/*
-	 * Pointers to interface service routines.
-	 */
-
-	dev->open = strip_open_low;
-	dev->stop = strip_close_low;
-	dev->hard_start_xmit = strip_xmit;
-	dev->header_ops = &strip_header_ops;
