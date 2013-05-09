From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/4] batman-adv: check return value of pskb_trim_rcsum()
Date: Thu,  9 May 2013 12:56:45 +0200
Message-ID: <1368097007-817-3-git-send-email-ordex@autistici.org>
References: <1368097007-817-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:44797 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053Ab3EIK6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 06:58:35 -0400
In-Reply-To: <1368097007-817-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <lindner_marek@yahoo.de>

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/network-coding.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index f7c5430..e84629e 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1514,6 +1514,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *b=
at_priv, struct sk_buff *skb,
 	struct ethhdr *ethhdr, ethhdr_tmp;
 	uint8_t *orig_dest, ttl, ttvn;
 	unsigned int coding_len;
+	int err;
=20
 	/* Save headers temporarily */
 	memcpy(&coded_packet_tmp, skb->data, sizeof(coded_packet_tmp));
@@ -1568,8 +1569,11 @@ batadv_nc_skb_decode_packet(struct batadv_priv *=
bat_priv, struct sk_buff *skb,
 			 coding_len);
=20
 	/* Resize decoded skb if decoded with larger packet */
-	if (nc_packet->skb->len > coding_len + h_size)
-		pskb_trim_rcsum(skb, coding_len + h_size);
+	if (nc_packet->skb->len > coding_len + h_size) {
+		err =3D pskb_trim_rcsum(skb, coding_len + h_size);
+		if (err)
+			return NULL;
+	}
=20
 	/* Create decoded unicast packet */
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
--=20
1.8.1.5
