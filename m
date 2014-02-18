From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Tue, 18 Feb 2014 17:13:06 +0000
Message-ID: <20140218171306.GA19774@e106331-lin.cambridge.arm.com>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk>
 <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk>
 <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com>
 <5302801F.6000903@cogentembedded.com>
 <CAGVrzcbZC3t0oexc5Aj-KyGj-qC8J9eYp8+rb8V-AqKtrSjyYw@mail.gmail.com>
 <530316EE.5010104@codethink.co.uk>
 <20140218115443.GC6051@e106331-lin.cambridge.arm.com>
 <53039193.4010500@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53039193.4010500@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 18, 2014 at 05:00:03PM +0000, Sergei Shtylyov wrote:
> Hello.
> 
> On 02/18/2014 02:54 PM, Mark Rutland wrote:
> 
> >> [snip]
> 
> >>>>> - fixing up some design mistake?
> >>>>> - accounting for a specific board design?
> 
> >>>>      Kind of both. This was invented to defy the necessity of having platform
> >>>> fixup in the DT case (where there should be no board file to place it into).
> >>>> I have already described that platform fixup necessary on the Renesas
> >>>> Lager/Koelsch boards where the LED0 signat is connected to ETH_LINK signal
> >>>> on the SoC and the PHY reset sets the LED control bits to default 0 which
> >>>> means that LED0 will be LINK/ACTIVITY signal and thus blink on activity and
> >>>> cause ETH_LINK to bounce off/on after each packet.
> 
> >>>>> In any case a PHY fixup would do the job for you.
> 
> >>>>      Not in any case. In case of DT we have no place for it, so should invent
> >>>> something involving DT.
> 
> >>> How is DT different than any machine probing mechanism here? The way
> >>> to involve DT is to do the following:
> 
> >>> if (of_machine_is_compatible("renesas,foo-board-with-broken-micrel-phy"))
> >>>              phy_register_fixup(&foo_board_with_broken_micrel_phy);
> 
> >> Oh yes, but now I have to do that for Linux, for $BSD, and for
> >> anything else I want to run on the device. I thought dt was meant
> >> to allow us to describe the hardware.
> 
> > It does allow you to describe the hardware. Arbitrary register writes
> > aren't a description of the hardware, they're a sequence of instructions
> > that tells the OS nothing about the hardware and limit the ability of an
> > OS to do something different that might be better.
> 
> > It's already the case that the OS has to have some knowledge of the
> > hardware that's implicit in a binding. We don't expect to have to
> > include bytecode to tell the OS how to poke a particular UART when it
> > can figure that out from a compatible string.
> 
> >> If this is the case, let's just call this linuxtree and let everyone
> >> else get on with their own thing again.
> 
> > This doesn't follow at all. Any OS needs to have some understanding of
> > the hardware it will try to poke. Describing a specific sequence of
> > writes in a DT is no more operating system independent than identifying
> > the hardware and expecting the OS to have a driver for it. The
> > requirements aren't any more suited to an individual OS in either case.
> 
> >> See also comment below.
> 
> >>> If your machine compatible string does not allow you to uniquely
> >>> identify your machine, this is a DT problem, as this should really be
> >>> the case. If you do not want to add this code to wherever this is
> >>> relevant in arch/arm/mach-shmobile/board-*.c, neither is
> >>> drivers/net/phy/phy_device.c this the place to add it.
> 
> >> So where should it be added? If we keep piling stuff into board files
> >> in arch/arm.... then we're just back to the pre-dt case and going to
> >> keep getting shouted at.
> 
> > The general trend has been to allocate new compatible strings for
> > components and let individual drivers handle this.
> 
> > As far as I can see your case doesn't involve any components external to
> > the PHY, so should probably live in a PHY driver. The PHY can have a
> 
>     It does involve LEDs which should function in the way described by their 
> labels, and it does involve SoC for which ETH_LINK signal should remain stable 
> and not bouncing after each packet.

Ah, I see I misunderstood.

> 
> > specific compatible string with the generic string as a fallback (if it
> > works to some degree without special poking).
> 
>     It can but that doesn't solve this issue in any way. The issue is board 
> specific, not only PHY specific.

Sure. So additional properties are required.

> 
> > I don't see that we need anything board-specific.
> 
>     Did you read the text substantially above this in this mail for more 
> complete description of the issue? We're trying to emulate the PHY *platform* 
> fixup here which didn't belong with the PHY driver.

Apologies, I was indeed mistaken.

Cheers,
Mark.
