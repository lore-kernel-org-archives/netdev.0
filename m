From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 29/30] net: fec: remove useless status check in tx reap
 path
Date: Fri, 27 Jun 2014 16:21:21 +0100
Message-ID: <E1X0Xxp-0001P6-FJ@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45267 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754376AbaF0PVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:21:23 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a useless status check in the transmit reap path - we have
already checked that the BD_ENET_TX_READY bit is clear, and as the
hardware only ever clears this bit, there is no way this test can ever
be true.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1e0eeb43ff6a..916b9ab97da4 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1133,9 +1133,6 @@ fec_enet_tx(struct net_device *ndev)
 			skb_tstamp_tx(skb, &shhwtstamps);
 		}
 
-		if (status & BD_ENET_TX_READY)
-			netdev_err(ndev, "HEY! Enet xmit interrupt and TX_READY\n");
-
 		/* Deferred means some collisions occurred during transmit,
 		 * but we eventually sent the packet OK.
 		 */
-- 
1.8.3.1
