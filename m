From: David Miller <davem@davemloft.net>
Subject: [PATCH 01/26] xfrm: Pass km_event pointers around as const when
 possible.
Date: Wed, 23 Feb 2011 23:13:00 -0800 (PST)
Message-ID: <20110223.231300.71116318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755779Ab1BXHMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:24 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0F79724C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h    |    8 ++++----
 net/key/af_key.c      |   16 ++++++++--------
 net/xfrm/xfrm_state.c |    4 ++--
 net/xfrm/xfrm_user.c  |   24 ++++++++++++------------
 4 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bb824a5..6ef5c37 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -284,8 +284,8 @@ struct xfrm_policy_afinfo {
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
 extern int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
-extern void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c);
-extern void km_state_notify(struct xfrm_state *x, struct km_event *c);
+extern void km_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c);
+extern void km_state_notify(struct xfrm_state *x, const struct km_event *c);
 
 struct xfrm_tmpl;
 extern int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
@@ -548,11 +548,11 @@ struct xfrm_migrate {
 struct xfrm_mgr {
 	struct list_head	list;
 	char			*id;
-	int			(*notify)(struct xfrm_state *x, struct km_event *c);
+	int			(*notify)(struct xfrm_state *x, const struct km_event *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
-	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
+	int			(*notify_policy)(struct xfrm_policy *x, int dir, const struct km_event *c);
 	int			(*report)(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles, struct xfrm_kmaddress *k);
 };
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 60fd2f1..7c5e101 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1429,7 +1429,7 @@ static inline int event2keytype(int event)
 }
 
 /* ADD/UPD/DEL */
-static int key_notify_sa(struct xfrm_state *x, struct km_event *c)
+static int key_notify_sa(struct xfrm_state *x, const struct km_event *c)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
@@ -1688,7 +1688,7 @@ static int unicast_flush_resp(struct sock *sk, struct sadb_msg *ihdr)
 	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ONE, sk, sock_net(sk));
 }
 
-static int key_notify_sa_flush(struct km_event *c)
+static int key_notify_sa_flush(const struct km_event *c)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
@@ -2123,7 +2123,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	return 0;
 }
 
-static int key_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
+static int key_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
@@ -2660,7 +2660,7 @@ static int pfkey_spddump(struct sock *sk, struct sk_buff *skb, struct sadb_msg *
 	return pfkey_do_dump(pfk);
 }
 
-static int key_notify_policy_flush(struct km_event *c)
+static int key_notify_policy_flush(const struct km_event *c)
 {
 	struct sk_buff *skb_out;
 	struct sadb_msg *hdr;
@@ -2914,12 +2914,12 @@ static void dump_esp_combs(struct sk_buff *skb, struct xfrm_tmpl *t)
 	}
 }
 
-static int key_notify_policy_expire(struct xfrm_policy *xp, struct km_event *c)
+static int key_notify_policy_expire(struct xfrm_policy *xp, const struct km_event *c)
 {
 	return 0;
 }
 
-static int key_notify_sa_expire(struct xfrm_state *x, struct km_event *c)
+static int key_notify_sa_expire(struct xfrm_state *x, const struct km_event *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
@@ -2949,7 +2949,7 @@ static int key_notify_sa_expire(struct xfrm_state *x, struct km_event *c)
 	return 0;
 }
 
-static int pfkey_send_notify(struct xfrm_state *x, struct km_event *c)
+static int pfkey_send_notify(struct xfrm_state *x, const struct km_event *c)
 {
 	struct net *net = x ? xs_net(x) : c->net;
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
@@ -2976,7 +2976,7 @@ static int pfkey_send_notify(struct xfrm_state *x, struct km_event *c)
 	return 0;
 }
 
-static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
+static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 	if (xp && xp->type != XFRM_POLICY_TYPE_MAIN)
 		return 0;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 30a0f17..7028f06 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1727,7 +1727,7 @@ void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
 static LIST_HEAD(xfrm_km_list);
 static DEFINE_RWLOCK(xfrm_km_lock);
 
-void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
+void km_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 	struct xfrm_mgr *km;
 
@@ -1738,7 +1738,7 @@ void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 	read_unlock(&xfrm_km_lock);
 }
 
-void km_state_notify(struct xfrm_state *x, struct km_event *c)
+void km_state_notify(struct xfrm_state *x, const struct km_event *c)
 {
 	struct xfrm_mgr *km;
 	read_lock(&xfrm_km_lock);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 6129196..2cc9dab 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1582,7 +1582,7 @@ static inline size_t xfrm_aevent_msgsize(void)
 	       + nla_total_size(4); /* XFRM_AE_ETHR */
 }
 
-static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, struct km_event *c)
+static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct km_event *c)
 {
 	struct xfrm_aevent_id *id;
 	struct nlmsghdr *nlh;
@@ -2220,7 +2220,7 @@ static inline size_t xfrm_expire_msgsize(void)
 	       + nla_total_size(sizeof(struct xfrm_mark));
 }
 
-static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_event *c)
+static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct km_event *c)
 {
 	struct xfrm_user_expire *ue;
 	struct nlmsghdr *nlh;
@@ -2242,7 +2242,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
+static int xfrm_exp_state_notify(struct xfrm_state *x, const struct km_event *c)
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
@@ -2259,7 +2259,7 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
-static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
+static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event *c)
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
@@ -2274,7 +2274,7 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_AEVENTS, GFP_ATOMIC);
 }
 
-static int xfrm_notify_sa_flush(struct km_event *c)
+static int xfrm_notify_sa_flush(const struct km_event *c)
 {
 	struct net *net = c->net;
 	struct xfrm_usersa_flush *p;
@@ -2330,7 +2330,7 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 	return l;
 }
 
-static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
+static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 {
 	struct net *net = xs_net(x);
 	struct xfrm_usersa_info *p;
@@ -2387,7 +2387,7 @@ nla_put_failure:
 	return -1;
 }
 
-static int xfrm_send_state_notify(struct xfrm_state *x, struct km_event *c)
+static int xfrm_send_state_notify(struct xfrm_state *x, const struct km_event *c)
 {
 
 	switch (c->event) {
@@ -2546,7 +2546,7 @@ static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
 }
 
 static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
-			   int dir, struct km_event *c)
+			   int dir, const struct km_event *c)
 {
 	struct xfrm_user_polexpire *upe;
 	struct nlmsghdr *nlh;
@@ -2576,7 +2576,7 @@ nlmsg_failure:
 	return -EMSGSIZE;
 }
 
-static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
+static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 	struct net *net = xp_net(xp);
 	struct sk_buff *skb;
@@ -2591,7 +2591,7 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_eve
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
-static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
+static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 	struct net *net = xp_net(xp);
 	struct xfrm_userpolicy_info *p;
@@ -2656,7 +2656,7 @@ nlmsg_failure:
 	return -1;
 }
 
-static int xfrm_notify_policy_flush(struct km_event *c)
+static int xfrm_notify_policy_flush(const struct km_event *c)
 {
 	struct net *net = c->net;
 	struct nlmsghdr *nlh;
@@ -2681,7 +2681,7 @@ nlmsg_failure:
 	return -1;
 }
 
-static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
+static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 
 	switch (c->event) {
-- 
1.7.4.1

