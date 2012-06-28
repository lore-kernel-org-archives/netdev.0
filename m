From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/18] batman-adv: Prefix local defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:17 +0200
Message-ID: <1340876067-28333-9-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30209 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932524Ab2F1Jec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:32 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_debugfs.c    |   26 ++++-----
 net/batman-adv/bat_sysfs.c      |  114 ++++++++++++++++++++-----------=
--------
 net/batman-adv/gateway_client.c |   12 ++---
 net/batman-adv/vis.c            |   16 +++---
 4 files changed, 87 insertions(+), 81 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.=
c
index ca6aee4..ce84a61 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -35,14 +35,14 @@
 static struct dentry *batadv_debugfs;
=20
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-#define LOG_BUFF_MASK (batadv_log_buff_len - 1)
-#define LOG_BUFF(idx) (debug_log->log_buff[(idx) & LOG_BUFF_MASK])
+#define BATADV_LOG_BUFF_MASK (batadv_log_buff_len - 1)
+#define BATADV_LOG_BUFF(idx) (debug_log->log_buff[(idx) & BATADV_LOG_B=
UFF_MASK])
=20
 static int batadv_log_buff_len =3D LOG_BUF_LEN;
=20
 static void batadv_emit_log_char(struct debug_log *debug_log, char c)
 {
-	LOG_BUFF(debug_log->log_end) =3D c;
+	BATADV_LOG_BUFF(debug_log->log_end) =3D c;
 	debug_log->log_end++;
=20
 	if (debug_log->log_end - debug_log->log_start > batadv_log_buff_len)
@@ -133,7 +133,7 @@ static ssize_t batadv_log_read(struct file *file, c=
har __user *buf,
=20
 	while ((!error) && (i < count) &&
 	       (debug_log->log_start !=3D debug_log->log_end)) {
-		c =3D LOG_BUFF(debug_log->log_start);
+		c =3D BATADV_LOG_BUFF(debug_log->log_start);
=20
 		debug_log->log_start++;
=20
@@ -270,7 +270,7 @@ struct bat_debuginfo {
 	const struct file_operations fops;
 };
=20
-#define BAT_DEBUGINFO(_name, _mode, _open)		\
+#define BATADV_DEBUGINFO(_name, _mode, _open)		\
 struct bat_debuginfo batadv_debuginfo_##_name =3D {	\
 	.attr =3D { .name =3D __stringify(_name),		\
 		  .mode =3D _mode, },			\
@@ -282,15 +282,17 @@ struct bat_debuginfo batadv_debuginfo_##_name =3D=
 {	\
 		}					\
 };
=20
-static BAT_DEBUGINFO(routing_algos, S_IRUGO, batadv_algorithms_open);
-static BAT_DEBUGINFO(originators, S_IRUGO, batadv_originators_open);
-static BAT_DEBUGINFO(gateways, S_IRUGO, batadv_gateways_open);
-static BAT_DEBUGINFO(transtable_global, S_IRUGO, batadv_transtable_glo=
bal_open);
+static BATADV_DEBUGINFO(routing_algos, S_IRUGO, batadv_algorithms_open=
);
+static BATADV_DEBUGINFO(originators, S_IRUGO, batadv_originators_open)=
;
+static BATADV_DEBUGINFO(gateways, S_IRUGO, batadv_gateways_open);
+static BATADV_DEBUGINFO(transtable_global, S_IRUGO,
+			batadv_transtable_global_open);
 #ifdef CONFIG_BATMAN_ADV_BLA
-static BAT_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_table_=
open);
+static BATADV_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_tab=
le_open);
 #endif
-static BAT_DEBUGINFO(transtable_local, S_IRUGO, batadv_transtable_loca=
l_open);
-static BAT_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
+static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
+			batadv_transtable_local_open);
+static BATADV_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
=20
 static struct bat_debuginfo *batadv_mesh_debuginfos[] =3D {
 	&batadv_debuginfo_originators,
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 54429a2..3862fe1 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -38,9 +38,9 @@ static struct bat_priv *batadv_kobj_to_batpriv(struct=
 kobject *obj)
 	return netdev_priv(net_dev);
 }
