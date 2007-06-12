From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] mac80211: Set low initial rate in rc80211_simple
Date: Mon, 11 Jun 2007 21:24:11 -0400
Message-ID: <20070612012411.GI20422@tuxdriver.com>
References: <20070610.181704.73383002.davem@davemloft.net> <20070612012228.GG20422@tuxdriver.com> <20070612012319.GH20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2820 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757132AbXFLByw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 21:54:52 -0400
Content-Disposition: inline
In-Reply-To: <20070612012319.GH20422@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger@lwfinger.net>

The initial rate for STA's using rc80211_simple is set to the last
rate in the rate table. For situations for which the signal is weak,
the rate may be too high for authentication and association. Although
the rc80211_simple module will adjust the speed, the response may not
be fast enough for a successful connection. This modification sets the
initial rate to the lowest supported value.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/rc80211_simple.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index 2048cfd..5ae7fc4 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -283,14 +283,16 @@ static void rate_control_simple_rate_init(void *priv, void *priv_sta,
 	int i;
 	sta->txrate = 0;
 	mode = local->oper_hw_mode;
-	/* TODO: what is a good starting rate for STA? About middle? Maybe not
-	 * the lowest or the highest rate.. Could consider using RSSI from
-	 * previous packets? Need to have IEEE 802.1X auth succeed immediately
-	 * after assoc.. */
+	/* TODO: This routine should consider using RSSI from previous packets
+	 * as we need to have IEEE 802.1X auth succeed immediately after assoc..
+	 * Until that method is implemented, we will use the lowest supported rate
+	 * as a workaround, */
 	for (i = 0; i < mode->num_rates; i++) {
 		if ((sta->supp_rates & BIT(i)) &&
-		    (mode->rates[i].flags & IEEE80211_RATE_SUPPORTED))
+		    (mode->rates[i].flags & IEEE80211_RATE_SUPPORTED)) {
 			sta->txrate = i;
+			break;
+		}
 	}
 }
 
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
