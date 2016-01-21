From: Sunil Shahu <shshahu@gmail.com>
Subject: [PATCH] net:mac80211:mesh_plink: remove redundant sta_info check
Date: Thu, 21 Jan 2016 11:06:25 +0530
Message-ID: <1453354585-26069-1-git-send-email-shshahu@gmail.com>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessory "if" statement and club it with previos "if" block.

Signed-off-by: Sunil Shahu <shshahu@gmail.com>
---
 net/mac80211/mesh_plink.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index bd3d55e..e5851ae 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -976,6 +976,9 @@ mesh_plink_get_event(struct ieee80211_sub_if_data *sdata,
 			mpl_dbg(sdata, "Mesh plink error: no more free plinks\n");
 			goto out;
 		}
+		/* new matching peer */
+		event = OPN_ACPT;
+		goto out;
 	} else {
 		if (!test_sta_flag(sta, WLAN_STA_AUTH)) {
 			mpl_dbg(sdata, "Mesh plink: Action frame from non-authed peer\n");
@@ -985,12 +988,6 @@ mesh_plink_get_event(struct ieee80211_sub_if_data *sdata,
 			goto out;
 	}
 
-	/* new matching peer */
-	if (!sta) {
-		event = OPN_ACPT;
-		goto out;
-	}
-
 	switch (ftype) {
 	case WLAN_SP_MESH_PEERING_OPEN:
 		if (!matches_local)
-- 
1.9.1