=20
-#define UEV_TYPE_VAR	"BATTYPE=3D"
-#define UEV_ACTION_VAR	"BATACTION=3D"
-#define UEV_DATA_VAR	"BATDATA=3D"
+#define BATADV_UEV_TYPE_VAR	"BATTYPE=3D"
+#define BATADV_UEV_ACTION_VAR	"BATACTION=3D"
+#define BATADV_UEV_DATA_VAR	"BATDATA=3D"
=20
 static char *batadv_uev_action_str[] =3D {
 	"add",
@@ -53,15 +53,15 @@ static char *batadv_uev_type_str[] =3D {
 };
=20
 /* Use this, if you have customized show and store functions */
-#define BAT_ATTR(_name, _mode, _show, _store)	\
-struct bat_attribute batadv_attr_##_name =3D {	\
-	.attr =3D {.name =3D __stringify(_name),	\
-		 .mode =3D _mode },		\
-	.show   =3D _show,			\
-	.store  =3D _store,			\
+#define BATADV_ATTR(_name, _mode, _show, _store)	\
+struct bat_attribute batadv_attr_##_name =3D {		\
+	.attr =3D {.name =3D __stringify(_name),		\
+		 .mode =3D _mode },			\
+	.show   =3D _show,				\
+	.store  =3D _store,				\
 };
=20
-#define BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)			\
+#define BATADV_ATTR_SIF_STORE_BOOL(_name, _post_func)			\
 ssize_t batadv_store_##_name(struct kobject *kobj,			\
 			     struct attribute *attr, char *buff,	\
 			     size_t count)				\
@@ -72,7 +72,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			=
\
 					&bat_priv->_name, net_dev);	\
 }
=20
-#define BAT_ATTR_SIF_SHOW_BOOL(_name)					\
+#define BATADV_ATTR_SIF_SHOW_BOOL(_name)				\
 ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
@@ -85,14 +85,14 @@ ssize_t batadv_show_##_name(struct kobject *kobj,		=
	\
 /* Use this, if you are going to turn a [name] in the soft-interface
  * (bat_priv) on or off
  */
-#define BAT_ATTR_SIF_BOOL(_name, _mode, _post_func)			\
-	static BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)		\
-	static BAT_ATTR_SIF_SHOW_BOOL(_name)				\
-	static BAT_ATTR(_name, _mode, batadv_show_##_name,		\
-			batadv_store_##_name)
+#define BATADV_ATTR_SIF_BOOL(_name, _mode, _post_func)			\
+	static BATADV_ATTR_SIF_STORE_BOOL(_name, _post_func)		\
+	static BATADV_ATTR_SIF_SHOW_BOOL(_name)				\
+	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
+			   batadv_store_##_name)
=20
=20
-#define BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)		\
+#define BATADV_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)	\
 ssize_t batadv_store_##_name(struct kobject *kobj,			\
 			     struct attribute *attr, char *buff,	\
 			     size_t count)				\
@@ -104,7 +104,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,	=
		\
 					&bat_priv->_name, net_dev);	\
 }
=20
-#define BAT_ATTR_SIF_SHOW_UINT(_name)					\
+#define BATADV_ATTR_SIF_SHOW_UINT(_name)				\
 ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
@@ -115,14 +115,14 @@ ssize_t batadv_show_##_name(struct kobject *kobj,=
			\
 /* Use this, if you are going to set [name] in the soft-interface
  * (bat_priv) to an unsigned integer value
  */
-#define BAT_ATTR_SIF_UINT(_name, _mode, _min, _max, _post_func)		\
-	static BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)	\
-	static BAT_ATTR_SIF_SHOW_UINT(_name)				\
-	static BAT_ATTR(_name, _mode, batadv_show_##_name,		\
-			batadv_store_##_name)
+#define BATADV_ATTR_SIF_UINT(_name, _mode, _min, _max, _post_func)	\
+	static BATADV_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)\
+	static BATADV_ATTR_SIF_SHOW_UINT(_name)				\
+	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
+			   batadv_store_##_name)
=20
=20
-#define BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)		\
+#define BATADV_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
 ssize_t batadv_store_##_name(struct kobject *kobj,			\
 			     struct attribute *attr, char *buff,	\
 			     size_t count)				\
@@ -143,7 +143,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,	=
		\
 	return length;							\
 }
=20
-#define BAT_ATTR_HIF_SHOW_UINT(_name)					\
+#define BATADV_ATTR_HIF_SHOW_UINT(_name)				\
 ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
@@ -164,11 +164,11 @@ ssize_t batadv_show_##_name(struct kobject *kobj,=
			\
 /* Use this, if you are going to set [name] in hard_iface to an
  * unsigned integer value
  */
