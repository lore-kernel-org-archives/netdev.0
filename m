From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] d80211: fix is_ieee80211_device
Date: Wed, 27 Sep 2006 17:57:20 +0200
Message-ID: <20060927175720.2ff53844@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28117 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965001AbWI0P5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:57:22 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The is_ieee80211_device function must ensure that the passed net_device
belongs to the hardware device we are working with.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
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
Jiri Benc
SUSE Labs
