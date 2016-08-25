From: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v3 2/2] net: ethernet: mediatek: modify GDM to send
 packets to the PDMA for RX
Date: Thu, 25 Aug 2016 10:26:31 +0800
Message-ID: <1472091991-1814-3-git-send-email-nelson.chang@mediatek.com>
References: <1472091991-1814-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 nelsonch.tw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472091991-1814-1-git-send-email-nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
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

Because we change to use the PDMA as the Ethernet RX DMA engine,
the patch modifies to set GDM to send packets to PDMA for RX.

Signed-off-by: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 0
 2 files changed, 2 insertions(+), 2 deletions(-)
 mode change 100755 => 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.c
 mode change 100755 => 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.h

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
old mode 100755
new mode 100644
index cbeb793..c47fef4
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1473,9 +1473,9 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	for (i = 0; i < 2; i++) {
 		u32 val = mtk_r32(eth, MTK_GDMA_FWD_CFG(i));
 
-		/* setup the forward port to send frame to QDMA */
+		/* setup the forward port to send frame to PDMA */
 		val &= ~0xffff;
-		val |= 0x5555;
+		val |= 0x0000;
 
 		/* Enable RX checksum */
 		val |= MTK_GDMA_ICS_EN | MTK_GDMA_TCS_EN | MTK_GDMA_UCS_EN;
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
old mode 100755
new mode 100644
-- 
1.9.1
