From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/20] batman-adv: Prefix bat_sysfs local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:33 +0200
Message-ID: <1340607284-29950-10-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30444 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679Ab2FYGyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:47 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_sysfs.c |  255 ++++++++++++++++++++++++--------------------
 1 file changed, 138 insertions(+), 117 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 7f464a9..03b76a4 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -26,15 +26,15 @@
 #include "gateway_client.h"
 #include "vis.h"
 
-static struct net_device *kobj_to_netdev(struct kobject *obj)
+static struct net_device *batadv_kobj_to_netdev(struct kobject *obj)
 {
 	struct device *dev = container_of(obj->parent, struct device, kobj);
 	return to_net_dev(dev);
 }
 
-static struct bat_priv *kobj_to_batpriv(struct kobject *obj)
+static struct bat_priv *batadv_kobj_to_batpriv(struct kobject *obj)
 {
-	struct net_device *net_dev = kobj_to_netdev(obj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(obj);
 	return netdev_priv(net_dev);
 }
 
@@ -42,19 +42,19 @@ static struct bat_priv *kobj_to_batpriv(struct kobject *obj)
 #define UEV_ACTION_VAR	"BATACTION="
 #define UEV_DATA_VAR	"BATDATA="
 
-static char *uev_action_str[] = {
+static char *batadv_uev_action_str[] = {
 	"add",
 	"del",
 	"change"
 };
 
-static char *uev_type_str[] = {
+static char *batadv_uev_type_str[] = {
 	"gw"
 };
 
 /* Use this, if you have customized show and store functions */
 #define BAT_ATTR(_name, _mode, _show, _store)	\
-struct bat_attribute bat_attr_##_name = {	\
+struct bat_attribute batadv_attr_##_name = {	\
 	.attr = {.name = __stringify(_name),	\
 		 .mode = _mode },		\
 	.show   = _show,			\
@@ -62,20 +62,21 @@ struct bat_attribute bat_attr_##_name = {	\
 };
 
 #define BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)			\
-ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
-		      char *buff, size_t count)				\
+ssize_t batadv_store_##_name(struct kobject *kobj,			\
+			     struct attribute *attr, char *buff,	\
+			     size_t count)				\
 {									\
-	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
 	struct bat_priv *bat_priv = netdev_priv(net_dev);		\
-	return __store_bool_attr(buff, count, _post_func, attr,		\
-				 &bat_priv->_name, net_dev);		\
+	return __batadv_store_bool_attr(buff, count, _post_func, attr,	\
+					&bat_priv->_name, net_dev);	\
 }
 
 #define BAT_ATTR_SIF_SHOW_BOOL(_name)					\
-ssize_t show_##_name(struct kobject *kobj,				\
-		     struct attribute *attr, char *buff)		\
+ssize_t batadv_show_##_name(struct kobject *kobj,			\
+			    struct attribute *attr, char *buff)		\
 {									\
-	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);		\
+	struct bat_priv *bat_priv = batadv_kobj_to_batpriv(kobj);	\
 	return sprintf(buff, "%s\n",					\
 		       atomic_read(&bat_priv->_name) == 0 ?		\
 		       "disabled" : "enabled");				\
@@ -87,24 +88,27 @@ ssize_t show_##_name(struct kobject *kobj,				\
 #define BAT_ATTR_SIF_BOOL(_name, _mode, _post_func)			\
 	static BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)		\
 	static BAT_ATTR_SIF_SHOW_BOOL(_name)				\
-	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+	static BAT_ATTR(_name, _mode, batadv_show_##_name,		\
+			batadv_store_##_name)
 
 
 #define BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)		\
-ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
-		      char *buff, size_t count)				\
+ssize_t batadv_store_##_name(struct kobject *kobj,			\
+			     struct attribute *attr, char *buff,	\
+			     size_t count)				\
 {									\
-	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
 	struct bat_priv *bat_priv = netdev_priv(net_dev);		\
-	return __store_uint_attr(buff, count, _min, _max, _post_func,	\
-				 attr, &bat_priv->_name, net_dev);	\
+	return __batadv_store_uint_attr(buff, count, _min, _max,	\
+					_post_func, attr,		\
+					&bat_priv->_name, net_dev);	\
 }
 
 #define BAT_ATTR_SIF_SHOW_UINT(_name)					\
