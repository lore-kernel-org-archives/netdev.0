From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Mon, 6 Apr 2009 15:22:15 -0400
Message-ID: <200904061522.15810.rgetz@blackfin.uclinux.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <49DA4C85.5090806@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Chris Peterson" <cpeterso@cpeterso.com>,
	"Matt Mackall" <mpm@selenic.com>,
	"David Miller" <davem@davemloft.net>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:30062 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbZDFTUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 15:20:00 -0400
In-Reply-To: <49DA4C85.5090806@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 6 Apr 2009 14:40, Jeff Garzik pondered:
> Robin Getz wrote:
> > Although there was some discussion  
> > http://thread.gmane.org/gmane.linux.kernel/680723
> > 
> > about removing IRQF_SAMPLE_RANDOM from the remaining network drivers 
> > in May of 2008, but they still appears to be there in 2.6.29.
> > 
> > drivers/net/ibmlana.c
> > drivers/net/macb.c
> > drivers/net/3c523.c
> > drivers/net/3c527.c
> > drivers/net/netxen/netxen_nic_main.c
> > drivers/net/cris/eth_v10.c
> > drivers/net/xen-netfront.c
> > drivers/net/atlx/atl1.c
> > drivers/net/qla3xxx.c
> > drivers/net/tg3.c
> > drivers/net/niu.c
> > 
> > So what is the plan? If I send a patch to add IRQF_SAMPLE_RANDOM to others 
> > (like the Blackfin) networking drivers - will it get rejected?
> > 
> > We have lots of embedded headless systems (no keyboard/mouse, no
> > soundcard, no video) systems with *no* sources of entropy - and
> > people using SSL. 
> > 
> > I didn't really find any docs which describe what should have 
> > IRQF_SAMPLE_RANDOM on it or not. I did find Matt Mackall describing it as:
> >> We currently assume that IRQF_SAMPLE_RANDOM means 'this is a completely
> >> trusted unobservable entropy source' which is obviously wrong for
> >> network devices but is right for some other classes of device.
> > 
> > Currently - I see most things I see using IRQF_SAMPLE_RANDOM would 
> > also fail the "completely unobservable" test. Other than the TRNG that 
> > are inside the CPU - what does pass?
> 
> IMO it's not observation but rather that a remote host is essentially 
> your source of entropy -- which means your source of entropy is 
> potentially controllable or influenced by an attacker.

Ok - so if it is "un-influenceable" or more specifically - not remotely 
influenceable - that works for me, and says that keyboards, serial devices, 
USB, etc -- should be OK - since they are not remote, even if they can be 
controlled locally.

You assume that the local user is the root user - as least as far as entropy 
goes?

Correct?

> Furthermore, with hardware interrupt mitigation, non-trivial traffic 
> levels can imply that interrupts are delivered with timer-based 
> regularity.  This, too, may clearly be influenced by a remote attacker.
> 
> Thus I think IRQF_SAMPLE_RANDOM should be banned from network drivers... 
> but that is not a universal opinion.

It didn't seem like there were that many people who disagreed with Chris's 
original patch - but there wasn't anyone acking it either...

-Robin
