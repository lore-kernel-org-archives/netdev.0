From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] net: fix kfifo_alloc() error check
Date: Thu, 23 Nov 2006 03:33:35 +0900
Message-ID: <20061122183335.GA2985@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:7801 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1756368AbWKVSjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 13:39:35 -0500
Received: by ug-out-1314.google.com with SMTP id 44so255268uga
        for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 10:39:29 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of kfifo_alloc() should be checked by IS_ERR().

Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 net/dccp/probe.c     |    2 ++
 net/ipv4/tcp_probe.c |    2 ++
 2 files changed, 4 insertions(+)

Index: work-fault-inject/net/ipv4/tcp_probe.c
===================================================================
--- work-fault-inject.orig/net/ipv4/tcp_probe.c
+++ work-fault-inject/net/ipv4/tcp_probe.c
@@ -156,6 +156,8 @@ static __init int tcpprobe_init(void)
 	init_waitqueue_head(&tcpw.wait);
 	spin_lock_init(&tcpw.lock);
 	tcpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &tcpw.lock);
+	if (IS_ERR(tcpw.fifo))
+		return PTR_ERR(tcpw.fifo);
 
 	if (!proc_net_fops_create(procname, S_IRUSR, &tcpprobe_fops))
 		goto err0;
Index: work-fault-inject/net/dccp/probe.c
===================================================================
--- work-fault-inject.orig/net/dccp/probe.c
+++ work-fault-inject/net/dccp/probe.c
@@ -160,6 +160,8 @@ static __init int dccpprobe_init(void)
 	init_waitqueue_head(&dccpw.wait);
 	spin_lock_init(&dccpw.lock);
 	dccpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &dccpw.lock);
+	if (IS_ERR(dccpw.fifo))
+		return PTR_ERR(dccpw.fifo);
 
 	if (!proc_net_fops_create(procname, S_IRUSR, &dccpprobe_fops))
 		goto err0;
