From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 55/77] netwave: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:22 -0700
Message-ID: <20090321053716.736316447@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=netwave.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Also get rid of unneeded cast

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>


--- a/drivers/net/wireless/netwave_cs.c	2009-03-20 22:14:37.954403178 -0700
+++ b/drivers/net/wireless/netwave_cs.c	2009-03-20 22:15:57.752963633 -0700
@@ -355,6 +355,17 @@ static struct iw_statistics *netwave_get
     return &priv->iw_stats;
 }
 
+static const struct net_device_ops netwave_netdev_ops = {
+	.ndo_open	 	= netwave_open,
+	.ndo_stop		= netwave_close,
+	.ndo_start_xmit		= netwave_start_xmit,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_tx_timeout		= netwave_watchdog,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*
  * Function netwave_attach (void)
  *
@@ -403,16 +414,12 @@ static int netwave_probe(struct pcmcia_d
     spin_lock_init(&priv->spinlock);
 
     /* Netwave specific entries in the device structure */
-    dev->hard_start_xmit = &netwave_start_xmit;
-    dev->set_multicast_list = &set_multicast_list;
+    dev->netdev_ops = &netwave_netdev_ops;
     /* wireless extensions */
-    dev->wireless_handlers = (struct iw_handler_def *)&netwave_handler_def;
+    dev->wireless_handlers = &netwave_handler_def;
 
-    dev->tx_timeout = &netwave_watchdog;
     dev->watchdog_timeo = TX_TIMEOUT;
 
-    dev->open = &netwave_open;
-    dev->stop = &netwave_close;
     link->irq.Instance = dev;
 
     return netwave_pcmcia_config( link);

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
