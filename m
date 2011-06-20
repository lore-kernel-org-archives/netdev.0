From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 01/12] batman-adv: Move compare_orig to originator.c
Date: Mon, 20 Jun 2011 12:16:54 +0200
Message-ID: <1308565025-21293-2-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:57157 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457Ab1FTKR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 06:17:28 -0400
In-Reply-To: <1308565025-21293-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

compare_orig is only used in context of orig_node which is managed
inside originator.c. It is not necessary to keep that function inside
the header originator.h.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/originator.c |    8 ++++++++
 net/batman-adv/originator.h |    8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a6c35d4..991a6e7 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -37,6 +37,14 @@ static void start_purge_timer(struct bat_priv *bat_priv)
 	queue_delayed_work(bat_event_workqueue, &bat_priv->orig_work, 1 * HZ);
 }
 
+/* returns 1 if they are the same originator */
+static int compare_orig(const struct hlist_node *node, const void *data2)
+{
+	const void *data1 = container_of(node, struct orig_node, hash_entry);
+
+	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+}
+
 int originator_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->orig_hash)
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 8e307af..cfc1f60 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -40,14 +40,6 @@ int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num);
 int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 
 
-/* returns 1 if they are the same originator */
-static inline int compare_orig(const struct hlist_node *node, const void *data2)
-{
-	const void *data1 = container_of(node, struct orig_node, hash_entry);
-
-	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
-}
-
 /* hashfunction to choose an entry in a hash table of given size */
 /* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
 static inline int choose_orig(const void *data, int32_t size)
-- 
1.7.5.3

