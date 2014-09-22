From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH] Revert "net/macb: add pinctrl consumer support"
Date: Mon, 22 Sep 2014 16:49:08 -0700
Message-ID: <1411429748-31444-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Soren Brinkmann <soren.brinkmann@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 8ef29f8aae524bd51298fb10ac6a5ce6c4c5a3d8.
The driver core already calls pinctrl_get() and claims the default
state. There is no need to replicate this in the driver.
---
Hi,

I might be mistaken, but I think the driver core does already take care=
 of
calling into the pinctrl framework and the driver does not need to do i=
t on its
own (drivers/base/dd.c:really_probe() calls 'pinctrl_bind_pins() which =
takes
care of the pinctrl setup).

	Thanks,
	S=C3=B6ren

 drivers/net/ethernet/cadence/macb.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
index ca5d7798b265..e1e02fba4fcc 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -30,7 +30,6 @@
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
-#include <linux/pinctrl/consumer.h>
=20
 #include "macb.h"
=20
@@ -2071,7 +2070,6 @@ static int __init macb_probe(struct platform_devi=
ce *pdev)
 	struct phy_device *phydev;
 	u32 config;
 	int err =3D -ENXIO;
-	struct pinctrl *pinctrl;
 	const char *mac;
=20
 	regs =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2080,15 +2078,6 @@ static int __init macb_probe(struct platform_dev=
ice *pdev)
 		goto err_out;
 	}
=20
-	pinctrl =3D devm_pinctrl_get_select_default(&pdev->dev);
-	if (IS_ERR(pinctrl)) {
-		err =3D PTR_ERR(pinctrl);
-		if (err =3D=3D -EPROBE_DEFER)
-			goto err_out;
-
-		dev_warn(&pdev->dev, "No pinctrl provided\n");
-	}
-
 	err =3D -ENOMEM;
 	dev =3D alloc_etherdev(sizeof(*bp));
 	if (!dev)
--=20
2.1.0.1.g27b9230
