From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: + xfrm_policy-warning-fix.patch added to -mm tree
Date: Fri, 30 Nov 2007 11:02:05 +1100
Message-ID: <20071130000205.GG23769@gondor.apana.org.au>
References: <200711281056.lASAupF5028450@imap1.linux-foundation.org> <20071129135132.GI8487@gondor.apana.org.au> <20071129093202.c638b45a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2647 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755547AbXK3ACS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 19:02:18 -0500
Content-Disposition: inline
In-Reply-To: <20071129093202.c638b45a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 09:32:02AM -0800, Andrew Morton wrote:
>
> > diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> > index b702bd8..9a4cf2e 100644
> > --- a/net/xfrm/xfrm_policy.c
> > +++ b/net/xfrm/xfrm_policy.c
> > @@ -1344,6 +1344,7 @@ restart:
> >  	xfrm_nr += pols[0]->xfrm_nr;
> >  
> >  	switch (policy->action) {
> > +	default:
> >  	case XFRM_POLICY_BLOCK:
> >  		/* Prohibit the flow */
> >  		err = -EPERM;
> 
> hm.  If someone feeds a bad value into here we want to know about it rather
> than silently fixing it up, don't we?

As I said, we already check all policy actions when they enter the kernel
from user-space.  For example, in xfrm_user we make sure that action is
one of these values.  So this is mainly to shut gcc up.

Even if we did somehow get an illegal value through, dropping the packet
sounds like a sane action to follow and I'm sure people will notice pretty
quickly when packets don't flow anymore :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
