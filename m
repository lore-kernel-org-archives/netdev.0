From: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Subject: [PATCH 06/10] mac80211: Add sta_state to ethtool stats.
Date: Wed, 11 Apr 2012 10:52:14 -0700
Message-ID: <1334166738-28243-7-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334166738-28243-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>

Helps to know how the station is doing in it's association
attempt.

Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
---
:100644 100644 bbaf564... a63834d... M	net/mac80211/cfg.c
 net/mac80211/cfg.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index bbaf564..a63834d 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -118,7 +118,7 @@ static const char ieee80211_gstrings_sta_stats[][ETH_GSTRING_LEN] = {
 	"rx_duplicates", "rx_fragments", "rx_dropped",
 	"tx_packets", "tx_bytes", "tx_fragments",
 	"tx_filtered", "tx_retry_failed", "tx_retries",
-	"beacon_loss", "txrate", "rxrate", "signal",
+	"beacon_loss", "sta_state", "txrate", "rxrate", "signal",
 	"channel", "noise", "ch_time", "ch_time_busy",
 	"ch_time_ext_busy", "ch_time_rx", "ch_time_tx"
 };
@@ -534,10 +534,12 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
