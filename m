From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2 net-next] af_netlink: cleanups
Date: Mon, 23 Apr 2012 09:30:21 +0200
Message-ID: <1335166221.3293.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47959 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab2DWHaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 03:30:25 -0400
Received: by bkcik5 with SMTP id ik5so8325026bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 00:30:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

netlink_destroy_callback() move to avoid forward reference

CodingStyle cleanups

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netlink/af_netlink.c |   61 ++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 30 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index da87214..85d27f9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -104,27 +104,27 @@ static inline int netlink_is_kernel(struct sock *sk)
 }
 
 struct nl_pid_hash {
-	struct hlist_head *table;
-	unsigned long rehash_time;
+	struct hlist_head	*table;
+	unsigned long		rehash_time;
 
-	unsigned int mask;
-	unsigned int shift;
+	unsigned int		mask;
+	unsigned int		shift;
 
-	unsigned int entries;
-	unsigned int max_shift;
+	unsigned int		entries;
+	unsigned int		max_shift;
 
-	u32 rnd;
+	u32			rnd;
 };
 
 struct netlink_table {
-	struct nl_pid_hash hash;
-	struct hlist_head mc_list;
-	struct listeners __rcu *listeners;
-	unsigned int nl_nonroot;
-	unsigned int groups;
-	struct mutex *cb_mutex;
-	struct module *module;
-	int registered;
+	struct nl_pid_hash	hash;
+	struct hlist_head	mc_list;
+	struct listeners __rcu	*listeners;
+	unsigned int		nl_nonroot;
+	unsigned int		groups;
+	struct mutex		*cb_mutex;
+	struct module		*module;
+	int			registered;
 };
 
 static struct netlink_table *nl_table;
@@ -132,7 +132,6 @@ static struct netlink_table *nl_table;
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 
 static int netlink_dump(struct sock *sk);
-static void netlink_destroy_callback(struct netlink_callback *cb);
 
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
@@ -149,6 +148,12 @@ static inline struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid
 	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
 }
 
+static void netlink_destroy_callback(struct netlink_callback *cb)
+{
+	kfree_skb(cb->skb);
+	kfree(cb);
+}
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -414,9 +419,9 @@ static int __netlink_create(struct net *net, struct socket *sock,
 	sock_init_data(sock, sk);
 
 	nlk = nlk_sk(sk);
-	if (cb_mutex)
+	if (cb_mutex) {
 		nlk->cb_mutex = cb_mutex;
-	else {
+	} else {
 		nlk->cb_mutex = &nlk->cb_def_mutex;
 		mutex_init(nlk->cb_mutex);
 	}
@@ -522,8 +527,9 @@ static int netlink_release(struct socket *sock)
 			nl_table[sk->sk_protocol].module = NULL;
 			nl_table[sk->sk_protocol].registered = 0;
 		}
-	} else if (nlk->subscriptions)
+	} else if (nlk->subscriptions) {
 		netlink_update_listeners(sk);
+	}
 	netlink_table_ungrab();
 
 	kfree(nlk->groups);
@@ -1086,8 +1092,8 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	if (info.delivery_failure) {
 		kfree_skb(info.skb2);
 		return -ENOBUFS;
-	} else
-		consume_skb(info.skb2);
+	}
+	consume_skb(info.skb2);
 
 	if (info.delivered) {
 		if (info.congested && (allocation & __GFP_WAIT))
@@ -1240,8 +1246,9 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			nlk->flags |= NETLINK_RECV_NO_ENOBUFS;
 			clear_bit(0, &nlk->state);
 			wake_up_interruptible(&nlk->wait);
-		} else
+		} else {
 			nlk->flags &= ~NETLINK_RECV_NO_ENOBUFS;
+		}
 		err = 0;
 		break;
 	default:
@@ -1645,12 +1652,6 @@ void netlink_set_nonroot(int protocol, unsigned int flags)
 }
 EXPORT_SYMBOL(netlink_set_nonroot);
 
-static void netlink_destroy_callback(struct netlink_callback *cb)
-{
-	kfree_skb(cb->skb);
-	kfree(cb);
-}
-
 struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 {
@@ -1996,11 +1997,11 @@ static void netlink_seq_stop(struct seq_file *seq, void *v)
 
 static int netlink_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == SEQ_START_TOKEN)
+	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
 			 "sk       Eth Pid    Groups   "
 			 "Rmem     Wmem     Dump     Locks     Drops     Inode\n");
-	else {
+	} else {
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
