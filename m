From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v3 2/2] net/xen-netback: Remove unused code in xenvif_rx_action
Date: Thu, 4 Jun 2015 16:35:14 +0100
Message-ID: <1433432114-22198-3-git-send-email-julien.grall@citrix.com>
References: <1433432114-22198-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433432114-22198-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variables old_req_cons and ring_slots_used are assigned but never
used since commit 1650d5455bd2dc6b5ee134bd6fc1a3236c266b5b "xen-netback:
always fully coalesce guest Rx packets".

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org

---
    Changes in v2:
        - Add Wei's Acked-by
---
 drivers/net/xen-netback/netback.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 0d25943..ba3ae30 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -515,14 +515,9 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 
 	while (xenvif_rx_ring_slots_available(queue, XEN_NETBK_RX_SLOTS_MAX)
 	       && (skb = xenvif_rx_dequeue(queue)) != NULL) {
-		RING_IDX old_req_cons;
-		RING_IDX ring_slots_used;
-
 		queue->last_rx_time = jiffies;
 
-		old_req_cons = queue->rx.req_cons;
 		XENVIF_RX_CB(skb)->meta_slots_used = xenvif_gop_skb(skb, &npo, queue);
-		ring_slots_used = queue->rx.req_cons - old_req_cons;
 
 		__skb_queue_tail(&rxq, skb);
 	}
-- 
2.1.4