-ssize_t show_##_name(struct kobject *kobj,				\
-		     struct attribute *attr, char *buff)		\
+ssize_t batadv_show_##_name(struct kobject *kobj,			\
+			    struct attribute *attr, char *buff)		\
 {									\
-	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);		\
+	struct bat_priv *bat_priv = batadv_kobj_to_batpriv(kobj);	\
 	return sprintf(buff, "%i\n", atomic_read(&bat_priv->_name));	\
 }									\
 
@@ -114,14 +118,16 @@ ssize_t show_##_name(struct kobject *kobj,				\
 #define BAT_ATTR_SIF_UINT(_name, _mode, _min, _max, _post_func)		\
 	static BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)	\
 	static BAT_ATTR_SIF_SHOW_UINT(_name)				\
-	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+	static BAT_ATTR(_name, _mode, batadv_show_##_name,		\
+			batadv_store_##_name)
 
 
 #define BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)		\
-ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
-		      char *buff, size_t count)				\
+ssize_t batadv_store_##_name(struct kobject *kobj,			\
+			     struct attribute *attr, char *buff,	\
+			     size_t count)				\
 {									\
-	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
 	struct hard_iface *hard_iface;					\
 	ssize_t length;							\
 									\
@@ -129,18 +135,19 @@ ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
 	if (!hard_iface)						\
 		return 0;						\
 									\
-	length = __store_uint_attr(buff, count, _min, _max, _post_func,	\
-				   attr, &hard_iface->_name, net_dev);	\
+	length = __batadv_store_uint_attr(buff, count, _min, _max,	\
+					  _post_func, attr,		\
+					  &hard_iface->_name, net_dev);	\
 									\
 	batadv_hardif_free_ref(hard_iface);				\
 	return length;							\
 }
 
 #define BAT_ATTR_HIF_SHOW_UINT(_name)					\
