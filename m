From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 2/2] can: mcp251x: fix generation of error frames
Date: Wed, 20 Oct 2010 12:02:26 +0200
Message-ID: <1287568946-32727-3-git-send-email-mkl@pengutronix.de>
References: <1287568946-32727-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287568946-32727-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

The function "mcp251x_error_skb" is used to generate error frames.
They are identified by the "CAN_ERR_FLAG" in can_id. The function
overwrites the can_id so that the frames show up as normal frames instead
of error frames.

This patch fixes the problem by or'ing the can_id instead of overwriting it.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Tested-by: Jargalan Nermunkh <jargalan.nermunkh-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org>
---
 drivers/net/can/mcp251x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 59f40bc..6aadc3e 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -705,7 +705,7 @@ static void mcp251x_error_skb(struct net_device *net, int can_id, int data1)
 
 	skb = alloc_can_err_skb(net, &frame);
 	if (skb) {
-		frame->can_id = can_id;
+		frame->can_id |= can_id;
 		frame->data[1] = data1;
 		netif_rx_ni(skb);
 	} else {
-- 
1.7.0.4
