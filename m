From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/15] batman-adv: Do not add multicast MAC addresses to translation table
Date: Mon, 14 Jan 2013 09:41:07 +1000
Message-ID: <1358120480-25960-3-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49405 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab3AMXmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:42:31 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

The current translation table mechanism is not suitable for multicast
addresses and we are currently flooding such frames anyway.

Therefore this patch prevents multicast MAC addresses being added to th=
e
translation table.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 90f4049..f8cc142 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -180,7 +180,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		goto dropped;
=20
 	/* Register the client MAC in the transtable */
-	batadv_tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
+	if (!is_multicast_ether_addr(ethhdr->h_source))
+		batadv_tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
=20
 	/* don't accept stp packets. STP does not help in meshes.
 	 * better use the bridge loop avoidance ...
--=20
1.8.0.2
