From: John Linn <john.linn@xilinx.com>
Subject: [PATCH 1/2] net: ll_temac: remove virt_to_bus call
Date: Thu, 8 Apr 2010 11:08:01 -0600
Message-ID: <e94678c0-497a-4cd3-a0a6-9d94fdcf99ed@SG2EHSMHS017.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john.williams@petalogix.com, michal.simek@petalogix.com,
	John Linn <john.linn@xilinx.com>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe005.messaging.microsoft.com ([207.46.51.79]:41431 "EHLO
	SG2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932653Ab0DHRIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 13:08:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The virt_to_bus call should not be used any longer as it's
considered illegal. The driver has the physical address of
the buffer in the descriptor such that it's not necessary
anyway.

Signed-off-by: John Linn <john.linn@xilinx.com>
---
 drivers/net/ll_temac_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index ba617e3..ce9aa78 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -612,7 +612,6 @@ static void ll_temac_recv(struct net_device *ndev)
 	struct cdmac_bd *cur_p;
 	dma_addr_t tail_p;
 	int length;
-	unsigned long skb_vaddr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->rx_lock, flags);
@@ -626,8 +625,7 @@ static void ll_temac_recv(struct net_device *ndev)
 		skb = lp->rx_skb[lp->rx_bd_ci];
 		length = cur_p->app4 & 0x3FFF;
 
-		skb_vaddr = virt_to_bus(skb->data);
-		dma_unmap_single(ndev->dev.parent, skb_vaddr, length,
+		dma_unmap_single(ndev->dev.parent, cur_p->phys, length,
 				 DMA_FROM_DEVICE);
 
 		skb_put(skb, length);
-- 
1.6.2.1



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


