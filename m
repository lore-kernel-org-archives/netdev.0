From: akpm@linux-foundation.org
Subject: [patch 03/11] vioc cast warningfix
Date: Thu, 26 Apr 2007 00:23:16 -0700
Message-ID: <200704260723.l3Q7NGFH023826@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	driver-support@fabric7.com, schidambaram@fabric7.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:50009 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933320AbXDZHYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:24:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

i386:

drivers/net/vioc/vioc_receive.c: In function '_vioc_fill_n_xfer':
drivers/net/vioc/vioc_receive.c:198: warning: cast from pointer to integer of different size
drivers/net/vioc/vioc_receive.c:199: warning: cast to pointer from integer of different size
drivers/net/vioc/vioc_irq.c: In function 'vioc_set_intr_func_param':
drivers/net/vioc/vioc_irq.c:344: warning: cast to pointer from integer of different size

This code looks fishy.

Cc: Sriram Chidambaram <schidambaram@fabric7.com>
Cc: Fabric7 Driver-Support <driver-support@fabric7.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/vioc/vioc_receive.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/vioc/vioc_receive.c~vioc-cast-warning-fix drivers/net/vioc/vioc_receive.c
--- a/drivers/net/vioc/vioc_receive.c~vioc-cast-warning-fix
+++ a/drivers/net/vioc/vioc_receive.c
@@ -195,8 +195,8 @@ static u32 _vioc_fill_n_xfer(struct rxdq
 				goto undo_refill;
 			}
 			/* Cache align */
-			x = (u64) skb->data;
-			skb->data = (unsigned char *)ALIGN(x, 64);
+			x = (u64)(long)skb->data;
+			skb->data = (unsigned char *)(long)ALIGN(x, 64);
 			rxdq->vbuf[idx].skb = skb;
 			rxdq->vbuf[idx].dma =
 			    pci_map_single(rxdq->viocdev->pdev,
_
