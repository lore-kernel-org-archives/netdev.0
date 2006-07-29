From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 14/23] [PATCH] [XFRM]: Restrict authentication algorithm only when inbound transformation protocol is IPsec.
Date: Sat, 29 Jul 2006 18:30:38 +0900
Message-ID: <1154165438334-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:25219 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161096AbWG2Jaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:39 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For Mobile IPv6 usage, routing header or destination options header is used and
it doesn't require this compare. It is checked only when IPsec template.
Based on MIPL2 kernel patch.
---
 net/xfrm/xfrm_policy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1663ffa..e3c71b6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -952,7 +952,8 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, st
 		(x->id.spi == tmpl->id.spi || !tmpl->id.spi) &&
 		(x->props.reqid == tmpl->reqid || !tmpl->reqid) &&
 		x->props.mode == tmpl->mode &&
-		(tmpl->aalgos & (1<<x->props.aalgo)) &&
+		((tmpl->aalgos & (1<<x->props.aalgo)) ||
+		 !(xfrm_id_proto_match(tmpl->id.proto, IPSEC_PROTO_ANY))) &&
 		!(x->props.mode != XFRM_MODE_TRANSPORT &&
 		  xfrm_state_addr_cmp(tmpl, x, family));
 }
-- 
1.4.1

