From: akpm@osdl.org
Subject: [patch 3/3] x25_create initializing socket data twice
Date: Fri, 04 Mar 2005 04:37:19 -0800
Message-ID: <200503041237.j24Cbdbm026482@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, herbert@13thfloor.at
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Herbert Poetzl <herbert@13thfloor.at>

x25_create() [net/x25/af_x25.c] is calling sock_init_data() twice ...  once
indirectly via x25_alloc_socket() and a second time directly via
sock_init_data(sock, sk);

while this might not look as critical as it seems, it can easily break
stuff which assumes that sock_init_data() isn't called twice on the same
socket.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 /dev/null                |    0 
 25-akpm/net/x25/af_x25.c |    1 -
 2 files changed, 1 deletion(-)

diff -puN net/x25/af_x25.c~x25_create-initializing-socket-data-twice net/x25/af_x25.c
--- 25/net/x25/af_x25.c~x25_create-initializing-socket-data-twice	2005-03-02 19:22:48.000000000 -0800
+++ 25-akpm/net/x25/af_x25.c	2005-03-02 19:22:48.000000000 -0800
@@ -490,7 +490,6 @@ static int x25_create(struct socket *soc
 
 	x25 = x25_sk(sk);
 
-	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
 
 	x25_init_timers(sk);
diff -L net/x25/af_x25.c.orig -puN /dev/null /dev/null
_
