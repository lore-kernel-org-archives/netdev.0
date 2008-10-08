From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 06:37:01 +0000
Message-ID: <20081008063701.GA4174@ff.dom.local>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au> <20081007074435.GA2700@ff.dom.local> <20081008000928.GJ12021@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:49543 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbYJHGhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 02:37:08 -0400
Received: by ik-out-1112.google.com with SMTP id c30so2369586ika.5
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 23:37:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081008000928.GJ12021@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 11:09:28AM +1100, Simon Horman wrote:
> On Tue, Oct 07, 2008 at 07:44:35AM +0000, Jarek Poplawski wrote:
...
> > So, thanks for testing and reporting this. (BTW, what network card
> > do you use and is there multiqueuing on?)
> 
> The network card is an e1000. Acutally there are two, but I
> am only using the first one. I am not sure what the Broadcom
> controllers are (I can get someone to go and inspect the
> machine if its important).
> 
> # lspci | grep Ether
> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
> 05:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
> 0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
> 0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
> 
> And from dmsg
> 
> e1000e 0000:0b:00.0: setting latency timer to 64
> 0000:0b:00.0: 0000:0b:00.0: Failed to initialize MSI interrupts.  Falling back to legacy interrupts.
> 0000:0b:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:1b:78:57:dc:f2
> 0000:0b:00.0: eth0: Intel(R) PRO/1000 Network Connection
> 0000:0b:00.0: eth0: MAC: 0, PHY: 4, PBA No: d51930-003
> e1000e 0000:0b:00.1: setting latency timer to 64
> 0000:0b:00.1: 0000:0b:00.1: Failed to initialize MSI interrupts.  Falling back to legacy interrupts.
> 0000:0b:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:1b:78:57:dc:f3
> 0000:0b:00.1: eth1: Intel(R) PRO/1000 Network Connection
> 0000:0b:00.1: eth1: MAC: 0, PHY: 4, PBA No: d51930-003
> 
> It is eth0 that I am using.

I've only wandered if we should consider any new effects because of
this, but e1000/1000e don't have this yet (bnx2 has).

> My kernel is compiled with CONFIG_NET_SCH_MULTIQ disabled.

Multiquing can work without this too.

Jarek P.
