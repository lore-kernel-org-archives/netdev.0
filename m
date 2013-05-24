From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood SoCs
Date: Fri, 24 May 2013 13:03:25 +0200
Message-ID: <CACRpkdbsicPkPAiaQCOg2mQF2Ce2dg_K=BKqqx=FCdAH7Y+QBg@mail.gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com>
	<20130522201607.GA18823@obsidianresearch.com>
	<20130523160111.GP31290@titan.lakedaemon.net>
	<20130523171112.GB31281@obsidianresearch.com>
	<20130523172339.GQ31290@titan.lakedaemon.net>
	<20130523175357.GB2821@obsidianresearch.com>
	<20130523184028.GU31290@titan.lakedaemon.net>
	<519E9ADA.3040204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jason Cooper <jason@lakedaemon.net>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:46573 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab3EXLDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 07:03:25 -0400
Received: by mail-ie0-f170.google.com with SMTP id aq17so11923965iec.1
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 04:03:25 -0700 (PDT)
In-Reply-To: <519E9ADA.3040204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 12:40 AM, Sebastian Hesselbarth
<sebastian.hesselbarth@gmail.com> wrote:
> On 05/23/2013 08:40 PM, Jason Cooper wrote:

>> I think marvell,psc1_reset =<>; gives us the most flexibility in
>> accurately describing the hardware.
>
>
> IMHO using that is just another workaround for a broken driver. We
> could hack the whole register setup in DT as it would still accurately
> describe HW. Don't get me wrong, but I don't like it.
>
> Haven't checked how happy Linus Walleij is about pinctrl drivers with
> reg values hacked in lately.

One of the things I've been ranting about lately is that Linux
subsystem maintainers have become de-facto device tree
standard commite chairs. :-(

So to the actual question:

In general I think we need to draw a line and define what we
mean with "describing the hardware" in a device tree.

We have some consensus:
- <reg> properties to describe regsiter BASE offset in physical
  memory and size.
- Resources like IRQ, DMA channel, regulator, GPIO pin control
  handles, are passed using <&ampersand> notation.

And so it goes on.

When it comes to defining different registers and their individual
bits and the meaning of these and/or default values, I personally
think that is making things harder for developers rather than
simplifying things. I know that pinctrl-single is anyway doing this
and I was talked into accepting it under circumstances where
developers are being passed opaque machine-generated
data that would otherwise be translated into unreadable header
files littering the kernel.

For a coder it is definately better if the *driver* know these
details, but whether that is possible seems to depend on things
like hardware development process.

IMO: if you want to go down that road, what you really want is not
ever more expressible device trees, but real open firmware,
or ACPI or UEFI that can interpret and run bytecode as some
"bios" for you. With DT coming from OF maybe this is a natural
progression of things, but one has to realize when we reach the
point where what we really want is a bios. Then your time is
likely better spent with Tianocore or something than with the
kernel.

Yours,
Linus Walleij
