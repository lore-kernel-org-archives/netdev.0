From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv3 4/4] batman-adv: Increase BATADV_TVLV_MCAST version
 number to 2
Date: Tue,  7 Apr 2015 21:57:32 +0200
Message-ID: <1428436652-4676-5-git-send-email-linus.luessing@c0d3.blue>
References: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:40870 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683AbbDGT5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:57:49 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id 5416E586340
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 21:57:46 +0200 (CEST)
In-Reply-To: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multicast optimizations bridge integration will require the just
implemented IGMP/MLD report handling later. Therefore bumping the
version number.
---
 net/batman-adv/multicast.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index a6eff07..ff5d866 100644
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
@@ -960,7 +960,7 @@ static void batadv_mcast_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 void batadv_mcast_init(struct batadv_priv *bat_priv)
 {
 	batadv_tvlv_handler_register(bat_priv, batadv_mcast_tvlv_ogm_handler_v1,
-				     NULL, BATADV_TVLV_MCAST, 1,
+				     NULL, BATADV_TVLV_MCAST, 2,
 				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
 }
 
@@ -970,8 +970,8 @@ void batadv_mcast_init(struct batadv_priv *bat_priv)
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
