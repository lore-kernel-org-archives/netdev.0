From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 15/17] can: m_can: add missing delay after setting CCCR_INIT bit
Date: Tue, 18 Nov 2014 21:37:45 +0100
Message-ID: <1416343067-9810-16-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Dong Aisheng <b29396@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dong Aisheng <b29396@freescale.com>

The spec mentions there may be a delay until the value written to INIT can be
read back due to the synchronization mechanism between the two clock domains.
But it does not indicate the exact clock cycles needed. The 5us delay is a
test value and seems ok.

Without the delay, CCCR.CCE bit may fail to be set and then the initialization
fail sometimes when do repeatly up and down.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/m_can/m_can.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 98f7e0ea7f6a..3ad7d88720b7 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -296,6 +296,7 @@ static inline void m_can_config_endisable(const struct m_can_priv *priv,
 	if (enable) {
 		/* enable m_can configuration */
 		m_can_write(priv, M_CAN_CCCR, cccr | CCCR_INIT);
+		udelay(5);
 		/* CCCR.CCE can only be set/reset while CCCR.INIT = '1' */
 		m_can_write(priv, M_CAN_CCCR, cccr | CCCR_INIT | CCCR_CCE);
 	} else {
-- 
2.1.3

