From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 2/5] amd-xgbe: Clear the proper MTL interrupt register
Date: Wed, 2 Jul 2014 13:04:34 -0500
Message-ID: <20140702180434.14996.7711.stgit@tlendack-t1.amdoffice.net>
References: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0206.outbound.protection.outlook.com ([207.46.163.206]:59431
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757375AbaGBSE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 14:04:57 -0400
In-Reply-To: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initializing the MTL interrupts the interrupt status
register is written to instead of the interrupt enable register.
Since no MTL interrupts are being enabled and the default state
is for MTL interrupts to be disabled this did not cause a problem,
but needs to be fixed to target the correct register.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index a56069c..e9fed23b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -486,7 +486,7 @@ static void xgbe_enable_mtl_interrupts(struct xgbe_prv_data *pdata)
 		XGMAC_MTL_IOWRITE(pdata, i, MTL_Q_ISR, mtl_q_isr);
 
 		/* No MTL interrupts to be enabled */
-		XGMAC_MTL_IOWRITE(pdata, i, MTL_Q_ISR, 0);
+		XGMAC_MTL_IOWRITE(pdata, i, MTL_Q_IER, 0);
 	}
 }
 
