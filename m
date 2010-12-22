From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH] pch_can: Fix array miss-pointing issue
Date: Wed, 22 Dec 2010 22:00:39 +0900
Message-ID: <1293022839-3202-1-git-send-email-tomoya-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
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


Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 8d45fdd..c42e972 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1078,15 +1078,17 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	/* Save Tx buffer enable state */
 	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
-		priv->tx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_TX_IFREG);
+		priv->tx_enable[i - 1] = pch_can_get_rxtx_ir(priv, i,
+							     PCH_TX_IFREG);
 
 	/* Disable all Transmit buffers */
 	pch_can_set_tx_all(priv, 0);
 
 	/* Save Rx buffer enable state */
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
-		priv->rx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_RX_IFREG);
-		priv->rx_link[i] = pch_can_get_rx_buffer_link(priv, i);
+		priv->rx_enable[i - 1] = pch_can_get_rxtx_ir(priv, i,
+							     PCH_RX_IFREG);
+		priv->rx_link[i - 1] = pch_can_get_rx_buffer_link(priv, i);
 	}
 
 	/* Disable all Receive buffers */
@@ -1139,15 +1141,15 @@ static int pch_can_resume(struct pci_dev *pdev)
 
 	/* Enabling the transmit buffer. */
 	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
-		pch_can_set_rxtx(priv, i, priv->tx_enable[i], PCH_TX_IFREG);
+		pch_can_set_rxtx(priv, i, priv->tx_enable[i - 1], PCH_TX_IFREG);
 
 	/* Configuring the receive buffer and enabling them. */
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		/* Restore buffer link */
-		pch_can_set_rx_buffer_link(priv, i, priv->rx_link[i]);
+		pch_can_set_rx_buffer_link(priv, i, priv->rx_link[i - 1]);
 
 		/* Restore buffer enables */
-		pch_can_set_rxtx(priv, i, priv->rx_enable[i], PCH_RX_IFREG);
+		pch_can_set_rxtx(priv, i, priv->rx_enable[i - 1], PCH_RX_IFREG);
 	}
 
 	/* Enable CAN Interrupts */
-- 
1.6.0.6
