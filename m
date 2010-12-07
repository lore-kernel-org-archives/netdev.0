From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v8 13/20] CAN : Fix bit timing calculation issue
Date: Tue, 07 Dec 2010 20:09:28 +0900
Message-ID: <4CFE15E8.1020502@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Modify like use calculated value directly passed by CAN core module.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/pch_can.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 3540978..5a6a0df 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -786,17 +786,15 @@ static int pch_set_bittiming(struct net_device *ndev)
 	const struct can_bittiming *bt = &priv->can.bittiming;
 	u32 canbit;
 	u32 bepe;
-	u32 brp;
 
 	/* Setting the CCE bit for accessing the Can Timing register. */
 	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_CCE);
 
-	brp = (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
-	canbit = brp & PCH_MSK_BITT_BRP;
+	canbit = (bt->brp - 1) & PCH_MSK_BITT_BRP;
 	canbit |= (bt->sjw - 1) << PCH_BIT_SJW_SHIFT;
 	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1_SHIFT;
 	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2_SHIFT;
-	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
+	bepe = ((bt->brp - 1) & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
 	iowrite32(canbit, &priv->regs->bitt);
 	iowrite32(bepe, &priv->regs->brpe);
 	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
-- 
1.6.0.6
