From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 04/18] batman-adv: Prefix remaining function
	like macros with batadv_
Date: Thu, 28 Jun 2012 11:34:13 +0200
Message-ID: <1340876067-28333-5-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340876067-28333-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c       |    4 +-
 net/batman-adv/bat_iv_ogm.c        |    2 +-
 net/batman-adv/bat_sysfs.c         |   81 ++++++++++++++++++++----------------
 net/batman-adv/gateway_client.c    |    2 +-
 net/batman-adv/gateway_common.c    |   26 ++++++------
 net/batman-adv/hard-interface.c    |   38 ++++++++---------
 net/batman-adv/main.h              |   20 ++++-----
 net/batman-adv/routing.c           |    4 +-
 net/batman-adv/send.c              |    2 +-
 net/batman-adv/translation-table.c |    4 +-
 net/batman-adv/vis.c               |    4 +-
 11 files changed, 98 insertions(+), 89 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 03f09f0..ca6aee4 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -360,8 +360,8 @@ int batadv_debugfs_add_meshif(struct net_device *dev)
 					  bat_priv->debug_dir,
 					  dev, &(*bat_debug)->fops);
 		if (!file) {
-			bat_err(dev, "Can't add debugfs file: %s/%s\n",
-				dev->name, ((*bat_debug)->attr).name);
+			batadv_err(dev, "Can't add debugfs file: %s/%s\n",
+				   dev->name, ((*bat_debug)->attr).name);
 			goto rem_attr;
 		}
 	}
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ca64665..ffe9d1d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -373,7 +373,7 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	/* own packet should always be scheduled */
 	if (!own_packet) {
-		if (!atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
+		if (!batadv_atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
 			batadv_dbg(DBG_BATMAN, bat_priv,
 				   "batman packet queue full\n");
 			goto out;
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 03b76a4..54429a2 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -191,18 +191,17 @@ static int batadv_store_bool_attr(char *buff, size_t count,
 		enabled = 0;
 
 	if (enabled < 0) {
-		bat_info(net_dev,
-			 "%s: Invalid parameter received: %s\n",
-			 attr_name, buff);
+		batadv_info(net_dev, "%s: Invalid parameter received: %s\n",
+			    attr_name, buff);
 		return -EINVAL;
 	}
 
 	if (atomic_read(attr) == enabled)
 		return count;
 
-	bat_info(net_dev, "%s: Changing from: %s to: %s\n", attr_name,
-		 atomic_read(attr) == 1 ? "enabled" : "disabled",
-		 enabled == 1 ? "enabled" : "disabled");
+	batadv_info(net_dev, "%s: Changing from: %s to: %s\n", attr_name,
+		    atomic_read(attr) == 1 ? "enabled" : "disabled",
+		    enabled == 1 ? "enabled" : "disabled");
 
 	atomic_set(attr, (unsigned int)enabled);
 	return count;
@@ -235,29 +234,28 @@ static int batadv_store_uint_attr(const char *buff, size_t count,
 
 	ret = kstrtoul(buff, 10, &uint_val);
 	if (ret) {
-		bat_info(net_dev,
-			 "%s: Invalid parameter received: %s\n",
-			 attr_name, buff);
+		batadv_info(net_dev, "%s: Invalid parameter received: %s\n",
+			    attr_name, buff);
 		return -EINVAL;
 	}
 
 	if (uint_val < min) {
-		bat_info(net_dev, "%s: Value is too small: %lu min: %u\n",
-			 attr_name, uint_val, min);
+		batadv_info(net_dev, "%s: Value is too small: %lu min: %u\n",
+			    attr_name, uint_val, min);
 		return -EINVAL;
 	}
 
 	if (uint_val > max) {
-		bat_info(net_dev, "%s: Value is too big: %lu max: %u\n",
-			 attr_name, uint_val, max);
+		batadv_info(net_dev, "%s: Value is too big: %lu max: %u\n",
+			    attr_name, uint_val, max);
 		return -EINVAL;
 	}
 
 	if (atomic_read(attr) == uint_val)
 		return count;
 
-	bat_info(net_dev, "%s: Changing from: %i to: %lu\n",
-		 attr_name, atomic_read(attr), uint_val);
+	batadv_info(net_dev, "%s: Changing from: %i to: %lu\n",
+		    attr_name, atomic_read(attr), uint_val);
 
 	atomic_set(attr, uint_val);
 	return count;
@@ -299,6 +297,7 @@ static ssize_t batadv_store_vis_mode(struct kobject *kobj,
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	unsigned long val;
 	int ret, vis_mode_tmp = -1;
+	const char *old_mode, *new_mode;
 
 	ret = kstrtoul(buff, 10, &val);
 
@@ -315,19 +314,27 @@ static ssize_t batadv_store_vis_mode(struct kobject *kobj,
 		if (buff[count - 1] == '\n')
 			buff[count - 1] = '\0';
 
-		bat_info(net_dev,
-			 "Invalid parameter for 'vis mode' setting received: %s\n",
-			 buff);
+		batadv_info(net_dev,
+			    "Invalid parameter for 'vis mode' setting received: %s\n",
+			    buff);
 		return -EINVAL;
 	}
 
 	if (atomic_read(&bat_priv->vis_mode) == vis_mode_tmp)
 		return count;
 
-	bat_info(net_dev, "Changing vis mode from: %s to: %s\n",
-		 atomic_read(&bat_priv->vis_mode) == VIS_TYPE_CLIENT_UPDATE ?
-		 "client" : "server", vis_mode_tmp == VIS_TYPE_CLIENT_UPDATE ?
-		 "client" : "server");
+	if (atomic_read(&bat_priv->vis_mode) == VIS_TYPE_CLIENT_UPDATE)
+		old_mode =  "client";
+	else
+		old_mode = "server";
+
+	if (vis_mode_tmp == VIS_TYPE_CLIENT_UPDATE)
+		new_mode =  "client";
+	else
+		new_mode = "server";
+
+	batadv_info(net_dev, "Changing vis mode from: %s to: %s\n", old_mode,
+		    new_mode);
 
 	atomic_set(&bat_priv->vis_mode, (unsigned int)vis_mode_tmp);
 	return count;
@@ -391,9 +398,9 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 		gw_mode_tmp = GW_MODE_SERVER;
 
 	if (gw_mode_tmp < 0) {
-		bat_info(net_dev,
-			 "Invalid parameter for 'gw mode' setting received: %s\n",
-			 buff);
+		batadv_info(net_dev,
+			    "Invalid parameter for 'gw mode' setting received: %s\n",
+			    buff);
 		return -EINVAL;
 	}
 
@@ -412,8 +419,8 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 		break;
 	}
 
-	bat_info(net_dev, "Changing gw mode from: %s to: %s\n",
-		 curr_gw_mode_str, buff);
+	batadv_info(net_dev, "Changing gw mode from: %s to: %s\n",
+		    curr_gw_mode_str, buff);
 
 	batadv_gw_deselect(bat_priv);
 	atomic_set(&bat_priv->gw_mode, (unsigned int)gw_mode_tmp);
@@ -500,8 +507,8 @@ int batadv_sysfs_add_meshif(struct net_device *dev)
 	bat_priv->mesh_obj = kobject_create_and_add(SYSFS_IF_MESH_SUBDIR,
 						    batif_kobject);
 	if (!bat_priv->mesh_obj) {
-		bat_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
-			SYSFS_IF_MESH_SUBDIR);
+		batadv_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
+			   SYSFS_IF_MESH_SUBDIR);
 		goto out;
 	}
 
@@ -509,9 +516,9 @@ int batadv_sysfs_add_meshif(struct net_device *dev)
 		err = sysfs_create_file(bat_priv->mesh_obj,
 					&((*bat_attr)->attr));
 		if (err) {
-			bat_err(dev, "Can't add sysfs file: %s/%s/%s\n",
-				dev->name, SYSFS_IF_MESH_SUBDIR,
-				((*bat_attr)->attr).name);
+			batadv_err(dev, "Can't add sysfs file: %s/%s/%s\n",
+				   dev->name, SYSFS_IF_MESH_SUBDIR,
+				   ((*bat_attr)->attr).name);
 			goto rem_attr;
 		}
 	}
@@ -669,17 +676,17 @@ int batadv_sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
 						    hardif_kobject);
 
 	if (!*hardif_obj) {
-		bat_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
-			SYSFS_IF_BAT_SUBDIR);
+		batadv_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
+			   SYSFS_IF_BAT_SUBDIR);
 		goto out;
 	}
 
 	for (bat_attr = batadv_batman_attrs; *bat_attr; ++bat_attr) {
 		err = sysfs_create_file(*hardif_obj, &((*bat_attr)->attr));
 		if (err) {
-			bat_err(dev, "Can't add sysfs file: %s/%s/%s\n",
-				dev->name, SYSFS_IF_BAT_SUBDIR,
-				((*bat_attr)->attr).name);
+			batadv_err(dev, "Can't add sysfs file: %s/%s/%s\n",
+				   dev->name, SYSFS_IF_BAT_SUBDIR,
+				   ((*bat_attr)->attr).name);
 			goto rem_attr;
 		}
 	}
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index efe7519..f43eb57 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -197,7 +197,7 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 	if (atomic_read(&bat_priv->gw_mode) != GW_MODE_CLIENT)
 		goto out;
 
