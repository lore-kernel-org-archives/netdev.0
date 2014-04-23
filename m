From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net] gianfar: Check if phydev present on ethtool -A
Date: Wed, 23 Apr 2014 16:38:47 +0300
Message-ID: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:56363
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755923AbaDWNzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 09:55:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a seg fault on 'ethtool -A' entry if the
interface is down.  Obviously we need to have the
phy device initialized / "connected" (see of_phy_connect())
to be able to advertise pause frame capabilities.

Fixes: 23402bddf9e56eecb27bbd1e5467b3b79b3dbe58
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 891dbee..76d7070 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -533,6 +533,9 @@ static int gfar_spauseparam(struct net_device *dev,
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 oldadv, newadv;
 
+	if (!phydev)
+		return -ENODEV;
+
 	if (!(phydev->supported & SUPPORTED_Pause) ||
 	    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
 	     (epause->rx_pause != epause->tx_pause)))
-- 
1.7.11.7
