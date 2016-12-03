From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpdma: use desc_read in chan_process instead of raw read
Date: Sat,  3 Dec 2016 04:05:15 +0200
Message-ID: <1480730715-16000-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is desc_read() macros to read desc fields, so no need to
use __raw_readl();

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/davinci_cpdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c776e45..d96dca5 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -1132,7 +1132,7 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	}
 	desc_dma = desc_phys(pool, desc);
 
-	status	= __raw_readl(&desc->hw_mode);
+	status = desc_read(desc, hw_mode);
 	outlen	= status & 0x7ff;
 	if (status & CPDMA_DESC_OWNER) {
 		chan->stats.busy_dequeue++;
-- 
2.7.4
