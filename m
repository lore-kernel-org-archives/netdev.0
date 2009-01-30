From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 15:57:06 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901301551460.3150@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain> <alpine.DEB.2.00.0901282049040.5026@parag-desktop> <20090129184215.GA13459@xw6200.broadcom.net> <alpine.DEB.2.00.0901291700130.5149@parag-desktop>
 <20090129222247.GA13861@xw6200.broadcom.net> <alpine.DEB.2.00.0901291730030.5149@parag-desktop> <20090130184030.GA14933@xw6200.broadcom.net> <alpine.DEB.2.00.0901301743410.4989@parag-desktop> <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain>
 <alpine.DEB.2.00.0901301826490.5027@parag-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47043 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753173AbZA3X5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:57:54 -0500
In-Reply-To: <alpine.DEB.2.00.0901301826490.5027@parag-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Parag Warudkar wrote:
> 
> Totally worth having this problem from a "getting an opportunity to 
> understand" standpoint. This confirms my long standing suspicion that bugs 
> in Linux kernel are merely a handiwork of few clever people to get more 
> people to understand and contribute :)

Heh. I wish. But if that's the end result, we've done something good.

> Any how  here is the pre-suspend lspci -vvxxx output followed by diff -u -

Bingo.

> diff -u lspci-pre-suspend lspci-post-suspend
> 
> --- lspci-pre-suspend	2009-01-30 18:19:50.752275695 -0500
> +++ lspci-post-suspend	2009-01-30 18:20:52.629779008 -0500
>  
>  00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
> -	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> +	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
>  	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>  	Latency: 0, Cache Line Size: 64 bytes
>  	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0

We've disabled IO and MEM behind this bridge - the one that bridges to 
secondary bus 0x0e.

And your tg3 device? It's at 0000:0e:00.0. Yeah. Exactly the bus that 
we've disabled IO and MEM for.

In other words, it was never your tg3 suspend/resume that was buggy. It 
was the suspend/resume for the PCI-E port driver. In fact, I think it's 
_exactly_ the issue I just emailed out about.

I bet Rafael can whip up a patch in a minute. I have too much of a 
headache right now to look at my screen for a while, so I'll take a break.

			Linus
