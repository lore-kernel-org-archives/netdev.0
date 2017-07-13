From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net v2] cxgb4: ptp_clock_register() returns error pointers
Date: Thu, 13 Jul 2017 18:36:50 +0530
Message-ID: <1499951210-6283-1-git-send-email-ganeshgr@chelsio.com>
Cc: atul.gupta@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com, dan.carpenter@oracle.com,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:59484 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbdGMNJ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 09:09:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check ptp_clock_register() return not only for NULL but
also for error pointers, and also nullify adapter->ptp_clock
if ptp_clock_register() fails.

Fixes: 9c33e4208bce ("cxgb4: Add PTP Hardware Clock (PHC) support")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
v2: nullifying adapter->ptp_clock if ptp_clock_register() fails.
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
index 50517cf..9f9d6ca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
@@ -441,7 +441,8 @@ void cxgb4_ptp_init(struct adapter *adapter)
 
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
 						&adapter->pdev->dev);
-	if (!adapter->ptp_clock) {
+	if (IS_ERR_OR_NULL(adapter->ptp_clock)) {
+		adapter->ptp_clock = NULL;
 		dev_err(adapter->pdev_dev,
 			"PTP %s Clock registration has failed\n", __func__);
 		return;
-- 
2.1.0
