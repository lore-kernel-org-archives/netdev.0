From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Use proper Rx flow control register
Date: Tue, 20 Jan 2015 12:20:31 -0600
Message-ID: <20150120182031.20236.62843.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:50379 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751145AbbATSUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 13:20:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated hardware documention shows the Rx flow control settings were
moved from the Rx queue operation mode register to a new Rx queue flow
control register.  The old flow control settings are now reserved areas
of the Rx queue operation mode register. Update the code to use the new
register.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    9 +++++----
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |    4 ++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 75b08c6..29a0927 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -767,16 +767,17 @@
 #define MTL_Q_RQOMR			0x40
 #define MTL_Q_RQMPOCR			0x44
 #define MTL_Q_RQDR			0x4c
+#define MTL_Q_RQFCR			0x50
 #define MTL_Q_IER			0x70
 #define MTL_Q_ISR			0x74
 
 /* MTL queue register entry bit positions and sizes */
+#define MTL_Q_RQFCR_RFA_INDEX		1
+#define MTL_Q_RQFCR_RFA_WIDTH		6
+#define MTL_Q_RQFCR_RFD_INDEX		17
+#define MTL_Q_RQFCR_RFD_WIDTH		6
 #define MTL_Q_RQOMR_EHFC_INDEX		7
 #define MTL_Q_RQOMR_EHFC_WIDTH		1
-#define MTL_Q_RQOMR_RFA_INDEX		8
-#define MTL_Q_RQOMR_RFA_WIDTH		3
-#define MTL_Q_RQOMR_RFD_INDEX		13
-#define MTL_Q_RQOMR_RFD_WIDTH		3
 #define MTL_Q_RQOMR_RQS_INDEX		16
 #define MTL_Q_RQOMR_RQS_WIDTH		9
 #define MTL_Q_RQOMR_RSF_INDEX		5
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 53f5f66..4c66cd1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2079,10 +2079,10 @@ static void xgbe_config_flow_control_threshold(struct xgbe_prv_data *pdata)
 
 	for (i = 0; i < pdata->rx_q_count; i++) {
 		/* Activate flow control when less than 4k left in fifo */
-		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RFA, 2);
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQFCR, RFA, 2);
 
 		/* De-activate flow control when more than 6k left in fifo */
-		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RFD, 4);
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQFCR, RFD, 4);
 	}
 }
 
