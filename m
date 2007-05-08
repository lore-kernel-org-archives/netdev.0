From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] core: Call net_tx_action only if work pending
Date: Tue, 08 May 2007 13:01:30 +0530
Message-ID: <20070508073130.17546.91346.sendpatchset@localhost.localdomain>
Cc: krkumar2@in.ibm.com, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:64582 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934451AbXEHHcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 03:32:01 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l487pXfa047022
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:51:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l487ZPlr167296
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:35:25 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l487Vq7p010334
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:31:53 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Optimize call to net_tx_action only if work is pending.

Patch against net-2.6.22.git

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2007-04-09 12:43:15.000000000 +0530
+++ new/net/core/dev.c	2007-04-09 12:43:42.000000000 +0530
@@ -3474,7 +3474,8 @@ static int dev_cpu_callback(struct notif
 	*list_net = oldsd->output_queue;
 	oldsd->output_queue = NULL;
 
-	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+	if (sd->completion_queue || sd->output_queue)
+		raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
