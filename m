From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/9] net: greth: use phy_read_status()
Date: Fri, 6 Dec 2013 13:01:32 -0800
Message-ID: <1386363698-8407-4-git-send-email-f.fainelli@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:56936 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab3LFVB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:01:59 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the greth driver is bound to anything but the Generic PHY
driver or the PHY has a special read_status callback implemented,
unexpected things will happen. Make sure we that we use
phy_read_status() which does the proper abstraction of calling the
driver specific read_status() callback for a given PHY.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/aeroflex/greth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index e066945..b20cbf0 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1361,7 +1361,7 @@ static int greth_mdio_init(struct greth_private *greth)
 		timeout = jiffies + 6*HZ;
 		while (!phy_aneg_done(greth->phy) && time_before(jiffies, timeout)) {
 		}
-		genphy_read_status(greth->phy);
+		phy_read_status(greth->phy);
 		greth_link_change(greth->netdev);
 	}
 
-- 
1.8.3.2
