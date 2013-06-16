From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 11:49:30 +0200
Message-ID: <20130616094930.GA5899@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130613222411.GA5396@sig21.net>
 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
 <20130614055346.GB6547@sig21.net>
 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:42413 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754923Ab3FPJtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jun 2013 05:49:36 -0400
Content-Disposition: inline
In-Reply-To: <1371327319.14174.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 15, 2013 at 10:15:19PM +0200, Johannes Berg wrote:
> On Sat, 2013-06-15 at 20:26 +0200, Johannes Berg wrote:
> > On Fri, 2013-06-14 at 07:53 +0200, Johannes Stezenbach wrote:
> > 
> > > > Does it still pass traffic after that? Or is it actually dead?
> > > 
> > > It is dead.  Not interrupts, I tried ping from both ends
> > > of the link (link LED flashes on RX).
> > 
> > Can you check if one of RX actually works? It seems TX doesn't, at least
> > given the message, but it'd be good to know if RX actually worked? Just
> > trying ping obviously wouldn't determine that, maybe try tcpdump?

I tried it but no packets are received, and no irqs generated.

> > I don't see any difference between 8171 and 8161 in the TX code
> > though ...
> 
> FWIW I tried again on my device against 3.9.6, and it works fine :-/
> 
> Latest code is here: http://p.sipsolutions.net/c2e7235ba77373f0.txt in
> case you want to retry that.
> 
> I'm assuming you did try the QCA driver and it works?

It worked at some time in the past, but I just tried again
and now it doesn't work, it spits a large register dump
periodically and then does task:alx_reinit.  I'll try
to backtrack to find the working version, but give me
some time.

(Usually I don't use eth on this maching except for doing
bulk data copies to my laptop, which happens very rarely.
For the most time I'm using ath9k_htc WLAN USB dongle.)

Another thing: suspend to disk fails (also happened with QCA driver):

Jun 16 00:54:32 abc kernel: [93820.564582] Suspending console(s) (use no_console_suspend to debug)
Jun 16 00:54:32 abc kernel: [93820.568633] serial 00:0a: disabled
Jun 16 00:54:32 abc kernel: [93820.568644] serial 00:0a: System wakeup disabled by ACPI
Jun 16 00:54:32 abc kernel: [93820.569407] alx 0000:03:00.0: PHY SPD/DPLX unresolved: 0xffff
Jun 16 00:54:32 abc kernel: [93820.569410] alx 0000:03:00.0: shutdown fail in suspend -22
Jun 16 00:54:32 abc kernel: [93820.569417] pci_pm_freeze(): alx_suspend+0x0/0x75 returns -22
Jun 16 00:54:32 abc kernel: [93820.569421] dpm_run_callback(): pci_pm_freeze+0x0/0x8f returns -22
Jun 16 00:54:32 abc kernel: [93820.569427] PM: Device 0000:03:00.0 failed to freeze async: error -22

(I think it worked the first time but failed on second suspend)


Thanks,
Johannes
