From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/7] net: phy: mdio-bcm-unimac: Add debug print for PHY workaround
Date: Mon, 31 Jul 2017 12:04:24 -0700
Message-ID: <20170731190429.24204-4-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38660 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdGaTEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:44 -0400
Received: by mail-wr0-f193.google.com with SMTP id g32so15074334wrd.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:43 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be stricly identical to what bcmgenet does, add a debug
print when a PHY workaround during bus->reset() is executed. Preliminary
change to moving bcmgenet towards mdio-bcm-unimac.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 97cac10bd0d5..4e52692f9eea 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -154,8 +154,10 @@ static int unimac_mdio_reset(struct mii_bus *bus)
 	}
 
 	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
-		if (read_mask & 1 << addr)
+		if (read_mask & 1 << addr) {
+			dev_dbg(&bus->dev, "Workaround for PHY @ %d\n", addr);
 			mdiobus_read(bus, addr, MII_BMSR);
+		}
 	}
 
 	return 0;
-- 
2.9.3
