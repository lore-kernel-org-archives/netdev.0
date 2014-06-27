From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 06/30] net: fec: remove checking for NULL phy_dev in
 fec_enet_close()
Date: Fri, 27 Jun 2014 16:19:24 +0100
Message-ID: <E1X0Xvw-0001NA-0L@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45190 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753696AbaF0PT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:19:26 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fep->phy_dev can not be NULL here for two reasons:
- fec_enet_open() will have successfully connected the phy, or will have
  failed.
- fec_enet_open() will have called phy_start(fep->phy_dev), which
  unconditionally dereferences this pointer.

If it were to be NULL here, then fec_enet_open() will have already
oopsed.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cb9ced738607..6a03d7eced4d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2184,10 +2184,8 @@ fec_enet_close(struct net_device *ndev)
 	netif_tx_disable(ndev);
 	fec_stop(ndev);
 
-	if (fep->phy_dev) {
-		phy_stop(fep->phy_dev);
-		phy_disconnect(fep->phy_dev);
-	}
+	phy_stop(fep->phy_dev);
+	phy_disconnect(fep->phy_dev);
 
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
-- 
1.8.3.1