-	if (!atomic_dec_not_zero(&bat_priv->gw_reselect))
+	if (!batadv_atomic_dec_not_zero(&bat_priv->gw_reselect))
 		goto out;
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 6edf37f..f5c3980 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -97,9 +97,9 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 
 	ret = kstrtol(buff, 10, &ldown);
 	if (ret) {
-		bat_err(net_dev,
-			"Download speed of gateway mode invalid: %s\n",
-			buff);
+		batadv_err(net_dev,
+			   "Download speed of gateway mode invalid: %s\n",
+			   buff);
 		return false;
 	}
 
@@ -122,9 +122,9 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 
 		ret = kstrtol(slash_ptr + 1, 10, &lup);
 		if (ret) {
-			bat_err(net_dev,
-				"Upload speed of gateway mode invalid: %s\n",
-				slash_ptr + 1);
+			batadv_err(net_dev,
+				   "Upload speed of gateway mode invalid: %s\n",
+				   slash_ptr + 1);
 			return false;
 		}
 
@@ -164,13 +164,13 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 		return count;
 
 	batadv_gw_deselect(bat_priv);
-	bat_info(net_dev,
-		 "Changing gateway bandwidth from: '%i' to: '%ld' (propagating: %d%s/%d%s)\n",
-		 atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
-		 (down > 2048 ? down / 1024 : down),
-		 (down > 2048 ? "MBit" : "KBit"),
-		 (up > 2048 ? up / 1024 : up),
-		 (up > 2048 ? "MBit" : "KBit"));
+	batadv_info(net_dev,
+		    "Changing gateway bandwidth from: '%i' to: '%ld' (propagating: %d%s/%d%s)\n",
+		    atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
+		    (down > 2048 ? down / 1024 : down),
+		    (down > 2048 ? "MBit" : "KBit"),
+		    (up > 2048 ? up / 1024 : up),
+		    (up > 2048 ? "MBit" : "KBit"));
 
 	atomic_set(&bat_priv->gw_bandwidth, gw_bandwidth_tmp);
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index c22c145..c1ba6e2 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -234,8 +234,8 @@ static void batadv_hardif_activate_interface(struct hard_iface *hard_iface)
 	if (!primary_if)
 		batadv_primary_if_select(bat_priv, hard_iface);
 
