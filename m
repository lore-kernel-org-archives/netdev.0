From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 1/2] net: check return value for dst_alloc
Date: Mon, 26 Sep 2011 20:04:36 +0300
Message-ID: <1317056676-23584-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<timo.teras@iki.fi>, Madalin Bucur <madalin.bucur@freescale.com>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:13530
	"EHLO AM1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198Ab1IZRDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:03:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

return value of dst_alloc must be checked before use

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 net/xfrm/xfrm_policy.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 94fdcc7..552df27 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1349,14 +1349,16 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 		BUG();
 	}
 	xdst = dst_alloc(dst_ops, NULL, 0, 0, 0);
-	memset(&xdst->u.rt6.rt6i_table, 0, sizeof(*xdst) - sizeof(struct dst_entry));
-	xfrm_policy_put_afinfo(afinfo);
 
-	if (likely(xdst))
+	if (likely(xdst)) {
+		memset(&xdst->u.rt6.rt6i_table, 0,
+			sizeof(*xdst) - sizeof(struct dst_entry));
 		xdst->flo.ops = &xfrm_bundle_fc_ops;
-	else
+	} else
 		xdst = ERR_PTR(-ENOBUFS);
 
+	xfrm_policy_put_afinfo(afinfo);
+
 	return xdst;
 }
 
-- 
1.7.0.1
