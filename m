From: akpm@osdl.org
Subject: [patch 31/41] via-rhine: NAPI poll enable
Date: Mon, 14 Aug 2006 23:00:18 -0700
Message-ID: <200608150600.k7F60IXi012699@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, shemminger@osdl.org,
	rl@hellgate.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36242 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965138AbWHOGAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:30 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>

The poll_enable should be in init_registers before enabling interrupts, not
in tx_timeout.  Thanks for spotting it Roger.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Cc: Roger Luethi <rl@hellgate.ch>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/via-rhine.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/via-rhine.c~via-rhine-napi-poll-enable drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c~via-rhine-napi-poll-enable
+++ a/drivers/net/via-rhine.c
@@ -1048,6 +1048,8 @@ static void init_registers(struct net_de
 
 	rhine_set_rx_mode(dev);
 
+	netif_poll_enable(dev);
+
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 	       IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
@@ -1199,7 +1201,6 @@ static void rhine_tx_timeout(struct net_
 	dev->trans_start = jiffies;
 	rp->stats.tx_errors++;
 	netif_wake_queue(dev);
-	netif_poll_enable(dev);
 }
 
 static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
_
