From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipx - set socket owner field
Date: Fri, 29 Aug 2003 11:37:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829113704.548a9af4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All sockets created by a protocol need to have owner field set
to prevent problems with orphaned sockets during module unload.

Patch for 2.6.0-test4

diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	Fri Aug 29 11:20:48 2003
+++ b/net/ipx/af_ipx.c	Fri Aug 29 11:20:48 2003
@@ -1365,6 +1365,7 @@
 			atomic_read(&ipx_sock_nr));
 #endif
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_no_check = 1;		/* Checksum off by default */
 	rc = 0;
 out:
