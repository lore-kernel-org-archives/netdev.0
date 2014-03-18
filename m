From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/13] xfrm: rename struct xfrm_filter
Date: Tue, 18 Mar 2014 08:21:26 +0100
Message-ID: <1395127298-24083-2-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53255 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbaCRHVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:53 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

iproute2 already defines a structure with that name, let's use another one to
avoid any conflict.

CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h        |    4 ++--
 include/uapi/linux/xfrm.h |    4 ++--
 net/key/af_key.c          |    2 +-
 net/xfrm/xfrm_state.c     |    4 ++--
 net/xfrm/xfrm_user.c      |    8 ++++----
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8b92528..ce3d96f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -121,7 +121,7 @@ struct xfrm_state_walk {
 	u8			dying;
 	u8			proto;
 	u32			seq;
-	struct xfrm_filter	*filter;
+	struct xfrm_address_filter *filter;
 };
 
 /* Full description of state of transformer. */
@@ -1423,7 +1423,7 @@ static inline void xfrm_sysctl_fini(struct net *net)
 #endif
 
 void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
-			  struct xfrm_filter *filter);
+			  struct xfrm_address_filter *filter);
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*), void *);
 void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net);
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 6550c67..25e5dd9 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -299,7 +299,7 @@ enum xfrm_attr_type_t {
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
 	XFRMA_PROTO,		/* __u8 */
-	XFRMA_FILTER,		/* struct xfrm_filter */
+	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -476,7 +476,7 @@ struct xfrm_user_mapping {
 	__be16				new_sport;
 };
 
-struct xfrm_filter {
+struct xfrm_address_filter {
 	xfrm_address_t			saddr;
 	xfrm_address_t			daddr;
 	__u16				family;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index a50d979..12651b4 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1799,7 +1799,7 @@ static void pfkey_dump_sa_done(struct pfkey_sock *pfk)
 static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_msg *hdr, void * const *ext_hdrs)
 {
 	u8 proto;
-	struct xfrm_filter *filter = NULL;
+	struct xfrm_address_filter *filter = NULL;
 	struct pfkey_sock *pfk = pfkey_sk(sk);
 
 	if (pfk->dump.dump != NULL)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5339c26..cee850c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1598,7 +1598,7 @@ unlock:
 EXPORT_SYMBOL(xfrm_alloc_spi);
 
 static bool __xfrm_state_filter_match(struct xfrm_state *x,
-				      struct xfrm_filter *filter)
+				      struct xfrm_address_filter *filter)
 {
 	if (filter) {
 		if ((filter->family == AF_INET ||
@@ -1657,7 +1657,7 @@ out:
 EXPORT_SYMBOL(xfrm_state_walk);
 
 void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
-			  struct xfrm_filter *filter)
+			  struct xfrm_address_filter *filter)
 {
 	INIT_LIST_HEAD(&walk->all);
 	walk->proto = proto;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 023e5e7..903725b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -904,7 +904,7 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (!cb->args[0]) {
 		struct nlattr *attrs[XFRMA_MAX+1];
-		struct xfrm_filter *filter = NULL;
+		struct xfrm_address_filter *filter = NULL;
 		u8 proto = 0;
 		int err;
 
@@ -915,12 +915,12 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		if (err < 0)
 			return err;
 
-		if (attrs[XFRMA_FILTER]) {
+		if (attrs[XFRMA_ADDRESS_FILTER]) {
 			filter = kmalloc(sizeof(*filter), GFP_KERNEL);
 			if (filter == NULL)
 				return -ENOMEM;
 
-			memcpy(filter, nla_data(attrs[XFRMA_FILTER]),
+			memcpy(filter, nla_data(attrs[XFRMA_ADDRESS_FILTER]),
 			       sizeof(*filter));
 		}
 
@@ -2334,7 +2334,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_REPLAY_ESN_VAL]	= { .len = sizeof(struct xfrm_replay_state_esn) },
 	[XFRMA_SA_EXTRA_FLAGS]	= { .type = NLA_U32 },
 	[XFRMA_PROTO]		= { .type = NLA_U8 },
-	[XFRMA_FILTER]		= { .len = sizeof(struct xfrm_filter) },
+	[XFRMA_ADDRESS_FILTER]	= { .len = sizeof(struct xfrm_address_filter) },
 };
 
 static const struct xfrm_link {
-- 
1.7.9.5
