From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 11/18] spidernet: increase the NAPI weight
Date: Thu, 7 Jun 2007 14:43:31 -0500
Message-ID: <20070607194331.GK16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45164 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbXFGTnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:43:35 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JhX13028786
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:43:33 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JhWaZ261280
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:43:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JhVUU014004
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:43:32 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-07 11:51:47.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-07 11:52:22.000000000 -0500
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
