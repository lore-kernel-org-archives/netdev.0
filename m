From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv2 4/4] batman-adv: Increase BATADV_TVLV_MCAST
 version number to 2
Date: Wed,  1 Apr 2015 10:04:39 +0200
Message-ID: <1427875479-9240-5-git-send-email-linus.luessing@c0d3.blue>
References: <1427875479-9240-1-git-send-email-linus.luessing@c0d3.blue>
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1427875479-9240-1-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The multicast optimizations bridge integration will require the just
implemented IGMP/MLD report handling later. Therefore bumping the
version number.
---
 net/batman-adv/multicast.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 055f55b..3d29d6d 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -200,7 +200,7 @@ static bool batadv_mcast_mla_tvlv_update(struct batadv_priv *bat_priv)
 	if (batadv_mcast_has_bridge(bat_priv)) {
 		if (bat_priv->mcast.enabled) {
 			batadv_tvlv_container_unregister(bat_priv,
-							 BATADV_TVLV_MCAST, 1);
+							 BATADV_TVLV_MCAST, 2);
 			bat_priv->mcast.enabled = false;
 		}
 
@@ -209,7 +209,7 @@ static bool batadv_mcast_mla_tvlv_update(struct batadv_priv *bat_priv)
 
 	if (!bat_priv->mcast.enabled ||
 	    mcast_data.flags != bat_priv->mcast.flags) {
-		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_MCAST, 1,
+		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_MCAST, 2,
 					       &mcast_data, sizeof(mcast_data));
 		bat_priv->mcast.flags = mcast_data.flags;
 		bat_priv->mcast.enabled = true;
@@ -952,7 +952,7 @@ static void batadv_mcast_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 void batadv_mcast_init(struct batadv_priv *bat_priv)
 {
 	batadv_tvlv_handler_register(bat_priv, batadv_mcast_tvlv_ogm_handler_v1,
-				     NULL, BATADV_TVLV_MCAST, 1,
+				     NULL, BATADV_TVLV_MCAST, 2,
 				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
 }
 
@@ -962,8 +962,8 @@ void batadv_mcast_init(struct batadv_priv *bat_priv)
  */
 void batadv_mcast_free(struct batadv_priv *bat_priv)
 {
-	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_MCAST, 1);
-	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_MCAST, 1);
+	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_MCAST, 2);
+	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_MCAST, 2);
 
 	batadv_mcast_mla_tt_retract(bat_priv, NULL);
 }
-- 
1.7.10.4
