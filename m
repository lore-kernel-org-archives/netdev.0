From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 12/17] tipc_sendmsg(): pass msghdr instead of its ->msg_iov
Date: Sat, 22 Nov 2014 04:36:45 +0000
Message-ID: <20141122043645.GL30478@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/tipc/socket.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 591bbfa..8c94ec4 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -692,7 +692,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
  * tipc_sendmcast - send multicast message
  * @sock: socket structure
  * @seq: destination address
- * @iov: message data to send
+ * @msg: message to send
  * @dsz: total length of message data
  * @timeo: timeout to wait for wakeup
  *
@@ -700,7 +700,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
  * Returns the number of bytes sent on success, or errno
  */
 static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
-			  struct iovec *iov, size_t dsz, long timeo)
+			  struct msghdr *msg, size_t dsz, long timeo)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
@@ -719,7 +719,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
-	rc = tipc_msg_build(mhdr, iov, 0, dsz, mtu, &buf);
+	rc = tipc_msg_build(mhdr, msg->msg_iov, 0, dsz, mtu, &buf);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -943,7 +943,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 
 	if (dest->addrtype == TIPC_ADDR_MCAST) {
-		rc = tipc_sendmcast(sock, seq, iov, dsz, timeo);
+		rc = tipc_sendmcast(sock, seq, m, dsz, timeo);
 		goto exit;
 	} else if (dest->addrtype == TIPC_ADDR_NAME) {
 		u32 type = dest->addr.name.name.type;
-- 
1.7.10.4
