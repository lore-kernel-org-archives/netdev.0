From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] isa-skelton: Remove a wrong netif_wake_queue() call
Date: Thu, 25 Feb 2010 01:00:17 +0900
Message-ID: <1267027217-7812-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mv-drv-hcb004.ocn.ad.jp ([118.23.109.134]:52084 "EHLO
	mv-drv-hcb004.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886Ab0BXQA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 11:00:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netif_wake_queue() is called correctly (i.e. only on !txfull
condition) from net_tx().  So Unconditional call to the
netif_wake_queue() here is wrong.  This might cause calling of
start_xmit routine on txfull state and trigger tx-ring overflow.

This fix is ported from commit 662a96bd6f020782dfbdc0d0bd177c7dbb556687.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/isa-skeleton.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 04d0502..3f33c90 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -536,7 +536,6 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 		/* Transmit complete. */
 		net_tx(dev);
 		np->stats.tx_packets++;
-		netif_wake_queue(dev);
 	}
 #endif
 	if (status & COUNTERS_INTR) {
-- 
1.5.6.5

