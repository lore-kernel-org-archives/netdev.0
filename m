From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 02/14] amd-xgbe: Set the MII control width for
 the MAC interface
Date: Thu, 17 Aug 2017 19:02:20 -0500
Message-ID: <20170818000220.10005.98781.stgit@tlendack-t1.amdoffice.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0089.outbound.protection.outlook.com ([104.47.40.89]:6368
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753806AbdHRAC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:02:26 -0400
In-Reply-To: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in SGMII mode at speeds below 1000Mbps, the auto-negotition
control register must set the MII control width for the MAC interface
to be 8-bits wide.  By default the width is 4-bits.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    1 +
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c   |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 9795419..d07edf9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -1339,6 +1339,7 @@
 #define XGBE_AN_CL37_PCS_MODE_BASEX	0x00
 #define XGBE_AN_CL37_PCS_MODE_SGMII	0x04
 #define XGBE_AN_CL37_TX_CONFIG_MASK	0x08
+#define XGBE_AN_CL37_MII_CTRL_8BIT	0x0100
 
 /* Bit setting and getting macros
  *  The get macro will extract the current bit field value from within
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 8068491..2222bbf8 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -982,6 +982,8 @@ static void xgbe_an37_init(struct xgbe_prv_data *pdata)
 		break;
 	}
 
+	reg |= XGBE_AN_CL37_MII_CTRL_8BIT;
+
 	XMDIO_WRITE(pdata, MDIO_MMD_VEND2, MDIO_VEND2_AN_CTRL, reg);
 
 	netif_dbg(pdata, link, pdata->netdev, "CL37 AN (%s) initialized\n",
