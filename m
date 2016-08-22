From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 15/20] batman-adv: Place kref_get for nc_node near use
Date: Mon, 22 Aug 2016 15:56:15 +0200
Message-ID: <20160822135620.15337-16-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:39004 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755500AbcHVN57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:59 -0400
In-Reply-To: <20160822135620.15337-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It is hard to understand why the refcnt is increased when it isn't done
near the actual place the new reference is used. So using kref_get right
before the place which requires the reference and in the same function
helps to avoid accidental problems caused by incorrect reference counting.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/network-coding.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 3814cfb..4f4cfe5 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -859,7 +859,6 @@ batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
 	/* Initialize nc_node */
 	INIT_LIST_HEAD(&nc_node->list);
 	kref_init(&nc_node->refcount);
-	kref_get(&nc_node->refcount);
 	ether_addr_copy(nc_node->addr, orig_node->orig);
 	kref_get(&orig_neigh_node->refcount);
 	nc_node->orig_node = orig_neigh_node;
@@ -878,6 +877,7 @@ batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
 
 	/* Add nc_node to orig_node */
 	spin_lock_bh(lock);
+	kref_get(&nc_node->refcount);
 	list_add_tail_rcu(&nc_node->list, list);
 	spin_unlock_bh(lock);
 
-- 
2.9.3
