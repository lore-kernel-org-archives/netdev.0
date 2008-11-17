From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: Cleanup of af_unix
Date: Mon, 17 Nov 2008 07:46:21 +0100
Message-ID: <4921133D.6070800@cosmosbay.com>
References: <49210AE7.3050405@cosmosbay.com> <20081116.223209.239966240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408010704070503020106"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34219 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbYKQGq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:46:28 -0500
In-Reply-To: <20081116.223209.239966240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030408010704070503020106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 17 Nov 2008 07:10:47 +0100
>=20
>> @@ -1998,7 +1990,8 @@ static unsigned int unix_poll(struct file * file=
, struct socket *sock, poll_tabl
>>  		mask |=3D POLLIN | POLLRDNORM;
>> =20
>>  	/* Connection-based need to check for termination and startup */
>> -	if ((sk->sk_type =3D=3D SOCK_STREAM || sk->sk_type =3D=3D SOCK_SEQPA=
CKET) && sk->sk_state =3D=3D TCP_CLOSE)
>> +	if ((sk->sk_type =3D=3D SOCK_STREAM || sk->sk_type =3D=3D SOCK_SEQPA=
CKET) &&
>> +		sk->sk_state =3D=3D TCP_CLOSE)
>>  		mask |=3D POLLHUP;
>> =20
>>  	/*
>=20
> This should instead be:
>=20
> 	if ((sk->sk_type =3D=3D SOCK_STREAM || sk->sk_type =3D=3D SOCK_SEQPACK=
ET) &&
> 	    sk->sk_state =3D=3D TCP_CLOSE)

Oops thats right.

>=20
>> Some long lines (over 80 columns) were not changed, please tell me if =
you prefer
>> them go.
>=20
> I'm ambivalent, at which point it's just noise and merge hassles, so le=
t's
> just leave it alone.

OK, let's try with the updated version then :)

Thanks

[PATCH] net: Cleanup of af_unix

This is a pure cleanup of net/unix/af_unix.c to meet current code style s=
tandards

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---=20
 net/unix/af_unix.c |  117 ++++++++++++++++++++-----------------------
 1 files changed, 55 insertions(+), 62 deletions(-)

--------------030408010704070503020106
Content-Type: text/plain;
 name="af_unix_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_unix_cleanup.patch"

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4a39771..58db2a2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -164,7 +164,7 @@ static inline int unix_our_peer(struct sock *sk, struct sock *osk)
 
 static inline int unix_may_send(struct sock *sk, struct sock *osk)
 {
-	return (unix_peer(osk) == NULL || unix_our_peer(sk, osk));
+	return unix_peer(osk) == NULL || unix_our_peer(sk, osk);
 }
 
 static inline int unix_recvq_full(struct sock const *sk)
@@ -197,7 +197,7 @@ static inline void unix_release_addr(struct unix_address *addr)
  *		- if started by zero, it is abstract name.
  */
 
-static int unix_mkname(struct sockaddr_un * sunaddr, int len, unsigned *hashp)
+static int unix_mkname(struct sockaddr_un *sunaddr, int len, unsigned *hashp)
 {
 	if (len <= sizeof(short) || len > sizeof(*sunaddr))
 		return -EINVAL;
@@ -216,7 +216,7 @@ static int unix_mkname(struct sockaddr_un * sunaddr, int len, unsigned *hashp)
 		return len;
 	}
 
-	*hashp = unix_hash_fold(csum_partial((char*)sunaddr, len, 0));
+	*hashp = unix_hash_fold(csum_partial((char *)sunaddr, len, 0));
 	return len;
 }
 
@@ -295,8 +295,7 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
 		if (!net_eq(sock_net(s), net))
 			continue;
 
-		if(dentry && dentry->d_inode == i)
-		{
+		if (dentry && dentry->d_inode == i) {
 			sock_hold(s);
 			goto found;
 		}
@@ -354,7 +353,7 @@ static void unix_sock_destructor(struct sock *sk)
 	WARN_ON(!sk_unhashed(sk));
 	WARN_ON(sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Attempt to release alive unix socket: %p\n", sk);
+		printk(KERN_DEBUG "Attempt to release alive unix socket: %p\n", sk);
 		return;
 	}
 
@@ -363,11 +362,12 @@ static void unix_sock_destructor(struct sock *sk)
 
 	atomic_dec(&unix_nr_socks);
 #ifdef UNIX_REFCNT_DEBUG
-	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk, atomic_read(&unix_nr_socks));
+	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk,
+		atomic_read(&unix_nr_socks));
 #endif
 }
 
