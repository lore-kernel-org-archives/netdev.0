From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 4/9] net: bfin_mac: do not reset PHY after phy_start()
Date: Thu, 5 Dec 2013 16:55:12 -0800
Message-ID: <1386291317-1202-5-git-send-email-f.fainelli@gmail.com>
References: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:21606 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab3LFBFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:05:02 -0500
In-Reply-To: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY is already reset during driver probing, and this manual reset
after calling phy_start() will wipe out board-specific PHY fixups and
driver specific configuration initialization. Remove that explicit PHY
reset.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 75fb1d2..2ce382e 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1544,7 +1544,6 @@ static int bfin_mac_open(struct net_device *dev)
 		return ret;
 
 	phy_start(lp->phydev);
-	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
 	setup_mac_addr(dev->dev_addr);
 
-- 
1.8.3.2
