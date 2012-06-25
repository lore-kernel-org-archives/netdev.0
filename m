From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 03/20] batman-adv: Prefix hard-interface
	static inline functions with batadv_
Date: Mon, 25 Jun 2012 08:54:27 +0200
Message-ID: <1340607284-29950-4-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340607284-29950-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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
 net/batman-adv/bat_iv_ogm.c            |   14 +++++++-------
 net/batman-adv/bat_sysfs.c             |   16 ++++++++--------
 net/batman-adv/bridge_loop_avoidance.c |   28 ++++++++++++++--------------
 net/batman-adv/gateway_client.c        |    4 ++--
 net/batman-adv/hard-interface.c        |   28 ++++++++++++++--------------
 net/batman-adv/hard-interface.h        |    7 ++++---
 net/batman-adv/icmp_socket.c           |    4 ++--
 net/batman-adv/originator.c            |    4 ++--
 net/batman-adv/routing.c               |   12 ++++++------
 net/batman-adv/send.c                  |    6 +++---
 net/batman-adv/soft-interface.c        |    4 ++--
 net/batman-adv/translation-table.c     |   28 ++++++++++++++--------------
 net/batman-adv/unicast.c               |    4 ++--
 net/batman-adv/vis.c                   |    8 ++++----
 14 files changed, 84 insertions(+), 83 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ad641e8..94e6fdb 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -232,7 +232,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 	if (forw_packet->if_incoming->if_status != IF_ACTIVE)
 		goto out;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -273,7 +273,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 /* return true if new_packet can be aggregated with forw_packet */
@@ -311,7 +311,7 @@ static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
 		 *    a "global" packet as well as the base
 		 *    packet
 		 */
-		primary_if = primary_if_get_selected(bat_priv);
+		primary_if = batadv_primary_if_get_selected(bat_priv);
 		if (!primary_if)
 			goto out;
 
@@ -352,7 +352,7 @@ static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return res;
 }
 
@@ -431,7 +431,7 @@ static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	return;
 out:
-	hardif_free_ref(if_incoming);
+	batadv_hardif_free_ref(if_incoming);
 }
 
 /* aggregate a new packet into the existing ogm packet */
@@ -570,7 +570,7 @@ static void bat_iv_ogm_schedule(struct hard_iface *hard_iface)
 	int vis_server, tt_num_changes = 0;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (hard_iface == primary_if)
 		tt_num_changes = batadv_tt_append_diff(bat_priv,
@@ -608,7 +608,7 @@ static void bat_iv_ogm_schedule(struct hard_iface *hard_iface)
 			     bat_iv_ogm_emit_send_time(bat_priv));
 
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 8196fa6..0c7e22e 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -132,7 +132,7 @@ ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
 	length = __store_uint_attr(buff, count, _min, _max, _post_func,	\
 				   attr, &hard_iface->_name, net_dev);	\
 									\
-	hardif_free_ref(hard_iface);					\
+	batadv_hardif_free_ref(hard_iface);				\
 	return length;							\
 }
 
@@ -150,7 +150,7 @@ ssize_t show_##_name(struct kobject *kobj,				\
 									\
 	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_name));\
 									\
-	hardif_free_ref(hard_iface);					\
+	batadv_hardif_free_ref(hard_iface);				\
 	return length;							\
 }
 
@@ -535,7 +535,7 @@ static ssize_t show_mesh_iface(struct kobject *kobj, struct attribute *attr,
 	length = sprintf(buff, "%s\n", hard_iface->if_status == IF_NOT_IN_USE ?
 			 "none" : hard_iface->soft_iface->name);
 
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 
 	return length;
 }
@@ -557,7 +557,7 @@ static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
 	if (strlen(buff) >= IFNAMSIZ) {
 		pr_err("Invalid parameter for 'mesh_iface' setting received: interface name too long '%s'\n",
 		       buff);
-		hardif_free_ref(hard_iface);
+		batadv_hardif_free_ref(hard_iface);
 		return -EINVAL;
 	}
 
@@ -592,7 +592,7 @@ static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
 unlock:
 	rtnl_unlock();
 out:
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 	return ret;
 }
 
