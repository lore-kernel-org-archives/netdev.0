From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/17) decnet -- size_t in sned/recvmsg
Date: Fri, 9 Jan 2004 14:03:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140336.45c393c5@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Steven Whitehouse <SteveW@ACM.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 Send/recv msg now take an unsigned total message length.

diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	Mon Dec  8 16:19:55 2003
+++ b/net/decnet/af_decnet.c	Mon Dec  8 16:19:55 2003
@@ -1659,13 +1659,13 @@
 
 
 static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int size, int flags)
+	struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
 	struct sk_buff_head *queue = &sk->sk_receive_queue;
-	int target = size > 1 ? 1 : 0;
-	int copied = 0;
+	size_t target = size > 1 ? 1 : 0;
+	size_t copied = 0;
 	int rv = 0;
 	struct sk_buff *skb, *nskb;
 	struct dn_skb_cb *cb = NULL;
@@ -1746,7 +1746,7 @@
 	}
 
 	for(skb = queue->next; skb != (struct sk_buff *)queue; skb = nskb) {
-		int chunk = skb->len;
+		unsigned int chunk = skb->len;
 		cb = DN_SKB_CB(skb);
 
 		if ((chunk + copied) > size)
@@ -1888,20 +1888,20 @@
 }
 
 static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
-	   struct msghdr *msg, int size)
+	   struct msghdr *msg, size_t size)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
-	int mss;
+	size_t mss;
 	struct sk_buff_head *queue = &scp->data_xmit_queue;
 	int flags = msg->msg_flags;
 	int err = 0;
-	int sent = 0;
+	size_t sent = 0;
 	int addr_len = msg->msg_namelen;
 	struct sockaddr_dn *addr = (struct sockaddr_dn *)msg->msg_name;
 	struct sk_buff *skb = NULL;
 	struct dn_skb_cb *cb;
-	int len;
+	size_t len;
 	unsigned char fctype;
 	long timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
 
