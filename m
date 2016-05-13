From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 1/2] net: pxa168_eth: use {readl|writel}_relaxed instead of
 readl/writel
Date: Fri, 13 May 2016 19:57:29 +0800
Message-ID: <1463140650-7038-2-git-send-email-jszhang@marvell.com>
References: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1463140650-7038-1-git-send-email-jszhang@marvell.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Since appropriate memory barriers are already there, use the relaxed
version to improve performance a bit.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index c442f6a..db774e3 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -286,12 +286,12 @@ static int pxa168_eth_stop(struct net_device *dev);
 
 static inline u32 rdl(struct pxa168_eth_private *pep, int offset)
 {
-	return readl(pep->base + offset);
+	return readl_relaxed(pep->base + offset);
 }
 
 static inline void wrl(struct pxa168_eth_private *pep, int offset, u32 data)
 {
-	writel(data, pep->base + offset);
+	writel_relaxed(data, pep->base + offset);
 }
 
 static void abort_dma(struct pxa168_eth_private *pep)
-- 
2.8.1
