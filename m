From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/21] batman-adv: do not silently ignore wrong condition
Date: Wed, 29 May 2013 02:59:33 +0200
Message-ID: <1369789186-3600-9-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43841 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934241Ab3E2BBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:51 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only one neigh_node per orig_node should match a given
neighbor address, therefore, if more than one matching
neigh_node is found, a WARNING has to be triggered to let
the user know that something is wrong in the originator
state instead of silently skipping the error.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 38183dc..bd50e0d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -669,7 +669,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		if (batadv_compare_eth(neigh_addr, ethhdr->h_source) &&
 		    tmp_neigh_node->if_incoming == if_incoming &&
 		    atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
-			if (neigh_node)
+			if (WARN(neigh_node, "too many matching neigh_nodes"))
 				batadv_neigh_node_free_ref(neigh_node);
 			neigh_node = tmp_neigh_node;
 			continue;
-- 
1.8.1.5
