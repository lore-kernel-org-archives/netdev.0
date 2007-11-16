From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Thu, 15 Nov 2007 16:32:38 -0800
Message-ID: <473CE526.4080209@hp.com>
References: <1194655141.5745.272.camel@teletran1>	<20071112.212135.172019737.davem@davemloft.net>	<1195165211.20497.107.camel@teletran1> <20071115.144103.24280158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net,
	mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:11670 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878AbXKPAni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 19:43:38 -0500
In-Reply-To: <20071115.144103.24280158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>I sense that the PCI spec wants devices to use an MRRS value of 512 in
>>>order to get better fairness on a PCI-E segment amongst multiple
>>>devices.

Unless there are PCIe switches, there is only ever one device on the 
PCIe segment yes?  Even on the biggest PCI-X or PCIe systems with which 
I am familiar, each PCIe slot is a separate PCIe bus, and I think that 
holds for the most recent PCI-X one as well.

Now, "core" I/O may be another matter - for example, on the rx3600 and 
rx6600 there are some shared PCI-X bus slots (two per) and on the 
"combo" versions in addition to the two independent PCIe x8's there is 
one pair of PCIe's on a switched bus.

However, none of the shared bus slots are recommended for "high 
performance cards" (that wonderfully moving target of a devinition :).


>>>From that perspective, jacking up the MRRS to 4096 unilaterally seems
>>>like a very bad idea.  If this was necessary for good performance, I'm
>>>sure the PCI spec folks would have choosen a higher value.
>>>
>>>Or is this some tg3 specific performance issue?
>>
>>Keeping the MRRS at 512 introduces DMA latencies that effectively
>>prevent us from achieving linerate.  With a packet size of ~1.5K and the
>>MRRS at 512 bytes, the DMA will be broken into at least 3 DMA reads.
>>Each DMA read takes ~1usec to initiate.  It is this overhead that starts
>>to cut into total throughput.

Reminds me of Tigon2 on original PCI.

> Ok, but wouldn't every networking device on PCI need to do this then?

I'm going to get very rapidly out of my PCI depth, but on one or the 
other (e vs X) isn't is possible from the standpoint of PCI for a device 
to have multiple transactions outstanding at a time?

If a given device can only have one outstanding at a time and happens to 
take a while to setup the DMA (perhaps there is firmware down there or 
something) I could see where it would want to make the transactions as 
large as it could, but another device, either able to have multiple in 
flight, or perhaps quicker on the DMA setup draw might not need it so large.

And even if the device itself is reasonably quick on the DMA setup draw, 
there may be systems, particularly large ones, where the rest of the 
setup of the DMA isn't instantaneous.

> I want to hear what you think about this wrt. what I mentioned about
> fairness above.  What's the point of PCI specifying a limit to comply
> with if nobody complies with the limit for localized performance
> reasons?

I'm _guessing_ that much of those limits were set with shared busses in 
mind.  The "trend" seems to be towards single-slot busses.

> I think this is an important issue.  Someone down the road is going to
> see bad disk throughput when doing lots of network transfers and
> wonder why that is.  It will be hard to debug, but it won't be
> difficult for us to do something proactive about this right now to
> prevent that problem from happening in the first place.

Does the current value of the MRRS get displayed in lspci output?  It 
wouldn't be a slam dunk, but if someone were looking at that and saw the 
value large they might make an educated guess.

rick jones
