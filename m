From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH] net/fsl: Make xgmac_mdio read error message useful
Date: Wed, 11 Jun 2014 13:41:40 -0500
Message-ID: <1402512100-16735-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0144.outbound.protection.outlook.com ([207.46.163.144]:34586
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752436AbaFKSlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 14:41:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print the device address, the register number and the PHY ID for
which the MDIO read operation failed

Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index d449fcb..0c9d55c 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -162,7 +162,9 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 
 	/* Return all Fs if nothing was there */
 	if (in_be32(&regs->mdio_stat) & MDIO_STAT_RD_ER) {
-		dev_err(&bus->dev, "MDIO read error\n");
+		dev_err(&bus->dev,
+			"Error while reading PHY%d reg at %d.%d\n",
+			phy_id, dev_addr, regnum);
 		return 0xffff;
 	}
 
-- 
1.8.3.1
