From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 8/8] amd-xgbe: Remove the XGBE_LINK state bit
Date: Wed, 30 Sep 2015 08:53:22 -0500
Message-ID: <20150930135322.12605.18605.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0057.outbound.protection.outlook.com ([65.55.169.57]:27390
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751539AbbI3OH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:07:58 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XGBE_LINK bit is used just to determine whether to call the
netif_carrier_on/off functions. Rather than define and use this bit,
just call the functions. The netif_carrier_ok function can be used in
place of checking the XGBE_LINK bit in the future.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   16 ++++------------
 drivers/net/ethernet/amd/xgbe/xgbe.h      |    1 -
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 9088c3a..4460580 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -1115,8 +1115,7 @@ static void xgbe_phy_status(struct xgbe_prv_data *pdata)
 	unsigned int reg, link_aneg;
 
 	if (test_bit(XGBE_LINK_ERR, &pdata->dev_state)) {
-		if (test_and_clear_bit(XGBE_LINK, &pdata->dev_state))
-			netif_carrier_off(pdata->netdev);
+		netif_carrier_off(pdata->netdev);
 
 		pdata->phy.link = 0;
 		goto adjust_link;
@@ -1142,10 +1141,7 @@ static void xgbe_phy_status(struct xgbe_prv_data *pdata)
 		if (test_bit(XGBE_LINK_INIT, &pdata->dev_state))
 			clear_bit(XGBE_LINK_INIT, &pdata->dev_state);
 
-		if (!test_bit(XGBE_LINK, &pdata->dev_state)) {
-			set_bit(XGBE_LINK, &pdata->dev_state);
-			netif_carrier_on(pdata->netdev);
-		}
+		netif_carrier_on(pdata->netdev);
 	} else {
 		if (test_bit(XGBE_LINK_INIT, &pdata->dev_state)) {
 			xgbe_check_link_timeout(pdata);
@@ -1156,10 +1152,7 @@ static void xgbe_phy_status(struct xgbe_prv_data *pdata)
 
 		xgbe_phy_status_aneg(pdata);
 
-		if (test_bit(XGBE_LINK, &pdata->dev_state)) {
-			clear_bit(XGBE_LINK, &pdata->dev_state);
-			netif_carrier_off(pdata->netdev);
-		}
+		netif_carrier_off(pdata->netdev);
 	}
 
 adjust_link:
@@ -1179,8 +1172,7 @@ static void xgbe_phy_stop(struct xgbe_prv_data *pdata)
 	devm_free_irq(pdata->dev, pdata->an_irq, pdata);
 
 	pdata->phy.link = 0;
-	if (test_and_clear_bit(XGBE_LINK, &pdata->dev_state))
-		netif_carrier_off(pdata->netdev);
+	netif_carrier_off(pdata->netdev);
 
 	xgbe_phy_adjust_link(pdata);
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index a5f5a78..e234b99 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -459,7 +459,6 @@ struct xgbe_channel {
 
 enum xgbe_state {
 	XGBE_DOWN,
-	XGBE_LINK,
 	XGBE_LINK_INIT,
 	XGBE_LINK_ERR,
 };
