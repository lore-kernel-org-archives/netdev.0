From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipv4 -- proc_net_fops_create
Date: Thu, 11 Sep 2003 15:43:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911154357.6b31891c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use proc_net_fops_create it is cleaner.

diff -Nru a/net/ipv4/proc.c b/net/ipv4/proc.c
--- a/net/ipv4/proc.c	Thu Sep 11 15:36:06 2003
+++ b/net/ipv4/proc.c	Thu Sep 11 15:36:06 2003
@@ -240,20 +240,12 @@
 	int rc = 0;
 	struct proc_dir_entry *p;
 
-	p = create_proc_entry("netstat", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("netstat", S_IRUGO, &netstat_seq_fops))
 		goto out_netstat;
-	p->proc_fops = &netstat_seq_fops;
-
-	p = create_proc_entry("snmp", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("snmp", S_IRUGO, &snmp_seq_fops))
 		goto out_snmp;
-	p->proc_fops = &snmp_seq_fops;
-
-	p = create_proc_entry("sockstat", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("sockstat", S_IRUGO, &sockstat_seq_fops))
 		goto out_sockstat;
-	p->proc_fops = &sockstat_seq_fops;
 out:
 	return rc;
 out_sockstat:
