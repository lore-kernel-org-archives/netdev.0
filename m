From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 08/14] amd-xgbe: Limit the I2C error messages
 that are output
Date: Wed, 28 Jun 2017 13:42:35 -0500
Message-ID: <20170628184235.21972.47095.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0087.outbound.protection.outlook.com ([104.47.38.87]:51808
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751523AbdF1Smi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:42:38 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I2C communication fails, it tends to always fail. Rather than
continuously issue an error message (once per second in most cases),
change the message to be issued just once.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index b8be62e..04b5c14 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -1121,7 +1121,8 @@ static int xgbe_phy_sfp_read_eeprom(struct xgbe_prv_data *pdata)
 
 	ret = xgbe_phy_sfp_get_mux(pdata);
 	if (ret) {
-		netdev_err(pdata->netdev, "I2C error setting SFP MUX\n");
+		dev_err_once(pdata->dev, "%s: I2C error setting SFP MUX\n",
+			     netdev_name(pdata->netdev));
 		return ret;
 	}
 
@@ -1131,7 +1132,8 @@ static int xgbe_phy_sfp_read_eeprom(struct xgbe_prv_data *pdata)
 				&eeprom_addr, sizeof(eeprom_addr),
 				&sfp_eeprom, sizeof(sfp_eeprom));
 	if (ret) {
-		netdev_err(pdata->netdev, "I2C error reading SFP EEPROM\n");
+		dev_err_once(pdata->dev, "%s: I2C error reading SFP EEPROM\n",
+			     netdev_name(pdata->netdev));
 		goto put;
 	}
 
@@ -1190,7 +1192,8 @@ static void xgbe_phy_sfp_signals(struct xgbe_prv_data *pdata)
 				&gpio_reg, sizeof(gpio_reg),
 				gpio_ports, sizeof(gpio_ports));
 	if (ret) {
-		netdev_err(pdata->netdev, "I2C error reading SFP GPIOs\n");
+		dev_err_once(pdata->dev, "%s: I2C error reading SFP GPIOs\n",
+			     netdev_name(pdata->netdev));
 		return;
 	}
 
