From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/14] batman-adv: rename sysfs macros to reflect the soft-interface dependency
Date: Wed,  9 May 2012 13:12:52 +0200
Message-ID: <1336561976-16088-11-git-send-email-ordex@autistici.org>
References: <1336561976-16088-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:52797 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757955Ab2EILMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 07:12:47 -0400
In-Reply-To: <1336561976-16088-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_sysfs.c |   57 ++++++++++++++++++++++----------------------
 1 file changed, 29 insertions(+), 28 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 2c81688..913299d 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -63,7 +63,7 @@ struct bat_attribute bat_attr_##_name = {	\
 	.store  = _store,			\
 };
 
-#define BAT_ATTR_STORE_BOOL(_name, _post_func)				\
+#define BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)			\
 ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
 		      char *buff, size_t count)				\
 {									\
@@ -73,9 +73,9 @@ ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
 				 &bat_priv->_name, net_dev);		\
 }
 
-#define BAT_ATTR_SHOW_BOOL(_name)					\
-ssize_t show_##_name(struct kobject *kobj, struct attribute *attr,	\
-			    char *buff)					\
+#define BAT_ATTR_SIF_SHOW_BOOL(_name)					\
+ssize_t show_##_name(struct kobject *kobj,				\
+		     struct attribute *attr, char *buff)		\
 {									\
 	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);		\
 	return sprintf(buff, "%s\n",					\
@@ -83,16 +83,17 @@ ssize_t show_##_name(struct kobject *kobj, struct attribute *attr,	\
 		       "disabled" : "enabled");				\
 }									\
 
-/* Use this, if you are going to turn a [name] in bat_priv on or off */
-#define BAT_ATTR_BOOL(_name, _mode, _post_func)				\
-	static BAT_ATTR_STORE_BOOL(_name, _post_func)			\
-	static BAT_ATTR_SHOW_BOOL(_name)				\
+/* Use this, if you are going to turn a [name] in the soft-interface
+ * (bat_priv) on or off */
+#define BAT_ATTR_SIF_BOOL(_name, _mode, _post_func)			\
+	static BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)		\
+	static BAT_ATTR_SIF_SHOW_BOOL(_name)				\
 	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
 
 
-#define BAT_ATTR_STORE_UINT(_name, _min, _max, _post_func)		\
+#define BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)		\
 ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
-			     char *buff, size_t count)			\
+		      char *buff, size_t count)				\
 {									\
 	struct net_device *net_dev = kobj_to_netdev(kobj);		\
 	struct bat_priv *bat_priv = netdev_priv(net_dev);		\
@@ -100,19 +101,19 @@ ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
 				 attr, &bat_priv->_name, net_dev);	\
 }
 
-#define BAT_ATTR_SHOW_UINT(_name)					\
-ssize_t show_##_name(struct kobject *kobj, struct attribute *attr,	\
-			    char *buff)					\
+#define BAT_ATTR_SIF_SHOW_UINT(_name)					\
+ssize_t show_##_name(struct kobject *kobj,				\
+		     struct attribute *attr, char *buff)		\
 {									\
 	struct bat_priv *bat_priv = kobj_to_batpriv(kobj);		\
 	return sprintf(buff, "%i\n", atomic_read(&bat_priv->_name));	\
 }									\
 
-/* Use this, if you are going to set [name] in bat_priv to unsigned integer
- * values only */
-#define BAT_ATTR_UINT(_name, _mode, _min, _max, _post_func)		\
-	static BAT_ATTR_STORE_UINT(_name, _min, _max, _post_func)	\
-	static BAT_ATTR_SHOW_UINT(_name)				\
+/* Use this, if you are going to set [name] in the soft-interface
+ * (bat_priv) to an unsigned integer value */
+#define BAT_ATTR_SIF_UINT(_name, _mode, _min, _max, _post_func)		\
+	static BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)	\
+	static BAT_ATTR_SIF_SHOW_UINT(_name)				\
 	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
 
 
@@ -384,24 +385,24 @@ static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 	return gw_bandwidth_set(net_dev, buff, count);
 }
 
-BAT_ATTR_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
-BAT_ATTR_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 #ifdef CONFIG_BATMAN_ADV_BLA
-BAT_ATTR_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
 #endif
-BAT_ATTR_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
-BAT_ATTR_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
+BAT_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
 static BAT_ATTR(routing_algo, S_IRUGO, show_bat_algo, NULL);
 static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, show_gw_mode, store_gw_mode);
-BAT_ATTR_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MAX, NULL);
-BAT_ATTR_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, NULL);
-BAT_ATTR_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
-	      post_gw_deselect);
+BAT_ATTR_SIF_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MAX, NULL);
+BAT_ATTR_SIF_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, NULL);
+BAT_ATTR_SIF_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
+		  post_gw_deselect);
 static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, show_gw_bwidth,
 		store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 15, NULL);
+BAT_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, 15, NULL);
 #endif
 
 static struct bat_attribute *mesh_attrs[] = {
-- 
1.7.9.4
