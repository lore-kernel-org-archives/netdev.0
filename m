From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 4/4] batman-adv: Disallow originator addressing within mesh layer
Date: Sat, 12 Feb 2011 00:21:43 +0100
Message-ID: <1297466503-13246-5-git-send-email-sven@narfation.org>
References: <1297466503-13246-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@ascom.ch>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:35970 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758478Ab1BKXWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 18:22:03 -0500
In-Reply-To: <1297466503-13246-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@ascom.ch>

=46or a host in the mesh network, the batman layer should be transparen=
t.
However, we had one exception, data packets within the mesh network
which have the same destination as a originator are being routed to
that node, although there is no host that node's bat0 interface and
therefore gets dropped anyway. This commit removes this exception.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@ascom.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/unicast.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 6c92eef..1b5e761 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -281,7 +281,7 @@ int unicast_send_skb(struct sk_buff *skb, struct ba=
t_priv *bat_priv)
 {
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
 	struct unicast_packet *unicast_packet;
-	struct orig_node *orig_node;
+	struct orig_node *orig_node =3D NULL;
 	struct batman_if *batman_if;
 	struct neigh_node *router;
 	int data_len =3D skb->len;
@@ -292,11 +292,6 @@ int unicast_send_skb(struct sk_buff *skb, struct b=
at_priv *bat_priv)
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest))
 		orig_node =3D (struct orig_node *)gw_get_selected(bat_priv);
-	else
-		orig_node =3D ((struct orig_node *)hash_find(bat_priv->orig_hash,
-							   compare_orig,
-							   choose_orig,
-							   ethhdr->h_dest));
=20
 	/* check for hna host */
 	if (!orig_node)
--=20
1.7.2.3

