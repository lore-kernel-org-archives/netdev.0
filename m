From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 18/20] batman-adv: Prefix vis non-static
	functions with batadv_
Date: Thu, 21 Jun 2012 18:57:54 +0200
Message-ID: <1340297876-29923-19-git-send-email-ordex@autistici.org>
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
 net/batman-adv/bat_debugfs.c |    2 +-
 net/batman-adv/main.c        |    4 ++--
 net/batman-adv/routing.c     |    8 ++++----
 net/batman-adv/vis.c         |   20 ++++++++++----------
 net/batman-adv/vis.h         |   18 +++++++++---------
 5 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 93cc0d1..ad377ab 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -263,7 +263,7 @@ static int transtable_local_open(struct inode *inode, struct file *file)
 static int vis_data_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, vis_seq_print_text, net_dev);
+	return single_open(file, batadv_vis_seq_print_text, net_dev);
 }
 
 struct bat_debuginfo {
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8d2011b..ffea360 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -121,7 +121,7 @@ int mesh_init(struct net_device *soft_iface)
 
 	batadv_tt_local_add(soft_iface, soft_iface->dev_addr, NULL_IFINDEX);
 
-	ret = vis_init(bat_priv);
+	ret = batadv_vis_init(bat_priv);
 	if (ret < 0)
 		goto err;
 
@@ -147,7 +147,7 @@ void mesh_free(struct net_device *soft_iface)
 
 	batadv_purge_outstanding_packets(bat_priv, NULL);
 
-	vis_quit(bat_priv);
+	batadv_vis_quit(bat_priv);
 
 	batadv_gw_node_purge(bat_priv);
 	batadv_originator_free(bat_priv);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4103f68..d492634 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1151,13 +1151,13 @@ int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	switch (vis_packet->vis_type) {
 	case VIS_TYPE_SERVER_SYNC:
-		receive_server_sync_packet(bat_priv, vis_packet,
-					   skb_headlen(skb));
+		batadv_receive_server_sync_packet(bat_priv, vis_packet,
+						  skb_headlen(skb));
 		break;
 
 	case VIS_TYPE_CLIENT_UPDATE:
-		receive_client_update_packet(bat_priv, vis_packet,
-					     skb_headlen(skb));
+		batadv_receive_client_update_packet(bat_priv, vis_packet,
+						    skb_headlen(skb));
 		break;
 
 	default:	/* ignore unknown packet */
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c56737c..24040c3 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -188,7 +188,7 @@ static ssize_t vis_data_read_entry(char *buff,
 	return 0;
 }
 
-int vis_seq_print_text(struct seq_file *seq, void *offset)
+int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct hard_iface *primary_if;
 	struct hlist_node *node;
@@ -483,9 +483,9 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 }
 
 /* handle the server sync packet, forward if needed. */
-void receive_server_sync_packet(struct bat_priv *bat_priv,
-				struct vis_packet *vis_packet,
-				int vis_info_len)
+void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
+				       struct vis_packet *vis_packet,
+				       int vis_info_len)
 {
 	struct vis_info *info;
 	int is_new, make_broadcast;
@@ -508,9 +508,9 @@ end:
 }
 
 /* handle an incoming client update packet and schedule forward if needed. */
-void receive_client_update_packet(struct bat_priv *bat_priv,
-				  struct vis_packet *vis_packet,
-				  int vis_info_len)
+void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
+					 struct vis_packet *vis_packet,
+					 int vis_info_len)
 {
 	struct vis_info *info;
 	struct vis_packet *packet;
@@ -880,7 +880,7 @@ static void send_vis_packets(struct work_struct *work)
 
 /* init the vis server. this may only be called when if_list is already
  * initialized (e.g. bat0 is initialized, interfaces have been added) */
-int vis_init(struct bat_priv *bat_priv)
+int batadv_vis_init(struct bat_priv *bat_priv)
 {
 	struct vis_packet *packet;
 	int hash_added;
@@ -944,7 +944,7 @@ free_info:
 	bat_priv->my_vis_info = NULL;
 err:
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
-	vis_quit(bat_priv);
+	batadv_vis_quit(bat_priv);
 	return -ENOMEM;
 }
 
@@ -959,7 +959,7 @@ static void free_info_ref(struct hlist_node *node, void *arg)
 }
 
 /* shutdown vis-server */
-void vis_quit(struct bat_priv *bat_priv)
+void batadv_vis_quit(struct bat_priv *bat_priv)
 {
 	if (!bat_priv->vis_hash)
 		return;
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index ee2e46e..932514e 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -25,14 +25,14 @@
 #define VIS_TIMEOUT		200000	/* timeout of vis packets
 					 * in miliseconds */
 
-int vis_seq_print_text(struct seq_file *seq, void *offset);
-void receive_server_sync_packet(struct bat_priv *bat_priv,
-				struct vis_packet *vis_packet,
-				int vis_info_len);
-void receive_client_update_packet(struct bat_priv *bat_priv,
-				  struct vis_packet *vis_packet,
-				  int vis_info_len);
-int vis_init(struct bat_priv *bat_priv);
-void vis_quit(struct bat_priv *bat_priv);
+int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
+void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
+				       struct vis_packet *vis_packet,
+				       int vis_info_len);
+void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
+					 struct vis_packet *vis_packet,
+					 int vis_info_len);
+int batadv_vis_init(struct bat_priv *bat_priv);
+void batadv_vis_quit(struct bat_priv *bat_priv);
 
 #endif /* _NET_BATMAN_ADV_VIS_H_ */
-- 
1.7.9.4