-static int unix_release_sock (struct sock *sk, int embrion)
+static int unix_release_sock(struct sock *sk, int embrion)
 {
 	struct unix_sock *u = unix_sk(sk);
 	struct dentry *dentry;
@@ -453,11 +453,11 @@ static int unix_listen(struct socket *sock, int backlog)
 	struct unix_sock *u = unix_sk(sk);
 
 	err = -EOPNOTSUPP;
-	if (sock->type!=SOCK_STREAM && sock->type!=SOCK_SEQPACKET)
-		goto out;			/* Only stream/seqpacket sockets accept */
+	if (sock->type != SOCK_STREAM && sock->type != SOCK_SEQPACKET)
+		goto out;	/* Only stream/seqpacket sockets accept */
 	err = -EINVAL;
 	if (!u->addr)
-		goto out;			/* No listens on an unbound socket */
+		goto out;	/* No listens on an unbound socket */
 	unix_state_lock(sk);
 	if (sk->sk_state != TCP_CLOSE && sk->sk_state != TCP_LISTEN)
 		goto out_unlock;
@@ -579,7 +579,7 @@ static struct proto unix_proto = {
  */
 static struct lock_class_key af_unix_sk_receive_queue_lock_key;
 
-static struct sock * unix_create1(struct net *net, struct socket *sock)
+static struct sock *unix_create1(struct net *net, struct socket *sock)
 {
 	struct sock *sk = NULL;
 	struct unix_sock *u;
@@ -592,7 +592,7 @@ static struct sock * unix_create1(struct net *net, struct socket *sock)
 	if (!sk)
 		goto out;
 
-	sock_init_data(sock,sk);
+	sock_init_data(sock, sk);
 	lockdep_set_class(&sk->sk_receive_queue.lock,
 				&af_unix_sk_receive_queue_lock_key);
 
@@ -653,7 +653,7 @@ static int unix_release(struct socket *sock)
 
 	sock->sk = NULL;
 
-	return unix_release_sock (sk, 0);
+	return unix_release_sock(sk, 0);
 }
 
 static int unix_autobind(struct socket *sock)
@@ -662,7 +662,7 @@ static int unix_autobind(struct socket *sock)
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	static u32 ordernum = 1;
-	struct unix_address * addr;
+	struct unix_address *addr;
 	int err;
 
 	mutex_lock(&u->readlock);
@@ -681,7 +681,7 @@ static int unix_autobind(struct socket *sock)
 
 retry:
 	addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);
-	addr->hash = unix_hash_fold(csum_partial((void*)addr->name, addr->len, 0));
+	addr->hash = unix_hash_fold(csum_partial((void *)addr->name, addr->len, 0));
 
 	spin_lock(&unix_table_lock);
 	ordernum = (ordernum+1)&0xFFFFF;
@@ -768,7 +768,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
-	struct dentry * dentry = NULL;
+	struct dentry *dentry = NULL;
 	struct nameidata nd;
 	int err;
 	unsigned hash;
@@ -1207,7 +1207,7 @@ static int unix_accept(struct socket *sock, struct socket *newsock, int flags)
 	int err;
 
 	err = -EOPNOTSUPP;
-	if (sock->type!=SOCK_STREAM && sock->type!=SOCK_SEQPACKET)
+	if (sock->type != SOCK_STREAM && sock->type != SOCK_SEQPACKET)
 		goto out;
 
 	err = -EINVAL;
@@ -1286,7 +1286,7 @@ static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	skb->destructor = sock_wfree;
 	UNIXCB(skb).fp = NULL;
 
-	for (i=scm->fp->count-1; i>=0; i--)
+	for (i = scm->fp->count-1; i >= 0; i--)
 		unix_notinflight(scm->fp->fp[i]);
 }
 
@@ -1315,7 +1315,7 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	if (!UNIXCB(skb).fp)
 		return -ENOMEM;
 
-	for (i=scm->fp->count-1; i>=0; i--)
+	for (i = scm->fp->count-1; i >= 0; i--)
 		unix_inflight(scm->fp->fp[i]);
 	skb->destructor = unix_destruct_fds;
 	return 0;
@@ -1385,7 +1385,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	unix_get_secdata(siocb->scm, skb);
 
 	skb_reset_transport_header(skb);
-	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
+	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 	if (err)
 		goto out_free;
 
@@ -1486,7 +1486,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
 	struct sockaddr_un *sunaddr = msg->msg_name;
-	int err,size;
+	int err, size;
 	struct sk_buff *skb;
 	int sent = 0;
 	struct scm_cookie tmp_scm;
@@ -1515,8 +1515,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (sk->sk_shutdown & SEND_SHUTDOWN)
 		goto pipe_err;
 
-	while(sent < len)
-	{
+	while (sent < len) {
 		/*
 		 *	Optimisation for the fact that under 0.01% of X
 		 *	messages typically need breaking up.
@@ -1535,7 +1534,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 *	Grab a buffer
 		 */
 
-		skb = sock_alloc_send_skb(sk,size,msg->msg_flags&MSG_DONTWAIT, &err);
+		skb = sock_alloc_send_skb(sk, size, msg->msg_flags&MSG_DONTWAIT,
+					  &err);
 
 		if (skb == NULL)
 			goto out_err;
@@ -1558,7 +1558,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			}
 		}
 
