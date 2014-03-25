From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 13/54] macb: Call dev_kfree_skb_any instead of kfree_skb.
Date: Mon, 24 Mar 2014 23:04:59 -0700
Message-ID: <1395727540-12148-13-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34622 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaCYGLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:32 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_kfree_skb_any in macb_start_xmit that can
be called in hard irq and other contexts.

macb_start_xmit only frees skbs when dropping them so
dev_kfree_skb_any is used.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/cadence/macb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index d0c38e01e99f..6116887d2880 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1045,7 +1045,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mapping = dma_map_single(&bp->pdev->dev, skb->data,
 				 len, DMA_TO_DEVICE);
 	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		goto unlock;
 	}
 
-- 
1.7.10.4
