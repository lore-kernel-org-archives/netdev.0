From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (17/17) x25 -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:02:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140208.7dd9a0fe@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert X.25 to handle unsigned for len in send/receive msg.

diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	Mon Dec  8 16:20:19 2003
+++ b/net/x25/af_x25.c	Mon Dec  8 16:20:19 2003
@@ -910,7 +910,7 @@
 }
 
 static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, int len)
+		       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct x25_opt *x25 = x25_sk(sk);
@@ -919,7 +919,8 @@
 	struct sk_buff *skb;
 	unsigned char *asmptr;
 	int noblock = msg->msg_flags & MSG_DONTWAIT;
-	int size, qbit = 0, rc = -EINVAL;
+	size_t size;
+	int qbit = 0, rc = -EINVAL;
 
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_OOB | MSG_EOR))
 		goto out;
@@ -1085,13 +1086,14 @@
 
 
 static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, int size,
+		       struct msghdr *msg, size_t size,
 		       int flags)
 {
 	struct sock *sk = sock->sk;
 	struct x25_opt *x25 = x25_sk(sk);
 	struct sockaddr_x25 *sx25 = (struct sockaddr_x25 *)msg->msg_name;
-	int copied, qbit;
+	size_t copied;
+	int qbit;
 	struct sk_buff *skb;
 	unsigned char *asmptr;
 	int rc = -ENOTCONN;
