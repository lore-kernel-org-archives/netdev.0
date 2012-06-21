From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 19/20] batman-adv: Prefix main non-static
	functions with batadv_
Date: Thu, 21 Jun 2012 18:57:55 +0200
Message-ID: <1340297876-29923-20-git-send-email-ordex@autistici.org>
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
 net/batman-adv/bat_debugfs.c           |    6 ++--
 net/batman-adv/bat_iv_ogm.c            |   16 ++++-----
 net/batman-adv/bridge_loop_avoidance.c |    2 +-
 net/batman-adv/hard-interface.c        |   14 ++++----
 net/batman-adv/icmp_socket.c           |    4 +--
 net/batman-adv/main.c                  |   57 ++++++++++++++++----------------
 net/batman-adv/main.h                  |   37 +++++++++++----------
 net/batman-adv/originator.c            |    4 +--
 net/batman-adv/routing.c               |   26 +++++++--------
 net/batman-adv/send.c                  |    6 ++--
 net/batman-adv/soft-interface.c        |    6 ++--
 net/batman-adv/translation-table.c     |    4 +--
 net/batman-adv/vis.c                   |   10 +++---
 13 files changed, 97 insertions(+), 95 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index ad377ab..3900624 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -94,13 +94,13 @@ static int log_open(struct inode *inode, struct file *file)
 {
 	nonseekable_open(inode, file);
 	file->private_data = inode->i_private;
-	inc_module_count();
+	batadv_inc_module_count();
 	return 0;
 }
 
 static int log_release(struct inode *inode, struct file *file)
 {
-	dec_module_count();
+	batadv_dec_module_count();
 	return 0;
 }
 
@@ -224,7 +224,7 @@ static void debug_log_cleanup(struct bat_priv *bat_priv)
 
 static int bat_algorithms_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, bat_algo_seq_print_text, NULL);
+	return single_open(file, batadv_algo_seq_print_text, NULL);
 }
 
 static int originators_open(struct inode *inode, struct file *file)
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 62b52b6..0430063 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -204,7 +204,7 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 		batadv_inc_counter(bat_priv, BAT_CNT_MGMT_TX);
 		batadv_add_counter(bat_priv, BAT_CNT_MGMT_TX_BYTES,
 				   skb->len + ETH_HLEN);
-		batadv_send_skb_packet(skb, hard_iface, broadcast_addr);
+		batadv_send_skb_packet(skb, hard_iface, batadv_broadcast_addr);
 	}
 }
 
@@ -255,7 +255,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 		/* skb is only used once and than forw_packet is free'd */
 		batadv_send_skb_packet(forw_packet->skb,
 				       forw_packet->if_incoming,
-				       broadcast_addr);
+				       batadv_broadcast_addr);
 		forw_packet->skb = NULL;
 
 		goto out;
@@ -263,7 +263,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 
 	/* broadcast on every interface */
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
@@ -425,7 +425,7 @@ static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	/* start timer for this packet */
 	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
 			  batadv_send_outstanding_bat_ogm_packet);
-	queue_delayed_work(bat_event_workqueue,
+	queue_delayed_work(batadv_event_workqueue,
 			   &forw_packet_aggr->delayed_work,
 			   send_time - jiffies);
 
@@ -984,7 +984,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		batman_ogm_packet->header.version, has_directlink_flag);
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->if_status != IF_ACTIVE)
 			continue;
 
@@ -1259,18 +1259,18 @@ int __init batadv_iv_init(void)
 	int ret;
 
 	/* batman originator packet */
-	ret = recv_handler_register(BAT_IV_OGM, bat_iv_ogm_receive);
+	ret = batadv_recv_handler_register(BAT_IV_OGM, bat_iv_ogm_receive);
 	if (ret < 0)
 		goto out;
 
-	ret = bat_algo_register(&batman_iv);
+	ret = batadv_algo_register(&batman_iv);
 	if (ret < 0)
 		goto handler_unregister;
 
 	goto out;
 
 handler_unregister:
