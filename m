From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 04/14] sctp: remove the typedef sctp_scope_t
Date: Sat,  5 Aug 2017 19:59:54 +0800
Message-ID: <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35000 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751338AbdHEMAp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:00:45 -0400
In-Reply-To: <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_scope_t, and
replace with enum sctp_scope in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  4 ++--
 include/net/sctp/sctp.h      |  4 ++--
 include/net/sctp/structs.h   | 17 +++++++++--------
 net/sctp/associola.c         | 17 ++++++++---------
 net/sctp/bind_addr.c         | 20 ++++++++++----------
 net/sctp/ipv6.c              |  6 +++---
 net/sctp/protocol.c          |  6 +++---
 net/sctp/sm_make_chunk.c     |  6 +++---
 net/sctp/socket.c            |  4 ++--
 9 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index acb03eb..0503bb7 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -333,13 +333,13 @@ typedef enum {
  * At this point, the IPv6 scopes will be mapped to these internal scopes
  * as much as possible.
  */
-typedef enum {
+enum sctp_scope {
 	SCTP_SCOPE_GLOBAL,		/* IPv4 global addresses */
 	SCTP_SCOPE_PRIVATE,		/* IPv4 private addresses */
 	SCTP_SCOPE_LINK,		/* IPv4 link local address */
 	SCTP_SCOPE_LOOPBACK,		/* IPv4 loopback address */
 	SCTP_SCOPE_UNUSABLE,		/* IPv4 unusable addresses */
-} sctp_scope_t;
+};
 
 enum {
 	SCTP_SCOPE_POLICY_DISABLE,	/* Disable IPv4 address scoping */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 84650fe..ca66b03 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -94,8 +94,8 @@
 /*
  * sctp/protocol.c
  */
-int sctp_copy_local_addr_list(struct net *, struct sctp_bind_addr *,
-			      sctp_scope_t, gfp_t gfp, int flags);
+int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *addr,
+			      enum sctp_scope, gfp_t gfp, int flags);
 struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
 int sctp_register_pf(struct sctp_pf *, sa_family_t);
 void sctp_addr_wq_mgmt(struct net *, struct sctp_sockaddr_entry *, int);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5e872ac..d771d41 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -449,7 +449,7 @@ struct sctp_af {
 	int		(*addr_valid)	(union sctp_addr *,
 					 struct sctp_sock *,
 					 const struct sk_buff *);
-	sctp_scope_t	(*scope) (union sctp_addr *);
+	enum sctp_scope	(*scope)(union sctp_addr *);
 	void		(*inaddr_any)	(union sctp_addr *, __be16);
 	int		(*is_any)	(const union sctp_addr *);
 	int		(*available)	(union sctp_addr *,
@@ -1111,7 +1111,7 @@ void sctp_bind_addr_init(struct sctp_bind_addr *, __u16 port);
 void sctp_bind_addr_free(struct sctp_bind_addr *);
 int sctp_bind_addr_copy(struct net *net, struct sctp_bind_addr *dest,
 			const struct sctp_bind_addr *src,
-			sctp_scope_t scope, gfp_t gfp,
+			enum sctp_scope scope, gfp_t gfp,
 			int flags);
 int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
 			const struct sctp_bind_addr *src,
@@ -1135,8 +1135,9 @@ union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
 int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw, int len,
 			   __u16 port, gfp_t gfp);
 
-sctp_scope_t sctp_scope(const union sctp_addr *);
-int sctp_in_scope(struct net *net, const union sctp_addr *addr, const sctp_scope_t scope);
+enum sctp_scope sctp_scope(const union sctp_addr *addr);
+int sctp_in_scope(struct net *net, const union sctp_addr *addr,
+		  const enum sctp_scope scope);
 int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
 int sctp_is_ep_boundall(struct sock *sk);
 
@@ -1925,8 +1926,8 @@ static inline struct sctp_association *sctp_assoc(struct sctp_ep_common *base)
 
 
 struct sctp_association *
-sctp_association_new(const struct sctp_endpoint *, const struct sock *,
-		     sctp_scope_t scope, gfp_t gfp);
+sctp_association_new(const struct sctp_endpoint *ep, const struct sock *sk,
+		     enum sctp_scope scope, gfp_t gfp);
 void sctp_association_free(struct sctp_association *);
 void sctp_association_put(struct sctp_association *);
 void sctp_association_hold(struct sctp_association *);
@@ -1967,8 +1968,8 @@ void sctp_assoc_set_primary(struct sctp_association *,
 			    struct sctp_transport *);
 void sctp_assoc_del_nonprimary_peers(struct sctp_association *,
 				    struct sctp_transport *);
-int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *,
-				     sctp_scope_t, gfp_t);
+int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *asoc,
+				     enum sctp_scope scope, gfp_t gfp);
 int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *,
 					 struct sctp_cookie*,
 					 gfp_t gfp);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 40ec836..4c1f1bb 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -63,11 +63,11 @@ static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc);
 /* 1st Level Abstractions. */
 
 /* Initialize a new association from provided memory. */
