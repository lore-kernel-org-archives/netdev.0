From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: [PATCH net-next] net: ethernet: ax88796: support generating a random mac address
Date: Thu, 25 May 2017 22:55:11 +0200
Message-ID: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:43365 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S939250AbdEYUzW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 16:55:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of falling back to 00:00:00:00:00:00 generate a random address
if none is provided via platform data or from the the device's register
space.

Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/8390/ax88796.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index db02bc2fb4b2..05d9d3e2e92e 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -723,6 +723,12 @@ static int ax_init_dev(struct net_device *dev)
 	    ax->plat->mac_addr)
 		memcpy(dev->dev_addr, ax->plat->mac_addr, ETH_ALEN);
 
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		eth_hw_addr_random(dev);
+		dev_info(&dev->dev, "Using random MAC address: %pM\n",
+			 dev->dev_addr);
+	}
+
 	ax_reset_8390(dev);
 
 	ei_local->name = "AX88796";
-- 
2.11.0
