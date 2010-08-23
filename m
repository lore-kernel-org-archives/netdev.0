From: Anton Blanchard <anton@samba.org>
Subject: [patch 11/20] ibmveth: Convert to netdev_alloc_skb
Date: Mon, 23 Aug 2010 10:09:41 +1000
Message-ID: <20100823001239.327034592@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51847 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748Ab0HWA2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:28:49 -0400
Content-Disposition: inline; filename=veth_use_netdev_alloc_skb
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were using alloc_skb which doesn't create any headroom. Change it to
use netdev_alloc_skb to match most other drivers.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:31.723652837 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:32.113625155 +1000
@@ -248,7 +248,7 @@ static void ibmveth_replenish_buffer_poo
 	for(i = 0; i < count; ++i) {
 		union ibmveth_buf_desc desc;
 
-		skb = alloc_skb(pool->buff_size, GFP_ATOMIC);
+		skb = netdev_alloc_skb(adapter->netdev, pool->buff_size);
 
 		if(!skb) {
 			ibmveth_debug_printk("replenish: unable to allocate skb\n");


