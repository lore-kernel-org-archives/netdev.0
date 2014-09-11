From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: flexcan: avoid calling usleep_range from interrupt context
Date: Thu, 11 Sep 2014 09:53:04 +0200
Message-ID: <1410421984-15125-2-git-send-email-mkl@pengutronix.de>
References: <1410421984-15125-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, David Jander <david@protonic.nl>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1410421984-15125-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Jander <david@protonic.nl>

Apparently can_restart() runs from a (timer-) interrupt and can call
flexcan_chip_[en|dis]able(), so avoid using usleep_range()

Signed-off-by: David Jander <david@protonic.nl>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 944aa5d..630c7bf 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -298,7 +298,7 @@ static int flexcan_chip_enable(struct flexcan_priv *priv)
 	flexcan_write(reg, &regs->mcr);
 
 	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
-		usleep_range(10, 20);
+		udelay(10);
 
 	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK)
 		return -ETIMEDOUT;
@@ -317,7 +317,7 @@ static int flexcan_chip_disable(struct flexcan_priv *priv)
 	flexcan_write(reg, &regs->mcr);
 
 	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
-		usleep_range(10, 20);
+		udelay(10);
 
 	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
 		return -ETIMEDOUT;
@@ -336,7 +336,7 @@ static int flexcan_chip_freeze(struct flexcan_priv *priv)
 	flexcan_write(reg, &regs->mcr);
 
 	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
-		usleep_range(100, 200);
+		udelay(100);
 
 	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
 		return -ETIMEDOUT;
@@ -355,7 +355,7 @@ static int flexcan_chip_unfreeze(struct flexcan_priv *priv)
 	flexcan_write(reg, &regs->mcr);
 
 	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
-		usleep_range(10, 20);
+		udelay(10);
 
 	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK)
 		return -ETIMEDOUT;
@@ -370,7 +370,7 @@ static int flexcan_chip_softreset(struct flexcan_priv *priv)
 
 	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
 	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST))
-		usleep_range(10, 20);
+		udelay(10);
 
 	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST)
 		return -ETIMEDOUT;
-- 
2.1.0
