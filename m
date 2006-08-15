From: akpm@osdl.org
Subject: [patch 36/41] skge: remember to run netif_poll_disable()
Date: Mon, 14 Aug 2006 23:00:24 -0700
Message-ID: <200608150600.k7F60Onf012735@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, edgar.iglesias@axis.com,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42642 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965140AbWHOGAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:40 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>

Signed-off-by: Edgar E. Iglesias <edgar.iglesias@axis.com>
Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/skge.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/skge.c~skge-remember-to-run-netif_poll_disable drivers/net/skge.c
--- a/drivers/net/skge.c~skge-remember-to-run-netif_poll_disable
+++ a/drivers/net/skge.c
@@ -2211,6 +2211,7 @@ static int skge_up(struct net_device *de
 	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
 	skge_led(skge, LED_MODE_ON);
 
+	netif_poll_enable(dev);
 	return 0;
 
  free_rx_ring:
@@ -2279,6 +2280,7 @@ static int skge_down(struct net_device *
 
 	skge_led(skge, LED_MODE_OFF);
 
+	netif_poll_disable(dev);
 	skge_tx_clean(skge);
 	skge_rx_clean(skge);
 
_
