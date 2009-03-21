From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 73/77] ipw2100: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:40 -0700
Message-ID: <20090321053718.145743314@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, jkosina@suse.cz,
	dstreba@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36738 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761153AbZCUFsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:30 -0400
Content-Disposition: inline; filename=ipw2100.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/wireless/ipw2x00/ipw2100.c       |   17 ++++++++++++-----
 drivers/net/wireless/ipw2x00/libipw_module.c |    2 ++
 2 files changed, 14 insertions(+), 5 deletions(-)

--- a/drivers/net/wireless/ipw2x00/ipw2100.c	2009-03-20 21:18:36.962783530 -0700
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c	2009-03-20 21:24:40.533652141 -0700
@@ -6008,6 +6008,17 @@ static void ipw2100_rf_kill(struct work_
 
 static void ipw2100_irq_tasklet(struct ipw2100_priv *priv);
 
+static const struct net_device_ops ipw2100_netdev_ops = {
+	.ndo_open		= ipw2100_open,
+	.ndo_stop		= ipw2100_close,
+	.ndo_start_xmit		= ieee80211_xmit,
+	.ndo_change_mtu		= ieee80211_change_mtu,
+	.ndo_init		= ipw2100_net_init,
+	.ndo_tx_timeout		= ipw2100_tx_timeout,
+	.ndo_set_mac_address	= ipw2100_set_address,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* Look into using netdev destructor to shutdown ieee80211? */
 
 static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
@@ -6032,15 +6043,11 @@ static struct net_device *ipw2100_alloc_
 	priv->ieee->perfect_rssi = -20;
 	priv->ieee->worst_rssi = -85;
 
-	dev->open = ipw2100_open;
-	dev->stop = ipw2100_close;
-	dev->init = ipw2100_net_init;
+	dev->netdev_ops = &ipw2100_netdev_ops;
 	dev->ethtool_ops = &ipw2100_ethtool_ops;
-	dev->tx_timeout = ipw2100_tx_timeout;
 	dev->wireless_handlers = &ipw2100_wx_handler_def;
 	priv->wireless_data.ieee80211 = priv->ieee;
 	dev->wireless_data = &priv->wireless_data;
-	dev->set_mac_address = ipw2100_set_address;
 	dev->watchdog_timeo = 3 * HZ;
 	dev->irq = 0;
 

-- 

