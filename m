From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] set owner on /proc/net/rt6_stats
Date: Fri, 15 Aug 2003 11:01:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815110107.3ea9b4dc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix up initialization of IPV6 /proc/net/rt6_stats entries so owner field is set.
Use proc_net_fops_create helper instead of proc_net_create and fops assignment.

diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	Fri Aug 15 10:57:55 2003
+++ b/net/ipv6/route.c	Fri Aug 15 10:57:55 2003
@@ -1983,10 +1983,11 @@
 						     NULL, NULL);
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
-	proc_net_create("ipv6_route", 0, rt6_proc_info);
-	p = create_proc_entry("rt6_stats", S_IRUGO, proc_net);
+	p = proc_net_create("ipv6_route", 0, rt6_proc_info);
 	if (p)
-		p->proc_fops = &rt6_stats_seq_fops;
+		p->owner = THIS_MODULE;
+
+	proc_net_fops_create("rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif
 #ifdef CONFIG_XFRM
 	xfrm6_init();
