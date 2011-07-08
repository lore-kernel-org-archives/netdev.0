From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] XFRM: Fix memory leak in xfrm_state_update
Date: Fri, 8 Jul 2011 11:00:32 +0800
Message-ID: <20110708030032.GA25702@gondor.apana.org.au>
References: <alpine.LFD.1.10.1107071820060.7677@net-test1.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tusharsg@gmail.com
To: Tushar Gohad <tgohad@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:32882 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869Ab1GHDAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 23:00:42 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.1107071820060.7677@net-test1.az.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2011 at 06:38:52PM -0700, Tushar Gohad wrote:
>
> Upon "ip xfrm state update ..", xfrm_add_sa() takes an extra reference on 
> the user-supplied SA and forgets to drop the reference when  
> xfrm_state_update() returns 0.  This leads to a memory leak as the  
> parameter SA is never freed.  This change attempts to fix the leak by  
> calling __xfrm_state_put() when xfrm_state_update() updates a valid SA  
> (err = 0).  The parameter SA is added to the gc list when the final  
> reference is dropped by xfrm_add_sa() upon completion.
>
> Signed-off-by: Tushar Gohad <tgohad@mvista.com>

Ouch, thanks for catching this bug!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
