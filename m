From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/12] d80211: Fix passing of invalid pointer
Date: Wed,  3 Jan 2007 19:05:08 +0100 (CET)
Message-ID: <20070103180508.F09143AA7E9@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42221 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751014AbXACSFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:10 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

ieee80211_hw pointers have to be passed to ops->set_key()
and ops->get_tsf().

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_iface.c |    4 ++--
 net/d80211/ieee80211_sta.c   |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

0690925f2f99f6d43322ec8507eaabdcf1435c3c
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 6b45895..cb1da56 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -227,8 +227,8 @@ #if 0
 		 * really much point in disabling the keys at this point. */
 		memset(addr, 0xff, ETH_ALEN);
 		if (local->ops->set_key)
-			local->ops->set_key(dev, DISABLE_KEY, addr,
-					   local->keys[i], 0);
+			local->ops->set_key(local_to_hw(local), DISABLE_KEY, addr,
+					    local->keys[i], 0);
 #endif
 		ieee80211_key_free(sdata->keys[i]);
 	}
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index df7a238..0d46c66 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1362,7 +1362,7 @@ #ifdef CONFIG_D80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
 		u64 tsf;
 		if (local->ops->get_tsf)
-			tsf = local->ops->get_tsf(local->mdev);
+			tsf = local->ops->get_tsf(local_to_hw(local));
 		else
 			tsf = -1LLU;
 		if (time_after(jiffies, last_tsf_debug + 5 * HZ)) {
-- 
1.3.0

