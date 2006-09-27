From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 13/14] d80211: getting wrong freq value if we did hardware scan
Date: Wed, 27 Sep 2006 17:50:58 +0200 (CEST)
Message-ID: <20060927155058.3F87D3BA25A@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51084 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964989AbWI0Ptx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:53 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mohamed Abbas <mabbas@linux.intel.com>

This patch modify d80211 to fix getting wrong frequency value
for scan implemented in hardware. With harware scan we might get
beacon of a network that is on different channel that in
local->conf.channel causing set freq to wrong value.

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

a5b4c8adb19c9d5d8b6c9b187ae6b2351e74e4a1
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2e82405..dd95ce8 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1541,12 +1541,12 @@ #endif
 	}
 
 
-	bss->hw_mode = local->conf.phymode;
+	bss->hw_mode = rx_status->phymode;
 	bss->channel = channel;
-	bss->freq = local->conf.freq;
-	if (channel != local->conf.channel &&
-	    (local->conf.phymode == MODE_IEEE80211G ||
-	     local->conf.phymode == MODE_IEEE80211B) &&
+	bss->freq = rx_status->freq;
+	if (channel != rx_status->channel &&
+	    (bss->hw_mode == MODE_IEEE80211G ||
+	     bss->hw_mode == MODE_IEEE80211B) &&
 	    channel >= 1 && channel <= 14) {
 		static const int freq_list[] = {
 			2412, 2417, 2422, 2427, 2432, 2437, 2442,
-- 
1.3.0