-static struct sctp_association *sctp_association_init(struct sctp_association *asoc,
-					  const struct sctp_endpoint *ep,
-					  const struct sock *sk,
-					  sctp_scope_t scope,
-					  gfp_t gfp)
+static struct sctp_association *sctp_association_init(
+					struct sctp_association *asoc,
+					const struct sctp_endpoint *ep,
+					const struct sock *sk,
+					enum sctp_scope scope, gfp_t gfp)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
@@ -301,9 +301,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 /* Allocate and initialize a new association */
 struct sctp_association *sctp_association_new(const struct sctp_endpoint *ep,
-					 const struct sock *sk,
-					 sctp_scope_t scope,
-					 gfp_t gfp)
+					      const struct sock *sk,
+					      enum sctp_scope scope, gfp_t gfp)
 {
 	struct sctp_association *asoc;
 
@@ -1564,7 +1563,7 @@ void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned int len)
  * local endpoint and the remote peer.
  */
 int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *asoc,
-				     sctp_scope_t scope, gfp_t gfp)
+				     enum sctp_scope scope, gfp_t gfp)
 {
 	int flags;
 
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 1ebc184..7df3704 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -45,9 +45,9 @@
 #include <net/sctp/sm.h>
 
 /* Forward declarations for internal helpers. */
-static int sctp_copy_one_addr(struct net *, struct sctp_bind_addr *,
-			      union sctp_addr *, sctp_scope_t scope, gfp_t gfp,
-			      int flags);
+static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
+			      union sctp_addr *addr, enum sctp_scope scope,
+			      gfp_t gfp, int flags);
 static void sctp_bind_addr_clean(struct sctp_bind_addr *);
 
 /* First Level Abstractions. */
@@ -57,7 +57,7 @@ static void sctp_bind_addr_clean(struct sctp_bind_addr *);
  */
 int sctp_bind_addr_copy(struct net *net, struct sctp_bind_addr *dest,
 			const struct sctp_bind_addr *src,
-			sctp_scope_t scope, gfp_t gfp,
+			enum sctp_scope scope, gfp_t gfp,
 			int flags)
 {
 	struct sctp_sockaddr_entry *addr;
@@ -440,9 +440,8 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 
 /* Copy out addresses from the global local address list. */
 static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
-			      union sctp_addr *addr,
-			      sctp_scope_t scope, gfp_t gfp,
-			      int flags)
+			      union sctp_addr *addr, enum sctp_scope scope,
+			      gfp_t gfp, int flags)
 {
 	int error = 0;
 
@@ -485,9 +484,10 @@ int sctp_is_any(struct sock *sk, const union sctp_addr *addr)
 }
 
 /* Is 'addr' valid for 'scope'?  */
