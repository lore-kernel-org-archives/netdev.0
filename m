From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/15] batman-adv: clear control block of received socket buffers
Date: Thu,  8 Jan 2015 16:15:17 +0100
Message-ID: <1420730120-9844-13-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:45371 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864AbbAHPbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:31:55 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Since other network components (and some drivers) uses the control bloc=
k
provided in skb's, the network coding feature might wrongly assume that
an SKB has been decoded, and thus not try to code it with another packe=
t
again. This happens for instance when batman-adv is running on a bridge=
 device.

=46ix this by clearing the control block for every received SKB.

Introduced by 3c12de9a5c756b23fe7c9ab332474ece1568914c
("batman-adv: network coding - code and transmit packets if possible")
Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d4079cd..3bcd847 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -402,6 +402,9 @@ int batadv_batman_skb_recv(struct sk_buff *skb, str=
uct net_device *dev,
 		goto err_free;
 	}
=20
+	/* reset control block to avoid left overs from previous users */
+	memset(skb->cb, 0, sizeof(struct batadv_skb_cb));
+
 	/* all receive handlers return whether they received or reused
 	 * the supplied skb. if not, we have to free the skb.
 	 */
--=20
2.2.1
