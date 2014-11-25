From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 12/17] tipc_sendmsg(): pass msghdr instead of its ->msg_iov
Date: Tue, 25 Nov 2014 14:02:26 +0000
Message-ID: <1416924151-28698-12-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/tipc/socket.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e918091..2d4b2fa 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -700,7 +700,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
  * tipc_sendmcast - send multicast message
  * @sock: socket structure
  * @seq: destination address
- * @iov: message data to send
+ * @msg: message to send
  * @dsz: total length of message data
  * @timeo: timeout to wait for wakeup
  *
@@ -708,7 +708,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
  * Returns the number of bytes sent on success, or errno
  */
 static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
-			  struct iovec *iov, size_t dsz, long timeo)
+			  struct msghdr *msg, size_t dsz, long timeo)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
@@ -727,7 +727,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
-	rc = tipc_msg_build(mhdr, iov, 0, dsz, mtu, &buf);
+	rc = tipc_msg_build(mhdr, msg->msg_iov, 0, dsz, mtu, &buf);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -951,7 +951,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 
 	if (dest->addrtype == TIPC_ADDR_MCAST) {
-		rc = tipc_sendmcast(sock, seq, iov, dsz, timeo);
+		rc = tipc_sendmcast(sock, seq, m, dsz, timeo);
 		goto exit;
 	} else if (dest->addrtype == TIPC_ADDR_NAME) {
 		u32 type = dest->addr.name.name.type;
-- 
1.7.10.4
