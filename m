From: David Miller <davem@davemloft.net>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Sun, 16 Dec 2007 15:22:35 -0800 (PST)
Message-ID: <20071216.152235.213233734.davem@davemloft.net>
References: <20071205001230.GA11391@gondor.apana.org.au>
	<20071204.223023.262159049.davem@davemloft.net>
	<4765AAFC.3040406@tmr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davidsen@tmr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756217AbXLPXWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 18:22:47 -0500
In-Reply-To: <4765AAFC.3040406@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Davidsen <davidsen@tmr.com>
Date: Sun, 16 Dec 2007 17:47:24 -0500

> David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Wed, 5 Dec 2007 11:12:32 +1100
> > 
> >> [INET]: Export non-blocking flags to proto connect call
> >>
> >> Previously we made connect(2) block on IPsec SA resolution.  This is
> >> good in general but not desirable for non-blocking sockets.
> >>
> >> To fix this properly we'd need to implement the larval IPsec dst stuff
> >> that we talked about.  For now let's just revert to the old behaviour
> >> on non-blocking sockets.
> >>
> >> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > We made an explicit decision not to do things this way.
> > 
> > Non-blocking has a meaning dependant upon the xfrm_larval_drop sysctl
> > setting, and this is across the board.  If xfrm_larval_drop is zero,
> > non-blocking semantics do not extend to IPSEC route resolution,
> > otherwise it does.
> > 
> > If he sets this sysctl to "1" as I detailed in my reply, he'll
> > get the behavior he wants.
> > 
> I think you for the hint, but I would hardly call this sentence 
> "detailed" in terms of being a cookbook solution to the problem.

I guess "echo '1' >/proc/sys/net/core/xfrm_larval_drop" is not
explicit enough?  What more would you like me to say?
