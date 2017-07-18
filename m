From: "Gustavo A. R. Silva" <gustavo-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Subject: [PATCH] net: ethernet: mediatek: remove useless code in mtk_poll_tx()
Date: Tue, 18 Jul 2017 15:48:06 -0500
Message-ID: <20170718204805.GA30888@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 "Gustavo A. R. Silva" <gustavo-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
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

Remove useless local variable _condition_ and the code related.

Signed-off-by: Gustavo A. R. Silva <gustavo-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index b3d0c2e..7e95cf5 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1027,7 +1027,6 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget)
 	unsigned int done[MTK_MAX_DEVS];
 	unsigned int bytes[MTK_MAX_DEVS];
 	u32 cpu, dma;
-	static int condition;
 	int total = 0, i;
 
 	memset(done, 0, sizeof(done));
@@ -1051,10 +1050,8 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget)
 			mac = 1;
 
 		skb = tx_buf->skb;
-		if (!skb) {
-			condition = 1;
+		if (!skb)
 			break;
-		}
 
 		if (skb != (struct sk_buff *)MTK_DMA_DUMMY_DESC) {
 			bytes[mac] += skb->len;
-- 
2.5.0
