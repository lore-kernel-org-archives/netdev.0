From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 03/11] can: at91_can: don't copy data to rx'ed RTR frames
Date: Mon,  6 Jun 2011 15:42:52 +0200
Message-ID: <1307367780-30715-4-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1307367780-30715-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
 drivers/net/can/at91_can.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index afd0f5d..5358d70 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -513,12 +513,14 @@ static void at91_read_mb(struct net_device *dev, unsigned int mb,
 		cf->can_id = (reg_mid >> 18) & CAN_SFF_MASK;
 
 	reg_msr = at91_read(priv, AT91_MSR(mb));
-	if (reg_msr & AT91_MSR_MRTR)
-		cf->can_id |= CAN_RTR_FLAG;
 	cf->can_dlc = get_can_dlc((reg_msr >> 16) & 0xf);
 
-	*(u32 *)(cf->data + 0) = at91_read(priv, AT91_MDL(mb));
-	*(u32 *)(cf->data + 4) = at91_read(priv, AT91_MDH(mb));
+	if (reg_msr & AT91_MSR_MRTR)
+		cf->can_id |= CAN_RTR_FLAG;
+	else {
+		*(u32 *)(cf->data + 0) = at91_read(priv, AT91_MDL(mb));
+		*(u32 *)(cf->data + 4) = at91_read(priv, AT91_MDH(mb));
+	}
 
 	/* allow RX of extended frames */
 	at91_write(priv, AT91_MID(mb), AT91_MID_MIDE);
-- 
1.7.4.1
