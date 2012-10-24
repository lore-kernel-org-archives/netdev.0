From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in probe
Date: Wed, 24 Oct 2012 11:21:36 -0400
Message-ID: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
Cc: Wei Yang <Wei.Yang@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62979 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965198Ab2JXPVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 11:21:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <Wei.Yang@windriver.com>

When using a 36 bit dtb file, the driver complains "resource busy".

Investigating the source of the message leads one to the
gianfar_ptp_probe function.

Since the type of the device resource requested in this function
is IORESOURCE_MEM, it should use "iomem_resource" instead of
"ioports_resource".

Signed-off-by: Wei Yang <Wei.Yang@windriver.com>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index b9db0e0..2e5daee 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -478,7 +478,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 		pr_err("no resource\n");
 		goto no_resource;
 	}
-	if (request_resource(&ioport_resource, etsects->rsrc)) {
+	if (request_resource(&iomem_resource, etsects->rsrc)) {
 		pr_err("resource busy\n");
 		goto no_resource;
 	}
-- 
1.7.11.1
