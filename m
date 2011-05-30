From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 11/17] batman-adv: Calculate sizeof using variable insead of types
Date: Mon, 30 May 2011 09:22:56 +0200
Message-ID: <1306740182-2665-12-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60278 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab1E3HXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:22 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/CodingStyle recommends to use the form

	p = kmalloc(sizeof(*p), ...);

to calculate the size of a struct and not the version where the struct
name is spelled out to prevent bugs when the type of p changes. This
also seems appropriate for manipulation of buffers when they are
directly associated with p.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/aggregation.c       |    2 +-
 net/batman-adv/bat_debugfs.c       |    2 +-
 net/batman-adv/gateway_client.c    |   12 +++++-----
 net/batman-adv/hard-interface.c    |    2 +-
 net/batman-adv/hash.c              |    7 +++--
 net/batman-adv/icmp_socket.c       |    4 +-
 net/batman-adv/originator.c        |    4 +-
 net/batman-adv/routing.c           |    8 +++---
 net/batman-adv/send.c              |   17 +++++++--------
 net/batman-adv/soft-interface.c    |   12 ++++------
 net/batman-adv/translation-table.c |    7 ++---
 net/batman-adv/unicast.c           |   21 +++++++++----------
 net/batman-adv/unicast.h           |    2 +-
 net/batman-adv/vis.c               |   37 ++++++++++++++++-------------------
 14 files changed, 65 insertions(+), 72 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index f8ccb49b..b41f25b 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -119,7 +119,7 @@ static void new_aggregated_packet(const unsigned char *packet_buff,
 		}
 	}
 
