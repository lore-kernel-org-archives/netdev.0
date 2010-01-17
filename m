From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipv4: don't remove /proc/net/rt_acct
Date: Sun, 17 Jan 2010 15:32:50 +0200
Message-ID: <20100117133250.GA6178@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:34434 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab0AQNdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 08:33:13 -0500
Received: by fxm25 with SMTP id 25so335838fxm.21
        for <netdev@vger.kernel.org>; Sun, 17 Jan 2010 05:33:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/rt_acct is not created if NET_CLS_ROUTE=n.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/route.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -586,7 +586,9 @@ static void __net_exit ip_rt_do_proc_exit(struct net *net)
 {
 	remove_proc_entry("rt_cache", net->proc_net_stat);
 	remove_proc_entry("rt_cache", net->proc_net);
+#ifdef CONFIG_NET_CLS_ROUTE
 	remove_proc_entry("rt_acct", net->proc_net);
+#endif
 }
 
 static struct pernet_operations ip_rt_proc_ops __net_initdata =  {