-	recv_handler_unregister(BAT_IV_OGM);
+	batadv_recv_handler_unregister(BAT_IV_OGM);
 out:
 	return ret;
 }
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index bd356a1..27f451a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1070,7 +1070,7 @@ void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 static void bla_start_timer(struct bat_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->bla_work, bla_periodic_work);
-	queue_delayed_work(bat_event_workqueue, &bat_priv->bla_work,
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla_work,
 			   msecs_to_jiffies(BLA_PERIOD_LENGTH));
 }
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 93acf2b..ab2fcfa 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -46,7 +46,7 @@ struct hard_iface *batadv_hardif_get_by_netdev(const struct net_device *net_dev)
 	struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->net_dev == net_dev &&
 		    atomic_inc_not_zero(&hard_iface->refcount))
 			goto out;
@@ -86,7 +86,7 @@ static struct hard_iface *hardif_get_active(const struct net_device *soft_iface)
 	struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
@@ -161,7 +161,7 @@ static void check_known_mac_addr(const struct net_device *net_dev)
 	const struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if ((hard_iface->if_status != IF_ACTIVE) &&
 		    (hard_iface->if_status != IF_TO_BE_ACTIVATED))
 			continue;
@@ -192,7 +192,7 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 		goto out;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if ((hard_iface->if_status != IF_ACTIVE) &&
 		    (hard_iface->if_status != IF_TO_BE_ACTIVATED))
 			continue;
@@ -315,7 +315,7 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 	batadv_orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
 
 	hard_iface->batman_adv_ptype.type = __constant_htons(ETH_P_BATMAN);
-	hard_iface->batman_adv_ptype.func = batman_skb_recv;
+	hard_iface->batman_adv_ptype.func = batadv_batman_skb_recv;
 	hard_iface->batman_adv_ptype.dev = hard_iface->net_dev;
 	dev_add_pack(&hard_iface->batman_adv_ptype);
 
@@ -436,7 +436,7 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 	atomic_set(&hard_iface->refcount, 2);
 
 	check_known_mac_addr(hard_iface->net_dev);
-	list_add_tail_rcu(&hard_iface->list, &hardif_list);
+	list_add_tail_rcu(&hard_iface->list, &batadv_hardif_list);
 
 	/**
 	 * This can't be called via a bat_priv callback because
@@ -477,7 +477,7 @@ void batadv_hardif_remove_interfaces(void)
 
 	rtnl_lock();
 	list_for_each_entry_safe(hard_iface, hard_iface_tmp,
-				 &hardif_list, list) {
+				 &batadv_hardif_list, list) {
 		list_del_rcu(&hard_iface->list);
 		hardif_remove_interface(hard_iface);
 	}
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 21c0010..2300561 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -73,7 +73,7 @@ static int bat_socket_open(struct inode *inode, struct file *file)
 
 	file->private_data = socket_client;
 
-	inc_module_count();
+	batadv_inc_module_count();
 	return 0;
 }
 
@@ -98,7 +98,7 @@ static int bat_socket_release(struct inode *inode, struct file *file)
 	spin_unlock_bh(&socket_client->lock);
 
 	kfree(socket_client);
-	dec_module_count();
+	batadv_dec_module_count();
 
 	return 0;
 }
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index ffea360..5e1d906 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -38,20 +38,20 @@
 
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
  * list traversals just rcu-locked */
-struct list_head hardif_list;
+struct list_head batadv_hardif_list;
 static int (*recv_packet_handler[256])(struct sk_buff *, struct hard_iface *);
-char bat_routing_algo[20] = "BATMAN_IV";
+char batadv_routing_algo[20] = "BATMAN_IV";
 static struct hlist_head bat_algo_list;
 
