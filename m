From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] mac80211: Fix likely misuse of | for &
Date: Wed, 30 May 2012 13:25:54 -0700
Message-ID: <aa9c55edda55d38111660c0b250d12d79f6e1755.1338408931.git.joe@perches.com>
References: <cover.1338408931.git.joe@perches.com>
Cc: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1338408931.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using | with a constant is always true.
Likely this should have be &.

cc: Ben Greear <greearb@candelatech.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/cfg.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 495831e..e9cecca 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -533,16 +533,16 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
 		sinfo.filled = 0;
 		sta_set_sinfo(sta, &sinfo);
 
-		if (sinfo.filled | STATION_INFO_TX_BITRATE)
+		if (sinfo.filled & STATION_INFO_TX_BITRATE)
 			data[i] = 100000 *
 				cfg80211_calculate_bitrate(&sinfo.txrate);
 		i++;
-		if (sinfo.filled | STATION_INFO_RX_BITRATE)
+		if (sinfo.filled & STATION_INFO_RX_BITRATE)
 			data[i] = 100000 *
 				cfg80211_calculate_bitrate(&sinfo.rxrate);
 		i++;
 
-		if (sinfo.filled | STATION_INFO_SIGNAL_AVG)
+		if (sinfo.filled & STATION_INFO_SIGNAL_AVG)
 			data[i] = (u8)sinfo.signal_avg;
 		i++;
 	} else {
-- 
1.7.8.111.gad25c.dirty
