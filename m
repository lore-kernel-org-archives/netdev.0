From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 5/9 net-next] xfrm: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:13 +0200
Message-ID: <1427749998-28464-5-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/xfrm/xfrm_policy.c |  5 ++---
 net/xfrm/xfrm_user.c   | 27 +++++++++------------------
 2 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 638af06..15de248 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -306,9 +306,8 @@ EXPORT_SYMBOL(xfrm_policy_alloc);
 void xfrm_policy_destroy(struct xfrm_policy *policy)
 {
 	BUG_ON(!policy->walk.dead);
-
-	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_timer))
-		BUG();
+	BUG_ON(del_timer(&policy->timer) ||
+	       del_timer(&policy->polq.hold_timer));
 
 	security_xfrm_policy_free(policy->security);
 	kfree(policy);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 7de2ed9..b2ef371 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1081,8 +1081,7 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
-		BUG();
+	BUG_ON(build_spdinfo(r_skb, net, sportid, seq, *flags) < 0);
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
@@ -1139,8 +1138,7 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_sadinfo(r_skb, net, sportid, seq, *flags) < 0)
-		BUG();
+	BUG_ON(build_sadinfo(r_skb, net, sportid, seq, *flags) < 0);
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
@@ -1887,8 +1885,7 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
 
-	if (build_aevent(r_skb, x, &c) < 0)
-		BUG();
+	BUG_ON(build_aevent(r_skb, x, &c) < 0);
 	err = nlmsg_unicast(net->xfrm.nlsk, r_skb, NETLINK_CB(skb).portid);
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
@@ -2305,8 +2302,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		return -ENOMEM;
 
 	/* build migrate */
-	if (build_migrate(skb, m, num_migrate, k, sel, dir, type) < 0)
-		BUG();
+	BUG_ON(build_migrate(skb, m, num_migrate, k, sel, dir, type) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MIGRATE);
 }
@@ -2524,8 +2520,7 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_aevent(skb, x, c) < 0)
-		BUG();
+	BUG_ON(build_aevent(skb, x, c) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_AEVENTS);
 }
@@ -2731,8 +2726,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_acquire(skb, x, xt, xp) < 0)
-		BUG();
+	BUG_ON(build_acquire(skb, x, xt, xp) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_ACQUIRE);
 }
@@ -2846,8 +2840,7 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, c) < 0)
-		BUG();
+	BUG_ON(build_polexpire(skb, xp, dir, c) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
@@ -3006,8 +2999,7 @@ static int xfrm_send_report(struct net *net, u8 proto,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_report(skb, proto, sel, addr) < 0)
-		BUG();
+	BUG_ON(build_report(skb, proto, sel, addr) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_REPORT);
 }
@@ -3059,8 +3051,7 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_mapping(skb, x, ipaddr, sport) < 0)
-		BUG();
+	BUG_ON(build_mapping(skb, x, ipaddr, sport) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MAPPING);
 }
-- 
1.9.1
