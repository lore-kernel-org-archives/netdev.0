From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (16/17) af_unix -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:01:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140116.639569b6@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert Unix domain to handle unsigned for length in send/recv msg.

diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	Mon Dec  8 16:20:16 2003
+++ b/net/unix/af_unix.c	Mon Dec  8 16:20:16 2003
@@ -1176,7 +1176,7 @@
  */
 
 static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			      struct msghdr *msg, int len)
+			      struct msghdr *msg, size_t len)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
@@ -1217,7 +1217,7 @@
 		goto out;
 
 	err = -EMSGSIZE;
-	if ((unsigned)len > sk->sk_sndbuf - 32)
+	if (len > sk->sk_sndbuf - 32)
 		goto out;
 
 	skb = sock_alloc_send_skb(sk, len, msg->msg_flags&MSG_DONTWAIT, &err);
@@ -1324,7 +1324,7 @@
 
 		
 static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, int len)
+			       struct msghdr *msg, size_t len)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
@@ -1447,7 +1447,7 @@
 }
 
 static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int size,
+			      struct msghdr *msg, size_t size,
 			      int flags)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
@@ -1555,7 +1555,7 @@
 
 
 static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int size,
+			       struct msghdr *msg, size_t size,
 			       int flags)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
