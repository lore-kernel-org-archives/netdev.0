From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 02/16] batman-adv: Prefix hard-interface enum
	with BATADV_
Date: Mon,  2 Jul 2012 01:43:32 +0200
Message-ID: <1341186226-10549-3-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1341186226-10549-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

Reported-by: Martin Hundeb=C3=B8ll <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c            |    6 ++---
 net/batman-adv/bat_sysfs.c             |   27 ++++++++++++---------
 net/batman-adv/bridge_loop_avoidance.c |    2 +-
 net/batman-adv/gateway_client.c        |    2 +-
 net/batman-adv/hard-interface.c        |   40 ++++++++++++++++----------=
------
 net/batman-adv/hard-interface.h        |   14 +++++------
 net/batman-adv/icmp_socket.c           |    2 +-
 net/batman-adv/main.c                  |    4 ++--
 net/batman-adv/originator.c            |   16 ++++++-------
 net/batman-adv/routing.c               |    2 +-
 net/batman-adv/send.c                  |   10 ++++----
 net/batman-adv/translation-table.c     |    4 ++--
 net/batman-adv/vis.c                   |    2 +-
 13 files changed, 68 insertions(+), 63 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index d3fc581..a59e317 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -165,7 +165,7 @@ static void batadv_iv_ogm_send_to_if(struct forw_pack=
et *forw_packet,
 	struct batman_ogm_packet *batman_ogm_packet;
 	struct sk_buff *skb;
=20
-	if (hard_iface->if_status !=3D IF_ACTIVE)
+	if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
 		return;
=20
 	packet_num =3D 0;
@@ -238,7 +238,7 @@ static void batadv_iv_ogm_emit(struct forw_packet *fo=
rw_packet)
 	soft_iface =3D forw_packet->if_incoming->soft_iface;
 	bat_priv =3D netdev_priv(soft_iface);
=20
-	if (forw_packet->if_incoming->if_status !=3D IF_ACTIVE)
+	if (forw_packet->if_incoming->if_status !=3D BATADV_IF_ACTIVE)
 		goto out;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -1017,7 +1017,7 @@ static void batadv_iv_ogm_process(const struct ethh=
dr *ethhdr,
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if (hard_iface->if_status !=3D IF_ACTIVE)
+		if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
 			continue;
=20
 		if (hard_iface->soft_iface !=3D if_incoming->soft_iface)
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 561ec31..680caca 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -559,12 +559,17 @@ static ssize_t batadv_show_mesh_iface(struct kobjec=
t *kobj,
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);
 	struct hard_iface *hard_iface =3D batadv_hardif_get_by_netdev(net_dev);
 	ssize_t length;
+	const char *ifname;
=20
 	if (!hard_iface)
 		return 0;
=20
-	length =3D sprintf(buff, "%s\n", hard_iface->if_status =3D=3D IF_NOT_IN=
_USE ?
-			 "none" : hard_iface->soft_iface->name);
+	if (hard_iface->if_status =3D=3D BATADV_IF_NOT_IN_USE)
+		ifname =3D  "none";
+	else
+		ifname =3D hard_iface->soft_iface->name;
+
+	length =3D sprintf(buff, "%s\n", ifname);
=20
 	batadv_hardif_free_ref(hard_iface);
=20
@@ -594,9 +599,9 @@ static ssize_t batadv_store_mesh_iface(struct kobject=
 *kobj,
 	}
=20
 	if (strncmp(buff, "none", 4) =3D=3D 0)
-		status_tmp =3D IF_NOT_IN_USE;
+		status_tmp =3D BATADV_IF_NOT_IN_USE;
 	else
-		status_tmp =3D IF_I_WANT_YOU;
+		status_tmp =3D BATADV_IF_I_WANT_YOU;
=20
 	if (hard_iface->if_status =3D=3D status_tmp)
 		goto out;
@@ -610,13 +615,13 @@ static ssize_t batadv_store_mesh_iface(struct kobje=
ct *kobj,
 		goto out;
 	}
=20
-	if (status_tmp =3D=3D IF_NOT_IN_USE) {
+	if (status_tmp =3D=3D BATADV_IF_NOT_IN_USE) {
 		batadv_hardif_disable_interface(hard_iface);
 		goto unlock;
 	}
=20
 	/* if the interface already is in use */
-	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
+	if (hard_iface->if_status !=3D BATADV_IF_NOT_IN_USE)
 		batadv_hardif_disable_interface(hard_iface);
=20
 	ret =3D batadv_hardif_enable_interface(hard_iface, buff);
@@ -639,19 +644,19 @@ static ssize_t batadv_show_iface_status(struct kobj=
ect *kobj,
 		return 0;
=20
 	switch (hard_iface->if_status) {
-	case IF_TO_BE_REMOVED:
+	case BATADV_IF_TO_BE_REMOVED:
 		length =3D sprintf(buff, "disabling\n");
 		break;
-	case IF_INACTIVE:
+	case BATADV_IF_INACTIVE:
 		length =3D sprintf(buff, "inactive\n");
 		break;
-	case IF_ACTIVE:
+	case BATADV_IF_ACTIVE:
 		length =3D sprintf(buff, "active\n");
 		break;
-	case IF_TO_BE_ACTIVATED:
+	case BATADV_IF_TO_BE_ACTIVATED:
 		length =3D sprintf(buff, "enabling\n");
 		break;
-	case IF_NOT_IN_USE:
+	case BATADV_IF_NOT_IN_USE:
 	default:
 		length =3D sprintf(buff, "not in use\n");
 		break;
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/brid=
ge_loop_avoidance.c
index db20b68..13afc65 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1552,7 +1552,7 @@ int batadv_bla_claim_table_seq_print_text(struct se=
q_file *seq, void *offset)
 		goto out;
 	}
=20
-	if (primary_if->if_status !=3D IF_ACTIVE) {
+	if (primary_if->if_status !=3D BATADV_IF_ACTIVE) {
 		ret =3D seq_printf(seq,
 				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_cli=
ent.c
index 2fcf26f..3b50c31 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -475,7 +475,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *=
seq, void *offset)
 		goto out;
 	}
=20
-	if (primary_if->if_status !=3D IF_ACTIVE) {
+	if (primary_if->if_status !=3D BATADV_IF_ACTIVE) {
 		ret =3D seq_printf(seq,
 				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interf=
ace.c
index e7eba9c..e109d65 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -85,7 +85,7 @@ batadv_hardif_get_active(const struct net_device *soft_=
iface)
 		if (hard_iface->soft_iface !=3D soft_iface)
 			continue;
=20
-		if (hard_iface->if_status =3D=3D IF_ACTIVE &&
+		if (hard_iface->if_status =3D=3D BATADV_IF_ACTIVE &&
 		    atomic_inc_not_zero(&hard_iface->refcount))
 			goto out;
 	}
@@ -157,8 +157,8 @@ static void batadv_check_known_mac_addr(const struct =
net_device *net_dev)
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if ((hard_iface->if_status !=3D IF_ACTIVE) &&
-		    (hard_iface->if_status !=3D IF_TO_BE_ACTIVATED))
+		if ((hard_iface->if_status !=3D BATADV_IF_ACTIVE) &&
+		    (hard_iface->if_status !=3D BATADV_IF_TO_BE_ACTIVATED))
 			continue;
=20
 		if (hard_iface->net_dev =3D=3D net_dev)
@@ -189,8 +189,8 @@ int batadv_hardif_min_mtu(struct net_device *soft_ifa=
ce)
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if ((hard_iface->if_status !=3D IF_ACTIVE) &&
-		    (hard_iface->if_status !=3D IF_TO_BE_ACTIVATED))
+		if ((hard_iface->if_status !=3D BATADV_IF_ACTIVE) &&
+		    (hard_iface->if_status !=3D BATADV_IF_TO_BE_ACTIVATED))
 			continue;
=20
 		if (hard_iface->soft_iface !=3D soft_iface)
@@ -220,13 +220,13 @@ static void batadv_hardif_activate_interface(struct=
 hard_iface *hard_iface)
 	struct bat_priv *bat_priv;
 	struct hard_iface *primary_if =3D NULL;
=20
-	if (hard_iface->if_status !=3D IF_INACTIVE)
+	if (hard_iface->if_status !=3D BATADV_IF_INACTIVE)
 		goto out;
=20
 	bat_priv =3D netdev_priv(hard_iface->soft_iface);
=20
 	bat_priv->bat_algo_ops->bat_iface_update_mac(hard_iface);
-	hard_iface->if_status =3D IF_TO_BE_ACTIVATED;
+	hard_iface->if_status =3D BATADV_IF_TO_BE_ACTIVATED;
=20
 	/* the first active interface becomes our primary interface or
 	 * the next active interface after the old primary interface was remove=
d
@@ -247,11 +247,11 @@ out:
=20
 static void batadv_hardif_deactivate_interface(struct hard_iface *hard_i=
face)
 {
-	if ((hard_iface->if_status !=3D IF_ACTIVE) &&
-	    (hard_iface->if_status !=3D IF_TO_BE_ACTIVATED))
+	if ((hard_iface->if_status !=3D BATADV_IF_ACTIVE) &&
+	    (hard_iface->if_status !=3D BATADV_IF_TO_BE_ACTIVATED))
 		return;
=20
-	hard_iface->if_status =3D IF_INACTIVE;
+	hard_iface->if_status =3D BATADV_IF_INACTIVE;
=20
 	batadv_info(hard_iface->soft_iface, "Interface deactivated: %s\n",
 		    hard_iface->net_dev->name);
@@ -267,7 +267,7 @@ int batadv_hardif_enable_interface(struct hard_iface =
*hard_iface,
 	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
 	int ret;
=20
-	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
+	if (hard_iface->if_status !=3D BATADV_IF_NOT_IN_USE)
 		goto out;
=20
 	if (!atomic_inc_not_zero(&hard_iface->refcount))
@@ -308,7 +308,7 @@ int batadv_hardif_enable_interface(struct hard_iface =
*hard_iface,
=20
 	hard_iface->if_num =3D bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
-	hard_iface->if_status =3D IF_INACTIVE;
+	hard_iface->if_status =3D BATADV_IF_INACTIVE;
 	batadv_orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
=20
 	hard_iface->batman_adv_ptype.type =3D ethertype;
@@ -359,10 +359,10 @@ void batadv_hardif_disable_interface(struct hard_if=
ace *hard_iface)
 	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	struct hard_iface *primary_if =3D NULL;
=20
-	if (hard_iface->if_status =3D=3D IF_ACTIVE)
+	if (hard_iface->if_status =3D=3D BATADV_IF_ACTIVE)
 		batadv_hardif_deactivate_interface(hard_iface);
=20
-	if (hard_iface->if_status !=3D IF_INACTIVE)
+	if (hard_iface->if_status !=3D BATADV_IF_INACTIVE)
 		goto out;
=20
 	batadv_info(hard_iface->soft_iface, "Removing interface: %s\n",
@@ -384,7 +384,7 @@ void batadv_hardif_disable_interface(struct hard_ifac=
e *hard_iface)
 	}
=20
 	bat_priv->bat_algo_ops->bat_iface_disable(hard_iface);
-	hard_iface->if_status =3D IF_NOT_IN_USE;
+	hard_iface->if_status =3D BATADV_IF_NOT_IN_USE;
=20
 	/* delete all references to this hard_iface */
 	batadv_purge_orig_ref(bat_priv);
@@ -428,7 +428,7 @@ batadv_hardif_add_interface(struct net_device *net_de=
v)
 	hard_iface->if_num =3D -1;
 	hard_iface->net_dev =3D net_dev;
 	hard_iface->soft_iface =3D NULL;
-	hard_iface->if_status =3D IF_NOT_IN_USE;
+	hard_iface->if_status =3D BATADV_IF_NOT_IN_USE;
 	INIT_LIST_HEAD(&hard_iface->list);
 	/* extra reference for return */
 	atomic_set(&hard_iface->refcount, 2);
@@ -457,13 +457,13 @@ static void batadv_hardif_remove_interface(struct h=
ard_iface *hard_iface)
 	ASSERT_RTNL();
=20
 	/* first deactivate interface */
-	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
+	if (hard_iface->if_status !=3D BATADV_IF_NOT_IN_USE)
 		batadv_hardif_disable_interface(hard_iface);
=20
-	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
+	if (hard_iface->if_status !=3D BATADV_IF_NOT_IN_USE)
 		return;
=20
-	hard_iface->if_status =3D IF_TO_BE_REMOVED;
+	hard_iface->if_status =3D BATADV_IF_TO_BE_REMOVED;
 	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
 	batadv_hardif_free_ref(hard_iface);
 }
@@ -513,7 +513,7 @@ static int batadv_hard_if_event(struct notifier_block=
 *this,
 			batadv_update_min_mtu(hard_iface->soft_iface);
 		break;
 	case NETDEV_CHANGEADDR:
-		if (hard_iface->if_status =3D=3D IF_NOT_IN_USE)
+		if (hard_iface->if_status =3D=3D BATADV_IF_NOT_IN_USE)
 			goto hardif_put;
=20
 		batadv_check_known_mac_addr(hard_iface->net_dev);
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interf=
ace.h
index d66dabd..4b60d58 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -20,13 +20,13 @@
 #ifndef _NET_BATMAN_ADV_HARD_INTERFACE_H_
 #define _NET_BATMAN_ADV_HARD_INTERFACE_H_
=20
-enum hard_if_state {
-	IF_NOT_IN_USE,
-	IF_TO_BE_REMOVED,
-	IF_INACTIVE,
-	IF_ACTIVE,
-	IF_TO_BE_ACTIVATED,
-	IF_I_WANT_YOU
+enum batadv_hard_if_state {
+	BATADV_IF_NOT_IN_USE,
+	BATADV_IF_TO_BE_REMOVED,
+	BATADV_IF_INACTIVE,
+	BATADV_IF_ACTIVE,
+	BATADV_IF_TO_BE_ACTIVATED,
+	BATADV_IF_I_WANT_YOU,
 };
=20
 extern struct notifier_block batadv_hard_if_notifier;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index f2f578b..f5373a2 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -225,7 +225,7 @@ static ssize_t batadv_socket_write(struct file *file,=
 const char __user *buff,
 	if (!neigh_node->if_incoming)
 		goto dst_unreach;
=20
-	if (neigh_node->if_incoming->if_status !=3D IF_ACTIVE)
+	if (neigh_node->if_incoming->if_status !=3D BATADV_IF_ACTIVE)
 		goto dst_unreach;
=20
 	memcpy(icmp_packet->orig,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index df7335c..23f5c8e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -179,7 +179,7 @@ int batadv_is_my_mac(const uint8_t *addr)
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if (hard_iface->if_status !=3D IF_ACTIVE)
+		if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
 			continue;
=20
 		if (batadv_compare_eth(hard_iface->net_dev->dev_addr, addr)) {
@@ -234,7 +234,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struc=
t net_device *dev,
 		goto err_free;
=20
 	/* discard frames on not active interfaces */
-	if (hard_iface->if_status !=3D IF_ACTIVE)
+	if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
 		goto err_free;
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)skb->data;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f04f591..9e60cc0 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -286,13 +286,13 @@ static bool batadv_purge_orig_neighbors(struct bat_=
priv *bat_priv,
 		if_incoming =3D neigh_node->if_incoming;
=20
 		if ((batadv_has_timed_out(last_seen, BATADV_PURGE_TIMEOUT)) ||
-		    (if_incoming->if_status =3D=3D IF_INACTIVE) ||
-		    (if_incoming->if_status =3D=3D IF_NOT_IN_USE) ||
-		    (if_incoming->if_status =3D=3D IF_TO_BE_REMOVED)) {
+		    (if_incoming->if_status =3D=3D BATADV_IF_INACTIVE) ||
+		    (if_incoming->if_status =3D=3D BATADV_IF_NOT_IN_USE) ||
+		    (if_incoming->if_status =3D=3D BATADV_IF_TO_BE_REMOVED)) {
=20
-			if ((if_incoming->if_status =3D=3D IF_INACTIVE) ||
-			    (if_incoming->if_status =3D=3D IF_NOT_IN_USE) ||
-			    (if_incoming->if_status =3D=3D IF_TO_BE_REMOVED))
+			if ((if_incoming->if_status =3D=3D BATADV_IF_INACTIVE) ||
+			    (if_incoming->if_status =3D=3D BATADV_IF_NOT_IN_USE) ||
+			    (if_incoming->if_status =3D=3D BATADV_IF_TO_BE_REMOVED))
 				batadv_dbg(DBG_BATMAN, bat_priv,
 					   "neighbor purge: originator %pM, neighbor: %pM, iface: %s\n",
 					   orig_node->orig, neigh_node->addr,
@@ -422,7 +422,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, =
void *offset)
 		goto out;
 	}
=20
-	if (primary_if->if_status !=3D IF_ACTIVE) {
+	if (primary_if->if_status !=3D BATADV_IF_ACTIVE) {
 		ret =3D seq_printf(seq,
 				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
@@ -627,7 +627,7 @@ int batadv_orig_hash_del_if(struct hard_iface *hard_i=
face, int max_if_num)
 	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface_tmp, &batadv_hardif_list, list) {
-		if (hard_iface_tmp->if_status =3D=3D IF_NOT_IN_USE)
+		if (hard_iface_tmp->if_status =3D=3D BATADV_IF_NOT_IN_USE)
 			continue;
=20
 		if (hard_iface =3D=3D hard_iface_tmp)
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b3fd61c..4d63221 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -792,7 +792,7 @@ struct neigh_node *batadv_find_router(struct bat_priv=
 *bat_priv,
 		router =3D batadv_find_ifalter_router(primary_orig_node, recv_if);
=20
 return_router:
-	if (router && router->if_incoming->if_status !=3D IF_ACTIVE)
+	if (router && router->if_incoming->if_status !=3D BATADV_IF_ACTIVE)
 		goto err_unlock;
=20
 	rcu_read_unlock();
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 72542cb..8de6e25 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -37,7 +37,7 @@ int batadv_send_skb_packet(struct sk_buff *skb, struct =
hard_iface *hard_iface,
 {
 	struct ethhdr *ethhdr;
=20
-	if (hard_iface->if_status !=3D IF_ACTIVE)
+	if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
 		goto send_skb_err;
=20
 	if (unlikely(!hard_iface->net_dev))
@@ -80,8 +80,8 @@ void batadv_schedule_bat_ogm(struct hard_iface *hard_if=
ace)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
=20
-	if ((hard_iface->if_status =3D=3D IF_NOT_IN_USE) ||
-	    (hard_iface->if_status =3D=3D IF_TO_BE_REMOVED))
+	if ((hard_iface->if_status =3D=3D BATADV_IF_NOT_IN_USE) ||
+	    (hard_iface->if_status =3D=3D BATADV_IF_TO_BE_REMOVED))
 		return;
=20
 	/* the interface gets activated here to avoid race conditions between
@@ -90,8 +90,8 @@ void batadv_schedule_bat_ogm(struct hard_iface *hard_if=
ace)
 	 * outdated packets (especially uninitialized mac addresses) in the
 	 * packet queue
 	 */
-	if (hard_iface->if_status =3D=3D IF_TO_BE_ACTIVATED)
-		hard_iface->if_status =3D IF_ACTIVE;
+	if (hard_iface->if_status =3D=3D BATADV_IF_TO_BE_ACTIVATED)
+		hard_iface->if_status =3D BATADV_IF_ACTIVE;
=20
 	bat_priv->bat_algo_ops->bat_ogm_schedule(hard_iface);
 }
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translat=
ion-table.c
index a0487e9..156c309 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -433,7 +433,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *s=
eq, void *offset)
 		goto out;
 	}
=20
-	if (primary_if->if_status !=3D IF_ACTIVE) {
+	if (primary_if->if_status !=3D BATADV_IF_ACTIVE) {
 		ret =3D seq_printf(seq,
 				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
@@ -785,7 +785,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *=
seq, void *offset)
 		goto out;
 	}
=20
-	if (primary_if->if_status !=3D IF_ACTIVE) {
+	if (primary_if->if_status !=3D BATADV_IF_ACTIVE) {
 		ret =3D seq_printf(seq,
 				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 7418169..c920b4b 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -599,7 +599,7 @@ static int batadv_generate_vis_packet(struct bat_priv=
 *bat_priv)
 			if (!batadv_compare_eth(router->addr, orig_node->orig))
 				goto next;
=20
-			if (router->if_incoming->if_status !=3D IF_ACTIVE)
+			if (router->if_incoming->if_status !=3D BATADV_IF_ACTIVE)
 				goto next;
=20
 			if (router->tq_avg < 1)
--=20
1.7.9.4
