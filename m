From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 2/2] amd-xgbe: Enable interrupts for all management
 counters
Date: Fri, 5 Sep 2014 18:02:36 -0500
Message-ID: <20140905230236.27896.17966.stgit@tlendack-t1.amdoffice.net>
References: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0124.outbound.protection.outlook.com ([65.55.169.124]:31328
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754254AbaIEXCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:02:54 -0400
In-Reply-To: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the management counters reach a threshold they will generate an
interrupt so the value can be saved and the counter reset. The
current code does not enable this interrupt on all counters. This
can result in inaccurate statistics.

Update the code to enable all the counters to generate an interrupt
when its threshold is exceeded.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index f3d04f1..ea27383 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -509,8 +509,8 @@ static void xgbe_enable_mac_interrupts(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE(pdata, MAC_IER, mac_ier);
 
 	/* Enable all counter interrupts */
-	XGMAC_IOWRITE_BITS(pdata, MMC_RIER, ALL_INTERRUPTS, 0xff);
-	XGMAC_IOWRITE_BITS(pdata, MMC_TIER, ALL_INTERRUPTS, 0xff);
+	XGMAC_IOWRITE_BITS(pdata, MMC_RIER, ALL_INTERRUPTS, 0xffffffff);
+	XGMAC_IOWRITE_BITS(pdata, MMC_TIER, ALL_INTERRUPTS, 0xffffffff);
 }
 
 static int xgbe_set_gmii_speed(struct xgbe_prv_data *pdata)
