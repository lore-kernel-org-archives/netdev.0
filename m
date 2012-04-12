From: greearb@candelatech.com
Subject: [PATCH 5/5] mac80211: Add sta_state to ethtool stats.
Date: Thu, 12 Apr 2012 09:32:55 -0700
Message-ID: <1334248375-22967-6-git-send-email-greearb@candelatech.com>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51538 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965558Ab2DLQeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 12:34:10 -0400
In-Reply-To: <1334248375-22967-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Helps to know how the station is doing in it's association
attempt.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 99e3597... 8375168... M	net/mac80211/cfg.c
 net/mac80211/cfg.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 99e3597..8375168 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -117,7 +117,7 @@ static const char ieee80211_gstrings_sta_stats[][ETH_GSTRING_LEN] = {
 	"rx_duplicates", "rx_fragments", "rx_dropped",
 	"tx_packets", "tx_bytes", "tx_fragments",
 	"tx_filtered", "tx_retry_failed", "tx_retries",
-	"beacon_loss", "txrate", "rxrate", "signal",
+	"beacon_loss", "sta_state", "txrate", "rxrate", "signal",
 	"channel", "noise", "ch_time", "ch_time_busy",
 	"ch_time_ext_busy", "ch_time_rx", "ch_time_tx"
 };
@@ -533,10 +533,12 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
 		data[i++] += sta->beacon_loss_count;
 
 		if (!do_once) {
-			i += 3;
+			i += 4;
 			goto after_once;
 		}
 
+		data[i++] = sta->sta_state;
+
 		do_once = false;
 		sinfo.filled = 0;
 		sta_set_sinfo(sta, &sinfo);
-- 
1.7.3.4
