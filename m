From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 6/7] sctp: remove macros sctp_{lock|release}_sock
Date: Tue, 21 Jan 2014 15:44:11 +0800
Message-ID: <1390290252-16080-7-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:30394 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaAUHuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:50:04 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined {lock|release}_sock to sctp_{lock|release}_sock for user space friendly
code which we haven't use in years, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h |  2 --
 net/sctp/socket.c       | 62 ++++++++++++++++++++++++-------------------------
 2 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 572cd5a..ec18d30 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -171,8 +171,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  */
 
 /* sock lock wrappers. */
-#define sctp_lock_sock(sk)       lock_sock(sk)
-#define sctp_release_sock(sk)    release_sock(sk)
 #define sctp_bh_lock_sock(sk)    bh_lock_sock(sk)
 #define sctp_bh_unlock_sock(sk)  bh_unlock_sock(sk)
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 98532cb..893aa56 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -272,7 +272,7 @@ static int sctp_bind(struct sock *sk, struct sockaddr *addr, int addr_len)
 {
 	int retval = 0;
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	pr_debug("%s: sk:%p, addr:%p, addr_len:%d\n", __func__, sk,
 		 addr, addr_len);
@@ -284,7 +284,7 @@ static int sctp_bind(struct sock *sk, struct sockaddr *addr, int addr_len)
 	else
 		retval = -EINVAL;
 
-	sctp_release_sock(sk);
+	release_sock(sk);
 
 	return retval;
 }
@@ -1461,7 +1461,7 @@ static void sctp_close(struct sock *sk, long timeout)
 
 	pr_debug("%s: sk:%p, timeout:%ld\n", __func__, sk, timeout);
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 	sk->sk_shutdown = SHUTDOWN_MASK;
 	sk->sk_state = SCTP_SS_CLOSING;
 
@@ -1505,7 +1505,7 @@ static void sctp_close(struct sock *sk, long timeout)
 		sctp_wait_for_close(sk, timeout);
 
 	/* This will run the backlog queue.  */
-	sctp_release_sock(sk);
+	release_sock(sk);
 
 	/* Supposedly, no process has access to the socket, but
 	 * the net layers still may.
@@ -1665,7 +1665,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	pr_debug("%s: about to look up association\n", __func__);
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	/* If a msg_name has been specified, assume this is to be used.  */
 	if (msg_name) {
@@ -1949,7 +1949,7 @@ out_free:
 		sctp_association_free(asoc);
 	}
 out_unlock:
-	sctp_release_sock(sk);
+	release_sock(sk);
 
 out_nounlock:
 	return sctp_error(sk, msg_flags, err);
@@ -2035,7 +2035,7 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 		 "addr_len:%p)\n", __func__, sk, msg, len, noblock, flags,
 		 addr_len);
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	if (sctp_style(sk, TCP) && !sctp_sstate(sk, ESTABLISHED)) {
 		err = -ENOTCONN;
@@ -2119,7 +2119,7 @@ out_free:
 		sctp_ulpevent_free(event);
 	}
 out:
-	sctp_release_sock(sk);
+	release_sock(sk);
 	return err;
 }
 
@@ -3590,7 +3590,7 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 		goto out_nounlock;
 	}
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	switch (optname) {
 	case SCTP_SOCKOPT_BINDX_ADD:
@@ -3708,7 +3708,7 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 		break;
 	}
 
-	sctp_release_sock(sk);
+	release_sock(sk);
 
 out_nounlock:
 	return retval;
@@ -3736,7 +3736,7 @@ static int sctp_connect(struct sock *sk, struct sockaddr *addr,
 	int err = 0;
 	struct sctp_af *af;
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	pr_debug("%s: sk:%p, sockaddr:%p, addr_len:%d\n", __func__, sk,
 		 addr, addr_len);
@@ -3752,7 +3752,7 @@ static int sctp_connect(struct sock *sk, struct sockaddr *addr,
 		err = __sctp_connect(sk, addr, af->sockaddr_len, NULL);
 	}
 
-	sctp_release_sock(sk);
+	release_sock(sk);
 	return err;
 }
 
@@ -3778,7 +3778,7 @@ static struct sock *sctp_accept(struct sock *sk, int flags, int *err)
 	long timeo;
 	int error = 0;
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	sp = sctp_sk(sk);
 	ep = sp->ep;
