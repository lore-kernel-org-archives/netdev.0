From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 16/20] batman-adv: Place kref_get for nc_path near use
Date: Mon, 22 Aug 2016 15:56:16 +0200
Message-ID: <20160822135620.15337-17-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38997 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755148AbcHVN56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:58 -0400
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
index 4f4cfe5..165cd27 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -978,7 +978,6 @@ static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
 	INIT_LIST_HEAD(&nc_path->packet_list);
 	spin_lock_init(&nc_path->packet_list_lock);
 	kref_init(&nc_path->refcount);
-	kref_get(&nc_path->refcount);
 	nc_path->last_valid = jiffies;
 	ether_addr_copy(nc_path->next_hop, dst);
 	ether_addr_copy(nc_path->prev_hop, src);
@@ -988,6 +987,7 @@ static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
 		   nc_path->next_hop);
 
 	/* Add nc_path to hash table */
+	kref_get(&nc_path->refcount);
 	hash_added = batadv_hash_add(hash, batadv_nc_hash_compare,
 				     batadv_nc_hash_choose, &nc_path_key,
 				     &nc_path->hash_entry);
-- 
2.9.3
