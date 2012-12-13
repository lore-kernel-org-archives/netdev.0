From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: do not check x->km.state
Date: Thu, 13 Dec 2012 17:06:00 +0800
Message-ID: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54088 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab2LMJGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 04:06:05 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so1357919pbc.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 01:06:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

do not check x->km.state, it will be checked by succedent
xfrm_state_check_expire()

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/xfrm6_input.c |    1 -
 net/xfrm/xfrm_input.c  |    4 ----
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..de4babd 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -108,7 +108,6 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		spin_lock(&x->lock);
 
 		if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
-		    likely(x->km.state == XFRM_STATE_VALID) &&
 		    !xfrm_state_check_expire(x)) {
 			spin_unlock(&x->lock);
 			if (x->type->input(x, skb) > 0) {
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ab2bb42..a8fbb09 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -163,10 +163,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp->xvec[skb->sp->len++] = x;
 
 		spin_lock(&x->lock);
-		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
-			goto drop_unlock;
-		}
 
 		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
-- 
1.7.5.4
