From: akpm@osdl.org
Subject: [patch 11/13] net/socket.c::__sock_create() cleanup.
Date: Sun, 21 Nov 2004 22:43:57 -0800
Message-ID: <200411220644.iAM6i9900678@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        lcapitulino@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "Luiz Fernando N. Capitulino" <lcapitulino@conectiva.com.br>

The 'i' variable in net/socket.c::__sock_create() is not necessary.  It's
have been used to store error codes but there is an 'err' variable already.

Signed-off-by: Luiz Capitulino <lcapitulino@conectiva.com.br>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/socket.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff -puN net/socket.c~net-socketc__sock_create-cleanup net/socket.c
--- 25/net/socket.c~net-socketc__sock_create-cleanup	2004-11-21 22:42:53.756510008 -0800
+++ 25-akpm/net/socket.c	2004-11-21 22:42:53.762509096 -0800
@@ -1073,7 +1073,6 @@ int sock_wake_async(struct socket *sock,
 
 static int __sock_create(int family, int type, int protocol, struct socket **res, int kern)
 {
-	int i;
 	int err;
 	struct socket *sock;
 
@@ -1118,7 +1117,7 @@ static int __sock_create(int family, int
 
 	net_family_read_lock();
 	if (net_families[family] == NULL) {
-		i = -EAFNOSUPPORT;
+		err = -EAFNOSUPPORT;
 		goto out;
 	}
 
@@ -1128,10 +1127,9 @@ static int __sock_create(int family, int
  *	default.
  */
 
-	if (!(sock = sock_alloc())) 
-	{
+	if (!(sock = sock_alloc())) {
 		printk(KERN_WARNING "socket: no more sockets\n");
-		i = -ENFILE;		/* Not exactly a match, but its the
+		err = -ENFILE;		/* Not exactly a match, but its the
 					   closest posix thing */
 		goto out;
 	}
@@ -1142,11 +1140,11 @@ static int __sock_create(int family, int
 	 * We will call the ->create function, that possibly is in a loadable
 	 * module, so we have to bump that loadable module refcnt first.
 	 */
-	i = -EAFNOSUPPORT;
+	err = -EAFNOSUPPORT;
 	if (!try_module_get(net_families[family]->owner))
 		goto out_release;
 
-	if ((i = net_families[family]->create(sock, protocol)) < 0)
+	if ((err = net_families[family]->create(sock, protocol)) < 0)
 		goto out_module_put;
 	/*
 	 * Now to bump the refcnt of the [loadable] module that owns this
@@ -1166,7 +1164,7 @@ static int __sock_create(int family, int
 
 out:
 	net_family_read_unlock();
-	return i;
+	return err;
 out_module_put:
 	module_put(net_families[family]->owner);
 out_release:
_
