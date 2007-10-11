From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 15:12:24 +0800
Message-ID: <20071011071224.GA15860@gondor.apana.org.au>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com> <20071010.211654.85404234.davem@davemloft.net> <m1r6k2i1es.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2124 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753926AbXJKHMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 03:12:44 -0400
Content-Disposition: inline
In-Reply-To: <m1r6k2i1es.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 12:57:31AM -0600, Eric W. Biederman wrote:
>
> There was a practical suggestion by Herbert that ASSERT_RTNL have a
> might_sleep() added.  That suggestion will currently result in
> ASSERT_RTNL firing unnecessarily from the macvlan_open code path.

As I've already said we should change the macvlan and core
netdev code so that this doesn't happen in the first place.
In gernal checking for the RTNL while holding a spin lock is
a sign of a bug.

So I would object to a patch that caused the RTNL_ASSERT to not
warn about being called in an atomic context.

I don't have a problem with your patch per se, it's the fact
that the patch is removing the warning when it's called in an
atomic context that I don't like.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
