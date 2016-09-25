From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH] net: smc91x: take into account register shift
Date: Sun, 25 Sep 2016 23:00:45 +0200
Message-ID: <1474837245-32512-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>
To: Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This aligns smc91x with its cousin, namely smc911x.c.
This also allows the driver to run also in a device-tree based lubbock
board build, on which it was tested.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 drivers/net/ethernet/smsc/smc91x.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 726b80f45906..77ad2a3f59db 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2316,6 +2316,9 @@ static int smc_drv_probe(struct platform_device *pdev)
 		} else {
 			lp->cfg.flags |= SMC91X_USE_16BIT;
 		}
+		if (!device_property_read_u32(&pdev->dev, "reg-shift",
+					      &val))
+			lp->io_shift = val;
 	}
 #endif
 
-- 
2.1.4
