From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] xfrm4: strip ECN bits from tos field
Date: Wed, 22 Sep 2010 18:45:11 +0200
Message-ID: <20100922164511.GA10963@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-39.dex002.intermedia.net ([64.78.21.124]:20176 "EHLO
	dhost002-39.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752362Ab0IVQpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 12:45:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

otherwise ECT(1) bit will get interpreted as RTO_ONLINK
and routing will fail with XfrmOutBundleGenError.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 net/ipv4/xfrm4_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 869078d..a580349 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -61,7 +61,7 @@ static int xfrm4_get_saddr(struct net *net,
 
 static int xfrm4_get_tos(struct flowi *fl)
 {
-	return fl->fl4_tos;
+	return IPTOS_RT_MASK & fl->fl4_tos; /* Strip ECN bits */
 }
 
 static int xfrm4_init_path(struct xfrm_dst *path, struct dst_entry *dst,
-- 
1.7.0.4

