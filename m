From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCHv2 net-next] net: fec: add fallback to random MAC address
Date: Mon,  3 Jun 2013 12:38:39 +0200
Message-ID: <1370255919-12762-1-git-send-email-l.stach@pengutronix.de>
Cc: davem@davemloft.net, Lucas Stach <l.stach@pengutronix.de>,
	Pavel Machek <pavel@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48695 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097Ab3FCKkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 06:40:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If no valid MAC address could be obtained from the hardware,
fall back to a randomly generated one.

Signed-off-by: Pavel Machek <pavel@denx.de>
Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 927f4c6..0063761 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1039,6 +1039,18 @@ static void fec_get_mac(struct net_device *ndev)
 		iap = &tmpaddr[0];
 	}
 
+	/*
+	 * 5) random mac address
+	 */
+	if (!is_valid_ether_addr(iap)) {
+		/* Report it and use a random ethernet address instead */
+		netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
+		eth_hw_addr_random(ndev);
+		netdev_info(ndev, "Using random MAC address: %pM\n",
+			    ndev->dev_addr);
+		return;
+	}
+
 	memcpy(ndev->dev_addr, iap, ETH_ALEN);
 
 	/* Adjust MAC if using macaddr */
-- 
1.8.2.rc2
