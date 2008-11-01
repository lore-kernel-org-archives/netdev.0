From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH/1] nets:clean up net/unix/af_unix.c garbage.c
	sysctl_net_unix.c
Date: Sat, 1 Nov 2008 18:15:49 +0800
Message-ID: <20081101101549.GF6556@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752629AbYKAKQP@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


clean up net/unix/af_unix.c garbage.c sysctl_net_unix.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/unix/af_unix.c         |   73 +++++++++++++++++++++----------------------
 net/unix/garbage.c         |   12 +++---
 net/unix/sysctl_net_unix.c |    1 -
 3 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index dc504d3..0b80634 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -211,7 +211,7 @@ static int unix_mkname(struct sockaddr_un * sunaddr, int len, unsigned *hashp)
 		 * we are guaranteed that it is a valid memory location in our
 		 * kernel address buffer.
 		 */
-		((char *)sunaddr)[len]=0;
+		((char *)sunaddr)[len] = 0;
 		len = strlen(sunaddr->sun_path)+1+sizeof(short);
 		return len;
 	}
@@ -392,9 +392,9 @@ static int unix_release_sock (struct sock *sk, int embrion)
 
 	wake_up_interruptible_all(&u->peer_wait);
 
-	skpair=unix_peer(sk);
+	skpair = unix_peer(sk);
 
