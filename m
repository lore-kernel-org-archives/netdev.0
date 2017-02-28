From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 3/3] amd-xgbe: Don't overwrite SFP PHY mod_absent
 settings
Date: Tue, 28 Feb 2017 15:03:10 -0600
Message-ID: <20170228210310.32166.14230.stgit@tlendack-t1.amdoffice.net>
References: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0086.outbound.protection.outlook.com ([104.47.36.86]:1680
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751534AbdB1Xob (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 18:44:31 -0500
In-Reply-To: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an SFP module is not present, xgbe_phy_sfp_phy_settings() should
return after applying the default settings. Currently there is no return
statement and the default settings are overwritten.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 04804cb..e707c49 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -716,6 +716,8 @@ static void xgbe_phy_sfp_phy_settings(struct xgbe_prv_data *pdata)
 		pdata->phy.duplex = DUPLEX_UNKNOWN;
 		pdata->phy.autoneg = AUTONEG_ENABLE;
 		pdata->phy.advertising = pdata->phy.supported;
+
+		return;
 	}
 
 	pdata->phy.advertising &= ~ADVERTISED_Autoneg;
