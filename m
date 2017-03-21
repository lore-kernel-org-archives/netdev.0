From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] net: dwc-xlgmac: fix an error code in
 xlgmac_alloc_pages()
Date: Tue, 21 Mar 2017 23:42:27 +0300
Message-ID: <20170321204227.GB22118@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jie Deng <jiedeng@synopsys.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dma_mapping_error() returns true if there is an error but we want
to return -ENOMEM and not 1.

Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
index 55c796ed7d26..39b5cb967bba 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
@@ -335,7 +335,6 @@ static int xlgmac_alloc_pages(struct xlgmac_pdata *pdata,
 {
 	struct page *pages = NULL;
 	dma_addr_t pages_dma;
-	int ret;
 
 	/* Try to obtain pages, decreasing order if necessary */
 	gfp |= __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
@@ -352,10 +351,9 @@ static int xlgmac_alloc_pages(struct xlgmac_pdata *pdata,
 	/* Map the pages */
 	pages_dma = dma_map_page(pdata->dev, pages, 0,
 				 PAGE_SIZE << order, DMA_FROM_DEVICE);
-	ret = dma_mapping_error(pdata->dev, pages_dma);
-	if (ret) {
+	if (dma_mapping_error(pdata->dev, pages_dma)) {
 		put_page(pages);
-		return ret;
+		return -ENOMEM;
 	}
 
 	pa->pages = pages;
