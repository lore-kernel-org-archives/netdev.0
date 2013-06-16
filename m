From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 13:17:52 +0200
Message-ID: <1371381472.8546.1.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130613222411.GA5396@sig21.net>
	 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
	 <20130614055346.GB6547@sig21.net>
	 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
	 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
	 <20130616094930.GA5899@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58416 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060Ab3FPLR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 07:17:57 -0400
In-Reply-To: <20130616094930.GA5899@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-16 at 11:49 +0200, Johannes Stezenbach wrote:

> > > Can you check if one of RX actually works? It seems TX doesn't, at least
> > > given the message, but it'd be good to know if RX actually worked? Just
> > > trying ping obviously wouldn't determine that, maybe try tcpdump?
> 
> I tried it but no packets are received, and no irqs generated.

Ok.

> > I'm assuming you did try the QCA driver and it works?
> 
> It worked at some time in the past, but I just tried again
> and now it doesn't work, it spits a large register dump
> periodically and then does task:alx_reinit.  I'll try
> to backtrack to find the working version, but give me
> some time.

Ouch. Which tree are you testing there, btw? I found a handful of trees
on github.

> (Usually I don't use eth on this maching except for doing
> bulk data copies to my laptop, which happens very rarely.
> For the most time I'm using ath9k_htc WLAN USB dongle.)
> 
> Another thing: suspend to disk fails (also happened with QCA driver):
> 
> Jun 16 00:54:32 abc kernel: [93820.564582] Suspending console(s) (use no_console_suspend to debug)
> Jun 16 00:54:32 abc kernel: [93820.568633] serial 00:0a: disabled
> Jun 16 00:54:32 abc kernel: [93820.568644] serial 00:0a: System wakeup disabled by ACPI
> Jun 16 00:54:32 abc kernel: [93820.569407] alx 0000:03:00.0: PHY SPD/DPLX unresolved: 0xffff
> Jun 16 00:54:32 abc kernel: [93820.569410] alx 0000:03:00.0: shutdown fail in suspend -22
> Jun 16 00:54:32 abc kernel: [93820.569417] pci_pm_freeze(): alx_suspend+0x0/0x75 returns -22
> Jun 16 00:54:32 abc kernel: [93820.569421] dpm_run_callback(): pci_pm_freeze+0x0/0x8f returns -22
> Jun 16 00:54:32 abc kernel: [93820.569427] PM: Device 0000:03:00.0 failed to freeze async: error -22
> 
> (I think it worked the first time but failed on second suspend)

Hmm. I don't really have a use for suspend/resume here, I'll poke at it
but ... maybe I should just remove WOL and kill the chip in suspend. :)

johannes
