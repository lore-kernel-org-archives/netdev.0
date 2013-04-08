From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 17:09:32 -0400
Message-ID: <6182509.cOVcY8B4g7@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <3294227.D2rod7xgQB@sifl> <1365454501.3887.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964875Ab3DHVJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 17:09:35 -0400
In-Reply-To: <1365454501.3887.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 01:55:01 PM Eric Dumazet wrote:
> On Mon, 2013-04-08 at 16:37 -0400, Paul Moore wrote:
> > The people who use this functionality almost never use upstream kernels,
> > they need to protection/certification/warm-fuzzies/etc. that come from a
> > distribution kernel and a support infrastructure.  I didn't catch it
> > because I use a slightly different configuration that didn't expose this
> > bug; while I would like to run a full regression test every release I
> > simply don't have the time to do that myself.
> > 
> > > This sounds like a very small issue to me, a revert is simply overkill.
> > 
> > It all depends on your use case.  To you, whom I assume doesn't use
> > SELinux, it is indeed a trivial issue.  To someone who relies on SELinux
> > for its network access controls this is a pretty significant issue.
> 
> Is the patch I sent addressing the problem or not ?
> 
> Note that I do have : CONFIG_SECURITY=y
> 
> So this patch basically adds the overhead back, and I'll have to use
> real hook later in net-next.

Please repost the patch to the LSM list, it needs to be discussed there.

> At least my patch clearly _shows_ the security requirement, instead of
> relying on a side effect of a previous sock_wmalloc()

I don't see it as a side effect, and as far as demonstration, I think the 
SELinux network access controls in their entirety shows the security 
requirement.  If we want to make the security requirements even more explicit 
in the networking stack, let's add a security blob to the sk_buff and allow 
some proper LSM hooks.

> Again, it would be nice you understand the plan.

I have no idea what the above sentence is trying to say.

-- 
paul moore
security and virtualization @ redhat
