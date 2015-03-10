From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] inet_diag: cleanups
Date: Tue, 10 Mar 2015 07:15:53 -0700
Message-ID: <1425996954-24693-3-git-send-email-edumazet@google.com>
References: <1425996954-24693-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:33388 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbbCJOQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 10:16:26 -0400
Received: by obbnt9 with SMTP id nt9so496925obb.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 07:16:26 -0700 (PDT)
In-Reply-To: <1425996954-24693-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove all inline keywords, add some const, and cleanup style.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 144 +++++++++++++++++++++++++--------------------------
 1 file changed, 71 insertions(+), 73 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 0c974d3499ed..cd261f6e3abb 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -38,8 +38,8 @@
 static const struct inet_diag_handler **inet_diag_table;
 
 struct inet_diag_entry {
-	__be32 *saddr;
-	__be32 *daddr;
+	const __be32 *saddr;
+	const __be32 *daddr;
 	u16 sport;
 	u16 dport;
 	u16 family;
@@ -65,28 +65,27 @@ static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
 	return inet_diag_table[proto];
 }
 
-static inline void inet_diag_unlock_handler(
-	const struct inet_diag_handler *handler)
+static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
 {
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
-			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
-			      struct user_namespace *user_ns,		      	
-			      u32 portid, u32 seq, u16 nlmsg_flags,
-			      const struct nlmsghdr *unlh)
+		      struct sk_buff *skb, struct inet_diag_req_v2 *req,
+		      struct user_namespace *user_ns,
+		      u32 portid, u32 seq, u16 nlmsg_flags,
+		      const struct nlmsghdr *unlh)
 {
 	const struct inet_sock *inet = inet_sk(sk);
+	const struct inet_diag_handler *handler;
+	int ext = req->idiag_ext;
 	struct inet_diag_msg *r;
 	struct nlmsghdr  *nlh;
 	struct nlattr *attr;
 	void *info = NULL;
-	const struct inet_diag_handler *handler;
-	int ext = req->idiag_ext;
 
 	handler = inet_diag_table[req->sdiag_protocol];
-	BUG_ON(handler == NULL);
+	BUG_ON(!handler);
 
 	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
 			nlmsg_flags);
@@ -125,7 +124,6 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
-
 		*(struct in6_addr *)r->id.idiag_src = sk->sk_v6_rcv_saddr;
 		*(struct in6_addr *)r->id.idiag_dst = sk->sk_v6_daddr;
 
@@ -155,7 +153,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
 			goto errout;
 
-	if (icsk == NULL) {
+	if (!icsk) {
 		handler->idiag_get_info(sk, r, NULL);
 		goto out;
 	}
@@ -213,23 +211,25 @@ errout:
 EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
 
 static int inet_csk_diag_fill(struct sock *sk,
-			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
+			      struct sk_buff *skb,
+			      struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,
 			      u32 portid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
-	return inet_sk_diag_fill(sk, inet_csk(sk),
-			skb, req, user_ns, portid, seq, nlmsg_flags, unlh);
+	return inet_sk_diag_fill(sk, inet_csk(sk), skb, req,
+				 user_ns, portid, seq, nlmsg_flags, unlh);
 }
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
-			       struct sk_buff *skb, struct inet_diag_req_v2 *req,
+			       struct sk_buff *skb,
+			       struct inet_diag_req_v2 *req,
 			       u32 portid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
-	s32 tmo;
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
+	s32 tmo;
 
 	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
 			nlmsg_flags);
@@ -290,36 +290,35 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 				  nlmsg_flags, unlh);
 }
 
-int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
-		const struct nlmsghdr *nlh, struct inet_diag_req_v2 *req)
+int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
+			    struct sk_buff *in_skb,
+			    const struct nlmsghdr *nlh,
+			    struct inet_diag_req_v2 *req)
 {
-	int err;
-	struct sock *sk;
-	struct sk_buff *rep;
 	struct net *net = sock_net(in_skb->sk);
+	struct sk_buff *rep;
+	struct sock *sk;
+	int err;
 
 	err = -EINVAL;
-	if (req->sdiag_family == AF_INET) {
+	if (req->sdiag_family == AF_INET)
 		sk = inet_lookup(net, hashinfo, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
-	}
 #if IS_ENABLED(CONFIG_IPV6)
-	else if (req->sdiag_family == AF_INET6) {
+	else if (req->sdiag_family == AF_INET6)
 		sk = inet6_lookup(net, hashinfo,
 				  (struct in6_addr *)req->id.idiag_dst,
 				  req->id.idiag_dport,
 				  (struct in6_addr *)req->id.idiag_src,
 				  req->id.idiag_sport,
 				  req->id.idiag_if);
-	}
 #endif
-	else {
+	else
 		goto out_nosk;
-	}
 
 	err = -ENOENT;
-	if (sk == NULL)
+	if (!sk)
 		goto out_nosk;
 
 	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
@@ -400,9 +399,8 @@ static int bitstring_match(const __be32 *a1, const __be32 *a2, int bits)
 	return 1;
 }
 
-
 static int inet_diag_bc_run(const struct nlattr *_bc,
-		const struct inet_diag_entry *entry)
+			    const struct inet_diag_entry *entry)
 {
 	const void *bc = nla_data(_bc);
 	int len = nla_len(_bc);
@@ -434,10 +432,10 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 			break;
 		case INET_DIAG_BC_S_COND:
 		case INET_DIAG_BC_D_COND: {
-			struct inet_diag_hostcond *cond;
-			__be32 *addr;
+			const struct inet_diag_hostcond *cond;
+			const __be32 *addr;
 
-			cond = (struct inet_diag_hostcond *)(op + 1);
+			cond = (const struct inet_diag_hostcond *)(op + 1);
 			if (cond->port != -1 &&
 			    cond->port != (op->code == INET_DIAG_BC_S_COND ?
 					     entry->sport : entry->dport)) {
@@ -488,16 +486,15 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 
 int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 {
-	struct inet_diag_entry entry;
 	struct inet_sock *inet = inet_sk(sk);
+	struct inet_diag_entry entry;
 
-	if (bc == NULL)
+	if (!bc)
 		return 1;
 
 	entry.family = sk->sk_family;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (entry.family == AF_INET6) {
-
 		entry.saddr = sk->sk_v6_rcv_saddr.s6_addr32;
 		entry.daddr = sk->sk_v6_daddr.s6_addr32;
 	} else
@@ -535,8 +532,8 @@ static int valid_cc(const void *bc, int len, int cc)
 static bool valid_hostcond(const struct inet_diag_bc_op *op, int len,
 			   int *min_len)
 {
-	int addr_len;
 	struct inet_diag_hostcond *cond;
+	int addr_len;
 
 	/* Check hostcond space. */
 	*min_len += sizeof(struct inet_diag_hostcond);
@@ -570,8 +567,8 @@ static bool valid_hostcond(const struct inet_diag_bc_op *op, int len,
 }
 
 /* Validate a port comparison operator. */
-static inline bool valid_port_comparison(const struct inet_diag_bc_op *op,
-					 int len, int *min_len)
+static bool valid_port_comparison(const struct inet_diag_bc_op *op,
+				  int len, int *min_len)
 {
 	/* Port comparisons put the port in a follow-on inet_diag_bc_op. */
 	*min_len += sizeof(struct inet_diag_bc_op);
@@ -586,10 +583,9 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 	int  len = bytecode_len;
 
 	while (len > 0) {
-		const struct inet_diag_bc_op *op = bc;
 		int min_len = sizeof(struct inet_diag_bc_op);
+		const struct inet_diag_bc_op *op = bc;
 
-//printk("BC: %d %d %d {%d} / %d\n", op->code, op->yes, op->no, op[1].no, len);
 		switch (op->code) {
 		case INET_DIAG_BC_S_COND:
 		case INET_DIAG_BC_D_COND:
@@ -687,11 +683,11 @@ static int inet_twsk_diag_dump(struct sock *sk,
 /* Get the IPv4, IPv6, or IPv4-mapped-IPv6 local and remote addresses
  * from a request_sock. For IPv4-mapped-IPv6 we must map IPv4 to IPv6.
  */
-static inline void inet_diag_req_addrs(const struct sock *sk,
-				       const struct request_sock *req,
-				       struct inet_diag_entry *entry)
+static void inet_diag_req_addrs(const struct sock *sk,
+				const struct request_sock *req,
+				struct inet_diag_entry *entry)
 {
-	struct inet_request_sock *ireq = inet_rsk(req);
+	const struct inet_request_sock *ireq = inet_rsk(req);
 
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6) {
@@ -761,6 +757,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
 		struct inet_diag_entry entry;
+
 		inet_diag_req_addrs(sk, req, &entry);
 		memcpy(r->id.idiag_src, entry.saddr, sizeof(struct in6_addr));
 		memcpy(r->id.idiag_dst, entry.daddr, sizeof(struct in6_addr));
@@ -776,12 +773,11 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			       struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
-	struct inet_diag_entry entry;
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt;
 	struct inet_sock *inet = inet_sk(sk);
-	int j, s_j;
-	int reqnum, s_reqnum;
+	struct inet_diag_entry entry;
+	int j, s_j, reqnum, s_reqnum;
+	struct listen_sock *lopt;
 	int err = 0;
 
 	s_j = cb->args[3];
@@ -798,7 +794,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	if (!lopt || !lopt->qlen)
 		goto out;
 
-	if (bc != NULL) {
+	if (bc) {
 		entry.sport = inet->inet_num;
 		entry.userlocks = sk->sk_userlocks;
 	}
@@ -825,9 +821,9 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			}
 
 			err = inet_diag_fill_req(skb, sk, req,
-					       sk_user_ns(NETLINK_CB(cb->skb).sk),
-					       NETLINK_CB(cb->skb).portid,
-					       cb->nlh->nlmsg_seq, cb->nlh);
+						 sk_user_ns(NETLINK_CB(cb->skb).sk),
+						 NETLINK_CB(cb->skb).portid,
+						 cb->nlh->nlmsg_seq, cb->nlh);
 			if (err < 0) {
 				cb->args[3] = j + 1;
 				cb->args[4] = reqnum;
@@ -845,11 +841,11 @@ out:
 }
 
 void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
-		struct netlink_callback *cb, struct inet_diag_req_v2 *r, struct nlattr *bc)
+			 struct netlink_callback *cb,
+			 struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
-	int i, num;
-	int s_i, s_num;
 	struct net *net = sock_net(skb->sk);
+	int i, num, s_i, s_num;
 
 	s_i = cb->args[1];
 	s_num = num = cb->args[2];
@@ -859,9 +855,9 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			goto skip_listen_ht;
 
 		for (i = s_i; i < INET_LHTABLE_SIZE; i++) {
-			struct sock *sk;
-			struct hlist_nulls_node *node;
 			struct inet_listen_hashbucket *ilb;
+			struct hlist_nulls_node *node;
+			struct sock *sk;
 
 			num = 0;
 			ilb = &hashinfo->listening_hash[i];
@@ -878,7 +874,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 				}
 
 				if (r->sdiag_family != AF_UNSPEC &&
-						sk->sk_family != r->sdiag_family)
+				    sk->sk_family != r->sdiag_family)
 					goto next_listen;
 
 				if (r->id.idiag_sport != inet->inet_sport &&
@@ -926,8 +922,8 @@ skip_listen_ht:
 	for (i = s_i; i <= hashinfo->ehash_mask; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
 		spinlock_t *lock = inet_ehash_lockp(hashinfo, i);
-		struct sock *sk;
 		struct hlist_nulls_node *node;
+		struct sock *sk;
 
 		num = 0;
 
@@ -939,8 +935,7 @@ skip_listen_ht:
 
 		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &head->chain) {
-			int res;
-			int state;
+			int state, res;
 
 			if (!net_eq(sock_net(sk), net))
 				continue;
@@ -983,7 +978,8 @@ out:
 EXPORT_SYMBOL_GPL(inet_diag_dump_icsk);
 
 static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req_v2 *r, struct nlattr *bc)
+			    struct inet_diag_req_v2 *r,
+			    struct nlattr *bc)
 {
 	const struct inet_diag_handler *handler;
 	int err = 0;
@@ -1000,8 +996,8 @@ static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 
 static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct nlattr *bc = NULL;
 	int hdrlen = sizeof(struct inet_diag_req_v2);
+	struct nlattr *bc = NULL;
 
 	if (nlmsg_attrlen(cb->nlh, hdrlen))
 		bc = nlmsg_find_attr(cb->nlh, hdrlen, INET_DIAG_REQ_BYTECODE);
@@ -1009,7 +1005,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return __inet_diag_dump(skb, cb, nlmsg_data(cb->nlh), bc);
 }
 
-static inline int inet_diag_type2proto(int type)
+static int inet_diag_type2proto(int type)
 {
 	switch (type) {
 	case TCPDIAG_GETSOCK:
@@ -1021,12 +1017,13 @@ static inline int inet_diag_type2proto(int type)
 	}
 }
 
-static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *cb)
+static int inet_diag_dump_compat(struct sk_buff *skb,
+				 struct netlink_callback *cb)
 {
 	struct inet_diag_req *rc = nlmsg_data(cb->nlh);
+	int hdrlen = sizeof(struct inet_diag_req);
 	struct inet_diag_req_v2 req;
 	struct nlattr *bc = NULL;
-	int hdrlen = sizeof(struct inet_diag_req);
 
 	req.sdiag_family = AF_UNSPEC; /* compatibility */
 	req.sdiag_protocol = inet_diag_type2proto(cb->nlh->nlmsg_type);
@@ -1041,7 +1038,7 @@ static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *c
 }
 
 static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
-			       const struct nlmsghdr *nlh)
+				      const struct nlmsghdr *nlh)
 {
 	struct inet_diag_req *rc = nlmsg_data(nlh);
 	struct inet_diag_req_v2 req;
@@ -1070,7 +1067,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			attr = nlmsg_find_attr(nlh, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			if (attr == NULL ||
+			if (!attr ||
 			    nla_len(attr) < sizeof(struct inet_diag_bc_op) ||
 			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
 				return -EINVAL;
@@ -1097,9 +1094,10 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	if (h->nlmsg_flags & NLM_F_DUMP) {
 		if (nlmsg_attrlen(h, hdrlen)) {
 			struct nlattr *attr;
+
 			attr = nlmsg_find_attr(h, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			if (attr == NULL ||
+			if (!attr ||
 			    nla_len(attr) < sizeof(struct inet_diag_bc_op) ||
 			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
 				return -EINVAL;
@@ -1135,7 +1133,7 @@ int inet_diag_register(const struct inet_diag_handler *h)
 
 	mutex_lock(&inet_diag_table_mutex);
 	err = -EEXIST;
-	if (inet_diag_table[type] == NULL) {
+	if (!inet_diag_table[type]) {
 		inet_diag_table[type] = h;
 		err = 0;
 	}
-- 
2.2.0.rc0.207.ga3a616c
