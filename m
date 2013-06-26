From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 1/2] xfrm: constify mark argument of xfrm_find_acq()
Date: Wed, 26 Jun 2013 23:56:58 +0200
Message-ID: <1372283819-30012-2-git-send-email-minipli@googlemail.com>
References: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:50503 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab3FZV5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 17:57:12 -0400
Received: by mail-bk0-f51.google.com with SMTP id ji1so5168065bkc.38
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 14:57:11 -0700 (PDT)
In-Reply-To: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mark argument is read only, so constify it. Also make dummy_mark in
af_key const -- only used as dummy argument for this very function.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/net/xfrm.h    |    2 +-
 net/key/af_key.c      |    2 +-
 net/xfrm/xfrm_state.c |   12 +++++++-----
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..89d3d8a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1548,7 +1548,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir, u32
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
-struct xfrm_state *xfrm_find_acq(struct net *net, struct xfrm_mark *mark,
+struct xfrm_state *xfrm_find_acq(struct net *net, const struct xfrm_mark *mark,
 				 u8 mode, u32 reqid, u8 proto,
 				 const xfrm_address_t *daddr,
 				 const xfrm_address_t *saddr, int create,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index c5fbd75..5490d97 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -45,7 +45,7 @@ struct netns_pfkey {
 static DEFINE_MUTEX(pfkey_mutex);
 
 #define DUMMY_MARK 0
-static struct xfrm_mark dummy_mark = {0, 0};
+static const struct xfrm_mark dummy_mark = {0, 0};
 struct pfkey_sock {
 	/* struct sock must be the first member of struct pfkey_sock */
 	struct sock	sk;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..b2cd806 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -990,11 +990,13 @@ void xfrm_state_insert(struct xfrm_state *x)
 EXPORT_SYMBOL(xfrm_state_insert);
 
 /* xfrm_state_lock is held */
-static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
+static struct xfrm_state *__find_acq_core(struct net *net,
+					  const struct xfrm_mark *m,
 					  unsigned short family, u8 mode,
 					  u32 reqid, u8 proto,
 					  const xfrm_address_t *daddr,
-					  const xfrm_address_t *saddr, int create)
+					  const xfrm_address_t *saddr,
+					  int create)
 {
 	unsigned int h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
 	struct xfrm_state *x;
@@ -1399,9 +1401,9 @@ xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 EXPORT_SYMBOL(xfrm_state_lookup_byaddr);
 
 struct xfrm_state *
-xfrm_find_acq(struct net *net, struct xfrm_mark *mark, u8 mode, u32 reqid, u8 proto,
-	      const xfrm_address_t *daddr, const xfrm_address_t *saddr,
-	      int create, unsigned short family)
+xfrm_find_acq(struct net *net, const struct xfrm_mark *mark, u8 mode, u32 reqid,
+	      u8 proto, const xfrm_address_t *daddr,
+	      const xfrm_address_t *saddr, int create, unsigned short family)
 {
 	struct xfrm_state *x;
 
-- 
1.7.10.4
