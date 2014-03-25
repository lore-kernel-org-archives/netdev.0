From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 36/54] forcedeth: Call dev_kfree_skb_any instead of kfree_skb.
Date: Mon, 24 Mar 2014 23:05:22 -0700
Message-ID: <1395727540-12148-36-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34601 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbaCYGL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:28 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Every location changes is a drop making dev_kfree_skby_any appropriate.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 811be0bccd14..fddb464aeab3 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2231,7 +2231,7 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (pci_dma_mapping_error(np->pci_dev,
 					  np->put_tx_ctx->dma)) {
 			/* on DMA mapping error - drop the packet */
-			kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			u64_stats_update_begin(&np->swstats_tx_syncp);
 			np->stat_tx_dropped++;
 			u64_stats_update_end(&np->swstats_tx_syncp);
@@ -2277,7 +2277,7 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					if (unlikely(tmp_tx_ctx++ == np->last_tx_ctx))
 						tmp_tx_ctx = np->first_tx_ctx;
 				} while (tmp_tx_ctx != np->put_tx_ctx);
-				kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 				np->put_tx_ctx = start_tx_ctx;
 				u64_stats_update_begin(&np->swstats_tx_syncp);
 				np->stat_tx_dropped++;
@@ -2380,7 +2380,7 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 		if (pci_dma_mapping_error(np->pci_dev,
 					  np->put_tx_ctx->dma)) {
 			/* on DMA mapping error - drop the packet */
-			kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			u64_stats_update_begin(&np->swstats_tx_syncp);
 			np->stat_tx_dropped++;
 			u64_stats_update_end(&np->swstats_tx_syncp);
@@ -2427,7 +2427,7 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 					if (unlikely(tmp_tx_ctx++ == np->last_tx_ctx))
 						tmp_tx_ctx = np->first_tx_ctx;
 				} while (tmp_tx_ctx != np->put_tx_ctx);
-				kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 				np->put_tx_ctx = start_tx_ctx;
 				u64_stats_update_begin(&np->swstats_tx_syncp);
 				np->stat_tx_dropped++;
-- 
1.7.10.4
