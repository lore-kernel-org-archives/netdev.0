From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 5/7] d80211: remove unused references to sub interface data
Date: Wed, 6 Dec 2006 16:45:26 -0800
Message-ID: <20061207004526.GE16252@devicescape.com>
References: <20061207004238.540749000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:33835 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937857AbWLGAp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:45:27 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="unused-sdata.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In these three cases the pointer returned by IEEE80211_DEV_TO_SUB_IF()
is never used.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -1362,11 +1362,9 @@ static int ieee80211_master_start_xmit(s
 	struct ieee80211_tx_control control;
 	struct ieee80211_tx_packet_data *pkt_data;
 	struct net_device *odev = NULL;
-	struct ieee80211_sub_if_data *sdata, *osdata;
+	struct ieee80211_sub_if_data *osdata;
 	int ret;
 
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-
 	/*
 	 * copy control out of the skb so other people can use skb->cb
 	 */
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -407,10 +407,8 @@ static int ieee80211_ioctl_get_info_sta(
 	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
 	    param->sta_addr[2] == 0xff && param->sta_addr[3] == 0xff &&
 	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff) {
-		struct ieee80211_sub_if_data *sdata;
 		struct net_device_stats *stats;
 
-		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 		stats = ieee80211_dev_stats(local->mdev);
 		param->u.get_info_sta.rx_bytes = stats->rx_bytes;
 		param->u.get_info_sta.tx_bytes = stats->tx_bytes;
Index: wireless-dev/net/d80211/ieee80211_iface.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_iface.c
+++ wireless-dev/net/d80211/ieee80211_iface.c
@@ -42,7 +42,7 @@ int ieee80211_if_add(struct net_device *
 {
 	struct net_device *ndev, *tmp_dev;
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
+	struct ieee80211_sub_if_data *sdata = NULL;
 	int ret;
 	int i;
 
@@ -83,7 +83,6 @@ int ieee80211_if_add(struct net_device *
 	sdata->type = IEEE80211_IF_TYPE_AP;
 	sdata->dev = ndev;
 	sdata->local = local;
-	sdata_parent = IEEE80211_DEV_TO_SUB_IF(dev);
 	ieee80211_if_sdata_init(sdata);
 
 	ret = register_netdevice(ndev);

--
