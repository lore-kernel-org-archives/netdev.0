From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Fix IRQ processing when running in single IRQ
 mode
Date: Wed, 4 Jan 2017 15:07:16 -0600
Message-ID: <20170104210716.8401.99717.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0083.outbound.protection.outlook.com ([104.47.34.83]:52145
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S937254AbdADVHm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 16:07:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in single IRQ mode, the additional IRQ routines were being
skipped because only the XGMAC interrupt status was being checked.
Update the code so that the additional IRQ routines are checked whenever
an interrupt is received.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 155190d..9943629 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -539,6 +539,7 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 		}
 	}
 
+isr_done:
 	/* If there is not a separate AN irq, handle it here */
 	if (pdata->dev_irq == pdata->an_irq)
 		pdata->phy_if.an_isr(irq, pdata);
@@ -551,7 +552,6 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 	if (pdata->vdata->i2c_support && (pdata->dev_irq == pdata->i2c_irq))
 		pdata->i2c_if.i2c_isr(irq, pdata);
 
-isr_done:
 	return IRQ_HANDLED;
 }
 
