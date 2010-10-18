From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 1/8] can: mcp251x: fix NOHZ local_softirq_pending 08 warning
Date: Mon, 18 Oct 2010 15:31:07 +0200
Message-ID: <1287408674-15412-2-git-send-email-mkl@pengutronix.de>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287408674-15412-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

This patch replaces netif_rx() with netif_rx_ni() which has to be used
from the threaded interrupt i.e. process context context.

Thanks to Christian Pellegrin for pointing at the right fix:
481a8199142c050b72bff8a1956a49fd0a75bbe0 by Oliver Hartkopp.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---
 drivers/net/can/mcp251x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index b11a0cb..c06e023 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -451,7 +451,7 @@ static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 
 	priv->net->stats.rx_packets++;
 	priv->net->stats.rx_bytes += frame->can_dlc;
-	netif_rx(skb);
+	netif_rx_ni(skb);
 }
 
 static void mcp251x_hw_sleep(struct spi_device *spi)
@@ -676,7 +676,7 @@ static void mcp251x_error_skb(struct net_device *net, int can_id, int data1)
 	if (skb) {
 		frame->can_id = can_id;
 		frame->data[1] = data1;
-		netif_rx(skb);
+		netif_rx_ni(skb);
 	} else {
 		dev_err(&net->dev,
 			"cannot allocate error skb\n");
-- 
1.7.0.4
