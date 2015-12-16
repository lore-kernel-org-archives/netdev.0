From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/12] batman-adv: Use chain pointer when purging fragments
Date: Wed, 16 Dec 2015 15:49:31 +0800
Message-ID: <1450252173-20949-11-git-send-email-antonio__31442.9175145508$1450253257$gmane$org@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:34848 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932664AbbLPIHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 03:07:30 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

The chain pointer was already created in batadv_frag_purge_orig to make=
 the
checks more readable. Just use the chain pointer everywhere instead of
having the same dereference + array access in the most lines of this
function.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/fragmentation.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index 700c96c..20d9282 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -71,14 +71,14 @@ void batadv_frag_purge_orig(struct batadv_orig_node=
 *orig_node,
=20
 	for (i =3D 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
 		chain =3D &orig_node->fragments[i];
-		spin_lock_bh(&orig_node->fragments[i].lock);
+		spin_lock_bh(&chain->lock);
=20
 		if (!check_cb || check_cb(chain)) {
-			batadv_frag_clear_chain(&orig_node->fragments[i].head);
-			orig_node->fragments[i].size =3D 0;
+			batadv_frag_clear_chain(&chain->head);
+			chain->size =3D 0;
 		}
=20
-		spin_unlock_bh(&orig_node->fragments[i].lock);
+		spin_unlock_bh(&chain->lock);
 	}
 }
=20
--=20
2.6.4
