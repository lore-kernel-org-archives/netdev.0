From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 4/4] amd-xgbe: Use the Tx queue count for Tx flow
 control support
Date: Fri, 29 Aug 2014 13:17:08 -0500
Message-ID: <20140829181708.3257.67620.stgit@tlendack-t1.amdoffice.net>
References: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0237.outbound.protection.outlook.com ([207.46.163.237]:56208
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752914AbaH2SRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 14:17:13 -0400
In-Reply-To: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring Tx flow control the Rx queue count was used instead of
the Tx queue count for looping through the Tx hardware queues. Fix the
code to use the Tx queue count.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index acde00c..6d0207e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -348,7 +348,7 @@ static int xgbe_disable_tx_flow_control(struct xgbe_prv_data *pdata)
 
 	/* Clear MAC flow control */
 	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
-	q_count = min_t(unsigned int, pdata->rx_q_count, max_q_count);
+	q_count = min_t(unsigned int, pdata->tx_q_count, max_q_count);
 	reg = MAC_Q0TFCR;
 	for (i = 0; i < q_count; i++) {
 		reg_val = XGMAC_IOREAD(pdata, reg);
@@ -373,7 +373,7 @@ static int xgbe_enable_tx_flow_control(struct xgbe_prv_data *pdata)
 
 	/* Set MAC flow control */
 	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
-	q_count = min_t(unsigned int, pdata->rx_q_count, max_q_count);
+	q_count = min_t(unsigned int, pdata->tx_q_count, max_q_count);
 	reg = MAC_Q0TFCR;
 	for (i = 0; i < q_count; i++) {
 		reg_val = XGMAC_IOREAD(pdata, reg);
