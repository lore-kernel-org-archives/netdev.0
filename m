From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH] mac80211: util: mesh is not connected properly after recovery
Date: Tue, 28 Jun 2016 14:15:44 +0300
Message-ID: <20160628111546.8932-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maital Hahn <maitalm@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:55737 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbcF1LPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 07:15:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maital Hahn <maitalm@ti.com>

In the reconfigure process for mesh interface, moved the reconfiguration
of the mesh peers to be done only after restarting the beacons,
the same as it is done for AP.

Signed-off-by: Maital Hahn <maitalm@ti.com>
Acked-by: Yaniv Machani <yanivma@ti.com>
---
 net/mac80211/util.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 5375a82..2431684 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1910,6 +1910,7 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 			ieee80211_reconfig_stations(sdata);
 			/* fall through */
 		case NL80211_IFTYPE_AP: /* AP stations are handled later */
+		case NL80211_IFTYPE_MESH_POINT: /* MP peers are handled later */
 			for (i = 0; i < IEEE80211_NUM_ACS; i++)
 				drv_conf_tx(local, sdata, i,
 					    &sdata->tx_conf[i]);
@@ -2013,7 +2014,8 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		if (!sta->uploaded)
 			continue;
 
-		if (sta->sdata->vif.type != NL80211_IFTYPE_AP)
+		if ((sta->sdata->vif.type != NL80211_IFTYPE_AP) &&
+		    (sta->sdata->vif.type != NL80211_IFTYPE_MESH_POINT))
 			continue;
 
 		for (state = IEEE80211_STA_NOTEXIST;
-- 
2.9.0