-	forw_packet_aggr = kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
+	forw_packet_aggr = kmalloc(sizeof(*forw_packet_aggr), GFP_ATOMIC);
 	if (!forw_packet_aggr) {
 		if (!own_packet)
 			atomic_inc(&bat_priv->batman_queue_left);
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 1049ae3..d0af9bf 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -185,7 +185,7 @@ static int debug_log_setup(struct bat_priv *bat_priv)
 	if (!bat_priv->debug_dir)
 		goto err;
 
-	bat_priv->debug_log = kzalloc(sizeof(struct debug_log), GFP_ATOMIC);
+	bat_priv->debug_log = kzalloc(sizeof(*bat_priv->debug_log), GFP_ATOMIC);
 	if (!bat_priv->debug_log)
 		goto err;
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index e9c7eb1..a44dff3 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -273,7 +273,7 @@ static void gw_node_add(struct bat_priv *bat_priv,
 	struct gw_node *gw_node;
 	int down, up;
 
-	gw_node = kzalloc(sizeof(struct gw_node), GFP_ATOMIC);
+	gw_node = kzalloc(sizeof(*gw_node), GFP_ATOMIC);
 	if (!gw_node)
 		return;
 
@@ -508,7 +508,7 @@ int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
 	/* check for ip header */
 	switch (ntohs(ethhdr->h_proto)) {
 	case ETH_P_IP:
-		if (!pskb_may_pull(skb, header_len + sizeof(struct iphdr)))
+		if (!pskb_may_pull(skb, header_len + sizeof(*iphdr)))
 			return 0;
 		iphdr = (struct iphdr *)(skb->data + header_len);
 		header_len += iphdr->ihl * 4;
@@ -519,10 +519,10 @@ int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
 
 		break;
 	case ETH_P_IPV6:
-		if (!pskb_may_pull(skb, header_len + sizeof(struct ipv6hdr)))
+		if (!pskb_may_pull(skb, header_len + sizeof(*ipv6hdr)))
 			return 0;
 		ipv6hdr = (struct ipv6hdr *)(skb->data + header_len);
-		header_len += sizeof(struct ipv6hdr);
+		header_len += sizeof(*ipv6hdr);
 
 		/* check for udp header */
 		if (ipv6hdr->nexthdr != IPPROTO_UDP)
@@ -533,10 +533,10 @@ int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
 		return 0;
 	}
 
-	if (!pskb_may_pull(skb, header_len + sizeof(struct udphdr)))
+	if (!pskb_may_pull(skb, header_len + sizeof(*udphdr)))
 		return 0;
 	udphdr = (struct udphdr *)(skb->data + header_len);
-	header_len += sizeof(struct udphdr);
+	header_len += sizeof(*udphdr);
 
 	/* check for bootp port */
 	if ((ntohs(ethhdr->h_proto) == ETH_P_IP) &&
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index e626e75..e0052cf 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -459,7 +459,7 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 
 	dev_hold(net_dev);
 
-	hard_iface = kmalloc(sizeof(struct hard_iface), GFP_ATOMIC);
+	hard_iface = kmalloc(sizeof(*hard_iface), GFP_ATOMIC);
 	if (!hard_iface) {
 		pr_err("Can't add interface (%s): out of memory\n",
 		       net_dev->name);
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index c5213d8..2a17250 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -46,15 +46,16 @@ struct hashtable_t *hash_new(int size)
 {
 	struct hashtable_t *hash;
 
-	hash = kmalloc(sizeof(struct hashtable_t), GFP_ATOMIC);
+	hash = kmalloc(sizeof(*hash), GFP_ATOMIC);
 	if (!hash)
 		return NULL;
 
-	hash->table = kmalloc(sizeof(struct element_t *) * size, GFP_ATOMIC);
+	hash->table = kmalloc(sizeof(*hash->table) * size, GFP_ATOMIC);
 	if (!hash->table)
 		goto free_hash;
 
-	hash->list_locks = kmalloc(sizeof(spinlock_t) * size, GFP_ATOMIC);
+	hash->list_locks = kmalloc(sizeof(*hash->list_locks) * size,
+				   GFP_ATOMIC);
 	if (!hash->list_locks)
 		goto free_table;
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index fa22ba2..ac3520e0 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -46,7 +46,7 @@ static int bat_socket_open(struct inode *inode, struct file *file)
 
 	nonseekable_open(inode, file);
 
-	socket_client = kmalloc(sizeof(struct socket_client), GFP_KERNEL);
+	socket_client = kmalloc(sizeof(*socket_client), GFP_KERNEL);
 
 	if (!socket_client)
 		return -ENOMEM;
@@ -310,7 +310,7 @@ static void bat_socket_add_packet(struct socket_client *socket_client,
 {
 	struct socket_packet *socket_packet;
 
-	socket_packet = kmalloc(sizeof(struct socket_packet), GFP_ATOMIC);
+	socket_packet = kmalloc(sizeof(*socket_packet), GFP_ATOMIC);
 
 	if (!socket_packet)
 		return;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 3ea997d..a6c35d4 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -86,7 +86,7 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Creating new last-hop neighbor of originator\n");
 
-	neigh_node = kzalloc(sizeof(struct neigh_node), GFP_ATOMIC);
+	neigh_node = kzalloc(sizeof(*neigh_node), GFP_ATOMIC);
 	if (!neigh_node)
 		return NULL;
 
@@ -196,7 +196,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Creating new originator: %pM\n", addr);
 
-	orig_node = kzalloc(sizeof(struct orig_node), GFP_ATOMIC);
+	orig_node = kzalloc(sizeof(*orig_node), GFP_ATOMIC);
 	if (!orig_node)
 		return NULL;
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e0df4a0..07f23ba 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1357,7 +1357,7 @@ out:
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct unicast_packet *unicast_packet;
-	int hdr_size = sizeof(struct unicast_packet);
+	int hdr_size = sizeof(*unicast_packet);
 
 	if (check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
@@ -1377,7 +1377,7 @@ int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct unicast_frag_packet *unicast_packet;
-	int hdr_size = sizeof(struct unicast_frag_packet);
+	int hdr_size = sizeof(*unicast_packet);
 	struct sk_buff *new_skb = NULL;
 	int ret;
 
@@ -1413,7 +1413,7 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	struct orig_node *orig_node = NULL;
 	struct bcast_packet *bcast_packet;
 	struct ethhdr *ethhdr;
-	int hdr_size = sizeof(struct bcast_packet);
+	int hdr_size = sizeof(*bcast_packet);
 	int ret = NET_RX_DROP;
 	int32_t seq_diff;
 
@@ -1491,7 +1491,7 @@ int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	struct vis_packet *vis_packet;
 	struct ethhdr *ethhdr;
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	int hdr_size = sizeof(struct vis_packet);
+	int hdr_size = sizeof(*vis_packet);
 
 	/* keep skb linear */
 	if (skb_linearize(skb) < 0)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 9a20ba9..d0cfa95 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -73,7 +73,7 @@ int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 	}
 
 	/* push to the ethernet header. */
-	if (my_skb_head_push(skb, sizeof(struct ethhdr)) < 0)
+	if (my_skb_head_push(skb, sizeof(*ethhdr)) < 0)
 		goto send_skb_err;
 
 	skb_reset_mac_header(skb);
@@ -144,7 +144,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 			hard_iface->net_dev->name,
 			hard_iface->net_dev->dev_addr);
 
-		buff_pos += sizeof(struct batman_packet) +
+		buff_pos += sizeof(*batman_packet) +
 			(batman_packet->num_tt * ETH_ALEN);
 		packet_num++;
 		batman_packet = (struct batman_packet *)
@@ -220,19 +220,18 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 	unsigned char *new_buff;
 	struct batman_packet *batman_packet;
 
-	new_len = sizeof(struct batman_packet) +
-			(bat_priv->num_local_tt * ETH_ALEN);
+	new_len = sizeof(*batman_packet) + (bat_priv->num_local_tt * ETH_ALEN);
 	new_buff = kmalloc(new_len, GFP_ATOMIC);
 
 	/* keep old buffer if kmalloc should fail */
 	if (new_buff) {
 		memcpy(new_buff, hard_iface->packet_buff,
-		       sizeof(struct batman_packet));
+		       sizeof(*batman_packet));
 		batman_packet = (struct batman_packet *)new_buff;
 
 		batman_packet->num_tt = tt_local_fill_buffer(bat_priv,
-				new_buff + sizeof(struct batman_packet),
-				new_len - sizeof(struct batman_packet));
+					new_buff + sizeof(*batman_packet),
+					new_len - sizeof(*batman_packet));
 
 		kfree(hard_iface->packet_buff);
 		hard_iface->packet_buff = new_buff;
@@ -368,7 +367,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 	send_time = forward_send_time();
 	add_bat_packet_to_list(bat_priv,
 			       (unsigned char *)batman_packet,
-			       sizeof(struct batman_packet) + tt_buff_len,
+			       sizeof(*batman_packet) + tt_buff_len,
 			       if_incoming, 0, send_time);
 }
 
@@ -424,7 +423,7 @@ int add_bcast_packet_to_list(struct bat_priv *bat_priv,
 	if (!primary_if)
 		goto out_and_inc;
 
-	forw_packet = kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
+	forw_packet = kmalloc(sizeof(*forw_packet), GFP_ATOMIC);
 
 	if (!forw_packet)
 		goto out_and_inc;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 1bec3a0..cead606 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -123,8 +123,7 @@ static struct softif_neigh_vid *softif_neigh_vid_get(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	softif_neigh_vid = kzalloc(sizeof(struct softif_neigh_vid),
-				   GFP_ATOMIC);
+	softif_neigh_vid = kzalloc(sizeof(*softif_neigh_vid), GFP_ATOMIC);
 	if (!softif_neigh_vid)
 		goto out;
 
@@ -170,7 +169,7 @@ static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
 		goto unlock;
 	}
 
-	softif_neigh = kzalloc(sizeof(struct softif_neigh), GFP_ATOMIC);
+	softif_neigh = kzalloc(sizeof(*softif_neigh), GFP_ATOMIC);
 	if (!softif_neigh)
 		goto unlock;
 
@@ -611,7 +610,7 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		if (!primary_if)
 			goto dropped;
 
-		if (my_skb_head_push(skb, sizeof(struct bcast_packet)) < 0)
+		if (my_skb_head_push(skb, sizeof(*bcast_packet)) < 0)
 			goto dropped;
 
 		bcast_packet = (struct bcast_packet *)skb->data;
@@ -790,7 +789,7 @@ static void interface_setup(struct net_device *dev)
 
 	SET_ETHTOOL_OPS(dev, &bat_ethtool_ops);
 
-	memset(priv, 0, sizeof(struct bat_priv));
+	memset(priv, 0, sizeof(*priv));
 }
 
 struct net_device *softif_create(const char *name)
@@ -799,8 +798,7 @@ struct net_device *softif_create(const char *name)
 	struct bat_priv *bat_priv;
 	int ret;
 
-	soft_iface = alloc_netdev(sizeof(struct bat_priv) , name,
-				   interface_setup);
+	soft_iface = alloc_netdev(sizeof(*bat_priv), name, interface_setup);
 
 	if (!soft_iface) {
 		pr_err("Unable to allocate the batman interface: %s\n", name);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 802eace..561f769 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -164,7 +164,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	bat_dbg(DBG_ROUTES, bat_priv,
 		"Creating new local tt entry: %pM\n", addr);
 
-	tt_local_entry = kmalloc(sizeof(struct tt_local_entry), GFP_ATOMIC);
+	tt_local_entry = kmalloc(sizeof(*tt_local_entry), GFP_ATOMIC);
 	if (!tt_local_entry)
 		return;
 
@@ -427,9 +427,8 @@ void tt_global_add_orig(struct bat_priv *bat_priv,
 		if (!tt_global_entry) {
 			spin_unlock_bh(&bat_priv->tt_ghash_lock);
 
-			tt_global_entry =
-				kmalloc(sizeof(struct tt_global_entry),
-					GFP_ATOMIC);
+			tt_global_entry = kmalloc(sizeof(*tt_global_entry),
+						  GFP_ATOMIC);
 
 			if (!tt_global_entry)
 				break;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 82717fd..6eabf42 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -39,8 +39,8 @@ static struct sk_buff *frag_merge_packet(struct list_head *head,
 		(struct unicast_frag_packet *)skb->data;
 	struct sk_buff *tmp_skb;
 	struct unicast_packet *unicast_packet;
-	int hdr_len = sizeof(struct unicast_packet);
-	int uni_diff = sizeof(struct unicast_frag_packet) - hdr_len;
+	int hdr_len = sizeof(*unicast_packet);
+	int uni_diff = sizeof(*up) - hdr_len;
 
 	/* set skb to the first part and tmp_skb to the second part */
 	if (up->flags & UNI_FRAG_HEAD) {
@@ -53,7 +53,7 @@ static struct sk_buff *frag_merge_packet(struct list_head *head,
 	if (skb_linearize(skb) < 0 || skb_linearize(tmp_skb) < 0)
 		goto err;
 
-	skb_pull(tmp_skb, sizeof(struct unicast_frag_packet));
+	skb_pull(tmp_skb, sizeof(*up));
 	if (pskb_expand_head(skb, 0, tmp_skb->len, GFP_ATOMIC) < 0)
 		goto err;
 
@@ -99,8 +99,7 @@ static int frag_create_buffer(struct list_head *head)
 	struct frag_packet_list_entry *tfp;
 
 	for (i = 0; i < FRAG_BUFFER_SIZE; i++) {
-		tfp = kmalloc(sizeof(struct frag_packet_list_entry),
-			GFP_ATOMIC);
+		tfp = kmalloc(sizeof(*tfp), GFP_ATOMIC);
 		if (!tfp) {
 			frag_list_free(head);
 			return -ENOMEM;
@@ -224,8 +223,8 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	struct hard_iface *primary_if;
 	struct sk_buff *frag_skb;
 	struct unicast_frag_packet *frag1, *frag2;
-	int uc_hdr_len = sizeof(struct unicast_packet);
-	int ucf_hdr_len = sizeof(struct unicast_frag_packet);
+	int uc_hdr_len = sizeof(*unicast_packet);
+	int ucf_hdr_len = sizeof(*frag1);
 	int data_len = skb->len - uc_hdr_len;
 	int large_tail = 0, ret = NET_RX_DROP;
 	uint16_t seqno;
@@ -250,14 +249,14 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	frag1 = (struct unicast_frag_packet *)skb->data;
 	frag2 = (struct unicast_frag_packet *)frag_skb->data;
 
-	memcpy(frag1, &tmp_uc, sizeof(struct unicast_packet));
+	memcpy(frag1, &tmp_uc, sizeof(tmp_uc));
 
 	frag1->ttl--;
 	frag1->version = COMPAT_VERSION;
 	frag1->packet_type = BAT_UNICAST_FRAG;
 
 	memcpy(frag1->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(frag2, frag1, sizeof(struct unicast_frag_packet));
+	memcpy(frag2, frag1, sizeof(*frag2));
 
 	if (data_len & 1)
 		large_tail = UNI_FRAG_LARGETAIL;
@@ -314,7 +313,7 @@ find_router:
 	if (!neigh_node)
 		goto out;
 
-	if (my_skb_head_push(skb, sizeof(struct unicast_packet)) < 0)
+	if (my_skb_head_push(skb, sizeof(*unicast_packet)) < 0)
 		goto out;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
@@ -328,7 +327,7 @@ find_router:
 	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
 
 	if (atomic_read(&bat_priv->fragmentation) &&
-	    data_len + sizeof(struct unicast_packet) >
+	    data_len + sizeof(*unicast_packet) >
 				neigh_node->if_incoming->net_dev->mtu) {
 		/* send frag skb decreases ttl */
 		unicast_packet->ttl++;
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 2ba867c..62f54b9 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -49,7 +49,7 @@ static inline int frag_can_reassemble(const struct sk_buff *skb, int mtu)
 			uneven_correction = -1;
 	}
 
-	merged_size = (skb->len - sizeof(struct unicast_frag_packet)) * 2;
+	merged_size = (skb->len - sizeof(*unicast_packet)) * 2;
 	merged_size += sizeof(struct unicast_packet) + uneven_correction;
 
 	return merged_size <= mtu;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index b48954c..ea8d7e9 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -241,7 +241,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 		hlist_for_each_entry_rcu(info, node, head, hash_entry) {
 			packet = (struct vis_packet *)info->skb_packet->data;
 			entries = (struct vis_info_entry *)
-				((char *)packet + sizeof(struct vis_packet));
+				((char *)packet + sizeof(*packet));
 
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
@@ -289,7 +289,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 		hlist_for_each_entry_rcu(info, node, head, hash_entry) {
 			packet = (struct vis_packet *)info->skb_packet->data;
 			entries = (struct vis_info_entry *)
-				((char *)packet + sizeof(struct vis_packet));
+				((char *)packet + sizeof(*packet));
 
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
@@ -367,7 +367,7 @@ static void recv_list_add(struct bat_priv *bat_priv,
 {
 	struct recvlist_node *entry;
 
-	entry = kmalloc(sizeof(struct recvlist_node), GFP_ATOMIC);
+	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
 		return;
 
@@ -414,11 +414,11 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 		return NULL;
 
 	/* see if the packet is already in vis_hash */
-	search_elem.skb_packet = dev_alloc_skb(sizeof(struct vis_packet));
+	search_elem.skb_packet = dev_alloc_skb(sizeof(*search_packet));
 	if (!search_elem.skb_packet)
 		return NULL;
 	search_packet = (struct vis_packet *)skb_put(search_elem.skb_packet,
-						     sizeof(struct vis_packet));
+						     sizeof(*search_packet));
 
 	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
 	old_info = vis_hash_find(bat_priv, &search_elem);
@@ -444,27 +444,26 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 		kref_put(&old_info->refcount, free_info);
 	}
 
-	info = kmalloc(sizeof(struct vis_info), GFP_ATOMIC);
+	info = kmalloc(sizeof(*info), GFP_ATOMIC);
 	if (!info)
 		return NULL;
 
-	info->skb_packet = dev_alloc_skb(sizeof(struct vis_packet) +
-					 vis_info_len + sizeof(struct ethhdr));
+	info->skb_packet = dev_alloc_skb(sizeof(*packet) + vis_info_len +
+					 sizeof(struct ethhdr));
 	if (!info->skb_packet) {
 		kfree(info);
 		return NULL;
 	}
 	skb_reserve(info->skb_packet, sizeof(struct ethhdr));
-	packet = (struct vis_packet *)skb_put(info->skb_packet,
-					      sizeof(struct vis_packet) +
-					      vis_info_len);
+	packet = (struct vis_packet *)skb_put(info->skb_packet, sizeof(*packet)
+					      + vis_info_len);
 
 	kref_init(&info->refcount);
 	INIT_LIST_HEAD(&info->send_list);
 	INIT_LIST_HEAD(&info->recv_list);
 	info->first_seen = jiffies;
 	info->bat_priv = bat_priv;
-	memcpy(packet, vis_packet, sizeof(struct vis_packet) + vis_info_len);
+	memcpy(packet, vis_packet, sizeof(*packet) + vis_info_len);
 
 	/* initialize and add new packet. */
 	*is_new = 1;
@@ -634,7 +633,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	packet->ttl = TTL;
 	packet->seqno = htonl(ntohl(packet->seqno) + 1);
 	packet->entries = 0;
-	skb_trim(info->skb_packet, sizeof(struct vis_packet));
+	skb_trim(info->skb_packet, sizeof(*packet));
 
 	if (packet->vis_type == VIS_TYPE_CLIENT_UPDATE) {
 		best_tq = find_best_vis_server(bat_priv, info);
@@ -910,17 +909,15 @@ int vis_init(struct bat_priv *bat_priv)
 		goto err;
 	}
 
-	bat_priv->my_vis_info->skb_packet = dev_alloc_skb(
-						sizeof(struct vis_packet) +
-						MAX_VIS_PACKET_SIZE +
-						sizeof(struct ethhdr));
+	bat_priv->my_vis_info->skb_packet = dev_alloc_skb(sizeof(*packet) +
+							  MAX_VIS_PACKET_SIZE +
+							 sizeof(struct ethhdr));
 	if (!bat_priv->my_vis_info->skb_packet)
 		goto free_info;
 
 	skb_reserve(bat_priv->my_vis_info->skb_packet, sizeof(struct ethhdr));
-	packet = (struct vis_packet *)skb_put(
-					bat_priv->my_vis_info->skb_packet,
-					sizeof(struct vis_packet));
+	packet = (struct vis_packet *)skb_put(bat_priv->my_vis_info->skb_packet,
+					      sizeof(*packet));
 
 	/* prefill the vis info */
 	bat_priv->my_vis_info->first_seen = jiffies -
-- 
1.7.5.3

