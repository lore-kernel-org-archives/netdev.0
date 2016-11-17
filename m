From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe: Update connection validation for
 backplane mode
Date: Thu, 17 Nov 2016 08:43:37 -0600
Message-ID: <20161117144337.5714.57761.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0070.outbound.protection.outlook.com ([104.47.34.70]:7088
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941119AbcKQRSN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:18:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the connection type enumeration for backplane mode and return
an error when there is a mismatch between the mode and the connection
type.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 348cc8c..9d8c9530 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -164,6 +164,7 @@ enum xgbe_conn_type {
 	XGBE_CONN_TYPE_NONE = 0,
 	XGBE_CONN_TYPE_SFP,
 	XGBE_CONN_TYPE_MDIO,
+	XGBE_CONN_TYPE_RSVD1,
 	XGBE_CONN_TYPE_BACKPLANE,
 	XGBE_CONN_TYPE_MAX,
 };
@@ -2831,6 +2832,7 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 	if (xgbe_phy_conn_type_mismatch(pdata)) {
 		dev_err(pdata->dev, "phy mode/connection mismatch (%#x/%#x)\n",
 			phy_data->port_mode, phy_data->conn_type);
+		return -EINVAL;
 	}
 
 	/* Validate the mode requested */