-int sctp_in_scope(struct net *net, const union sctp_addr *addr, sctp_scope_t scope)
+int sctp_in_scope(struct net *net, const union sctp_addr *addr,
+		  enum sctp_scope scope)
 {
-	sctp_scope_t addr_scope = sctp_scope(addr);
+	enum sctp_scope addr_scope = sctp_scope(addr);
 
 	/* The unusable SCTP addresses will not be considered with
 	 * any defined scopes.
@@ -545,7 +545,7 @@ int sctp_is_ep_boundall(struct sock *sk)
  ********************************************************************/
 
 /* What is the scope of 'addr'?  */
-sctp_scope_t sctp_scope(const union sctp_addr *addr)
+enum sctp_scope sctp_scope(const union sctp_addr *addr)
 {
 	struct sctp_af *af;
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 107d7c9..a2a1c1d 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -243,8 +243,8 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	union sctp_addr *daddr = &t->ipaddr;
 	union sctp_addr dst_saddr;
 	struct in6_addr *final_p, final;
+	enum sctp_scope scope;
 	__u8 matchlen = 0;
-	sctp_scope_t scope;
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->daddr = daddr->v6.sin6_addr;
@@ -624,10 +624,10 @@ static int sctp_v6_addr_valid(union sctp_addr *addr,
 }
 
 /* What is the scope of 'addr'?  */
-static sctp_scope_t sctp_v6_scope(union sctp_addr *addr)
+static enum sctp_scope sctp_v6_scope(union sctp_addr *addr)
 {
+	enum sctp_scope retval;
 	int v6scope;
-	sctp_scope_t retval;
 
 	/* The IPv6 scope is really a set of bit fields.
 	 * See IFA_* in <net/if_inet6.h>.  Map to a generic SCTP scope.
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 852556d..fcd80fe 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -196,7 +196,7 @@ static void sctp_free_local_addr_list(struct net *net)
 
 /* Copy the local addresses which are valid for 'scope' into 'bp'.  */
 int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
-			      sctp_scope_t scope, gfp_t gfp, int copy_flags)
+			      enum sctp_scope scope, gfp_t gfp, int copy_flags)
 {
 	struct sctp_sockaddr_entry *addr;
 	union sctp_addr laddr;
@@ -400,9 +400,9 @@ static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
  * IPv4 scoping can be controlled through sysctl option
  * net.sctp.addr_scope_policy
  */
-static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
+static enum sctp_scope sctp_v4_scope(union sctp_addr *addr)
 {
-	sctp_scope_t retval;
+	enum sctp_scope retval;
 
 	/* Check for unusable SCTP addresses. */
 	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr)) {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index d17e8d1..a034d84 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1578,8 +1578,8 @@ struct sctp_association *sctp_make_temp_asoc(const struct sctp_endpoint *ep,
 					gfp_t gfp)
 {
 	struct sctp_association *asoc;
+	enum sctp_scope scope;
 	struct sk_buff *skb;
-	sctp_scope_t scope;
 
 	/* Create the bare association.  */
 	scope = sctp_scope(sctp_source(chunk));
@@ -1701,7 +1701,7 @@ struct sctp_association *sctp_unpack_cookie(
 	int headersize, bodysize, fixed_size;
 	__u8 *digest = ep->digest;
 	unsigned int len;
-	sctp_scope_t scope;
+	enum sctp_scope scope;
 	struct sk_buff *skb = chunk->skb;
 	ktime_t kt;
 
@@ -2502,7 +2502,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 	int i;
 	__u16 sat;
 	int retval = 1;
-	sctp_scope_t scope;
+	enum sctp_scope scope;
 	u32 stale;
 	struct sctp_af *af;
 	union sctp_addr_param *addr_param;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1db478e..a1e2113 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1055,7 +1055,7 @@ static int __sctp_connect(struct sock *sk,
 	struct sctp_association *asoc2;
 	struct sctp_transport *transport;
 	union sctp_addr to;
-	sctp_scope_t scope;
+	enum sctp_scope scope;
 	long timeo;
 	int err = 0;
 	int addrcnt = 0;
@@ -1610,7 +1610,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	struct sctp_initmsg *sinit;
 	sctp_assoc_t associd = 0;
 	sctp_cmsgs_t cmsgs = { NULL };
-	sctp_scope_t scope;
+	enum sctp_scope scope;
 	bool fill_sinfo_ttl = false, wait_connect = false;
 	struct sctp_datamsg *datamsg;
 	int msg_flags = msg->msg_flags;
-- 
2.1.0
