From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 06/17] batman-adv: refactor
	batadv_neigh_node_* functions to follow common style
Date: Fri,  1 Jul 2016 15:08:58 +0200
Message-ID: <1467378549-9646-7-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

From: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>

Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c |  3 ++-
 net/batman-adv/bat_v_elp.c  |  3 ++-
 net/batman-adv/bat_v_ogm.c  |  4 ++--
 net/batman-adv/originator.c | 35 +++++++++++++++++++++++++++++------
 net/batman-adv/originator.h |  6 +++---
 5 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ce2f203..aa11296 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -336,7 +336,8 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 {
 	struct batadv_neigh_node *neigh_node;
 
-	neigh_node = batadv_neigh_node_new(orig_node, hard_iface, neigh_addr);
+	neigh_node = batadv_neigh_node_get_or_create(orig_node,
+						     hard_iface, neigh_addr);
 	if (!neigh_node)
 		goto out;
 
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index df42eb1..8909d1e 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -443,7 +443,8 @@ static void batadv_v_elp_neigh_update(struct batadv_priv *bat_priv,
 	if (!orig_neigh)
 		return;
 
-	neigh = batadv_neigh_node_new(orig_neigh, if_incoming, neigh_addr);
+	neigh = batadv_neigh_node_get_or_create(orig_neigh,
+						if_incoming, neigh_addr);
 	if (!neigh)
 		goto orig_free;
 
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 473ebb9..23ea9bf 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -683,8 +683,8 @@ static void batadv_v_ogm_process(const struct sk_buff *skb, int ogm_offset,
 	if (!orig_node)
 		return;
 
-	neigh_node = batadv_neigh_node_new(orig_node, if_incoming,
-					   ethhdr->h_source);
+	neigh_node = batadv_neigh_node_get_or_create(orig_node, if_incoming,
+						     ethhdr->h_source);
 	if (!neigh_node)
 		goto out;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 7f51bc2..b0bad57 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -602,19 +602,19 @@ batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
 }
 
 /**
- * batadv_neigh_node_new - create and init a new neigh_node object
+ * batadv_neigh_node_create - create a neigh node object
  * @orig_node: originator object representing the neighbour
  * @hard_iface: the interface where the neighbour is connected to
  * @neigh_addr: the mac address of the neighbour interface
  *
  * Allocates a new neigh_node object and initialises all the generic fields.
  *
- * Return: neighbor when found. Othwerwise NULL
+ * Return: the neighbour node if found or created or NULL otherwise.
  */
-struct batadv_neigh_node *
-batadv_neigh_node_new(struct batadv_orig_node *orig_node,
-		      struct batadv_hard_iface *hard_iface,
-		      const u8 *neigh_addr)
+static struct batadv_neigh_node *
+batadv_neigh_node_create(struct batadv_orig_node *orig_node,
+			 struct batadv_hard_iface *hard_iface,
+			 const u8 *neigh_addr)
 {
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
@@ -667,6 +667,29 @@ out:
 }
 
 /**
+ * batadv_neigh_node_get_or_create - retrieve or create a neigh node object
+ * @orig_node: originator object representing the neighbour
+ * @hard_iface: the interface where the neighbour is connected to
+ * @neigh_addr: the mac address of the neighbour interface
+ *
+ * Return: the neighbour node if found or created or NULL otherwise.
+ */
+struct batadv_neigh_node *
+batadv_neigh_node_get_or_create(struct batadv_orig_node *orig_node,
+				struct batadv_hard_iface *hard_iface,
+				const u8 *neigh_addr)
+{
+	struct batadv_neigh_node *neigh_node = NULL;
+
+	/* first check without locking to avoid the overhead */
+	neigh_node = batadv_neigh_node_get(orig_node, hard_iface, neigh_addr);
+	if (neigh_node)
+		return neigh_node;
+
+	return batadv_neigh_node_create(orig_node, hard_iface, neigh_addr);
+}
+
+/**
  * batadv_hardif_neigh_seq_print_text - print the single hop neighbour list
  * @seq: neighbour table seq_file struct
  * @offset: not used
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 64a8951..566306b 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -46,9 +46,9 @@ batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
 void
 batadv_hardif_neigh_put(struct batadv_hardif_neigh_node *hardif_neigh);
 struct batadv_neigh_node *
-batadv_neigh_node_new(struct batadv_orig_node *orig_node,
-		      struct batadv_hard_iface *hard_iface,
-		      const u8 *neigh_addr);
+batadv_neigh_node_get_or_create(struct batadv_orig_node *orig_node,
+				struct batadv_hard_iface *hard_iface,
+				const u8 *neigh_addr);
 void batadv_neigh_node_put(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
 batadv_orig_router_get(struct batadv_orig_node *orig_node,
-- 
2.8.1
