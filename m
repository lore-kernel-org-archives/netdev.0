From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/2] Documentation: add Device tree bindings for
 Hisilicon hix5hd2 ethernet
Date: Wed, 28 May 2014 15:58:04 +0100
Message-ID: <20140528145804.GA16088@leverpostej>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
 <1401194667-14445-2-git-send-email-zhangfei.gao@linaro.org>
 <20140527133423.GB6969@leverpostej>
 <53857714.3070603@linaro.org>
 <20140528125354.GA2092@leverpostej>
 <5385E3CC.9050700@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"haifeng.yan@linaro.org" <haifeng.yan@linaro.org>,
	"jchxue@gmail.com" <jchxue@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: zhangfei <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:47187 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751994AbaE1O6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 10:58:45 -0400
Content-Disposition: inline
In-Reply-To: <5385E3CC.9050700@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 02:25:32PM +0100, zhangfei wrote:
> 
> 
> On 05/28/2014 08:53 PM, Mark Rutland wrote:
> > On Wed, May 28, 2014 at 06:41:40AM +0100, zhangfei wrote:
> >> Dear Mark
> >>
> >> On 05/27/2014 09:34 PM, Mark Rutland wrote:
> >>> On Tue, May 27, 2014 at 01:44:26PM +0100, Zhangfei Gao wrote:
> >>>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> >>>> ---
> >>>>    .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   36 ++++++++++++++++++++
> >>>>    1 file changed, 36 insertions(+)
> >>>>    create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> >>>>
> >>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> >>>> new file mode 100644
> >>>> index 0000000..5fe3835
> >>>> --- /dev/null
> >>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> >>>> @@ -0,0 +1,36 @@
> >>>> +Hisilicon hix5hd2 gmac controller
> >>>
> >>> Just to clarify, is the SoC name "hix5hd2", or is the 'x' a wildcard?
> >> "hix5hd2" is Soc name, which contains a series of similar chips.
> >
> > How similar are they?
> >
> > It's preferable to have a precise name, even when used as a fallback for
> > other similar devices.
> 
> The soc name "hix5hd2" is provided by hisilicon.
> In fact, they have considered a lot and discussed long time for this name :)

Sure, I would not expect hisilicon to rebrand their SoC family due to my
comments on a mailing list.

w.r.t. naming in the kernel I could only find an unanswered query [1]
from Olof Johansson earlier this month, and no rationale for the change.

I tried searching online for "hix5hd2" and didn't find much other than a
suggestion it's also known as "Hi3716cv200". I assume this means the
Hi371 range in general, which covers a few variants on the hisilicon
website [2]. The names there are far more specific than "hix5hd2".

We've been bitten in the past when generic SoC family names are used in
DT bindings without also having specific strings. It's usually better to
choose a particular variant as the base, and have others claim
compatibility with that (with additional more specific compatible
strings).

The key issue is how similar the SoC variants are. If they are identical
w.r.t. this block and the blocks it is attached to, then the compatible
string you propose is likely to be fine. However, subtle differences in
integration across variants might cause issues for which we want
targeted workarounds, or we might be able to make better use of
particular variants based on information that we cannot probe from the
HW. For that we need very specific compatible strings, and in general it
is better to add those and not need them than to need them but not have
them.

> >
> >>>
> >>>> +
> >>>> +Required properties:
> >>>> +- compatible: should be "hisilicon,hix5hd2-gmac".
> >>>> +- reg: specifies base physical address(s) and size of the device registers.
> >>>> +  The first region is the MAC register base and size.
> >>>> +  The second region is external interface control register.
> >>>
> >>> Single registers? Are these not part of a larger block?
> >> It is a single register, outside of the memory region.
> >> gmac0: reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
> >> gmac1: reg = <0xf9841000 0x1000>,<0xf9843010 0x4>;
> >>
> >> The register is controlling interface mode, duplex etc.
> >> In fact it is rather a bug fix to the silicon, when it is added with
> >> intension of not touching the original ip design.
> >>
> >> It may be moved to the memory region in the future silicon design.
> >> However, currently without such register, it can not work.
> >
> > I see. Is it possible that a future revision might have this fixed, such
> > that the second reg entry would become optional?
> 
> We have given this feedback to the silicon team, and they admit this 
> should be fixed.
> However, not sure it can be fixed soon since the product pressure.
> Can we keep this first since it is required currently.

I'm not asking for its removal, I'm just trying to find out if in future
we might need to support a DTB without the second entry.

> 
> >
> >>>
> >>>> +- interrupts: should contain the MAC interrupts
> >>>
> >>> How many, in which order?
> >> There is only one interrrupt.
> >> How about:
> >> - interrupts: interrupt for the device
> >
> > The original wording is OK, all you need to do is change the original
> > wording to get rid of the trailing 's':
> >
> > - interrupts: should contain the MAC interrupt
> OK, thanks
> 
> >
> >>
> >>>
> >>>> +- #address-cells: must be <1>.
> >>>> +- #size-cells: must be <0>.
> >>>> +- phy-mode: see ethernet.txt [1].
> >>>> +- phy-handle: see ethernet.txt [1].
> >>>> +- mac-address: see ethernet.txt [1].
> >>>> +- clocks: clock phandle and specifier pair.
> >>>
> >>> Is this the only clock input to the gmac block?
> >>>
> >>> Is the clock input named in any documentation?
> >>
> >> We have abstract only ONE mac clock input, which is in other patch for
> >> drivers/clk/hisilicon/clk-hix5hd2.c
> >> The clock input name is in include/dt-bindings/clock/hix5hd2-clock.h,
> >> described in "Documentation/devicetree/bindings/clock/hix5hd2-clock.txt"
> >
> > If you have only one physical clock input in the GMAC block, that's
> > fine. Is there a name for that input line from the POV of the GMAC
> > block?
> 
> There is no name, and since it is only one clock, no name required.

Ok. That's fine then, assuming we don't expect variants with different
clock input lines wired up.

Cheers,
Mark.

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2014-May/255195.html
[2] http://www.hisilicon.com/products/digital.html
