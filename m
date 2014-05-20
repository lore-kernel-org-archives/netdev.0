From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH 2/2] net: fec: correct the MDIO clock source
Date: Tue, 20 May 2014 13:23:09 +0800
Message-ID: <1400563389-3599-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>,
	<bhutchings@solarflare.com>, <stephen@networkplumber.org>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:29888
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751547AbaETGlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:41:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since imx serials FEC/ENET MDIO clock source is internal ipg clock,
and "ahb" clock is defined as FEC/ENET bus clock, so the patch just
correct the fec driver MDIO clock source.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 99fb0dc..cb5c987 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1407,7 +1407,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	 * Reference Manual has an error on this, and gets fixed on i.MX6Q
 	 * document.
 	 */
-	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk_ahb), 5000000);
+	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk_ipg), 5000000);
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
 		fep->phy_speed--;
 	fep->phy_speed <<= 1;
-- 
1.7.8
