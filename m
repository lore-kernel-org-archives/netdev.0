From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH v2 5/9] can: mcp251x: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:13 +0100
Message-ID: <1293296117-27624-6-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1293296117-27624-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
Cc: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 drivers/net/can/mcp251x.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 7ab534a..9e08acc 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -481,7 +481,8 @@ static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 	}
 	/* Data length */
 	frame->can_dlc = get_can_dlc(buf[RXBDLC_OFF] & RXBDLC_LEN_MASK);
-	memcpy(frame->data, buf + RXBDAT_OFF, frame->can_dlc);
+	if (!(frame->can_id & CAN_RTR_FLAG))
+		memcpy(frame->data, buf + RXBDAT_OFF, frame->can_dlc);
 
 	priv->net->stats.rx_packets++;
 	priv->net->stats.rx_bytes += frame->can_dlc;
-- 
1.7.2.3
