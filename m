From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/14] d80211: remove unused references to sub interface data
Date: Wed, 13 Dec 2006 17:41:40 +0100 (CET)
Message-ID: <20061213164140.6E2733AA6BD@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57265 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965041AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

In these three cases the pointer returned by IEEE80211_DEV_TO_SUB_IF()
is never used.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    4 +---
 net/d80211/ieee80211_iface.c |    3 +--
 net/d80211/ieee80211_ioctl.c |    2 --
 3 files changed, 2 insertions(+), 7 deletions(-)

c2f74bcf14ecc48919bcdfa79ff0adaec8afb25e
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e10db5..664e6d0 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
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
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index bb15442..3d5b73c 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
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
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 63424a7..cb600d7 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
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
-- 
1.3.0

