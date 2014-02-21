From: <cristian.bercaru@freescale.com>
Subject: [PATCH] net: phy: unmask link partner capabilities
Date: Fri, 21 Feb 2014 18:18:16 +0200
Message-ID: <1392999496-29753-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cristian Bercaru <cristian.bercaru@freescale.com>,
	<madalin.bucur@freescale.com>, <shaohui.xie@freescale.com>,
	<shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:55148 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754432AbaBUQSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 11:18:38 -0500
Received: from mail111-tx2 (localhost [127.0.0.1])	by
 mail111-tx2-R.bigfish.com (Postfix) with ESMTP id D5951420395	for
 <netdev@vger.kernel.org>; Fri, 21 Feb 2014 16:18:37 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cristian Bercaru <cristian.bercaru@freescale.com>

Masking the link partner's capabilities with local capabilities can be
misleading in autonegotiation scenarios such as PAUSE frame
autonegotiation.
Therefore, this patch unmasks the link partner's capabilities.

Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
---
 drivers/net/phy/phy_device.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a70b604..e57825e6 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -967,8 +967,6 @@ int genphy_read_status(struct phy_device *phydev)
 		if (adv < 0)
 			return adv;
 
-		lpa &= adv;
-
 		phydev->speed = SPEED_10;
 		phydev->duplex = DUPLEX_HALF;
 		phydev->pause = 0;
@@ -979,13 +977,13 @@ int genphy_read_status(struct phy_device *phydev)
 
 			if (lpagb & LPA_1000FULL)
 				phydev->duplex = DUPLEX_FULL;
-		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
+		} else if (lpa & adv & (LPA_100FULL | LPA_100HALF)) {
 			phydev->speed = SPEED_100;
 
-			if (lpa & LPA_100FULL)
+			if (lpa & adv & LPA_100FULL)
 				phydev->duplex = DUPLEX_FULL;
 		} else
-			if (lpa & LPA_10FULL)
+			if (lpa & adv & LPA_10FULL)
 				phydev->duplex = DUPLEX_FULL;
 
 		if (phydev->duplex == DUPLEX_FULL) {
-- 
1.7.11.7
