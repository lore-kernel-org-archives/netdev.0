From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/17) netlink/packet -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:02:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140236.35fb993a@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert "maintance protocols" af_key, packet, netlink 
over to use unsigned length for send/receive message.

diff -Nru a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c	Mon Dec  8 16:19:58 2003
+++ b/net/key/af_key.c	Mon Dec  8 16:19:58 2003
@@ -2655,7 +2655,7 @@
 }
 
 static int pfkey_sendmsg(struct kiocb *kiocb,
-			 struct socket *sock, struct msghdr *msg, int len)
+			 struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb = NULL;
@@ -2697,7 +2697,7 @@
 }
 
 static int pfkey_recvmsg(struct kiocb *kiocb,
-			 struct socket *sock, struct msghdr *msg, int len,
+			 struct socket *sock, struct msghdr *msg, size_t len,
 			 int flags)
 {
 	struct sock *sk = sock->sk;
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Mon Dec  8 16:19:58 2003
+++ b/net/netlink/af_netlink.c	Mon Dec  8 16:19:58 2003
@@ -601,7 +601,7 @@
 }
 
 static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			   struct msghdr *msg, int len)
+			   struct msghdr *msg, size_t len)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
@@ -641,7 +641,7 @@
 	}
 
 	err = -EMSGSIZE;
-	if ((unsigned)len > sk->sk_sndbuf - 32)
+	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
 	skb = alloc_skb(len, GFP_KERNEL);
@@ -683,7 +683,7 @@
 }
 
 static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
-			   struct msghdr *msg, int len,
+			   struct msghdr *msg, size_t len,
 			   int flags)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
@@ -691,7 +691,7 @@
 	struct sock *sk = sock->sk;
 	struct netlink_opt *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
-	int copied;
+	size_t copied;
 	struct sk_buff *skb;
 	int err;
 
diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	Mon Dec  8 16:19:58 2003
+++ b/net/packet/af_packet.c	Mon Dec  8 16:19:58 2003
@@ -279,7 +279,7 @@
  */
  
 static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int len)
+			       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_pkt *saddr=(struct sockaddr_pkt *)msg->msg_name;
@@ -651,7 +651,7 @@
 
 
 static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len)
+			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ll *saddr=(struct sockaddr_ll *)msg->msg_name;
@@ -999,7 +999,7 @@
  */
 
 static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len, int flags)
+			  struct msghdr *msg, size_t len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
