From: Johann Felix Soden <johfel@gmx.de>
Subject: [PATCH] [IPV4]: Fix compiler error with CONFIG_PROC_FS=n
Date: Tue, 05 Feb 2008 19:43:54 +0100
Message-ID: <1202237034.9289.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:41128 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755247AbYBESoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 13:44:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Felix Soden <johfel@users.sourceforge.net>

Handle CONFIG_PROC_FS=n in net/ipv4/fib_frontend.c because:

net/ipv4/fib_frontend.c: In function 'fib_net_init':
net/ipv4/fib_frontend.c:1032: error: implicit declaration of function 'fib_proc_init'
net/ipv4/fib_frontend.c: In function 'fib_net_exit':
net/ipv4/fib_frontend.c:1047: error: implicit declaration of function 'fib_proc_exit'

Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>
---
 net/ipv4/fib_frontend.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 86ff271..581d588 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1029,9 +1029,12 @@ static int __net_init fib_net_init(struct net *net)
 	error = nl_fib_lookup_init(net);
 	if (error < 0)
 		goto out_nlfl;
+#ifdef CONFIG_PROC_FS
 	error = fib_proc_init(net);
 	if (error < 0)
 		goto out_proc;
+#endif
+
 out:
 	return error;
 
@@ -1044,7 +1047,9 @@ out_nlfl:
 
 static void __net_exit fib_net_exit(struct net *net)
 {
+#ifdef CONFIG_PROC_FS
 	fib_proc_exit(net);
+#endif
 	nl_fib_lookup_exit(net);
 	ip_fib_net_exit(net);
 }
-- 
1.5.4



