From: Jonathan Cameron <jic23@cam.ac.uk>
Subject: [PATCH 2.6.27-rc1] smc91x.c smc_drv_remove bugfix? (been there a
 while!)
Date: Thu, 31 Jul 2008 20:27:56 +0100
Message-ID: <4892123C.2060007@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-6.csi.cam.ac.uk ([131.111.8.136]:60331 "EHLO
	ppsw-6.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbYGaTwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 15:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Cameron

Trivial bug fix for typo in smc91x.c that results in null pointer dereference

Signed-of-by: Jonathan Cameron

--
Could just have submitted this as a bug report, but as it's a trivial patch
this seemed easier. Clearly this will be irrelevant if people have moved board
configs to using resource names, but for now... Not been involved with net drivers
before so sorry if I've sent it to the wrong people!

/drivers/net/smc91x.c	2008-07-31 12:02:47.000000000 +0100
+++ b/drivers/net/smc91x.c	2008-07-31 20:06:19.000000000 +0100
@@ -2255,7 +2255,7 @@ static int smc_drv_remove(struct platfor
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-regs");
 	if (!res)
-		platform_get_resource(pdev, IORESOURCE_MEM, 0);
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, SMC_IO_EXTENT);
 
 	free_netdev(ndev);

