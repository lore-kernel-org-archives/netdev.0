From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 07/10] can: at91_can: set bittiming in chip_start
Date: Thu, 21 Oct 2010 13:01:19 +0200
Message-ID: <1287658882-26914-8-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34925 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757268Ab0JULB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:01:27 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 4fa0aa0..ace9c08 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -299,6 +299,7 @@ static void at91_chip_start(struct net_device *dev)
 	reg_mr = at91_read(priv, AT91_MR);
 	at91_write(priv, AT91_MR, reg_mr & ~AT91_MR_CANEN);
 
+	at91_set_bittiming(dev);
 	at91_setup_mailboxes(dev);
 	at91_transceiver_switch(priv, 1);
 
@@ -1086,7 +1087,6 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	priv = netdev_priv(dev);
 	priv->can.clock.freq = clk_get_rate(clk);
 	priv->can.bittiming_const = &at91_bittiming_const;
-	priv->can.do_set_bittiming = at91_set_bittiming;
 	priv->can.do_set_mode = at91_set_mode;
 	priv->can.do_get_berr_counter = at91_get_berr_counter;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
-- 
1.7.0.4

