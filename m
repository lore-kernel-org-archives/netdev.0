From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 17/21] d80211: remove useless and wrong check for interface type
Date: Wed, 23 Aug 2006 21:24:26 +0200 (CEST)
Message-ID: <20060823192426.6C226483B5@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30416 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965143AbWHWTY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:26 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The check for interface type in ieee80211_sta_rx_mgmt was wrong (it must
allow IBSS interface as well) and unnecessary, because the check is already
done in ieee80211_rx_h_mgmt.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

d0c2e2f74781b478f708d58aa83cb83812705af1
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 12d6c99..a3bcc1b 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1711,11 +1711,6 @@ void ieee80211_sta_rx_mgmt(struct net_de
 		goto fail;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_IF_TYPE_STA) {
-		printk(KERN_DEBUG "%s: ieee80211_sta_rx_mgmt: non-STA "
-		       "interface (type=%d)\n", dev->name, sdata->type);
-		goto fail;
-	}
 	ifsta = &sdata->u.sta;
 
 	mgmt = (struct ieee80211_mgmt *) skb->data;
-- 
1.3.0

