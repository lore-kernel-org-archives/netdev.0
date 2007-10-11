From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 16:28:45 +0800
Message-ID: <20071011082845.GA16527@gondor.apana.org.au>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com> <20071010.211654.85404234.davem@davemloft.net> <m1r6k2i1es.fsf@ebiederm.dsl.xmission.com> <20071011071224.GA15860@gondor.apana.org.au> <m1hckyf4ag.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2522 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753596AbXJKI3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 04:29:06 -0400
Content-Disposition: inline
In-Reply-To: <m1hckyf4ag.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 02:23:35AM -0600, Eric W. Biederman wrote:
>
> > So I would object to a patch that caused the RTNL_ASSERT to not
> > warn about being called in an atomic context.
> 
> ASSERT_RTNL does not warn about being called in an atomic context
> today!

Well it did didn't it or we wouldn't be having this thread :)
 
> Way way deep in mutex debugging on the slowpath there is a unreadable
> and incomprehensible WARN_ON in muxtex_trylock that will trigger if
> you have 10 tons of debugging turned on, and you are in,
> interrupt context, and you manage to hit the slow path.  I think that
> is a pretty unlikely scenario.

Well thanks to that warning we're on our way of improving the
code that triggered it in such a way that this warning will soon
go silent.

That's precisely the reason why I object to having this warning
removed.  Now you have a good point that this warning doesn't
trigger all the time.  The fix to that is to *make* it trigger
always, not removing it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
