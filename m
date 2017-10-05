From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Thu, 5 Oct 2017 18:16:20 +0800
Message-ID: <20171005101620.GA1246@gondor.apana.org.au>
References: <20171003052643.GB22750@gondor.apana.org.au>
 <20171003224505.GE19750@localhost.localdomain>
 <20171005034054.GB31996@gondor.apana.org.au>
 <20171004.213758.2210486785503998906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.leitner@gmail.com, luto@kernel.org, baijiaju1990@163.com,
        nhorman@tuxdriver.com, vyasevich@gmail.com, kvalo@codeaurora.org,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:50520 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751400AbdJEKQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:16:59 -0400
Content-Disposition: inline
In-Reply-To: <20171004.213758.2210486785503998906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 09:37:58PM -0700, David Miller wrote:
>
> > I'm not talking about the code-path in question.  I'm talking
> > about the function which generates the secret key in the first
> > place.  AFAICS that's only called in GFP_KERNEL context.  What
> > am I missing?
> 
> The setkey happens in functions like sctp_pack_cookie() and
> sctp_unpack_cookie(), which seems to run from software interrupts.

That was my point.  Functions like sctp_pack_cookie shouldn't be
setting the key in the first place.  The setkey should happen at
the point when the key is generated.  That's sctp_endpoint_init
which AFAICS only gets called in GFP_KERNEL context.

Or is there a code-path where sctp_endpoint_init is called in
softirq context?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
