From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH] mac80211: Remove unused 'struct rate_control_ref' variable
Date: Mon, 21 Nov 2016 22:54:16 -0800
Message-ID: <20161122065416.GA3565@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Maxim Altshul <maxim.altshul@ti.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34697 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752529AbcKVGyX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 01:54:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3b17fbf87d5d introduced sta_get_expected_throughput()
leaving variable 'struct rate_control_ref* ref' set but unused.
Compiling with W=1 gives the following warning, fix it.

net/mac80211/sta_info.c: In function ‘sta_set_sinfo’:
net/mac80211/sta_info.c:2052:27: warning: variable ‘ref’ set but not used [-Wunused-but-set-variable]

Fixes: 3b17fbf87d5d ("mac80211: mesh: Add support for HW RC implementation")
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Maxim Altshul <maxim.altshul@ti.com>
Signed-off-by: Kirtika Ruchandani <kirtika@google.com>
---
 net/mac80211/sta_info.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 1711bae..4ab75a9 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -2049,16 +2049,12 @@ void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo)
 {
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
 	struct ieee80211_local *local = sdata->local;
-	struct rate_control_ref *ref = NULL;
 	u32 thr = 0;
 	int i, ac, cpu;
 	struct ieee80211_sta_rx_stats *last_rxstats;

 	last_rxstats = sta_get_last_rx_stats(sta);

-	if (test_sta_flag(sta, WLAN_STA_RATE_CONTROL))
-		ref = local->rate_ctrl;
-
 	sinfo->generation = sdata->local->sta_generation;

 	/* do before driver, so beacon filtering drivers have a
