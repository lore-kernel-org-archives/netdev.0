From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: print MAC and serial number on probe failure
Date: Mon, 05 Jan 2009 23:57:32 +0100
Message-ID: <4962905C.1030308@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1808 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750823AbZAEW53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 17:57:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To help board identification and diagnosis, print the MAC
and serial number on probe failure if they are available.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-12-29 08:46:11.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-01-05 23:51:14.000000000 +0100
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.4-1.395"
+#define MYRI10GE_VERSION_STR "1.4.4-1.398"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -3929,6 +3929,10 @@
 	myri10ge_dummy_rdma(mgp, 0);
 
 abort_with_ioremap:
+	if (mgp->mac_addr_string != NULL)
+		dev_err(&pdev->dev,
+			"myri10ge_probe() failed: MAC=%s, SN=%ld\n",
+			mgp->mac_addr_string, mgp->serial_number);
 	iounmap(mgp->sram);
 
 abort_with_mtrr:


