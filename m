From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/13) appletalk - ddp set socket owner
Date: Fri, 29 Aug 2003 13:55:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829135555.31d277a0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

DDP needs to set the socket owner, without this it is possible
to OOPS.  What happens is a socket is closed, but data is outstanding
so it is orphaned to be cleaned up later.  Then if appletalk module
is unloaded, the timer code ends up referencing dead memory.

By setting the owner field, the module can't be unloaded.

Path applies to 2.6.0-test4.

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 11:02:16 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 11:02:16 2003
@@ -983,6 +983,8 @@
 	rc = 0;
 	sock->ops = &atalk_dgram_ops;
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
+
 	/* Checksums on by default */
 	sk->sk_zapped = 1;
 out:
