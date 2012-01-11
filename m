From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] inet_diag: Rename inet_diag_req into inet_diag_req_v2
Date: Wed, 11 Jan 2012 12:36:35 +0400
Message-ID: <4F0D4A13.2030606@parallels.com>
References: <4F0D49D4.7040100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44420 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163Ab2AKIgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 03:36:44 -0500
In-Reply-To: <4F0D49D4.7040100@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |   12 ++++++------
 net/dccp/diag.c           |    4 ++--
 net/ipv4/inet_diag.c      |   34 +++++++++++++++++-----------------
 net/ipv4/tcp_diag.c       |    4 ++--
 net/ipv4/udp_diag.c       |   14 +++++++-------
 5 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 34e8d52..a5b7e91 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -34,7 +34,7 @@ struct inet_diag_req_compat {
 	__u32	idiag_dbs;		/* Tables to dump (NI) */
 };
 
-struct inet_diag_req {
+struct inet_diag_req_v2 {
 	__u8	sdiag_family;
 	__u8	sdiag_protocol;
 	__u8	idiag_ext;
@@ -143,12 +143,12 @@ struct netlink_callback;
 struct inet_diag_handler {
 	void			(*dump)(struct sk_buff *skb,
 					struct netlink_callback *cb,
-					struct inet_diag_req *r,
+					struct inet_diag_req_v2 *r,
 					struct nlattr *bc);
 
 	int			(*dump_one)(struct sk_buff *in_skb,
 					const struct nlmsghdr *nlh,
-					struct inet_diag_req *req);
+					struct inet_diag_req_v2 *req);
 
 	void			(*idiag_get_info)(struct sock *sk,
 						  struct inet_diag_msg *r,
@@ -158,15 +158,15 @@ struct inet_diag_handler {
 
 struct inet_connection_sock;
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
-			      struct sk_buff *skb, struct inet_diag_req *req,
+			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh);
 void inet_diag_dump_icsk(struct inet_hashinfo *h, struct sk_buff *skb,
-		struct netlink_callback *cb, struct inet_diag_req *r,
+		struct netlink_callback *cb, struct inet_diag_req_v2 *r,
 		struct nlattr *bc);
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 		struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req *req);
+		struct inet_diag_req_v2 *req);
 
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 8f16257..028fc43 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -49,13 +49,13 @@ static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 }
 
 static void dccp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	inet_diag_dump_icsk(&dccp_hashinfo, skb, cb, r, bc);
 }
 
 static int dccp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req *req)
+		struct inet_diag_req_v2 *req)
 {
 	return inet_diag_dump_one_icsk(&dccp_hashinfo, in_skb, nlh, req);
 }
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 2240a8e..cf23a7c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -71,7 +71,7 @@ static inline void inet_diag_unlock_handler(
 }
 
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
-			      struct sk_buff *skb, struct inet_diag_req *req,
+			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
@@ -193,7 +193,7 @@ nlmsg_failure:
 EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
 
 static int inet_csk_diag_fill(struct sock *sk,
-			      struct sk_buff *skb, struct inet_diag_req *req,
+			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
@@ -202,7 +202,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 }
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
-			       struct sk_buff *skb, struct inet_diag_req *req,
+			       struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			       u32 pid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
@@ -253,7 +253,7 @@ nlmsg_failure:
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
-			struct inet_diag_req *r, u32 pid, u32 seq, u16 nlmsg_flags,
+			struct inet_diag_req_v2 *r, u32 pid, u32 seq, u16 nlmsg_flags,
 			const struct nlmsghdr *unlh)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
@@ -264,7 +264,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 }
 
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
-		const struct nlmsghdr *nlh, struct inet_diag_req *req)
+		const struct nlmsghdr *nlh, struct inet_diag_req_v2 *req)
 {
 	int err;
 	struct sock *sk;
@@ -333,7 +333,7 @@ EXPORT_SYMBOL_GPL(inet_diag_dump_one_icsk);
 
 static int inet_diag_get_exact(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
-			       struct inet_diag_req *req)
+			       struct inet_diag_req_v2 *req)
 {
 	const struct inet_diag_handler *handler;
 	int err;
@@ -540,7 +540,7 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 static int inet_csk_diag_dump(struct sock *sk,
 			      struct sk_buff *skb,
 			      struct netlink_callback *cb,
-			      struct inet_diag_req *r,
+			      struct inet_diag_req_v2 *r,
 			      const struct nlattr *bc)
 {
 	if (!inet_diag_bc_sk(bc, sk))
@@ -554,7 +554,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb,
 			       struct netlink_callback *cb,
-			       struct inet_diag_req *r,
+			       struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
 	if (bc != NULL) {
@@ -639,7 +639,7 @@ nlmsg_failure:
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			       struct netlink_callback *cb,
-			       struct inet_diag_req *r,
+			       struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
 	struct inet_diag_entry entry;
@@ -721,7 +721,7 @@ out:
 }
 
 void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
-		struct netlink_callback *cb, struct inet_diag_req *r, struct nlattr *bc)
+		struct netlink_callback *cb, struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	int i, num;
 	int s_i, s_num;
@@ -872,7 +872,7 @@ out:
 EXPORT_SYMBOL_GPL(inet_diag_dump_icsk);
 
 static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	const struct inet_diag_handler *handler;
 
@@ -887,12 +887,12 @@ static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct nlattr *bc = NULL;
-	int hdrlen = sizeof(struct inet_diag_req);
+	int hdrlen = sizeof(struct inet_diag_req_v2);
 
 	if (nlmsg_attrlen(cb->nlh, hdrlen))
 		bc = nlmsg_find_attr(cb->nlh, hdrlen, INET_DIAG_REQ_BYTECODE);
 
-	return __inet_diag_dump(skb, cb, (struct inet_diag_req *)NLMSG_DATA(cb->nlh), bc);
+	return __inet_diag_dump(skb, cb, (struct inet_diag_req_v2 *)NLMSG_DATA(cb->nlh), bc);
 }
 
 static inline int inet_diag_type2proto(int type)
@@ -910,7 +910,7 @@ static inline int inet_diag_type2proto(int type)
 static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct inet_diag_req_compat *rc = NLMSG_DATA(cb->nlh);
-	struct inet_diag_req req;
+	struct inet_diag_req_v2 req;
 	struct nlattr *bc = NULL;
 	int hdrlen = sizeof(struct inet_diag_req_compat);
 
@@ -930,7 +930,7 @@ static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh)
 {
 	struct inet_diag_req_compat *rc = NLMSG_DATA(nlh);
-	struct inet_diag_req req;
+	struct inet_diag_req_v2 req;
 
 	req.sdiag_family = rc->idiag_family;
 	req.sdiag_protocol = inet_diag_type2proto(nlh->nlmsg_type);
@@ -970,7 +970,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 {
-	int hdrlen = sizeof(struct inet_diag_req);
+	int hdrlen = sizeof(struct inet_diag_req_v2);
 
 	if (nlmsg_len(h) < hdrlen)
 		return -EINVAL;
@@ -990,7 +990,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 					  inet_diag_dump, NULL, 0);
 	}
 
-	return inet_diag_get_exact(skb, h, (struct inet_diag_req *)NLMSG_DATA(h));
+	return inet_diag_get_exact(skb, h, (struct inet_diag_req_v2 *)NLMSG_DATA(h));
 }
 
 static struct sock_diag_handler inet_diag_handler = {
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 8cd357a..ed3f2ad 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -35,13 +35,13 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 }
 
 static void tcp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	inet_diag_dump_icsk(&tcp_hashinfo, skb, cb, r, bc);
 }
 
 static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req *req)
+		struct inet_diag_req_v2 *req)
 {
 	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
 }
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 69f8a7c..e5e18cb 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -19,7 +19,7 @@
 #include <linux/sock_diag.h>
 
 static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
-		struct netlink_callback *cb, struct inet_diag_req *req,
+		struct netlink_callback *cb, struct inet_diag_req_v2 *req,
 		struct nlattr *bc)
 {
 	if (!inet_diag_bc_sk(bc, sk))
@@ -30,7 +30,7 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 }
 
 static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
-		const struct nlmsghdr *nlh, struct inet_diag_req *req)
+		const struct nlmsghdr *nlh, struct inet_diag_req_v2 *req)
 {
 	int err = -EINVAL;
 	struct sock *sk;
@@ -88,7 +88,7 @@ out_nosk:
 }
 
 static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	int num, s_num, slot, s_slot;
 
@@ -136,13 +136,13 @@ done:
 }
 
 static void udp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	udp_dump(&udp_table, skb, cb, r, bc);
 }
 
 static int udp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req *req)
+		struct inet_diag_req_v2 *req)
 {
 	return udp_dump_one(&udp_table, in_skb, nlh, req);
 }
@@ -154,13 +154,13 @@ static const struct inet_diag_handler udp_diag_handler = {
 };
 
 static void udplite_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	udp_dump(&udplite_table, skb, cb, r, bc);
 }
 
 static int udplite_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req *req)
+		struct inet_diag_req_v2 *req)
 {
 	return udp_dump_one(&udplite_table, in_skb, nlh, req);
 }
-- 
1.5.5.6
