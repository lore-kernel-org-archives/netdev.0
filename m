From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] xfrm: fix stack access out of bounds with
 CONFIG_XFRM_SUB_POLICY
Date: Mon, 24 Apr 2017 15:59:09 +0800
Message-ID: <20170424075909.GA20194@gondor.apana.org.au>
References: <17208ec89e09ed7223ffd2302abfa3475255c384.1492769294.git.sd@queasysnail.net>
 <20170421110643.GA13809@gondor.apana.org.au>
 <20170421120531.GA12502@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:43704 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1166271AbdDXH7x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:59:53 -0400
Content-Disposition: inline
In-Reply-To: <20170421120531.GA12502@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 02:05:31PM +0200, Sabrina Dubroca wrote:
> 
> You're right. I had a note about that but it got lost.  The bug
> (ignoring what flavor of flowi is passed) is older than that (from the
> introduction of subpolicies, I suspect, but I would have to dig more
> into the history), but this commit removed the last uses of
> origin/partner.
> 
> Looking into raw_sendmsg(), this code may have been safe before
> 9d6ec938019c ("ipv4: Use flowi4 in public route lookup interfaces."),
> since full flowi were used.
> 
> If we want a fix for kernels that don't have ca116922afa8, we would
> probably need to take the size of the flowi* struct depending on the
> address family passed to xfrm_resolve_and_create_bundle().
> 
> 
> I'm not sure how to proceed here, any advice?

I think the Fixes header should simply refer to the commit that
introduced the bug.  You're instead using it as a hint for how
to backport the patch.  That is beyond the scope of the Fixes
header.

So if the bug started with 9d6ec938019c then just use that in
your Fixes header.  If you want to help the backporter with more
information then you can put ca116922afa8 in the body of the commit
description.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