-		if ((err = memcpy_fromiovec(skb_put(skb,size), msg->msg_iov, size)) != 0) {
+		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		if (err) {
 			kfree_skb(skb);
 			goto out_err;
 		}
@@ -1584,8 +1585,8 @@ pipe_err_free:
 	unix_state_unlock(other);
 	kfree_skb(skb);
 pipe_err:
-	if (sent==0 && !(msg->msg_flags&MSG_NOSIGNAL))
-		send_sig(SIGPIPE,current,0);
+	if (sent == 0 && !(msg->msg_flags&MSG_NOSIGNAL))
+		send_sig(SIGPIPE, current, 0);
 	err = -EPIPE;
 out_err:
 	scm_destroy(siocb->scm);
@@ -1675,13 +1676,10 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	siocb->scm->creds = *UNIXCREDS(skb);
 	unix_set_secdata(siocb->scm, skb);
 
-	if (!(flags & MSG_PEEK))
-	{
+	if (!(flags & MSG_PEEK)) {
 		if (UNIXCB(skb).fp)
 			unix_detach_fds(siocb->scm, skb);
-	}
-	else
-	{
+	} else {
 		/* It is questionable: on PEEK we could:
 		   - do not return fds - good, but too simple 8)
 		   - return fds, and do not return them on read (old strategy,
@@ -1702,7 +1700,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	scm_recv(sock, msg, siocb->scm, flags);
 
 out_free:
-	skb_free_datagram(sk,skb);
+	skb_free_datagram(sk, skb);
 out_unlock:
 	mutex_unlock(&u->readlock);
 out:
@@ -1713,7 +1711,7 @@ out:
  *	Sleep until data has arrive. But check for races..
  */
 
-static long unix_stream_data_wait(struct sock * sk, long timeo)
+static long unix_stream_data_wait(struct sock *sk, long timeo)
 {
 	DEFINE_WAIT(wait);
 
@@ -1782,15 +1780,13 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	mutex_lock(&u->readlock);
 
-	do
-	{
+	do {
 		int chunk;
 		struct sk_buff *skb;
 
 		unix_state_lock(sk);
 		skb = skb_dequeue(&sk->sk_receive_queue);
-		if (skb == NULL)
-		{
+		if (skb == NULL) {
 			if (copied >= target)
 				goto unlock;
 
@@ -1798,7 +1794,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			 *	POSIX 1003.1g mandates this order.
 			 */
 
-			if ((err = sock_error(sk)) != 0)
+			err = sock_error(sk);
+			if (err)
 				goto unlock;
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				goto unlock;
@@ -1825,7 +1822,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
-			if (memcmp(UNIXCREDS(skb), &siocb->scm->creds, sizeof(siocb->scm->creds)) != 0) {
+			if (memcmp(UNIXCREDS(skb), &siocb->scm->creds,
+				   sizeof(siocb->scm->creds)) != 0) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				break;
 			}
@@ -1836,8 +1834,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		/* Copy address just once */
-		if (sunaddr)
-		{
+		if (sunaddr) {
 			unix_copy_addr(msg, skb->sk);
 			sunaddr = NULL;
 		}
@@ -1853,16 +1850,14 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		size -= chunk;
 
 		/* Mark read part of skb as used */
-		if (!(flags & MSG_PEEK))
-		{
+		if (!(flags & MSG_PEEK)) {
 			skb_pull(skb, chunk);
 
 			if (UNIXCB(skb).fp)
 				unix_detach_fds(siocb->scm, skb);
 
 			/* put the skb back if we didn't use it up.. */
-			if (skb->len)
-			{
+			if (skb->len) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				break;
 			}
@@ -1871,9 +1866,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 			if (siocb->scm->fp)
 				break;
-		}
-		else
-		{
+		} else {
 			/* It is questionable, see note in unix_dgram_recvmsg.
 			 */
 			if (UNIXCB(skb).fp)
@@ -1939,13 +1932,12 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	long amount = 0;
 	int err;
 
-	switch(cmd)
-	{
-		case SIOCOUTQ:
-			amount = atomic_read(&sk->sk_wmem_alloc);
-			err = put_user(amount, (int __user *)arg);
-			break;
-		case SIOCINQ:
+	switch (cmd) {
+	case SIOCOUTQ:
+		amount = atomic_read(&sk->sk_wmem_alloc);
+		err = put_user(amount, (int __user *)arg);
+		break;
+	case SIOCINQ:
 		{
 			struct sk_buff *skb;
 
@@ -1969,14 +1961,14 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			break;
 		}
 
-		default:
-			err = -ENOIOCTLCMD;
-			break;
+	default:
+		err = -ENOIOCTLCMD;
+		break;
 	}
 	return err;
 }
 
-static unsigned int unix_poll(struct file * file, struct socket *sock, poll_table *wait)
+static unsigned int unix_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
 	unsigned int mask;
@@ -1998,7 +1990,8 @@ static unsigned int unix_poll(struct file * file, struct socket *sock, poll_tabl
 		mask |= POLLIN | POLLRDNORM;
 
 	/* Connection-based need to check for termination and startup */
-	if ((sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) && sk->sk_state == TCP_CLOSE)
+	if ((sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) &&
+	    sk->sk_state == TCP_CLOSE)
 		mask |= POLLHUP;
 
 	/*

--------------030408010704070503020106--
