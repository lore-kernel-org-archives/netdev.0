From: bookjovi@gmail.com
Subject: [PATCH] net: mac80211: fix compilation warning
Date: Wed,  2 Mar 2011 18:32:33 -0500
Message-ID: <1299108754-5492-1-git-send-email-bookjovi@gmail.com>
Cc: "John W. Linville" <linville@tuxdriver.com> (maintainer:NETWORKING
	[WIREL...),
	Johannes Berg <johannes@sipsolutions.net> (maintainer:MAC80211),
	"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
	[GENERAL]),
	linux-wireless@vger.kernel.org (open list:NETWORKING [WIREL...),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list)
To: bookjovi@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jovi Zhang <bookjovi@gmail.com>

this commit fix compilation warning as following:
net/mac80211/tx.c:1753: warning: unused variable mppath

Signed-off-by: Jovi Zhang <bookjovi@gmail.com>
---
 net/mac80211/tx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index b0beaa5..e87b07f 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1750,7 +1750,6 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	__le16 fc;
 	struct ieee80211_hdr hdr;
 	struct ieee80211s_hdr mesh_hdr __maybe_unused;
-	struct mesh_path *mppath = NULL;
 	const u8 *encaps_data;
 	int encaps_len, skip_header_bytes;
 	int nh_pos, h_pos;
@@ -1805,6 +1804,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		break;
 #ifdef CONFIG_MAC80211_MESH
 	case NL80211_IFTYPE_MESH_POINT:
+		struct mesh_path *mppath = NULL;
+
 		if (!sdata->u.mesh.mshcfg.dot11MeshTTL) {
 			/* Do not send frames with mesh_ttl == 0 */
 			sdata->u.mesh.mshstats.dropped_frames_ttl++;
-- 
1.7.2.3
