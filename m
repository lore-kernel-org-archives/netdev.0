From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 02/18] batman-adv: Prefix vis local static
	functions with batadv_
Date: Thu, 28 Jun 2012 11:34:11 +0200
Message-ID: <1340876067-28333-3-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340876067-28333-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/vis.c |  201 ++++++++++++++++++++++++++------------------------
 1 file changed, 103 insertions(+), 98 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index d45989e..607b101 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -28,10 +28,10 @@
 
 #define MAX_VIS_PACKET_SIZE 1000
 
-static void start_vis_timer(struct bat_priv *bat_priv);
+static void batadv_start_vis_timer(struct bat_priv *bat_priv);
 
 /* free the info */
-static void free_info(struct kref *ref)
+static void batadv_free_info(struct kref *ref)
 {
 	struct vis_info *info = container_of(ref, struct vis_info, refcount);
 	struct bat_priv *bat_priv = info->bat_priv;
@@ -50,7 +50,7 @@ static void free_info(struct kref *ref)
 }
 
 /* Compare two vis packets, used by the hashing algorithm */
-static int vis_info_cmp(const struct hlist_node *node, const void *data2)
+static int batadv_vis_info_cmp(const struct hlist_node *node, const void *data2)
 {
 	const struct vis_info *d1, *d2;
 	const struct vis_packet *p1, *p2;
@@ -65,7 +65,7 @@ static int vis_info_cmp(const struct hlist_node *node, const void *data2)
 /* hash function to choose an entry in a hash table of given size
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
  */
-static uint32_t vis_info_choose(const void *data, uint32_t size)
+static uint32_t batadv_vis_info_choose(const void *data, uint32_t size)
 {
 	const struct vis_info *vis_info = data;
 	const struct vis_packet *packet;
@@ -88,8 +88,8 @@ static uint32_t vis_info_choose(const void *data, uint32_t size)
 	return hash % size;
 }
 
-static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
-				      const void *data)
+static struct vis_info *batadv_vis_hash_find(struct bat_priv *bat_priv,
+					     const void *data)
 {
 	struct hashtable_t *hash = bat_priv->vis_hash;
 	struct hlist_head *head;
@@ -100,12 +100,12 @@ static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
 	if (!hash)
 		return NULL;
 
-	index = vis_info_choose(data, hash->size);
+	index = batadv_vis_info_choose(data, hash->size);
 	head = &hash->table[index];
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(vis_info, node, head, hash_entry) {
-		if (!vis_info_cmp(node, data))
+		if (!batadv_vis_info_cmp(node, data))
 			continue;
 
 		vis_info_tmp = vis_info;
@@ -119,9 +119,9 @@ static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
 /* insert interface to the list of interfaces of one originator, if it
  * does not already exist in the list
  */
-static void vis_data_insert_interface(const uint8_t *interface,
-				      struct hlist_head *if_list,
-				      bool primary)
+static void batadv_vis_data_insert_interface(const uint8_t *interface,
+					     struct hlist_head *if_list,
+					     bool primary)
 {
 	struct if_list_entry *entry;
 	struct hlist_node *pos;
@@ -140,8 +140,7 @@ static void vis_data_insert_interface(const uint8_t *interface,
 	hlist_add_head(&entry->list, if_list);
 }
 
-static ssize_t vis_data_read_prim_sec(char *buff,
-				      const struct hlist_head *if_list)
+static ssize_t batadv_vis_prim_sec(char *buff, const struct hlist_head *if_list)
 {
 	struct if_list_entry *entry;
 	struct hlist_node *pos;
@@ -157,7 +156,7 @@ static ssize_t vis_data_read_prim_sec(char *buff,
 	return len;
 }
 
-static size_t vis_data_count_prim_sec(struct hlist_head *if_list)
+static size_t batadv_vis_cnt_prim_sec(struct hlist_head *if_list)
 {
 	struct if_list_entry *entry;
 	struct hlist_node *pos;
@@ -174,9 +173,9 @@ static size_t vis_data_count_prim_sec(struct hlist_head *if_list)
 }
 
 /* read an entry  */
-static ssize_t vis_data_read_entry(char *buff,
-				   const struct vis_info_entry *entry,
-				   const uint8_t *src, bool primary)
+static ssize_t batadv_vis_data_read_entry(char *buff,
+					  const struct vis_info_entry *entry,
+					  const uint8_t *src, bool primary)
 {
 	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
 	if (primary && entry->quality == 0)
@@ -227,8 +226,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 			entries = (struct vis_info_entry *)
 				((char *)packet + sizeof(*packet));
 
-			vis_data_insert_interface(packet->vis_orig,
-						  &vis_if_list, true);
+			batadv_vis_data_insert_interface(packet->vis_orig,
+							 &vis_if_list, true);
 
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
@@ -236,9 +235,9 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 				if (batadv_compare_eth(entries[j].src,
 						       packet->vis_orig))
 					continue;
-				vis_data_insert_interface(entries[j].src,
-							  &vis_if_list,
-							  false);
+				batadv_vis_data_insert_interface(entries[j].src,
+								 &vis_if_list,
+								 false);
 			}
 
 			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
@@ -248,7 +247,7 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 				if (batadv_compare_eth(entry->addr,
 						       packet->vis_orig))
 					buf_size +=
-					  vis_data_count_prim_sec(&vis_if_list);
+					  batadv_vis_cnt_prim_sec(&vis_if_list);
 
 				buf_size += 1;
 			}
@@ -280,8 +279,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 			entries = (struct vis_info_entry *)
 				((char *)packet + sizeof(*packet));
 
-			vis_data_insert_interface(packet->vis_orig,
-						  &vis_if_list, true);
+			batadv_vis_data_insert_interface(packet->vis_orig,
+							 &vis_if_list, true);
 
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
@@ -289,9 +288,9 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 				if (batadv_compare_eth(entries[j].src,
 						       packet->vis_orig))
 					continue;
-				vis_data_insert_interface(entries[j].src,
-							  &vis_if_list,
-							  false);
+				batadv_vis_data_insert_interface(entries[j].src,
+								 &vis_if_list,
+								 false);
 			}
 
 			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
@@ -299,7 +298,7 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 						entry->addr);
 
 				for (j = 0; j < packet->entries; j++)
-					buff_pos += vis_data_read_entry(
+					buff_pos += batadv_vis_data_read_entry(
 							buff + buff_pos,
 							&entries[j],
 							entry->addr,
@@ -309,8 +308,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 				if (batadv_compare_eth(entry->addr,
 						       packet->vis_orig))
 					buff_pos +=
-					 vis_data_read_prim_sec(buff + buff_pos,
-								&vis_if_list);
+					 batadv_vis_prim_sec(buff + buff_pos,
+							     &vis_if_list);
 
 				buff_pos += sprintf(buff + buff_pos, "\n");
 			}
@@ -338,7 +337,8 @@ out:
 /* add the info packet to the send list, if it was not
  * already linked in.
  */
-static void send_list_add(struct bat_priv *bat_priv, struct vis_info *info)
+static void batadv_send_list_add(struct bat_priv *bat_priv,
+				 struct vis_info *info)
 {
 	if (list_empty(&info->send_list)) {
 		kref_get(&info->refcount);
@@ -349,17 +349,17 @@ static void send_list_add(struct bat_priv *bat_priv, struct vis_info *info)
 /* delete the info packet from the send list, if it was
  * linked in.
  */
-static void send_list_del(struct vis_info *info)
+static void batadv_send_list_del(struct vis_info *info)
 {
 	if (!list_empty(&info->send_list)) {
 		list_del_init(&info->send_list);
-		kref_put(&info->refcount, free_info);
+		kref_put(&info->refcount, batadv_free_info);
 	}
 }
 
 /* tries to add one entry to the receive list. */
-static void recv_list_add(struct bat_priv *bat_priv,
-			  struct list_head *recv_list, const char *mac)
+static void batadv_recv_list_add(struct bat_priv *bat_priv,
+				 struct list_head *recv_list, const char *mac)
 {
 	struct recvlist_node *entry;
 
@@ -374,8 +374,9 @@ static void recv_list_add(struct bat_priv *bat_priv,
 }
 
 /* returns 1 if this mac is in the recv_list */
-static int recv_list_is_in(struct bat_priv *bat_priv,
-			   const struct list_head *recv_list, const char *mac)
+static int batadv_recv_list_is_in(struct bat_priv *bat_priv,
+				  const struct list_head *recv_list,
+				  const char *mac)
 {
 	const struct recvlist_node *entry;
 
@@ -394,10 +395,10 @@ static int recv_list_is_in(struct bat_priv *bat_priv,
  * broken.. ).	vis hash must be locked outside.  is_new is set when the packet
  * is newer than old entries in the hash.
  */
-static struct vis_info *add_packet(struct bat_priv *bat_priv,
-				   struct vis_packet *vis_packet,
-				   int vis_info_len, int *is_new,
-				   int make_broadcast)
+static struct vis_info *batadv_add_packet(struct bat_priv *bat_priv,
+					  struct vis_packet *vis_packet,
+					  int vis_info_len, int *is_new,
+					  int make_broadcast)
 {
 	struct vis_info *info, *old_info;
 	struct vis_packet *search_packet, *old_packet;
@@ -418,7 +419,7 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 						     sizeof(*search_packet));
 
 	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
-	old_info = vis_hash_find(bat_priv, &search_elem);
+	old_info = batadv_vis_hash_find(bat_priv, &search_elem);
 	kfree_skb(search_elem.skb_packet);
 
 	if (old_info) {
@@ -426,8 +427,9 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 		if (!seq_after(ntohl(vis_packet->seqno),
 			       ntohl(old_packet->seqno))) {
 			if (old_packet->seqno == vis_packet->seqno) {
-				recv_list_add(bat_priv, &old_info->recv_list,
-					      vis_packet->sender_orig);
+				batadv_recv_list_add(bat_priv,
+						     &old_info->recv_list,
+						     vis_packet->sender_orig);
 				return old_info;
 			} else {
 				/* newer packet is already in hash. */
@@ -435,10 +437,10 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 			}
 		}
 		/* remove old entry */
-		batadv_hash_remove(bat_priv->vis_hash, vis_info_cmp,
-				   vis_info_choose, old_info);
-		send_list_del(old_info);
-		kref_put(&old_info->refcount, free_info);
+		batadv_hash_remove(bat_priv->vis_hash, batadv_vis_info_cmp,
+				   batadv_vis_info_choose, old_info);
+		batadv_send_list_del(old_info);
+		kref_put(&old_info->refcount, batadv_free_info);
 	}
 
 	info = kmalloc(sizeof(*info), GFP_ATOMIC);
@@ -473,14 +475,15 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 	if (packet->entries * sizeof(struct vis_info_entry) > vis_info_len)
 		packet->entries = vis_info_len / sizeof(struct vis_info_entry);
 
-	recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
+	batadv_recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
 
 	/* try to add it */
-	hash_added = batadv_hash_add(bat_priv->vis_hash, vis_info_cmp,
-				     vis_info_choose, info, &info->hash_entry);
+	hash_added = batadv_hash_add(bat_priv->vis_hash, batadv_vis_info_cmp,
+				     batadv_vis_info_choose, info,
+				     &info->hash_entry);
 	if (hash_added != 0) {
 		/* did not work (for some reason) */
-		kref_put(&info->refcount, free_info);
+		kref_put(&info->refcount, batadv_free_info);
 		info = NULL;
 	}
 
@@ -499,8 +502,8 @@ void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
 	make_broadcast = (vis_server == VIS_TYPE_SERVER_SYNC);
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
-	info = add_packet(bat_priv, vis_packet, vis_info_len,
-			  &is_new, make_broadcast);
+	info = batadv_add_packet(bat_priv, vis_packet, vis_info_len,
+				 &is_new, make_broadcast);
 	if (!info)
 		goto end;
 
@@ -508,7 +511,7 @@ void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
 	 * hash.
 	 */
 	if (vis_server == VIS_TYPE_SERVER_SYNC && is_new)
-		send_list_add(bat_priv, info);
+		batadv_send_list_add(bat_priv, info);
 end:
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
 }
@@ -534,8 +537,8 @@ void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
 		are_target = 1;
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
-	info = add_packet(bat_priv, vis_packet, vis_info_len,
-			  &is_new, are_target);
+	info = batadv_add_packet(bat_priv, vis_packet, vis_info_len,
+				 &is_new, are_target);
 
 	if (!info)
 		goto end;
@@ -546,11 +549,11 @@ void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
 	/* send only if we're the target server or ... */
 	if (are_target && is_new) {
 		packet->vis_type = VIS_TYPE_SERVER_SYNC;	/* upgrade! */
-		send_list_add(bat_priv, info);
+		batadv_send_list_add(bat_priv, info);
 
 		/* ... we're not the recipient (and thus need to forward). */
 	} else if (!batadv_is_my_mac(packet->target_orig)) {
-		send_list_add(bat_priv, info);
+		batadv_send_list_add(bat_priv, info);
 	}
 
 end:
@@ -562,8 +565,8 @@ end:
  *
  * Must be called with the originator hash locked
  */
-static int find_best_vis_server(struct bat_priv *bat_priv,
-				struct vis_info *info)
+static int batadv_find_best_vis_server(struct bat_priv *bat_priv,
+				       struct vis_info *info)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct neigh_node *router;
@@ -600,7 +603,7 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 }
 
 /* Return true if the vis packet is full. */
-static bool vis_packet_full(const struct vis_info *info)
+static bool batadv_vis_packet_full(const struct vis_info *info)
 {
 	const struct vis_packet *packet;
 	packet = (struct vis_packet *)info->skb_packet->data;
@@ -614,7 +617,7 @@ static bool vis_packet_full(const struct vis_info *info)
 /* generates a packet of own vis data,
  * returns 0 on success, -1 if no packet could be generated
  */
-static int generate_vis_packet(struct bat_priv *bat_priv)
+static int batadv_generate_vis_packet(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_node *node;
@@ -638,7 +641,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	skb_trim(info->skb_packet, sizeof(*packet));
 
 	if (packet->vis_type == VIS_TYPE_CLIENT_UPDATE) {
-		best_tq = find_best_vis_server(bat_priv, info);
+		best_tq = batadv_find_best_vis_server(bat_priv, info);
 
 		if (best_tq < 0)
 			return best_tq;
@@ -675,7 +678,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 next:
 			batadv_neigh_node_free_ref(router);
 
-			if (vis_packet_full(info))
+			if (batadv_vis_packet_full(info))
 				goto unlock;
 		}
 		rcu_read_unlock();
@@ -697,7 +700,7 @@ next:
 			entry->quality = 0; /* 0 means TT */
 			packet->entries++;
 
-			if (vis_packet_full(info))
+			if (batadv_vis_packet_full(info))
 				goto unlock;
 		}
 		rcu_read_unlock();
@@ -713,7 +716,7 @@ unlock:
 /* free old vis packets. Must be called with this vis_hash_lock
  * held
  */
-static void purge_vis_packets(struct bat_priv *bat_priv)
+static void batadv_purge_vis_packets(struct bat_priv *bat_priv)
 {
 	uint32_t i;
 	struct hashtable_t *hash = bat_priv->vis_hash;
@@ -733,15 +736,15 @@ static void purge_vis_packets(struct bat_priv *bat_priv)
 			if (batadv_has_timed_out(info->first_seen,
 						 VIS_TIMEOUT)) {
 				hlist_del(node);
-				send_list_del(info);
-				kref_put(&info->refcount, free_info);
+				batadv_send_list_del(info);
+				kref_put(&info->refcount, batadv_free_info);
 			}
 		}
 	}
 }
 
-static void broadcast_vis_packet(struct bat_priv *bat_priv,
-				 struct vis_info *info)
+static void batadv_broadcast_vis_packet(struct bat_priv *bat_priv,
+					struct vis_info *info)
 {
 	struct neigh_node *router;
 	struct hashtable_t *hash = bat_priv->orig_hash;
@@ -774,8 +777,8 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 			/* don't send it if we already received the packet from
 			 * this node.
 			 */
-			if (recv_list_is_in(bat_priv, &info->recv_list,
-					    orig_node->orig)) {
+			if (batadv_recv_list_is_in(bat_priv, &info->recv_list,
+						   orig_node->orig)) {
 				batadv_neigh_node_free_ref(router);
 				continue;
 			}
@@ -796,8 +799,8 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 	}
 }
 
-static void unicast_vis_packet(struct bat_priv *bat_priv,
-			       struct vis_info *info)
+static void batadv_unicast_vis_packet(struct bat_priv *bat_priv,
+				      struct vis_info *info)
 {
 	struct orig_node *orig_node;
 	struct neigh_node *router = NULL;
@@ -825,8 +828,9 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 }
 
-/* only send one vis packet. called from send_vis_packets() */
-static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
+/* only send one vis packet. called from batadv_send_vis_packets() */
+static void batadv_send_vis_packet(struct bat_priv *bat_priv,
+				   struct vis_info *info)
 {
 	struct hard_iface *primary_if;
 	struct vis_packet *packet;
@@ -845,9 +849,9 @@ static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
 	packet->header.ttl--;
 
 	if (is_broadcast_ether_addr(packet->target_orig))
-		broadcast_vis_packet(bat_priv, info);
+		batadv_broadcast_vis_packet(bat_priv, info);
 	else
-		unicast_vis_packet(bat_priv, info);
+		batadv_unicast_vis_packet(bat_priv, info);
 	packet->header.ttl++; /* restore TTL */
 
 out:
@@ -856,7 +860,7 @@ out:
 }
 
 /* called from timer; send (and maybe generate) vis packet. */
-static void send_vis_packets(struct work_struct *work)
+static void batadv_send_vis_packets(struct work_struct *work)
 {
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
@@ -865,11 +869,11 @@ static void send_vis_packets(struct work_struct *work)
 	struct vis_info *info;
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
-	purge_vis_packets(bat_priv);
+	batadv_purge_vis_packets(bat_priv);
 
-	if (generate_vis_packet(bat_priv) == 0) {
+	if (batadv_generate_vis_packet(bat_priv) == 0) {
 		/* schedule if generation was successful */
-		send_list_add(bat_priv, bat_priv->my_vis_info);
+		batadv_send_list_add(bat_priv, bat_priv->my_vis_info);
 	}
 
 	while (!list_empty(&bat_priv->vis_send_list)) {
@@ -879,14 +883,14 @@ static void send_vis_packets(struct work_struct *work)
 		kref_get(&info->refcount);
 		spin_unlock_bh(&bat_priv->vis_hash_lock);
 
-		send_vis_packet(bat_priv, info);
+		batadv_send_vis_packet(bat_priv, info);
 
 		spin_lock_bh(&bat_priv->vis_hash_lock);
-		send_list_del(info);
-		kref_put(&info->refcount, free_info);
+		batadv_send_list_del(info);
+		kref_put(&info->refcount, batadv_free_info);
 	}
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
-	start_vis_timer(bat_priv);
+	batadv_start_vis_timer(bat_priv);
 }
 
 /* init the vis server. this may only be called when if_list is already
@@ -937,18 +941,19 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 
 	INIT_LIST_HEAD(&bat_priv->vis_send_list);
 
-	hash_added = batadv_hash_add(bat_priv->vis_hash, vis_info_cmp,
-				     vis_info_choose, bat_priv->my_vis_info,
+	hash_added = batadv_hash_add(bat_priv->vis_hash, batadv_vis_info_cmp,
+				     batadv_vis_info_choose,
+				     bat_priv->my_vis_info,
 				     &bat_priv->my_vis_info->hash_entry);
 	if (hash_added != 0) {
 		pr_err("Can't add own vis packet into hash\n");
 		/* not in hash, need to remove it manually. */
-		kref_put(&bat_priv->my_vis_info->refcount, free_info);
+		kref_put(&bat_priv->my_vis_info->refcount, batadv_free_info);
 		goto err;
 	}
 
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
-	start_vis_timer(bat_priv);
+	batadv_start_vis_timer(bat_priv);
 	return 0;
 
 free_info:
@@ -961,13 +966,13 @@ err:
 }
 
 /* Decrease the reference count on a hash item info */
-static void free_info_ref(struct hlist_node *node, void *arg)
+static void batadv_free_info_ref(struct hlist_node *node, void *arg)
 {
 	struct vis_info *info;
 
 	info = container_of(node, struct vis_info, hash_entry);
-	send_list_del(info);
-	kref_put(&info->refcount, free_info);
+	batadv_send_list_del(info);
+	kref_put(&info->refcount, batadv_free_info);
 }
 
 /* shutdown vis-server */
@@ -980,16 +985,16 @@ void batadv_vis_quit(struct bat_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 	/* properly remove, kill timers ... */
-	batadv_hash_delete(bat_priv->vis_hash, free_info_ref, NULL);
+	batadv_hash_delete(bat_priv->vis_hash, batadv_free_info_ref, NULL);
 	bat_priv->vis_hash = NULL;
 	bat_priv->my_vis_info = NULL;
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
 }
 
 /* schedule packets for (re)transmission */
-static void start_vis_timer(struct bat_priv *bat_priv)
+static void batadv_start_vis_timer(struct bat_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->vis_work, send_vis_packets);
+	INIT_DELAYED_WORK(&bat_priv->vis_work, batadv_send_vis_packets);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis_work,
 			   msecs_to_jiffies(VIS_INTERVAL));
 }
-- 
1.7.9.4
