From: Anton Blanchard <anton@samba.org>
Subject: [patch 17/20] ibmveth: Return -EINVAL on all ->probe errors.
Date: Mon, 23 Aug 2010 10:09:47 +1000
Message-ID: <20100823001239.897783243@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51869 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab0HWA3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:29:42 -0400
Content-Disposition: inline; filename=veth_return_error
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a few cases where we returned success on error.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 09:23:11.982966815 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 09:23:32.781489458 +1000
@@ -1358,7 +1358,7 @@ static int __devinit ibmveth_probe(struc
 						VETH_MAC_ADDR, NULL);
 	if (!mac_addr_p) {
 		dev_err(&dev->dev, "Can't find VETH_MAC_ADDR attribute\n");
-		return 0;
+		return -EINVAL;
 	}
 
 	mcastFilterSize_p = (unsigned int *)vio_get_attribute(dev,
@@ -1366,7 +1366,7 @@ static int __devinit ibmveth_probe(struc
 	if (!mcastFilterSize_p) {
 		dev_err(&dev->dev, "Can't find VETH_MCAST_FILTER_SIZE "
 			"attribute\n");
-		return 0;
+		return -EINVAL;
 	}
 
 	netdev = alloc_etherdev(sizeof(struct ibmveth_adapter));


