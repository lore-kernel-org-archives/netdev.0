From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/9] batman-adv: Return reason for failure in batadv_check_unicast_packet()
Date: Wed, 13 Mar 2013 23:56:32 +0100
Message-ID: <1363215399-18875-3-git-send-email-ordex@autistici.org>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:65454 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932534Ab3CMW56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:57:58 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

batadv_check_unicast_packet() is changed to return a value based on the
reason to drop the packet, which will be useful information for
future users of batadv_check_unicast_packet().

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5ee21ce..322c97a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -548,27 +548,37 @@ batadv_find_ifalter_router(struct batadv_orig_nod=
e *primary_orig,
 	return router;
 }
=20
+/**
+ * batadv_check_unicast_packet - Check for malformed unicast packets
+ * @skb: packet to check
+ * @hdr_size: size of header to pull
+ *
+ * Check for short header and bad addresses in given packet. Returns n=
egative
+ * value when check fails and 0 otherwise. The negative value depends =
on the
+ * reason: -ENODATA for bad header, -EBADR for broadcast destination o=
r source,
+ * and -EREMOTE for non-local (other host) destination.
+ */
 static int batadv_check_unicast_packet(struct sk_buff *skb, int hdr_si=
ze)
 {
 	struct ethhdr *ethhdr;
=20
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		return -1;
+		return -ENODATA;
=20
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
=20
 	/* packet with unicast indication but broadcast recipient */
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
-		return -1;
+		return -EBADR;
=20
 	/* packet with broadcast sender address */
 	if (is_broadcast_ether_addr(ethhdr->h_source))
-		return -1;
+		return -EBADR;
=20
 	/* not for me */
 	if (!batadv_is_my_mac(ethhdr->h_dest))
-		return -1;
+		return -EREMOTE;
=20
 	return 0;
 }
--=20
1.8.1.5
