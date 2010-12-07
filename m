From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v8 10/20] CAN : Replace netdev_dbg instead of
	dev_dbg partly
Date: Tue, 07 Dec 2010 20:08:18 +0900
Message-ID: <4CFE15A2.5010601@dsn.okisemi.com>
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

For easy to readable, use netdev_dbg instead of dev_dbg partly

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 293be51..0093a01 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -222,7 +222,7 @@ static void pch_can_set_run_mode(struct pch_can_priv *priv,
 		break;
 
 	default:
-		dev_err(&priv->ndev->dev, "%s -> Invalid Mode.\n", __func__);
+		netdev_err(priv->ndev, "%s -> Invalid Mode.\n", __func__);
 		break;
 	}
 }
@@ -275,7 +275,7 @@ static void pch_can_set_int_enables(struct pch_can_priv *priv,
 		break;
 
 	default:
-		dev_err(&priv->ndev->dev, "Invalid interrupt number.\n");
+		netdev_err(priv->ndev, "Invalid interrupt number.\n");
 		break;
 	}
 }
@@ -528,7 +528,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
 		if ((errc & PCH_TEC) > 96)
 			cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
-		dev_warn(&ndev->dev,
+		netdev_dbg(ndev,
 			"%s -> Error Counter is more than 96.\n", __func__);
 	}
 	/* Error passive interrupt. */
@@ -540,7 +540,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
 		if ((errc & PCH_TEC) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
-		dev_err(&ndev->dev,
+		netdev_dbg(ndev,
 			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);
 	}
 
@@ -859,10 +859,10 @@ static int pch_can_open(struct net_device *ndev)
 
 	retval = pci_enable_msi(priv->dev);
 	if (retval) {
-		dev_info(&ndev->dev, "PCH CAN opened without MSI\n");
+		netdev_err(ndev, "PCH CAN opened without MSI\n");
 		priv->use_msi = 0;
 	} else {
-		dev_info(&ndev->dev, "PCH CAN opened with MSI\n");
+		netdev_err(ndev, "PCH CAN opened with MSI\n");
 		priv->use_msi = 1;
 	}
 
@@ -870,14 +870,14 @@ static int pch_can_open(struct net_device *ndev)
 	retval = request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED,
 			     ndev->name, ndev);
 	if (retval) {
-		dev_err(&ndev->dev, "request_irq failed.\n");
+		netdev_err(ndev, "request_irq failed.\n");
 		goto req_irq_err;
 	}
 
 	/* Open common can device */
 	retval = open_candev(ndev);
 	if (retval) {
-		dev_err(ndev->dev.parent, "open_candev() failed %d\n", retval);
+		netdev_err(ndev, "open_candev() failed %d\n", retval);
 		goto err_open_candev;
 	}
 
-- 
1.6.0.6
