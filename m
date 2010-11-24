From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 9/17 v2] can: EG20T PCH: Use netdev_dbg instead
 of dev_dbg
Date: Wed, 24 Nov 2010 16:36:56 +0900
Message-ID: <4CECC098.5020809__1271.5921424844$1290584318$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11479 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751488Ab0KXHhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:37:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For easy to readable, use netdev_dbg instead of dev_dbg partly

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 3a39786..e71817d 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -222,7 +222,7 @@ static void pch_can_set_run_mode(struct pch_can_priv
*priv,
 		break;
  	default:
-		dev_err(&priv->ndev->dev, "%s -> Invalid Mode.\n", __func__);
+		netdev_err(priv->ndev, "%s -> Invalid Mode.\n", __func__);
 		break;
 	}
 }
@@ -275,7 +275,7 @@ static void pch_can_set_int_enables(struct
pch_can_priv *priv,
 		break;
  	default:
-		dev_err(&priv->ndev->dev, "Invalid interrupt number.\n");
+		netdev_err(priv->ndev, "Invalid interrupt number.\n");
 		break;
 	}
 }
@@ -535,7 +535,7 @@ static void pch_can_error(struct net_device *ndev,
u32 status)
 			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
 		if ((errc & PCH_TEC) > 96)
 			cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
-		dev_warn(&ndev->dev,
+		netdev_dbg(ndev,
 			"%s -> Error Counter is more than 96.\n", __func__);
 	}
 	/* Error passive interrupt. */
@@ -547,7 +547,7 @@ static void pch_can_error(struct net_device *ndev,
u32 status)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
 		if ((errc & PCH_TEC) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
-		dev_err(&ndev->dev,
+		netdev_dbg(ndev,
 			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);
 	}
 @@ -877,10 +877,10 @@ static int pch_can_open(struct net_device *ndev)
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
 @@ -888,14 +888,14 @@ static int pch_can_open(struct net_device *ndev)
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
 -- 1.6.0.6

