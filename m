From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 03/20] batman-adv: Prefix bat_sysfs
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:39 +0200
Message-ID: <1340297876-29923-4-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_sysfs.c      |   12 ++++++------
 net/batman-adv/bat_sysfs.h      |   13 +++++++------
 net/batman-adv/gateway_client.c |    6 +++---
 net/batman-adv/hard-interface.c |    4 ++--
 net/batman-adv/soft-interface.c |    6 +++---
 5 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index dc1edbe..5dce1ab 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -469,7 +469,7 @@ static struct bat_attribute *mesh_attrs[] = {
 	NULL,
 };
 
-int sysfs_add_meshif(struct net_device *dev)
+int batadv_sysfs_add_meshif(struct net_device *dev)
 {
 	struct kobject *batif_kobject = &dev->dev.kobj;
 	struct bat_priv *bat_priv = netdev_priv(dev);
@@ -507,7 +507,7 @@ out:
 	return -ENOMEM;
 }
 
-void sysfs_del_meshif(struct net_device *dev)
+void batadv_sysfs_del_meshif(struct net_device *dev)
 {
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	struct bat_attribute **bat_attr;
@@ -637,7 +637,7 @@ static struct bat_attribute *batman_attrs[] = {
 	NULL,
 };
 
-int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
+int batadv_sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
 {
 	struct kobject *hardif_kobject = &dev->dev.kobj;
 	struct bat_attribute **bat_attr;
@@ -671,14 +671,14 @@ out:
 	return -ENOMEM;
 }
 
-void sysfs_del_hardif(struct kobject **hardif_obj)
+void batadv_sysfs_del_hardif(struct kobject **hardif_obj)
 {
 	kobject_put(*hardif_obj);
 	*hardif_obj = NULL;
 }
 
-int throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
-		 enum uev_action action, const char *data)
+int batadv_throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
+			enum uev_action action, const char *data)
 {
 	int ret = -ENOMEM;
 	struct hard_iface *primary_if = NULL;
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index fece77a..f01aea8 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -34,11 +34,12 @@ struct bat_attribute {
 			 char *buf, size_t count);
 };
 
-int sysfs_add_meshif(struct net_device *dev);
-void sysfs_del_meshif(struct net_device *dev);
-int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev);
-void sysfs_del_hardif(struct kobject **hardif_obj);
-int throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
-		 enum uev_action action, const char *data);
+int batadv_sysfs_add_meshif(struct net_device *dev);
+void batadv_sysfs_del_meshif(struct net_device *dev);
+int batadv_sysfs_add_hardif(struct kobject **hardif_obj,
+			    struct net_device *dev);
+void batadv_sysfs_del_hardif(struct kobject **hardif_obj);
+int batadv_throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
+			enum uev_action action, const char *data);
 
 #endif /* _NET_BATMAN_ADV_SYSFS_H_ */
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 47f7186..1d7f08e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -220,19 +220,19 @@ void gw_election(struct bat_priv *bat_priv)
 	if ((curr_gw) && (!next_gw)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Removing selected gateway - no gateway in range\n");
-		throw_uevent(bat_priv, UEV_GW, UEV_DEL, NULL);
+		batadv_throw_uevent(bat_priv, UEV_GW, UEV_DEL, NULL);
 	} else if ((!curr_gw) && (next_gw)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
 			next_gw->orig_node->orig, next_gw->orig_node->gw_flags,
 			router->tq_avg);
-		throw_uevent(bat_priv, UEV_GW, UEV_ADD, gw_addr);
+		batadv_throw_uevent(bat_priv, UEV_GW, UEV_ADD, gw_addr);
 	} else {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Changing route to gateway %pM (gw_flags: %i, tq: %i)\n",
 			next_gw->orig_node->orig, next_gw->orig_node->gw_flags,
 			router->tq_avg);
-		throw_uevent(bat_priv, UEV_GW, UEV_CHANGE, gw_addr);
+		batadv_throw_uevent(bat_priv, UEV_GW, UEV_CHANGE, gw_addr);
 	}
 
 	gw_select(bat_priv, next_gw);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index ce78c6d..380572e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -423,7 +423,7 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 	if (!hard_iface)
 		goto release_dev;
 
-	ret = sysfs_add_hardif(&hard_iface->hardif_obj, net_dev);
+	ret = batadv_sysfs_add_hardif(&hard_iface->hardif_obj, net_dev);
 	if (ret)
 		goto free_if;
 
@@ -467,7 +467,7 @@ static void hardif_remove_interface(struct hard_iface *hard_iface)
 		return;
 
 	hard_iface->if_status = IF_TO_BE_REMOVED;
-	sysfs_del_hardif(&hard_iface->hardif_obj);
+	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
 	hardif_free_ref(hard_iface);
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 0f0003b..11bfe53 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -415,7 +415,7 @@ struct net_device *softif_create(const char *name)
 	if (ret < 0)
 		goto free_bat_counters;
 
-	ret = sysfs_add_meshif(soft_iface);
+	ret = batadv_sysfs_add_meshif(soft_iface);
 	if (ret < 0)
 		goto free_bat_counters;
 
@@ -432,7 +432,7 @@ struct net_device *softif_create(const char *name)
 unreg_debugfs:
 	batadv_debugfs_del_meshif(soft_iface);
 unreg_sysfs:
-	sysfs_del_meshif(soft_iface);
+	batadv_sysfs_del_meshif(soft_iface);
 free_bat_counters:
 	free_percpu(bat_priv->bat_counters);
 unreg_soft_iface:
@@ -448,7 +448,7 @@ out:
 void softif_destroy(struct net_device *soft_iface)
 {
 	batadv_debugfs_del_meshif(soft_iface);
-	sysfs_del_meshif(soft_iface);
+	batadv_sysfs_del_meshif(soft_iface);
 	mesh_free(soft_iface);
 	unregister_netdevice(soft_iface);
 }
-- 
1.7.9.4
