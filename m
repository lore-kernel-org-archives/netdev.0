From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 19:33:12 +0100
Message-ID: <20081027183312.GD11494@elte.hu>
References: <1224917623.4929.15.camel@marge.simson.net> <20081025.002420.82739316.davem@davemloft.net> <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz> <1225010790.8566.22.camel@marge.simson.net> <1225011648.27415.4.camel@twins> <20081026021153.47878580.akpm@linux-foundation.org> <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz> <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz> <20081027112750.GA2771@elte.hu> <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jkosina@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:45385 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559AbYJ0Sde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:33:34 -0400
Content-Disposition: inline
In-Reply-To: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > The way to get the best possible dbench numbers in CPU-bound dbench 
> > runs, you have to throw away the scheduler completely, and do this 
> > instead:
> > 
> >  - first execute all requests of client 1
> >  - then execute all requests of client 2
> >  ....
> >  - execute all requests of client N
> 
> Rubbish. [...]

i've actually implemented that about a decade ago: i've tracked down 
what makes dbench tick, i've implemented the kernel heuristics for it 
to make dbench scale linearly with the number of clients - just to be 
shot down by Linus about my utter rubbish approach ;-)

> [...] If you do that you'll not get enough I/O in parallel to 
> schedule the disk well (not that most of our I/O schedulers are 
> doing the job well, and the vm writeback threads then mess it up and 
> the lack of Arjans ioprio fixes then totally screw you) </rant>

the best dbench results come from systems that have enough RAM to 
cache the full working set, and a filesystem intelligent enough to not 
insert bogus IO serialization cycles (ext3 is not such a filesystem).

The moment there's real IO it becomes harder to analyze but the same 
basic behavior remains: the more unfair the IO scheduler, the "better" 
dbench results we get.

	Ingo
