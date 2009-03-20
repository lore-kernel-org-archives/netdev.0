From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]spider_net netdev ops conversion
Date: Fri, 20 Mar 2009 16:50:20 +0800
Message-ID: <49C358CC.4050101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63437 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754913AbZCTIvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 04:51:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spider_net: Convert to net_device_ops.

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>

---
 drivers/net/spider_net.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 88d2c67..1c81185 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2259,6 +2259,22 @@ spider_net_tx_timeout(struct net_device *netdev)
 	card->spider_stats.tx_timeouts++;
 }
 
+static const struct net_device_ops spider_net_ops = {
+	.ndo_open		= spider_net_open;
+	.ndo_stop		= spider_net_stop;
+	.ndo_start_xmit		= spider_net_xmit;
+	.ndo_set_multicast_list	= spider_net_set_multi;
+	.ndo_set_mac_address	= spider_net_set_mac;
+	.ndo_change_mtu		= spider_net_change_mtu;
+	.ndo_do_ioctl		= spider_net_do_ioctl;
+	.ndo_tx_timeout		= spider_net_tx_timeout;
+	/* HW VLAN */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	/* poll controller */
+	.ndo_poll_controller	= spider_net_poll_controller;
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+};
+
 /**
  * spider_net_setup_netdev_ops - initialization of net_device operations
  * @netdev: net_device structure
@@ -2268,21 +2284,8 @@ spider_net_tx_timeout(struct net_device *netdev)
 static void
 spider_net_setup_netdev_ops(struct net_device *netdev)
 {
-	netdev->open = &spider_net_open;
-	netdev->stop = &spider_net_stop;
-	netdev->hard_start_xmit = &spider_net_xmit;
-	netdev->set_multicast_list = &spider_net_set_multi;
-	netdev->set_mac_address = &spider_net_set_mac;
-	netdev->change_mtu = &spider_net_change_mtu;
-	netdev->do_ioctl = &spider_net_do_ioctl;
-	/* tx watchdog */
-	netdev->tx_timeout = &spider_net_tx_timeout;
+	netdev->netdev_ops = &spider_net_ops;
 	netdev->watchdog_timeo = SPIDER_NET_WATCHDOG_TIMEOUT;
-	/* HW VLAN */
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	/* poll controller */
-	netdev->poll_controller = &spider_net_poll_controller;
-#endif /* CONFIG_NET_POLL_CONTROLLER */
 	/* ethtool ops */
 	netdev->ethtool_ops = &spider_net_ethtool_ops;
 }
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
