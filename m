From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 6 Aug 2009 23:37:46 +1000
Message-ID: <20090806133746.GA28557@gondor.apana.org.au>
References: <20090803161242.12947.14620.stgit@flek.lan> <m1ljlyvn9a.fsf@fess.ebiederm.org> <200908051738.43134.paul.moore@hp.com> <20090806101044.GA26589@gondor.apana.org.au> <m1hbwlkzt6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50654 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755430AbZHFNhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 09:37:53 -0400
Content-Disposition: inline
In-Reply-To: <m1hbwlkzt6.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 03:21:41AM -0700, Eric W. Biederman wrote:
>
> Two threads one file descriptor.  Both simultaneously attempt to 
> attach to a tun device.  One will fail, the other succeed.
> 
> At least that is how I read the locking.

Yes but the "race" fixed by this patch is centred on the tun_attach
call for a newly created network device.  As tun_set_iff occurs
under RTNL, the second thread cannot start attaching until the
creation thread has completed.  IOW the thread that creates the
net device should always succeed in attaching.

If two threads try to attach to the same device that was already
created then yes one will fail and the other succeed.  However,
AFAICS that case has nothing to do with this patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
