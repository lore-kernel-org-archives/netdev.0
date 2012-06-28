From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/18] batman-adv: Prefix main local static functions with batadv_
Date: Thu, 28 Jun 2012 11:34:12 +0200
Message-ID: <1340876067-28333-4-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30195 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932524Ab2F1Je2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:28 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c |   76 +++++++++++++++++++++++++------------------------
 1 file changed, 39 insertions(+), 37 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index e456430..9cf0b38 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -38,22 +38,23 @@
  * list traversals just rcu-locked
  */
 struct list_head batadv_hardif_list;
-static int (*recv_packet_handler[256])(struct sk_buff *, struct hard_iface *);
+static int (*batadv_rx_handler[256])(struct sk_buff *,
+				     struct hard_iface *);
 char batadv_routing_algo[20] = "BATMAN_IV";
-static struct hlist_head bat_algo_list;
+static struct hlist_head batadv_algo_list;
 
 unsigned char batadv_broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 struct workqueue_struct *batadv_event_workqueue;
 
-static void recv_handler_init(void);
+static void batadv_recv_handler_init(void);
 
-static int __init batman_init(void)
+static int __init batadv_init(void)
 {
 	INIT_LIST_HEAD(&batadv_hardif_list);
-	INIT_HLIST_HEAD(&bat_algo_list);
+	INIT_HLIST_HEAD(&batadv_algo_list);
 
-	recv_handler_init();
+	batadv_recv_handler_init();
 
 	batadv_iv_init();
 
@@ -76,7 +77,7 @@ static int __init batman_init(void)
 	return 0;
 }
 
-static void __exit batman_exit(void)
+static void __exit batadv_exit(void)
 {
 	batadv_debugfs_destroy();
 	unregister_netdevice_notifier(&batadv_hard_if_notifier);
@@ -189,8 +190,8 @@ int batadv_is_my_mac(const uint8_t *addr)
 	return 0;
 }
 
-static int recv_unhandled_packet(struct sk_buff *skb,
-				 struct hard_iface *recv_if)
+static int batadv_recv_unhandled_packet(struct sk_buff *skb,
+					struct hard_iface *recv_if)
 {
 	return NET_RX_DROP;
 }
@@ -248,7 +249,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	 * the supplied skb. if not, we have to free the skb.
 	 */
 	idx = batman_ogm_packet->header.packet_type;
-	ret = (*recv_packet_handler[idx])(skb, hard_iface);
+	ret = (*batadv_rx_handler[idx])(skb, hard_iface);
 
 	if (ret == NET_RX_DROP)
 		kfree_skb(skb);
@@ -265,51 +266,51 @@ err_out:
 	return NET_RX_DROP;
 }
 
-static void recv_handler_init(void)
+static void batadv_recv_handler_init(void)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(recv_packet_handler); i++)
-		recv_packet_handler[i] = recv_unhandled_packet;
+	for (i = 0; i < ARRAY_SIZE(batadv_rx_handler); i++)
+		batadv_rx_handler[i] = batadv_recv_unhandled_packet;
 
 	/* batman icmp packet */
-	recv_packet_handler[BAT_ICMP] = batadv_recv_icmp_packet;
+	batadv_rx_handler[BAT_ICMP] = batadv_recv_icmp_packet;
 	/* unicast packet */
-	recv_packet_handler[BAT_UNICAST] = batadv_recv_unicast_packet;
+	batadv_rx_handler[BAT_UNICAST] = batadv_recv_unicast_packet;
 	/* fragmented unicast packet */
-	recv_packet_handler[BAT_UNICAST_FRAG] = batadv_recv_ucast_frag_packet;
+	batadv_rx_handler[BAT_UNICAST_FRAG] = batadv_recv_ucast_frag_packet;
 	/* broadcast packet */
-	recv_packet_handler[BAT_BCAST] = batadv_recv_bcast_packet;
+	batadv_rx_handler[BAT_BCAST] = batadv_recv_bcast_packet;
 	/* vis packet */
-	recv_packet_handler[BAT_VIS] = batadv_recv_vis_packet;
+	batadv_rx_handler[BAT_VIS] = batadv_recv_vis_packet;
 	/* Translation table query (request or response) */
-	recv_packet_handler[BAT_TT_QUERY] = batadv_recv_tt_query;
+	batadv_rx_handler[BAT_TT_QUERY] = batadv_recv_tt_query;
 	/* Roaming advertisement */
