From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: xfrm_user: use BUG_ON instead of if condition followed
 by BUG
Date: Mon, 23 Oct 2017 13:18:57 -0500
Message-ID: <20171023181857.GA25379@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/xfrm/xfrm_user.c | 28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 465f3ec..9e8851f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1152,8 +1152,7 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
-		BUG();
+	BUG_ON(build_spdinfo(r_skb, net, sportid, seq, *flags) < 0);
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
@@ -1210,8 +1209,7 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_sadinfo(r_skb, net, sportid, seq, *flags) < 0)
-		BUG();
+	BUG_ON(build_sadinfo(r_skb, net, sportid, seq, *flags) < 0);
 
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
@@ -1958,8 +1956,8 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
 
-	if (build_aevent(r_skb, x, &c) < 0)
-		BUG();
+	BUG_ON(build_aevent(r_skb, x, &c) < 0);
+
 	err = nlmsg_unicast(net->xfrm.nlsk, r_skb, NETLINK_CB(skb).portid);
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
@@ -2393,8 +2391,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		return -ENOMEM;
 
 	/* build migrate */
-	if (build_migrate(skb, m, num_migrate, k, sel, encap, dir, type) < 0)
-		BUG();
+	BUG_ON(build_migrate(skb, m, num_migrate, k, sel, encap, dir, type) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MIGRATE);
 }
@@ -2623,8 +2620,7 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_aevent(skb, x, c) < 0)
-		BUG();
+	BUG_ON(build_aevent(skb, x, c) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_AEVENTS);
 }
@@ -2836,8 +2832,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_acquire(skb, x, xt, xp) < 0)
-		BUG();
+	BUG_ON(build_acquire(skb, x, xt, xp) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_ACQUIRE);
 }
@@ -2951,8 +2946,7 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, c) < 0)
-		BUG();
+	BUG_ON(build_polexpire(skb, xp, dir, c) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
@@ -3112,8 +3106,7 @@ static int xfrm_send_report(struct net *net, u8 proto,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_report(skb, proto, sel, addr) < 0)
-		BUG();
+	BUG_ON(build_report(skb, proto, sel, addr) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_REPORT);
 }
@@ -3165,8 +3158,7 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_mapping(skb, x, ipaddr, sport) < 0)
-		BUG();
+	BUG_ON(build_mapping(skb, x, ipaddr, sport) < 0);
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MAPPING);
 }
-- 
2.7.4
