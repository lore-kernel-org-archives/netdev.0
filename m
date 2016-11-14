From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 1/2] amd-xgbe: Fix mask appliciation for Clause
 37 register
Date: Mon, 14 Nov 2016 16:39:07 -0600
Message-ID: <20161114223907.25437.50884.stgit@tlendack-t1.amdoffice.net>
References: <20161114223856.25437.13649.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <christophe.jaillet@wanadoo.fr>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0046.outbound.protection.outlook.com ([104.47.38.46]:7872
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933841AbcKNWjO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:39:14 -0500
In-Reply-To: <20161114223856.25437.13649.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The application of a mask to clear an area of a clause 37 register value
was not properly applied. Update the code to do the proper application
of the mask.

Reported-by: Marion & Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 0ecae70..4c5b90e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -943,8 +943,8 @@ static void xgbe_an37_init(struct xgbe_prv_data *pdata)
 
 	/* Set up the Control register */
 	reg = XMDIO_READ(pdata, MDIO_MMD_VEND2, MDIO_VEND2_AN_CTRL);
-	reg &= XGBE_AN_CL37_TX_CONFIG_MASK;
-	reg &= XGBE_AN_CL37_PCS_MODE_MASK;
+	reg &= ~XGBE_AN_CL37_TX_CONFIG_MASK;
+	reg &= ~XGBE_AN_CL37_PCS_MODE_MASK;
 
 	switch (pdata->an_mode) {
 	case XGBE_AN_MODE_CL37:
