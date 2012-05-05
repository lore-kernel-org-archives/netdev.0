From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] net/ipv6/af_inet6.c: checkpatch cleanup
Date: Sat,  5 May 2012 22:13:53 +0200
Message-ID: <1336248834-25271-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

af_inet6.c:80: ERROR: do not initialise statics to 0 or NULL
af_inet6.c:259: ERROR: spaces required around that '=' (ctx:VxV)
af_inet6.c:394: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:412: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:422: ERROR: do not use assignment in if condition
af_inet6.c:425: ERROR: do not use assignment in if condition
af_inet6.c:433: ERROR: do not use assignment in if condition
af_inet6.c:437: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:446: ERROR: spaces required around that '=' (ctx:VxV)
af_inet6.c:478: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:485: ERROR: that open brace { should be on the previous line
af_inet6.c:485: ERROR: space required before the open parenthesis '('
af_inet6.c:513: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:629: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:647: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:687: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:709: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
af_inet6.c:1073: ERROR: space required before the open parenthesis '('

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/af_inet6.c |   29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0ad046c..bf8e146 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -77,7 +77,7 @@ struct ipv6_params ipv6_defaults = {
 	.autoconf = 1,
 };
 
-static int disable_ipv6_mod = 0;
+static int disable_ipv6_mod;
 
 module_param_named(disable, disable_ipv6_mod, int, 0444);
 MODULE_PARM_DESC(disable, "Disable IPv6 module such that it is non-functional");
@@ -256,7 +256,7 @@ out_rcu_unlock:
 /* bind for INET6 API */
 int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
-	struct sockaddr_in6 *addr=(struct sockaddr_in6 *)uaddr;
+	struct sockaddr_in6 *addr = (struct sockaddr_in6 *)uaddr;
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -390,7 +390,6 @@ out_unlock:
 	rcu_read_unlock();
 	goto out;
 }
-
 EXPORT_SYMBOL(inet6_bind);
 
 int inet6_release(struct socket *sock)
@@ -408,7 +407,6 @@ int inet6_release(struct socket *sock)
 
 	return inet_release(sock);
 }
-
 EXPORT_SYMBOL(inet6_release);
 
 void inet6_destroy_sock(struct sock *sk)
@@ -419,10 +417,12 @@ void inet6_destroy_sock(struct sock *sk)
 
 	/* Release rx options */
 
-	if ((skb = xchg(&np->pktoptions, NULL)) != NULL)
+	skb = xchg(&np->pktoptions, NULL);
+	if (skb != NULL)
 		kfree_skb(skb);
 
-	if ((skb = xchg(&np->rxpmtu, NULL)) != NULL)
+	skb = xchg(&np->rxpmtu, NULL);
+	if (skb != NULL)
 		kfree_skb(skb);
 
 	/* Free flowlabels */
@@ -430,10 +430,10 @@ void inet6_destroy_sock(struct sock *sk)
 
 	/* Free tx options */
 
-	if ((opt = xchg(&np->opt, NULL)) != NULL)
+	opt = xchg(&np->opt, NULL);
+	if (opt != NULL)
 		sock_kfree_s(sk, opt, opt->tot_len);
 }
-
 EXPORT_SYMBOL_GPL(inet6_destroy_sock);
 
 /*
@@ -443,7 +443,7 @@ EXPORT_SYMBOL_GPL(inet6_destroy_sock);
 int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 		 int *uaddr_len, int peer)
 {
-	struct sockaddr_in6 *sin=(struct sockaddr_in6 *)uaddr;
+	struct sockaddr_in6 *sin = (struct sockaddr_in6 *)uaddr;
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -474,7 +474,6 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 	*uaddr_len = sizeof(*sin);
 	return 0;
 }
-
 EXPORT_SYMBOL(inet6_getname);
 
 int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
@@ -482,8 +481,7 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 
-	switch(cmd)
-	{
+	switch (cmd) {
 	case SIOCGSTAMP:
 		return sock_get_timestamp(sk, (struct timeval __user *)arg);
 
@@ -509,7 +507,6 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	/*NOTREACHED*/
 	return 0;
 }
-
 EXPORT_SYMBOL(inet6_ioctl);
 
 const struct proto_ops inet6_stream_ops = {
@@ -625,7 +622,6 @@ out_illegal:
 	       p->type);
 	goto out;
 }
-
 EXPORT_SYMBOL(inet6_register_protosw);
 
 void
@@ -643,7 +639,6 @@ inet6_unregister_protosw(struct inet_protosw *p)
 		synchronize_net();
 	}
 }
-
 EXPORT_SYMBOL(inet6_unregister_protosw);
 
 int inet6_sk_rebuild_header(struct sock *sk)
@@ -683,7 +678,6 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(inet6_sk_rebuild_header);
 
 int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
@@ -705,7 +699,6 @@ int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
 	}
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
 static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
@@ -1070,7 +1063,7 @@ static int __init inet6_init(void)
 	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb));
 
 	/* Register the socket-side information for inet6_create.  */
-	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
+	for (r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
 		INIT_LIST_HEAD(r);
 
 	if (disable_ipv6_mod) {
-- 
1.7.10
