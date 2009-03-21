From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 60/77] atmel: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:27 -0700
Message-ID: <20090321053717.126155878@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=atmel.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

--- a/drivers/net/wireless/atmel.c	2009-03-20 22:14:19.375839873 -0700
+++ b/drivers/net/wireless/atmel.c	2009-03-20 22:25:54.642841540 -0700
@@ -1495,6 +1495,17 @@ static int atmel_read_proc(char *page, c
 	return len;
 }
 
+static const struct net_device_ops atmel_netdev_ops = {
+	.ndo_open 		= atmel_open,
+	.ndo_stop		= atmel_close,
+	.ndo_change_mtu 	= atmel_change_mtu,
+	.ndo_set_mac_address 	= atmel_set_mac_address,
+	.ndo_start_xmit 	= start_tx,
+	.ndo_do_ioctl 		= atmel_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 				   const AtmelFWType fw_type,
 				   struct device *sys_dev,
@@ -1579,13 +1590,8 @@ struct net_device *init_atmel_card(unsig
 	priv->management_timer.function = atmel_management_timer;
 	priv->management_timer.data = (unsigned long) dev;
 
-	dev->open = atmel_open;
-	dev->stop = atmel_close;
-	dev->change_mtu = atmel_change_mtu;
-	dev->set_mac_address = atmel_set_mac_address;
-	dev->hard_start_xmit = start_tx;
-	dev->wireless_handlers = (struct iw_handler_def *)&atmel_handler_def;
-	dev->do_ioctl = atmel_ioctl;
+	dev->netdev_ops = &atmel_netdev_ops;
+	dev->wireless_handlers = &atmel_handler_def;
 	dev->irq = irq;
 	dev->base_addr = port;
 

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
