From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/15] batman-adv: don't compile the BLA switch if not requested
Date: Mon, 14 Jan 2013 09:41:16 +1000
Message-ID: <1358120480-25960-12-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49843 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab3AMXnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:43:13 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the Bridge Loop Avoidance component is not compiled-in, its boolean switch
should be not compiled as well. This patch surrounds the switch with a proper
ifdef.

This behaviour was introduced by 9fd6b0615b5499b270d39a92b8790e206cf75833
("batman-adv: add bridge loop avoidance compile option")

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/soft-interface.c | 2 ++
 net/batman-adv/types.h          | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index f8cc142..57714f8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -480,7 +480,9 @@ struct net_device *batadv_softif_create(const char *name)
 
 	atomic_set(&bat_priv->aggregated_ogms, 1);
 	atomic_set(&bat_priv->bonding, 0);
+#ifdef CONFIG_BATMAN_ADV_BLA
 	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
+#endif
 #ifdef CONFIG_BATMAN_ADV_DAT
 	atomic_set(&bat_priv->distributed_arp_table, 1);
 #endif
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ae9ac9a..030ce41 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -273,7 +273,9 @@ struct batadv_priv {
 	atomic_t bonding;		/* boolean */
 	atomic_t fragmentation;		/* boolean */
 	atomic_t ap_isolation;		/* boolean */
+#ifdef CONFIG_BATMAN_ADV_BLA
 	atomic_t bridge_loop_avoidance;	/* boolean */
+#endif
 #ifdef CONFIG_BATMAN_ADV_DAT
 	atomic_t distributed_arp_table;	/* boolean */
 #endif
-- 
1.8.0.2
