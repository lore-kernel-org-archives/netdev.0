From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/16] batman-adv: return proper value in case of hash_add failure
Date: Sun, 28 Oct 2012 12:17:06 +0100
Message-ID: <1351423037-5292-6-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:55602 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab2J1LSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:20 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of hash_add failure tt_global_add() must return 0 (which means on entry
insertion).

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d87d9b4..42a74e3 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -776,13 +776,13 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (via %pM)\n",
 		   tt_global_entry->common.addr, orig_node->orig);
+	ret = 1;
 
 out_remove:
 	/* remove address from local hash if present */
 	batadv_tt_local_remove(bat_priv, tt_global_entry->common.addr,
 			       "global tt received",
 			       flags & BATADV_TT_CLIENT_ROAM);
-	ret = 1;
 out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
-- 
1.7.12.4
