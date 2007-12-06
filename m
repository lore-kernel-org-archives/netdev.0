From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch] net/xfrm/xfrm_policy.c: Some small improvements
Date: Thu, 6 Dec 2007 19:01:23 +0800
Message-ID: <20071206110123.GB2469@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ro-out-1112.google.com ([72.14.202.182]:3462 "EHLO
	ro-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbXLFLFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 06:05:33 -0500
Received: by ro-out-1112.google.com with SMTP id p4so6578072roc
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 03:05:32 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch contains the following changes.

	- Use 'bool' instead of 'int' for booleans.
	- Use 'size_t' instead of 'int' for 'sizeof' return value.
	- Some style fixes.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---
 net/xfrm/xfrm_policy.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5d6a81d..311b08f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -476,17 +476,17 @@ static u32 xfrm_gen_index(u8 type, int dir)
 		struct hlist_head *list;
 		struct xfrm_policy *p;
 		u32 idx;
-		int found;
+		bool found;
 
 		idx = (idx_generator | dir);
 		idx_generator += 8;
 		if (idx == 0)
 			idx = 8;
 		list = xfrm_policy_byidx + idx_hash(idx);
-		found = 0;
+		found = false;
 		hlist_for_each_entry(p, entry, list, byidx) {
 			if (p->index == idx) {
-				found = 1;
+				found = true;
 				break;
 			}
 		}
@@ -499,8 +499,8 @@ static inline int selector_cmp(struct xfrm_selector *s1, struct xfrm_selector *s
 {
 	u32 *p1 = (u32 *) s1;
 	u32 *p2 = (u32 *) s2;
-	int len = sizeof(struct xfrm_selector) / sizeof(u32);
-	int i;
+	size_t len = sizeof(struct xfrm_selector) / sizeof(u32);
+	size_t i;
 
 	for (i = 0; i < len; i++) {
 		if (p1[i] != p2[i])
@@ -953,7 +953,7 @@ static int xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
 #ifdef CONFIG_XFRM_SUB_POLICY
 end:
 #endif
-	if ((*objp = (void *) pol) != NULL)
+	if ((*objp = pol) != NULL)
 		*obj_refp = &pol->refcnt;
 	return err;
 }
@@ -1137,7 +1137,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
 	xfrm_address_t *saddr = xfrm_flowi_saddr(fl, family);
 	xfrm_address_t tmp;
 
-	for (nx=0, i = 0; i < policy->xfrm_nr; i++) {
+	for (nx = 0, i = 0; i < policy->xfrm_nr; i++) {
 		struct xfrm_state *x;
 		xfrm_address_t *remote = daddr;
 		xfrm_address_t *local  = saddr;
@@ -1395,7 +1395,7 @@ free_dst:
 }
 
 static int inline
-xfrm_dst_alloc_copy(void **target, void *src, int size)
+xfrm_dst_alloc_copy(void **target, void *src, size_t size)
 {
 	if (!*target) {
 		*target = kmalloc(size, GFP_ATOMIC);
@@ -1554,7 +1554,7 @@ restart:
 #endif
 		nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
-		if (unlikely(nx<0)) {
+		if (unlikely(nx < 0)) {
 			err = nx;
 			if (err == -EAGAIN && sysctl_xfrm_larval_drop) {
 				/* EREMOTE tells the caller to generate
@@ -1688,7 +1688,8 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, struct xfrm_state *x,
 	      unsigned short family)
 {
 	if (xfrm_state_kern(x))
-		return tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, tmpl->encap_family);
+		return tmpl->optional &&
+			!xfrm_state_addr_cmp(tmpl, x, tmpl->encap_family);
 	return	x->id.proto == tmpl->id.proto &&
 		(x->id.spi == tmpl->id.spi || !tmpl->id.spi) &&
 		(x->props.reqid == tmpl->reqid || !tmpl->reqid) &&
@@ -1777,7 +1778,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	if (skb->sp) {
 		int i;
 
-		for (i=skb->sp->len-1; i>=0; i--) {
+		for (i = skb->sp->len-1; i >= 0; i--) {
 			struct xfrm_state *x = skb->sp->xvec[i];
 			if (!xfrm_selector_match(&x->sel, &fl, family))
 				return 0;
