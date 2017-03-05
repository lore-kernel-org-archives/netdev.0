From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Do not perform software reset for Generic PHY
Date: Sun,  5 Mar 2017 12:26:10 -0800
Message-ID: <20170305202610.9263-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, nbd@nbd.name,
        john@phrozen.org, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:33935 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752329AbdCEU1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 15:27:17 -0500
Received: by mail-ot0-f194.google.com with SMTP id x37so9297632ota.1
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 12:26:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Generic PHY driver is a catch-all PHY driver and it should preserve
whatever prior initialization has been done by boot loader or firmware
agents. For specific PHY device configuration it is expected that a
specialized PHY driver would take over that role.

Resetting the generic PHY was a bad idea that has lead to several
complaints and downstream workarounds e.g: in OpenWrt/LEDE so restore
the behavior prior to 87aa9f9c61ad ("net: phy: consolidate PHY
reset in phy_init_hw()").

Reported-by: Felix Fietkau <nbd@nbd.name>
Fixes: 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index daec6555f3b1..5198ccfa347f 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1864,7 +1864,7 @@ static struct phy_driver genphy_driver[] = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
-	.soft_reset	= genphy_soft_reset,
+	.soft_reset	= genphy_no_soft_reset,
 	.config_init	= genphy_config_init,
 	.features	= PHY_GBIT_FEATURES | SUPPORTED_MII |
 			  SUPPORTED_AUI | SUPPORTED_FIBRE |
-- 
2.9.3
