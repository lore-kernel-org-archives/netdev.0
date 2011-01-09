From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6 1/5] bnx2x: Don't prevent RSS configuration in
 INT#x and MSI interrupt modes.
Date: Sun, 9 Jan 2011 14:19:40 +0200
Message-ID: <1294575580.31551.12.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2592 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587Ab1AIMT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 07:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't prevent RSS configuration in INT#x and MSI interrupt modes. Otherwise
Rx hash key won't be available.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 9709b85..972b957 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8382,13 +8382,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		dev_err(&bp->pdev->dev, "MCP disabled, "
 					"must load devices in order!\n");
 
-	/* Set multi queue mode */
-	if ((multi_mode != ETH_RSS_MODE_DISABLED) &&
-	    ((int_mode == INT_MODE_INTx) || (int_mode == INT_MODE_MSI))) {
-		dev_err(&bp->pdev->dev, "Multi disabled since int_mode "
-					"requested is not MSI-X\n");
-		multi_mode = ETH_RSS_MODE_DISABLED;
-	}
 	bp->multi_mode = multi_mode;
 	bp->int_mode = int_mode;
 
-- 
1.7.0.4




