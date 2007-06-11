From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 14/15] spidernet: fix misnamed flag
Date: Mon, 11 Jun 2007 14:09:16 -0500
Message-ID: <20070611190916.GN13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:47455 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904AbXFKTJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 15:09:31 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5BJ4pKM001593
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 15:04:51 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BJ9HB3262914
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 13:09:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BJ9GEC016110
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 13:09:17 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 11:53:27.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 11:53:29.000000000 -0500
@@ -716,7 +716,7 @@ spider_net_prepare_tx_descr(struct spide
 	hwdescr->data_status = 0;
 
 	hwdescr->dmac_cmd_status =
-			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
+			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_TXFRMTL;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-11 11:53:26.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-11 11:53:29.000000000 -0500
@@ -354,7 +354,7 @@ enum spider_net_int2_status {
 #define SPIDER_NET_GPRDAT_MASK			0x0000ffff
 
 #define SPIDER_NET_DMAC_NOINTR_COMPLETE		0x00800000
-#define SPIDER_NET_DMAC_NOCS			0x00040000
+#define SPIDER_NET_DMAC_TXFRMTL		0x00040000
 #define SPIDER_NET_DMAC_TCP			0x00020000
 #define SPIDER_NET_DMAC_UDP			0x00030000
 #define SPIDER_NET_TXDCEST			0x08000000
