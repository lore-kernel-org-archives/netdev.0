From: Jonathan Cameron <jic23@cam.ac.uk>
Subject: [PATCH 2.6.27-rc4] smc91x bug fix to avoid null pointer dereference
Date: Fri, 22 Aug 2008 10:48:54 +0100
Message-ID: <48AE8B86.8080608@cam.ac.uk>
References: <4892123C.2060007@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-0.csi.cam.ac.uk ([131.111.8.130]:55051 "EHLO
	ppsw-0.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbYHVJsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 05:48:53 -0400
Received: from coriolanus.eng.cam.ac.uk ([129.169.154.144]:40029)
	by ppsw-0.csi.cam.ac.uk (smtp.hermes.cam.ac.uk [131.111.8.150]:25)
	with esmtpsa (PLAIN:jic23) (TLSv1:DHE-RSA-AES256-SHA:256)
	id 1KWTGG-0001zv-1I (Exim 4.70) for netdev@vger.kernel.org
	(return-path <jic23@cam.ac.uk>); Fri, 22 Aug 2008 10:48:52 +0100
In-Reply-To: <4892123C.2060007@cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Cameron

Bug fix for typo in smc91x.c that results in null pointer dereference.

Signed-off-by: Jonathan Cameron <jic23@cam.ac.uk>
Acked-by: Nicolas Pitre <nico@cam.org>

--
Rebased against 2.6.27-rc4 and with Nicolas' ack.

--- a/drivers/net/smc91x.c	2008-08-21 14:49:28.000000000 +0100
+++ b/drivers/net/smc91x.c	2008-08-21 15:12:48.000000000 +0100
@@ -2255,7 +2255,7 @@ static int smc_drv_remove(struct platfor
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-regs");
 	if (!res)
-		platform_get_resource(pdev, IORESOURCE_MEM, 0);
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, SMC_IO_EXTENT);
 
 	free_netdev(ndev);
