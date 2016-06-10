From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 07/11] net: mediatek: fix threshold value
Date: Fri, 10 Jun 2016 13:28:04 +0200
Message-ID: <1465558088-15265-8-git-send-email-john@phrozen.org>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465558088-15265-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The logic to calculate the threshold value for stopping the TX queue is
bad. Currently it will always use 1/2 of the rings size, which is way t=
oo
much. Set the threshold to MAX_SKB_FRAGS. This makes sure that the queu=
e
is stopped when there is not enough room to accept an additional segmen=
t.=C2=A0

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/=
ethernet/mediatek/mtk_eth_soc.c
index 93af4e3..8b289e1 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1012,8 +1012,7 @@ static int mtk_tx_alloc(struct mtk_eth *eth)
 	atomic_set(&ring->free_count, MTK_DMA_SIZE - 2);
 	ring->next_free =3D &ring->dma[0];
 	ring->last_free =3D &ring->dma[MTK_DMA_SIZE - 2];
-	ring->thresh =3D max((unsigned long)MTK_DMA_SIZE >> 2,
-			      MAX_SKB_FRAGS);
+	ring->thresh =3D MAX_SKB_FRAGS;
=20
 	/* make sure that all changes to the dma ring are flushed before we
 	 * continue
--=20
1.7.10.4
