From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v9 10/20] pch_can: Replace netdev_dbg instead of dev_dbg partly
Date: Mon, 13 Dec 2010 15:24:16 +0900
Message-ID: <1292221467-8039-10-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-5-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-6-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-7-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-8-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-9-git-send-email-tomoya-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: wg@grandegger.com, w.sang@pengutronix.de, chripell@fsfe.org,
	21cnbao@gmail.com, sameo@linux.intel.com,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kerne
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292221467-8039-9-git-send-email-tomoya-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For easy to readable, use netdev_dbg instead of dev_dbg partly

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
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
