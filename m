From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 21:52:04 +0100
Message-ID: <20141030205204.GE10069@breakpoint.cc>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
 <20141028.165737.2009356944765978630.davem@davemloft.net>
 <20141029122307.GA29253@breakpoint.cc>
 <20141030.155958.156984068627586090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39370 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933938AbaJ3UwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:52:07 -0400
Content-Disposition: inline
In-Reply-To: <20141030.155958.156984068627586090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Wed, 29 Oct 2014 13:23:07 +0100
> 
> > We could do that, if you prefer.
> > 
> > I tried to come up with a scenario though, where sysctl_tcp_ecn=0, and
> > then we want to enable 'passive' ecn for incoming connections only on
> > a particular route without announcing ecn to the peer. I haven't been
> > able to find any -- I think if you deem 'route to x' safe for ecn it
> > might as well be enabled for both initiator and responder.  The original
> > patch would be sufficient for that.
> > 
> > IOW, is 'ecn from a to b but not b to a' a sensible requirement?
> 
> I think you have to apply the same logic for the sysctl (there's a
> reason to only support ECN passively) as you do for the route feature
> because you can logically look at the sysctl as applying to the
> default route.

Agreed, sysctl is comparable to default route.
And I think 'passive ecn' makes perfect sense for a default route.

But for a specific host/network?

Either I know that path to $x is ecn-safe (i.e. turn it on for both ends)
or I don't, in which case the global 'passive' default ("if peer requests
it they probably know what they're doing") is fine.

> > default at one point (almost no routers set CE bit at this time, perhaps
> > that would change if ecn usage is more widespread).
> 
> Now you're talking.
> 
> So, either passive ECN support makes sense or it does not.  To me, no
> matter what the argument, it doesn't matter what realm (whole system,
> specific routes) you apply that argument to.

The passive mode was added 5 years ago via

commit 255cac91c3c9ce7dca7713b93ab03c75b7902e0e
(tcp: extend ECN sysctl to allow server-side only ECN), and I think the
commit log rationale makes sense.

So, what about changing the default to 1 in net-next?

We could add automatic 'no-ecn' to retransmitted syns to avoid
ecn blackholes (Daniel Borkmann has a patch for this), and, in case
ecn=1 causes too much breakage we can always revert (and re-consider ecn
per route settings as an intermediate step).

What do you think?

Thanks,
Florian
