From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/5] bcm43xx-d80211: fix sending of fragments
Date: Mon, 12 Jun 2006 21:16:06 +0200 (CEST)
Message-ID: <20060612191606.7AA8E48391@silver.suse.cz>
References: <20060612211454.409884000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:4007 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932093AbWFLTOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 15:14:53 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060612211454.409884000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes fragmentation work with bcm43xx.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c |    2 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -703,7 +703,7 @@ static int dma_tx_fragment(struct bcm43x
 	bcm43xx_generate_txhdr(ring->bcm,
 			       (struct bcm43xx_txhdr *)hdr_skb->data,
 			       skb->data, skb->len,
-			       1,//FIXME
+			       ctl->first_fragment,
 			       generate_cookie(ring, slot),
 			       ctl);
 
--- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
+++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
@@ -183,7 +183,7 @@ static void pio_tx_write_fragment(struct
 	assert(skb_shinfo(skb)->nr_frags == 0);
 	bcm43xx_generate_txhdr(queue->bcm,
 			       &txhdr, skb->data, skb->len,
-			       1,//FIXME
+			       packet->ctl->first_fragment,
 			       generate_cookie(queue, pio_txpacket_getindex(packet)),
 			       packet->ctl);
 
