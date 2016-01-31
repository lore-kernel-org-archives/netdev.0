From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH] net: smc91x: propagate irq return code
Date: Sun, 31 Jan 2016 23:46:17 +0100
Message-ID: <1454280377-25697-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The smc91x driver doesn't honor the probe deferral mechanism when the
interrupt source is not yet available, such as one provided by a gpio
controller not probed.

Fix this by propagating the platform_get_irq() error code as the probe
return value.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 drivers/net/ethernet/smsc/smc91x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 0e2fc1a844ab..43ab7aa31a79 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2343,7 +2343,7 @@ static int smc_drv_probe(struct platform_device *pdev)
 
 	ndev->irq = platform_get_irq(pdev, 0);
 	if (ndev->irq <= 0) {
-		ret = -ENODEV;
+		ret = ndev->irq;
 		goto out_release_io;
 	}
 	/*
-- 
2.1.4
