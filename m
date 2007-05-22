From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 10/10] spidernet: increase the NAPI weight
Date: Tue, 22 May 2007 18:52:37 -0500
Message-ID: <20070522235237.GI2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:49730 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757186AbXEVXwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 19:52:39 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MNre0W026860
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:53:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNqdmm551836
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:52:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNqcSW008232
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:52:39 -0400
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
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

Index: netdev-2.6/drivers/net/spider_net.h
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.h	2007-05-22 18:03:24.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.h	2007-05-22 18:03:43.000000000 -0500
@@ -56,8 +56,13 @@ extern char spider_net_driver_name[];
 
 #define SPIDER_NET_RX_CSUM_DEFAULT		1
 
-#define SPIDER_NET_WATCHDOG_TIMEOUT		50*HZ
-#define SPIDER_NET_NAPI_WEIGHT			64
+#define SPIDER_NET_WATCHDOG_TIMEOUT		3*HZ
+
+/* We really really want to empty the ring buffer every time,
+ * so as to avoid the RX ram full bug. So set the napi weight
+ * to the ring size.
+ */
+#define SPIDER_NET_NAPI_WEIGHT			SPIDER_NET_RX_DESCRIPTORS_DEFAULT
 
 #define SPIDER_NET_FIRMWARE_SEQS	6
 #define SPIDER_NET_FIRMWARE_SEQWORDS	1024
