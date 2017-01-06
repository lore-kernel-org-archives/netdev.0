From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 4/7] net: ethernet: ti: cpdma: use devm_ioremap
Date: Fri, 6 Jan 2017 14:07:32 -0600
Message-ID: <20170106200735.4210-5-grygorii.strashko@ti.com>
References: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:58961 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937972AbdAFUHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:07:40 -0500
In-Reply-To: <20170106200735.4210-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use devm_ioremap() and simplify the code.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 7080eb9..b229bf3 100644
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
2.10.1.dirty
