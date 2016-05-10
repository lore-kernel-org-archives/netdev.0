From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 08/17] batman-adv: Increase hard_iface refcnt for ptype
Date: Wed, 11 May 2016 03:29:56 +0800
Message-ID: <1462908605-27412-9-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:29074 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbcEJTbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:31:09 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The hard_iface is referenced in the packet_type for batman-adv. Increase
the refcounter of the hard_interface for it to have an explicit reference
for it in case this functionality gets refactorted and the currently
used implicit reference for it will be removed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/hard-interface.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f0e1899e5b6b..d3d37f3f99cf 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -522,6 +522,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 		goto err_upper;
 	}
 
+	kref_get(&hard_iface->refcount);
 	hard_iface->batman_adv_ptype.type = ethertype;
 	hard_iface->batman_adv_ptype.func = batadv_batman_skb_recv;
 	hard_iface->batman_adv_ptype.dev = hard_iface->net_dev;
@@ -583,6 +584,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 	batadv_info(hard_iface->soft_iface, "Removing interface: %s\n",
 		    hard_iface->net_dev->name);
 	dev_remove_pack(&hard_iface->batman_adv_ptype);
+	batadv_hardif_put(hard_iface);
 
 	bat_priv->num_ifaces--;
 	batadv_orig_hash_del_if(hard_iface, bat_priv->num_ifaces);
-- 
2.8.2
