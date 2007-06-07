From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 16/18] spidernet: fix misnamed flag
Date: Thu, 7 Jun 2007 14:57:48 -0500
Message-ID: <20070607195748.GP16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:60175 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbXFGT5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:57:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JvnSj010541
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:57:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JvnHF239252
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:57:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57Jvm3o016434
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:57:48 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The transmit frame tail bit is stranglely misnamed as 
"no checksum". Fix the name to what it should be:
"transmit frame tail". No functional change, 
just a name change.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    2 +-
 drivers/net/spider_net.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:56:23.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:56:31.000000000 -0500
@@ -720,7 +720,7 @@ spider_net_prepare_tx_descr(struct spide
 	hwdescr->data_status = 0;
 
 	hwdescr->dmac_cmd_status =
-			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
+			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_TXFRMTL;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-07 11:55:06.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-07 11:56:31.000000000 -0500
@@ -354,7 +354,7 @@ enum spider_net_int2_status {
 #define SPIDER_NET_GPRDAT_MASK			0x0000ffff
 
 #define SPIDER_NET_DMAC_NOINTR_COMPLETE		0x00800000
-#define SPIDER_NET_DMAC_NOCS			0x00040000
+#define SPIDER_NET_DMAC_TXFRMTL		0x00040000
 #define SPIDER_NET_DMAC_TCP			0x00020000
 #define SPIDER_NET_DMAC_UDP			0x00030000
 #define SPIDER_NET_TXDCEST			0x08000000
