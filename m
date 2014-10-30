From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 15:59:58 -0400 (EDT)
Message-ID: <20141030.155958.156984068627586090.davem@davemloft.net>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
	<20141028.165737.2009356944765978630.davem@davemloft.net>
	<20141029122307.GA29253@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161145AbaJ3UAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:00:00 -0400
In-Reply-To: <20141029122307.GA29253@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 29 Oct 2014 13:23:07 +0100

> We could do that, if you prefer.
> 
> I tried to come up with a scenario though, where sysctl_tcp_ecn=0, and
> then we want to enable 'passive' ecn for incoming connections only on
> a particular route without announcing ecn to the peer. I haven't been
> able to find any -- I think if you deem 'route to x' safe for ecn it
> might as well be enabled for both initiator and responder.  The original
> patch would be sufficient for that.
> 
> IOW, is 'ecn from a to b but not b to a' a sensible requirement?

I think you have to apply the same logic for the sysctl (there's a
reason to only support ECN passively) as you do for the route feature
because you can logically look at the sysctl as applying to the
default route.

> Unrelated to this patch, but I'd like to see sysctl_tcp_ecn=1 as a
> default at one point (almost no routers set CE bit at this time, perhaps
> that would change if ecn usage is more widespread).

Now you're talking.

So, either passive ECN support makes sense or it does not.  To me, no
matter what the argument, it doesn't matter what realm (whole system,
specific routes) you apply that argument to.
