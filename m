From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 06/20] batman-adv: Prefix gateway-client
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:42 +0200
Message-ID: <1340297876-29923-7-git-send-email-ordex@autistici.org>
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
 net/batman-adv/bat_debugfs.c    |    2 +-
 net/batman-adv/bat_iv_ogm.c     |    6 +++---
 net/batman-adv/bat_sysfs.c      |    4 ++--
 net/batman-adv/gateway_client.c |   40 ++++++++++++++++++++-------------------
 net/batman-adv/gateway_client.h |   26 +++++++++++++------------
 net/batman-adv/gateway_common.c |    2 +-
 net/batman-adv/main.c           |    2 +-
 net/batman-adv/originator.c     |    7 ++++---
 net/batman-adv/soft-interface.c |    6 +++---
 net/batman-adv/unicast.c        |    2 +-
 10 files changed, 51 insertions(+), 46 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 71b225c..7b294b4 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -236,7 +236,7 @@ static int originators_open(struct inode *inode, struct file *file)
 static int gateways_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, gw_client_seq_print_text, net_dev);
+	return single_open(file, batadv_gw_client_seq_print_text, net_dev);
 }
 
 static int transtable_global_open(struct inode *inode, struct file *file)
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 53bce95..defcac1 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -729,8 +729,8 @@ update_tt:
 			       ntohs(batman_ogm_packet->tt_crc));
 
 	if (orig_node->gw_flags != batman_ogm_packet->gw_flags)
-		gw_node_update(bat_priv, orig_node,
-			       batman_ogm_packet->gw_flags);
+		batadv_gw_node_update(bat_priv, orig_node,
+				      batman_ogm_packet->gw_flags);
 
 	orig_node->gw_flags = batman_ogm_packet->gw_flags;
 
@@ -738,7 +738,7 @@ update_tt:
 	if ((orig_node->gw_flags) &&
 	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_CLIENT) &&
 	    (atomic_read(&bat_priv->gw_sel_class) > 2))
-		gw_check_election(bat_priv, orig_node);
+		batadv_gw_check_election(bat_priv, orig_node);
 
 	goto out;
 
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 5dce1ab..31d23db 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -326,7 +326,7 @@ static ssize_t show_bat_algo(struct kobject *kobj, struct attribute *attr,
 static void post_gw_deselect(struct net_device *net_dev)
 {
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
-	gw_deselect(bat_priv);
+	batadv_gw_deselect(bat_priv);
 }
 
 static ssize_t show_gw_mode(struct kobject *kobj, struct attribute *attr,
@@ -397,7 +397,7 @@ static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *attr,
 	bat_info(net_dev, "Changing gw mode from: %s to: %s\n",
 		 curr_gw_mode_str, buff);
 
-	gw_deselect(bat_priv);
+	batadv_gw_deselect(bat_priv);
 	atomic_set(&bat_priv->gw_mode, (unsigned int)gw_mode_tmp);
 	return count;
 }
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 1d7f08e..a28d9ce 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -60,7 +60,7 @@ out:
 	return gw_node;
 }
 
-struct orig_node *gw_get_selected_orig(struct bat_priv *bat_priv)
+struct orig_node *batadv_gw_get_selected_orig(struct bat_priv *bat_priv)
 {
 	struct gw_node *gw_node;
 	struct orig_node *orig_node = NULL;
@@ -103,7 +103,7 @@ static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
 	spin_unlock_bh(&bat_priv->gw_list_lock);
 }
 
-void gw_deselect(struct bat_priv *bat_priv)
+void batadv_gw_deselect(struct bat_priv *bat_priv)
 {
 	atomic_set(&bat_priv->gw_reselect, 1);
 }
@@ -182,7 +182,7 @@ next:
 	return curr_gw;
 }
 
-void gw_election(struct bat_priv *bat_priv)
+void batadv_gw_election(struct bat_priv *bat_priv)
 {
 	struct gw_node *curr_gw = NULL, *next_gw = NULL;
 	struct neigh_node *router = NULL;
@@ -212,7 +212,7 @@ void gw_election(struct bat_priv *bat_priv)
 
 		router = orig_node_get_router(next_gw->orig_node);
 		if (!router) {
-			gw_deselect(bat_priv);
+			batadv_gw_deselect(bat_priv);
 			goto out;
 		}
 	}