-#define BAT_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)		\
-	static BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
-	static BAT_ATTR_HIF_SHOW_UINT(_name)				\
-	static BAT_ATTR(_name, _mode, batadv_show_##_name,		\
-			batadv_store_##_name)
+#define BATADV_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)	\
+	static BATADV_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)\
+	static BATADV_ATTR_HIF_SHOW_UINT(_name)				\
+	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
+			   batadv_store_##_name)
=20
=20
 static int batadv_store_bool_attr(char *buff, size_t count,
@@ -454,26 +454,27 @@ static ssize_t batadv_store_gw_bwidth(struct kobj=
ect *kobj,
 	return batadv_gw_bandwidth_set(net_dev, buff, count);
 }
=20
-BAT_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
-BAT_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 #ifdef CONFIG_BATMAN_ADV_BLA
-BAT_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
 #endif
-BAT_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_=
mtu);
-BAT_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
-static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, batadv_show_vis_mode,
-		batadv_store_vis_mode);
-static BAT_ATTR(routing_algo, S_IRUGO, batadv_show_bat_algo, NULL);
-static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, batadv_show_gw_mode,
-		batadv_store_gw_mode);
-BAT_ATTR_SIF_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MA=
X, NULL);
-BAT_ATTR_SIF_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, NUL=
L);
-BAT_ATTR_SIF_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
-		  batadv_post_gw_deselect);
-static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwidth=
,
-		batadv_store_gw_bwidth);
+BATADV_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_m=
in_mtu);
+BATADV_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
+static BATADV_ATTR(vis_mode, S_IRUGO | S_IWUSR, batadv_show_vis_mode,
+		   batadv_store_vis_mode);
+static BATADV_ATTR(routing_algo, S_IRUGO, batadv_show_bat_algo, NULL);
+static BATADV_ATTR(gw_mode, S_IRUGO | S_IWUSR, batadv_show_gw_mode,
+		   batadv_store_gw_mode);
+BATADV_ATTR_SIF_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT=
_MAX,
+		     NULL);
+BATADV_ATTR_SIF_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, =
NULL);
+BATADV_ATTR_SIF_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
+		     batadv_post_gw_deselect);
+static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwi=
dth,
+		   batadv_store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BAT_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, DBG_ALL, NULL);
+BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, DBG_ALL, NULL);
 #endif
