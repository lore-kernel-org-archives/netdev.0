From: =?ISO-8859-2?Q?Martin_MOKREJ=A9?= <mmokrejs@ribosome.natur.cuni.cz>
Subject: Re: [PATCH][2.4.27-pre4] tcp_input.c compile-time error
Date: Mon, 31 May 2004 10:47:46 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40BAF132.5010907@ribosome.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264578AbUEaIrw@vger.kernel.org>
To: mikpe@csd.uu.se, marcelo.tosatti@cyclades.com, davem@redhat.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch has helped to me to compile teh kernel at least. Thanks.


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
