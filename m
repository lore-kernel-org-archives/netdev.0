From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) llc - set owner on /proc/net/llc directory
Date: Fri, 29 Aug 2003 10:51:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829105140.72c5fad3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Owner field on /proc/net/llc directory needs to be set,
otherwise badness if some application has directory open while
module being unloaded. 

diff -Nru a/net/llc/llc_proc.c b/net/llc/llc_proc.c
--- a/net/llc/llc_proc.c	Fri Aug 29 09:27:45 2003
+++ b/net/llc/llc_proc.c	Fri Aug 29 09:27:45 2003
@@ -245,6 +245,7 @@
 	llc_proc_dir = proc_mkdir("llc", proc_net);
 	if (!llc_proc_dir)
 		goto out;
+	llc_proc_dir->owner = THIS_MODULE;
 
 	p = create_proc_entry("socket", S_IRUGO, llc_proc_dir);
 	if (!p)
