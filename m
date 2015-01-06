From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 3/6] batman-adv: fix lock class for decoding hash in network-coding.c
Date: Tue,  6 Jan 2015 12:10:02 +0100
Message-ID: <1420542605-28865-4-git-send-email-antonio@meshcoding.com>
References: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21635 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348AbbAFLKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:10:49 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

batadv_has_set_lock_class() is called with the wrong hash table as firs=
t
argument (probably due to a copy-paste error), which leads to false
positives when running with lockdep.

Introduced-by: 612d2b4fe0a1ff2f8389462a6f8be34e54124c05
("batman-adv: network coding - save overheard and tx packets for decodi=
ng")

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/network-coding.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 8d04d17..fab47f1 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -133,7 +133,7 @@ int batadv_nc_mesh_init(struct batadv_priv *bat_pri=
v)
 	if (!bat_priv->nc.decoding_hash)
 		goto err;
=20
-	batadv_hash_set_lock_class(bat_priv->nc.coding_hash,
+	batadv_hash_set_lock_class(bat_priv->nc.decoding_hash,
 				   &batadv_nc_decoding_hash_lock_class_key);
=20
 	INIT_DELAYED_WORK(&bat_priv->nc.work, batadv_nc_worker);
--=20
2.2.1
