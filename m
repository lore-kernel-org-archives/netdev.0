From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe: Use disable_irq_nosync when in IRQ
 context
Date: Tue, 9 Dec 2014 14:54:08 -0600
Message-ID: <20141209205408.26097.70441.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0133.outbound.protection.outlook.com ([157.56.111.133]:39072
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751190AbaLIUyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 15:54:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The disable_irq_nosync function, not the disable_irq function, must be
used to disable the DMA channel interrupt from within the interrupt
service routine. Change the disable_irq call to disable_irq_nosync.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index bedfdb1..bf6bf11 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -396,7 +396,7 @@ static irqreturn_t xgbe_dma_isr(int irq, void *data)
 	 */
 	if (napi_schedule_prep(&channel->napi)) {
 		/* Disable Tx and Rx interrupts */
-		disable_irq(channel->dma_irq);
+		disable_irq_nosync(channel->dma_irq);
 
 		/* Turn on polling */
 		__napi_schedule(&channel->napi);
