From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH 2/2 net] cxgb4: ptp_clock_register() returns error pointers
Date: Mon, 10 Jul 2017 10:16:15 +0300
Message-ID: <20170710071615.k6b6726cwushhdmm@mwanda>
References: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Ganesh Goudar <ganeshgr@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20494 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752451AbdGJHQ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 03:16:27 -0400
Content-Disposition: inline
In-Reply-To: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're checking ptp_clock_register() for NULL but we should be checking
for error pointers.

Fixes: 9c33e4208bce ("cxgb4: Add PTP Hardware Clock (PHC) support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
index 50517cfd9671..c24313a103c6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
@@ -441,7 +441,7 @@ void cxgb4_ptp_init(struct adapter *adapter)
 
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
 						&adapter->pdev->dev);
-	if (!adapter->ptp_clock) {
+	if (IS_ERR(adapter->ptp_clock)) {
 		dev_err(adapter->pdev_dev,
 			"PTP %s Clock registration has failed\n", __func__);
 		return;
