From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/7] 8139cp: remove gratuitous indirection
Date: Thu, 31 Aug 2006 22:49:07 +0200
Message-ID: <20060831204907.GB14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63915 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932444AbWHaUxv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:53:51 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev is an argument of the current function.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

c48e9399e895834f26dff9149de1930ba18a0d6c
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 8f5d779..ae9bb75 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -571,7 +571,7 @@ rx_status_loop:
 
 		if (netif_msg_rx_status(cp))
 			printk(KERN_DEBUG "%s: rx slot %d status 0x%x len %d\n",
-			       cp->dev->name, rx_tail, status, len);
+			       dev->name, rx_tail, status, len);
 
 		buflen = cp->rx_buf_sz + RX_OFFSET;
 		new_skb = dev_alloc_skb (buflen);
@@ -581,7 +581,7 @@ rx_status_loop:
 		}
 
 		skb_reserve(new_skb, RX_OFFSET);
-		new_skb->dev = cp->dev;
+		new_skb->dev = dev;
 
 		pci_unmap_single(cp->pdev, mapping,
 				 buflen, PCI_DMA_FROMDEVICE);
-- 
1.3.1

