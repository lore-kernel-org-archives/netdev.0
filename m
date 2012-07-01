From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/16] batman-adv: Prefix local sysfs struct with batadv_
Date: Mon,  2 Jul 2012 01:43:38 +0200
Message-ID: <1341186226-10549-9-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23595 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab2GAXnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:40 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_sysfs.c |   12 ++++++------
 net/batman-adv/bat_sysfs.h |    2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index c4794c6..eb17629 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -54,7 +54,7 @@ static char *batadv_uev_type_str[] =3D {
=20
 /* Use this, if you have customized show and store functions */
 #define BATADV_ATTR(_name, _mode, _show, _store)	\
-struct bat_attribute batadv_attr_##_name =3D {		\
+struct batadv_attribute batadv_attr_##_name =3D {		\
 	.attr =3D {.name =3D __stringify(_name),		\
 		 .mode =3D _mode },			\
 	.show   =3D _show,				\
@@ -488,7 +488,7 @@ static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR,=
 batadv_show_gw_bwidth,
 BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, BATADV_DBG_ALL, =
NULL);
 #endif
=20
-static struct bat_attribute *batadv_mesh_attrs[] =3D {
+static struct batadv_attribute *batadv_mesh_attrs[] =3D {
 	&batadv_attr_aggregated_ogms,
 	&batadv_attr_bonding,
 #ifdef CONFIG_BATMAN_ADV_BLA
@@ -513,7 +513,7 @@ int batadv_sysfs_add_meshif(struct net_device *dev)
 {
 	struct kobject *batif_kobject =3D &dev->dev.kobj;
 	struct bat_priv *bat_priv =3D netdev_priv(dev);
-	struct bat_attribute **bat_attr;
+	struct batadv_attribute **bat_attr;
 	int err;
=20
 	bat_priv->mesh_obj =3D kobject_create_and_add(BATADV_SYSFS_IF_MESH_SU=
BDIR,
@@ -550,7 +550,7 @@ out:
 void batadv_sysfs_del_meshif(struct net_device *dev)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(dev);
-	struct bat_attribute **bat_attr;
+	struct batadv_attribute **bat_attr;
=20
 	for (bat_attr =3D batadv_mesh_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
@@ -677,7 +677,7 @@ static BATADV_ATTR(mesh_iface, S_IRUGO | S_IWUSR, b=
atadv_show_mesh_iface,
 		   batadv_store_mesh_iface);
 static BATADV_ATTR(iface_status, S_IRUGO, batadv_show_iface_status, NU=
LL);
=20
-static struct bat_attribute *batadv_batman_attrs[] =3D {
+static struct batadv_attribute *batadv_batman_attrs[] =3D {
 	&batadv_attr_mesh_iface,
 	&batadv_attr_iface_status,
 	NULL,
@@ -686,7 +686,7 @@ static struct bat_attribute *batadv_batman_attrs[] =
=3D {
 int batadv_sysfs_add_hardif(struct kobject **hardif_obj, struct net_de=
vice *dev)
 {
 	struct kobject *hardif_kobject =3D &dev->dev.kobj;
-	struct bat_attribute **bat_attr;
+	struct batadv_attribute **bat_attr;
 	int err;
=20
 	*hardif_obj =3D kobject_create_and_add(BATADV_SYSFS_IF_BAT_SUBDIR,
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index 28c2948..88f95f8 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -23,7 +23,7 @@
 #define BATADV_SYSFS_IF_MESH_SUBDIR "mesh"
 #define BATADV_SYSFS_IF_BAT_SUBDIR "batman_adv"
=20
-struct bat_attribute {
+struct batadv_attribute {
 	struct attribute attr;
 	ssize_t (*show)(struct kobject *kobj, struct attribute *attr,
 			char *buf);
--=20
1.7.9.4
