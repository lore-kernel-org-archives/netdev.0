From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) llc - need to set owner on created sockets.
Date: Fri, 29 Aug 2003 10:48:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829104857.027a8c6f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

LLC needs to set owner field on sockets it creates, otherwise
it is possible to remove module with detached sockets still
outstanding.

diff -Nru a/net/llc/llc_main.c b/net/llc/llc_main.c
--- a/net/llc/llc_main.c	Fri Aug 29 09:27:28 2003
+++ b/net/llc/llc_main.c	Fri Aug 29 09:27:28 2003
@@ -229,6 +229,7 @@
 	if (llc_sk_init(sk))
 		goto outsk;
 	sock_init_data(NULL, sk);
+	sk_set_owner(sk, THIS_MODULE);
 #ifdef LLC_REFCNT_DEBUG
 	atomic_inc(&llc_sock_nr);
 	printk(KERN_DEBUG "LLC socket %p created in %s, now we have %d alive\n", sk,
