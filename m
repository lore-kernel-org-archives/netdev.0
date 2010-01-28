From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: CBQ broken in 2.6
Date: Thu, 28 Jan 2010 22:21:00 +0100
Message-ID: <20100128212100.GB3109@del.dom.local>
References: <20100128125317.GA8931@ff.dom.local>
 <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
 <20100128184519.GA3109@del.dom.local>
 <1264708135.22027.13.camel@magrat.sigsegv.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:39677 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666Ab0A1VVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 16:21:06 -0500
Received: by fg-out-1718.google.com with SMTP id 22so124313fge.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 13:21:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1264708135.22027.13.camel@magrat.sigsegv.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 07:48:55PM +0000, Anton Ivanov wrote:
> Hi Jarek,
Hi Anton,
...
> > So, xstats.borrows is updated for lender as well, which might look
> > wrong/right/funny (depending on your political principles ;-).
> 
> OK. I will look at it. The traffic is actually in a subclass (1:18) so
> this may explain it. It definitely does not fit my "political
> principles". Borrow should mean how many times the class has borrowed
> and overactions should mean the whole lot of overs - delay, borrow,
> drop, etc. At least that were the semantics on BSD and other
> implementations I dealt with before Linux. 

Of course I was joking, and no need to explain this is at least
misleading, but if it's old enough it might be treated as part of user
API. Probably somebody wanted to save an additional variable, and btw.
in some languages there is one verb only, something like here:

"bounded
	Signifies that this class will not borrow bandwidth from its siblings.

 isolated
        Means that this class will not borrow bandwidth to its siblings"

[from man(8)tc-cbq]

So, consider it documented ;-)

> 
> My problem as well is that my C has always sucked bricks and I use it
> once a year when I run into a problem like that. So it takes me a while
> to trace it and figure it out.
> 
> > 
> > It could be your case if the class above has an unbounded child class.
> > Otherwise, it needs more searching. Btw, I'm not the CBQ expert to
> > verify (without learning the specs) these borrowing relations. (As a
> > matter of fact, within a few years I didn't find here many traces of
> > such (active) experts, so my recommendation would be HTB or HFSC
> > unless you really know what you're doing ;-)
> 
> Well, I know CBQ reasonably well from a "network engineer" perspective.
> I used to run it production in an ISP 1998 and after that in an SMB
> 2002-2007. I have also been running it in lab and on my home network for
> 10+ years. Mostly on BSD though. There was even a point where I
> maintained a fork of the patches before they went into the main tree.
> The sole reason I ditched BSD was that they plugged it into the pf
> framework and it became too big of a hassle to port/maintain the
> configs.
> 
> I know what I am doing and HTB is not what I want. It is a good algo for
> expressing classic commerical relationships (CIR/PIR). It is worse than
> CBQ for "sharing" where all of the apps that share are your own and the
> scheduler/estimator is good.

Well, congratulations! But, please, remember this nice, but a very
complex tool is rarely improved/fixed now, mainly not to break some
backward compatibility, while not much reporters/testers either. But,
of course, any feedback is welcome...

Thanks,
Jarek P.
