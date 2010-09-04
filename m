From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 18/21] ibmveth: Return -EINVAL on all ->probe errors
Date: Fri, 03 Sep 2010 23:29:36 -0500
Message-ID: <20100904042936.2655.15399.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43882 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab0IDEaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:30:05 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844P7X2002645
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:25:07 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844U3sQ112542
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:30:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844U3Fq003353
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:30:03 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a few cases where we returned success on error.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:23.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:24.000000000 -0500
@@ -1392,7 +1392,7 @@ static int __devinit ibmveth_probe(struc
 							NULL);
 	if (!mac_addr_p) {
 		dev_err(&dev->dev, "Can't find VETH_MAC_ADDR attribute\n");
-		return 0;
+		return -EINVAL;
 	}
 
 	mcastFilterSize_p = (unsigned int *)vio_get_attribute(dev,
@@ -1400,7 +1400,7 @@ static int __devinit ibmveth_probe(struc
 	if (!mcastFilterSize_p) {
 		dev_err(&dev->dev, "Can't find VETH_MCAST_FILTER_SIZE "
 			"attribute\n");
-		return 0;
+		return -EINVAL;
 	}
 
 	netdev = alloc_etherdev(sizeof(struct ibmveth_adapter));
