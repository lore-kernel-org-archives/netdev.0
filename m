From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 11/44] [XFRM]: Rename secpath_has_tunnel to secpath_has_nontransport.
Date: Thu, 24 Aug 2006 00:02:12 +0900
Message-ID: <11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:63368 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964924AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

On current kernel inbound transformation state is allowed transport and
disallowed tunnel mode when mismatch is occurred between tempates and states.
As the result of adding two more modes by Mobile IPv6, this function name
is misleading. Inbound transformation can allow only transport mode
when mismatch is occurred between template and secpath.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/xfrm_policy.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 66cd501..f91cf69 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1046,7 +1046,7 @@ xfrm_decode_session(struct sk_buff *skb,
 }
 EXPORT_SYMBOL(xfrm_decode_session);
 
-static inline int secpath_has_tunnel(struct sec_path *sp, int k)
+static inline int secpath_has_nontransport(struct sec_path *sp, int k)
 {
 	for (; k < sp->len; k++) {
 		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT)
@@ -1087,7 +1087,7 @@ int __xfrm_policy_check(struct sock *sk,
 					xfrm_policy_lookup);
 
 	if (!pol)
-		return !skb->sp || !secpath_has_tunnel(skb->sp, 0);
+		return !skb->sp || !secpath_has_nontransport(skb->sp, 0);
 
 	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
 
@@ -1111,7 +1111,7 @@ int __xfrm_policy_check(struct sock *sk,
 				goto reject;
 		}
 
-		if (secpath_has_tunnel(sp, k))
+		if (secpath_has_nontransport(sp, k))
 			goto reject;
 
 		xfrm_pol_put(pol);
-- 
1.4.0

