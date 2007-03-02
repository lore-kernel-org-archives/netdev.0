From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [git patches] net driver fixes
Date: Thu, 1 Mar 2007 21:28:20 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org>
References: <20070227110233.GA14138@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43116 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422813AbXCBF21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 00:28:27 -0500
In-Reply-To: <20070227110233.GA14138@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Ok, here's an interesting one: my e1000 card no longer worked for a while.

The green link-light blinks on/off once a second, and in time to that, my 
dmesg fills up with an endless supply of

	e1000: eth0: e1000_watchdog: NIC Link is Down
	e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
	e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO

and networking obviously doesn't actually work.

I tried to do bisection, but my log made no sense, since it seemed to say 
that the problem was introduced between git commits 2442d310 and bff288c1, 
and there aren't even any commits to drivers/net/ in that range!

SO...

It seems to be that what actually happened is that my switch got confused 
(I ended up just power-cycling the switch when I hit the "impossible" 
situation, and that seems to be what made it start working again, rather 
than any kernel changes due to bisection ;)

Regardless, the "spam the logs every second" is a *bad* idea. I'll try to 
see if I can re-create the problem (probably not), but I thought I'd 
report this message spamming regardless. If there really is some link 
problem, no way do I want to see a message about it every second for all 
eternity. Hmm?

Does this "once a second link issue" ring any bells for anybody? Suggested 
fixes? I realize people do want to know about link problems, but that was 
a bit excessive and since it happened with a reboot, I thought it was a 
kernel bug (it may still be - I'll have to try to recreate it, but my 
suspicion right now is that the reboot just caused some noise and/or link 
renegotiation on the ethernet link that was what actually confused my 
switch).

		Linus
