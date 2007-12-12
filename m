From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] [IPSEC]: Make xfrm_lookup flags argument a bit-field
Date: Wed, 12 Dec 2007 09:57:59 +0800
Message-ID: <E1J2GrH-0005SK-00@gondolin.me.apana.org.au>
References: <20071212012552.GA20618@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4799 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750772AbXLLB6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 20:58:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPSEC]: Make xfrm_lookup flags argument a bit-field

This patch introduces an enum for bits in the flags argument of xfrm_lookup.
This is so that we can cram more information into it later.

Since all current users use just the values 0 and 1, XFRM_LOOKUP_WAIT has
been added with the value 1 << 0 to represent the current meaning of flags.

The test in __xfrm_lookup has been changed accordingly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/dst.h      |    5 +++++
 net/xfrm/xfrm_policy.c |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e86b9a0..aaa2dbb 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -265,6 +265,11 @@ static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 
 extern void		dst_init(void);
 
+/* Flags for xfrm_lookup flags argument. */
+enum {
+	XFRM_LOOKUP_WAIT = 1 << 0,
+};
+
 struct flowi;
 #ifndef CONFIG_XFRM
 static inline int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 39805b4..265c679 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1565,7 +1565,7 @@ restart:
 				xfrm_pol_put(policy);
 				return -EREMOTE;
 			}
-			if (err == -EAGAIN && flags) {
+			if (err == -EAGAIN && (flags & XFRM_LOOKUP_WAIT)) {
 				DECLARE_WAITQUEUE(wait, current);
 
 				add_wait_queue(&km_waitq, &wait);
