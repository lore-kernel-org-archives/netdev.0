From: Matthew J Galgoci <mgalgoci@parcelfarce.linux.theplanet.co.uk>
Subject: 2.6.10-bk4 ip_conntrack oops fix
Date: Sun, 2 Jan 2005 06:12:38 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0501020611430.12403@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I stumbled onto an annoying oops in 2.6.10-bk4.

Here is how to cause the oops.

load ip_conntrack
remove ip_conntrack
ls /proc/net/stat
boom

Here is what I think the fix is:


--- linux-2.6.10-bk4/net/ipv4/netfilter/ip_conntrack_standalone.c.orig	2005-01-01 23:44:42.000000000 -0500
+++ linux-2.6.10-bk4/net/ipv4/netfilter/ip_conntrack_standalone.c	2005-01-02 00:57:20.000000000 -0500
@@ -820,7 +820,7 @@
 	nf_unregister_hook(&ip_conntrack_defrag_ops);
  cleanup_proc_stat:
 #ifdef CONFIG_PROC_FS
-	proc_net_remove("ip_conntrack_stat");
+	remove_proc_entry("ip_conntrack", proc_net_stat);
 cleanup_proc_exp:
 	proc_net_remove("ip_conntrack_expect");
  cleanup_proc:
