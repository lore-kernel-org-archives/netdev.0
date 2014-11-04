From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 10/12] amd-xgbe-phy: Sync PCS and PHY modes
 after reset
Date: Tue, 4 Nov 2014 16:07:35 -0600
Message-ID: <20141104220735.24738.7557.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0106.outbound.protection.outlook.com ([157.56.110.106]:15836
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751421AbaKDWWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:22:09 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to sync the states of the PCS and the PHY
after a reset is performed.  If the PCS and the PHY are not in the
same state after reset an extra mode change would be performed. This
extra mode change might not be needed if the PCS and the PHY are
synced up after reset.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index c456559..37b9f3f 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -992,7 +992,8 @@ static int amd_xgbe_phy_soft_reset(struct phy_device *phydev)
 	if (ret & MDIO_CTRL1_RESET)
 		return -ETIMEDOUT;
 
-	return 0;
+	/* Make sure the XPCS and SerDes are in compatible states */
+	return amd_xgbe_phy_xgmii_mode(phydev);
 }
 
 static int amd_xgbe_phy_config_init(struct phy_device *phydev)
