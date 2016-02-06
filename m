From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v2] net: smc91x: propagate irq return code
Date: Sat,  6 Feb 2016 22:23:20 +0100
Message-ID: <1454793800-7789-1-git-send-email-robert.jarzmik@free.fr>
Cc: linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:27913 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbcBFVXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 16:23:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smc91x driver doesn't honor the probe deferral mechanism when the
interrupt source is not yet available, such as one provided by a gpio
controller not probed.

Fix this by propagating the platform_get_irq() error code as the probe
return value.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
Since v1: change the irq test to < 0
---
 drivers/net/ethernet/smsc/smc91x.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 0e2fc1a844ab..db7db8ac4ca3 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2342,8 +2342,8 @@ static int smc_drv_probe(struct platform_device *pdev)
 	}
 
 	ndev->irq = platform_get_irq(pdev, 0);
-	if (ndev->irq <= 0) {
-		ret = -ENODEV;
+	if (ndev->irq < 0) {
+		ret = ndev->irq;
 		goto out_release_io;
 	}
 	/*
-- 
2.1.4
