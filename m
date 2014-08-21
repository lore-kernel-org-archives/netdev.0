From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/4] can: flexcan: Disable error interrupt when bus error reporting is disabled
Date: Thu, 21 Aug 2014 11:23:21 +0200
Message-ID: <1408613002-29693-4-git-send-email-mkl@pengutronix.de>
References: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Alexander Stein <alexander.stein@systec-electronic.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42658 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbaHUJXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 05:23:40 -0400
In-Reply-To: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Stein <alexander.stein@systec-electronic.com>

In case we don't have FLEXCAN_HAS_BROKEN_ERR_STATE and the user set
CAN_CTRLMODE_BERR_REPORTING once it can not be unset again until reboot.
So in case neither hardware nor user wants the error interrupt disable
the bit.

Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index f425ec2..a691651 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -852,6 +852,8 @@ static int flexcan_chip_start(struct net_device *dev)
 	if (priv->devtype_data->features & FLEXCAN_HAS_BROKEN_ERR_STATE ||
 	    priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
 		reg_ctrl |= FLEXCAN_CTRL_ERR_MSK;
+	else
+		reg_ctrl &= ~FLEXCAN_CTRL_ERR_MSK;
 
 	/* save for later use */
 	priv->reg_ctrl_default = reg_ctrl;
-- 
2.1.0.rc1
