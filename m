From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (13/17) llc -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:03:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140311.66c2fa57@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, acme@conectiva.com.br
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert LLC to unsigned for send/recv msg.

diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	Mon Dec  8 16:20:07 2003
+++ b/net/llc/af_llc.c	Mon Dec  8 16:20:07 2003
@@ -671,12 +671,13 @@
  *	Returns non-negative upon success, negative otherwise.
  */
 static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int size, int flags)
+			  struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_llc *uaddr = (struct sockaddr_llc *)msg->msg_name;
 	struct sk_buff *skb;
-	int rc = -ENOMEM, copied = 0, timeout;
+	size_t copied = 0;
+	int rc = -ENOMEM, timeout;
 	int noblock = flags & MSG_DONTWAIT;
 
 	dprintk("%s: receiving in %02X from %02X\n", __FUNCTION__,
@@ -725,7 +726,7 @@
  *	Returns non-negative upon success, negative otherwise.
  */
 static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len)
+			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct llc_opt *llc = llc_sk(sk);
@@ -734,7 +735,8 @@
 	int noblock = flags & MSG_DONTWAIT;
 	struct net_device *dev;
 	struct sk_buff *skb;
-	int rc = -EINVAL, size = 0, copied = 0, hdrlen;
+	size_t size = 0;
+	int rc = -EINVAL, copied = 0, hdrlen;
 
 	dprintk("%s: sending from %02X to %02X\n", __FUNCTION__,
 		llc->laddr.lsap, llc->daddr.lsap);
