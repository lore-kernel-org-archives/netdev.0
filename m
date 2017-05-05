From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: [PATCH v4 2/4] can: m_can: make m_can_start and m_can_stop symmetric
Date: Fri,  5 May 2017 15:50:31 +0200
Message-ID: <20170505135033.8349-2-quentin.schulz@free-electrons.com>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: wg@grandegger.com, mkl@pengutronix.de, mario.huettel@gmx.net,
        socketcan@hartkopp.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This moves clocks gating outside of the m_can_stop function as the
m_can_start function does not (and cannot, at least in current
implementation) ungate clocks. This way, both functions can now be used
symmetrically.

Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
---

added in v4

 drivers/net/can/m_can/m_can.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 5da1bdb202a3..6115dede671e 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1324,9 +1324,6 @@ static void m_can_stop(struct net_device *dev)
 	/* disable all interrupts */
 	m_can_disable_all_interrupts(priv);
 
-	clk_disable_unprepare(priv->hclk);
-	clk_disable_unprepare(priv->cclk);
-
 	/* set the state as STOPPED */
 	priv->can.state = CAN_STATE_STOPPED;
 }
@@ -1338,6 +1335,8 @@ static int m_can_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
 	m_can_stop(dev);
+	clk_disable_unprepare(priv->hclk);
+	clk_disable_unprepare(priv->cclk);
 	free_irq(dev->irq, dev);
 	close_candev(dev);
 	can_led_event(dev, CAN_LED_EVENT_STOP);
-- 
2.11.0