@@ -3816,7 +3816,7 @@ static struct sock *sctp_accept(struct sock *sk, int flags, int *err)
 	sctp_sock_migrate(sk, newsk, asoc, SCTP_SOCKET_TCP);
 
 out:
-	sctp_release_sock(sk);
+	release_sock(sk);
 	*err = error;
 	return newsk;
 }
@@ -3826,7 +3826,7 @@ static int sctp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	int rc = -ENOTCONN;
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	/*
 	 * SEQPACKET-style sockets in LISTENING state are valid, for
@@ -3856,7 +3856,7 @@ static int sctp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		break;
 	}
 out:
-	sctp_release_sock(sk);
+	release_sock(sk);
 	return rc;
 }
 
@@ -5754,7 +5754,7 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	switch (optname) {
 	case SCTP_STATUS:
@@ -5878,7 +5878,7 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		break;
 	}
 
-	sctp_release_sock(sk);
+	release_sock(sk);
 	return retval;
 }
 
@@ -6144,7 +6144,7 @@ int sctp_inet_listen(struct socket *sock, int backlog)
 	if (unlikely(backlog < 0))
 		return err;
 
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 	/* Peeled-off sockets are not allowed to listen().  */
 	if (sctp_style(sk, UDP_HIGH_BANDWIDTH))
@@ -6177,7 +6177,7 @@ int sctp_inet_listen(struct socket *sock, int backlog)
 
 	err = 0;
 out:
-	sctp_release_sock(sk);
+	release_sock(sk);
 	return err;
 }
 
@@ -6474,9 +6474,9 @@ static int sctp_wait_for_packet(struct sock *sk, int *err, long *timeo_p)
 	 * does not fit in the user's buffer, but this seems to be the
 	 * only way to honor MSG_DONTWAIT realistically.
 	 */
-	sctp_release_sock(sk);
+	release_sock(sk);
 	*timeo_p = schedule_timeout(*timeo_p);
-	sctp_lock_sock(sk);
+	lock_sock(sk);
 
 ready:
 	finish_wait(sk_sleep(sk), &wait);
@@ -6659,10 +6659,10 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
 		/* Let another process have a go.  Since we are going
 		 * to sleep anyway.
 		 */
-		sctp_release_sock(sk);
+		release_sock(sk);
 		current_timeo = schedule_timeout(current_timeo);
 		BUG_ON(sk != asoc->base.sk);
-		sctp_lock_sock(sk);
+		lock_sock(sk);
 
 		*timeo_p = current_timeo;
 	}
@@ -6767,9 +6767,9 @@ static int sctp_wait_for_connect(struct sctp_association *asoc, long *timeo_p)
 		/* Let another process have a go.  Since we are going
 		 * to sleep anyway.
 		 */
-		sctp_release_sock(sk);
+		release_sock(sk);
 		current_timeo = schedule_timeout(current_timeo);
-		sctp_lock_sock(sk);
+		lock_sock(sk);
 
 		*timeo_p = current_timeo;
 	}
@@ -6812,9 +6812,9 @@ static int sctp_wait_for_accept(struct sock *sk, long timeo)
 					  TASK_INTERRUPTIBLE);
 
 		if (list_empty(&ep->asocs)) {
-			sctp_release_sock(sk);
+			release_sock(sk);
 			timeo = schedule_timeout(timeo);
-			sctp_lock_sock(sk);
+			lock_sock(sk);
 		}
 
 		err = -EINVAL;
@@ -6847,9 +6847,9 @@ static void sctp_wait_for_close(struct sock *sk, long timeout)
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		if (list_empty(&sctp_sk(sk)->ep->asocs))
 			break;
-		sctp_release_sock(sk);
+		release_sock(sk);
 		timeout = schedule_timeout(timeout);
-		sctp_lock_sock(sk);
+		lock_sock(sk);
 	} while (!signal_pending(current) && timeout);
 
 	finish_wait(sk_sleep(sk), &wait);
@@ -7046,7 +7046,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 		newsk->sk_shutdown |= RCV_SHUTDOWN;
 
 	newsk->sk_state = SCTP_SS_ESTABLISHED;
-	sctp_release_sock(newsk);
+	release_sock(newsk);
 }
 
 
-- 
1.7.12
