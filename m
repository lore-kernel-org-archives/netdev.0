From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] cfg80211: make RATE_INFO_BW_20 the default
Date: Thu,  4 May 2017 08:42:30 +0200
Message-ID: <20170504064230.22058-1-johannes@sipsolutions.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50294 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751517AbdEDGmk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 02:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Due to the way I did the RX bitrate conversions in mac80211 with
spatch, going setting flags to setting the value, many drivers now
don't set the bandwidth value for 20 MHz, since with the flags it
wasn't necessary to (there was no 20 MHz flag, only the others.)

Rather than go through and try to fix up all the drivers, instead
renumber the enum so that 20 MHz, which is the typical bandwidth,
actually has the value 0, making those drivers all work again.

If VHT was hit used with a driver not reporting it, e.g. iwlmvm,
this manifested in hitting the bandwidth warning in
cfg80211_calculate_bitrate_vht().

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/cfg80211.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 6e90f1a4950f..15d6599b8bc6 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1013,9 +1013,9 @@ enum rate_info_flags {
  * @RATE_INFO_BW_160: 160 MHz bandwidth
  */
 enum rate_info_bw {
+	RATE_INFO_BW_20 = 0,
 	RATE_INFO_BW_5,
 	RATE_INFO_BW_10,
-	RATE_INFO_BW_20,
 	RATE_INFO_BW_40,
 	RATE_INFO_BW_80,
 	RATE_INFO_BW_160,
-- 
2.11.0
