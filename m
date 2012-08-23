From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/18] batman-adv: Move batadv_check_unicast_packet()
Date: Thu, 23 Aug 2012 15:10:20 +0200
Message-ID: <1345727427-20805-12-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28883 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933657Ab2HWNLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:00 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

batadv_check_unicast_packet() is needed in batadv_recv_tt_query(), so
move the former to before the latter.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c |   50 +++++++++++++++++++++++---------------=
--------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d5edee7..a79ded5 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -579,6 +579,31 @@ batadv_find_ifalter_router(struct batadv_orig_node=
 *primary_orig,
 	return router;
 }
=20
+static int batadv_check_unicast_packet(struct sk_buff *skb, int hdr_si=
ze)
+{
+	struct ethhdr *ethhdr;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return -1;
+
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with unicast indication but broadcast recipient */
+	if (is_broadcast_ether_addr(ethhdr->h_dest))
+		return -1;
+
+	/* packet with broadcast sender address */
+	if (is_broadcast_ether_addr(ethhdr->h_source))
+		return -1;
+
+	/* not for me */
+	if (!batadv_is_my_mac(ethhdr->h_dest))
+		return -1;
+
+	return 0;
+}
+
 int batadv_recv_tt_query(struct sk_buff *skb, struct batadv_hard_iface=
 *recv_if)
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
@@ -819,31 +844,6 @@ err:
 	return NULL;
 }
=20
-static int batadv_check_unicast_packet(struct sk_buff *skb, int hdr_si=
ze)
-{
-	struct ethhdr *ethhdr;
-
-	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		return -1;
-
-	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
-
-	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
-		return -1;
-
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
-		return -1;
-
-	/* not for me */
-	if (!batadv_is_my_mac(ethhdr->h_dest))
-		return -1;
-
-	return 0;
-}
-
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if)
 {
--=20
1.7.9.4
