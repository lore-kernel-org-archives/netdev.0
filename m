From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/3] bcm43xx-d80211: fix sending of fragments
Date: Fri, 23 Jun 2006 15:09:34 +0200 (CEST)
Message-ID: <20060623130934.895A8483AC@silver.suse.cz>
References: <20060623150913.986994000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28118 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964813AbWFWNIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 09:08:12 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150913.986994000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes fragmentation work with bcm43xx.

Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

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
@@ -186,7 +186,7 @@ static void pio_tx_write_fragment(struct
 	assert(skb_shinfo(skb)->nr_frags == 0);
 	bcm43xx_generate_txhdr(queue->bcm,
 			       &txhdr, skb->data, skb->len,
-			       1,//FIXME
+			       packet->txstat.control.first_fragment,
 			       generate_cookie(queue, packet),
 			       &packet->txstat.control);
 
