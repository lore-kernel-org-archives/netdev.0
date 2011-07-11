From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 08/46] net/wireless: b43: fix DMA direction for RX buffers
Date: Mon, 11 Jul 2011 02:52:47 +0200 (CEST)
Message-ID: <dba672ae50fdb3286d5b4db6fecfb331fad31da6.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43667 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174Ab1GKAwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:50 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/wireless/b43/dma.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/=
dma.c
index 7a09a46..15b11f0 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -336,8 +336,9 @@ static inline
 		dmaaddr =3D dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len, DMA_TO_DEVICE);
 	} else {
+		/* DMA_BIDIRECTIONAL because of b43_poison_rx_buffer() */
 		dmaaddr =3D dma_map_single(ring->dev->dev->dma_dev,
-					 buf, len, DMA_FROM_DEVICE);
+					 buf, len, DMA_BIDIRECTIONAL);
 	}
=20
 	return dmaaddr;
@@ -352,7 +353,7 @@ static inline
 				 addr, len, DMA_TO_DEVICE);
 	} else {
 		dma_unmap_single(ring->dev->dev->dma_dev,
-				 addr, len, DMA_FROM_DEVICE);
+				 addr, len, DMA_BIDIRECTIONAL);
 	}
 }
=20
@@ -362,7 +363,7 @@ static inline
 {
 	B43_WARN_ON(ring->tx);
 	dma_sync_single_for_cpu(ring->dev->dev->dma_dev,
-				    addr, len, DMA_FROM_DEVICE);
+				    addr, len, DMA_BIDIRECTIONAL);
 }
=20
 static inline
@@ -371,7 +372,7 @@ static inline
 {
 	B43_WARN_ON(ring->tx);
 	dma_sync_single_for_device(ring->dev->dev->dma_dev,
-				   addr, len, DMA_FROM_DEVICE);
+				   addr, len, DMA_BIDIRECTIONAL);
 }
=20
 static inline
--=20
1.7.5.4

