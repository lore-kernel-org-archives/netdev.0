From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH] batman-adv: fix NULL pointer dereferences
Date: Tue, 27 May 2014 04:25:47 +0200
Message-ID: <1401157547-25199-2-git-send-email-antonio@meshcoding.com>
References: <1401157547-25199-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:32427 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbaE0C1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 22:27:39 -0400
In-Reply-To: <1401157547-25199-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <mareklindner@neomailbox.ch>

Was introduced with 4c8755d69cbde2ec464a39c932aed0a83f9ff89f
("batman-adv: Send multicast packets to nodes with a WANT_ALL flag")

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/multicast.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 8c7ca81..96b66fd 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -415,7 +415,7 @@ batadv_mcast_forw_ipv4_node_get(struct batadv_priv =
*bat_priv)
 	hlist_for_each_entry_rcu(tmp_orig_node,
 				 &bat_priv->mcast.want_all_ipv4_list,
 				 mcast_want_all_ipv4_node) {
-		if (!atomic_inc_not_zero(&orig_node->refcount))
+		if (!atomic_inc_not_zero(&tmp_orig_node->refcount))
 			continue;
=20
 		orig_node =3D tmp_orig_node;
@@ -442,7 +442,7 @@ batadv_mcast_forw_ipv6_node_get(struct batadv_priv =
*bat_priv)
 	hlist_for_each_entry_rcu(tmp_orig_node,
 				 &bat_priv->mcast.want_all_ipv6_list,
 				 mcast_want_all_ipv6_node) {
-		if (!atomic_inc_not_zero(&orig_node->refcount))
+		if (!atomic_inc_not_zero(&tmp_orig_node->refcount))
 			continue;
=20
 		orig_node =3D tmp_orig_node;
@@ -493,7 +493,7 @@ batadv_mcast_forw_unsnoop_node_get(struct batadv_pr=
iv *bat_priv)
 	hlist_for_each_entry_rcu(tmp_orig_node,
 				 &bat_priv->mcast.want_all_unsnoopables_list,
 				 mcast_want_all_unsnoopables_node) {
-		if (!atomic_inc_not_zero(&orig_node->refcount))
+		if (!atomic_inc_not_zero(&tmp_orig_node->refcount))
 			continue;
=20
 		orig_node =3D tmp_orig_node;
--=20
1.8.5.5
