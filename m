From: Dongli Zhang <dongli.zhang@oracle.com>
Subject: [PATCH 1/1] xen-netfront: cast grant table reference first to type int
Date: Wed,  2 Nov 2016 09:04:33 +0800
Message-ID: <1478048673-26284-1-git-send-email-dongli.zhang@oracle.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IS_ERR_VALUE() in commit 87557efc27f6a50140fb20df06a917f368ce3c66
("xen-netfront: do not cast grant table reference to signed short") would
not return true for error code unless we cast ref first to type int.

Signed-off-by: Dongli Zhang <dongli.zhang@oracle.com>
---
 drivers/net/xen-netfront.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 189a28d..bf2744e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -304,7 +304,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		queue->rx_skbs[id] = skb;
 
 		ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
-		WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));
+		WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)(int)ref));
 		queue->grant_rx_ref[id] = ref;
 
 		page = skb_frag_page(&skb_shinfo(skb)->frags[0]);
@@ -428,7 +428,7 @@ static void xennet_tx_setup_grant(unsigned long gfn, unsigned int offset,
 	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
 	tx = RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
 	ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
-	WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));
+	WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)(int)ref));
 
 	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
 					gfn, GNTMAP_readonly);
-- 
2.7.4
