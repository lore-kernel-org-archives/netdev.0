From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 05/20] batman-adv: Prefix
	bridge_loop_avoidance non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:41 +0200
Message-ID: <1340297876-29923-6-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c           |    3 +-
 net/batman-adv/bridge_loop_avoidance.c |   28 ++++++-------
 net/batman-adv/bridge_loop_avoidance.h |   67 +++++++++++++++++---------------
 net/batman-adv/hard-interface.c        |    2 +-
 net/batman-adv/main.c                  |    4 +-
 net/batman-adv/routing.c               |    6 +--
 net/batman-adv/soft-interface.c        |    4 +-
 net/batman-adv/translation-table.c     |    6 +--
 8 files changed, 62 insertions(+), 58 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 444d10b..71b225c 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -249,7 +249,8 @@ static int transtable_global_open(struct inode *inode, struct file *file)
 static int bla_claim_table_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, bla_claim_table_seq_print_text, net_dev);
+	return single_open(file, batadv_bla_claim_table_seq_print_text,
+			   net_dev);
 }
 #endif
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 314e37b..b0561e3 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1019,9 +1019,9 @@ purge_now:
  * Update the backbone gateways when the own orig address changes.
  *
  */
-void bla_update_orig_address(struct bat_priv *bat_priv,
-			     struct hard_iface *primary_if,
-			     struct hard_iface *oldif)
+void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
+				    struct hard_iface *primary_if,
+				    struct hard_iface *oldif)
 {
 	struct backbone_gw *backbone_gw;
 	struct hlist_node *node;
@@ -1136,7 +1136,7 @@ static struct lock_class_key claim_hash_lock_class_key;
 static struct lock_class_key backbone_hash_lock_class_key;
 
 /* initialize all bla structures */
-int bla_init(struct bat_priv *bat_priv)
+int batadv_bla_init(struct bat_priv *bat_priv)
 {
 	int i;
 	uint8_t claim_dest[ETH_ALEN] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
@@ -1199,9 +1199,9 @@ int bla_init(struct bat_priv *bat_priv)
  *
  **/
 
-int bla_check_bcast_duplist(struct bat_priv *bat_priv,
-			    struct bcast_packet *bcast_packet,
-			    int hdr_size)
+int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
+				   struct bcast_packet *bcast_packet,
+				   int hdr_size)
 {
 	int i, length, curr;
 	uint8_t *content;
@@ -1260,7 +1260,7 @@ int bla_check_bcast_duplist(struct bat_priv *bat_priv,
  *
  */
 
-int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
+int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
 {
 	struct hashtable_t *hash = bat_priv->backbone_hash;
 	struct hlist_head *head;
@@ -1301,8 +1301,8 @@ int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
  * returns 0.
  *
  */
-int bla_is_backbone_gw(struct sk_buff *skb,
-		       struct orig_node *orig_node, int hdr_size)
+int batadv_bla_is_backbone_gw(struct sk_buff *skb,
+			      struct orig_node *orig_node, int hdr_size)
 {
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
@@ -1339,7 +1339,7 @@ int bla_is_backbone_gw(struct sk_buff *skb,
 }
 
 /* free all bla structures (for softinterface free or module unload) */
-void bla_free(struct bat_priv *bat_priv)
+void batadv_bla_free(struct bat_priv *bat_priv)
 {
 	struct hard_iface *primary_if;
 
@@ -1374,7 +1374,7 @@ void bla_free(struct bat_priv *bat_priv)
  * process the skb.
  *
  */
-int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
+int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 {
 	struct ethhdr *ethhdr;
 	struct claim search_claim, *claim = NULL;
@@ -1463,7 +1463,7 @@ out:
  * process the skb.
  *
  */
-int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
+int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 {
 	struct ethhdr *ethhdr;
 	struct claim search_claim, *claim = NULL;
@@ -1537,7 +1537,7 @@ out:
 	return ret;
 }
 
-int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
+int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index e39f93a..546cd64 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -23,73 +23,76 @@
 #define _NET_BATMAN_ADV_BLA_H_
 
 #ifdef CONFIG_BATMAN_ADV_BLA
-int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
-int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
-int bla_is_backbone_gw(struct sk_buff *skb,
-		       struct orig_node *orig_node, int hdr_size);
-int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
-int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig);
-int bla_check_bcast_duplist(struct bat_priv *bat_priv,
-			    struct bcast_packet *bcast_packet, int hdr_size);
-void bla_update_orig_address(struct bat_priv *bat_priv,
-			     struct hard_iface *primary_if,
-			     struct hard_iface *oldif);
-int bla_init(struct bat_priv *bat_priv);
-void bla_free(struct bat_priv *bat_priv);
+int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
+int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
+int batadv_bla_is_backbone_gw(struct sk_buff *skb,
+			      struct orig_node *orig_node, int hdr_size);
+int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig);
+int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
+				   struct bcast_packet *bcast_packet,
+				   int hdr_size);
+void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
+				    struct hard_iface *primary_if,
+				    struct hard_iface *oldif);
+int batadv_bla_init(struct bat_priv *bat_priv);
+void batadv_bla_free(struct bat_priv *bat_priv);
 
 #define BLA_CRC_INIT	0
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
-static inline int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb,
-			 short vid)
+static inline int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb,
+				short vid)
 {
 	return 0;
 }
 
-static inline int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb,
-			 short vid)
+static inline int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb,
+				short vid)
 {
 	return 0;
 }
 
