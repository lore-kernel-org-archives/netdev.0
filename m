From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 5/15] spidernet: turn off descriptor chain end interrupt.
Date: Mon, 11 Jun 2007 13:29:03 -0500
Message-ID: <20070611182903.GE13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48991 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753715AbXFKS3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 14:29:06 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIT5TY013118
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:29:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIT4V2528128
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:29:04 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIT3ph006439
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:29:04 -0400
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


At some point, the transmit descriptor chain end interrupt (TXDCEINT)
was turned on. This is a mistake; and it damages small packet
transmit performance, as it results in a huge storm of interrupts.  
Turn it off.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-08 17:40:02.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-08 17:40:05.000000000 -0500
@@ -222,6 +222,7 @@ extern char spider_net_driver_name[];
 #define SPIDER_NET_GDTBSTA             0x00000300
 #define SPIDER_NET_GDTDCEIDIS          0x00000002
 #define SPIDER_NET_DMA_TX_VALUE        SPIDER_NET_TX_DMA_EN | \
+                                       SPIDER_NET_GDTDCEIDIS | \
                                        SPIDER_NET_GDTBSTA
 
 #define SPIDER_NET_DMA_TX_FEND_VALUE	0x00030003
@@ -332,8 +333,7 @@ enum spider_net_int2_status {
 	SPIDER_NET_GRISPDNGINT
 };
 
-#define SPIDER_NET_TXINT	( (1 << SPIDER_NET_GDTFDCINT) | \
-                             (1 << SPIDER_NET_GDTDCEINT) )
+#define SPIDER_NET_TXINT	(1 << SPIDER_NET_GDTFDCINT)
 
 /* We rely on flagged descriptor interrupts */
 #define SPIDER_NET_RXINT	( (1 << SPIDER_NET_GDAFDCINT) )
