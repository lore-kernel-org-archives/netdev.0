From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net] cxgb4: ptp_clock_register() returns error pointers
Date: Tue, 11 Jul 2017 19:54:38 +0530
Message-ID: <1499783078-4706-1-git-send-email-ganeshgr@chelsio.com>
Cc: dan.carpenter@oracle.com, atul.gupta@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:11008 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932774AbdGKOYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 10:24:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check ptp_clock_register() return not only for NULL but
also for error pointers.

Fixes: 9c33e4208bce ("cxgb4: Add PTP Hardware Clock (PHC) support")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
index 50517cf..06c0de4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
@@ -441,7 +441,7 @@ void cxgb4_ptp_init(struct adapter *adapter)
 
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
 						&adapter->pdev->dev);
-	if (!adapter->ptp_clock) {
+	if (IS_ERR_OR_NULL(adapter->ptp_clock)) {
 		dev_err(adapter->pdev_dev,
 			"PTP %s Clock registration has failed\n", __func__);
 		return;
-- 
2.1.0
