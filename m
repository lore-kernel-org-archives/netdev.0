From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] use local_softirq_pending instead of softirq_pending in netif_rx_ni
Date: Sun, 14 Nov 2004 11:38:46 +0100
Message-ID: <20041114103846.GA32024@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Some architectures can optimize local_softirq_pending much better than
softirq_pending(smp_processor_id()), and for all others the former is
just a macro expanding to the later.

Also this is the last use of softirq_pending() in common code, once this
is in we can soon kill the notation of beeing able to query other cpus
softirq pending count.


--- 1.174/net/core/dev.c	2004-11-10 01:12:00 +01:00
+++ edited/net/core/dev.c	2004-11-14 11:35:19 +01:00
@@ -1470,7 +1470,7 @@ int netif_rx_ni(struct sk_buff *skb)
 
 	preempt_disable();
 	err = netif_rx(skb);
-	if (softirq_pending(smp_processor_id()))
+	if (local_softirq_pending())
 		do_softirq();
 	preempt_enable();
 