-ssize_t show_##_name(struct kobject *kobj,				\
-		     struct attribute *attr, char *buff)		\
+ssize_t batadv_show_##_name(struct kobject *kobj,			\
+			    struct attribute *attr, char *buff)		\
 {									\
-	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
 	struct hard_iface *hard_iface;					\
 	ssize_t length;							\
 									\
@@ -160,12 +167,13 @@ ssize_t show_##_name(struct kobject *kobj,				\
 #define BAT_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)		\
 	static BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
 	static BAT_ATTR_HIF_SHOW_UINT(_name)				\
-	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+	static BAT_ATTR(_name, _mode, batadv_show_##_name,		\
+			batadv_store_##_name)
 
 
-static int store_bool_attr(char *buff, size_t count,
-			   struct net_device *net_dev,
-			   const char *attr_name, atomic_t *attr)
+static int batadv_store_bool_attr(char *buff, size_t count,
+				  struct net_device *net_dev,
+				  const char *attr_name, atomic_t *attr)
 {
 	int enabled = -1;
 
@@ -200,23 +208,27 @@ static int store_bool_attr(char *buff, size_t count,
 	return count;
 }
 
-static inline ssize_t __store_bool_attr(char *buff, size_t count,
-			void (*post_func)(struct net_device *),
-			struct attribute *attr,
-			atomic_t *attr_store, struct net_device *net_dev)
+static inline ssize_t
+__batadv_store_bool_attr(char *buff, size_t count,
+			 void (*post_func)(struct net_device *),
+			 struct attribute *attr,
+			 atomic_t *attr_store, struct net_device *net_dev)
 {
 	int ret;
 
-	ret = store_bool_attr(buff, count, net_dev, attr->name, attr_store);
+	ret = batadv_store_bool_attr(buff, count, net_dev, attr->name,
+				     attr_store);
 	if (post_func && ret)
 		post_func(net_dev);
 
 	return ret;
 }
 
-static int store_uint_attr(const char *buff, size_t count,
-			   struct net_device *net_dev, const char *attr_name,
-			   unsigned int min, unsigned int max, atomic_t *attr)
+static int batadv_store_uint_attr(const char *buff, size_t count,
+				  struct net_device *net_dev,
+				  const char *attr_name,
+				  unsigned int min, unsigned int max,
+				  atomic_t *attr)
 {
 	unsigned long uint_val;
 	int ret;
@@ -251,26 +263,27 @@ static int store_uint_attr(const char *buff, size_t count,
 	return count;
 }
 
-static inline ssize_t __store_uint_attr(const char *buff, size_t count,
-			int min, int max,
-			void (*post_func)(struct net_device *),
-			const struct attribute *attr,
-			atomic_t *attr_store, struct net_device *net_dev)
+static inline ssize_t
+__batadv_store_uint_attr(const char *buff, size_t count,
+			 int min, int max,
+			 void (*post_func)(struct net_device *),
+			 const struct attribute *attr,
+			 atomic_t *attr_store, struct net_device *net_dev)
 {
 	int ret;
 
-	ret = store_uint_attr(buff, count, net_dev, attr->name,
-			      min, max, attr_store);
+	ret = batadv_store_uint_attr(buff, count, net_dev, attr->name, min, max,
+				     attr_store);
 	if (post_func && ret)
 		post_func(net_dev);
 
 	return ret;
 }
 
-static ssize_t show_vis_mode(struct kobject *kobj, struct attribute *attr,
-			     char *buff)
+static ssize_t batadv_show_vis_mode(struct kobject *kobj,
+				    struct attribute *attr, char *buff)
 {
-	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);
+	struct bat_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 	int vis_mode = atomic_read(&bat_priv->vis_mode);
 
 	return sprintf(buff, "%s\n",
@@ -278,10 +291,11 @@ static ssize_t show_vis_mode(struct kobject *kobj, struct attribute *attr,
 							"client" : "server");
 }
 
-static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *attr,
-			      char *buff, size_t count)
+static ssize_t batadv_store_vis_mode(struct kobject *kobj,
+				     struct attribute *attr, char *buff,
+				     size_t count)
 {
-	struct net_device *net_dev = kobj_to_netdev(kobj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	unsigned long val;
 	int ret, vis_mode_tmp = -1;
@@ -319,23 +333,23 @@ static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *attr,
 	return count;
 }
 
-static ssize_t show_bat_algo(struct kobject *kobj, struct attribute *attr,
-			    char *buff)
+static ssize_t batadv_show_bat_algo(struct kobject *kobj,
+				    struct attribute *attr, char *buff)
 {
-	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);
+	struct bat_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 	return sprintf(buff, "%s\n", bat_priv->bat_algo_ops->name);
 }
 
-static void post_gw_deselect(struct net_device *net_dev)
+static void batadv_post_gw_deselect(struct net_device *net_dev)
 {
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	batadv_gw_deselect(bat_priv);
 }
 
-static ssize_t show_gw_mode(struct kobject *kobj, struct attribute *attr,
-			    char *buff)
+static ssize_t batadv_show_gw_mode(struct kobject *kobj, struct attribute *attr,
+				   char *buff)
 {
-	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);
+	struct bat_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 	int bytes_written;
 
 	switch (atomic_read(&bat_priv->gw_mode)) {
@@ -353,10 +367,11 @@ static ssize_t show_gw_mode(struct kobject *kobj, struct attribute *attr,
 	return bytes_written;
 }
 
-static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *attr,
-			     char *buff, size_t count)
+static ssize_t batadv_store_gw_mode(struct kobject *kobj,
+				    struct attribute *attr, char *buff,
+				    size_t count)
 {
-	struct net_device *net_dev = kobj_to_netdev(kobj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	char *curr_gw_mode_str;
 	int gw_mode_tmp = -1;
@@ -405,10 +420,10 @@ static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *attr,
 	return count;
 }
 
-static ssize_t show_gw_bwidth(struct kobject *kobj, struct attribute *attr,
-			      char *buff)
+static ssize_t batadv_show_gw_bwidth(struct kobject *kobj,
+				     struct attribute *attr, char *buff)
 {
-	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);
+	struct bat_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 	int down, up;
 	int gw_bandwidth = atomic_read(&bat_priv->gw_bandwidth);
 
@@ -420,10 +435,11 @@ static ssize_t show_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 		       (up > 2048 ? "MBit" : "KBit"));
 }
 
-static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *attr,
-			       char *buff, size_t count)
+static ssize_t batadv_store_gw_bwidth(struct kobject *kobj,
+				      struct attribute *attr, char *buff,
+				      size_t count)
 {
-	struct net_device *net_dev = kobj_to_netdev(kobj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 
 	if (buff[count - 1] == '\n')
 		buff[count - 1] = '\0';
@@ -438,36 +454,38 @@ BAT_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
 #endif
 BAT_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_mtu);
 BAT_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
-static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
-static BAT_ATTR(routing_algo, S_IRUGO, show_bat_algo, NULL);
-static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, show_gw_mode, store_gw_mode);
+static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, batadv_show_vis_mode,
+		batadv_store_vis_mode);
+static BAT_ATTR(routing_algo, S_IRUGO, batadv_show_bat_algo, NULL);
+static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, batadv_show_gw_mode,
+		batadv_store_gw_mode);
 BAT_ATTR_SIF_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MAX, NULL);
 BAT_ATTR_SIF_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, NULL);
 BAT_ATTR_SIF_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
