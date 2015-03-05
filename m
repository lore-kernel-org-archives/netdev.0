From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 2/2] net: macb: Fix multi queue support for xilinx ZynqMP soc
Date: Thu,  5 Mar 2015 14:04:12 +0100
Message-ID: <364d36c03e63ef33c5f52a8eaa4418320c6c0d3f.1425560649.git.michal.simek@xilinx.com>
References: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
In-Reply-To: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
References: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>

ZynqMP soc has single interrupt for all the queue events. So,
passing the IRQF_SHARED flag for interrupt registration call.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 24b1eb466e52..0493c3e6bbbe 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2319,7 +2319,7 @@ static int macb_probe(struct platform_device *pdev)
 		 */
 		queue->irq = platform_get_irq(pdev, q);
 		err = devm_request_irq(&pdev->dev, queue->irq, macb_interrupt,
-				       0, dev->name, queue);
+				       IRQF_SHARED, dev->name, queue);
 		if (err) {
 			dev_err(&pdev->dev,
 				"Unable to request IRQ %d (error %d)\n",
-- 
1.8.2.3
