From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 12/12] d80211: Reinit keys on mode change
Date: Wed,  3 Jan 2007 19:05:20 +0100 (CET)
Message-ID: <20070103180520.9BD953AA7E9@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42230 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751037AbXACSFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:25 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kiszka <jan.kiszka@web.de>

Switching the interface mode with some encryption keys set and then later
touching any key, triggers an oops because ieee80211_if_reinit fails to
NULL'ify the related pointers after free'ing the key on mode change. Long
explanation, simple fix below.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_iface.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

ff6a6797032d232d07be32594fdd7369cd927382
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index cb1da56..1a0b8cd 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -231,6 +231,7 @@ #if 0
 					    local->keys[i], 0);
 #endif
 		ieee80211_key_free(sdata->keys[i]);
+		sdata->keys[i] = NULL;
 	}
 
 	/* Shouldn't be necessary but won't hurt */
-- 
1.3.0

