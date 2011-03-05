From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 27/28] batman-adv: Remove unused hdr_size variable in route_unicast_packet()
Date: Sat,  5 Mar 2011 13:28:41 +0100
Message-ID: <1299328122-21468-28-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@ascom.ch>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36363 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab1CEMaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:30 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@ascom.ch>

Signed-off-by: Linus L=C3=BCssing <linus.luessing@ascom.ch>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/routing.c        |    7 +++----
 net/batman-adv/routing.h        |    3 +--
 net/batman-adv/soft-interface.c |    2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 42cb6e2..c172f5d 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1263,8 +1263,7 @@ static int check_unicast_packet(struct sk_buff *s=
kb, int hdr_size)
 	return 0;
 }
=20
-int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_=
if,
-			 int hdr_size)
+int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_=
if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node =3D NULL;
@@ -1365,7 +1364,7 @@ int recv_unicast_packet(struct sk_buff *skb, stru=
ct hard_iface *recv_if)
 		return NET_RX_SUCCESS;
 	}
=20
-	return route_unicast_packet(skb, recv_if, hdr_size);
+	return route_unicast_packet(skb, recv_if);
 }
=20
 int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *rec=
v_if)
@@ -1398,7 +1397,7 @@ int recv_ucast_frag_packet(struct sk_buff *skb, s=
truct hard_iface *recv_if)
 		return NET_RX_SUCCESS;
 	}
=20
-	return route_unicast_packet(skb, recv_if, hdr_size);
+	return route_unicast_packet(skb, recv_if);
 }
=20
=20
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 5efceaf..b5a064c 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -30,8 +30,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_n=
ode,
 		   struct neigh_node *neigh_node, unsigned char *hna_buff,
 		   int hna_buff_len);
-int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_=
if,
-			 int hdr_size);
+int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_=
if);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_i=
f);
 int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *rec=
v_if);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 95d1c3f..6b514ec 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -462,7 +462,7 @@ void interface_rx(struct net_device *soft_iface,
=20
 		memcpy(unicast_packet->dest,
 		       bat_priv->softif_neigh->addr, ETH_ALEN);
-		ret =3D route_unicast_packet(skb, recv_if, hdr_size);
+		ret =3D route_unicast_packet(skb, recv_if);
 		if (ret =3D=3D NET_RX_DROP)
 			goto dropped;
=20
--=20
1.7.2.3

