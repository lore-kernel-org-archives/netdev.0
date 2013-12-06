From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/9] net: bfin_mac: do not reset PHY after phy_start()
Date: Fri, 6 Dec 2013 13:01:33 -0800
Message-ID: <1386363698-8407-5-git-send-email-f.fainelli@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:20824 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757384Ab3LFVB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:01:59 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
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
index 0d4f295..c0f68dc 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1557,7 +1557,6 @@ static int bfin_mac_open(struct net_device *dev)
 		return ret;
 
 	phy_start(lp->phydev);
-	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
 	setup_mac_addr(dev->dev_addr);
 
-- 
1.8.3.2
