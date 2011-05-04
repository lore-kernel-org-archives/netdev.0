From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/4] [RFC] netdevice: Introduce per-txq xmit_restart
Date: Wed, 04 May 2011 19:33:09 +0530
Message-ID: <20110504140309.14817.61411.sendpatchset@krkumar2.in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:33317 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438Ab1EDODN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 10:03:13 -0400
In-Reply-To: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a per-txq field that can (optionally) be set by participating
drivers to indicate when to restart tx.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    1 +
 1 file changed, 1 insertion(+)

diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2011-05-04 18:57:06.000000000 +0530
+++ new/include/linux/netdevice.h	2011-05-04 18:57:09.000000000 +0530
@@ -571,6 +571,7 @@ struct netdev_queue {
 	 * please use this field instead of dev->trans_start
 	 */
 	unsigned long		trans_start;
+	unsigned long		xmit_restart_jiffies; /* jiffies to restart */
 } ____cacheline_aligned_in_smp;
 
 static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
