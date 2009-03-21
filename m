From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 66/77] mac80211_hwsim: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:33 -0700
Message-ID: <20090321053717.601771143@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, j@w1.fi
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=hwsim.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>


--- a/drivers/net/wireless/mac80211_hwsim.c	2009-03-20 21:45:40.802964051 -0700
+++ b/drivers/net/wireless/mac80211_hwsim.c	2009-03-20 22:26:02.959027480 -0700
@@ -739,10 +739,16 @@ static struct device_driver mac80211_hws
 	.name = "mac80211_hwsim"
 };
 
+static const struct net_device_ops hwsim_netdev_ops = {
+	.ndo_start_xmit 	= hwsim_mon_xmit,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static void hwsim_mon_setup(struct net_device *dev)
 {
-	dev->hard_start_xmit = hwsim_mon_xmit;
+	dev->netdev_ops = &hwsim_netdev_ops;
 	dev->destructor = free_netdev;
 	ether_setup(dev);
 	dev->tx_queue_len = 0;

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
