From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Use disable_irq_nosync from within timer
 function
Date: Fri, 5 Jun 2015 16:02:26 -0500
Message-ID: <20150605210226.14842.17410.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0114.outbound.protection.outlook.com ([157.56.111.114]:11136
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751556AbbFEVCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 17:02:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the Tx timer function runs in softirq context the driver needs
to call disable_irq_nosync instead of a disable_irq.

Reported-by: Josh Stone <jistone@redhat.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index db84ddc..9fd6c69 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -423,7 +423,7 @@ static void xgbe_tx_timer(unsigned long data)
 	if (napi_schedule_prep(napi)) {
 		/* Disable Tx and Rx interrupts */
 		if (pdata->per_channel_irq)
-			disable_irq(channel->dma_irq);
+			disable_irq_nosync(channel->dma_irq);
 		else
 			xgbe_disable_rx_tx_ints(pdata);
 
