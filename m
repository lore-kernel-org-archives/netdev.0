From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 65/77] zd1201: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:32 -0700
Message-ID: <20090321053717.514936473@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, pe1rxq-QXXXXQs8DbXYtjvyW6yDsg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=zd1201-ops.patch
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>


--- a/drivers/net/wireless/zd1201.c	2009-03-20 22:26:00.356902321 -0700
+++ b/drivers/net/wireless/zd1201.c	2009-03-20 22:26:01.715027053 -0700
@@ -1717,6 +1717,18 @@ static const struct iw_handler_def zd120
 	.get_wireless_stats	= zd1201_get_wireless_stats,
 };
 
+static const struct net_device_ops zd1201_netdev_ops = {
+	.ndo_open		= zd1201_net_open,
+	.ndo_stop		= zd1201_net_stop,
+	.ndo_start_xmit		= zd1201_hard_start_xmit,
+	.ndo_tx_timeout		= zd1201_tx_timeout,
+	.ndo_set_multicast_list = zd1201_set_multicast,
+	.ndo_set_mac_address	= zd1201_set_mac_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int zd1201_probe(struct usb_interface *interface,
 			const struct usb_device_id *id)
 {
@@ -1769,14 +1781,9 @@ static int zd1201_probe(struct usb_inter
 	if (err)
 		goto err_start;
 
-	dev->open = zd1201_net_open;
-	dev->stop = zd1201_net_stop;
+	dev->netdev_ops = &zd1201_netdev_ops;
 	dev->wireless_handlers = &zd1201_iw_handlers;
-	dev->hard_start_xmit = zd1201_hard_start_xmit;
 	dev->watchdog_timeo = ZD1201_TX_TIMEOUT;
-	dev->tx_timeout = zd1201_tx_timeout;
-	dev->set_multicast_list = zd1201_set_multicast;
-	dev->set_mac_address = zd1201_set_mac_address;
 	strcpy(dev->name, "wlan%d");
 
 	err = zd1201_getconfig(zd, ZD1201_RID_CNFOWNMACADDR, 

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
