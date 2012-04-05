From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 10/16] batman-adv: export claim tables
	through debugfs
Date: Thu,  5 Apr 2012 12:38:56 +0200
Message-ID: <1333622342-6128-11-git-send-email-ordex@autistici.org>
References: <1333622342-6128-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1333622342-6128-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 Documentation/networking/batman-adv.txt |    5 ++-
 net/batman-adv/bat_debugfs.c            |   10 ++++++
 net/batman-adv/bridge_loop_avoidance.c  |   53 +++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h  |    1 +
 4 files changed, 66 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 9523e9e..220a58c 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -77,9 +77,8 @@ folder:
 There is a special folder for debugging information:
 
 #  ls /sys/kernel/debug/batman_adv/bat0/
-#  gateways     socket        transtable_global  vis_data
-#  originators  softif_neigh  transtable_local
-
+# bla_claim_table    log                socket             transtable_local
+# gateways           originators        transtable_global  vis_data
 
 Some of the files contain all sort of status information  regard-
 ing  the  mesh  network.  For  example, you can view the table of
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 165ff62..0e35177 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -32,6 +32,7 @@
 #include "soft-interface.h"
 #include "vis.h"
 #include "icmp_socket.h"
+#include "bridge_loop_avoidance.h"
 
 static struct dentry *bat_debugfs;
 
@@ -244,6 +245,13 @@ static int transtable_global_open(struct inode *inode, struct file *file)
 	return single_open(file, tt_global_seq_print_text, net_dev);
 }
 
+static int bla_claim_table_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, bla_claim_table_seq_print_text, net_dev);
+}
+
+
 static int transtable_local_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
@@ -277,6 +285,7 @@ static BAT_DEBUGINFO(routing_algos, S_IRUGO, bat_algorithms_open);
 static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
 static BAT_DEBUGINFO(gateways, S_IRUGO, gateways_open);
 static BAT_DEBUGINFO(transtable_global, S_IRUGO, transtable_global_open);
+static BAT_DEBUGINFO(bla_claim_table, S_IRUGO, bla_claim_table_open);
 static BAT_DEBUGINFO(transtable_local, S_IRUGO, transtable_local_open);
 static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
 
@@ -284,6 +293,7 @@ static struct bat_debuginfo *mesh_debuginfos[] = {
 	&bat_debuginfo_originators,
 	&bat_debuginfo_gateways,
 	&bat_debuginfo_transtable_global,
+	&bat_debuginfo_bla_claim_table,
 	&bat_debuginfo_transtable_local,
 	&bat_debuginfo_vis_data,
 	NULL,
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index e86cc90..e8b4435 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1299,3 +1299,56 @@ out:
 		claim_free_ref(claim);
 	return ret;
 }
+
+int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	struct hashtable_t *hash = bat_priv->claim_hash;
+	struct claim *claim;
+	struct hard_iface *primary_if;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	uint32_t i;
+	bool is_own;
+	int ret = 0;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if) {
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status != IF_ACTIVE) {
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	seq_printf(seq, "Claims announced for the mesh %s (orig %pM)\n",
+		   net_dev->name, primary_if->net_dev->dev_addr);
+	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-4s)\n",
+		   "Client", "VID", "Originator", "CRC");
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
+			is_own = compare_eth(claim->backbone_gw->orig,
+					     primary_if->net_dev->dev_addr);
+			seq_printf(seq,	" * %pM on % 5d by %pM [%c] (%04x)\n",
+				   claim->addr, claim->vid,
+				   claim->backbone_gw->orig,
+				   (is_own ? 'x' : ' '),
+				   claim->backbone_gw->crc);
+		}
+		rcu_read_unlock();
+	}
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
+}
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 488d778..d9e3480 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -26,6 +26,7 @@ int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
 int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
 int bla_is_backbone_gw(struct sk_buff *skb,
 		       struct orig_node *orig_node, int hdr_size);
+int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
 void bla_update_orig_address(struct bat_priv *bat_priv,
 			     struct hard_iface *primary_if,
 			     struct hard_iface *oldif);
-- 
1.7.9.4
