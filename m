From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 3/9] amd-xgbe: Use __napi_schedule_irqoff
Date: Wed, 17 Feb 2016 11:48:29 -0600
Message-ID: <20160217174829.26246.21639.stgit@tlendack-t1.amdoffice.net>
References: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0079.outbound.protection.outlook.com ([157.56.110.79]:55486
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161024AbcBQSDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 13:03:44 -0500
In-Reply-To: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
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
index 5a4d9ca..80ef404 100644
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
