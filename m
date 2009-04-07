From: Jeff Garzik <jeff@garzik.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 07 Apr 2009 18:25:42 -0400
Message-ID: <49DBD2E6.1060702@garzik.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <alpine.DEB.2.00.0904070003470.6968@aurora.sdinet.de> <49DA91C2.1020106@garzik.org> <200904071758.50823.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
	Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46380 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755601AbZDGWZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 18:25:54 -0400
In-Reply-To: <200904071758.50823.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robin Getz wrote:
> On Mon 6 Apr 2009 19:35, Jeff Garzik pondered:
>> Sven-Haegar Koch wrote:
>>> On Mon, 6 Apr 2009, Matt Mackall wrote:
>>>
>>>> On Mon, 2009-04-06 at 14:30 -0400, Robin Getz wrote:
>>>>> We have lots of embedded headless systems (no keyboard/mouse, no
>>>>> soundcard, no video) systems with *no* sources of entropy - and people
>>>>> using SSL. 
>>>> I'd rather add a random_sample_network call somewhere reasonably central
>>>> in the network stack. Then we can use the knowledge that the sample is
>>>> network-connected in the random core to decide how to measure its
>>>> entropy. The trouble with IRQF_SAMPLE_RANDOM is that many of its users
>>>> are technically bogus as entropy sources in the current model.
>>>>
>>>> I'm eventually going to move the RNG away from the strict theoretical
>>>> entropy accounting model to a more pragmatic one which will be much
>>>> happier with iffy entropy sources, but that's a ways off.
>>> Btw, perhaps not the perfect question in this thread:
>>> But what should we use to keep servers running without a hardware rng 
>>> available and without any external input besides the network?
>>> After having ssh and openvpn die because of no random and having 
>>> the machines like dead and unreachable for me I use "ln -sf 
>>> /dev/urandom /dev/random", but that does not feel so good.
>> We see this question every time IRQF_SAMPLE_RANDOM is discussed.
>>
>> There is plenty of entropy data available, you just have to look 
>> around...  Google around for "EGD", video entropy daemon, audio entropy 
>> daemon, etc...
>>
>> Even headless servers have entropy sources if you look hard enough.
> 
> The original question wasn't headless servers - it was headless, no audio, no 
> video, boot from flash, (initrd root file systems), diskless. embedded 
> devices.
> 
> And few want to load up perl on an embedded device just to gather entropy. :(

Get a list of <special files> from EGD, and

	cat <special files> | sha1sum

then...

The basic point is that you can find entropy, even in a guest VM.

	Jeff