-	if (skpair!=NULL) {
+	if (skpair != NULL) {
 		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
 			unix_state_lock(skpair);
 			/* No more writes */
@@ -414,7 +414,7 @@ static int unix_release_sock (struct sock *sk, int embrion)
 	/* Try to flush out this socket. Throw out buffers at least */
 
 	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-		if (state==TCP_LISTEN)
+		if (state == TCP_LISTEN)
 			unix_release_sock(skb->sk, 1);
 		/* passed fds are erased in the kfree_skb hook	      */
 		kfree_skb(skb);
@@ -630,7 +630,7 @@ static int unix_create(struct net *net, struct socket *sock, int protocol)
 		 *	nothing uses it.
 		 */
 	case SOCK_RAW:
-		sock->type=SOCK_DGRAM;
+		sock->type = SOCK_DGRAM;
 	case SOCK_DGRAM:
 		sock->ops = &unix_dgram_ops;
 		break;
@@ -736,14 +736,14 @@ static struct sock *unix_find_other(struct net *net,
 
 		path_put(&path);
 
-		err=-EPROTOTYPE;
+		err = -EPROTOTYPE;
 		if (u->sk_type != type) {
 			sock_put(u);
 			goto fail;
 		}
 	} else {
 		err = -ECONNREFUSED;
-		u=unix_find_socket_byname(net, sunname, len, type, hash);
+		u = unix_find_socket_byname(net, sunname, len, type, hash);
 		if (u) {
 			struct dentry *dentry;
 			dentry = unix_sk(u)->dentry;
@@ -757,7 +757,7 @@ static struct sock *unix_find_other(struct net *net,
 put_fail:
 	path_put(&path);
 fail:
-	*error=err;
+	*error = err;
 	return NULL;
 }
 
@@ -767,7 +767,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
-	struct sockaddr_un *sunaddr=(struct sockaddr_un *)uaddr;
+	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
 	struct dentry * dentry = NULL;
 	struct nameidata nd;
 	int err;
@@ -779,7 +779,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (sunaddr->sun_family != AF_UNIX)
 		goto out;
 
-	if (addr_len==sizeof(short)) {
+	if (addr_len == sizeof(short)) {
 		err = unix_autobind(sock);
 		goto out;
 	}
@@ -875,8 +875,8 @@ out_mknod_unlock:
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 	path_put(&nd.path);
 out_mknod_parent:
-	if (err==-EEXIST)
-		err=-EADDRINUSE;
+	if (err == -EEXIST)
+		err = -EADDRINUSE;
 	unix_release_addr(addr);
 	goto out_up;
 }
@@ -911,7 +911,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
-	struct sockaddr_un *sunaddr=(struct sockaddr_un*)addr;
+	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
 	struct sock *other;
 	unsigned hash;
 	int err;
@@ -927,7 +927,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			goto out;
 
 restart:
-		other=unix_find_other(net, sunaddr, alen, sock->type, hash, &err);
+		other = unix_find_other(net, sunaddr, alen, sock->type, hash, &err);
 		if (!other)
 			goto out;
 
@@ -961,14 +961,14 @@ restart:
 	 */
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
-		unix_peer(sk)=other;
+		unix_peer(sk) = other;
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
 			unix_dgram_disconnected(sk, old_peer);
 		sock_put(old_peer);
 	} else {
-		unix_peer(sk)=other;
+		unix_peer(sk) = other;
 		unix_state_double_unlock(sk, other);
 	}
 	return 0;
@@ -1004,7 +1004,7 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 			       int addr_len, int flags)
 {
-	struct sockaddr_un *sunaddr=(struct sockaddr_un *)uaddr;
+	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk), *newu, *otheru;
@@ -1179,13 +1179,13 @@ out:
 
 static int unix_socketpair(struct socket *socka, struct socket *sockb)
 {
-	struct sock *ska=socka->sk, *skb = sockb->sk;
+	struct sock *ska = socka->sk, *skb = sockb->sk;
 
 	/* Join our sockets back to back */
 	sock_hold(ska);
 	sock_hold(skb);
-	unix_peer(ska)=skb;
-	unix_peer(skb)=ska;
+	unix_peer(ska) = skb;
+	unix_peer(skb) = ska;
 	ska->sk_peercred.pid = skb->sk_peercred.pid = task_tgid_vnr(current);
 	ska->sk_peercred.uid = skb->sk_peercred.uid = current->euid;
 	ska->sk_peercred.gid = skb->sk_peercred.gid = current->egid;
@@ -1246,7 +1246,7 @@ static int unix_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_
 {
 	struct sock *sk = sock->sk;
 	struct unix_sock *u;
-	struct sockaddr_un *sunaddr=(struct sockaddr_un *)uaddr;
+	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
 	int err = 0;
 
 	if (peer) {
@@ -1323,7 +1323,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
-	struct sockaddr_un *sunaddr=msg->msg_name;
+	struct sockaddr_un *sunaddr = msg->msg_name;
 	struct sock *other = NULL;
 	int namelen = 0; /* fake GCC */
 	int err;
@@ -1364,7 +1364,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto out;
 
 	skb = sock_alloc_send_skb(sk, len, msg->msg_flags&MSG_DONTWAIT, &err);
-	if (skb==NULL)
+	if (skb == NULL)
 		goto out;
 
 	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
@@ -1387,7 +1387,7 @@ restart:
 
 		other = unix_find_other(net, sunaddr, namelen, sk->sk_type,
 					hash, &err);
-		if (other==NULL)
+		if (other == NULL)
 			goto out_free;
 	}
 
@@ -1407,7 +1407,7 @@ restart:
 		err = 0;
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
-			unix_peer(sk)=NULL;
+			unix_peer(sk) = NULL;
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -1473,10 +1473,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
-	struct sockaddr_un *sunaddr=msg->msg_name;
+	struct sockaddr_un *sunaddr = msg->msg_name;
 	int err,size;
 	struct sk_buff *skb;
-	int sent=0;
+	int sent = 0;
 	struct scm_cookie tmp_scm;
 
 	if (NULL == siocb->scm)
@@ -1523,9 +1523,9 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 *	Grab a buffer
 		 */
 
-		skb=sock_alloc_send_skb(sk,size,msg->msg_flags&MSG_DONTWAIT, &err);
+		skb = sock_alloc_send_skb(sk,size,msg->msg_flags&MSG_DONTWAIT, &err);
 
-		if (skb==NULL)
+		if (skb == NULL)
 			goto out_err;
 
 		/*
@@ -1555,7 +1555,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		unix_state_unlock(other);
 		other->sk_data_ready(other, size);
-		sent+=size;
+		sent += size;
 	}
 
 	scm_destroy(siocb->scm);
@@ -1734,7 +1734,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
-	struct sockaddr_un *sunaddr=msg->msg_name;
+	struct sockaddr_un *sunaddr = msg->msg_name;
 	int copied = 0;
 	int check_creds = 0;
 	int target;
@@ -1772,7 +1772,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		unix_state_lock(sk);
 		skb = skb_dequeue(&sk->sk_receive_queue);
-		if (skb==NULL)
+		if (skb == NULL)
 		{
 			if (copied >= target)
 				goto unlock;
@@ -1884,7 +1884,7 @@ static int unix_shutdown(struct socket *sock, int mode)
 	if (mode) {
 		unix_state_lock(sk);
 		sk->sk_shutdown |= mode;
-		other=unix_peer(sk);
+		other = unix_peer(sk);
 		if (other)
 			sock_hold(other);
 		unix_state_unlock(sk);
@@ -1919,7 +1919,7 @@ static int unix_shutdown(struct socket *sock, int mode)
 static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	long amount=0;
+	long amount = 0;
 	int err;
 
 	switch(cmd)
@@ -1945,7 +1945,7 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			} else {
 				skb = skb_peek(&sk->sk_receive_queue);
 				if (skb)
-					amount=skb->len;
+					amount = skb->len;
 			}
 			spin_unlock(&sk->sk_receive_queue.lock);
 			err = put_user(amount, (int __user *)arg);
@@ -2077,6 +2077,7 @@ struct unix_iter_state {
 	struct seq_net_private p;
 	int i;
 };
+
 static struct sock *unix_seq_idx(struct seq_file *seq, loff_t pos)
 {
 	struct unix_iter_state *iter = seq->private;
@@ -2093,7 +2094,6 @@ static struct sock *unix_seq_idx(struct seq_file *seq, loff_t pos)
 	return NULL;
 }
 
-
 static void *unix_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(unix_table_lock)
 {
@@ -2173,7 +2173,6 @@ static const struct seq_operations unix_seq_ops = {
 	.show   = unix_seq_show,
 };
 
-
 static int unix_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &unix_seq_ops,
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 2a27b84..00734e2 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -104,8 +104,8 @@ static struct sock *unix_get_socket(struct file *filp)
 	 *	Socket ?
 	 */
 	if (S_ISSOCK(inode->i_mode)) {
-		struct socket * sock = SOCKET_I(inode);
-		struct sock * s = sock->sk;
+		struct socket *sock = SOCKET_I(inode);
+		struct sock *s = sock->sk;
 
 		/*
 		 *	PF_UNIX ?
@@ -124,7 +124,7 @@ static struct sock *unix_get_socket(struct file *filp)
 void unix_inflight(struct file *fp)
 {
 	struct sock *s = unix_get_socket(fp);
-	if(s) {
+	if (s) {
 		struct unix_sock *u = unix_sk(s);
 		spin_lock(&unix_gc_lock);
 		if (atomic_long_inc_return(&u->inflight) == 1) {
@@ -141,7 +141,7 @@ void unix_inflight(struct file *fp)
 void unix_notinflight(struct file *fp)
 {
 	struct sock *s = unix_get_socket(fp);
-	if(s) {
+	if (s) {
 		struct unix_sock *u = unix_sk(s);
 		spin_lock(&unix_gc_lock);
 		BUG_ON(list_empty(&u->link));
@@ -154,7 +154,7 @@ void unix_notinflight(struct file *fp)
 
 static inline struct sk_buff *sock_queue_head(struct sock *sk)
 {
-	return (struct sk_buff *) &sk->sk_receive_queue;
+	return (struct sk_buff *)&sk->sk_receive_queue;
 }
 
 #define receive_queue_for_each_skb(sk, next, skb) \
@@ -339,7 +339,7 @@ void unix_gc(void)
 	 */
 	skb_queue_head_init(&hitlist);
 	list_for_each_entry(u, &gc_candidates, link)
-		scan_children(&u->sk, inc_inflight, &hitlist);
+	scan_children(&u->sk, inc_inflight, &hitlist);
 
 	spin_unlock(&unix_gc_lock);
 
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 77513d7..1f4040c 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -61,4 +61,3 @@ void unix_sysctl_unregister(struct net *net)
 	unregister_sysctl_table(net->unx.ctl);
 	kfree(table);
 }
-
-- 
1.5.6.3
