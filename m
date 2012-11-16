From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 3/4] batman-adv: don't add TEMP clients belonging to other backbone nodes
Date: Fri, 16 Nov 2012 09:49:17 +0100
Message-ID: <1353055758-2901-4-git-send-email-ordex@autistici.org>
References: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:34908 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab2KPIuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 03:50:24 -0500
In-Reply-To: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "early client detection" mechanism must not add clients belonging
to other backbone nodes. Such clients must be reached by directly
using the LAN instead of the mesh.

This was introduced by 30cfd02b60e1cb16f5effb0a01f826c5bb7e4c59
("batman-adv: detect not yet announced clients")

Reported-by: Glen Page <glen.page@thet.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index fec1a00..baae715 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2456,6 +2456,13 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 {
 	bool ret = false;
 
+	/* if the originator is a backbone node (meaning it belongs to the same
+	 * LAN of this node) the temporary client must not be added because to
+	 * reach such destination the node must use the LAN instead of the mesh
+	 */
+	if (batadv_bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
+		goto out;
+
 	if (!batadv_tt_global_add(bat_priv, orig_node, addr,
 				  BATADV_TT_CLIENT_TEMP,
 				  atomic_read(&orig_node->last_ttvn)))
-- 
1.8.0
