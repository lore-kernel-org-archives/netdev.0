From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 9/44] [XFRM]: Restrict authentication algorithm only when inbound transformation protocol is IPsec.
Date: Thu, 24 Aug 2006 00:02:10 +0900
Message-ID: <11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:62856 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964919AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

For Mobile IPv6 usage, routing header or destination options header is used and
it doesn't require this comparison. It is checked only for IPsec template.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/xfrm_policy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index dd8e543..66cd501 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1004,7 +1004,8 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, st
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
1.4.0

