From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 4/7] net: ethernet: ti: cpdma: use devm_ioremap
Date: Thu, 1 Dec 2016 17:34:29 -0600
Message-ID: <20161201233432.6182-5-grygorii.strashko@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201233432.6182-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use devm_ioremap() and simplify the code.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index db0a7fd..ba892bb 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -195,8 +195,6 @@ static void cpdma_desc_pool_destroy(struct cpdma_ctlr *ctlr)
 	if (pool->cpumap)
 		dma_free_coherent(ctlr->dev, pool->mem_size, pool->cpumap,
 				  pool->phys);
-	else
-		iounmap(pool->iomap);
 }
 
 /*
@@ -231,7 +229,8 @@ int cpdma_desc_pool_create(struct cpdma_ctlr *ctlr)
 
 	if (cpdma_params->desc_mem_phys) {
 		pool->phys  = cpdma_params->desc_mem_phys;
-		pool->iomap = ioremap(pool->phys, pool->mem_size);
+		pool->iomap = devm_ioremap(ctlr->dev, pool->phys,
+					   pool->mem_size);
 		pool->hw_addr = cpdma_params->desc_hw_addr;
 	} else {
 		pool->cpumap = dma_alloc_coherent(ctlr->dev,  pool->mem_size,
-- 
2.10.1
