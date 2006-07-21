From: Brice Goglin <brice@myri.com>
Subject: [patch 1/2] myri10ge - Always do a dummy RDMA after loading the firmware
Date: Fri, 21 Jul 2006 15:49:32 -0400
Message-ID: <44C12FCC.5080906@myri.com>
References: <44C12D14.7050509@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:59336 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751128AbWGUTte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 15:49:34 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44C12D14.7050509@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Always do a dummy RDMA after loading the firmware to work around
buggy PCIe chipsets which do not implement resending properly.
This is so cheap as to be almost free, and should never have been
conditional on the tx boundary != 4096.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-18 15:15:13.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-18 15:15:57.000000000 -0400
@@ -620,7 +620,7 @@
 		return -ENXIO;
 	}
 	dev_info(&mgp->pdev->dev, "handoff confirmed\n");
-	myri10ge_dummy_rdma(mgp, mgp->tx.boundary != 4096);
+	myri10ge_dummy_rdma(mgp, 1);
 
 	return 0;
 }


