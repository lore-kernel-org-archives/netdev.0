From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 15/46] net/wireless: b43: use kfree_skb() for untouched
 skbs
Date: Mon, 11 Jul 2011 02:52:50 +0200 (CEST)
Message-ID: <08fc87f027ad07874b83b98786215c94a7acf8b9.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43686 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab1GKAwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:54 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/wireless/b43/dma.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/=
dma.c
index 15b11f0..ed78f14 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -592,7 +592,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *=
ring,
 		/* ugh. try to realloc in zone_dma */
 		gfp_flags |=3D GFP_DMA;
=20
-		dev_kfree_skb_any(skb);
+		kfree_skb(skb);
=20
 		skb =3D __dev_alloc_skb(ring->rx_buffersize, gfp_flags);
 		if (unlikely(!skb))
@@ -602,7 +602,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *=
ring,
 					 ring->rx_buffersize, 0);
 		if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
 			b43err(ring->dev->wl, "RX DMA buffer allocation failed\n");
-			dev_kfree_skb_any(skb);
+			kfree_skb(skb);
 			return -EIO;
 		}
 	}
@@ -645,7 +645,7 @@ static int alloc_initial_descbuffers(struct b43_dma=
ring *ring)
 		desc =3D ring->ops->idx2desc(ring, i, &meta);
=20
 		unmap_descbuffer(ring, meta->dmaaddr, ring->rx_buffersize, 0);
-		dev_kfree_skb(meta->skb);
+		kfree_skb(meta->skb);
 	}
 	goto out;
 }
--=20
1.7.5.4

