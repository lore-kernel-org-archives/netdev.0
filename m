From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 01/10] can: at91_can: use correct bit to enable
	CAN_CTRLMODE_3_SAMPLES
Date: Thu, 21 Oct 2010 13:01:13 +0200
Message-ID: <1287658882-26914-2-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287658882-26914-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 2d8bd86..b2a4599 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -2,7 +2,7 @@
  * at91_can.c - CAN network driver for AT91 SoC CAN controller
  *
  * (C) 2007 by Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
- * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ * (C) 2008, 2009, 2010 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
  *
  * This software may be distributed under the terms of the GNU General
  * Public License ("GPL") version 2 as distributed in the 'COPYING'
@@ -257,8 +257,8 @@ static int at91_set_bittiming(struct net_device *dev)
 	const struct can_bittiming *bt = &priv->can.bittiming;
 	u32 reg_br;
 
-	reg_br = ((priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) << 24) |
-		((bt->brp - 1) << 16) |	((bt->sjw - 1) << 12) |
+	reg_br = ((priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) ? 1 << 24 : 0) |
+		((bt->brp - 1) << 16) | ((bt->sjw - 1) << 12) |
 		((bt->prop_seg - 1) << 8) | ((bt->phase_seg1 - 1) << 4) |
 		((bt->phase_seg2 - 1) << 0);
 
-- 
1.7.0.4
