From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/20] xfrm: Mark flowi arg to xfrm_type->reject() const.
Date: Tue, 22 Feb 2011 19:54:18 -0800 (PST)
Message-ID: <20110222.195418.112618852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756150Ab1BWDxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:42 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 084E624C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    3 ++-
 net/ipv6/mip6.c        |    3 ++-
 net/xfrm/xfrm_policy.c |    2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 614c296..cbe0003 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -334,7 +334,8 @@ struct xfrm_type {
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
-	int			(*reject)(struct xfrm_state *, struct sk_buff *, struct flowi *);
+	int			(*reject)(struct xfrm_state *, struct sk_buff *,
+					  const struct flowi *);
 	int			(*hdr_offset)(struct xfrm_state *, struct sk_buff *, u8 **);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_mtu)(struct xfrm_state *, int size);
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index d6e9599..f3e3ca9 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -203,7 +203,8 @@ static inline int mip6_report_rl_allow(struct timeval *stamp,
 	return allow;
 }
 
-static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb, struct flowi *fl)
+static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
+			       const struct flowi *fl)
 {
 	struct net *net = xs_net(x);
 	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fa0b7f3..ccd47cf 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1907,7 +1907,7 @@ int xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
 EXPORT_SYMBOL(xfrm_lookup);
 
 static inline int
-xfrm_secpath_reject(int idx, struct sk_buff *skb, struct flowi *fl)
+xfrm_secpath_reject(int idx, struct sk_buff *skb, const struct flowi *fl)
 {
 	struct xfrm_state *x;
 
-- 
1.7.4.1

