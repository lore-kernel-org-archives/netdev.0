From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Remove netlink_sock_nr
Date: Wed, 27 Oct 2004 15:11:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027051107.GA8784@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch removes netlink_sock_nr which is only used by a printk
statement in af_netlink.c.  Even that's only there if
NETLINK_REFCNT_DEBUG is defined.

If we were really looking for netlink refcnt bugs there are probably
better places to do that anyway.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.57 vs edited =====
--- 1.57/net/netlink/af_netlink.c	2004-10-20 15:10:40 +10:00
+++ edited/net/netlink/af_netlink.c	2004-10-27 15:01:47 +10:00
@@ -80,8 +80,6 @@
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
 
-atomic_t netlink_sock_nr;
-
 static rwlock_t nl_table_lock = RW_LOCK_UNLOCKED;
 static atomic_t nl_table_users = ATOMIC_INIT(0);
 
@@ -100,11 +98,6 @@
 	BUG_TRAP(!nlk_sk(sk)->cb);
 
 	kfree(nlk_sk(sk));
-
-	atomic_dec(&netlink_sock_nr);
-#ifdef NETLINK_REFCNT_DEBUG
-	printk(KERN_DEBUG "NETLINK %p released, %d are still alive\n", sk, atomic_read(&netlink_sock_nr));
-#endif
 }
 
 /* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on SMP.
@@ -240,7 +233,6 @@
 	spin_lock_init(&nlk->cb_lock);
 	init_waitqueue_head(&nlk->wait);
 	sk->sk_destruct = netlink_sock_destruct;
-	atomic_inc(&netlink_sock_nr);
 
 	sk->sk_protocol = protocol;
 	return 0;

--bg08WKrSYDhXBjb5--
