From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 5/5] batman-adv: Fix broadcast/ogm queue limit on a removed interface
Date: Tue, 26 Apr 2016 11:27:19 +0800
Message-ID: <1461641239-7097-6-git-send-email-a@unstable.cc>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:45079 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbcDZD2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 23:28:16 -0400
In-Reply-To: <1461641239-7097-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

When removing a single interface while a broadcast or ogm packet is
still pending then we will free the forward packet without releasing th=
e
queue slots again.

This patch is supposed to fix this issue.

=46ixes: 6d5808d4ae1b ("batman-adv: Add missing hardif_free_ref in forw=
_packet_free")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/send.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3ce06e0a91b1..76417850d3fc 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -675,6 +675,9 @@ batadv_purge_outstanding_packets(struct batadv_priv=
 *bat_priv,
=20
 		if (pending) {
 			hlist_del(&forw_packet->list);
+			if (!forw_packet->own)
+				atomic_inc(&bat_priv->bcast_queue_left);
+
 			batadv_forw_packet_free(forw_packet);
 		}
 	}
@@ -702,6 +705,9 @@ batadv_purge_outstanding_packets(struct batadv_priv=
 *bat_priv,
=20
 		if (pending) {
 			hlist_del(&forw_packet->list);
+			if (!forw_packet->own)
+				atomic_inc(&bat_priv->batman_queue_left);
+
 			batadv_forw_packet_free(forw_packet);
 		}
 	}
--=20
2.8.1
