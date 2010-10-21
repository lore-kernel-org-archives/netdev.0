From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] can: mcp251x: fix reception of standard RTR frames
Date: Thu, 21 Oct 2010 18:37:10 +0200
Message-ID: <1287679030-13993-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

This patch sets the missing CAN_RTR_FLAG if a standard RTR frame is
received.
(For extended frames the CAN_RTR_FLAG was already set correctly.)

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---

BTW:
This patch is unrelated to the ongoing discussion:
"CAN frames with RTR and dlc != 0"

The following changes since commit 27b75c95f10d249574d9c4cb9dab878107faede8:
  Eric Dumazet (1):
        net: avoid RCU for NOCACHE dst

are available in the git repository at:

  git://git.pengutronix.de/git/mkl/linux-2.6.git can/mcp251x-rtr-for-net-next

Marc Kleine-Budde (1):
      can: mcp251x: fix reception of standard RTR frames

 drivers/net/can/mcp251x.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index c664be2..e3b4b35 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -168,6 +168,7 @@
 #  define RXBSIDH_SHIFT 3
 #define RXBSIDL(n)  (((n) * 0x10) + 0x60 + RXBSIDL_OFF)
 #  define RXBSIDL_IDE   0x08
+#  define RXBSIDL_SRR   0x10
 #  define RXBSIDL_EID   3
 #  define RXBSIDL_SHIFT 5
 #define RXBEID8(n)  (((n) * 0x10) + 0x60 + RXBEID8_OFF)
@@ -474,6 +475,8 @@ static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 		frame->can_id =
 			(buf[RXBSIDH_OFF] << RXBSIDH_SHIFT) |
 			(buf[RXBSIDL_OFF] >> RXBSIDL_SHIFT);
+		if (buf[RXBSIDL_OFF] & RXBSIDL_SRR)
+			frame->can_id |= CAN_RTR_FLAG;
 	}
 	/* Data length */
 	frame->can_dlc = get_can_dlc(buf[RXBDLC_OFF] & RXBDLC_LEN_MASK);
-- 
1.7.0.4
