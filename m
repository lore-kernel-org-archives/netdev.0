From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (14/17) netrom -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:02:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140258.34aa7c73@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Ralf Baechle <ralf@linux-mips.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert Netrom to unsigned length for send/receive msg.

diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Mon Dec  8 16:20:10 2003
+++ b/net/netrom/af_netrom.c	Mon Dec  8 16:20:10 2003
@@ -1003,7 +1003,7 @@
 }
 
 static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, int len)
+		      struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	nr_cb *nr = nr_sk(sk);
@@ -1112,11 +1112,11 @@
 }
 
 static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, int size, int flags)
+		      struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ax25 *sax = (struct sockaddr_ax25 *)msg->msg_name;
-	int copied;
+	size_t copied;
 	struct sk_buff *skb;
 	int er;
 
