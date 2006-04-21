From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/10] d80211: fix SIOCGIWESSID ioctl
Date: Fri, 21 Apr 2006 22:53:20 +0200 (CEST)
Message-ID: <20060421205320.E9161482C1@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45697 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932440AbWDUUwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:53 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Flags for SIOCGIWESSID ioctl were not set, thus SSID was never displayed by
iwconfig.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

56d18689a4964cc2e906cfb5164b31649735774a
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index dfa0ef7..792fcf4 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1782,8 +1782,11 @@ static int ieee80211_ioctl_giwessid(stru
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
 	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		int res = ieee80211_sta_get_ssid(dev, ssid, &len);
-		if (res == 0)
+		if (res == 0) {
 			data->length = len;
+			data->flags = 1;
+		} else
+			data->flags = 0;
 		return res;
 	}
 
@@ -1792,6 +1795,7 @@ static int ieee80211_ioctl_giwessid(stru
 		len = IW_ESSID_MAX_SIZE;
 	memcpy(ssid, local->conf.ssid, len);
 	data->length = len;
+	data->flags = 1;
 	return 0;
 }
 
-- 
1.3.0

