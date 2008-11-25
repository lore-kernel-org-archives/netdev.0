From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 33/53] netns xfrm: policy walking in netns
Date: Tue, 25 Nov 2008 20:27:05 +0300
Message-ID: <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:40948 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401AbYKYRY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:58 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23228eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:57 -0800 (PST)
In-Reply-To: <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h     |    2 +-
 net/key/af_key.c       |    4 ++--
 net/xfrm/xfrm_policy.c |    6 +++---
 net/xfrm/xfrm_user.c   |    2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ec2b7a9..1dc4ff0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1435,7 +1435,7 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
 extern void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
-extern int xfrm_policy_walk(struct xfrm_policy_walk *walk,
+extern int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	int (*func)(struct xfrm_policy *, int, int, void*), void *);
 extern void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index ca26811..a0d8498 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1846,7 +1846,7 @@ static u32 gen_reqid(void)
 		if (reqid == 0)
 			reqid = IPSEC_MANUAL_REQID_MAX+1;
 		xfrm_policy_walk_init(&walk, XFRM_POLICY_TYPE_MAIN);
-		rc = xfrm_policy_walk(&walk, check_reqid, (void*)&reqid);
+		rc = xfrm_policy_walk(&init_net, &walk, check_reqid, (void*)&reqid);
 		xfrm_policy_walk_done(&walk);
 		if (rc != -EEXIST)
 			return reqid;
@@ -2633,7 +2633,7 @@ static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
 
 static int pfkey_dump_sp(struct pfkey_sock *pfk)
 {
-	return xfrm_policy_walk(&pfk->dump.u.policy, dump_sp, (void *) pfk);
+	return xfrm_policy_walk(&init_net, &pfk->dump.u.policy, dump_sp, (void *) pfk);
 }
 
 static void pfkey_dump_sp_done(struct pfkey_sock *pfk)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 96895ef..6165218 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -851,7 +851,7 @@ out:
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
 
-int xfrm_policy_walk(struct xfrm_policy_walk *walk,
+int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 		     int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
@@ -868,10 +868,10 @@ int xfrm_policy_walk(struct xfrm_policy_walk *walk,
 
 	write_lock_bh(&xfrm_policy_lock);
 	if (list_empty(&walk->walk.all))
-		x = list_first_entry(&init_net.xfrm.policy_all, struct xfrm_policy_walk_entry, all);
+		x = list_first_entry(&net->xfrm.policy_all, struct xfrm_policy_walk_entry, all);
 	else
 		x = list_entry(&walk->walk.all, struct xfrm_policy_walk_entry, all);
-	list_for_each_entry_from(x, &init_net.xfrm.policy_all, all) {
+	list_for_each_entry_from(x, &net->xfrm.policy_all, all) {
 		if (x->dead)
 			continue;
 		pol = container_of(x, struct xfrm_policy, walk);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index efd6ab5..f6e0272 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1279,7 +1279,7 @@ static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_policy_walk_init(walk, XFRM_POLICY_TYPE_ANY);
 	}
 
-	(void) xfrm_policy_walk(walk, dump_one_policy, &info);
+	(void) xfrm_policy_walk(&init_net, walk, dump_one_policy, &info);
 
 	return skb->len;
 }
-- 
1.5.6.5

