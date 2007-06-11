From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 12/15] spidernet: increase the NAPI weight
Date: Mon, 11 Jun 2007 14:02:36 -0500
Message-ID: <20070611190236.GL13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:58244 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755084AbXFKTCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 15:02:38 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BJ3hRu010472
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 15:03:43 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BJ2brP478882
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 15:02:37 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BJ2bwR021894
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 15:02:37 -0400
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Another way of minimizing the likelyhood of RX ram from overflowing
is to empty out the entire rx ring every chance we get. Change
the crazy watchdog timeout from 50 seconds to 3 seconds, while
we're here.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.h |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-11 11:50:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-11 11:53:26.000000000 -0500
@@ -56,8 +56,13 @@ extern char spider_net_driver_name[];
 
 #define SPIDER_NET_RX_CSUM_DEFAULT		1
 
-#define SPIDER_NET_WATCHDOG_TIMEOUT		50*HZ
-#define SPIDER_NET_NAPI_WEIGHT			64
+#define SPIDER_NET_WATCHDOG_TIMEOUT		3*HZ
+
+/* We really really want to empty the ring buffer every time,
+ * so as to avoid the RX ram full bug. So set te napi wieght
+ * to the ring size.
+ */
+#define SPIDER_NET_NAPI_WEIGHT	SPIDER_NET_RX_DESCRIPTORS_DEFAULT
 
 #define SPIDER_NET_FIRMWARE_SEQS	6
 #define SPIDER_NET_FIRMWARE_SEQWORDS	1024
