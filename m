From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Fix velocity driver unmapping incorrect size.
Date: Sun, 21 Jun 2009 23:37:35 -0400
Message-ID: <20090622033735.GA9923@redhat.com>
References: <20090621173745.GC26093@redhat.com> <20090621.184345.194558005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43595 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636AbZFVDhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 23:37:35 -0400
Content-Disposition: inline
In-Reply-To: <20090621.184345.194558005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh man, this was subtle.  How did this never bite us before ?
-- 

When a packet is greater than ETH_ZLEN, we end up assigning the
boolean result of a comparison to the size we unmap.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index b02f7ad..46405e9 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1847,7 +1847,7 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 	 */
 	if (tdinfo->skb_dma) {
 
-		pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
+		pktlen = (skb->len > ETH_ZLEN ? skb->len : ETH_ZLEN);
 		for (i = 0; i < tdinfo->nskb_dma; i++) {
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], le16_to_cpu(td->tdesc1.len), PCI_DMA_TODEVICE);
