From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v2 2/3] net: smc91x: take into account half-word workaround
Date: Sun,  9 Oct 2016 22:33:46 +0200
Message-ID: <1476045227-2970-2-git-send-email-robert.jarzmik@free.fr>
References: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:18489 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751790AbcJIUeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 16:34:19 -0400
In-Reply-To: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For device-tree builds, platforms such as mainstone, idp and stargate2
must have their u16 writes all aligned on 32 bit boundaries. This is
already enabled in platform data builds, and this patch adds it to
device-tree builds.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
Since v1: rename dt property to pxa-u16-align4
---
 drivers/net/ethernet/smsc/smc91x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index b1f74e06d98e..e2f151258b38 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2323,6 +2323,8 @@ static int smc_drv_probe(struct platform_device *pdev)
 		if (!device_property_read_u32(&pdev->dev, "reg-shift",
 					      &val))
 			lp->io_shift = val;
+		lp->half_word_align4 =
+			device_property_read_bool(&pdev->dev, "pxa-u16-align4");
 	}
 #endif
 
-- 
2.1.4
