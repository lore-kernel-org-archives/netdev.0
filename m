From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] net/can/mscan: add listen only mode
Date: Wed,  9 Nov 2011 21:50:49 +0100
Message-ID: <1320871849-24719-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds listen only mode to the mscan controller.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---

The patch targets net-next/master and can be pulled:

The following changes since commit e56c57d0d3fdbbdf583d3af96bfb803b8dfa713e:

  net: rename sk_clone to sk_clone_lock (2011-11-08 17:07:07 -0500)

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

