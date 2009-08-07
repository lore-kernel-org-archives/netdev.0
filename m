From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Fri, 7 Aug 2009 10:00:21 +1000
Message-ID: <20090807000021.GA1566@gondor.apana.org.au>
References: <20090803161242.12947.14620.stgit@flek.lan> <200908051738.43134.paul.moore@hp.com> <m1ws5hua4h.fsf@fess.ebiederm.org> <200908061420.20983.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37256 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756614AbZHGAA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 20:00:29 -0400
Content-Disposition: inline
In-Reply-To: <200908061420.20983.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 02:20:20PM -0400, Paul Moore wrote:
>
> The code currently looks something like this:
> 
> 	err = -ENOMEM;
> 	buf = alloc(...);
> 	if (!buf)
> 		goto label;
> 
> This means that in the common case where 'alloc()' completes without error we 
> are doing an extra, unnecessary assignment where we set the value in 'err'.  
> Now, if we change this slightly to match what I proposed in the patch:
> 
> 	buf = alloc(...);
> 	if (!buf) {
> 		err = -ENOMEM;
> 		goto label;
> 	}
> 
> We eliminate that extra assignment in the case where 'alloc()' completes 
> without error, which should result in more efficient code (less instructions 
> in the common case).  Am I wrong?  If that is the case I would appreciate an 
> explanation ...

Your style potentially introduces a second jump which may end
up being worse compared to the extra work on a modern CPU.


Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