-unsigned char broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+unsigned char batadv_broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
-struct workqueue_struct *bat_event_workqueue;
+struct workqueue_struct *batadv_event_workqueue;
 
 static void recv_handler_init(void);
 
 static int __init batman_init(void)
 {
-	INIT_LIST_HEAD(&hardif_list);
+	INIT_LIST_HEAD(&batadv_hardif_list);
 	INIT_HLIST_HEAD(&bat_algo_list);
 
 	recv_handler_init();
@@ -60,9 +60,9 @@ static int __init batman_init(void)
 
 	/* the name should not be longer than 10 chars - see
 	 * http://lwn.net/Articles/23634/ */
-	bat_event_workqueue = create_singlethread_workqueue("bat_events");
+	batadv_event_workqueue = create_singlethread_workqueue("bat_events");
 
-	if (!bat_event_workqueue)
+	if (!batadv_event_workqueue)
 		return -ENOMEM;
 
 	batadv_socket_init();
@@ -82,14 +82,14 @@ static void __exit batman_exit(void)
 	unregister_netdevice_notifier(&batadv_hard_if_notifier);
 	batadv_hardif_remove_interfaces();
 
-	flush_workqueue(bat_event_workqueue);
-	destroy_workqueue(bat_event_workqueue);
-	bat_event_workqueue = NULL;
+	flush_workqueue(batadv_event_workqueue);
+	destroy_workqueue(batadv_event_workqueue);
+	batadv_event_workqueue = NULL;
 
 	rcu_barrier();
 }
 
-int mesh_init(struct net_device *soft_iface)
+int batadv_mesh_init(struct net_device *soft_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	int ret;
@@ -135,11 +135,11 @@ int mesh_init(struct net_device *soft_iface)
 	return 0;
 
 err:
-	mesh_free(soft_iface);
+	batadv_mesh_free(soft_iface);
 	return ret;
 }
 
-void mesh_free(struct net_device *soft_iface)
+void batadv_mesh_free(struct net_device *soft_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 
@@ -161,22 +161,22 @@ void mesh_free(struct net_device *soft_iface)
 	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
 }
 
-void inc_module_count(void)
+void batadv_inc_module_count(void)
 {
 	try_module_get(THIS_MODULE);
 }
 
-void dec_module_count(void)
+void batadv_dec_module_count(void)
 {
 	module_put(THIS_MODULE);
 }
 
-int is_my_mac(const uint8_t *addr)
+int batadv_is_my_mac(const uint8_t *addr)
 {
 	const struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->if_status != IF_ACTIVE)
 			continue;
 
@@ -198,8 +198,9 @@ static int recv_unhandled_packet(struct sk_buff *skb,
 /* incoming packets with the batman ethertype received on any active hard
  * interface
  */
-int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *ptype, struct net_device *orig_dev)
+int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
+			   struct packet_type *ptype,
+			   struct net_device *orig_dev)
 {
 	struct bat_priv *bat_priv;
 	struct batman_ogm_packet *batman_ogm_packet;
@@ -287,9 +288,9 @@ static void recv_handler_init(void)
 	recv_packet_handler[BAT_ROAM_ADV] = batadv_recv_roam_adv;
 }
 
-int recv_handler_register(uint8_t packet_type,
-			  int (*recv_handler)(struct sk_buff *,
-					      struct hard_iface *))
+int batadv_recv_handler_register(uint8_t packet_type,
+				 int (*recv_handler)(struct sk_buff *,
+						     struct hard_iface *))
 {
 	if (recv_packet_handler[packet_type] != &recv_unhandled_packet)
 		return -EBUSY;
@@ -298,7 +299,7 @@ int recv_handler_register(uint8_t packet_type,
 	return 0;
 }
 
-void recv_handler_unregister(uint8_t packet_type)
+void batadv_recv_handler_unregister(uint8_t packet_type)
 {
 	recv_packet_handler[packet_type] = recv_unhandled_packet;
 }
@@ -319,7 +320,7 @@ static struct bat_algo_ops *bat_algo_get(char *name)
 	return bat_algo_ops;
 }
 
-int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
+int batadv_algo_register(struct bat_algo_ops *bat_algo_ops)
 {
 	struct bat_algo_ops *bat_algo_ops_tmp;
 	int ret;
@@ -353,7 +354,7 @@ out:
 	return ret;
 }
 