@@ -625,7 +625,7 @@ static ssize_t show_iface_status(struct kobject *kobj, struct attribute *attr,
 		break;
 	}
 
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 
 	return length;
 }
@@ -688,7 +688,7 @@ int batadv_throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
 	struct kobject *bat_kobj;
 	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -727,7 +727,7 @@ out:
 	kfree(uevent_env[2]);
 
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 
 	if (ret)
 		bat_dbg(DBG_BATMAN, bat_priv,
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 52c0d63..72ff8b9 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -255,7 +255,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 	struct bla_claim_dst local_claim_dest;
 	__be32 zeroip = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		return;
 
@@ -339,7 +339,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 	netif_rx(skb);
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 /* @bat_priv: the bat priv with all the soft interface information
@@ -1075,7 +1075,7 @@ static void bla_periodic_work(struct work_struct *work)
 	struct hard_iface *primary_if;
 	int i;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -1106,7 +1106,7 @@ static void bla_periodic_work(struct work_struct *work)
 	}
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 
 	bla_start_timer(bat_priv);
 }
@@ -1131,12 +1131,12 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 	/* setting claim destination address */
 	memcpy(&bat_priv->claim_dest.magic, claim_dest, 3);
 	bat_priv->claim_dest.type = 0;
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (primary_if) {
 		bat_priv->claim_dest.group =
 			htons(crc16(0, primary_if->net_dev->dev_addr,
 				    ETH_ALEN));
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	} else {
 		bat_priv->claim_dest.group = 0; /* will be set later */
 	}
@@ -1319,7 +1319,7 @@ void batadv_bla_free(struct bat_priv *bat_priv)
 	struct hard_iface *primary_if;
 
 	cancel_delayed_work_sync(&bat_priv->bla_work);
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (bat_priv->claim_hash) {
 		bla_purge_claims(bat_priv, primary_if, 1);
@@ -1332,7 +1332,7 @@ void batadv_bla_free(struct bat_priv *bat_priv)
 		bat_priv->backbone_hash = NULL;
 	}
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 /* @bat_priv: the bat priv with all the soft interface information
@@ -1356,7 +1356,7 @@ int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto handled;
 
@@ -1416,7 +1416,7 @@ handled:
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (claim)
 		claim_free_ref(claim);
 	return ret;
@@ -1441,7 +1441,7 @@ int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 	struct hard_iface *primary_if;
 	int ret = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -1502,7 +1502,7 @@ handled:
 	ret = 1;
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (claim)
 		claim_free_ref(claim);
 	return ret;
@@ -1521,7 +1521,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	bool is_own;
 	int ret = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if) {
 		ret = seq_printf(seq,
 				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
@@ -1559,6 +1559,6 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 0d90fff..c917a2e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -464,7 +464,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_node *node;
 	int gw_count = 0, ret = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if) {
 		ret = seq_printf(seq,
 				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
@@ -503,7 +503,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 2a4d394..06f8d63 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -102,7 +102,7 @@ static void primary_if_update_addr(struct bat_priv *bat_priv,
 	struct vis_packet *vis_packet;
 	struct hard_iface *primary_if;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -115,7 +115,7 @@ static void primary_if_update_addr(struct bat_priv *bat_priv,
 	batadv_bla_update_orig_address(bat_priv, primary_if, oldif);
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 static void primary_if_select(struct bat_priv *bat_priv,
@@ -139,7 +139,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 
 out:
 	if (curr_hard_iface)
-		hardif_free_ref(curr_hard_iface);
+		batadv_hardif_free_ref(curr_hard_iface);
 }
 
 static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
@@ -229,7 +229,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 	/* the first active interface becomes our primary interface or
 	 * the next active interface after the old primary interface was removed
 	 */
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		primary_if_select(bat_priv, hard_iface);
 
@@ -240,7 +240,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 static void hardif_deactivate_interface(struct hard_iface *hard_iface)
@@ -347,7 +347,7 @@ out:
 err_dev:
 	dev_put(soft_iface);
 err:
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 	return ret;
 }
 
