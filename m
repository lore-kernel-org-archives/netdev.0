From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/14] d80211: fix invalid check for sub interface type AP
Date: Wed, 13 Dec 2006 17:41:41 +0100 (CET)
Message-ID: <20061213164141.7ACBA3AA6BE@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57266 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965044AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

We should be checking the type member, not the raw pointer.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

7511a31ac07b8cb4141fe2d47abd55b9875b84a9
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index cb600d7..4be86c9 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1996,7 +1996,7 @@ static int ieee80211_ioctl_siwscan(struc
 		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 			ssid = sdata->u.sta.ssid;
 			ssid_len = sdata->u.sta.ssid_len;
-		} else if (sdata == IEEE80211_IF_TYPE_AP) {
+		} else if (sdata->type == IEEE80211_IF_TYPE_AP) {
 			ssid = sdata->u.ap.ssid;
 			ssid_len = sdata->u.ap.ssid_len;
 		} else
-- 
1.3.0

