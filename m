From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/17) irda -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:03:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140317.0a8a30a8@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Jean Tourrilhes
 <jt@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert IRDA to unsigned length for send/recv msg.

diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	Mon Dec  8 16:20:04 2003
+++ b/net/irda/af_irda.c	Mon Dec  8 16:20:04 2003
@@ -1257,7 +1257,7 @@
  *    fragment the message if necessary
  */
 static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, int len)
+			struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1329,12 +1329,13 @@
  *    after being read, regardless of how much the user actually read
  */
 static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int size, int flags)
+			      struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
 	struct sk_buff *skb;
-	int copied, err;
+	size_t copied;
+	int err;
 
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
@@ -1379,12 +1380,12 @@
  * Function irda_recvmsg_stream (iocb, sock, msg, size, flags)
  */
 static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int size, int flags)
+			       struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
 	int noblock = flags & MSG_DONTWAIT;
-	int copied = 0;
+	size_t copied = 0;
 	int target = 1;
 	DECLARE_WAITQUEUE(waitq, current);
 
@@ -1505,7 +1506,7 @@
  *
  */
 static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int len)
+			      struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1571,7 +1572,7 @@
  */
 #ifdef CONFIG_IRDA_ULTRA
 static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int len)
+			      struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
