From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fib_hash -- proc_net_fops_create
Date: Thu, 11 Sep 2003 15:41:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911154156.0a68843e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Once again, use proc_net_fops_create for convience

diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	Thu Sep 11 15:36:06 2003
+++ b/net/ipv4/fib_hash.c	Thu Sep 11 15:36:06 2003
@@ -1096,15 +1096,8 @@
 
 int __init fib_proc_init(void)
 {
-	struct proc_dir_entry *p;
-	int rc = 0;
-
-	p = create_proc_entry("route", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &fib_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	return proc_net_fops_create("route", S_IRUGO, &fib_seq_fops) ? 0
+		: -ENOMEM;
 }
 
 void __init fib_proc_exit(void)
