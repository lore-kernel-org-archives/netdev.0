From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 1/4] bnx2x: call dev_kfree_skb_any instead of
 dev_kfree_skb
Date: Sun, 22 May 2011 23:06:58 +0300
Message-ID: <1306094818.9376.1.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3618 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814Ab1EVUQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 16:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

replace function calls when possible call in both irq/non-irq contexts

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    4 ++--
 drivers/net/bnx2x/bnx2x_cmn.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 16581df..9403049 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -87,7 +87,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* release skb */
 	WARN_ON(!skb);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
@@ -419,7 +419,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		} else {
 			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new pages"
 			   " - dropping packet!\n");
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 		}
 
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index ef37b98..89eb9ca 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -838,7 +838,7 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 	mapping = dma_map_single(&bp->pdev->dev, skb->data, fp->rx_buf_size,
 				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return -ENOMEM;
 	}
 
-- 
1.7.2.2




