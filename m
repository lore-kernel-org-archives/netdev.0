From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: don't reset the rx coal timer on interface up
Date: Wed, 8 Apr 2009 22:44:14 +0200
Message-ID: <20090408204414.GC4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:60295 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757843AbZDHUoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 16:44:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move SDMA configuration from interface up to port probe, to prevent
overwriting the receive coalescing timer value on interface up.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

(The affected code is new in 2.6.30-rcX, so this doesn't apply to 2.6.29.)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a56d9d2..b3185bf 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2274,8 +2274,6 @@ static void port_start(struct mv643xx_eth_private *mp)
 		pscr |= FORCE_LINK_PASS;
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
-	wrlp(mp, SDMA_CONFIG, PORT_SDMA_CONFIG_DEFAULT_VALUE);
-
 	/*
 	 * Configure TX path and queues.
 	 */
@@ -2957,6 +2955,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	netif_carrier_off(dev);
 
+	wrlp(mp, SDMA_CONFIG, PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
 	set_rx_coal(mp, 250);
 	set_tx_coal(mp, 0);
 
-- 
1.5.6.4
