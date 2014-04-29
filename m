From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH net-next 6/7] net:fec: use netif_tx_disable() rather than netif_stop_queue()
Date: Tue, 29 Apr 2014 20:09:09 +0800
Message-ID: <1398773350-7293-6-git-send-email-Frank.Li@freescale.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0211.outbound.protection.outlook.com ([207.46.163.211]:33969
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755931AbaD2NUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 09:20:41 -0400
In-Reply-To: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

We use netif_stop_queue() in several places where we want to ensure that
the start_xmit function is not running.  netif_stop_queue() is not
sufficient to achieve that - it merely sets a flag to indicate that the
transmit queue(s) should not be run.

netif_tx_disable() gives this guarantee, since it takes the transmit
queue lock while marking the queue stopped.  This will wait for the
transmit function to complete before returning.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 7d506ae..1c84f3a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -522,7 +522,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	if (netif_running(ndev)) {
 		netif_device_detach(ndev);
 		napi_disable(&fep->napi);
-		netif_stop_queue(ndev);
+		netif_tx_disable(ndev);
 		netif_tx_lock_bh(ndev);
 	}
 
@@ -1821,7 +1821,7 @@ fec_enet_close(struct net_device *ndev)
 	/* Don't know what to do yet. */
 	napi_disable(&fep->napi);
 	fep->opened = 0;
-	netif_stop_queue(ndev);
+	netif_tx_disable(ndev);
 	fec_stop(ndev);
 
 	phy_stop(fep->phy_dev);
-- 
1.7.8
