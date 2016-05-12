From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Thu, 12 May 2016 19:53:18 +0200
Message-ID: <CAKv+Gu-0xuE3HuTeXncZt2QoM50dxLKAtBEaZCMy3m5TAak0mg@mail.gmail.com>
References: <CAKv+Gu-UcEnvFcK+6GSHkas5V5ZUMawc2K_EfRpW3K+jLNB4+A@mail.gmail.com>
	<20160512140920.GA28073@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	Leo Duran <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chunhao Lin <hau@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37125 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbcELRxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 13:53:19 -0400
Received: by mail-ig0-f171.google.com with SMTP id s8so57205151ign.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 10:53:18 -0700 (PDT)
In-Reply-To: <20160512140920.GA28073@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 May 2016 at 16:09, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> On 12 May 2016 at 01:58, David Miller <davem@davemloft.net> wrote:
>> > From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> > Date: Wed, 11 May 2016 09:47:49 +0200
> [...]
>> > I think we should just seriously consider changing the default, it's
>> > a really outdated reasoning behind the current default setting.  Maybe
>> > relevant a decade ago, but probably not now.
>> >
>> > And if the card is completely disfunctional in said configuration, the
>> > default is definitely wrong.
>>
>> The card is indeed completely disfunctional. So we could try to
>> resurrect 353176888386 ("r8169: enable 64-bit DMA by default for PCI
>> Express devices"), and instead of backing it out again if regressions
>> are reported, blacklist the particular chips. This is a much better
>> approach, since then we can also print some kind of diagnostic on
>> those arm64 systems why such a blacklisted NIC is not supported.
>
> I doubt there will be much *reporting* from broken systems that
> include plain old PCI realtek chipsets (r8169.c::RTL_CFG_0). Changing
> the default for those is imnsho asking for troubles without clear
> benefit (experimental evidence suggests that smsc etherpower II grows
> older more easily than plain pci 8169 :o/ ).
>

By resurrecting 353176888386, I mean the patch that changes the
default for PCI express devices, so I think we are in agreement here?

> I'd rather leave these alone and change the default for the PCI Express
> chipsets. Btw, while it does not seem to hurt, they should not need any
> CPlusCmd Dual Access Cycle tweak either. Realtek may establish it (Lin ?)
>
> A few news from the "pathologically better safe than sorry" squad:
> I have switched the default on a couple of non-critical production
> servers that include 8168c (RTL_GIGA_MAC_VER_22). It should give an hint
> for hardware from 2008 ~ 2009. I'll do some basic sanity testing with
> different chipsets.
>

Thanks for testing that. In the mean time, I will dust off the patch
and rebase it to today's -next.