-static inline int bla_is_backbone_gw(struct sk_buff *skb,
-				     struct orig_node *orig_node,
-				     int hdr_size)
+static inline int batadv_bla_is_backbone_gw(struct sk_buff *skb,
+					    struct orig_node *orig_node,
+					    int hdr_size)
 {
 	return 0;
 }
 
-static inline int bla_claim_table_seq_print_text(struct seq_file *seq,
-						 void *offset)
+static inline int batadv_bla_claim_table_seq_print_text(struct seq_file *seq,
+							void *offset)
 {
 	return 0;
 }
 
-static inline int bla_is_backbone_gw_orig(struct bat_priv *bat_priv,
-					  uint8_t *orig)
+static inline int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv,
+						 uint8_t *orig)
 {
 	return 0;
 }
 
-static inline int bla_check_bcast_duplist(struct bat_priv *bat_priv,
-					  struct bcast_packet *bcast_packet,
-					  int hdr_size)
+static inline int
+batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
+			       struct bcast_packet *bcast_packet,
+			       int hdr_size)
 {
 	return 0;
 }
 
-static inline void bla_update_orig_address(struct bat_priv *bat_priv,
-					   struct hard_iface *primary_if,
-					   struct hard_iface *oldif)
+static inline void
+batadv_bla_update_orig_address(struct bat_priv *bat_priv,
+			       struct hard_iface *primary_if,
+			       struct hard_iface *oldif)
 {
 }
 
-static inline int bla_init(struct bat_priv *bat_priv)
+static inline int batadv_bla_init(struct bat_priv *bat_priv)
 {
 	return 1;
 }
 
-static inline void bla_free(struct bat_priv *bat_priv)
+static inline void batadv_bla_free(struct bat_priv *bat_priv)
 {
 }
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 380572e..1643e7f 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -118,7 +118,7 @@ static void primary_if_update_addr(struct bat_priv *bat_priv,
 	memcpy(vis_packet->sender_orig,
 	       primary_if->net_dev->dev_addr, ETH_ALEN);
 
-	bla_update_orig_address(bat_priv, primary_if, oldif);
+	batadv_bla_update_orig_address(bat_priv, primary_if, oldif);
 out:
 	if (primary_if)
 		hardif_free_ref(primary_if);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 46a35e1..3e1bb7a 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -125,7 +125,7 @@ int mesh_init(struct net_device *soft_iface)
 	if (ret < 0)
 		goto err;
 
-	ret = bla_init(bat_priv);
+	ret = batadv_bla_init(bat_priv);
 	if (ret < 0)
 		goto err;
 
@@ -154,7 +154,7 @@ void mesh_free(struct net_device *soft_iface)
 
 	tt_free(bat_priv);
 
-	bla_free(bat_priv);
+	batadv_bla_free(bat_priv);
 
 	free_percpu(bat_priv->bat_counters);
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e573c32..5b5feb4 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -676,7 +676,7 @@ int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	 * roaming advertisement from it, as it has the same
 	 * entries as we have.
 	 */
-	if (bla_is_backbone_gw_orig(bat_priv, roam_adv_packet->src))
+	if (batadv_bla_is_backbone_gw_orig(bat_priv, roam_adv_packet->src))
 		goto out;
 
 	orig_node = orig_hash_find(bat_priv, roam_adv_packet->src);
@@ -1089,7 +1089,7 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
 
 	/* check whether this has been sent by another originator before */
-	if (bla_check_bcast_duplist(bat_priv, bcast_packet, hdr_size))
+	if (batadv_bla_check_bcast_duplist(bat_priv, bcast_packet, hdr_size))
 		goto out;
 
 	/* rebroadcast packet */
@@ -1098,7 +1098,7 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	/* don't hand the broadcast up if it is from an originator
 	 * from the same backbone.
 	 */
-	if (bla_is_backbone_gw(skb, orig_node, hdr_size))
+	if (batadv_bla_is_backbone_gw(skb, orig_node, hdr_size))
 		goto out;
 
 	/* broadcast for me */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 11bfe53..16e866a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -162,7 +162,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		goto dropped;
 	}
 
-	if (bla_tx(bat_priv, skb, vid))
+	if (batadv_bla_tx(bat_priv, skb, vid))
 		goto dropped;
 
 	/* Register the client MAC in the transtable */
@@ -309,7 +309,7 @@ void interface_rx(struct net_device *soft_iface,
 	/* Let the bridge loop avoidance check the packet. If will
 	 * not handle it, we can safely push it up.
 	 */
-	if (bla_rx(bat_priv, skb, vid))
+	if (batadv_bla_rx(bat_priv, skb, vid))
 		goto out;
 
 	netif_rx(skb);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a1a51cc..bb8557e 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1674,7 +1674,7 @@ bool send_tt_response(struct bat_priv *bat_priv,
 {
 	if (is_my_mac(tt_request->dst)) {
 		/* don't answer backbone gws! */
-		if (bla_is_backbone_gw_orig(bat_priv, tt_request->src))
+		if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_request->src))
 			return true;
 
 		return send_my_tt_response(bat_priv, tt_request);
@@ -1786,7 +1786,7 @@ void handle_tt_response(struct bat_priv *bat_priv,
 		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* we should have never asked a backbone gw */
-	if (bla_is_backbone_gw_orig(bat_priv, tt_response->src))
+	if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_response->src))
 		goto out;
 
 	orig_node = orig_hash_find(bat_priv, tt_response->src);
@@ -2163,7 +2163,7 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	bool full_table = true;
 
 	/* don't care about a backbone gateways updates. */
-	if (bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
+	if (batadv_bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
 		return;
 
 	/* orig table not initialised AND first diff is in the OGM OR the ttvn
-- 
1.7.9.4
