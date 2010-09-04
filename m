From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 12/21] ibmveth: Convert to netdev_alloc_skb
Date: Fri, 03 Sep 2010 23:29:03 -0500
Message-ID: <20100904042903.2655.97177.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:49697 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162Ab0IDE3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 00:29:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844F0sH017057
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 00:15:00 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844TVE9475224
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 00:29:31 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844TUxh001434
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:31 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were using alloc_skb which doesn't create any headroom. Change it to
use netdev_alloc_skb to match most other drivers.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:05.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:06.000000000 -0500
@@ -251,7 +251,7 @@ static void ibmveth_replenish_buffer_poo
 	for(i = 0; i < count; ++i) {
 		union ibmveth_buf_desc desc;
 
-		skb = alloc_skb(pool->buff_size, GFP_ATOMIC);
+		skb = netdev_alloc_skb(adapter->netdev, pool->buff_size);
 
 		if(!skb) {
 			ibmveth_debug_printk("replenish: unable to allocate skb\n");
