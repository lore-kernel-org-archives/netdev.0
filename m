From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/21] batman-adv: pass a 16bit long flag argument to tt_global_add()
Date: Wed, 29 May 2013 10:10:45 +0200
Message-ID: <1369815051-708-16-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:39889 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965070Ab3E2INF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:13:05 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it may be the case that we want to store some local TT client flags in a global
entry, therefore the tt_global_add needs to get a proper argument for this

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 19 +++++++++++++++++--
 net/batman-adv/translation-table.h |  2 +-
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 52808c4..e272f68 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -798,10 +798,25 @@ out:
 		batadv_tt_orig_list_entry_free_ref(orig_entry);
 }
 
-/* caller must hold orig_node refcount */
+/**
+ * batadv_tt_global_add - add a new TT global entry or update an existing one
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: the originator announcing the client
+ * @tt_addr: the mac address of the non-mesh client
+ * @flags: TT flags that have to be set for this non-mesh client
+ * @ttvn: the tt version number ever announcing this non-mesh client
+ *
+ * Add a new TT global entry for the given originator. If the entry already
+ * exists add a new reference to the given originator (a global entry can have
+ * references to multiple originators) and adjust the flags attribute to reflect
+ * the function argument.
+ * If a TT local entry exists for this non-mesh client remove it.
+ *
+ * The caller must hold orig_node refcount.
+ */
 int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			 struct batadv_orig_node *orig_node,
-			 const unsigned char *tt_addr, uint8_t flags,
+			 const unsigned char *tt_addr, uint16_t flags,
 			 uint8_t ttvn)
 {
 	struct batadv_tt_global_entry *tt_global_entry;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index ab8e683..659a3bb 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -33,7 +33,7 @@ void batadv_tt_global_add_orig(struct batadv_priv *bat_priv,
 			       const unsigned char *tt_buff, int tt_buff_len);
 int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			 struct batadv_orig_node *orig_node,
-			 const unsigned char *addr, uint8_t flags,
+			 const unsigned char *addr, uint16_t flags,
 			 uint8_t ttvn);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
-- 
1.8.1.5