@@ -246,13 +246,14 @@ out:
 		neigh_node_free_ref(router);
 }
 
-void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
+void batadv_gw_check_election(struct bat_priv *bat_priv,
+			      struct orig_node *orig_node)
 {
 	struct orig_node *curr_gw_orig;
 	struct neigh_node *router_gw = NULL, *router_orig = NULL;
 	uint8_t gw_tq_avg, orig_tq_avg;
 
-	curr_gw_orig = gw_get_selected_orig(bat_priv);
+	curr_gw_orig = batadv_gw_get_selected_orig(bat_priv);
 	if (!curr_gw_orig)
 		goto deselect;
 
@@ -288,7 +289,7 @@ void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
 		gw_tq_avg, orig_tq_avg);
 
 deselect:
-	gw_deselect(bat_priv);
+	batadv_gw_deselect(bat_priv);
 out:
 	if (curr_gw_orig)
 		orig_node_free_ref(curr_gw_orig);
@@ -328,8 +329,8 @@ static void gw_node_add(struct bat_priv *bat_priv,
 		(up > 2048 ? "MBit" : "KBit"));
 }
 
-void gw_node_update(struct bat_priv *bat_priv,
-		    struct orig_node *orig_node, uint8_t new_gwflags)
+void batadv_gw_node_update(struct bat_priv *bat_priv,
+			   struct orig_node *orig_node, uint8_t new_gwflags)
 {
 	struct hlist_node *node;
 	struct gw_node *gw_node, *curr_gw;
@@ -374,7 +375,7 @@ void gw_node_update(struct bat_priv *bat_priv,
 	goto unlock;
 
 deselect:
-	gw_deselect(bat_priv);
+	batadv_gw_deselect(bat_priv);
 unlock:
 	rcu_read_unlock();
 
@@ -382,12 +383,13 @@ unlock:
 		gw_node_free_ref(curr_gw);
 }
 
-void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node)
+void batadv_gw_node_delete(struct bat_priv *bat_priv,
+			   struct orig_node *orig_node)
 {
-	gw_node_update(bat_priv, orig_node, 0);
+	batadv_gw_node_update(bat_priv, orig_node, 0);
 }
 
-void gw_node_purge(struct bat_priv *bat_priv)
+void batadv_gw_node_purge(struct bat_priv *bat_priv)
 {
 	struct gw_node *gw_node, *curr_gw;
 	struct hlist_node *node, *node_tmp;
@@ -416,7 +418,7 @@ void gw_node_purge(struct bat_priv *bat_priv)
 
 	/* gw_deselect() needs to acquire the gw_list_lock */
 	if (do_deselect)
-		gw_deselect(bat_priv);
+		batadv_gw_deselect(bat_priv);
 
 	if (curr_gw)
 		gw_node_free_ref(curr_gw);
@@ -458,7 +460,7 @@ out:
 	return ret;
 }
 
-int gw_client_seq_print_text(struct seq_file *seq, void *offset)
+int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
@@ -568,7 +570,7 @@ out:
 	return ret;
 }
 
-bool gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
+bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 {
 	struct ethhdr *ethhdr;
 	struct iphdr *iphdr;
@@ -634,8 +636,8 @@ bool gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 	return true;
 }
 