=20
 static struct bat_attribute *batadv_mesh_attrs[] =3D {
@@ -656,9 +657,9 @@ static ssize_t batadv_show_iface_status(struct kobj=
ect *kobj,
 	return length;
 }
=20
-static BAT_ATTR(mesh_iface, S_IRUGO | S_IWUSR,
-		batadv_show_mesh_iface, batadv_store_mesh_iface);
-static BAT_ATTR(iface_status, S_IRUGO, batadv_show_iface_status, NULL)=
;
+static BATADV_ATTR(mesh_iface, S_IRUGO | S_IWUSR, batadv_show_mesh_ifa=
ce,
+		   batadv_store_mesh_iface);
+static BATADV_ATTR(iface_status, S_IRUGO, batadv_show_iface_status, NU=
LL);
=20
 static struct bat_attribute *batadv_batman_attrs[] =3D {
 	&batadv_attr_mesh_iface,
@@ -720,31 +721,32 @@ int batadv_throw_uevent(struct bat_priv *bat_priv=
, enum uev_type type,
=20
 	bat_kobj =3D &primary_if->soft_iface->dev.kobj;
=20
-	uevent_env[0] =3D kmalloc(strlen(UEV_TYPE_VAR) +
+	uevent_env[0] =3D kmalloc(strlen(BATADV_UEV_TYPE_VAR) +
 				strlen(batadv_uev_type_str[type]) + 1,
 				GFP_ATOMIC);
 	if (!uevent_env[0])
 		goto out;
=20
-	sprintf(uevent_env[0], "%s%s", UEV_TYPE_VAR, batadv_uev_type_str[type=
]);
+	sprintf(uevent_env[0], "%s%s", BATADV_UEV_TYPE_VAR,
+		batadv_uev_type_str[type]);
=20
-	uevent_env[1] =3D kmalloc(strlen(UEV_ACTION_VAR) +
+	uevent_env[1] =3D kmalloc(strlen(BATADV_UEV_ACTION_VAR) +
 				strlen(batadv_uev_action_str[action]) + 1,
 				GFP_ATOMIC);
 	if (!uevent_env[1])
 		goto out;
=20
-	sprintf(uevent_env[1], "%s%s", UEV_ACTION_VAR,
+	sprintf(uevent_env[1], "%s%s", BATADV_UEV_ACTION_VAR,
 		batadv_uev_action_str[action]);
=20
 	/* If the event is DEL, ignore the data field */
 	if (action !=3D UEV_DEL) {
-		uevent_env[2] =3D kmalloc(strlen(UEV_DATA_VAR) +
+		uevent_env[2] =3D kmalloc(strlen(BATADV_UEV_DATA_VAR) +
 					strlen(data) + 1, GFP_ATOMIC);
 		if (!uevent_env[2])
 			goto out;
=20
-		sprintf(uevent_env[2], "%s%s", UEV_DATA_VAR, data);
+		sprintf(uevent_env[2], "%s%s", BATADV_UEV_DATA_VAR, data);
 	}
=20
 	ret =3D kobject_uevent_env(bat_kobj, KOBJ_CHANGE, uevent_env);
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index f43eb57..3916e90 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -33,8 +33,8 @@
 /* This is the offset of the options field in a dhcp packet starting a=
t
  * the beginning of the dhcp header
  */
-#define DHCP_OPTIONS_OFFSET 240
-#define DHCP_REQUEST 3
+#define BATADV_DHCP_OPTIONS_OFFSET 240
+#define BATADV_DHCP_REQUEST 3
=20
 static void batadv_gw_node_free_ref(struct gw_node *gw_node)
 {
@@ -521,11 +521,11 @@ static bool batadv_is_type_dhcprequest(struct sk_=
buff *skb, int header_len)
=20
 	pkt_len =3D skb_headlen(skb);
=20
-	if (pkt_len < header_len + DHCP_OPTIONS_OFFSET + 1)
+	if (pkt_len < header_len + BATADV_DHCP_OPTIONS_OFFSET + 1)
 		goto out;
=20
-	p =3D skb->data + header_len + DHCP_OPTIONS_OFFSET;
-	pkt_len -=3D header_len + DHCP_OPTIONS_OFFSET + 1;
+	p =3D skb->data + header_len + BATADV_DHCP_OPTIONS_OFFSET;
+	pkt_len -=3D header_len + BATADV_DHCP_OPTIONS_OFFSET + 1;
=20
 	/* Access the dhcp option lists. Each entry is made up by:
 	 * - octet 1: option type
@@ -543,7 +543,7 @@ static bool batadv_is_type_dhcprequest(struct sk_bu=
ff *skb, int header_len)
 			p +=3D 2;
=20
 			/* check if the message type is what we need */
-			if (*p =3D=3D DHCP_REQUEST)
+			if (*p =3D=3D BATADV_DHCP_REQUEST)
 				ret =3D true;
 			break;
 		} else if (*p =3D=3D 0) {
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 3095c41..7dc7506 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -26,7 +26,7 @@
 #include "hash.h"
 #include "originator.h"
=20
-#define MAX_VIS_PACKET_SIZE 1000
+#define BATADV_MAX_VIS_PACKET_SIZE 1000
=20
 static void batadv_start_vis_timer(struct bat_priv *bat_priv);
=20
@@ -544,10 +544,12 @@ static int batadv_find_best_vis_server(struct bat=
_priv *bat_priv,
 static bool batadv_vis_packet_full(const struct vis_info *info)
 {
 	const struct vis_packet *packet;
+	size_t num_items;
+
 	packet =3D (struct vis_packet *)info->skb_packet->data;
+	num_items =3D BATADV_MAX_VIS_PACKET_SIZE / sizeof(struct vis_info_ent=
ry);
=20
-	if (MAX_VIS_PACKET_SIZE / sizeof(struct vis_info_entry)
-		< packet->entries + 1)
+	if (num_items < packet->entries + 1)
 		return true;
 	return false;
 }
@@ -838,6 +840,7 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 {
 	struct vis_packet *packet;
 	int hash_added;
+	unsigned int len;
=20
 	if (bat_priv->vis_hash)
 		return 0;
@@ -850,13 +853,12 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 		goto err;
 	}
=20
-	bat_priv->my_vis_info =3D kmalloc(MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
+	bat_priv->my_vis_info =3D kmalloc(BATADV_MAX_VIS_PACKET_SIZE, GFP_ATO=
MIC);
 	if (!bat_priv->my_vis_info)
 		goto err;
=20
-	bat_priv->my_vis_info->skb_packet =3D dev_alloc_skb(sizeof(*packet) +
-							  MAX_VIS_PACKET_SIZE +
-							  ETH_HLEN);
+	len =3D sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE + ETH_HLEN;
+	bat_priv->my_vis_info->skb_packet =3D dev_alloc_skb(len);
 	if (!bat_priv->my_vis_info->skb_packet)
 		goto free_info;
=20
--=20
1.7.9.4