@@ -369,7 +369,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 	bat_priv->num_ifaces--;
 	batadv_orig_hash_del_if(hard_iface, bat_priv->num_ifaces);
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (hard_iface == primary_if) {
 		struct hard_iface *new_if;
 
@@ -377,7 +377,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 		primary_if_select(bat_priv, new_if);
 
 		if (new_if)
-			hardif_free_ref(new_if);
+			batadv_hardif_free_ref(new_if);
 	}
 
 	bat_priv->bat_algo_ops->bat_iface_disable(hard_iface);
@@ -393,11 +393,11 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 		batadv_softif_destroy(hard_iface->soft_iface);
 
 	hard_iface->soft_iface = NULL;
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
@@ -461,7 +461,7 @@ static void hardif_remove_interface(struct hard_iface *hard_iface)
 
 	hard_iface->if_status = IF_TO_BE_REMOVED;
 	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 }
 
 void batadv_hardif_remove_interfaces(void)
@@ -517,7 +517,7 @@ static int hard_if_event(struct notifier_block *this,
 		bat_priv = netdev_priv(hard_iface->soft_iface);
 		bat_priv->bat_algo_ops->bat_iface_update_mac(hard_iface);
 
-		primary_if = primary_if_get_selected(bat_priv);
+		primary_if = batadv_primary_if_get_selected(bat_priv);
 		if (!primary_if)
 			goto hardif_put;
 
@@ -529,10 +529,10 @@ static int hard_if_event(struct notifier_block *this,
 	}
 
 hardif_put:
-	hardif_free_ref(hard_iface);
+	batadv_hardif_free_ref(hard_iface);
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return NOTIFY_DONE;
 }
 
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 6bc12c0..d66dabd 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -42,14 +42,15 @@ void batadv_update_min_mtu(struct net_device *soft_iface);
 void batadv_hardif_free_rcu(struct rcu_head *rcu);
 bool batadv_is_wifi_iface(int ifindex);
 
-static inline void hardif_free_ref(struct hard_iface *hard_iface)
+static inline void
+batadv_hardif_free_ref(struct hard_iface *hard_iface)
 {
 	if (atomic_dec_and_test(&hard_iface->refcount))
 		call_rcu(&hard_iface->rcu, batadv_hardif_free_rcu);
 }
 
