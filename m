From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH resend] bcm43xx-d80211: Fix DMA TX skb doublefree
Date: Tue, 23 Jan 2007 17:40:18 +0100
Message-ID: <200701231740.18708.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56048
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932954AbXAWQpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 11:45:11 -0500
To: John Linville <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a possible double-free of the TX skb buffers.
Always NULL the pointer after freeing.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

--

I already sent this patch to you on 21 Dec 2006.
This is a pretty critical patch, so I'd like to make sure
it's in your merge queue and is not lost.


Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-12-07 17:25:19.000000000 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-12-21 19:05:28.000000000 +0100
@@ -388,6 +388,7 @@ void free_descriptor_buffer(struct bcm43
 			dev_kfree_skb_irq(meta->skb);
 		else
 			dev_kfree_skb(meta->skb);
+		meta->skb = NULL;
 	}
 }
 
@@ -1131,6 +1132,7 @@ void bcm43xx_dma_handle_txstatus(struct 
 			meta->txstat.retry_count = status->frame_count - 1;
 			ieee80211_tx_status_irqsafe(bcm->ieee, meta->skb, &(meta->txstat));
 			/* skb is freed by ieee80211_tx_status_irqsafe() */
+			meta->skb = NULL;
 		} else {
 			/* No need to call free_descriptor_buffer here, as
 			 * this is only the txhdr, which is not allocated.


-- 
Greetings Michael.

