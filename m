From: Jeff Garzik <jeff@garzik.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Mon, 06 Apr 2009 20:30:59 -0400
Message-ID: <49DA9EC3.4060903@garzik.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>	 <1239044483.14392.55.camel@calx>	 <alpine.DEB.2.00.0904070003470.6968@aurora.sdinet.de> <1239063404.14392.118.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756946AbZDGAbY@vger.kernel.org>
In-Reply-To: <1239063404.14392.118.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Tue, 2009-04-07 at 00:09 +0200, Sven-Haegar Koch wrote:
>> On Mon, 6 Apr 2009, Matt Mackall wrote:
>>
>>> On Mon, 2009-04-06 at 14:30 -0400, Robin Getz wrote:
>>>> We have lots of embedded headless systems (no keyboard/mouse, no soundcard, no 
>>>> video) systems with *no* sources of entropy - and people using SSL.
>>> I'd rather add a random_sample_network call somewhere reasonably central
>>> in the network stack. Then we can use the knowledge that the sample is
>>> network-connected in the random core to decide how to measure its
>>> entropy. The trouble with IRQF_SAMPLE_RANDOM is that many of its users
>>> are technically bogus as entropy sources in the current model.
>>>
>>> I'm eventually going to move the RNG away from the strict theoretical
>>> entropy accounting model to a more pragmatic one which will be much
>>> happier with iffy entropy sources, but that's a ways off.
>> Btw, perhaps not the perfect question in this thread:
>> But what should we use to keep servers running without a hardware rng 
>> available and without any external input besides the network?
>> After having ssh and openvpn die because of no random and having 
>> the machines like dead and unreachable for me I use "ln -sf 
>> /dev/urandom /dev/random", but that does not feel so good.
> 
> It's fine so long as you're not wearing a tinfoil hat. In fact, as
> the /dev/random maintainer, I'd recommend it.
> 
> Ted and I have recently been talking about revisiting the design
> of /dev/random to avoid these sorts of issues.


Two points...

- while I would welcome a more pragmatic entropy accounting model,

- it seems misplaced to _solely_ address network entropy problems 
(timer-based regularity, external visibility and access) within the 
devrandom machinery.

IRQF_SAMPLE_RANDOM in network drivers IMO just gives users a false sense 
of security about their entropy.

And more fundamentally, IRQF_SAMPLE_RANDOM should never be used on a 
non-random source.

	Jeff
