From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/26] xfrm: Const'ify pointer args to km_migrate() and
 implementations.
Date: Wed, 23 Feb 2011 23:13:19 -0800 (PST)
Message-ID: <20110223.231319.48501480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37472
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932574Ab1BXHMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:42 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4499F24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h    |   12 ++++++++----
 net/key/af_key.c      |   22 +++++++++++-----------
 net/xfrm/xfrm_state.c |    6 +++---
 net/xfrm/xfrm_user.c  |   24 ++++++++++++------------
 4 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b60f956..17b296b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -556,7 +556,11 @@ struct xfrm_mgr {
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, const struct km_event *c);
 	int			(*report)(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
-	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles, struct xfrm_kmaddress *k);
+	int			(*migrate)(const struct xfrm_selector *sel,
+					   u8 dir, u8 type,
+					   const struct xfrm_migrate *m,
+					   int num_bundles,
+					   const struct xfrm_kmaddress *k);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -1483,9 +1487,9 @@ struct xfrm_state *xfrm_find_acq(struct net *net, struct xfrm_mark *mark,
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 
 #ifdef CONFIG_XFRM_MIGRATE
-extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-		      struct xfrm_migrate *m, int num_bundles,
-		      struct xfrm_kmaddress *k);
+extern int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+		      const struct xfrm_migrate *m, int num_bundles,
+		      const struct xfrm_kmaddress *k);
 extern struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m);
 extern struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
 					      struct xfrm_migrate *m);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7c5e101..5637285 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -690,7 +690,7 @@ static inline int pfkey_mode_to_xfrm(int mode)
 	}
 }
 
-static unsigned int pfkey_sockaddr_fill(xfrm_address_t *xaddr, __be16 port,
+static unsigned int pfkey_sockaddr_fill(const xfrm_address_t *xaddr, __be16 port,
 				       struct sockaddr *sa,
 				       unsigned short family)
 {
@@ -3318,7 +3318,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 
 #ifdef CONFIG_NET_KEY_MIGRATE
 static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
-			    struct xfrm_selector *sel)
+			    const struct xfrm_selector *sel)
 {
 	struct sadb_address *addr;
 	addr = (struct sadb_address *)skb_put(skb, sizeof(struct sadb_address) + sasize);
@@ -3348,7 +3348,7 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 }
 
 
-static int set_sadb_kmaddress(struct sk_buff *skb, struct xfrm_kmaddress *k)
+static int set_sadb_kmaddress(struct sk_buff *skb, const struct xfrm_kmaddress *k)
 {
 	struct sadb_x_kmaddress *kma;
 	u8 *sa;
@@ -3376,7 +3376,7 @@ static int set_sadb_kmaddress(struct sk_buff *skb, struct xfrm_kmaddress *k)
 static int set_ipsecrequest(struct sk_buff *skb,
 			    uint8_t proto, uint8_t mode, int level,
 			    uint32_t reqid, uint8_t family,
-			    xfrm_address_t *src, xfrm_address_t *dst)
+			    const xfrm_address_t *src, const xfrm_address_t *dst)
 {
 	struct sadb_x_ipsecrequest *rq;
 	u8 *sa;
@@ -3404,9 +3404,9 @@ static int set_ipsecrequest(struct sk_buff *skb,
 #endif
 
 #ifdef CONFIG_NET_KEY_MIGRATE
-static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			      struct xfrm_migrate *m, int num_bundles,
-			      struct xfrm_kmaddress *k)
+static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+			      const struct xfrm_migrate *m, int num_bundles,
+			      const struct xfrm_kmaddress *k)
 {
 	int i;
 	int sasize_sel;
@@ -3415,7 +3415,7 @@ static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
 	struct sadb_x_policy *pol;
-	struct xfrm_migrate *mp;
+	const struct xfrm_migrate *mp;
 
 	if (type != XFRM_POLICY_TYPE_MAIN)
 		return 0;
@@ -3513,9 +3513,9 @@ err:
 	return -EINVAL;
 }
 #else
-static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			      struct xfrm_migrate *m, int num_bundles,
-			      struct xfrm_kmaddress *k)
+static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+			      const struct xfrm_migrate *m, int num_bundles,
+			      const struct xfrm_kmaddress *k)
 {
 	return -ENOPROTOOPT;
 }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7028f06..555bedd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1819,9 +1819,9 @@ void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid)
 EXPORT_SYMBOL(km_policy_expired);
 
 #ifdef CONFIG_XFRM_MIGRATE
-int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-	       struct xfrm_migrate *m, int num_migrate,
-	       struct xfrm_kmaddress *k)
+int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+	       const struct xfrm_migrate *m, int num_migrate,
+	       const struct xfrm_kmaddress *k)
 {
 	int err = -EINVAL;
 	int ret;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2cc9dab..b43c1b1 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1986,7 +1986,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 #endif
 
 #ifdef CONFIG_XFRM_MIGRATE
-static int copy_to_user_migrate(struct xfrm_migrate *m, struct sk_buff *skb)
+static int copy_to_user_migrate(const struct xfrm_migrate *m, struct sk_buff *skb)
 {
 	struct xfrm_user_migrate um;
 
@@ -2004,7 +2004,7 @@ static int copy_to_user_migrate(struct xfrm_migrate *m, struct sk_buff *skb)
 	return nla_put(skb, XFRMA_MIGRATE, sizeof(um), &um);
 }
 
-static int copy_to_user_kmaddress(struct xfrm_kmaddress *k, struct sk_buff *skb)
+static int copy_to_user_kmaddress(const struct xfrm_kmaddress *k, struct sk_buff *skb)
 {
 	struct xfrm_user_kmaddress uk;
 
@@ -2025,11 +2025,11 @@ static inline size_t xfrm_migrate_msgsize(int num_migrate, int with_kma)
 	      + userpolicy_type_attrsize();
 }
 
-static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
-			 int num_migrate, struct xfrm_kmaddress *k,
-			 struct xfrm_selector *sel, u8 dir, u8 type)
+static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
+			 int num_migrate, const struct xfrm_kmaddress *k,
+			 const struct xfrm_selector *sel, u8 dir, u8 type)
 {
-	struct xfrm_migrate *mp;
+	const struct xfrm_migrate *mp;
 	struct xfrm_userpolicy_id *pol_id;
 	struct nlmsghdr *nlh;
 	int i;
@@ -2061,9 +2061,9 @@ nlmsg_failure:
 	return -EMSGSIZE;
 }
 
-static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			     struct xfrm_migrate *m, int num_migrate,
-			     struct xfrm_kmaddress *k)
+static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+			     const struct xfrm_migrate *m, int num_migrate,
+			     const struct xfrm_kmaddress *k)
 {
 	struct net *net = &init_net;
 	struct sk_buff *skb;
@@ -2079,9 +2079,9 @@ static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_MIGRATE, GFP_ATOMIC);
 }
 #else
-static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			     struct xfrm_migrate *m, int num_migrate,
-			     struct xfrm_kmaddress *k)
+static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+			     const struct xfrm_migrate *m, int num_migrate,
+			     const struct xfrm_kmaddress *k)
 {
 	return -ENOPROTOOPT;
 }
-- 
1.7.4.1

