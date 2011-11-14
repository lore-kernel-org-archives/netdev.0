From: Wolfgang Grandegger <wg@grandegger.com>
Subject: net/can/mscan: Fix buggy listen only mode setting
Date: Mon, 14 Nov 2011 14:34:56 +0100
Message-ID: <4EC11900.7030005@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, Socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue introduced recently with commit
452448f9283e1939408b397e87974a418825b0a8.

CC: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/mscan/mscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 74f3b18..1c82dd8 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -581,7 +581,7 @@ static int mscan_open(struct net_device *dev)
 
 	priv->open_time = jiffies;
 
-	if (ctrlmode.flags & CAN_CTRLMODE_LISTENONLY)
+	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
 		setbits8(&regs->canctl1, MSCAN_LISTEN);
 	else
 		clrbits8(&regs->canctl1, MSCAN_LISTEN);
-- 
1.7.6.4
