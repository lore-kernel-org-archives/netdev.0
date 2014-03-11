From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 05/10] bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Tue, 11 Mar 2014 14:17:41 -0700
Message-ID: <87zjkwa0zu.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55711 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbaCKVRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:17:48 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ca6b36220d94..c251ca3056de 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2885,7 +2885,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		sw_cons = BNX2_NEXT_TX_BD(sw_cons);
 
 		tx_bytes += skb->len;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		tx_pkt++;
 		if (tx_pkt == budget)
 			break;
@@ -6604,7 +6604,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	mapping = dma_map_single(&bp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
 	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -6697,7 +6697,7 @@ dma_error:
 			       PCI_DMA_TODEVICE);
 	}
 
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.5.4
