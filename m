From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP  encapsulation mode
Date: Fri, 19 Dec 2008 11:00:45 +0100
Message-ID: <1229680846.13159.115.camel@martin>
References: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
	 <1229603816.10402.178.camel@martin>
	 <20081218205406.GA451@gondor.apana.org.au>
	 <20081218.192313.250049404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	sbergman@cc.hut.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:41812 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752592AbYLSKBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 05:01:15 -0500
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id 41BF23078012
	for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 11:00:50 +0100 (CET)
In-Reply-To: <20081218.192313.250049404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm going to revert the change from net-next-2.6 from now

Yes, I'm fine with that.

> 3) Martin can apply the change locally to do testing until we
>    work this stuff out.

I'll do some testing with a modified patch that accepts encapsulated
packets on a non-encapsulating SA, but not vice-versa. This should solve
that specific issue without introducing that (and hopefully no other)
regression.

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 7527940..ffc32f5 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -166,7 +166,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 		}
 
-		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
+		if (x->encap && x->encap->encap_type != encap_type) {
 			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMISMATCH);
 			goto drop_unlock;
 		}
-- 
1.5.6.3