-	bat_info(hard_iface->soft_iface, "Interface activated: %s\n",
-		 hard_iface->net_dev->name);
+	batadv_info(hard_iface->soft_iface, "Interface activated: %s\n",
+		    hard_iface->net_dev->name);
 
 	batadv_update_min_mtu(hard_iface->soft_iface);
 
@@ -252,8 +252,8 @@ static void batadv_hardif_deactivate_interface(struct hard_iface *hard_iface)
 
 	hard_iface->if_status = IF_INACTIVE;
 
-	bat_info(hard_iface->soft_iface, "Interface deactivated: %s\n",
-		 hard_iface->net_dev->name);
+	batadv_info(hard_iface->soft_iface, "Interface deactivated: %s\n",
+		    hard_iface->net_dev->name);
 
 	batadv_update_min_mtu(hard_iface->soft_iface);
 }
@@ -315,29 +315,29 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 	dev_add_pack(&hard_iface->batman_adv_ptype);
 
 	atomic_set(&hard_iface->frag_seqno, 1);
-	bat_info(hard_iface->soft_iface, "Adding interface: %s\n",
-		 hard_iface->net_dev->name);
+	batadv_info(hard_iface->soft_iface, "Adding interface: %s\n",
+		    hard_iface->net_dev->name);
 
 	if (atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
-		bat_info(hard_iface->soft_iface,
-			 "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. Packets going over this interface will be fragmented on layer2 which could impact the performance. Setting the MTU to %zi would solve the problem.\n",
-			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			 ETH_DATA_LEN + BAT_HEADER_LEN);
+		batadv_info(hard_iface->soft_iface,
+			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. Packets going over this interface will be fragmented on layer2 which could impact the performance. Setting the MTU to %zi would solve the problem.\n",
+			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
+			    ETH_DATA_LEN + BAT_HEADER_LEN);
 
 	if (!atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
-		bat_info(hard_iface->soft_iface,
-			 "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. If you experience problems getting traffic through try increasing the MTU to %zi.\n",
-			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			 ETH_DATA_LEN + BAT_HEADER_LEN);
+		batadv_info(hard_iface->soft_iface,
+			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. If you experience problems getting traffic through try increasing the MTU to %zi.\n",
+			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
+			    ETH_DATA_LEN + BAT_HEADER_LEN);
 
 	if (batadv_hardif_is_iface_up(hard_iface))
 		batadv_hardif_activate_interface(hard_iface);
 	else
-		bat_err(hard_iface->soft_iface,
-			"Not using interface %s (retrying later): interface not active\n",
-			hard_iface->net_dev->name);
+		batadv_err(hard_iface->soft_iface,
+			   "Not using interface %s (retrying later): interface not active\n",
+			   hard_iface->net_dev->name);
 
 	/* begin scheduling originator messages on that interface */
 	batadv_schedule_bat_ogm(hard_iface);
@@ -363,8 +363,8 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 	if (hard_iface->if_status != IF_INACTIVE)
 		goto out;
 
-	bat_info(hard_iface->soft_iface, "Removing interface: %s\n",
-		 hard_iface->net_dev->name);
+	batadv_info(hard_iface->soft_iface, "Removing interface: %s\n",
+		    hard_iface->net_dev->name);
 	dev_remove_pack(&hard_iface->batman_adv_ptype);
 
 	bat_priv->num_ifaces--;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2824264..b7b9817 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -190,14 +190,14 @@ static inline void batadv_dbg(int type __always_unused,
 }
 #endif
 
-#define bat_info(net_dev, fmt, arg...)					\
+#define batadv_info(net_dev, fmt, arg...)				\
 	do {								\
 		struct net_device *_netdev = (net_dev);                 \
 		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
 		batadv_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
 		pr_info("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
-#define bat_err(net_dev, fmt, arg...)					\
+#define batadv_err(net_dev, fmt, arg...)				\
 	do {								\
 		struct net_device *_netdev = (net_dev);                 \
 		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
@@ -226,10 +226,10 @@ static inline bool batadv_has_timed_out(unsigned long timestamp,
 	return time_is_before_jiffies(timestamp + msecs_to_jiffies(timeout));
 }
 
-#define atomic_dec_not_zero(v)	atomic_add_unless((v), -1, 0)
+#define batadv_atomic_dec_not_zero(v)	atomic_add_unless((v), -1, 0)
 
 /* Returns the smallest signed integer in two's complement with the sizeof x */
-#define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
+#define batadv_smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
 
 /* Checks if a sequence number x is a predecessor/successor of y.
  * they handle overflows/underflows and can correctly check for a
@@ -241,12 +241,12 @@ static inline bool batadv_has_timed_out(unsigned long timestamp,
  *  - when adding 128 - it is neither a predecessor nor a successor,
  *  - after adding more than 127 to the starting value - it is a successor
  */
-#define seq_before(x, y) ({typeof(x) _d1 = (x); \
-			  typeof(y) _d2 = (y); \
-			  typeof(x) _dummy = (_d1 - _d2); \
-			  (void) (&_d1 == &_d2); \
-			  _dummy > smallest_signed_int(_dummy); })
-#define seq_after(x, y) seq_before(y, x)
+#define batadv_seq_before(x, y) ({typeof(x) _d1 = (x); \
+				 typeof(y) _d2 = (y); \
+				 typeof(x) _dummy = (_d1 - _d2); \
+				 (void) (&_d1 == &_d2); \
+				 _dummy > batadv_smallest_signed_int(_dummy); })
+#define batadv_seq_after(x, y) batadv_seq_before(y, x)
 
 /* Stop preemption on local cpu while incrementing the counter */
 static inline void batadv_add_counter(struct bat_priv *bat_priv, size_t idx,
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e7ee40d..1b8f677 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -922,6 +922,7 @@ static int batadv_check_unicast_ttvn(struct bat_priv *bat_priv,
 	struct hard_iface *primary_if;
 	struct unicast_packet *unicast_packet;
 	bool tt_poss_change;
+	int is_old_ttvn;
 
 	/* I could need to modify it */
 	if (skb_cow(skb, sizeof(struct unicast_packet)) < 0)
@@ -945,7 +946,8 @@ static int batadv_check_unicast_ttvn(struct bat_priv *bat_priv,
 	}
 
 	/* Check whether I have to reroute the packet */
-	if (seq_before(unicast_packet->ttvn, curr_ttvn) || tt_poss_change) {
+	is_old_ttvn = batadv_seq_before(unicast_packet->ttvn, curr_ttvn);
+	if (is_old_ttvn || tt_poss_change) {
 		/* check if there is enough data before accessing it */
 		if (pskb_may_pull(skb, sizeof(struct unicast_packet) +
 				  ETH_HLEN) < 0)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 1842cbc..3d725e0 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -141,7 +141,7 @@ int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
 	struct bcast_packet *bcast_packet;
 	struct sk_buff *newskb;
 
-	if (!atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
+	if (!batadv_atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
 		batadv_dbg(DBG_BATMAN, bat_priv, "bcast packet queue full\n");
 		goto out;
 	}
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c673b58..074936f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1930,7 +1930,7 @@ static bool batadv_tt_check_roam_count(struct bat_priv *bat_priv,
 					 ROAMING_MAX_TIME))
 			continue;
 
-		if (!atomic_dec_not_zero(&tt_roam_node->counter))
+		if (!batadv_atomic_dec_not_zero(&tt_roam_node->counter))
 			/* Sorry, you roamed too many times! */
 			goto unlock;
 		ret = true;
@@ -2162,7 +2162,7 @@ int batadv_tt_append_diff(struct bat_priv *bat_priv,
 
 	/* if the changes have been sent often enough */
 	if ((tt_num_changes < 0) &&
-	    (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))) {
+	    (!batadv_atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))) {
 		batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
 					      packet_min_len, packet_min_len);
 		tt_num_changes = 0;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 607b101..6b7a1c0 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -424,8 +424,8 @@ static struct vis_info *batadv_add_packet(struct bat_priv *bat_priv,
 
 	if (old_info) {
 		old_packet = (struct vis_packet *)old_info->skb_packet->data;
-		if (!seq_after(ntohl(vis_packet->seqno),
-			       ntohl(old_packet->seqno))) {
+		if (!batadv_seq_after(ntohl(vis_packet->seqno),
+				      ntohl(old_packet->seqno))) {
 			if (old_packet->seqno == vis_packet->seqno) {
 				batadv_recv_list_add(bat_priv,
 						     &old_info->recv_list,
-- 
1.7.9.4
