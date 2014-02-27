From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] xfrm: Fix unlink race when policies are deleted.
Date: Thu, 27 Feb 2014 15:01:20 +0800
Message-ID: <20140227070120.GA31520@gondor.apana.org.au>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
 <1393481799-20492-6-git-send-email-steffen.klassert@secunet.com>
 <20140227062712.GA31082@gondor.apana.org.au>
 <20140227063015.GA31204@gondor.apana.org.au>
 <20140227065353.GM32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40514 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaB0HB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 02:01:26 -0500
Content-Disposition: inline
In-Reply-To: <20140227065353.GM32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 07:53:53AM +0100, Steffen Klassert wrote:
> On Thu, Feb 27, 2014 at 02:30:15PM +0800, Herbert Xu wrote:
> > On Thu, Feb 27, 2014 at 02:27:12PM +0800, Herbert Xu wrote:
> > > On Thu, Feb 27, 2014 at 07:16:39AM +0100, Steffen Klassert wrote:
> > > > When a policy is unlinked from the lists in thread context,
> > > > the xfrm timer can fire before we can mark this policy as dead.
> > > > So reinitialize the bydst hlist, then hlist_unhashed() will
> > > > notice that this policy is not linked and will avoid a
> > > > doulble unlink of that policy.
> > > > 
> > > > Reported-by: Xianpeng Zhao <673321875@qq.com>
> > > > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > > 
> > > If this race condition is real then I don't see how this fix
> > > can be correct since there aren't any barriers between the check
> > > and the unlink.
> > 
> > Looking at the code it seems that we've already taken the policy
> > lock so how can this race occur?
> 
> We take the policy lock in xfrm_policy_delete() before we
> unlink the policy. But we release it before we mark the
> policy as dead with xfrm_policy_kill(). If the timer fires
> in the meantime it can be unlinked from the timer first
> and then again from xfrm_policy_delete().
> 
> This issue was originally reported here:
> https://bugzilla.kernel.org/show_bug.cgi?id=70471

Right, I see what you mean.

Thanks for the explanation!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
