From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 74/77] ipw2200: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:41 -0700
Message-ID: <20090321053718.224939952@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, jkosina@suse.cz,
	dstreba@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36739 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761166AbZCUFsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:30 -0400
Content-Disposition: inline; filename=ipw2200.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wireless/ipw2x00/ipw2200.c	2009-03-20 21:17:26.008902901 -0700
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c	2009-03-20 21:17:55.282652680 -0700
@@ -11529,6 +11529,15 @@ static int ipw_prom_hard_start_xmit(stru
 	return -EOPNOTSUPP;
 }
 
+static const struct net_device_ops ipw_prom_netdev_ops = {
+	.ndo_open 		= ipw_prom_open,
+	.ndo_stop		= ipw_prom_stop,
+	.ndo_start_xmit		= ipw_prom_hard_start_xmit,
+	.ndo_change_mtu		= ieee80211_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int ipw_prom_alloc(struct ipw_priv *priv)
 {
 	int rc = 0;
@@ -11548,9 +11557,7 @@ static int ipw_prom_alloc(struct ipw_pri
 	memcpy(priv->prom_net_dev->dev_addr, priv->mac_addr, ETH_ALEN);
 
 	priv->prom_net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
-	priv->prom_net_dev->open = ipw_prom_open;
-	priv->prom_net_dev->stop = ipw_prom_stop;
-	priv->prom_net_dev->hard_start_xmit = ipw_prom_hard_start_xmit;
+	priv->prom_net_dev->netdev_ops = &ipw_prom_netdev_ops;
 
 	priv->prom_priv->ieee->iw_mode = IW_MODE_MONITOR;
 	SET_NETDEV_DEV(priv->prom_net_dev, &priv->pci_dev->dev);
@@ -11578,6 +11585,17 @@ static void ipw_prom_free(struct ipw_pri
 
 #endif
 
+static const struct net_device_ops ipw_netdev_ops = {
+	.ndo_init		= ipw_net_init,
+	.ndo_open		= ipw_net_open,
+	.ndo_stop		= ipw_net_stop,
+	.ndo_set_multicast_list	= ipw_net_set_multicast_list,
+	.ndo_set_mac_address	= ipw_net_set_mac_address,
+	.ndo_start_xmit		= ieee80211_xmit,
+	.ndo_change_mtu		= ieee80211_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 				   const struct pci_device_id *ent)
@@ -11679,11 +11697,7 @@ static int __devinit ipw_pci_probe(struc
 	priv->ieee->perfect_rssi = -20;
 	priv->ieee->worst_rssi = -85;
 
-	net_dev->open = ipw_net_open;
-	net_dev->stop = ipw_net_stop;
-	net_dev->init = ipw_net_init;
-	net_dev->set_multicast_list = ipw_net_set_multicast_list;
-	net_dev->set_mac_address = ipw_net_set_mac_address;
+	net_dev->netdev_ops = &ipw_netdev_ops;
 	priv->wireless_data.spy_data = &priv->ieee->spy_data;
 	net_dev->wireless_data = &priv->wireless_data;
 	net_dev->wireless_handlers = &ipw_wx_handler_def;

-- 

