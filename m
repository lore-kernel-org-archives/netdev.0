From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 7/7] batman-adv: Remove unnecessary OOM
	logging messages
Date: Thu,  8 Sep 2011 18:40:51 +0200
Message-ID: <1315500051-1122-8-git-send-email-lindner_marek@yahoo.de>
References: <1315500051-1122-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1315500051-1122-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/hard-interface.c |    5 +----
 net/batman-adv/main.c           |    2 --
 net/batman-adv/originator.c     |   16 ++++------------
 net/batman-adv/soft-interface.c |    4 +---
 net/batman-adv/vis.c            |    4 +---
 5 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 0cc0f04..7704df4 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -434,11 +434,8 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 	dev_hold(net_dev);
 
 	hard_iface = kmalloc(sizeof(*hard_iface), GFP_ATOMIC);
-	if (!hard_iface) {
-		pr_err("Can't add interface (%s): out of memory\n",
-		       net_dev->name);
+	if (!hard_iface)
 		goto release_dev;
-	}
 
 	ret = sysfs_add_hardif(&hard_iface->hardif_obj, net_dev);
 	if (ret)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 79b9ae5..fb87bdc 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -117,8 +117,6 @@ int mesh_init(struct net_device *soft_iface)
 	goto end;
 
 err:
-	pr_err("Unable to allocate memory for mesh information structures: "
-	       "out of mem ?\n");
 	mesh_free(soft_iface);
 	return -1;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index cd7d256..0e5b772 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -492,10 +492,8 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 
 	data_ptr = kmalloc(max_if_num * sizeof(unsigned long) * NUM_WORDS,
 			   GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	memcpy(data_ptr, orig_node->bcast_own,
 	       (max_if_num - 1) * sizeof(unsigned long) * NUM_WORDS);
@@ -503,10 +501,8 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 	orig_node->bcast_own = data_ptr;
 
 	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	memcpy(data_ptr, orig_node->bcast_own_sum,
 	       (max_if_num - 1) * sizeof(uint8_t));
@@ -561,10 +557,8 @@ static int orig_node_del_if(struct orig_node *orig_node,
 
 	chunk_size = sizeof(unsigned long) * NUM_WORDS;
 	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	/* copy first part */
 	memcpy(data_ptr, orig_node->bcast_own, del_if_num * chunk_size);
@@ -582,10 +576,8 @@ free_bcast_own:
 		goto free_own_sum;
 
 	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	memcpy(data_ptr, orig_node->bcast_own_sum,
 	       del_if_num * sizeof(uint8_t));
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7d8332e..aceeabc 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -801,10 +801,8 @@ struct net_device *softif_create(const char *name)
 
 	soft_iface = alloc_netdev(sizeof(*bat_priv), name, interface_setup);
 
-	if (!soft_iface) {
-		pr_err("Unable to allocate the batman interface: %s\n", name);
+	if (!soft_iface)
 		goto out;
-	}
 
 	ret = register_netdevice(soft_iface);
 	if (ret < 0) {
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index fb9b19f..f81a6b6 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -887,10 +887,8 @@ int vis_init(struct bat_priv *bat_priv)
 	}
 
 	bat_priv->my_vis_info = kmalloc(MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
-	if (!bat_priv->my_vis_info) {
-		pr_err("Can't initialize vis packet\n");
+	if (!bat_priv->my_vis_info)
 		goto err;
-	}
 
 	bat_priv->my_vis_info->skb_packet = dev_alloc_skb(sizeof(*packet) +
 							  MAX_VIS_PACKET_SIZE +
-- 
1.7.5.4
