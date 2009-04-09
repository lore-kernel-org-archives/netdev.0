From: Dan Carpenter <error27@gmail.com>
Subject: [patch] error handling for platform_device_register_simple()
Date: Thu, 9 Apr 2009 10:55:29 +0300 (EAT)
Message-ID: <alpine.DEB.2.00.0904090640170.13970@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: vbordug@ru.mvista.com, avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:18720 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758660AbZDIHzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 03:55:54 -0400
Received: by qw-out-2122.google.com with SMTP id 8so585262qwh.37
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 00:55:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

platform_device_register_simple() returns ERR_PTR() and not NULL.

Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/phy/fixed.c	2009-04-09 05:53:24.000000000 +0300
+++ devel/drivers/net/phy/fixed.c	2009-04-09 05:53:52.000000000 +0300
@@ -207,8 +207,8 @@
 	int ret;
 
 	pdev = platform_device_register_simple("Fixed MDIO bus", 0, NULL, 0);
-	if (!pdev) {
-		ret = -ENOMEM;
+	if (IS_ERR(pdev)) {
+		ret = PTR_ERR(pdev);
 		goto err_pdev;
 	}
 
