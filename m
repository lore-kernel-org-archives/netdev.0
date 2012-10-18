From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 14:01:49 +0400
Message-ID: <20121018100149.GA5176@ms2.inr.ac.ru>
References: <507F38D4.102@genband.com> <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se> <1350551609.26103.1261.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikael Abrahamsson <swmike@swm.pp.se>,
	Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:60792 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752350Ab2JRKCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 06:02:06 -0400
Content-Disposition: inline
In-Reply-To: <1350551609.26103.1261.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 18, 2012 at 11:13:29AM +0200, Eric Dumazet wrote:
> > c) tell the kernel to kill all TCP sessions bound to a certain IP, because 
> > the connection manager is going to remove it shortly. Send TCP RSTs or 
> > whatever and close the TCP session, so both ends know that network 
> > connectivity is going down.
> > 
> 
> Yes, why not.

FYI the idea was by Andi Kleen back in 2003. If was flag IFF_DYNAMIC
on device (apparently, it should be per-interface sysctl instead
or even a flag on specific address).

Andi suggested to hook netdev notifier and to reset tcp connections
bound to addresses on this interface. He did not go so far to send
resets before address is actually disabled (it was not a goal, normally
address is already dead to the time when it is deleted),
but techically it is the same.

The problem with this was purely technical, the code has to scan through
all the tcp hash table to search for connections to this address (grrr already :-))
and to take socket lock before making any actions. It is doable, but quite chumbersome
and nobody was interested enough to finish the job.
