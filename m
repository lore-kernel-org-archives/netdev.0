From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] wandev_show single_open confusion
Date: Thu, 19 Feb 2004 11:27:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219112705.05416945@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Arnaldo Carvalho de Melo
 <acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix single_open interface confusion in wanrouter.  The argument passed
to single_open gets passed through via seq->private; not the void * argument
as assumed by this code.

diff -Nru a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
--- a/net/wanrouter/wanproc.c	Thu Feb 19 11:24:49 2004
+++ b/net/wanrouter/wanproc.c	Thu Feb 19 11:24:49 2004
@@ -207,7 +207,7 @@
 
 static int wandev_show(struct seq_file *m, void *v)
 {
-	struct wan_device *wandev = v;
+	struct wan_device *wandev = m->private;
 
 	if (wandev->magic != ROUTER_MAGIC)
 		return 0;
