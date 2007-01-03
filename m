From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/12] d80211: clear ifsta->associated flag when authentication starts
Date: Wed,  3 Jan 2007 19:05:18 +0100 (CET)
Message-ID: <20070103180518.8475C3AA7F3@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42225 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751040AbXACSFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:21 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

The 'associated' flag might be set if a previous association did not
end cleanly.  If the 'associated' flag is left set here then when
association succeeds ieee80211_set_associated() will think there is
nothing to report and will not inform userspace of the event.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

90be57e78c95bd0e66a2047c39d91156d63d6f4c
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 6edf17d..77a8308 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1923,7 +1923,7 @@ static void ieee80211_sta_new_auth(struc
 	printk(KERN_DEBUG "%s: Initial auth_alg=%d\n", dev->name,
 	       ifsta->auth_alg);
 	ifsta->auth_transaction = -1;
-	ifsta->auth_tries = ifsta->assoc_tries = 0;
+	ifsta->associated = ifsta->auth_tries = ifsta->assoc_tries = 0;
 	ieee80211_authenticate(dev, ifsta);
 }
 
-- 
1.3.0

