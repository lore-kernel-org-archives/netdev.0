From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/9] amd-xgbe: Use __napi_schedule_irqoff
Date: Fri, 12 Feb 2016 08:32:43 -0600
Message-ID: <20160212143243.23973.20115.stgit@tlendack-t1.amdoffice.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0068.outbound.protection.outlook.com ([65.55.169.68]:34181
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750802AbcBLOsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:48:46 -0500
In-Reply-To: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from calling __napi_schedule to __napi_schedule_irqoff when running
in interrupt context or when called by netpoll with interrupts already
disabled. The Tx timer function will continue to use __napi_schedule.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2aebbe2..b0ff700 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -356,7 +356,7 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 				xgbe_disable_rx_tx_ints(pdata);
 
 				/* Turn on polling */
-				__napi_schedule(&pdata->napi);
+				__napi_schedule_irqoff(&pdata->napi);
 			}
 		}
 
@@ -409,7 +409,7 @@ static irqreturn_t xgbe_dma_isr(int irq, void *data)
 		disable_irq_nosync(channel->dma_irq);
 
 		/* Turn on polling */
-		__napi_schedule(&channel->napi);
+		__napi_schedule_irqoff(&channel->napi);
 	}
 
 	return IRQ_HANDLED;
