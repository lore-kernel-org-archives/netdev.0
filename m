From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/14] d80211: fix potential invalid array index returning key information
Date: Wed, 13 Dec 2006 17:41:39 +0100 (CET)
Message-ID: <20061213164139.6061E3AA6BC@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57264 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965042AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

sdata->keys[] has NUM_DEFAULT_KEYS elements, don't access past that.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

11355b4c0aadecd31e43c5e6d5de652030aa0cf5
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 7de1fee..63424a7 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -803,7 +803,7 @@ static int ieee80211_ioctl_get_encryptio
 	    param->sta_addr[2] == 0xff && param->sta_addr[3] == 0xff &&
 	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff) {
 		sta = NULL;
-		if (param->u.crypt.idx > NUM_DEFAULT_KEYS) {
+		if (param->u.crypt.idx >= NUM_DEFAULT_KEYS) {
 			param->u.crypt.idx = sdata->default_key ?
 				sdata->default_key->keyidx : 0;
 			return 0;
-- 
1.3.0

