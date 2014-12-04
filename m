From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Prevent Tx cleanup stall
Date: Thu, 4 Dec 2014 11:52:35 -0600
Message-ID: <20141204175235.11100.52433.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0107.outbound.protection.outlook.com ([207.46.100.107]:6112
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932521AbaLDRwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 12:52:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When performing Tx cleanup, the dirty index counter is compared to the
current index counter as one of the tests used to determine when to stop
cleanup. The "less than" test will fail when the current index counter
rolls over to zero causing cleanup to never occur again. Update the test
to a "not equal" to avoid this situation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2349ea9..d0e3530 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1554,7 +1554,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	spin_lock_irqsave(&ring->lock, flags);
 
 	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
-	       (ring->dirty < ring->cur)) {
+	       (ring->dirty != ring->cur)) {
 		rdata = XGBE_GET_DESC_DATA(ring, ring->dirty);
 		rdesc = rdata->rdesc;
 