-	recv_packet_handler[BAT_ROAM_ADV] = batadv_recv_roam_adv;
+	batadv_rx_handler[BAT_ROAM_ADV] = batadv_recv_roam_adv;
 }
 
 int batadv_recv_handler_register(uint8_t packet_type,
 				 int (*recv_handler)(struct sk_buff *,
 						     struct hard_iface *))
 {
-	if (recv_packet_handler[packet_type] != &recv_unhandled_packet)
+	if (batadv_rx_handler[packet_type] != &batadv_recv_unhandled_packet)
 		return -EBUSY;
 
-	recv_packet_handler[packet_type] = recv_handler;
+	batadv_rx_handler[packet_type] = recv_handler;
 	return 0;
 }
 
 void batadv_recv_handler_unregister(uint8_t packet_type)
 {
-	recv_packet_handler[packet_type] = recv_unhandled_packet;
+	batadv_rx_handler[packet_type] = batadv_recv_unhandled_packet;
 }
 
-static struct bat_algo_ops *bat_algo_get(char *name)
+static struct bat_algo_ops *batadv_algo_get(char *name)
 {
 	struct bat_algo_ops *bat_algo_ops = NULL, *bat_algo_ops_tmp;
 	struct hlist_node *node;
 
-	hlist_for_each_entry(bat_algo_ops_tmp, node, &bat_algo_list, list) {
+	hlist_for_each_entry(bat_algo_ops_tmp, node, &batadv_algo_list, list) {
 		if (strcmp(bat_algo_ops_tmp->name, name) != 0)
 			continue;
 
@@ -325,7 +326,7 @@ int batadv_algo_register(struct bat_algo_ops *bat_algo_ops)
 	struct bat_algo_ops *bat_algo_ops_tmp;
 	int ret;
 
-	bat_algo_ops_tmp = bat_algo_get(bat_algo_ops->name);
+	bat_algo_ops_tmp = batadv_algo_get(bat_algo_ops->name);
 	if (bat_algo_ops_tmp) {
 		pr_info("Trying to register already registered routing algorithm: %s\n",
 			bat_algo_ops->name);
@@ -347,7 +348,7 @@ int batadv_algo_register(struct bat_algo_ops *bat_algo_ops)
 	}
 
 	INIT_HLIST_NODE(&bat_algo_ops->list);
-	hlist_add_head(&bat_algo_ops->list, &bat_algo_list);
+	hlist_add_head(&bat_algo_ops->list, &batadv_algo_list);
 	ret = 0;
 
 out:
@@ -359,7 +360,7 @@ int batadv_algo_select(struct bat_priv *bat_priv, char *name)
 	struct bat_algo_ops *bat_algo_ops;
 	int ret = -EINVAL;
 
-	bat_algo_ops = bat_algo_get(name);
+	bat_algo_ops = batadv_algo_get(name);
 	if (!bat_algo_ops)
 		goto out;
 
@@ -377,14 +378,14 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq, "Available routing algorithms:\n");
 
-	hlist_for_each_entry(bat_algo_ops, node, &bat_algo_list, list) {
+	hlist_for_each_entry(bat_algo_ops, node, &batadv_algo_list, list) {
 		seq_printf(seq, "%s\n", bat_algo_ops->name);
 	}
 
 	return 0;
 }
 
-static int param_set_ra(const char *val, const struct kernel_param *kp)
+static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 {
 	struct bat_algo_ops *bat_algo_ops;
 	char *algo_name = (char *)val;
@@ -393,7 +394,7 @@ static int param_set_ra(const char *val, const struct kernel_param *kp)
 	if (algo_name[name_len - 1] == '\n')
 		algo_name[name_len - 1] = '\0';
 
-	bat_algo_ops = bat_algo_get(algo_name);
+	bat_algo_ops = batadv_algo_get(algo_name);
 	if (!bat_algo_ops) {
 		pr_err("Routing algorithm '%s' is not supported\n", algo_name);
 		return -EINVAL;
@@ -402,19 +403,20 @@ static int param_set_ra(const char *val, const struct kernel_param *kp)
 	return param_set_copystring(algo_name, kp);
 }
 
-static const struct kernel_param_ops param_ops_ra = {
-	.set = param_set_ra,
+static const struct kernel_param_ops batadv_param_ops_ra = {
+	.set = batadv_param_set_ra,
 	.get = param_get_string,
 };
 
-static struct kparam_string __param_string_ra = {
+static struct kparam_string batadv_param_string_ra = {
 	.maxlen = sizeof(batadv_routing_algo),
 	.string = batadv_routing_algo,
 };
 
-module_param_cb(routing_algo, &param_ops_ra, &__param_string_ra, 0644);
-module_init(batman_init);
-module_exit(batman_exit);
+module_param_cb(routing_algo, &batadv_param_ops_ra, &batadv_param_string_ra,
+		0644);
+module_init(batadv_init);
+module_exit(batadv_exit);
 
 MODULE_LICENSE("GPL");
 
-- 
1.7.9.4
