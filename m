From: akpm@osdl.org
Subject: [patch 4/9] X.25: Stop x25_destroy_socket timer looping
Date: Thu, 28 Oct 2004 00:19:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Lf907993@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andrew Hendry <ahendry@tusc.com.au>

The sk_timer.data for the x.25 destroy_socket timer went missing at some
stage, causing a timer loop where x25_destroy_socket would keep setting up
timers to call itself.  This patch puts the sk_timer.data back.

Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/x25/af_x25.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN net/x25/af_x25.c~x25-stop-x25_destroy_socket-timer-looping net/x25/af_x25.c
--- 25/net/x25/af_x25.c~x25-stop-x25_destroy_socket-timer-looping	2004-10-28 00:17:07.879606104 -0700
+++ 25-akpm/net/x25/af_x25.c	2004-10-28 00:17:07.883605496 -0700
@@ -347,6 +347,7 @@ void x25_destroy_socket(struct sock *sk)
 		/* Defer: outstanding buffers */
 		sk->sk_timer.expires  = jiffies + 10 * HZ;
 		sk->sk_timer.function = x25_destroy_timer;
+		sk->sk_timer.data = (unsigned long)sk;
 		add_timer(&sk->sk_timer);
 	} else {
 		/* drop last reference so sock_put will free */
_
