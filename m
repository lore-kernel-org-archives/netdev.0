From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 01/16] batman-adv: Prefix gateway enum with
	BATADV_
Date: Mon,  2 Jul 2012 01:43:31 +0200
Message-ID: <1341186226-10549-2-git-send-email-ordex@autistici.org>
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
 net/batman-adv/bat_iv_ogm.c     |    4 ++--
 net/batman-adv/bat_sysfs.c      |   14 +++++++-------
 net/batman-adv/gateway_client.c |    8 ++++----
 net/batman-adv/gateway_common.h |    8 ++++----
 net/batman-adv/soft-interface.c |   10 +++++-----
 5 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index bbe0f12..d3fc581 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -611,7 +611,7 @@ static void batadv_iv_ogm_schedule(struct hard_iface =
*hard_iface)
 		batman_ogm_packet->flags &=3D ~VIS_SERVER;
=20
 	if ((hard_iface =3D=3D primary_if) &&
-	    (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_SERVER))
+	    (atomic_read(&bat_priv->gw_mode) =3D=3D BATADV_GW_MODE_SERVER))
 		batman_ogm_packet->gw_flags =3D
 				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
 	else
@@ -760,7 +760,7 @@ update_tt:
=20
 	/* restart gateway selection if fast or late switching was enabled */
 	if ((orig_node->gw_flags) &&
-	    (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_CLIENT) &&
+	    (atomic_read(&bat_priv->gw_mode) =3D=3D BATADV_GW_MODE_CLIENT) &&
 	    (atomic_read(&bat_priv->gw_sel_class) > 2))
 		batadv_gw_check_election(bat_priv, orig_node);
=20
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 95d80d1..561ec31 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -360,11 +360,11 @@ static ssize_t batadv_show_gw_mode(struct kobject *=
kobj, struct attribute *attr,
 	int bytes_written;
=20
 	switch (atomic_read(&bat_priv->gw_mode)) {
-	case GW_MODE_CLIENT:
+	case BATADV_GW_MODE_CLIENT:
 		bytes_written =3D sprintf(buff, "%s\n",
 					BATADV_GW_MODE_CLIENT_NAME);
 		break;
-	case GW_MODE_SERVER:
+	case BATADV_GW_MODE_SERVER:
 		bytes_written =3D sprintf(buff, "%s\n",
 					BATADV_GW_MODE_SERVER_NAME);
 		break;
@@ -391,15 +391,15 @@ static ssize_t batadv_store_gw_mode(struct kobject =
*kobj,
=20
 	if (strncmp(buff, BATADV_GW_MODE_OFF_NAME,
 		    strlen(BATADV_GW_MODE_OFF_NAME)) =3D=3D 0)
-		gw_mode_tmp =3D GW_MODE_OFF;
+		gw_mode_tmp =3D BATADV_GW_MODE_OFF;
=20
 	if (strncmp(buff, BATADV_GW_MODE_CLIENT_NAME,
 		    strlen(BATADV_GW_MODE_CLIENT_NAME)) =3D=3D 0)
-		gw_mode_tmp =3D GW_MODE_CLIENT;
+		gw_mode_tmp =3D BATADV_GW_MODE_CLIENT;
=20
 	if (strncmp(buff, BATADV_GW_MODE_SERVER_NAME,
 		    strlen(BATADV_GW_MODE_SERVER_NAME)) =3D=3D 0)
-		gw_mode_tmp =3D GW_MODE_SERVER;
+		gw_mode_tmp =3D BATADV_GW_MODE_SERVER;
=20
 	if (gw_mode_tmp < 0) {
 		batadv_info(net_dev,
@@ -412,10 +412,10 @@ static ssize_t batadv_store_gw_mode(struct kobject =
*kobj,
 		return count;
=20
 	switch (atomic_read(&bat_priv->gw_mode)) {
-	case GW_MODE_CLIENT:
+	case BATADV_GW_MODE_CLIENT:
 		curr_gw_mode_str =3D BATADV_GW_MODE_CLIENT_NAME;
 		break;
-	case GW_MODE_SERVER:
+	case BATADV_GW_MODE_SERVER:
 		curr_gw_mode_str =3D BATADV_GW_MODE_SERVER_NAME;
 		break;
 	default:
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_cli=
ent.c
index 5fc162c..2fcf26f 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -194,7 +194,7 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 	 * hear about. This check is based on the daemon's uptime which we
 	 * don't have.
 	 */
-	if (atomic_read(&bat_priv->gw_mode) !=3D GW_MODE_CLIENT)
+	if (atomic_read(&bat_priv->gw_mode) !=3D BATADV_GW_MODE_CLIENT)
 		goto out;
=20
 	if (!batadv_atomic_dec_not_zero(&bat_priv->gw_reselect))
@@ -663,13 +663,13 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_pr=
iv,
 		goto out;
=20
 	switch (atomic_read(&bat_priv->gw_mode)) {
-	case GW_MODE_SERVER:
+	case BATADV_GW_MODE_SERVER:
 		/* If we are a GW then we are our best GW. We can artificially
 		 * set the tq towards ourself as the maximum value
 		 */
 		curr_tq_avg =3D BATADV_TQ_MAX_VALUE;
 		break;
-	case GW_MODE_CLIENT:
+	case BATADV_GW_MODE_CLIENT:
 		curr_gw =3D batadv_gw_get_selected_gw_node(bat_priv);
 		if (!curr_gw)
 			goto out;
@@ -689,7 +689,7 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv=
,
=20
 		curr_tq_avg =3D neigh_curr->tq_avg;
 		break;
-	case GW_MODE_OFF:
+	case BATADV_GW_MODE_OFF:
 	default:
 		goto out;
 	}
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_com=
mon.h
index 31bbc3c..13697f6 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -20,10 +20,10 @@
 #ifndef _NET_BATMAN_ADV_GATEWAY_COMMON_H_
 #define _NET_BATMAN_ADV_GATEWAY_COMMON_H_
=20
-enum gw_modes {
-	GW_MODE_OFF,
-	GW_MODE_CLIENT,
-	GW_MODE_SERVER,
+enum batadv_gw_modes {
+	BATADV_GW_MODE_OFF,
+	BATADV_GW_MODE_CLIENT,
+	BATADV_GW_MODE_SERVER,
 };
=20
 #define BATADV_GW_MODE_OFF_NAME	"off"
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
index c1b2ab2..b77e598 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -177,7 +177,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		do_bcast =3D true;
=20
 		switch (atomic_read(&bat_priv->gw_mode)) {
-		case GW_MODE_SERVER:
+		case BATADV_GW_MODE_SERVER:
 			/* gateway servers should not send dhcp
 			 * requests into the mesh
 			 */
@@ -185,7 +185,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			if (ret)
 				goto dropped;
 			break;
-		case GW_MODE_CLIENT:
+		case BATADV_GW_MODE_CLIENT:
 			/* gateway clients should send dhcp requests
 			 * via unicast to their gateway
 			 */
@@ -193,7 +193,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			if (ret)
 				do_bcast =3D false;
 			break;
-		case GW_MODE_OFF:
+		case BATADV_GW_MODE_OFF:
 		default:
 			break;
 		}
@@ -234,7 +234,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
=20
 	/* unicast packet */
 	} else {
-		if (atomic_read(&bat_priv->gw_mode) !=3D GW_MODE_OFF) {
+		if (atomic_read(&bat_priv->gw_mode) !=3D BATADV_GW_MODE_OFF) {
 			ret =3D batadv_gw_out_of_range(bat_priv, skb, ethhdr);
 			if (ret)
 				goto dropped;
@@ -387,7 +387,7 @@ struct net_device *batadv_softif_create(const char *n=
ame)
 	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
 	atomic_set(&bat_priv->ap_isolation, 0);
 	atomic_set(&bat_priv->vis_mode, VIS_TYPE_CLIENT_UPDATE);
-	atomic_set(&bat_priv->gw_mode, GW_MODE_OFF);
+	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
 	atomic_set(&bat_priv->gw_bandwidth, 41);
 	atomic_set(&bat_priv->orig_interval, 1000);
--=20
1.7.9.4
