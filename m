From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] arp - proc_net_fops_create
Date: Thu, 11 Sep 2003 15:40:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911154054.45336bef.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use proc_net_fops_create for convience.

diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	Thu Sep 11 15:36:06 2003
+++ b/net/ipv4/arp.c	Thu Sep 11 15:36:06 2003
@@ -1416,14 +1416,8 @@
 
 static int __init arp_proc_init(void)
 {
-	int rc = 0;
-	struct proc_dir_entry *p = create_proc_entry("arp", S_IRUGO, proc_net);
-
-        if (p)
-		p->proc_fops = &arp_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	return proc_net_fops_create("arp", S_IRUGO, &arp_seq_fops) ? 0 
+		: -ENOMEM;
 }
 
 #else /* CONFIG_PROC_FS */
