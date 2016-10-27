From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 16/17] batman-adv: Use octal permissions instead of macros
Date: Thu, 27 Oct 2016 21:01:49 +0200
Message-ID: <20161027190150.7880-17-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38358 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942669AbcJ0TCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:02:01 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Linus prefers to have octal permission numbers instead of combinations of
macro names ("random line noise"). Also old existing "bad symbolic
permission bit macro use" should be converted to octal numbers.
(http://lkml.kernel.org/r/CA+55aFw5v23T-zvDZp-MmD_EYxF8WbafwwB59934FV7g21uMGQ@mail.gmail.com)

Also remove the S_IFREG bit from the octal representation because it is
filtered out by debugfs_create.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/debugfs.c        | 26 ++++++++++----------
 net/batman-adv/icmp_socket.c    |  5 ++--
 net/batman-adv/log.c            |  4 +---
 net/batman-adv/network-coding.c |  8 +++----
 net/batman-adv/sysfs.c          | 53 ++++++++++++++++++-----------------------
 5 files changed, 41 insertions(+), 55 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index b4ffba7..7792550 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -186,7 +186,7 @@ struct batadv_debuginfo batadv_debuginfo_##_name = {	\
 /* the following attributes are general and therefore they will be directly
  * placed in the BATADV_DEBUGFS_SUBDIR subdirectory of debugfs
  */
-static BATADV_DEBUGINFO(routing_algos, S_IRUGO, batadv_algorithms_open);
+static BATADV_DEBUGINFO(routing_algos, 0444, batadv_algorithms_open);
 
 static struct batadv_debuginfo *batadv_general_debuginfos[] = {
 	&batadv_debuginfo_routing_algos,
@@ -194,26 +194,24 @@ static struct batadv_debuginfo *batadv_general_debuginfos[] = {
 };
 
 /* The following attributes are per soft interface */
-static BATADV_DEBUGINFO(neighbors, S_IRUGO, neighbors_open);
-static BATADV_DEBUGINFO(originators, S_IRUGO, batadv_originators_open);
-static BATADV_DEBUGINFO(gateways, S_IRUGO, batadv_gateways_open);
-static BATADV_DEBUGINFO(transtable_global, S_IRUGO,
-			batadv_transtable_global_open);
+static BATADV_DEBUGINFO(neighbors, 0444, neighbors_open);
+static BATADV_DEBUGINFO(originators, 0444, batadv_originators_open);
+static BATADV_DEBUGINFO(gateways, 0444, batadv_gateways_open);
+static BATADV_DEBUGINFO(transtable_global, 0444, batadv_transtable_global_open);
 #ifdef CONFIG_BATMAN_ADV_BLA
-static BATADV_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_table_open);
-static BATADV_DEBUGINFO(bla_backbone_table, S_IRUGO,
+static BATADV_DEBUGINFO(bla_claim_table, 0444, batadv_bla_claim_table_open);
+static BATADV_DEBUGINFO(bla_backbone_table, 0444,
 			batadv_bla_backbone_table_open);
 #endif
 #ifdef CONFIG_BATMAN_ADV_DAT
-static BATADV_DEBUGINFO(dat_cache, S_IRUGO, batadv_dat_cache_open);
+static BATADV_DEBUGINFO(dat_cache, 0444, batadv_dat_cache_open);
 #endif
-static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
-			batadv_transtable_local_open);
+static BATADV_DEBUGINFO(transtable_local, 0444, batadv_transtable_local_open);
 #ifdef CONFIG_BATMAN_ADV_NC
-static BATADV_DEBUGINFO(nc_nodes, S_IRUGO, batadv_nc_nodes_open);
+static BATADV_DEBUGINFO(nc_nodes, 0444, batadv_nc_nodes_open);
 #endif
 #ifdef CONFIG_BATMAN_ADV_MCAST
-static BATADV_DEBUGINFO(mcast_flags, S_IRUGO, batadv_mcast_flags_open);
+static BATADV_DEBUGINFO(mcast_flags, 0444, batadv_mcast_flags_open);
 #endif
 
 static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
@@ -253,7 +251,7 @@ struct batadv_debuginfo batadv_hardif_debuginfo_##_name = {	\
 	},							\
 }
 
-static BATADV_HARDIF_DEBUGINFO(originators, S_IRUGO,
+static BATADV_HARDIF_DEBUGINFO(originators, 0444,
 			       batadv_originators_hardif_open);
 
 static struct batadv_debuginfo *batadv_hardif_debuginfos[] = {
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 378cc11..b310f381a 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -38,7 +38,6 @@
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/stat.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/uaccess.h>
@@ -322,8 +321,8 @@ int batadv_socket_setup(struct batadv_priv *bat_priv)
 	if (!bat_priv->debug_dir)
 		goto err;
 
-	d = debugfs_create_file(BATADV_ICMP_SOCKET, S_IFREG | S_IWUSR | S_IRUSR,
-				bat_priv->debug_dir, bat_priv, &batadv_fops);
+	d = debugfs_create_file(BATADV_ICMP_SOCKET, 0600, bat_priv->debug_dir,
+				bat_priv, &batadv_fops);
 	if (!d)
 		goto err;
 
diff --git a/net/batman-adv/log.c b/net/batman-adv/log.c
index 56dc532..c73c317 100644
--- a/net/batman-adv/log.c
+++ b/net/batman-adv/log.c
@@ -31,7 +31,6 @@
 #include <linux/sched.h> /* for linux/wait.h */
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/stat.h>
 #include <linux/stddef.h>
 #include <linux/types.h>
 #include <linux/uaccess.h>
@@ -212,8 +211,7 @@ int batadv_debug_log_setup(struct batadv_priv *bat_priv)
 	spin_lock_init(&bat_priv->debug_log->lock);
 	init_waitqueue_head(&bat_priv->debug_log->queue_wait);
 
-	d = debugfs_create_file("log", S_IFREG | S_IRUSR,
-				bat_priv->debug_dir, bat_priv,
+	d = debugfs_create_file("log", 0400, bat_priv->debug_dir, bat_priv,
 				&batadv_log_fops);
 	if (!d)
 		goto err;
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index e3baf69..c213dde 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -44,7 +44,6 @@
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/stat.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/workqueue.h>
@@ -1961,17 +1960,16 @@ int batadv_nc_init_debugfs(struct batadv_priv *bat_priv)
 	if (!nc_dir)
 		goto out;
 
-	file = debugfs_create_u8("min_tq", S_IRUGO | S_IWUSR, nc_dir,
-				 &bat_priv->nc.min_tq);
+	file = debugfs_create_u8("min_tq", 0644, nc_dir, &bat_priv->nc.min_tq);
 	if (!file)
 		goto out;
 
-	file = debugfs_create_u32("max_fwd_delay", S_IRUGO | S_IWUSR, nc_dir,
+	file = debugfs_create_u32("max_fwd_delay", 0644, nc_dir,
 				  &bat_priv->nc.max_fwd_delay);
 	if (!file)
 		goto out;
 
-	file = debugfs_create_u32("max_buffer_time", S_IRUGO | S_IWUSR, nc_dir,
+	file = debugfs_create_u32("max_buffer_time", 0644, nc_dir,
 				  &bat_priv->nc.max_buffer_time);
 	if (!file)
 		goto out;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 02d96f2..17c8441 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -33,7 +33,6 @@
 #include <linux/rcupdate.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
-#include <linux/stat.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/stringify.h>
@@ -666,41 +665,36 @@ static ssize_t batadv_store_isolation_mark(struct kobject *kobj,
 	return count;
 }
 
-BATADV_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
-BATADV_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(aggregated_ogms, 0644, NULL);
+BATADV_ATTR_SIF_BOOL(bonding, 0644, NULL);
 #ifdef CONFIG_BATMAN_ADV_BLA
-BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR,
-		     batadv_bla_status_update);
+BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, 0644, batadv_bla_status_update);
 #endif
 #ifdef CONFIG_BATMAN_ADV_DAT
-BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR,
-		     batadv_dat_status_update);
+BATADV_ATTR_SIF_BOOL(distributed_arp_table, 0644, batadv_dat_status_update);
 #endif
-BATADV_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_mtu);
-static BATADV_ATTR(routing_algo, S_IRUGO, batadv_show_bat_algo, NULL);
-static BATADV_ATTR(gw_mode, S_IRUGO | S_IWUSR, batadv_show_gw_mode,
-		   batadv_store_gw_mode);
-BATADV_ATTR_SIF_UINT(orig_interval, orig_interval, S_IRUGO | S_IWUSR,
-		     2 * BATADV_JITTER, INT_MAX, NULL);
-BATADV_ATTR_SIF_UINT(hop_penalty, hop_penalty, S_IRUGO | S_IWUSR, 0,
-		     BATADV_TQ_MAX_VALUE, NULL);
-static BATADV_ATTR(gw_sel_class, S_IRUGO | S_IWUSR, batadv_show_gw_sel_class,
+BATADV_ATTR_SIF_BOOL(fragmentation, 0644, batadv_update_min_mtu);
+static BATADV_ATTR(routing_algo, 0444, batadv_show_bat_algo, NULL);
+static BATADV_ATTR(gw_mode, 0644, batadv_show_gw_mode, batadv_store_gw_mode);
+BATADV_ATTR_SIF_UINT(orig_interval, orig_interval, 0644, 2 * BATADV_JITTER,
+		     INT_MAX, NULL);
+BATADV_ATTR_SIF_UINT(hop_penalty, hop_penalty, 0644, 0, BATADV_TQ_MAX_VALUE,
+		     NULL);
+static BATADV_ATTR(gw_sel_class, 0644, batadv_show_gw_sel_class,
 		   batadv_store_gw_sel_class);
-static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwidth,
+static BATADV_ATTR(gw_bandwidth, 0644, batadv_show_gw_bwidth,
 		   batadv_store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_MCAST
-BATADV_ATTR_SIF_BOOL(multicast_mode, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(multicast_mode, 0644, NULL);
 #endif
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BATADV_ATTR_SIF_UINT(log_level, log_level, S_IRUGO | S_IWUSR, 0,
-		     BATADV_DBG_ALL, NULL);
+BATADV_ATTR_SIF_UINT(log_level, log_level, 0644, 0, BATADV_DBG_ALL, NULL);
 #endif
 #ifdef CONFIG_BATMAN_ADV_NC
-BATADV_ATTR_SIF_BOOL(network_coding, S_IRUGO | S_IWUSR,
-		     batadv_nc_status_update);
+BATADV_ATTR_SIF_BOOL(network_coding, 0644, batadv_nc_status_update);
 #endif
-static BATADV_ATTR(isolation_mark, S_IRUGO | S_IWUSR,
-		   batadv_show_isolation_mark, batadv_store_isolation_mark);
+static BATADV_ATTR(isolation_mark, 0644, batadv_show_isolation_mark,
+		   batadv_store_isolation_mark);
 
 static struct batadv_attribute *batadv_mesh_attrs[] = {
 	&batadv_attr_aggregated_ogms,
@@ -731,7 +725,7 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 	NULL,
 };
 
-BATADV_ATTR_VLAN_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_VLAN_BOOL(ap_isolation, 0644, NULL);
 
 /* array of vlan specific sysfs attributes */
 static struct batadv_attribute *batadv_vlan_attrs[] = {
@@ -1116,14 +1110,13 @@ static ssize_t batadv_show_throughput_override(struct kobject *kobj,
 
 #endif
 
-static BATADV_ATTR(mesh_iface, S_IRUGO | S_IWUSR, batadv_show_mesh_iface,
+static BATADV_ATTR(mesh_iface, 0644, batadv_show_mesh_iface,
 		   batadv_store_mesh_iface);
-static BATADV_ATTR(iface_status, S_IRUGO, batadv_show_iface_status, NULL);
+static BATADV_ATTR(iface_status, 0444, batadv_show_iface_status, NULL);
 #ifdef CONFIG_BATMAN_ADV_BATMAN_V
-BATADV_ATTR_HIF_UINT(elp_interval, bat_v.elp_interval, S_IRUGO | S_IWUSR,
+BATADV_ATTR_HIF_UINT(elp_interval, bat_v.elp_interval, 0644,
 		     2 * BATADV_JITTER, INT_MAX, NULL);
-static BATADV_ATTR(throughput_override, S_IRUGO | S_IWUSR,
-		   batadv_show_throughput_override,
+static BATADV_ATTR(throughput_override, 0644, batadv_show_throughput_override,
 		   batadv_store_throughput_override);
 #endif
 
-- 
2.10.1
