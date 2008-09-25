From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via-velocity warnings on sparc64
Date: Thu, 25 Sep 2008 23:37:14 +0200
Message-ID: <20080925213714.GA13178@electric-eye.fr.zoreil.com>
References: <Pine.SOC.4.64.0809251007180.6342@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33639 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754051AbYIYVhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 17:37:18 -0400
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0809251007180.6342@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meelis Roos <mroos@linux.ee> :
> Noticed this while compiling 2.6.27-rc7+git on sparc64 - maybe it is of 
> interest.
> 
>   CC [M]  drivers/net/via-velocity.o
> drivers/net/via-velocity.c: In function 'velocity_free_rd_ring':
> drivers/net/via-velocity.c:1275: warning: cast from pointer to integer of different size
> drivers/net/via-velocity.c: In function 'velocity_free_td_ring_entry':
> drivers/net/via-velocity.c:1336: warning: cast from pointer to integer of different size

Something like the patch below maybe ?

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 007c129..ad20f96 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1272,7 +1272,7 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 			continue;
 		pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
 				 PCI_DMA_FROMDEVICE);
-		rd_info->skb_dma = (dma_addr_t) NULL;
+		rd_info->skb_dma = 0;
 
 		dev_kfree_skb(rd_info->skb);
 		rd_info->skb = NULL;
@@ -1333,7 +1333,7 @@ static void velocity_free_td_ring_entry(struct velocity_info *vptr,
 			if (td_info->skb_dma[i]) {
 				pci_unmap_single(vptr->pdev, td_info->skb_dma[i],
 					td_info->skb->len, PCI_DMA_TODEVICE);
-				td_info->skb_dma[i] = (dma_addr_t) NULL;
+				td_info->skb_dma[i] = 0;
 			}
 		}
 		dev_kfree_skb(td_info->skb);

