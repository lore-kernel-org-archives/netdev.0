From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/18] d80211: fix is_ieee80211_device
Date: Wed, 18 Oct 2006 17:49:24 +0200 (CEST)
Message-ID: <20061018154924.6E36947F5E@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12962 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161186AbWJRPs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:48:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The is_ieee80211_device function must ensure that the passed net_device
belongs to the hardware device we are working with.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

54bac502265add95b8ca098ccf62c1d506daeb86
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 1ef2707..3efba6a 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1123,9 +1123,10 @@ __ieee80211_tx_prepare(struct ieee80211_
 
 }
 
-static int inline is_ieee80211_device(struct net_device *dev)
+static int inline is_ieee80211_device(struct net_device *dev,
+				      struct net_device *master)
 {
-	return (dev->ieee80211_ptr != NULL);
+	return (dev->ieee80211_ptr == master->ieee80211_ptr);
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
@@ -1140,7 +1141,7 @@ static void inline ieee80211_tx_prepare(
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	dev = dev_get_by_index(pkt_data->ifindex);
-	if (unlikely(dev && !is_ieee80211_device(dev))) {
+	if (unlikely(dev && !is_ieee80211_device(dev, mdev))) {
 		dev_put(dev);
 		dev = NULL;
 	}
@@ -1395,7 +1396,7 @@ static int ieee80211_master_start_xmit(s
 
 	if (pkt_data->ifindex)
 		odev = dev_get_by_index(pkt_data->ifindex);
-	if (unlikely(odev && !is_ieee80211_device(odev))) {
+	if (unlikely(odev && !is_ieee80211_device(odev, dev))) {
 		dev_put(odev);
 		odev = NULL;
 	}
-- 
1.3.0

