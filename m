From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 17/17] batman-adv: Add debugfs table for
	mcast flags
Date: Fri,  1 Jul 2016 15:09:09 +0200
Message-ID: <1467378549-9646-18-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467378549-9646-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>

This patch adds a debugfs table with originators and their according
multicast flags to help users figure out why multicast optimizations
might be enabled or disabled for them.

Tested-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Linus L=C3=BCssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/debugfs.c   |  23 ++++++++++
 net/batman-adv/multicast.c | 104 +++++++++++++++++++++++++++++++++++++++=
++++++
 net/batman-adv/multicast.h |   3 ++
 3 files changed, 130 insertions(+)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 9529004..f187a8f 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -48,6 +48,7 @@
 #include "distributed-arp-table.h"
 #include "gateway_client.h"
 #include "icmp_socket.h"
+#include "multicast.h"
 #include "network-coding.h"
 #include "originator.h"
 #include "translation-table.h"
@@ -363,6 +364,22 @@ static int batadv_nc_nodes_open(struct inode *inode,=
 struct file *file)
 }
 #endif
=20
+#ifdef CONFIG_BATMAN_ADV_MCAST
+/**
+ * batadv_mcast_flags_open - prepare file handler for reads from mcast_f=
lags
+ * @inode: inode which was opened
+ * @file: file handle to be initialized
+ *
+ * Return: 0 on success or negative error number in case of failure
+ */
+static int batadv_mcast_flags_open(struct inode *inode, struct file *fil=
e)
+{
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+
+	return single_open(file, batadv_mcast_flags_seq_print_text, net_dev);
+}
+#endif
+
 #define BATADV_DEBUGINFO(_name, _mode, _open)		\
 struct batadv_debuginfo batadv_debuginfo_##_name =3D {	\
 	.attr =3D {					\
@@ -407,6 +424,9 @@ static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
 #ifdef CONFIG_BATMAN_ADV_NC
 static BATADV_DEBUGINFO(nc_nodes, S_IRUGO, batadv_nc_nodes_open);
 #endif
+#ifdef CONFIG_BATMAN_ADV_MCAST
+static BATADV_DEBUGINFO(mcast_flags, S_IRUGO, batadv_mcast_flags_open);
+#endif
=20
 static struct batadv_debuginfo *batadv_mesh_debuginfos[] =3D {
 	&batadv_debuginfo_neighbors,
@@ -424,6 +444,9 @@ static struct batadv_debuginfo *batadv_mesh_debuginfo=
s[] =3D {
 #ifdef CONFIG_BATMAN_ADV_NC
 	&batadv_debuginfo_nc_nodes,
 #endif
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	&batadv_debuginfo_mcast_flags,
+#endif
 	NULL,
 };
=20
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 2d1a896..d3222db 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -41,6 +41,7 @@
 #include <linux/printk.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
+#include <linux/seq_file.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -52,6 +53,8 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
=20
+#include "hard-interface.h"
+#include "hash.h"
 #include "packet.h"
 #include "translation-table.h"
=20
@@ -1130,6 +1133,107 @@ void batadv_mcast_init(struct batadv_priv *bat_pr=
iv)
 }
=20
 /**
+ * batadv_mcast_flags_print_header - print own mcast flags to debugfs ta=
ble
+ * @bat_priv: the bat priv with all the soft interface information
+ * @seq: debugfs table seq_file struct
+ *
+ * Prints our own multicast flags including a more specific reason why
+ * they are set, that is prints the bridge and querier state too, to
+ * the debugfs table specified via @seq.
+ */
+static void batadv_mcast_flags_print_header(struct batadv_priv *bat_priv=
,
+					    struct seq_file *seq)
+{
+	u8 flags =3D bat_priv->mcast.flags;
+	char querier4, querier6, shadowing4, shadowing6;
+	bool bridged =3D bat_priv->mcast.bridged;
+
+	if (bridged) {
+		querier4 =3D bat_priv->mcast.querier_ipv4.exists ? '.' : '4';
+		querier6 =3D bat_priv->mcast.querier_ipv6.exists ? '.' : '6';
+		shadowing4 =3D bat_priv->mcast.querier_ipv4.shadowing ? '4' : '.';
+		shadowing6 =3D bat_priv->mcast.querier_ipv6.shadowing ? '6' : '.';
+	} else {
+		querier4 =3D '?';
+		querier6 =3D '?';
+		shadowing4 =3D '?';
+		shadowing6 =3D '?';
+	}
+
+	seq_printf(seq, "Multicast flags (own flags: [%c%c%c])\n",
+		   (flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES) ? 'U' : '.',
+		   (flags & BATADV_MCAST_WANT_ALL_IPV4) ? '4' : '.',
+		   (flags & BATADV_MCAST_WANT_ALL_IPV6) ? '6' : '.');
+	seq_printf(seq, "* Bridged [U]\t\t\t\t%c\n", bridged ? 'U' : '.');
+	seq_printf(seq, "* No IGMP/MLD Querier [4/6]:\t\t%c/%c\n",
+		   querier4, querier6);
+	seq_printf(seq, "* Shadowing IGMP/MLD Querier [4/6]:\t%c/%c\n",
+		   shadowing4, shadowing6);
+	seq_puts(seq, "-------------------------------------------\n");
+	seq_printf(seq, "       %-10s %s\n", "Originator", "Flags");
+}
+
+/**
+ * batadv_mcast_flags_seq_print_text - print the mcast flags of other no=
des
+ * @seq: seq file to print on
+ * @offset: not used
+ *
+ * This prints a table of (primary) originators and their according
+ * multicast flags, including (in the header) our own.
+ *
+ * Return: always 0
+ */
+int batadv_mcast_flags_seq_print_text(struct seq_file *seq, void *offset=
)
+{
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_hard_iface *primary_if;
+	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
+	struct batadv_orig_node *orig_node;
+	struct hlist_head *head;
+	u8 flags;
+	u32 i;
+
+	primary_if =3D batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
+		return 0;
+
+	batadv_mcast_flags_print_header(bat_priv, seq);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+			if (!test_bit(BATADV_ORIG_CAPA_HAS_MCAST,
+				      &orig_node->capa_initialized))
+				continue;
+
+			if (!test_bit(BATADV_ORIG_CAPA_HAS_MCAST,
+				      &orig_node->capabilities)) {
+				seq_printf(seq, "%pM -\n", orig_node->orig);
+				continue;
+			}
+
+			flags =3D orig_node->mcast_flags;
+
+			seq_printf(seq, "%pM [%c%c%c]\n", orig_node->orig,
+				   (flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES)
+				   ? 'U' : '.',
+				   (flags & BATADV_MCAST_WANT_ALL_IPV4)
+				   ? '4' : '.',
+				   (flags & BATADV_MCAST_WANT_ALL_IPV6)
+				   ? '6' : '.');
+		}
+		rcu_read_unlock();
+	}
+
+	batadv_hardif_put(primary_if);
+
+	return 0;
+}
+
+/**
  * batadv_mcast_free - free the multicast optimizations structures
  * @bat_priv: the bat priv with all the soft interface information
  */
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 80bceec..1fb00ba 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -20,6 +20,7 @@
=20
 #include "main.h"
=20
+struct seq_file;
 struct sk_buff;
=20
 /**
@@ -46,6 +47,8 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_priv, st=
ruct sk_buff *skb,
=20
 void batadv_mcast_init(struct batadv_priv *bat_priv);
=20
+int batadv_mcast_flags_seq_print_text(struct seq_file *seq, void *offset=
);
+
 void batadv_mcast_free(struct batadv_priv *bat_priv);
=20
 void batadv_mcast_purge_orig(struct batadv_orig_node *orig_node);
--=20
2.8.1
