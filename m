From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 06/21] ibmveth: Use lighter weight read memory barrier in ibmveth_poll
Date: Fri, 03 Sep 2010 23:28:31 -0500
Message-ID: <20100904042831.2655.47418.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:39259 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab0IDE27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:59 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844KXH5008344
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:20:33 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844SwsX198614
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844SwVZ032437
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:58 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to order the read in ibmveth_rxq_pending_buffer and the read of
ibmveth_rxq_buffer_valid which are both cacheable memory. smp_rmb() is good
enough for this.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
ext-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:48.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:49.000000000 -0500
@@ -1010,7 +1010,7 @@ static int ibmveth_poll(struct napi_stru
 		if (!ibmveth_rxq_pending_buffer(adapter))
 			break;
 
-		rmb();
+		smp_rmb();
 		if (!ibmveth_rxq_buffer_valid(adapter)) {
 			wmb(); /* suggested by larson1 */
 			adapter->rx_invalid_buffer++;
