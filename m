From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH net 3/5] batman-adv: Fix double-put of vlan object
Date: Sun, 26 Jun 2016 11:16:11 +0200
Message-ID: <1466932573-23105-3-git-send-email-sven@narfation.org>
References: <10049349.EHEiaYmtBd@sven-edge>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Sven Eckelmann <sven@narfation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40198 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbcFZJQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2016 05:16:31 -0400
In-Reply-To: <10049349.EHEiaYmtBd@sven-edge>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>

Each batadv_tt_local_entry hold a single reference to a
batadv_softif_vlan.  In case a new entry cannot be added to the hash
table, the error path puts the reference, but the reference will also
now be dropped by batadv_tt_local_entry_release().

Fixes: a33d970d0b54 ("batman-adv: Fix reference counting of vlan object for tt_local_entry")
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/translation-table.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cfb5ccd..57ec87f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -693,7 +693,6 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	if (unlikely(hash_added != 0)) {
 		/* remove the reference for the hash */
 		batadv_tt_local_entry_put(tt_local);
-		batadv_softif_vlan_put(vlan);
 		goto out;
 	}
 
-- 
2.8.1
