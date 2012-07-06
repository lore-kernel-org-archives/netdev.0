From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 2/2] xfrm: Initialize the struct xfrm_dst behind
 the dst_enty field
Date: Fri, 6 Jul 2012 11:39:34 +0200
Message-ID: <20120706093934.GI1869@secunet.com>
References: <20120706093709.GH1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42126 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937Ab2GFJkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 05:40:21 -0400
Content-Disposition: inline
In-Reply-To: <20120706093709.GH1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We start initializing the struct xfrm_dst at the first field
behind the struct dst_enty. This is error prone because it
might leave a new field uninitialized. So start initializing
the struct xfrm_dst right behind the dst_entry.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6e97855..79c498b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1353,8 +1353,9 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	xdst = dst_alloc(dst_ops, NULL, 0, 0, 0);
 
 	if (likely(xdst)) {
-		memset(&xdst->u.rt6.rt6i_table, 0,
-			sizeof(*xdst) - sizeof(struct dst_entry));
+		struct dst_entry *dst = (struct dst_entry *)xdst;
+
+		memset(dst + 1, 0, sizeof(*xdst) - sizeof(*dst));
 		xdst->flo.ops = &xfrm_bundle_fc_ops;
 	} else
 		xdst = ERR_PTR(-ENOBUFS);
-- 
1.7.0.4
