From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: always re-enable dummy rdmas in myri10ge_resume
Date: Wed, 09 Aug 2006 00:07:53 -0400
Message-ID: <44D95F99.8000906@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:404 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1030453AbWHIEIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 00:08:34 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dummy RDMA are always enabled on device startup since commit
9a71db721a2cbb9921b929b2699ab181f5a3c6c0 (to work around buggy
PCIe chipsets which do not implement resending properly). But,
we also need to always re-enable them when resuming the device.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-06 07:35:49.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-06 07:36:52.000000000 -0400
@@ -2418,7 +2418,7 @@
 	}
 
 	myri10ge_reset(mgp);
-	myri10ge_dummy_rdma(mgp, mgp->tx.boundary != 4096);
+	myri10ge_dummy_rdma(mgp, 1);
 
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */


