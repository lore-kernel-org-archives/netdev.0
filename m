From: Mikael Pettersson <mikpe@csd.uu.se>
Subject: [PATCH][2.4.27-pre4] tcp_input.c compile-time error
Date: Sun, 30 May 2004 23:54:50 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405302154.i4ULso3l014496@harpo.it.uu.se>
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: marcelo.tosatti@cyclades.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

net/ipv4/tcp_input.c in 2.4.27-pre4 fails to compile:

tcp_input.c: In function `tcp_rcv_space_adjust':
tcp_input.c:479: error: structure has no member named `sk_rcvbuf'
tcp_input.c:480: error: structure has no member named `sk_rcvbuf'
make[3]: *** [tcp_input.o] Error 1

The patch below appears to fix this problem, although some netdev
person should probably check it.

/Mikael

diff -ruN linux-2.4.27-pre4/net/ipv4/tcp_input.c linux-2.4.27-pre4.tcp_input-fix/net/ipv4/tcp_input.c
--- linux-2.4.27-pre4/net/ipv4/tcp_input.c	2004-05-30 23:18:16.000000000 +0200
+++ linux-2.4.27-pre4.tcp_input-fix/net/ipv4/tcp_input.c	2004-05-30 23:45:52.000000000 +0200
@@ -476,8 +476,8 @@
 				  16 + sizeof(struct sk_buff));
 			space *= rcvmem;
 			space = min(space, sysctl_tcp_rmem[2]);
-			if (space > sk->sk_rcvbuf)
-				sk->sk_rcvbuf = space;
+			if (space > sk->rcvbuf)
+				sk->rcvbuf = space;
 		}
 	}
 	
