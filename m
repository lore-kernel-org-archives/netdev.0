From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -mainline] amd-xgbe: fix a couple timeout loops
Date: Tue, 15 Dec 2015 13:12:29 +0300
Message-ID: <20151215101229.GF20848@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49175 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964822AbbLOKMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 05:12:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the end of the loop we test "if (!count)" but because "count--" is
a post-op then the loop will end with count set to -1.  I have fixed
this by changing it to --count.

Fixes: c5aa9e3b8156 ('amd-xgbe: Initial AMD 10GbE platform driver')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 970781a..f6a7161 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1849,7 +1849,7 @@ static int xgbe_exit(struct xgbe_prv_data *pdata)
 	usleep_range(10, 15);
 
 	/* Poll Until Poll Condition */
-	while (count-- && XGMAC_IOREAD_BITS(pdata, DMA_MR, SWR))
+	while (--count && XGMAC_IOREAD_BITS(pdata, DMA_MR, SWR))
 		usleep_range(500, 600);
 
 	if (!count)
@@ -1873,7 +1873,7 @@ static int xgbe_flush_tx_queues(struct xgbe_prv_data *pdata)
 	/* Poll Until Poll Condition */
 	for (i = 0; i < pdata->tx_q_count; i++) {
 		count = 2000;
-		while (count-- && XGMAC_MTL_IOREAD_BITS(pdata, i,
+		while (--count && XGMAC_MTL_IOREAD_BITS(pdata, i,
 							MTL_Q_TQOMR, FTQ))
 			usleep_range(500, 600);
 
