From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [git patches] net driver fixes
Date: Thu, 1 Mar 2007 23:31:03 -0700
Message-ID: <e9c3a7c20703012231h7543efd0sb59ef13eae55d47e@mail.gmail.com>
References: <20070227110233.GA14138@havoc.gtf.org>
	 <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:22937 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422971AbXCBGbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 01:31:05 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1177192nfa
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2007 22:31:04 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/1/07, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>
> Ok, here's an interesting one: my e1000 card no longer worked for a while.
>
> The green link-light blinks on/off once a second, and in time to that, my
> dmesg fills up with an endless supply of
>
>         e1000: eth0: e1000_watchdog: NIC Link is Down
>         e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
>         e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO
>
> and networking obviously doesn't actually work.
>
> I tried to do bisection, but my log made no sense, since it seemed to say
> that the problem was introduced between git commits 2442d310 and bff288c1,
> and there aren't even any commits to drivers/net/ in that range!
>
> SO...
>
> It seems to be that what actually happened is that my switch got confused
> (I ended up just power-cycling the switch when I hit the "impossible"
> situation, and that seems to be what made it start working again, rather
> than any kernel changes due to bisection ;)
>
> Regardless, the "spam the logs every second" is a *bad* idea. I'll try to
> see if I can re-create the problem (probably not), but I thought I'd
> report this message spamming regardless. If there really is some link
> problem, no way do I want to see a message about it every second for all
> eternity. Hmm?
>
> Does this "once a second link issue" ring any bells for anybody? Suggested
> fixes? I realize people do want to know about link problems, but that was
> a bit excessive and since it happened with a reboot, I thought it was a
> kernel bug (it may still be - I'll have to try to recreate it, but my
> suspicion right now is that the reboot just caused some noise and/or link
> renegotiation on the ethernet link that was what actually confused my
> switch).
>
I have seen this occasionally with the e1000 on Xscale IOP development
boards.  The driver prints the up/down messages and makes no progress.
 I can also confirm that resetting the switch (SMC8505T) fixed things
for me.  It might be nice to just print "e1000 link can not be
established try resetting your switch?" after some time.

It's not clear what the steps are to reproduce this, and it doesn't
happen frequently enough to be a show stopper in my environment.  The
IOP boards in the lab typically run an NFS root and are often power
cycled without running shutdown.

So at least an "I see it too" for what it's worth.

>                 Linus

--
Dan