-		  post_gw_deselect);
-static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, show_gw_bwidth,
-		store_gw_bwidth);
+		  batadv_post_gw_deselect);
+static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwidth,
+		batadv_store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 BAT_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, DBG_ALL, NULL);
 #endif
 
-static struct bat_attribute *mesh_attrs[] = {
-	&bat_attr_aggregated_ogms,
-	&bat_attr_bonding,
+static struct bat_attribute *batadv_mesh_attrs[] = {
+	&batadv_attr_aggregated_ogms,
+	&batadv_attr_bonding,
 #ifdef CONFIG_BATMAN_ADV_BLA
-	&bat_attr_bridge_loop_avoidance,
+	&batadv_attr_bridge_loop_avoidance,
 #endif
-	&bat_attr_fragmentation,
-	&bat_attr_ap_isolation,
-	&bat_attr_vis_mode,
-	&bat_attr_routing_algo,
-	&bat_attr_gw_mode,
-	&bat_attr_orig_interval,
-	&bat_attr_hop_penalty,
-	&bat_attr_gw_sel_class,
-	&bat_attr_gw_bandwidth,
+	&batadv_attr_fragmentation,
+	&batadv_attr_ap_isolation,
+	&batadv_attr_vis_mode,
+	&batadv_attr_routing_algo,
+	&batadv_attr_gw_mode,
+	&batadv_attr_orig_interval,
+	&batadv_attr_hop_penalty,
+	&batadv_attr_gw_sel_class,
+	&batadv_attr_gw_bandwidth,
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-	&bat_attr_log_level,
+	&batadv_attr_log_level,
 #endif
 	NULL,
 };
@@ -487,7 +505,7 @@ int batadv_sysfs_add_meshif(struct net_device *dev)
 		goto out;
 	}
 
