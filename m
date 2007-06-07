From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 17/18] spidernet: turn off descriptor chain end interrupt.
Date: Thu, 7 Jun 2007 15:01:52 -0500
Message-ID: <20070607200152.GQ16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Nathan J Lee <njlee@us.ibm.com>,
	Ling Shao <shaol@cn.ibm.com>,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Zhen Bo Zhu <zhuzb@cn.ibm.com>, Zhu Han <hanzhu@cn.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Yan Qi Wang <yqwang@cn.ibm.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:50807 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933246AbXFGUBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 16:01:54 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57K2wfP028975
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:02:58 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57K1rpj493316
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:01:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57K1qr1006984
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:01:53 -0400
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-07 11:56:31.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-07 11:56:36.000000000 -0500
@@ -227,6 +227,7 @@ extern char spider_net_driver_name[];
 #define SPIDER_NET_GDTBSTA             0x00000300
 #define SPIDER_NET_GDTDCEIDIS          0x00000002
 #define SPIDER_NET_DMA_TX_VALUE        SPIDER_NET_TX_DMA_EN | \
+                                       SPIDER_NET_GDTDCEIDIS | \
                                        SPIDER_NET_GDTBSTA
 
 #define SPIDER_NET_DMA_TX_FEND_VALUE	0x00030003
@@ -337,8 +338,7 @@ enum spider_net_int2_status {
 	SPIDER_NET_GRISPDNGINT
 };
 
-#define SPIDER_NET_TXINT	( (1 << SPIDER_NET_GDTFDCINT) | \
-                             (1 << SPIDER_NET_GDTDCEINT) )
+#define SPIDER_NET_TXINT	(1 << SPIDER_NET_GDTFDCINT)
 
 /* We rely on flagged descriptor interrupts */
 #define SPIDER_NET_RXINT	( (1 << SPIDER_NET_GDAFDCINT) )
