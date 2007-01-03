From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 11/12] d80211: inhibit duplicate authentication requests when setting bssid
Date: Wed,  3 Jan 2007 19:05:19 +0100 (CET)
Message-ID: <20070103180519.9015D3AA7F4@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42228 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751012AbXACSFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:23 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

If we are already authenticating don't send another authentication
request.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

ca363cfd2c934d40dd0c24a52e58921d355b3c01
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 77a8308..32c2bbe 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2354,7 +2354,7 @@ int ieee80211_sta_set_bssid(struct net_d
 		ifsta->bssid_set = 0;
 	else
 		ifsta->bssid_set = 1;
-	if (ifsta->ssid_set)
+	if (ifsta->ssid_set && ifsta->state != IEEE80211_AUTHENTICATE)
 		ieee80211_sta_new_auth(dev, ifsta);
 
 	return 0;
-- 
1.3.0

