From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH net-next] net: fec: add fallback to random MAC address
Date: Fri, 31 May 2013 19:22:22 +0200
Message-ID: <1370020942-8342-1-git-send-email-l.stach@pengutronix.de>
Cc: davem@davemloft.net, Pavel Machek <pavel@denx.de>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55316 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349Ab3EaRYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 13:24:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Machek <pavel@denx.de>

If no valid MAC address could be obtained from the hardware,
fall back to a randomly generated one.

Signed-off-by: Pavel Machek <pavel@denx.de>
Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9b0c647..3694a56 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1037,6 +1037,16 @@ static void fec_get_mac(struct net_device *ndev)
 		iap = &tmpaddr[0];
 	}
 
+	/*
+	 * 5) random mac address
+	 */
+	if (!is_valid_ether_addr(iap)) {
+		/* Report it and use a random ethernet address instead */
+		netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
+		random_ether_addr(iap);
+		netdev_info(ndev, "Using random MAC address: %pM\n", iap);
+	}
+
 	memcpy(ndev->dev_addr, iap, ETH_ALEN);
 
 	/* Adjust MAC if using macaddr */
-- 
1.8.2.rc2
