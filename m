From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/4] mv643xx_eth: set sane default receive coalescing timeout
Date: Wed, 25 Feb 2009 02:42:05 +0100
Message-ID: <20090225014205.GZ17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53068 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616AbZBYBmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:42:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A receive coalescing timeout of 250 usec appears to strike a good
balance between allowing enough received frames to be aggregated for
LRO to do its job and not allowing the connection to stall due to
delaying ACKs to the remote end for too long.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2ea964c..40db24d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2958,7 +2958,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	netif_carrier_off(dev);
 
-	set_rx_coal(mp, 0);
+	set_rx_coal(mp, 250);
 	set_tx_coal(mp, 0);
 
 	err = register_netdev(dev);
-- 
1.5.6.4
