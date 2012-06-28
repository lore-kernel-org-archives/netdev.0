From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/18] batman-adv: Prefix types defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:24 +0200
Message-ID: <1340876067-28333-16-git-send-email-ordex@autistici.org>
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
	with ESMTP id S932524Ab2F1Jeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:37 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |   11 ++++++-----
 net/batman-adv/soft-interface.c |    2 +-
 net/batman-adv/types.h          |    9 ++++-----
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index 3401084..9b1cb23 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -196,7 +196,8 @@ int batadv_hardif_min_mtu(struct net_device *soft_i=
face)
 		if (hard_iface->soft_iface !=3D soft_iface)
 			continue;
=20
-		min_mtu =3D min_t(int, hard_iface->net_dev->mtu - BAT_HEADER_LEN,
+		min_mtu =3D min_t(int,
+				hard_iface->net_dev->mtu - BATADV_HEADER_LEN,
 				min_mtu);
 	}
 	rcu_read_unlock();
@@ -320,18 +321,18 @@ int batadv_hardif_enable_interface(struct hard_if=
ace *hard_iface,
 		    hard_iface->net_dev->name);
=20
 	if (atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu=
 <
-		ETH_DATA_LEN + BAT_HEADER_LEN)
+		ETH_DATA_LEN + BATADV_HEADER_LEN)
 		batadv_info(hard_iface->soft_iface,
 			    "The MTU of interface %s is too small (%i) to handle the transp=
ort of batman-adv packets. Packets going over this interface will be fr=
agmented on layer2 which could impact the performance. Setting the MTU =
to %zi would solve the problem.\n",
 			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			    ETH_DATA_LEN + BAT_HEADER_LEN);
+			    ETH_DATA_LEN + BATADV_HEADER_LEN);
=20
 	if (!atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mt=
u <
-		ETH_DATA_LEN + BAT_HEADER_LEN)
+		ETH_DATA_LEN + BATADV_HEADER_LEN)
 		batadv_info(hard_iface->soft_iface,
 			    "The MTU of interface %s is too small (%i) to handle the transp=
ort of batman-adv packets. If you experience problems getting traffic t=
hrough try increasing the MTU to %zi.\n",
 			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			    ETH_DATA_LEN + BAT_HEADER_LEN);
+			    ETH_DATA_LEN + BATADV_HEADER_LEN);
=20
 	if (batadv_hardif_is_iface_up(hard_iface))
 		batadv_hardif_activate_interface(hard_iface);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index e726419..bbbc9a9 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -351,7 +351,7 @@ static void batadv_interface_setup(struct net_devic=
e *dev)
 	 */
 	dev->mtu =3D ETH_DATA_LEN;
 	/* reserve more space in the skbuff for our header */
-	dev->hard_header_len =3D BAT_HEADER_LEN;
+	dev->hard_header_len =3D BATADV_HEADER_LEN;
=20
 	/* generate random address */
 	eth_hw_addr_random(dev);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 053c5d4..1d5d21e 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -22,12 +22,11 @@
=20
 #include "packet.h"
 #include "bitarray.h"
+#include <linux/kernel.h>
=20
-#define BAT_HEADER_LEN (ETH_HLEN + \
-	((sizeof(struct unicast_packet) > sizeof(struct bcast_packet) ? \
-	 sizeof(struct unicast_packet) : \
-	 sizeof(struct bcast_packet))))
-
+#define BATADV_HEADER_LEN \
+	(ETH_HLEN + max(sizeof(struct unicast_packet), \
+			sizeof(struct bcast_packet)))
=20
 struct hard_iface {
 	struct list_head list;
--=20
1.7.9.4
