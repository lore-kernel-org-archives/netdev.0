From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/11) netrom - shorten destroy timeout
Date: Wed, 13 Aug 2003 15:39:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813153920.68d52970.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Jeroen Vreeken <pe1rxq@amsat.org>

Expire sockets faster on close

diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 11:58:31 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 11:58:31 2003
@@ -269,7 +269,7 @@
 	    atomic_read(&sk->sk_rmem_alloc)) {
 		/* Defer: outstanding buffers */
 		init_timer(&sk->sk_timer);
-		sk->sk_timer.expires  = jiffies + 10 * HZ;
+		sk->sk_timer.expires  = jiffies + 2 * HZ;
 		sk->sk_timer.function = nr_destroy_timer;
 		sk->sk_timer.data     = (unsigned long)sk;
 		add_timer(&sk->sk_timer);
