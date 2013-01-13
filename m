From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/15] batman-adv: unbloat batadv_priv if debug is not enabled
Date: Mon, 14 Jan 2013 09:41:20 +1000
Message-ID: <1358120480-25960-16-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:50047 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab3AMXnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:43:32 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/debugfs.c        | 1 -
 net/batman-adv/soft-interface.c | 2 ++
 net/batman-adv/types.h          | 4 ++++
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 5136d32..55a9007 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -229,7 +229,6 @@ static void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
 #else /* CONFIG_BATMAN_ADV_DEBUG */
 static int batadv_debug_log_setup(struct batadv_priv *bat_priv)
 {
-	bat_priv->debug_log = NULL;
 	return 0;
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 57714f8..3d68166 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -493,7 +493,9 @@ struct net_device *batadv_softif_create(const char *name)
 	atomic_set(&bat_priv->gw_bandwidth, 41);
 	atomic_set(&bat_priv->orig_interval, 1000);
 	atomic_set(&bat_priv->hop_penalty, 30);
+#ifdef CONFIG_BATMAN_ADV_DEBUG
 	atomic_set(&bat_priv->log_level, 0);
+#endif
 	atomic_set(&bat_priv->fragmentation, 1);
 	atomic_set(&bat_priv->bcast_queue_left, BATADV_BCAST_QUEUE_LEN);
 	atomic_set(&bat_priv->batman_queue_left, BATADV_BATMAN_QUEUE_LEN);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 441880a..d8061ac 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -284,12 +284,16 @@ struct batadv_priv {
 	atomic_t gw_bandwidth;		/* gw bandwidth */
 	atomic_t orig_interval;		/* uint */
 	atomic_t hop_penalty;		/* uint */
+#ifdef CONFIG_BATMAN_ADV_DEBUG
 	atomic_t log_level;		/* uint */
+#endif
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
 	char num_ifaces;
+#ifdef CONFIG_BATMAN_ADV_DEBUG
 	struct batadv_debug_log *debug_log;
+#endif
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
-- 
1.8.0.2
