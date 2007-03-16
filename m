From: Anton Blanchard <anton@samba.org>
Subject: Fix return code in pci-skeleton.c
Date: Fri, 16 Mar 2007 17:00:21 -0500
Message-ID: <20070316220021.GA11929@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39831 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965982AbXCPWEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 18:04:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We assign the return value of register_netdev to i, but return rc later
on. Fix it.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 00ca0fd..6ca4e4f 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -710,8 +710,8 @@ match:
 		tp->chipset,
 		rtl_chip_info[tp->chipset].name);
 
-	i = register_netdev (dev);
-	if (i)
+	rc = register_netdev (dev);
+	if (rc)
 		goto err_out_unmap;
 
 	DPRINTK ("EXIT, returning 0\n");
