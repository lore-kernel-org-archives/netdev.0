From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 11633] Kernel panic after patch
	f3994eceebf64cf356a82ffb2718ef538eb8d4f4
Date: Thu, 25 Sep 2008 11:25:54 +0800
Message-ID: <20080925032554.GA16155@gondor.apana.org.au>
References: <20080925011035.GA15055@gondor.apana.org.au> <20080925012105.GA15241@gondor.apana.org.au> <20080925023622.GA15800@gondor.apana.org.au> <20080924.194955.209981542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50281 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752499AbYIYDZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 23:25:57 -0400
Content-Disposition: inline
In-Reply-To: <20080924.194955.209981542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 07:49:55PM -0700, David Miller wrote:
> 
> I'll integrate this when I next get a chance.

Thanks!

Oh and to make it more obvious in future:

net: BUG instead of corrupting memory in pskb_expand_head

If the caller of pskb_expand_head specifies a negative nhead
we'll silently overwrite other people's memory.  This patch
makes it BUG instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ca1ccdf..3fad166 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -701,6 +701,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 #endif
 	long off;
 
+	BUG_ON(nhead < 0);
+
 	if (skb_shared(skb))
 		BUG();
 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
