From: David Miller <davem@davemloft.net>
Subject: [PATCH]: netdev: Use __netdev_alloc_skb() instead of
 __dev_alloc_skb().
Date: Tue, 10 Feb 2009 01:58:42 -0800 (PST)
Message-ID: <20090210.015842.30221599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751480AbZBJJ6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 04:58:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2E6DCC8D94E
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 01:58:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/b44.c   |    2 +-
 drivers/net/defxx.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 92aaaa1..2a51c75 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -973,7 +973,7 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			ssb_dma_unmap_single(bp->sdev, mapping, len,
 					     DMA_TO_DEVICE);
 
-		bounce_skb = __dev_alloc_skb(len, GFP_ATOMIC | GFP_DMA);
+		bounce_skb = __netdev_alloc_skb(dev, len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 6445ced..4ec055d 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -2937,7 +2937,7 @@ static int dfx_rcv_init(DFX_board_t *bp, int get_buffers)
 	for (i = 0; i < (int)(bp->rcv_bufs_to_post); i++)
 		for (j = 0; (i + j) < (int)PI_RCV_DATA_K_NUM_ENTRIES; j += bp->rcv_bufs_to_post)
 		{
-			struct sk_buff *newskb = __dev_alloc_skb(NEW_SKB_SIZE, GFP_NOIO);
+			struct sk_buff *newskb = __netdev_alloc_skb(bp->dev, NEW_SKB_SIZE, GFP_NOIO);
 			if (!newskb)
 				return -ENOMEM;
 			bp->descr_block_virt->rcv_data[i+j].long_0 = (u32) (PI_RCV_DESCR_M_SOP |
-- 
1.6.1.2.253.ga34a

