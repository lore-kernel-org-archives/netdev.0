From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 12:10:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1210181203220.21297@uplift.swm.pp.se>
References: <507F38D4.102@genband.com> <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se> <1350551609.26103.1261.camel@edumazet-glaptop> <20121018100149.GA5176@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:49021 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972Ab2JRKKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 06:10:44 -0400
In-Reply-To: <20121018100149.GA5176@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Oct 2012, Alexey Kuznetsov wrote:

> Andi suggested to hook netdev notifier and to reset tcp connections 
> bound to addresses on this interface. He did not go so far to send 
> resets before address is actually disabled (it was not a goal, normally 
> address is already dead to the time when it is deleted), but techically 
> it is the same.

With IPv6 and temporary addresses etc, and DHCPv4/v6 leases expiring, 
addresses going away can be a quite foreseeable event. When I suspend my 
laptop, the IP going away is also quite forseeable.

> The problem with this was purely technical, the code has to scan through 
> all the tcp hash table to search for connections to this address (grrr 
> already :-)) and to take socket lock before making any actions. It is 
> doable, but quite chumbersome and nobody was interested enough to finish 
> the job.

Are there hooks so that someone could write a userland application to do 
this job? I could imagine the connection manager doing this job as well 
(so it's configurable what connection to close or not).

What about the reset of the TCP retransmit timers, is that doable from 
userland? Or at least lowering them to 1s or something fairly sane (going 
to fast-retransmit doesn't make sense, neither does having a retransmit 
timer in the 10s of minutes).

Btw, what are the TCP retransmit timers when I come out of suspend? The 
machine has been "offline" for hours, what idea does TCP have of what's 
going on, will it keep the timers it had when machine went down or does 
TCP believe it hasn't seen a response for a long time and now the 
retransmit timers are very high?

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
