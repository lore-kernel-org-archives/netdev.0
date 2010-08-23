From: Anton Blanchard <anton@samba.org>
Subject: [patch 06/20] ibmveth: Use lighter weight read memory barrier in ibmveth_poll
Date: Mon, 23 Aug 2010 10:09:36 +1000
Message-ID: <20100823001238.849831193@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35042 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab0HWA1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:27:53 -0400
Content-Disposition: inline; filename=veth_barriers
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to order the read in ibmveth_rxq_pending_buffer and the read of
ibmveth_rxq_buffer_valid which are both cacheable memory. smp_rmb() is good
enough for this.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:29.793789816 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:30.283755038 +1000
@@ -1010,7 +1010,7 @@ static int ibmveth_poll(struct napi_stru
 		if (!ibmveth_rxq_pending_buffer(adapter))
 			break;
 
-		rmb();
+		smp_rmb();
 		if (!ibmveth_rxq_buffer_valid(adapter)) {
 			wmb(); /* suggested by larson1 */
 			adapter->rx_invalid_buffer++;