-static inline struct hard_iface *primary_if_get_selected(
-						struct bat_priv *bat_priv)
+static inline struct hard_iface *
+batadv_primary_if_get_selected(struct bat_priv *bat_priv)
 {
 	struct hard_iface *hard_iface;
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 40c5e18..2523436 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -163,7 +163,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 		return -EINVAL;
 	}
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (!primary_if) {
 		len = -EFAULT;
@@ -244,7 +244,7 @@ free_skb:
 	kfree_skb(skb);
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (neigh_node)
 		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 86e7e08..90d24fc 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -412,7 +412,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 	uint32_t i;
 	int ret = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (!primary_if) {
 		ret = seq_printf(seq,
@@ -479,7 +479,7 @@ next:
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9c90cce..9c6edc2 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -292,7 +292,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -322,7 +322,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (router)
 		batadv_neigh_node_free_ref(router);
 	if (orig_node)
@@ -348,7 +348,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -377,7 +377,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (router)
 		batadv_neigh_node_free_ref(router);
 	if (orig_node)
@@ -955,12 +955,12 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 		if (!orig_node) {
 			if (!batadv_is_my_client(bat_priv, ethhdr->h_dest))
 				return 0;
-			primary_if = primary_if_get_selected(bat_priv);
+			primary_if = batadv_primary_if_get_selected(bat_priv);
 			if (!primary_if)
 				return 0;
 			memcpy(unicast_packet->dest,
 			       primary_if->net_dev->dev_addr, ETH_ALEN);
-			hardif_free_ref(primary_if);
+			batadv_hardif_free_ref(primary_if);
 		} else {
 			memcpy(unicast_packet->dest, orig_node->orig,
 			       ETH_ALEN);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 2c92a32..54091db 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -101,7 +101,7 @@ static void forw_packet_free(struct forw_packet *forw_packet)
 	if (forw_packet->skb)
 		kfree_skb(forw_packet->skb);
 	if (forw_packet->if_incoming)
-		hardif_free_ref(forw_packet->if_incoming);
+		batadv_hardif_free_ref(forw_packet->if_incoming);
 	kfree(forw_packet);
 }
 
@@ -146,7 +146,7 @@ int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out_and_inc;
 
@@ -180,7 +180,7 @@ out_and_inc:
 	atomic_inc(&bat_priv->bcast_queue_left);
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return NETDEV_TX_BUSY;
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 0658781..85fe9c1 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -199,7 +199,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 
 	/* ethernet packet should be broadcasted */
 	if (do_bcast) {
-		primary_if = primary_if_get_selected(bat_priv);
+		primary_if = batadv_primary_if_get_selected(bat_priv);
 		if (!primary_if)
 			goto dropped;
 
@@ -253,7 +253,7 @@ dropped_freed:
 	bat_priv->stats.tx_dropped++;
 end:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 5180d50..bc06af4 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -298,7 +298,7 @@ static void tt_prepare_packet_buff(struct bat_priv *bat_priv,
 	struct hard_iface *primary_if;
 	int req_len;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	req_len = min_packet_len;
 	req_len += batadv_tt_len(atomic_read(&bat_priv->tt_local_changes));
@@ -313,7 +313,7 @@ static void tt_prepare_packet_buff(struct bat_priv *bat_priv,
 			       min_packet_len, req_len);
 
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 static int tt_changes_fill_buff(struct bat_priv *bat_priv,
@@ -381,7 +381,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	uint32_t i;
 	int ret = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if) {
 		ret = seq_printf(seq,
 				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
@@ -423,7 +423,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
@@ -727,7 +727,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	uint32_t i;
 	int ret = 0;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if) {
 		ret = seq_printf(seq,
 				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
@@ -763,7 +763,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	}
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
@@ -1370,7 +1370,7 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	struct tt_req_node *tt_req_node = NULL;
 	int ret = 1;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -1420,7 +1420,7 @@ out:
 	if (neigh_node)
 		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (ret)
 		kfree_skb(skb);
 	if (ret && tt_req_node) {
@@ -1464,7 +1464,7 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 	if (!neigh_node)
 		goto out;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -1555,7 +1555,7 @@ out:
 	if (neigh_node)
 		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (!ret)
 		kfree_skb(skb);
 	return ret;
@@ -1592,7 +1592,7 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	if (!neigh_node)
 		goto out;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -1672,7 +1672,7 @@ out:
 	if (neigh_node)
 		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	if (!ret)
 		kfree_skb(skb);
 	/* This packet was for me, so it doesn't need to be re-routed */
@@ -1956,11 +1956,11 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 	roam_adv_packet->header.packet_type = BAT_ROAM_ADV;
 	roam_adv_packet->header.version = COMPAT_VERSION;
 	roam_adv_packet->header.ttl = TTL;
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 	memcpy(roam_adv_packet->src, primary_if->net_dev->dev_addr, ETH_ALEN);
-	hardif_free_ref(primary_if);
+	batadv_hardif_free_ref(primary_if);
 	memcpy(roam_adv_packet->dst, orig_node->orig, ETH_ALEN);
 	memcpy(roam_adv_packet->client, client, ETH_ALEN);
 
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index b2b76df..fff34e0 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -227,7 +227,7 @@ int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	int large_tail = 0, ret = NET_RX_DROP;
 	uint16_t seqno;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto dropped;
 
@@ -277,7 +277,7 @@ dropped:
 	kfree_skb(skb);
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 20eef04..619f0a5 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -208,7 +208,7 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 	size_t buff_pos, buf_size;
 	char *buff;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -329,7 +329,7 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
@@ -828,7 +828,7 @@ static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
 	struct hard_iface *primary_if;
 	struct vis_packet *packet;
 
-	primary_if = primary_if_get_selected(bat_priv);
+	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
@@ -849,7 +849,7 @@ static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
 
 out:
 	if (primary_if)
-		hardif_free_ref(primary_if);
+		batadv_hardif_free_ref(primary_if);
 }
 
 /* called from timer; send (and maybe generate) vis packet. */
-- 
1.7.9.4
