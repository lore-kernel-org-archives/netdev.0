From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 11:16:02 -0500
Message-ID: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:59979 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388AbcFNQQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 12:16:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the interrupt configuration isn't set and we are using the
internal phy, then we need to poll the phy to reliably detect
phy state changes.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8af2556..369dc7d 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1020,6 +1020,9 @@ static int smsc911x_mii_probe(struct net_device *dev)
 		return -ENODEV;
 	}
 
+	if ((!phydev->irq) && (!pdata->using_extphy))
+		phydev->irq = PHY_POLL;
+
 	SMSC_TRACE(pdata, probe, "PHY: addr %d, phy_id 0x%08X",
 		   phydev->mdio.addr, phydev->phy_id);
 
-- 
2.5.5
