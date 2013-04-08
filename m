From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 16:37:22 -0400
Message-ID: <3294227.D2rod7xgQB@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <1365445303.3887.33.camel@edumazet-glaptop> <1365445825.3887.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936032Ab3DHUh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 16:37:26 -0400
In-Reply-To: <1365445825.3887.35.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 11:30:25 AM Eric Dumazet wrote:
> On Mon, 2013-04-08 at 11:21 -0700, Eric Dumazet wrote:
> > On Mon, 2013-04-08 at 14:12 -0400, Paul Moore wrote:
> > > It seems a bit fragile to me, perhaps even hacky, but in some ways I
> > > guess it isn't anymore fragile than relying on skb->sk - as this
> > > problem demonstrates. My other concern is that adding this hook
> > > *correctly* is likely to touch a lot of files and may be a bit much so
> > > late in the 3.9 cycle, Dave, what say you?> 
> > I don't get it, 90ba9b1986b5ac4b2d18 was in 3.6, why do you care of
> > 3.9 ?
> > 
> > I am preparing a fix right now. Not a revert, thank you.
> 
> Is the following patch not good enough ?

I think it is somewhat telling that the hook you're proposing doesn't ever 
make any calls into any of the individual LSMs, it only calls back into the 
networking stack.  In my mind, this makes it an abuse of the LSM mechanism.

On Monday, April 08, 2013 11:34:11 AM Eric Dumazet wrote:
> On Mon, 2013-04-08 at 14:26 -0400, Paul Moore wrote:
> > I guess we'll have to wait and see then; the more I think about the new
> > hook you proposed the less enthused I am about it.
> > 
> > I'm still curious to hear what Dave has to say on this.
> 
> 90ba9b1986b5ac4b2 is 10 months old, and nobody complained until today ?

The people who use this functionality almost never use upstream kernels, they 
need to protection/certification/warm-fuzzies/etc. that come from a 
distribution kernel and a support infrastructure.  I didn't catch it because I 
use a slightly different configuration that didn't expose this bug; while I 
would like to run a full regression test every release I simply don't have the 
time to do that myself.

> This sounds like a very small issue to me, a revert is simply overkill.

It all depends on your use case.  To you, whom I assume doesn't use SELinux, 
it is indeed a trivial issue.  To someone who relies on SELinux for its 
network access controls this is a pretty significant issue.

-- 
paul moore
security and virtualization @ redhat
