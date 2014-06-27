From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 05/30] net: fec: use netif_tx_disable() rather than
 netif_stop_queue()
Date: Fri, 27 Jun 2014 16:19:18 +0100
Message-ID: <E1X0Xvq-0001N6-TX@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45186 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753892AbaF0PTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:19:21 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use netif_stop_queue() in several places where we want to ensure that
the start_xmit function is not running.  netif_stop_queue() is not
sufficient to achieve that - it merely sets a flag to indicate that the
transmit queue(s) should not be run.

netif_tx_disable() gives this guarantee, since it takes the transmit
queue lock while marking the queue stopped.  This will wait for the
transmit function to complete before returning.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4e695b742030..cb9ced738607 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -834,7 +834,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	if (netif_running(ndev)) {
 		netif_device_detach(ndev);
 		napi_disable(&fep->napi);
-		netif_stop_queue(ndev);
+		netif_tx_disable(ndev);
 		netif_tx_lock_bh(ndev);
 	}
 
@@ -2181,7 +2181,7 @@ fec_enet_close(struct net_device *ndev)
 	/* Don't know what to do yet. */
 	napi_disable(&fep->napi);
 	fep->opened = 0;
-	netif_stop_queue(ndev);
+	netif_tx_disable(ndev);
 	fec_stop(ndev);
 
 	if (fep->phy_dev) {
-- 
1.8.3.1
