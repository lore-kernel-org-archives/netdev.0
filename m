From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 2/4] mac80211: Remove unused 'len' variable
Date: Wed, 23 Nov 2016 20:45:49 -0800
Message-ID: <dfe71b8260fee9c0fa850ba5fdd29d7d5ca6cb2b.1479962513.git.kirtika@chromium.org>
References: <cover.1479962513.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Marek Kwaczynski <marek.kwaczynski@tieto.com>,
        David Spinadel <david.spinadel@intel.com>,
        Alexander Bondar <alexander.bondar@intel.com>,
        Michal Kazior <michal.kazior@tieto.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35283 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754522AbcKXEpz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 23:45:55 -0500
Content-Disposition: inline
In-Reply-To: <cover.1479962513.git.kirtika@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 633e27132625 (mac80211: split sched scan IEs) introduced the
len variable to keep track of the return value of
ieee80211_build_preq_ies() but did not use it. Compiling with W=1
gives the following warning, fix it.

net/mac80211/scan.c: In function ‘__ieee80211_request_sched_scan_start’:
net/mac80211/scan.c:1123:9: warning: variable ‘len’ set but not used [-Wunused-but-set-variable]

This is a harmless warning and is only being fixed to reduce the noise
with W=1 in the kernel.

Fixes: 633e27132625 ("mac80211: split sched scan IEs")
Cc: David Spinadel <david.spinadel@intel.com>
Cc: Alexander Bondar <alexander.bondar@intel.com>
Cc: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: Kirtika Ruchandani <kirtika@chromium.org>
---
 net/mac80211/scan.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 23d8ac8..faab3c4 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -1120,7 +1120,6 @@ int __ieee80211_request_sched_scan_start(struct ieee80211_sub_if_data *sdata,
 	u32 rate_masks[NUM_NL80211_BANDS] = {};
 	u8 bands_used = 0;
 	u8 *ie;
-	size_t len;
 
 	iebufsz = local->scan_ies_len + req->ie_len;
 
@@ -1145,10 +1144,9 @@ int __ieee80211_request_sched_scan_start(struct ieee80211_sub_if_data *sdata,
 
 	ieee80211_prepare_scan_chandef(&chandef, req->scan_width);
 
-	len = ieee80211_build_preq_ies(local, ie, num_bands * iebufsz,
-				       &sched_scan_ies, req->ie,
-				       req->ie_len, bands_used,
-				       rate_masks, &chandef);
+	ieee80211_build_preq_ies(local, ie, num_bands * iebufsz,
+				 &sched_scan_ies, req->ie,
+				 req->ie_len, bands_used, rate_masks, &chandef);
 
 	ret = drv_sched_scan_start(local, sdata, req, &sched_scan_ies);
 	if (ret == 0) {
-- 
2.8.0.rc3.226.g39d4020
