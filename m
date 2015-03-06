From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 2/2] net: macb: Fix multi queue support for xilinx ZynqMP
Date: Fri,  6 Mar 2015 18:29:12 +0100
Message-ID: <d7fb06d16c8139004cf8f580c30b1078d2eb8086.1425662901.git.michal.simek@xilinx.com>
References: <299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
In-Reply-To: <299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
References: <299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>

ZynqMP soc has single interrupt for all the queue events. So,
passing the IRQF_SHARED flag for interrupt registration call.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

Changes in v2:
- Based it on net-next
- Add Ack from Nicolas

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0436aefa49e4..f6c8935a4f0b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2339,7 +2339,7 @@ static int macb_probe(struct platform_device *pdev)
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
