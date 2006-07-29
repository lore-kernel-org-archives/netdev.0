From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 16/23] [PATCH] [XFRM]: Rename secpath_has_tunnel to secpath_has_nontransport.
Date: Sat, 29 Jul 2006 18:30:42 +0900
Message-ID: <11541654423790-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:27267 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161054AbWG2Jan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:43 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On current kernel inbound transformation state is allowed transport and
disallowed tunnel mode when mismatch is occurred between tempates and states.
As the result of adding two more modes by Mobile IPv6, this function name
is misleading. Inbound transformation can allow only transport mode
when mismatch is occurred between template and secpath.

Based on MIPL2 kernel patch.
---
 net/xfrm/xfrm_policy.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e3c71b6..7368f8a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1002,7 +1002,7 @@ xfrm_decode_session(struct sk_buff *skb,
 }
 EXPORT_SYMBOL(xfrm_decode_session);
 
-static inline int secpath_has_tunnel(struct sec_path *sp, int k, int *idxp)
+static inline int secpath_has_nontransport(struct sec_path *sp, int k, int *idxp)
 {
 	for (; k < sp->len; k++) {
 		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT) {
@@ -1055,7 +1055,7 @@ #endif
 					xfrm_policy_lookup);
 
 	if (!pol) {
-		if (skb->sp && secpath_has_tunnel(skb->sp, 0, xerr_idxp)) {
+		if (skb->sp && secpath_has_nontransport(skb->sp, 0, xerr_idxp)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
 			return 0;
 		}
@@ -1087,7 +1087,7 @@ #endif
 			}
 		}
 
-		if (secpath_has_tunnel(sp, k, xerr_idxp))
+		if (secpath_has_nontransport(sp, k, xerr_idxp))
 			goto reject;
 
 		xfrm_pol_put(pol);
-- 
1.4.1

