From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 9/9] net: sh_eth: do not issue a wild PHY reset through BMCR
Date: Thu, 5 Dec 2013 16:55:17 -0800
Message-ID: <1386291317-1202-10-git-send-email-f.fainelli@gmail.com>
References: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:19161 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3LFBEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:04:54 -0500
In-Reply-To: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sh_eth driver issues an uncontrolled PHY reset through the MII
register BMCR but fails to wait for the reset to complete, and will also
implicitely wipe out all possible PHY fixups applied. Use phy_init_hw()
which remedies both problems.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d256ce1..6761dde 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1704,7 +1704,10 @@ static int sh_eth_phy_start(struct net_device *ndev)
 		return ret;
 
 	/* reset phy - this also wakes it from PDOWN */
-	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);
+	ret = phy_init_hw(mdp->phydev);
+	if (ret)
+		return ret;
+
 	phy_start(mdp->phydev);
 
 	return 0;
-- 
1.8.3.2
