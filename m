From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/14] d80211: do not pass an invalid key index to set_key()
Date: Wed, 13 Dec 2006 17:41:42 +0100 (CET)
Message-ID: <20061213164142.878203AA6BF@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57267 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965033AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

d80211: do not pass an invalid key index to set_key()

If a hardware key has not been configured then there is no point
to calling DISABLE_KEY.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

0efae98fe404771fc3660f1d6023ab692149ddec
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 4be86c9..416d92e 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -612,7 +612,9 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (alg == ALG_NONE) {
 		keyconf = NULL;
-		if (try_hwaccel && key && local->ops->set_key &&
+		if (try_hwaccel && key &&
+		    key->hw_key_idx != HW_KEY_IDX_INVALID &&
+		    local->ops->set_key &&
 		    (keyconf = ieee80211_key_data2conf(local, key)) != NULL &&
 		    local->ops->set_key(local_to_hw(local), DISABLE_KEY,
 				       sta_addr, keyconf, sta ? sta->aid : 0)) {
-- 
1.3.0

