From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] net/can/mscan: add listen only mode
Date: Thu,  3 Nov 2011 14:00:43 +0100
Message-ID: <1320325243-24907-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49182 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143Ab1KCNAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 09:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds listen only mode to the mscan controller.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---

...can be pulled via:

The following changes since commit 8b3408f8ee994973869d8ba32c5bf482bc4ddca4:

  dp83640: free packet queues on remove (2011-10-24 19:14:50 -0400)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git can/mscan-listen-only-for-net-next

Marc Kleine-Budde (1):
      net/can/mscan: add listen only mode

 drivers/net/can/mscan/mscan.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index ec4a311..74f3b18 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -581,7 +581,10 @@ static int mscan_open(struct net_device *dev)
 
 	priv->open_time = jiffies;
 
-	clrbits8(&regs->canctl1, MSCAN_LISTEN);
+	if (ctrlmode.flags & CAN_CTRLMODE_LISTENONLY)
+		setbits8(&regs->canctl1, MSCAN_LISTEN);
+	else
+		clrbits8(&regs->canctl1, MSCAN_LISTEN);
 
 	ret = mscan_start(dev);
 	if (ret)
@@ -690,7 +693,8 @@ struct net_device *alloc_mscandev(void)
 	priv->can.bittiming_const = &mscan_bittiming_const;
 	priv->can.do_set_bittiming = mscan_do_set_bittiming;
 	priv->can.do_set_mode = mscan_do_set_mode;
-	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
+		CAN_CTRLMODE_LISTENONLY;
 
 	for (i = 0; i < TX_QUEUE_SIZE; i++) {
 		priv->tx_queue[i].id = i;
-- 
1.7.4.1
