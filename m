From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH C 6/7] net: fec: remove useless status check in tx reap path
Date: Tue, 08 Jul 2014 13:02:04 +0100
Message-ID: <E1X4U60-0005uI-E0@rmk-PC.arm.linux.org.uk>
References: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58747 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754499AbaGHMCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 08:02:06 -0400
In-Reply-To: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a useless status check in the transmit reap path - we have
already checked that the BD_ENET_TX_READY bit is clear, and as the
hardware only ever clears this bit, there is no way this test can ever
be true.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 09fcdc768931..8679c919419c 100644
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
