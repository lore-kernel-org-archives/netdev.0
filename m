From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH for 3.9] net: fec: fix regression in link change accounting
Date: Tue, 16 Apr 2013 12:42:42 +0200
Message-ID: <1366108962-8607-1-git-send-email-l.stach@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44650 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934017Ab3DPKnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 06:43:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A link-down isn't properly saved in the FEC state, so we wouldn't restart the
FEC after a repeated link-up.

Regression was introduced with commit
d97e7497 "net: fec: restart the FEC when PHY speed changes"

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f292c3a..73195f6 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1002,6 +1002,7 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 	} else {
 		if (fep->link) {
 			fec_stop(ndev);
+			fep->link = phy_dev->link;
 			status_change = 1;
 		}
 	}
-- 
1.7.10.4
