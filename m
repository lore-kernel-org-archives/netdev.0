From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/16] batman-adv: remove obsolete skb_reset_mac_header() in batadv_bla_tx()
Date: Sat, 22 Mar 2014 09:56:03 +0100
Message-ID: <1395478576-10999-4-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:27756 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbaCVI4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:49 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

Our .ndo_start_xmit handler (batadv_interface_tx()) can rely on having
the skb mac header pointer set correctly since the following commit
present in kernels >=3D 3.9:

"net: reset mac header in dev_start_xmit()" (6d1ccff627)

Therefore this commit removes the according, now redundant,
skb_reset_mac_header() call in batadv_bla_tx().

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bridge_loop_avoidance.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 73d8372..70d781a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1547,9 +1547,6 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, s=
truct sk_buff *skb,
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
 		goto allow;
=20
-	/* in VLAN case, the mac header might not be set. */
-	skb_reset_mac_header(skb);
-
 	if (batadv_bla_process_claim(bat_priv, primary_if, skb))
 		goto handled;
=20
--=20
1.8.3.2
