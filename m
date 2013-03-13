From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 3/9] batman-adv: don't use !! in bool conversion
Date: Wed, 13 Mar 2013 23:56:33 +0100
Message-ID: <1363215399-18875-4-git-send-email-ordex@autistici.org>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:65454 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934356Ab3CMW57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:57:59 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In C standard any expression different from 0 will be converted to
'true' when casting to bool (whatever is the length of the value).
Therefore all the "!!" conversions can be removed.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 4 ++--
 net/batman-adv/unicast.c           | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7e9e264..9322320 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -902,7 +902,7 @@ out_remove:
 	/* remove address from local hash if present */
 	local_flags = batadv_tt_local_remove(bat_priv, tt_addr,
 					     "global tt received",
-					     !!(flags & BATADV_TT_CLIENT_ROAM));
+					     flags & BATADV_TT_CLIENT_ROAM);
 	tt_global_entry->common.flags |= local_flags & BATADV_TT_CLIENT_WIFI;
 
 	if (!(flags & BATADV_TT_CLIENT_ROAM))
@@ -2515,7 +2515,7 @@ bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 	if (!tt_global_entry)
 		goto out;
 
-	ret = !!(tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM);
+	ret = tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM;
 	batadv_tt_global_entry_free_ref(tt_global_entry);
 out:
 	return ret;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 50e079f..0bb3b59 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -122,7 +122,7 @@ batadv_frag_search_packet(struct list_head *head,
 {
 	struct batadv_frag_packet_list_entry *tfp;
 	struct batadv_unicast_frag_packet *tmp_up = NULL;
-	int is_head_tmp, is_head;
+	bool is_head_tmp, is_head;
 	uint16_t search_seqno;
 
 	if (up->flags & BATADV_UNI_FRAG_HEAD)
@@ -130,7 +130,7 @@ batadv_frag_search_packet(struct list_head *head,
 	else
 		search_seqno = ntohs(up->seqno)-1;
 
-	is_head = !!(up->flags & BATADV_UNI_FRAG_HEAD);
+	is_head = up->flags & BATADV_UNI_FRAG_HEAD;
 
 	list_for_each_entry(tfp, head, list) {
 		if (!tfp->skb)
@@ -142,7 +142,7 @@ batadv_frag_search_packet(struct list_head *head,
 		tmp_up = (struct batadv_unicast_frag_packet *)tfp->skb->data;
 
 		if (tfp->seqno == search_seqno) {
-			is_head_tmp = !!(tmp_up->flags & BATADV_UNI_FRAG_HEAD);
+			is_head_tmp = tmp_up->flags & BATADV_UNI_FRAG_HEAD;
 			if (is_head_tmp != is_head)
 				return tfp;
 			else
-- 
1.8.1.5
