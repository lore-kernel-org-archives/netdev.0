From: akpm@linux-foundation.org
Subject: [patch 09/10] forcedeth: fix tx timeout
Date: Mon, 26 Mar 2007 21:47:28 -0800
Message-ID: <200703270547.l2R5lSTx008275@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40123 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbXC0Frc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ayaz Abdulla <aabdulla@nvidia.com>

The tx timeout routine was waking the tx queue conditionally.  However, it
must call it unconditionally since the dev_watchdog has halted the tx queue
before calling the timeout function.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcedeth-fix-tx-timeout drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-fix-tx-timeout
+++ a/drivers/net/forcedeth.c
@@ -2050,9 +2050,10 @@ static void nv_tx_timeout(struct net_dev
 		nv_drain_tx(dev);
 		nv_init_tx(dev);
 		setup_hw_rings(dev, NV_SETUP_TX_RING);
-		netif_wake_queue(dev);
 	}
 
+	netif_wake_queue(dev);
+
 	/* 4) restart tx engine */
 	nv_start_tx(dev);
 	spin_unlock_irq(&np->lock);
_
