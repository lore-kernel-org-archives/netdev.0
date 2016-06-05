From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 06/12] net: mediatek: add next data pointer coherency
 protection
Date: Sun,  5 Jun 2016 08:32:59 +0200
Message-ID: <1465108385-38286-7-git-send-email-john@phrozen.org>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1465108385-38286-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The QDMA engine can fail to update the register pointing to the next TX
descriptor if this bit does not get set in the QDMA configuration register.
Not setting this bit can result in invalid values inside the TX rings
registers which will causes TX stalls.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 0610262..bfac376 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1261,7 +1261,7 @@ static int mtk_start_dma(struct mtk_eth *eth)
 	mtk_w32(eth,
 		MTK_TX_WB_DDONE | MTK_RX_DMA_EN | MTK_TX_DMA_EN |
 		MTK_RX_2B_OFFSET | MTK_DMA_SIZE_16DWORDS |
-		MTK_RX_BT_32DWORDS,
+		MTK_RX_BT_32DWORDS | MTK_NDP_CO_PRO,
 		MTK_QDMA_GLO_CFG);
 
 	return 0;
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 57f7e8a..a5eb7c6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -91,6 +91,7 @@
 #define MTK_QDMA_GLO_CFG	0x1A04
 #define MTK_RX_2B_OFFSET	BIT(31)
 #define MTK_RX_BT_32DWORDS	(3 << 11)
+#define MTK_NDP_CO_PRO		BIT(10)
 #define MTK_TX_WB_DDONE		BIT(6)
 #define MTK_DMA_SIZE_16DWORDS	(2 << 4)
 #define MTK_RX_DMA_BUSY		BIT(3)
-- 
1.7.10.4
