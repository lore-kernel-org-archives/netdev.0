From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH V2] bgmac: Clean warning messages
Date: Sat,  7 Mar 2015 12:10:26 +0100
Message-ID: <1425726626-31785-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Senna Tschudin <peter.senna@gmail.com>
To: davem@davemloft.net, hauke@hauke-m.de,
	w-lkml@lebenslange-mailadresse.de, zajec5@gmail.com,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On my test environment the throughput of a file transfer drops
from 4.4MBps to 116KBps due the number of repeated warning
messages. This patch removes the warning messages as DMA works
correctly with addresses using 0xC0000000 bits.

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
Changes from V1:
   - Updated commit message. Thanks Rafa=C5=82 Mi=C5=82ecki <zajec5@gma=
il.com>

Changes from: bgmac: ratelimit warning messages
   - Remove the messages instead of using printk_ratelimit()

 drivers/net/ethernet/broadcom/bgmac.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 676ffe0..0469f72 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -302,9 +302,6 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *=
bgmac,
 	slot->skb =3D skb;
 	slot->dma_addr =3D dma_addr;
=20
-	if (slot->dma_addr & 0xC0000000)
-		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need =
translation trick\n");
-
 	return 0;
 }
=20
@@ -505,8 +502,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 				  ring->mmio_base);
 			goto err_dma_free;
 		}
-		if (ring->dma_base & 0xC0000000)
-			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
=20
 		ring->unaligned =3D bgmac_dma_unaligned(bgmac, ring,
 						      BGMAC_DMA_RING_TX);
@@ -536,8 +531,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 			err =3D -ENOMEM;
 			goto err_dma_free;
 		}
-		if (ring->dma_base & 0xC0000000)
-			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
=20
 		ring->unaligned =3D bgmac_dma_unaligned(bgmac, ring,
 						      BGMAC_DMA_RING_RX);
--=20
2.1.0
