From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 2/2] amd-xgbe: Check xgbe_init() return code
Date: Fri, 20 Jan 2017 12:14:13 -0600
Message-ID: <20170120181413.2321.52046.stgit@tlendack-t1.amdoffice.net>
References: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0087.outbound.protection.outlook.com ([104.47.42.87]:2657
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752592AbdATSOV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 13:14:21 -0500
In-Reply-To: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xgbe_init() routine returns a return code indicating success or
failure, but the return code is not checked. Add code to xgbe_init()
to issue a message when failures are seen and add code to check the
xgbe_init() return code.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    4 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index c8e8a4a..a7d16db 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -3407,8 +3407,10 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 
 	/* Flush Tx queues */
 	ret = xgbe_flush_tx_queues(pdata);
-	if (ret)
+	if (ret) {
+		netdev_err(pdata->netdev, "error flushing TX queues\n");
 		return ret;
+	}
 
 	/*
 	 * Initialize DMA related features
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 9943629..1c87cc2 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1070,7 +1070,9 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 
 	DBGPR("-->xgbe_start\n");
 
-	hw_if->init(pdata);
+	ret = hw_if->init(pdata);
+	if (ret)
+		return ret;
 
 	xgbe_napi_enable(pdata, 1);
 
