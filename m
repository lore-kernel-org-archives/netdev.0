From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] econet - set socket owner field
Date: Fri, 29 Aug 2003 11:18:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829111855.1425b7aa.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All sockets created by a protocol need to have owner field set
to prevent problems with orphaned sockets during module unload.

diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Fri Aug 29 11:15:12 2003
+++ b/net/econet/af_econet.c	Fri Aug 29 11:15:12 2003
@@ -562,6 +562,7 @@
 	sk->sk_reuse = 1;
 	sock->ops = &econet_ops;
 	sock_init_data(sock,sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	eo = ec_sk(sk) = kmalloc(sizeof(*eo), GFP_KERNEL);
 	if (!eo)
