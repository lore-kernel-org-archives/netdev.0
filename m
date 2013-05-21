From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: Avoid double freeing of bat_counters
Date: Tue, 21 May 2013 21:53:55 +0200
Message-ID: <1369166035-585-2-git-send-email-ordex@autistici.org>
References: <pull request for net: batman-adv 2013-05-21>
 <1369166035-585-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:51121 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940Ab3EUTzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 15:55:46 -0400
In-Reply-To: <1369166035-585-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

On errors in batadv_mesh_init(), bat_counters will be freed in both
batadv_mesh_free() and batadv_softif_init_late(). This patch fixes this
by returning earlier from batadv_softif_init_late() in case of errors i=
n
batadv_mesh_init() and by setting bat_counters to NULL after freeing.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c           | 1 +
 net/batman-adv/soft-interface.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 1240f07..51aafd6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -181,6 +181,7 @@ void batadv_mesh_free(struct net_device *soft_iface=
)
 	batadv_originator_free(bat_priv);
=20
 	free_percpu(bat_priv->bat_counters);
+	bat_priv->bat_counters =3D NULL;
=20
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
 }
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 6f20d33..819dfb0 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -505,6 +505,7 @@ unreg_debugfs:
 	batadv_debugfs_del_meshif(dev);
 free_bat_counters:
 	free_percpu(bat_priv->bat_counters);
+	bat_priv->bat_counters =3D NULL;
=20
 	return ret;
 }
--=20
1.8.1.5
