From: Willy Tarreau <w@1wt.eu>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Fri, 16 Nov 2012 07:39:05 +0100
Message-ID: <20121116063905.GA710@1wt.eu>
References: <20121115222812.GA647@1wt.eu> <1353023344.10798.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:35784 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab2KPGjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 01:39:10 -0500
Content-Disposition: inline
In-Reply-To: <1353023344.10798.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Nov 15, 2012 at 03:49:04PM -0800, Eric Dumazet wrote:
> On Thu, 2012-11-15 at 23:28 +0100, Willy Tarreau wrote:
> > Hello,
> > 
> > I was just about to make a quick comparison between LRO and GRO in
> > 3.7.0-rc5 to see if LRO still had the big advantage I've always observed,
> > but I failed the test because as soon as I enable LRO + splice, the kernel
> > panics and reboots.
> > 
> > I could not yet manage to catch the panic output, I could just reliably
> > reproduce it, it crashes instantly.
> > 
> > All I can say at the moment is the following :
> >   - test consist in forwarding HTTP traffic between two NICs via haproxy
> >   - driver used was myri10ge
> >   - LRO + recv+send : OK
> >   - LRO + splice : OK
> >   - GRO + recv+send : OK
> >   - GRO + splice : panic
> >   - no such problem was observed in 3.6.6 so I think this is a recent
> >     regression.
> > 
> > I'll go back digging for more information, but as I'm used to often see
> > Eric suggest the right candidates for reverting, I wanted to report the
> > issue here in case there are easy ones to try first.
> 
> Hi Willy
> 
> Nothing particular comes to mind, there were a lot of recent changes
> that could trigger this kind of bug.

OK, no problem.

> A stack trace would be useful of course ;)

I'll arrange to get one, then to bisect. I'll also try to reproduce with
the onboard NIC (sky2) to see if this is something related to the driver
itself. I can't promise anything before the end of the week-end, though.

Thanks !
Willy
