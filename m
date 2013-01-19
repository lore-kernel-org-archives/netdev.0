From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/13] batman-adv: rename batadv_if_list_entry struct to make clear it is used by vis
Date: Sat, 19 Jan 2013 21:27:51 +0800
Message-ID: <1358602079-24024-6-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57853 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab3ASN3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:47 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 19 ++++++++++---------
 net/batman-adv/vis.c   |  8 ++++----
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9a66115..d17517c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -426,15 +426,6 @@ struct batadv_forw_packet {
 	struct batadv_hard_iface *if_incoming;
 };
 
-/* While scanning for vis-entries of a particular vis-originator
- * this list collects its interfaces to create a subgraph/cluster
- * out of them later
- */
-struct batadv_if_list_entry {
-	uint8_t addr[ETH_ALEN];
-	bool primary;
-	struct hlist_node list;
-};
 struct batadv_frag_packet_list_entry {
 	struct list_head list;
 	uint16_t seqno;
@@ -467,6 +458,16 @@ struct batadv_recvlist_node {
 	uint8_t mac[ETH_ALEN];
 };
 
+/* While scanning for vis-entries of a particular vis-originator
+ * this list collects its interfaces to create a subgraph/cluster
+ * out of them later
+ */
+struct batadv_vis_if_list_entry {
+	uint8_t addr[ETH_ALEN];
+	bool primary;
+	struct hlist_node list;
+};
+
 struct batadv_algo_ops {
 	struct hlist_node list;
 	char *name;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 51e2bf0..3d42b17 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -127,7 +127,7 @@ static void batadv_vis_data_insert_interface(const uint8_t *interface,
 					     struct hlist_head *if_list,
 					     bool primary)
 {
-	struct batadv_if_list_entry *entry;
+	struct batadv_vis_if_list_entry *entry;
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
@@ -147,7 +147,7 @@ static void batadv_vis_data_insert_interface(const uint8_t *interface,
 static void batadv_vis_data_read_prim_sec(struct seq_file *seq,
 					  const struct hlist_head *if_list)
 {
-	struct batadv_if_list_entry *entry;
+	struct batadv_vis_if_list_entry *entry;
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
@@ -197,7 +197,7 @@ static void batadv_vis_data_read_entries(struct seq_file *seq,
 					 struct batadv_vis_info_entry *entries)
 {
 	int i;
-	struct batadv_if_list_entry *entry;
+	struct batadv_vis_if_list_entry *entry;
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, list, list) {
@@ -223,7 +223,7 @@ static void batadv_vis_seq_print_text_bucket(struct seq_file *seq,
 	struct batadv_vis_packet *packet;
 	uint8_t *entries_pos;
 	struct batadv_vis_info_entry *entries;
-	struct batadv_if_list_entry *entry;
+	struct batadv_vis_if_list_entry *entry;
 	struct hlist_node *pos, *n;
 
 	HLIST_HEAD(vis_if_list);
-- 
1.8.0.2
