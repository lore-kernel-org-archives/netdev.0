From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH] cxgb3: Wait longer for control packets on initialization
Date: Mon, 26 Apr 2010 12:38:27 -0300
Message-ID: <201004261238.27919.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:38745 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab0DZPiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 11:38:50 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3QFWc7M031645
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 09:32:38 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3QFcU4W111154
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 09:38:34 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3QFfDrd010265
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 09:41:14 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In some Power7 platforms, when using VIOS (Virtual I/O Server), we
need to wait longer for control packets to finish transfer during
initialization.
Without this change, initialization may fail prematurely.

Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

Index: linux-2.6.34-rc5/drivers/net/cxgb3/cxgb3_main.c
===================================================================
--- linux-2.6.34-rc5.orig/drivers/net/cxgb3/cxgb3_main.c	2010-04-23 18:59:43.000000000 -0300
+++ linux-2.6.34-rc5/drivers/net/cxgb3/cxgb3_main.c	2010-04-23 18:59:55.000000000 -0300
@@ -439,7 +439,7 @@ static void free_irq_resources(struct ad
 static int await_mgmt_replies(struct adapter *adap, unsigned long init_cnt,
 			      unsigned long n)
 {
-	int attempts = 5;
+	int attempts = 10;

 	while (adap->sge.qs[0].rspq.offload_pkts < init_cnt + n) {
 		if (!--attempts)