-bool gw_out_of_range(struct bat_priv *bat_priv,
-		     struct sk_buff *skb, struct ethhdr *ethhdr)
+bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
+			    struct sk_buff *skb, struct ethhdr *ethhdr)
 {
 	struct neigh_node *neigh_curr = NULL, *neigh_old = NULL;
 	struct orig_node *orig_dst_node = NULL;
@@ -644,7 +646,7 @@ bool gw_out_of_range(struct bat_priv *bat_priv,
 	unsigned int header_len = 0;
 	uint8_t curr_tq_avg;
 
-	ret = gw_is_dhcp_target(skb, &header_len);
+	ret = batadv_gw_is_dhcp_target(skb, &header_len);
 	if (!ret)
 		goto out;
 
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index bf56a5a..2c2446f 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -22,17 +22,19 @@
 #ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 #define _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 
-void gw_deselect(struct bat_priv *bat_priv);
-void gw_election(struct bat_priv *bat_priv);
-struct orig_node *gw_get_selected_orig(struct bat_priv *bat_priv);
-void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node);
-void gw_node_update(struct bat_priv *bat_priv,
-		    struct orig_node *orig_node, uint8_t new_gwflags);
-void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node);
-void gw_node_purge(struct bat_priv *bat_priv);
-int gw_client_seq_print_text(struct seq_file *seq, void *offset);
-bool gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len);
-bool gw_out_of_range(struct bat_priv *bat_priv,
-		     struct sk_buff *skb, struct ethhdr *ethhdr);
+void batadv_gw_deselect(struct bat_priv *bat_priv);
+void batadv_gw_election(struct bat_priv *bat_priv);
+struct orig_node *batadv_gw_get_selected_orig(struct bat_priv *bat_priv);
+void batadv_gw_check_election(struct bat_priv *bat_priv,
+			      struct orig_node *orig_node);
+void batadv_gw_node_update(struct bat_priv *bat_priv,
+			   struct orig_node *orig_node, uint8_t new_gwflags);
+void batadv_gw_node_delete(struct bat_priv *bat_priv,
+			   struct orig_node *orig_node);
+void batadv_gw_node_purge(struct bat_priv *bat_priv);
+int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset);
+bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len);
+bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
+			    struct sk_buff *skb, struct ethhdr *ethhdr);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 6e3b052..a0b0f52 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -165,7 +165,7 @@ ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
 	if (atomic_read(&bat_priv->gw_bandwidth) == gw_bandwidth_tmp)
 		return count;
 
-	gw_deselect(bat_priv);
+	batadv_gw_deselect(bat_priv);
 	bat_info(net_dev,
 		 "Changing gateway bandwidth from: '%i' to: '%ld' (propagating: %d%s/%d%s)\n",
 		 atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 3e1bb7a..8fe70b4 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -149,7 +149,7 @@ void mesh_free(struct net_device *soft_iface)
 
 	vis_quit(bat_priv);
 
-	gw_node_purge(bat_priv);
+	batadv_gw_node_purge(bat_priv);
 	originator_free(bat_priv);
 
 	tt_free(bat_priv);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index cf83c54..2f921bf 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -361,7 +361,8 @@ static void _purge_orig(struct bat_priv *bat_priv)
 					  head, hash_entry) {
 			if (purge_orig_node(bat_priv, orig_node)) {
 				if (orig_node->gw_flags)
-					gw_node_delete(bat_priv, orig_node);
+					batadv_gw_node_delete(bat_priv,
+							      orig_node);
 				hlist_del_rcu(node);
 				orig_node_free_ref(orig_node);
 				continue;
@@ -374,8 +375,8 @@ static void _purge_orig(struct bat_priv *bat_priv)
 		spin_unlock_bh(list_lock);
 	}
 
-	gw_node_purge(bat_priv);
-	gw_election(bat_priv);
+	batadv_gw_node_purge(bat_priv);
+	batadv_gw_election(bat_priv);
 }
 
 static void purge_orig(struct work_struct *work)
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 16e866a..bfc4fe0 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -181,14 +181,14 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		case GW_MODE_SERVER:
 			/* gateway servers should not send dhcp
 			 * requests into the mesh */
-			ret = gw_is_dhcp_target(skb, &header_len);
+			ret = batadv_gw_is_dhcp_target(skb, &header_len);
 			if (ret)
 				goto dropped;
 			break;
 		case GW_MODE_CLIENT:
 			/* gateway clients should send dhcp requests
 			 * via unicast to their gateway */
-			ret = gw_is_dhcp_target(skb, &header_len);
+			ret = batadv_gw_is_dhcp_target(skb, &header_len);
 			if (ret)
 				do_bcast = false;
 			break;
@@ -232,7 +232,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	/* unicast packet */
 	} else {
 		if (atomic_read(&bat_priv->gw_mode) != GW_MODE_OFF) {
-			ret = gw_out_of_range(bat_priv, skb, ethhdr);
+			ret = batadv_gw_out_of_range(bat_priv, skb, ethhdr);
 			if (ret)
 				goto dropped;
 		}
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 74175c2..92d3ea3 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -294,7 +294,7 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
-		orig_node = gw_get_selected_orig(bat_priv);
+		orig_node = batadv_gw_get_selected_orig(bat_priv);
 		if (orig_node)
 			goto find_router;
 	}
-- 
1.7.9.4