-int bat_algo_select(struct bat_priv *bat_priv, char *name)
+int batadv_algo_select(struct bat_priv *bat_priv, char *name)
 {
 	struct bat_algo_ops *bat_algo_ops;
 	int ret = -EINVAL;
@@ -369,7 +370,7 @@ out:
 	return ret;
 }
 
-int bat_algo_seq_print_text(struct seq_file *seq, void *offset)
+int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct bat_algo_ops *bat_algo_ops;
 	struct hlist_node *node;
@@ -407,8 +408,8 @@ static const struct kernel_param_ops param_ops_ra = {
 };
 
 static struct kparam_string __param_string_ra = {
-	.maxlen = sizeof(bat_routing_algo),
-	.string = bat_routing_algo,
+	.maxlen = sizeof(batadv_routing_algo),
+	.string = batadv_routing_algo,
 };
 
 module_param_cb(routing_algo, &param_ops_ra, &__param_string_ra, 0644);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ea9d433..1238642 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -145,26 +145,27 @@ enum dbg_level {
 #include <linux/seq_file.h>
 #include "types.h"
 
-extern char bat_routing_algo[];
-extern struct list_head hardif_list;
+extern char batadv_routing_algo[];
+extern struct list_head batadv_hardif_list;
 
-extern unsigned char broadcast_addr[];
-extern struct workqueue_struct *bat_event_workqueue;
+extern unsigned char batadv_broadcast_addr[];
+extern struct workqueue_struct *batadv_event_workqueue;
 
-int mesh_init(struct net_device *soft_iface);
-void mesh_free(struct net_device *soft_iface);
-void inc_module_count(void);
-void dec_module_count(void);
-int is_my_mac(const uint8_t *addr);
-int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *ptype, struct net_device *orig_dev);
-int recv_handler_register(uint8_t packet_type,
-			  int (*recv_handler)(struct sk_buff *,
-					      struct hard_iface *));
-void recv_handler_unregister(uint8_t packet_type);
-int bat_algo_register(struct bat_algo_ops *bat_algo_ops);
-int bat_algo_select(struct bat_priv *bat_priv, char *name);
-int bat_algo_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_mesh_init(struct net_device *soft_iface);
+void batadv_mesh_free(struct net_device *soft_iface);
+void batadv_inc_module_count(void);
+void batadv_dec_module_count(void);
+int batadv_is_my_mac(const uint8_t *addr);
+int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
+			   struct packet_type *ptype,
+			   struct net_device *orig_dev);
+int batadv_recv_handler_register(uint8_t packet_type,
+				 int (*recv_handler)(struct sk_buff *,
+						     struct hard_iface *));
+void batadv_recv_handler_unregister(uint8_t packet_type);
+int batadv_algo_register(struct bat_algo_ops *bat_algo_ops);
+int batadv_algo_select(struct bat_priv *bat_priv, char *name);
+int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 int batadv_debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 9d77ede..3e90204 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -35,7 +35,7 @@ static void purge_orig(struct work_struct *work);
 static void start_purge_timer(struct bat_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->orig_work, purge_orig);
-	queue_delayed_work(bat_event_workqueue,
+	queue_delayed_work(batadv_event_workqueue,
 			   &bat_priv->orig_work, msecs_to_jiffies(1000));
 }
 
@@ -623,7 +623,7 @@ int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
 
 	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface_tmp, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface_tmp, &batadv_hardif_list, list) {
 		if (hard_iface_tmp->if_status == IF_NOT_IN_USE)
 			continue;
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d492634..1b1dd41 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -419,7 +419,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* not for me */
-	if (!is_my_mac(ethhdr->h_dest))
+	if (!batadv_is_my_mac(ethhdr->h_dest))
 		goto out;
 
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
@@ -433,7 +433,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	}
 
 	/* packet for me */
-	if (is_my_mac(icmp_packet->dst))
+	if (batadv_is_my_mac(icmp_packet->dst))
 		return recv_my_icmp_packet(bat_priv, skb, hdr_size);
 
 	/* TTL exceeded */
