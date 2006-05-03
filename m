From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/3] d80211: fix is_ieee80211_device
Date: Wed,  3 May 2006 17:11:30 +0200 (CEST)
Message-ID: <20060503151130.80D67482B6@silver.suse.cz>
References: <20060503171031.304543000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44672 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965214AbWECPKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 11:10:52 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060503171031.304543000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sending packets from management interface (wmasterXap) didn't work. This
patch fixes that problem; it's not nice but it will go away when the
interface between kernel and hostapd is changed to netlink (the packets will
be sent through master interface then).

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

e0a6647c8a9371e00cfcb15452c6b577bc863f37
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index fc56450..701c38b 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -59,6 +59,8 @@ static int rate_control_initialize(struc
 
 static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
 
+static int ieee80211_mgmt_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
 
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
@@ -1097,7 +1099,8 @@ __ieee80211_tx_prepare(struct ieee80211_
 static int inline is_ieee80211_device(struct net_device *dev)
 {
 	return (dev->wireless_handlers ==
-		(struct iw_handler_def *) &ieee80211_iw_handler_def);
+		(struct iw_handler_def *) &ieee80211_iw_handler_def) ||
+	       (dev->hard_start_xmit == ieee80211_mgmt_start_xmit);
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
-- 
1.3.0

