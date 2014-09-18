From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/8] can: c_can_platform: fix parameters of c_can_hw_raminit_ti()
Date: Thu, 18 Sep 2014 12:40:55 +0200
Message-ID: <1411036862-13255-2-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Roger Quadros <rogerq@ti.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37879 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886AbaIRKlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 06:41:10 -0400
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Quadros <rogerq@ti.com>

Pass the correct 'mask' and 'value' bits to c_can_hw_raminit_wait_ti(). They
seem to have been swapped in the usage instances.

Reported-by: Jay Schroeder <jay.schroeder@garmin.com>
Signed-off-by: Roger Quadros <rogerq@ti.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_platform.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 109cb44..fb279d6 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -97,14 +97,14 @@ static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
 	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
 	writel(ctrl, priv->raminit_ctrlreg);
 	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
-	c_can_hw_raminit_wait_ti(priv, ctrl, mask);
+	c_can_hw_raminit_wait_ti(priv, mask, ctrl);
 
 	if (enable) {
 		/* Set start bit and wait for the done bit. */
 		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
 		writel(ctrl, priv->raminit_ctrlreg);
 		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
-		c_can_hw_raminit_wait_ti(priv, ctrl, mask);
+		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
 	}
 	spin_unlock(&raminit_lock);
 }
-- 
2.1.0