@@ -614,7 +614,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 	case TT_RESPONSE:
 		batadv_inc_counter(bat_priv, BAT_CNT_TT_RESPONSE_RX);
 
-		if (is_my_mac(tt_query->dst)) {
+		if (batadv_is_my_mac(tt_query->dst)) {
 			/* packet needs to be linearized to access the TT
 			 * changes */
 			if (skb_linearize(skb) < 0)
@@ -670,7 +670,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	roam_adv_packet = (struct roam_adv_packet *)skb->data;
 
-	if (!is_my_mac(roam_adv_packet->dst))
+	if (!batadv_is_my_mac(roam_adv_packet->dst))
 		return route_unicast_packet(skb, recv_if);
 
 	/* check if it is a backbone gateway. we don't accept
@@ -804,7 +804,7 @@ static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
 		return -1;
 
 	/* not for me */
-	if (!is_my_mac(ethhdr->h_dest))
+	if (!batadv_is_my_mac(ethhdr->h_dest))
 		return -1;
 
 	return 0;
@@ -909,7 +909,7 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
-	if (is_my_mac(unicast_packet->dest)) {
+	if (batadv_is_my_mac(unicast_packet->dest)) {
 		tt_poss_change = bat_priv->tt_poss_change;
 		curr_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
 	} else {
@@ -985,7 +985,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	unicast_packet = (struct unicast_packet *)skb->data;
 
 	/* packet for me */
-	if (is_my_mac(unicast_packet->dest)) {
+	if (batadv_is_my_mac(unicast_packet->dest)) {
 		batadv_interface_rx(recv_if->soft_iface, skb, recv_if,
 				    hdr_size);
 		return NET_RX_SUCCESS;
@@ -1012,7 +1012,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 	unicast_packet = (struct unicast_frag_packet *)skb->data;
 
 	/* packet for me */
-	if (is_my_mac(unicast_packet->dest)) {
+	if (batadv_is_my_mac(unicast_packet->dest)) {
 
 		ret = batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
 
@@ -1057,13 +1057,13 @@ int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* ignore broadcasts sent by myself */
-	if (is_my_mac(ethhdr->h_source))
+	if (batadv_is_my_mac(ethhdr->h_source))
 		goto out;
 
 	bcast_packet = (struct bcast_packet *)skb->data;
 
 	/* ignore broadcasts originated by myself */
-	if (is_my_mac(bcast_packet->orig))
+	if (batadv_is_my_mac(bcast_packet->orig))
 		goto out;
 
 	if (bcast_packet->header.ttl < 2)
@@ -1139,14 +1139,14 @@ int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* not for me */
-	if (!is_my_mac(ethhdr->h_dest))
+	if (!batadv_is_my_mac(ethhdr->h_dest))
 		return NET_RX_DROP;
 
 	/* ignore own packets */
-	if (is_my_mac(vis_packet->vis_orig))
+	if (batadv_is_my_mac(vis_packet->vis_orig))
 		return NET_RX_DROP;
 
-	if (is_my_mac(vis_packet->sender_orig))
+	if (batadv_is_my_mac(vis_packet->sender_orig))
 		return NET_RX_DROP;
 
 	switch (vis_packet->vis_type) {
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 8226b1c..1a0f7c3 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -121,7 +121,7 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
 	/* start timer for this packet */
 	INIT_DELAYED_WORK(&forw_packet->delayed_work,
 			  send_outstanding_bcast_packet);
-	queue_delayed_work(bat_event_workqueue, &forw_packet->delayed_work,
+	queue_delayed_work(batadv_event_workqueue, &forw_packet->delayed_work,
 			   send_time);
 }
 
@@ -205,7 +205,7 @@ static void send_outstanding_bcast_packet(struct work_struct *work)
 
 	/* rebroadcast packet */
 	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
@@ -213,7 +213,7 @@ static void send_outstanding_bcast_packet(struct work_struct *work)
 		skb1 = skb_clone(forw_packet->skb, GFP_ATOMIC);
 		if (skb1)
 			batadv_send_skb_packet(skb1, hard_iface,
-					       broadcast_addr);
+					       batadv_broadcast_addr);
 	}
 	rcu_read_unlock();
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 9fd19257..994b2b8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -411,7 +411,7 @@ struct net_device *batadv_softif_create(const char *name)
 	if (!bat_priv->bat_counters)
 		goto unreg_soft_iface;
 
-	ret = bat_algo_select(bat_priv, bat_routing_algo);
+	ret = batadv_algo_select(bat_priv, batadv_routing_algo);
 	if (ret < 0)
 		goto free_bat_counters;
 
@@ -423,7 +423,7 @@ struct net_device *batadv_softif_create(const char *name)
 	if (ret < 0)
 		goto unreg_sysfs;
 
-	ret = mesh_init(soft_iface);
+	ret = batadv_mesh_init(soft_iface);
 	if (ret < 0)
 		goto unreg_debugfs;
 
@@ -449,7 +449,7 @@ void batadv_softif_destroy(struct net_device *soft_iface)
 {
 	batadv_debugfs_del_meshif(soft_iface);
 	batadv_sysfs_del_meshif(soft_iface);
-	mesh_free(soft_iface);
+	batadv_mesh_free(soft_iface);
 	unregister_netdevice(soft_iface);
 }
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index ecef827..66e11b5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -48,7 +48,7 @@ static int compare_tt(const struct hlist_node *node, const void *data2)
 static void tt_start_timer(struct bat_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->tt_work, tt_purge);
-	queue_delayed_work(bat_event_workqueue, &bat_priv->tt_work,
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt_work,
 			   msecs_to_jiffies(5000));
 }
 
@@ -1673,7 +1673,7 @@ out:
 bool batadv_send_tt_response(struct bat_priv *bat_priv,
 			     struct tt_query_packet *tt_request)
 {
-	if (is_my_mac(tt_request->dst)) {
+	if (batadv_is_my_mac(tt_request->dst)) {
 		/* don't answer backbone gws! */
 		if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_request->src))
 			return true;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 24040c3..83c931f 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -462,7 +462,7 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 
 	/* Make it a broadcast packet, if required */
 	if (make_broadcast)
-		memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
+		memcpy(packet->target_orig, batadv_broadcast_addr, ETH_ALEN);
 
 	/* repair if entries is longer than packet. */
 	if (packet->entries * sizeof(struct vis_info_entry) > vis_info_len)
@@ -524,7 +524,7 @@ void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
 
 	/* Are we the target for this VIS packet? */
 	if (vis_server == VIS_TYPE_SERVER_SYNC	&&
-	    is_my_mac(vis_packet->target_orig))
+	    batadv_is_my_mac(vis_packet->target_orig))
 		are_target = 1;
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
@@ -543,7 +543,7 @@ void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
 		send_list_add(bat_priv, info);
 
 		/* ... we're not the recipient (and thus need to forward). */
-	} else if (!is_my_mac(packet->target_orig)) {
+	} else if (!batadv_is_my_mac(packet->target_orig)) {
 		send_list_add(bat_priv, info);
 	}
 
@@ -623,7 +623,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	info->first_seen = jiffies;
 	packet->vis_type = atomic_read(&bat_priv->vis_mode);
 
-	memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
+	memcpy(packet->target_orig, batadv_broadcast_addr, ETH_ALEN);
 	packet->header.ttl = TTL;
 	packet->seqno = htonl(ntohl(packet->seqno) + 1);
 	packet->entries = 0;
@@ -978,6 +978,6 @@ void batadv_vis_quit(struct bat_priv *bat_priv)
 static void start_vis_timer(struct bat_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->vis_work, send_vis_packets);
-	queue_delayed_work(bat_event_workqueue, &bat_priv->vis_work,
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis_work,
 			   msecs_to_jiffies(VIS_INTERVAL));
 }
-- 
1.7.9.4
