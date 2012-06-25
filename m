From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/20] batman-adv: Prefix hard-interface local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:37 +0200
Message-ID: <1340607284-29950-14-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30461 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab2FYGyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:49 -0400
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
 net/batman-adv/hard-interface.c |   64 ++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 6131d93..c22c145 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -57,7 +57,7 @@ out:
 	return hard_iface;
 }
 
-static int is_valid_iface(const struct net_device *net_dev)
+static int batadv_is_valid_iface(const struct net_device *net_dev)
 {
 	if (net_dev->flags & IFF_LOOPBACK)
 		return 0;
@@ -75,7 +75,8 @@ static int is_valid_iface(const struct net_device *net_dev)
 	return 1;
 }
 
-static struct hard_iface *hardif_get_active(const struct net_device *soft_iface)
+static struct hard_iface *
+batadv_hardif_get_active(const struct net_device *soft_iface)
 {
 	struct hard_iface *hard_iface;
 
@@ -96,8 +97,8 @@ out:
 	return hard_iface;
 }
 
-static void primary_if_update_addr(struct bat_priv *bat_priv,
-				   struct hard_iface *oldif)
+static void batadv_primary_if_update_addr(struct bat_priv *bat_priv,
+					  struct hard_iface *oldif)
 {
 	struct vis_packet *vis_packet;
 	struct hard_iface *primary_if;
@@ -118,8 +119,8 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
 
-static void primary_if_select(struct bat_priv *bat_priv,
-			      struct hard_iface *new_hard_iface)
+static void batadv_primary_if_select(struct bat_priv *bat_priv,
+				     struct hard_iface *new_hard_iface)
 {
 	struct hard_iface *curr_hard_iface;
 
@@ -135,14 +136,14 @@ static void primary_if_select(struct bat_priv *bat_priv,
 		goto out;
 
 	bat_priv->bat_algo_ops->bat_primary_iface_set(new_hard_iface);
-	primary_if_update_addr(bat_priv, curr_hard_iface);
+	batadv_primary_if_update_addr(bat_priv, curr_hard_iface);
 
 out:
 	if (curr_hard_iface)
 		batadv_hardif_free_ref(curr_hard_iface);
 }
 
-static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
+static bool batadv_hardif_is_iface_up(const struct hard_iface *hard_iface)
 {
 	if (hard_iface->net_dev->flags & IFF_UP)
 		return true;
@@ -150,7 +151,7 @@ static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
 	return false;
 }
 
-static void check_known_mac_addr(const struct net_device *net_dev)
+static void batadv_check_known_mac_addr(const struct net_device *net_dev)
 {
 	const struct hard_iface *hard_iface;
 
@@ -213,7 +214,7 @@ void batadv_update_min_mtu(struct net_device *soft_iface)
 		soft_iface->mtu = min_mtu;
 }
 
-static void hardif_activate_interface(struct hard_iface *hard_iface)
+static void batadv_hardif_activate_interface(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv;
 	struct hard_iface *primary_if = NULL;
@@ -231,7 +232,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 	 */
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		primary_if_select(bat_priv, hard_iface);
+		batadv_primary_if_select(bat_priv, hard_iface);
 
 	bat_info(hard_iface->soft_iface, "Interface activated: %s\n",
 		 hard_iface->net_dev->name);
@@ -243,7 +244,7 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
 
-static void hardif_deactivate_interface(struct hard_iface *hard_iface)
+static void batadv_hardif_deactivate_interface(struct hard_iface *hard_iface)
 {
 	if ((hard_iface->if_status != IF_ACTIVE) &&
 	    (hard_iface->if_status != IF_TO_BE_ACTIVATED))
@@ -331,8 +332,8 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
 			 ETH_DATA_LEN + BAT_HEADER_LEN);
 
-	if (hardif_is_iface_up(hard_iface))
-		hardif_activate_interface(hard_iface);
+	if (batadv_hardif_is_iface_up(hard_iface))
+		batadv_hardif_activate_interface(hard_iface);
 	else
 		bat_err(hard_iface->soft_iface,
 			"Not using interface %s (retrying later): interface not active\n",
@@ -357,7 +358,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 	struct hard_iface *primary_if = NULL;
 
 	if (hard_iface->if_status == IF_ACTIVE)
-		hardif_deactivate_interface(hard_iface);
+		batadv_hardif_deactivate_interface(hard_iface);
 
 	if (hard_iface->if_status != IF_INACTIVE)
 		goto out;
@@ -373,8 +374,8 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 	if (hard_iface == primary_if) {
 		struct hard_iface *new_if;
 
-		new_if = hardif_get_active(hard_iface->soft_iface);
-		primary_if_select(bat_priv, new_if);
+		new_if = batadv_hardif_get_active(hard_iface->soft_iface);
+		batadv_primary_if_select(bat_priv, new_if);
 
 		if (new_if)
 			batadv_hardif_free_ref(new_if);
@@ -400,14 +401,15 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
 
-static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
+static struct hard_iface *
+batadv_hardif_add_interface(struct net_device *net_dev)
 {
 	struct hard_iface *hard_iface;
 	int ret;
 
 	ASSERT_RTNL();
 
-	ret = is_valid_iface(net_dev);
+	ret = batadv_is_valid_iface(net_dev);
 	if (ret != 1)
 		goto out;
 
@@ -429,7 +431,7 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 	/* extra reference for return */
 	atomic_set(&hard_iface->refcount, 2);
 
-	check_known_mac_addr(hard_iface->net_dev);
+	batadv_check_known_mac_addr(hard_iface->net_dev);
 	list_add_tail_rcu(&hard_iface->list, &batadv_hardif_list);
 
 	/* This can't be called via a bat_priv callback because
@@ -448,7 +450,7 @@ out:
 	return NULL;
 }
 
-static void hardif_remove_interface(struct hard_iface *hard_iface)
+static void batadv_hardif_remove_interface(struct hard_iface *hard_iface)
 {
 	ASSERT_RTNL();
 
@@ -472,13 +474,13 @@ void batadv_hardif_remove_interfaces(void)
 	list_for_each_entry_safe(hard_iface, hard_iface_tmp,
 				 &batadv_hardif_list, list) {
 		list_del_rcu(&hard_iface->list);
-		hardif_remove_interface(hard_iface);
+		batadv_hardif_remove_interface(hard_iface);
 	}
 	rtnl_unlock();
 }
 
-static int hard_if_event(struct notifier_block *this,
-			 unsigned long event, void *ptr)
+static int batadv_hard_if_event(struct notifier_block *this,
+				unsigned long event, void *ptr)
 {
 	struct net_device *net_dev = ptr;
 	struct hard_iface *hard_iface = batadv_hardif_get_by_netdev(net_dev);
@@ -486,23 +488,23 @@ static int hard_if_event(struct notifier_block *this,
 	struct bat_priv *bat_priv;
 
 	if (!hard_iface && event == NETDEV_REGISTER)
-		hard_iface = hardif_add_interface(net_dev);
+		hard_iface = batadv_hardif_add_interface(net_dev);
 
 	if (!hard_iface)
 		goto out;
 
 	switch (event) {
 	case NETDEV_UP:
-		hardif_activate_interface(hard_iface);
+		batadv_hardif_activate_interface(hard_iface);
 		break;
 	case NETDEV_GOING_DOWN:
 	case NETDEV_DOWN:
-		hardif_deactivate_interface(hard_iface);
+		batadv_hardif_deactivate_interface(hard_iface);
 		break;
 	case NETDEV_UNREGISTER:
 		list_del_rcu(&hard_iface->list);
 
-		hardif_remove_interface(hard_iface);
+		batadv_hardif_remove_interface(hard_iface);
 		break;
 	case NETDEV_CHANGEMTU:
 		if (hard_iface->soft_iface)
@@ -512,7 +514,7 @@ static int hard_if_event(struct notifier_block *this,
 		if (hard_iface->if_status == IF_NOT_IN_USE)
 			goto hardif_put;
 
-		check_known_mac_addr(hard_iface->net_dev);
+		batadv_check_known_mac_addr(hard_iface->net_dev);
 
 		bat_priv = netdev_priv(hard_iface->soft_iface);
 		bat_priv->bat_algo_ops->bat_iface_update_mac(hard_iface);
@@ -522,7 +524,7 @@ static int hard_if_event(struct notifier_block *this,
 			goto hardif_put;
 
 		if (hard_iface == primary_if)
-			primary_if_update_addr(bat_priv, NULL);
+			batadv_primary_if_update_addr(bat_priv, NULL);
 		break;
 	default:
 		break;
@@ -569,5 +571,5 @@ out:
 }
 
 struct notifier_block batadv_hard_if_notifier = {
-	.notifier_call = hard_if_event,
+	.notifier_call = batadv_hard_if_event,
 };
-- 
1.7.9.4
