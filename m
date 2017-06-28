From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 03/14] amd-xgbe: Use the proper register during
 PTP initialization
Date: Wed, 28 Jun 2017 13:41:49 -0500
Message-ID: <20170628184149.21972.76881.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0061.outbound.protection.outlook.com ([104.47.34.61]:64512
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751614AbdF1Sly (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:41:54 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During PTP initialization, the Timestamp Control register should be
cleared and not the Tx Configuration register.  While this typo causes
the wrong register to be cleared, the default value of each register and
and the fact that the Tx Configuration register is programmed afterwards
doesn't result in a bug, hence only fixing in net-next.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
index a533a6c..d06d260 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
@@ -267,7 +267,7 @@ void xgbe_ptp_register(struct xgbe_prv_data *pdata)
 			 ktime_to_ns(ktime_get_real()));
 
 	/* Disable all timestamping to start */
-	XGMAC_IOWRITE(pdata, MAC_TCR, 0);
+	XGMAC_IOWRITE(pdata, MAC_TSCR, 0);
 	pdata->tstamp_config.tx_type = HWTSTAMP_TX_OFF;
 	pdata->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
 }
