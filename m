From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipv4/raw -- proc_net_fops_create
Date: Thu, 11 Sep 2003 15:44:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911154440.54468595.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	Thu Sep 11 15:36:06 2003
+++ b/net/ipv4/raw.c	Thu Sep 11 15:36:06 2003
@@ -831,15 +831,7 @@
 
 int __init raw_proc_init(void)
 {
-	struct proc_dir_entry *p;
-	int rc = 0;
-
-	p = create_proc_entry("raw", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &raw_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	return proc_net_fops_create("raw", S_IRUGO, &raw_seq_fops) ? 0 : -ENOMEM;
 }
 
 void __init raw_proc_exit(void)
