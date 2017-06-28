From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 06/14] amd-xgbe: Handle return code from
 software reset function
Date: Wed, 28 Jun 2017 13:42:16 -0500
Message-ID: <20170628184216.21972.34488.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0044.outbound.protection.outlook.com ([104.47.32.44]:48116
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751722AbdF1SmV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:42:21 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the function that performs a software reset of the hardware
provides a return code.  During driver probe check this return code and
exit with an error if the software reset fails.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 17ac8f9..982368b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -277,7 +277,11 @@ int xgbe_config_netdev(struct xgbe_prv_data *pdata)
 	pdata->desc_ded_period = jiffies;
 
 	/* Issue software reset to device */
-	pdata->hw_if.exit(pdata);
+	ret = pdata->hw_if.exit(pdata);
+	if (ret) {
+		dev_err(dev, "software reset failed\n");
+		return ret;
+	}
 
 	/* Set default configuration data */
 	xgbe_default_config(pdata);
