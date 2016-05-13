From: Hau <hau@realtek.com>
Subject: RE: [PATCH] r8169: default to 64-bit DMA on systems without memory below 4 GB
Date: Fri, 13 May 2016 13:10:38 +0000
Message-ID: <80377ECBC5453840BA8C7155328B5377013C3DF6@RTITMBSV03.realtek.com.tw>
References: <CAKv+Gu-UcEnvFcK+6GSHkas5V5ZUMawc2K_EfRpW3K+jLNB4+A@mail.gmail.com>
 <20160512140920.GA28073@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	"Leo Duran" <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:38085 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcEMNZq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 09:25:46 -0400
In-Reply-To: <20160512140920.GA28073@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Thursday, May 12, 2016 10:09 PM
> To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org; Ricardo
> Salveti <ricardo.salveti@linaro.org>; Leo Duran <leo.duran@amd.com>; G
> Gregory <graeme.gregory@linaro.org>; nic_swsd <nic_swsd@realtek.com>;
> Hau <hau@realtek.com>
> Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
> below 4 GB
> 
> > On 12 May 2016 at 01:58, David Miller <davem@davemloft.net> wrote:
> > > From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > Date: Wed, 11 May 2016 09:47:49 +0200
> [...]
> > > I think we should just seriously consider changing the default, it's
> > > a really outdated reasoning behind the current default setting.
> > > Maybe relevant a decade ago, but probably not now.
> > >
> > > And if the card is completely disfunctional in said configuration,
> > > the default is definitely wrong.
> >
> > The card is indeed completely disfunctional. So we could try to
> > resurrect 353176888386 ("r8169: enable 64-bit DMA by default for PCI
> > Express devices"), and instead of backing it out again if regressions
> > are reported, blacklist the particular chips. This is a much better
> > approach, since then we can also print some kind of diagnostic on
> > those arm64 systems why such a blacklisted NIC is not supported.
> 
> I doubt there will be much *reporting* from broken systems that include plain
> old PCI realtek chipsets (r8169.c::RTL_CFG_0). Changing the default for those is
> imnsho asking for troubles without clear benefit (experimental evidence
> suggests that smsc etherpower II grows older more easily than plain pci
> 8169 :o/ ).
> 
> I'd rather leave these alone and change the default for the PCI Express chipsets.
> Btw, while it does not seem to hurt, they should not need any CPlusCmd Dual
> Access Cycle tweak either. Realtek may establish it (Lin ?)

You don't have to set CPlusCmd Dual Access Cycle for the PCI Express chipsets.

------Please consider the environment before printing this e-mail.
