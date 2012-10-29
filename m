From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/16] batman-adv: properly convert flag into a boolean value
Date: Mon, 29 Oct 2012 09:58:15 +0100
Message-ID: <1351501097-1289-15-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54290 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758206Ab2J2I7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:59:07 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to properly convert a bitwise AND to a boolean value, the whole
expression must be prepended by "!!".

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 0ac39d5..c61209f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2420,7 +2420,7 @@ bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 	if (!tt_global_entry)
 		goto out;
 
-	ret = tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM;
+	ret = !!(tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM);
 	batadv_tt_global_entry_free_ref(tt_global_entry);
 out:
 	return ret;
-- 
1.7.12.4
