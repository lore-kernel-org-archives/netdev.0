From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/4] mv643xx_eth: move a couple of init actions from ->open() to port probe
Date: Wed, 25 Feb 2009 02:41:47 +0100
Message-ID: <20090225014147.GY17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53061 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223AbZBYBlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:41:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the netif_carrier_off() call in ->open() to port probe, so that
ethtool doesn't report the link as being up before we have up'd the
interface.

Move initialisation of the rx/tx coalescing timers from ->open() to
port probe, so that we don't reset the coalescing timers every time
the interface is up'd.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b711404..2ea964c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2388,13 +2388,8 @@ static int mv643xx_eth_open(struct net_device *dev)
 		}
 	}
 
-	netif_carrier_off(dev);
-
 	port_start(mp);
 
-	set_rx_coal(mp, 0);
-	set_tx_coal(mp, 0);
-
 	wrlp(mp, INT_MASK_EXT, INT_EXT_LINK_PHY | INT_EXT_TX);
 	wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
 
@@ -2961,6 +2956,11 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (mp->shared->win_protect)
 		wrl(mp, WINDOW_PROTECT(mp->port_num), mp->shared->win_protect);
 
+	netif_carrier_off(dev);
+
+	set_rx_coal(mp, 0);
+	set_tx_coal(mp, 0);
+
 	err = register_netdev(dev);
 	if (err)
 		goto out;
-- 
1.5.6.4
