From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] irda - need to set socket owner
Date: Fri, 29 Aug 2003 11:44:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829114406.52a429bd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All protocols need to set the socket owner field to prevent
module unloading when there are still orphaned sockets.

Patch against 2.6.0-test4 (but should work on 2.4 as well).

diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	Fri Aug 29 11:21:32 2003
+++ b/net/irda/af_irda.c	Fri Aug 29 11:21:32 2003
@@ -1098,6 +1098,7 @@
 
 	/* Initialise networking socket struct */
 	sock_init_data(sock, sk);	/* Note : set sk->sk_refcnt to 1 */
+	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_family = PF_IRDA;
 	sk->sk_protocol = protocol;
 	/* Link networking socket and IrDA socket structs together */
