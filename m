From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/2] batman-adv: check return type of unicast packet preparations
Date: Sat, 17 Aug 2013 13:04:46 +0200
Message-ID: <1376737486-1863-3-git-send-email-ordex@autistici.org>
References: <1376737486-1863-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:25714 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab3HQLb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 07:31:28 -0400
In-Reply-To: <1376737486-1863-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

batadv_unicast(_4addr)_prepare_skb  might reallocate the skb's data.
And if it tries to do so then this can potentially fail.

We shouldn't continue working on this skb in such a case.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/unicast.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 688a041..857e1b8 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -432,12 +432,16 @@ find_router:
=20
 	switch (packet_type) {
 	case BATADV_UNICAST:
-		batadv_unicast_prepare_skb(skb, orig_node);
+		if (!batadv_unicast_prepare_skb(skb, orig_node))
+			goto out;
+
 		header_len =3D sizeof(struct batadv_unicast_packet);
 		break;
 	case BATADV_UNICAST_4ADDR:
-		batadv_unicast_4addr_prepare_skb(bat_priv, skb, orig_node,
-						 packet_subtype);
+		if (!batadv_unicast_4addr_prepare_skb(bat_priv, skb, orig_node,
+						      packet_subtype))
+			goto out;
+
 		header_len =3D sizeof(struct batadv_unicast_4addr_packet);
 		break;
 	default:
--=20
1.8.1.5
