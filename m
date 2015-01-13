From: <shh.xie@gmail.com>
Subject: [PATCH] net/fsl: fix a bug in xgmac_mdio
Date: Tue, 13 Jan 2015 10:30:31 +0800
Message-ID: <1421116231-16100-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0094.outbound.protection.outlook.com ([157.56.111.94]:61377
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751511AbbAMDgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 22:36:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

There is a bug in xgmac_mdio_read when clear the bit MDIO_STAT_ENC,
which '&' is missed in 'mdio_stat &= ~MDIO_STAT_ENC'.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index e0fc3d1..a492e50 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -156,7 +156,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 		mdio_stat |= MDIO_STAT_ENC;
 	} else {
 		dev_addr = regnum & 0x1f;
-		mdio_stat = ~MDIO_STAT_ENC;
+		mdio_stat &= ~MDIO_STAT_ENC;
 	}
 
 	out_be32(&regs->mdio_stat, mdio_stat);
-- 
1.8.4.1
