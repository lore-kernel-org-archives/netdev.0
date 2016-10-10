From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH v6 1/4] mac80211: remove unnecessary num_mcast_sta user
Date: Mon, 10 Oct 2016 19:12:20 +0200
Message-ID: <1476119543-24509-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        linux-wireless@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:43050 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752942AbcJJRMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 13:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking for num_mcast_sta in __ieee80211_request_smps_ap() is unnecessary,
as sta list will be empty in this case anyway, so list_for_each_entry(sta,
...) will exit immediately.

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
---
 net/mac80211/cfg.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 543b1d4..24133f5 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2313,13 +2313,6 @@ int __ieee80211_request_smps_ap(struct ieee80211_sub_if_data *sdata,
 	    smps_mode == IEEE80211_SMPS_AUTOMATIC)
 		return 0;
 
-	 /* If no associated stations, there's no need to do anything */
-	if (!atomic_read(&sdata->u.ap.num_mcast_sta)) {
-		sdata->smps_mode = smps_mode;
-		ieee80211_queue_work(&sdata->local->hw, &sdata->recalc_smps);
-		return 0;
-	}
-
 	ht_dbg(sdata,
 	       "SMPS %d requested in AP mode, sending Action frame to %d stations\n",
 	       smps_mode, atomic_read(&sdata->u.ap.num_mcast_sta));
-- 
2.1.4
