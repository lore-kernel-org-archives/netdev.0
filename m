From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/24] batman-adv: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:24 -0700
Message-ID: <c469b9fb57fb75547e3e9092ebfdb3a79480b28f.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38319 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754972Ab1H2VTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 17:19:13 -0400
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/batman-adv/hard-interface.c |    5 +----
 net/batman-adv/main.c           |    2 --
 net/batman-adv/originator.c     |   16 ++++------------
 net/batman-adv/soft-interface.c |    4 +---
 net/batman-adv/vis.c            |    4 +---
 5 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index bf91e4d..6a5312e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -455,11 +455,8 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
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
index d448018..6e558cd 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -493,10 +493,8 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 
 	data_ptr = kmalloc(max_if_num * sizeof(unsigned long) * NUM_WORDS,
 			   GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	memcpy(data_ptr, orig_node->bcast_own,
 	       (max_if_num - 1) * sizeof(unsigned long) * NUM_WORDS);
@@ -504,10 +502,8 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 	orig_node->bcast_own = data_ptr;
 
 	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	memcpy(data_ptr, orig_node->bcast_own_sum,
 	       (max_if_num - 1) * sizeof(uint8_t));
@@ -562,10 +558,8 @@ static int orig_node_del_if(struct orig_node *orig_node,
 
 	chunk_size = sizeof(unsigned long) * NUM_WORDS;
 	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
-	if (!data_ptr) {
-		pr_err("Can't resize orig: out of memory\n");
+	if (!data_ptr)
 		return -1;
-	}
 
 	/* copy first part */
 	memcpy(data_ptr, orig_node->bcast_own, del_if_num * chunk_size);
@@ -583,10 +577,8 @@ free_bcast_own:
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
index 402fd96..9b5e69e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -800,10 +800,8 @@ struct net_device *softif_create(const char *name)
 
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
1.7.6.405.gc1be0
