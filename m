From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wireless: cw1200: queue.c:  Remove unused function
Date: Sat, 20 Dec 2014 17:46:54 +0100
Message-ID: <1419094014-8945-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Solomon Peachy <pizza@shaftnet.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function cw1200_queue_requeue_all() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/cw1200/queue.c |   27 ---------------------------
 drivers/net/wireless/cw1200/queue.h |    1 -
 2 files changed, 28 deletions(-)

diff --git a/drivers/net/wireless/cw1200/queue.c b/drivers/net/wireless/cw1200/queue.c
index 9c3925f..0aaa0b4 100644
--- a/drivers/net/wireless/cw1200/queue.c
+++ b/drivers/net/wireless/cw1200/queue.c
@@ -415,33 +415,6 @@ int cw1200_queue_requeue(struct cw1200_queue *queue, u32 packet_id)
 	return ret;
 }
 
-int cw1200_queue_requeue_all(struct cw1200_queue *queue)
-{
-	struct cw1200_queue_item *item, *tmp;
-	struct cw1200_queue_stats *stats = queue->stats;
-	spin_lock_bh(&queue->lock);
-
-	list_for_each_entry_safe_reverse(item, tmp, &queue->pending, head) {
-		--queue->num_pending;
-		++queue->link_map_cache[item->txpriv.link_id];
-
-		spin_lock_bh(&stats->lock);
-		++stats->num_queued;
-		++stats->link_map_cache[item->txpriv.link_id];
-		spin_unlock_bh(&stats->lock);
-
-		++item->generation;
-		item->packet_id = cw1200_queue_mk_packet_id(queue->generation,
-							    queue->queue_id,
-							    item->generation,
-							    item - queue->pool);
-		list_move(&item->head, &queue->queue);
-	}
-	spin_unlock_bh(&queue->lock);
-
-	return 0;
-}
-
 int cw1200_queue_remove(struct cw1200_queue *queue, u32 packet_id)
 {
 	int ret = 0;
diff --git a/drivers/net/wireless/cw1200/queue.h b/drivers/net/wireless/cw1200/queue.h
index 119f9c7..45802ea 100644
--- a/drivers/net/wireless/cw1200/queue.h
+++ b/drivers/net/wireless/cw1200/queue.h
@@ -88,7 +88,6 @@ int cw1200_queue_get(struct cw1200_queue *queue,
 		     struct ieee80211_tx_info **tx_info,
 		     const struct cw1200_txpriv **txpriv);
 int cw1200_queue_requeue(struct cw1200_queue *queue, u32 packet_id);
-int cw1200_queue_requeue_all(struct cw1200_queue *queue);
 int cw1200_queue_remove(struct cw1200_queue *queue,
 			u32 packet_id);
 int cw1200_queue_get_skb(struct cw1200_queue *queue, u32 packet_id,
-- 
1.7.10.4
