From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/6] batman-adv: fix and simplify condition when bonding should be used
Date: Tue,  6 Jan 2015 12:10:00 +0100
Message-ID: <1420542605-28865-2-git-send-email-antonio@meshcoding.com>
References: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:48961 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751AbbAFLKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:10:46 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

The current condition actually does NOT consider bonding when the
interface the packet came in from is the soft interface, which is the
opposite of what it should do (and the comment describes). Fix that and
slightly simplify the condition.

Reported-by: Ray Gibson <booray@gmail.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/routing.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 35f76f2..6648f32 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -443,11 +443,13 @@ batadv_find_router(struct batadv_priv *bat_priv,
 
 	router = batadv_orig_router_get(orig_node, recv_if);
 
+	if (!router)
+		return router;
+
 	/* only consider bonding for recv_if == BATADV_IF_DEFAULT (first hop)
 	 * and if activated.
 	 */
-	if (recv_if == BATADV_IF_DEFAULT || !atomic_read(&bat_priv->bonding) ||
-	    !router)
+	if (!(recv_if == BATADV_IF_DEFAULT && atomic_read(&bat_priv->bonding)))
 		return router;
 
 	/* bonding: loop through the list of possible routers found
-- 
2.2.1
