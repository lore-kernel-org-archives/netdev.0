From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] set socket owner (ax25, rose, netrom)
Date: Fri, 29 Aug 2003 11:42:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829114208.40f10cca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

AX25, NETROM, ROSE all need to set the socket owner field, otherwise it is possible
to remove the module when there are orphaned sockets.

Patch against 2.6.0-test4

diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	Fri Aug 29 11:23:32 2003
+++ b/net/x25/af_x25.c	Fri Aug 29 11:23:32 2003
@@ -449,6 +449,7 @@
 	x25->sk = sk;
 
 	sock_init_data(NULL, sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	skb_queue_head_init(&x25->ack_queue);
 	skb_queue_head_init(&x25->fragment_queue);
@@ -478,6 +479,7 @@
 	x25 = x25_sk(sk);
 
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	init_timer(&x25->timer);
 
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Fri Aug 29 11:22:10 2003
+++ b/net/rose/af_rose.c	Fri Aug 29 11:22:10 2003
@@ -518,6 +518,7 @@
 	rose = rose_sk(sk);
 
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	skb_queue_head_init(&rose->ack_queue);
 #ifdef M_BIT
@@ -556,6 +557,7 @@
 	rose = rose_sk(sk);
 
 	sock_init_data(NULL, sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	skb_queue_head_init(&rose->ack_queue);
 #ifdef M_BIT
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Fri Aug 29 11:22:49 2003
+++ b/net/netrom/af_netrom.c	Fri Aug 29 11:22:49 2003
@@ -433,6 +433,7 @@
 	nr = nr_sk(sk);
 
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	sock->ops    = &nr_proto_ops;
 	sk->sk_protocol = protocol;
@@ -473,6 +474,7 @@
 	nr = nr_sk(sk);
 
 	sock_init_data(NULL, sk);
+	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_type     = osk->sk_type;
 	sk->sk_socket   = osk->sk_socket;