-	for (bat_attr = mesh_attrs; *bat_attr; ++bat_attr) {
+	for (bat_attr = batadv_mesh_attrs; *bat_attr; ++bat_attr) {
 		err = sysfs_create_file(bat_priv->mesh_obj,
 					&((*bat_attr)->attr));
 		if (err) {
@@ -501,7 +519,7 @@ int batadv_sysfs_add_meshif(struct net_device *dev)
 	return 0;
 
 rem_attr:
-	for (bat_attr = mesh_attrs; *bat_attr; ++bat_attr)
+	for (bat_attr = batadv_mesh_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
 
 	kobject_put(bat_priv->mesh_obj);
@@ -515,17 +533,17 @@ void batadv_sysfs_del_meshif(struct net_device *dev)
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	struct bat_attribute **bat_attr;
 
-	for (bat_attr = mesh_attrs; *bat_attr; ++bat_attr)
+	for (bat_attr = batadv_mesh_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
 
 	kobject_put(bat_priv->mesh_obj);
 	bat_priv->mesh_obj = NULL;
 }
 
-static ssize_t show_mesh_iface(struct kobject *kobj, struct attribute *attr,
-			       char *buff)
+static ssize_t batadv_show_mesh_iface(struct kobject *kobj,
+				      struct attribute *attr, char *buff)
 {
-	struct net_device *net_dev = kobj_to_netdev(kobj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct hard_iface *hard_iface = batadv_hardif_get_by_netdev(net_dev);
 	ssize_t length;
 
@@ -540,10 +558,11 @@ static ssize_t show_mesh_iface(struct kobject *kobj, struct attribute *attr,
 	return length;
 }
 
-static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
-				char *buff, size_t count)
+static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
+				       struct attribute *attr, char *buff,
+				       size_t count)
 {
-	struct net_device *net_dev = kobj_to_netdev(kobj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct hard_iface *hard_iface = batadv_hardif_get_by_netdev(net_dev);
 	int status_tmp = -1;
 	int ret = count;
@@ -596,10 +615,10 @@ out:
 	return ret;
 }
 
-static ssize_t show_iface_status(struct kobject *kobj, struct attribute *attr,
-				 char *buff)
+static ssize_t batadv_show_iface_status(struct kobject *kobj,
+					struct attribute *attr, char *buff)
 {
-	struct net_device *net_dev = kobj_to_netdev(kobj);
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct hard_iface *hard_iface = batadv_hardif_get_by_netdev(net_dev);
 	ssize_t length;
 
@@ -631,12 +650,12 @@ static ssize_t show_iface_status(struct kobject *kobj, struct attribute *attr,
 }
 
 static BAT_ATTR(mesh_iface, S_IRUGO | S_IWUSR,
-		show_mesh_iface, store_mesh_iface);
-static BAT_ATTR(iface_status, S_IRUGO, show_iface_status, NULL);
+		batadv_show_mesh_iface, batadv_store_mesh_iface);
+static BAT_ATTR(iface_status, S_IRUGO, batadv_show_iface_status, NULL);
 
-static struct bat_attribute *batman_attrs[] = {
-	&bat_attr_mesh_iface,
-	&bat_attr_iface_status,
+static struct bat_attribute *batadv_batman_attrs[] = {
+	&batadv_attr_mesh_iface,
+	&batadv_attr_iface_status,
 	NULL,
 };
 
@@ -655,7 +674,7 @@ int batadv_sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
 		goto out;
 	}
 
-	for (bat_attr = batman_attrs; *bat_attr; ++bat_attr) {
+	for (bat_attr = batadv_batman_attrs; *bat_attr; ++bat_attr) {
 		err = sysfs_create_file(*hardif_obj, &((*bat_attr)->attr));
 		if (err) {
 			bat_err(dev, "Can't add sysfs file: %s/%s/%s\n",
@@ -668,7 +687,7 @@ int batadv_sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
 	return 0;
 
 rem_attr:
-	for (bat_attr = batman_attrs; *bat_attr; ++bat_attr)
+	for (bat_attr = batadv_batman_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(*hardif_obj, &((*bat_attr)->attr));
 out:
 	return -ENOMEM;
@@ -695,20 +714,21 @@ int batadv_throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
 	bat_kobj = &primary_if->soft_iface->dev.kobj;
 
 	uevent_env[0] = kmalloc(strlen(UEV_TYPE_VAR) +
-				strlen(uev_type_str[type]) + 1,
+				strlen(batadv_uev_type_str[type]) + 1,
 				GFP_ATOMIC);
 	if (!uevent_env[0])
 		goto out;
 
-	sprintf(uevent_env[0], "%s%s", UEV_TYPE_VAR, uev_type_str[type]);
+	sprintf(uevent_env[0], "%s%s", UEV_TYPE_VAR, batadv_uev_type_str[type]);
 
 	uevent_env[1] = kmalloc(strlen(UEV_ACTION_VAR) +
-				strlen(uev_action_str[action]) + 1,
+				strlen(batadv_uev_action_str[action]) + 1,
 				GFP_ATOMIC);
 	if (!uevent_env[1])
 		goto out;
 
-	sprintf(uevent_env[1], "%s%s", UEV_ACTION_VAR, uev_action_str[action]);
+	sprintf(uevent_env[1], "%s%s", UEV_ACTION_VAR,
+		batadv_uev_action_str[action]);
 
 	/* If the event is DEL, ignore the data field */
 	if (action != UEV_DEL) {
@@ -732,7 +752,8 @@ out:
 	if (ret)
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
-			   uev_type_str[type], uev_action_str[action],
+			   batadv_uev_type_str[type],
+			   batadv_uev_action_str[action],
 			   (action == UEV_DEL ? "NULL" : data), ret);
 	return ret;
 }
-- 
1.7.9.4
