From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/16] batman-adv: fix kerneldoc for TT functions
Date: Wed,  3 Feb 2016 10:18:32 +0800
Message-ID: <1454465917-13332-12-git-send-email-a@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:31118 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcBCCko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:44 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/translation-table.c | 33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index af1d24ce420f..9fcf6bf9fa11 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -69,9 +69,13 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 				 bool roaming);
 
 /**
- * batadv_compare_tt
+ * batadv_compare_tt - check if two TT entries are the same
+ * @node: the list element pointer of the first TT entry
+ * @data2: pointer to the tt_common_entry of the second TT entry
  *
- * Return: 1 if they are the same mac addr and vid
+ * Compare the MAC address and the VLAN ID of the two TT entries and check if
+ * they are the same TT client.
+ * Return: 1 if the two TT clients are the same, 0 otherwise
  */
 static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
 {
@@ -221,6 +225,7 @@ batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
 
 /**
  * batadv_tt_global_hash_count - count the number of orig entries
+ * @bat_priv: the bat priv with all the soft interface information
  * @addr: the mac address of the client to count entries for
  * @vid: VLAN identifier
  *
@@ -289,8 +294,9 @@ static void batadv_tt_local_size_dec(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_tt_global_size_mod - change the size by v of the local table
- *  identified by vid
+ * batadv_tt_global_size_mod - change the size by v of the global table
+ *  for orig_node identified by vid
+ * @orig_node: the originator for which the table has to be modified
  * @vid: the VLAN identifier
  * @v: the amount to sum to the global table size
  */
@@ -721,7 +727,6 @@ out:
  *  function reserves the amount of space needed to send the entire global TT
  *  table. In case of success the value is updated with the real amount of
  *  reserved bytes
-
  * Allocate the needed amount of memory for the entire TT TVLV and write its
  * header made up by one tvlv_tt_data object and a series of tvlv_tt_vlan_data
  * objects, one per active VLAN served by the originator node.
@@ -1243,9 +1248,12 @@ static void batadv_tt_changes_list_free(struct batadv_priv *bat_priv)
 }
 
 /**
- * batadv_tt_global_orig_entry_find
+ * batadv_tt_global_orig_entry_find - find a TT orig_list_entry
+ * @entry: the TT global entry where the orig_list_entry has to be
+ *  extracted from
+ * @orig_node: the originator for which the orig_list_entry has to be found
  *
- * retrieves the orig_tt_list_entry belonging to orig_node from the
+ * retrieve the orig_tt_list_entry belonging to orig_node from the
  * batadv_tt_global_entry list
  *
  * Return: it with an increased refcounter, NULL if not found
@@ -1274,7 +1282,10 @@ batadv_tt_global_orig_entry_find(const struct batadv_tt_global_entry *entry,
 }
 
 /**
- * batadv_tt_global_entry_has_orig
+ * batadv_tt_global_entry_has_orig - check if a TT global entry is also handled
+ *  by a given originator
+ * @entry: the TT global entry to check
+ * @orig_node: the originator to search in the list
  *
  * find out if an orig_node is already in the list of a tt_global_entry.
  *
@@ -2519,6 +2530,8 @@ static void batadv_tt_global_update_crc(struct batadv_priv *bat_priv,
  * @num_vlan: number of tvlv VLAN entries
  * @full_table: ask for the entire translation table if true, while only for the
  *  last TT diff otherwise
+ *
+ * Return: true if the TT Request was sent, false otherwise
  */
 static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 				  struct batadv_orig_node *dst_orig_node,
@@ -3062,7 +3075,9 @@ static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
 }
 
 /**
- * batadv_tt_check_roam_count
+ * batadv_tt_check_roam_count - check if a client has roamed too frequently
+ * @bat_priv: the bat priv with all the soft interface information
+ * @client: mac address of the roaming client
  *
  * This function checks whether the client already reached the
  * maximum number of possible roaming phases. In this case the ROAMING_ADV
-- 
2.7.0
