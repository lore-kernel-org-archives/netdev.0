From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/14] d80211: allow for hardware crypto of default keys
Date: Wed, 13 Dec 2006 17:41:36 +0100 (CET)
Message-ID: <20061213164136.375F03AA6B9@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57262 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965040AbWLMRIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:54 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Remove incorrect prohibition of hardware crypto support.  This was
originally present to prevent hardware crypto when more than one
station interface was created for a single hardware device, the code
in question is no longer correct and should be removed.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

281859d5a1d5004285bf806286600fa49ecb117b
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index c74b431..ef373f7 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -537,9 +537,7 @@ static int ieee80211_set_encryption(stru
 		}
 		key = sdata->keys[idx];
 
-		/* Disable hwaccel for default keys when the interface is not
-		 * the default one.
-		 * TODO: consider adding hwaccel support for these; at least
+		/* TODO: consider adding hwaccel support for these; at least
 		 * Atheros key cache should be able to handle this since AP is
 		 * only transmitting frames with default keys. */
 		/* FIX: hw key cache can be used when only one virtual
@@ -548,11 +546,6 @@ static int ieee80211_set_encryption(stru
 		 * must be used. This should be done automatically
 		 * based on configured station devices. For the time
 		 * being, this can be only set at compile time. */
-		/* FIXME: There is no more anything like "default
-		 * interface". We should try hwaccel if there is just one
-		 * interface - for now, hwaccel is unconditionaly
-		 * disabled. */
-		try_hwaccel = 0;
 	} else {
 		set_tx_key = 0;
 		if (idx != 0) {
-- 
1.3.0

