From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 2/2] dpaa_eth: reuse the dma_ops provided by the FMan MAC device
Date: Mon, 19 Jun 2017 18:04:17 +0300
Message-ID: <1497884657-3744-3-git-send-email-madalin.bucur@nxp.com>
References: <1497884657-3744-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497884657-3744-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the use of arch_setup_dma_ops() that was not exported
and was breaking loadable module compilation.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 9a520e4..290ad05 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2647,7 +2647,7 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 	priv->buf_layout[TX].priv_data_size = DPAA_TX_PRIV_DATA_SIZE; /* Tx */
 
 	/* device used for DMA mapping */
-	arch_setup_dma_ops(dev, 0, 0, NULL, false);
+	set_dma_ops(dev, get_dma_ops(&pdev->dev));
 	err = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(40));
 	if (err) {
 		dev_err(dev, "dma_coerce_mask_and_coherent() failed\n");
-- 
2.1.0
