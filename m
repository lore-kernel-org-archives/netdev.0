From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] [IPSEC]: Remove gratuitous km wake-up events on ACQUIRE
Date: Tue, 09 Oct 2007 22:36:33 +0800
Message-ID: <E1IfGCH-0005Lx-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4989 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753006AbXJIOgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Remove gratuitous km wake-up events on ACQUIRE

There is no point in waking people up when creating/updating larval states
because they'll just go back to sleep again as larval states by definition
cannot be found by xfrm_state_find.

We should only wake them up when the larvals mature or die.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_state.c |    2 --
 1 files changed, 2 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a00745a..0d07f6b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -848,7 +848,6 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
-		wake_up(&km_waitq);
 
 		xfrm_state_num++;
 
@@ -1311,7 +1310,6 @@ xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi)
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 		spin_unlock_bh(&xfrm_state_lock);
-		wake_up(&km_waitq);
 	}
 }
 EXPORT_SYMBOL(xfrm_alloc_spi);
