From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Tue, 08 May 2012 07:25:44 +0200
Message-ID: <1336454744.4328.2.camel@jlt3.sipsolutions.net>
References: <1336397946.4325.27.camel@jlt3.sipsolutions.net>
	 <1336398809.3752.2313.camel@edumazet-glaptop>
	 <1336399961.4325.30.camel@jlt3.sipsolutions.net>
	 <20120507.192052.181899101154654170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:40953 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab2EHFZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 01:25:48 -0400
In-Reply-To: <20120507.192052.181899101154654170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 19:20 -0400, David Miller wrote:

> >> > Neither compare_ether_addr() nor compare_ether_addr_64bits()
> >> > (as it can fall back to the former) have comparison semantics
> >> > like memcmp() where the sign of the return value indicates sort
> >> > order. We had a bug in the wireless code due to a blind memcmp
> >> > replacement because of this.
> >> > 
> >> > A cursory look suggests that the wireless bug was the only one
> >> > due to this semantic difference.
> >> > 
> >> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> >> > ---
> >> >  include/linux/etherdevice.h |   11 ++++++-----
> >> >  1 file changed, 6 insertions(+), 5 deletions(-)
> >> 
> >> The right way to avoid this kind of problems is to change these
> >> functions to return a bool
> > 
> > Well, I guess so, but that'd be a weird thing for a compare_ function...
> > should probably be named equal_... then, but I'm not really able to do
> > such a huge change on the first day after my vacation :-)
> 
> It's true the name could be improved, but changing the name is quite
> a large undertaking even with automated scripts.
> 
> Even the bool change is slightly painful, since all of the explicit
> tests against integers (%99.999 of these are in wireless BTW :-) would
> need to be adjusted.

I suppose I could fix those first and then later change the type, but I
think having a "compare_ether_addr" function that returns *false* when
they *match* would be rather confusing. I'd rather have
"equal_ether_addr()" that returns *true* when they match.

I guess we could introduce equal_ether_addr() though and slowly convert,
keeping compare_ether_addr() as a sort of wrapper around it.

johannes
