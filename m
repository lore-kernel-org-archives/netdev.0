From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/5] myri10ge: make msi configurable at runtime through sysfs
Date: Mon, 18 Dec 2006 11:51:22 +0100
Message-ID: <458672AA.4030003@myri.com>
References: <45867228.1090406@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:41358 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753844AbWLRLVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 06:21:40 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <45867228.1090406@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that IRQ are requested is called on open() and freed on close(),
we can safely switch from/to MSI without unloading the module.

We are guaranteed to correctly free IRQ even if the sysfs file got
written in the meantime since the MSI initialization is stored in
mgp->msi_enabled.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-12-17 22:15:52.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-12-17 22:16:47.000000000 +0100
@@ -228,7 +228,7 @@
 MODULE_PARM_DESC(myri10ge_small_bytes, "Threshold of small packets\n");
 
 static int myri10ge_msi = 1;	/* enable msi by default */
-module_param(myri10ge_msi, int, S_IRUGO);
+module_param(myri10ge_msi, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts\n");
 
 static int myri10ge_intr_coal_delay = 25;


