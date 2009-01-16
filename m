From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 2/2] PS3: gelic: wireless: convert the wireless part to net_device_ops
Date: Fri, 16 Jan 2009 17:52:55 +0900
Message-ID: <20090116174726.0B70.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Geoff Levand <geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
To: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert the gelic wireless driver to net_device_ops

Signed-off-by: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
---
 V2: added setting for ndo_validate_addr

 drivers/net/ps3_gelic_wireless.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2697,6 +2697,19 @@ static int gelic_wl_stop(struct net_devi
 
 /* -- */
 
+static const struct net_device_ops gelic_wl_netdevice_ops = {
+	.ndo_open = gelic_wl_open,
+	.ndo_stop = gelic_wl_stop,
+	.ndo_start_xmit = gelic_net_xmit,
+	.ndo_set_multicast_list = gelic_net_set_multi,
+	.ndo_change_mtu = gelic_net_change_mtu,
+	.ndo_tx_timeout = gelic_net_tx_timeout,
+	.ndo_validate_addr = eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = gelic_net_poll_controller,
+#endif
+};
+
 static struct ethtool_ops gelic_wl_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
 	.get_link	= gelic_wl_get_link,
@@ -2711,21 +2724,12 @@ static void gelic_wl_setup_netdev_ops(st
 	struct gelic_wl_info *wl;
 	wl = port_wl(netdev_priv(netdev));
 	BUG_ON(!wl);
-	netdev->open = &gelic_wl_open;
-	netdev->stop = &gelic_wl_stop;
-	netdev->hard_start_xmit = &gelic_net_xmit;
-	netdev->set_multicast_list = &gelic_net_set_multi;
-	netdev->change_mtu = &gelic_net_change_mtu;
-	netdev->wireless_data = &wl->wireless_data;
-	netdev->wireless_handlers = &gelic_wl_wext_handler_def;
-	/* tx watchdog */
-	netdev->tx_timeout = &gelic_net_tx_timeout;
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 
 	netdev->ethtool_ops = &gelic_wl_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = gelic_net_poll_controller;
-#endif
+	netdev->netdev_ops = &gelic_wl_netdevice_ops;
+	netdev->wireless_data = &wl->wireless_data;
+	netdev->wireless_handlers = &gelic_wl_wext_handler_def;
 }
 
 /*

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
