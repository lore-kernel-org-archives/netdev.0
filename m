From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 3/9] can: flexcan: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 15:40:28 +0100
Message-ID: <1293288034-22428-4-git-send-email-mkl@pengutronix.de>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1293288034-22428-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 drivers/net/can/flexcan.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index d499056..b0e16f5 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -471,12 +471,14 @@ static void flexcan_read_fifo(const struct net_device *dev,
 	else
 		cf->can_id = (reg_id >> 18) & CAN_SFF_MASK;
 
-	if (reg_ctrl & FLEXCAN_MB_CNT_RTR)
-		cf->can_id |= CAN_RTR_FLAG;
 	cf->can_dlc = get_can_dlc((reg_ctrl >> 16) & 0xf);
 
-	*(__be32 *)(cf->data + 0) = cpu_to_be32(readl(&mb->data[0]));
-	*(__be32 *)(cf->data + 4) = cpu_to_be32(readl(&mb->data[1]));
+	if (reg_ctrl & FLEXCAN_MB_CNT_RTR)
+		cf->can_id |= CAN_RTR_FLAG;
+	else {
+		*(__be32 *)(cf->data + 0) = cpu_to_be32(readl(&mb->data[0]));
+		*(__be32 *)(cf->data + 4) = cpu_to_be32(readl(&mb->data[1]));
+	}
 
 	/* mark as read */
 	writel(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
-- 
1.7.2.3
