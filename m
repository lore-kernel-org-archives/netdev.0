From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] ibmveth: Fix oops on request_irq failure
Date: Wed, 28 Sep 2011 10:33:43 -0500
Message-ID: <201109281533.p8SFXhfe030707@d03av04.boulder.ibm.com>
Cc: brking@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:38185 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168Ab1I1PeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 11:34:05 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8SFA3BD030996
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 11:10:03 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8SFXwGl966658
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 11:33:58 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8SFXiKt030802
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 09:33:44 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If request_irq fails, the ibmveth driver will overwrite
the rc and end up returning a successful rc on its open
function, resulting in an oops later when a packet gets
sent and buffers are not allocated due to the failed open.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 drivers/net/ibmveth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_bounce_oops2 drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_bounce_oops2	2011-09-28 09:53:09.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2011-09-28 09:53:09.000000000 -0500
@@ -636,8 +636,8 @@ static int ibmveth_open(struct net_devic
 		netdev_err(netdev, "unable to request irq 0x%x, rc %d\n",
 			   netdev->irq, rc);
 		do {
-			rc = h_free_logical_lan(adapter->vdev->unit_address);
-		} while (H_IS_LONG_BUSY(rc) || (rc == H_BUSY));
+			lpar_rc = h_free_logical_lan(adapter->vdev->unit_address);
+		} while (H_IS_LONG_BUSY(lpar_rc) || (lpar_rc == H_BUSY));
 
 		goto err_out;
 	}
_
