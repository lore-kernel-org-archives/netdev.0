From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: e1000e on thinkpad x60: interrupt problem
Date: Tue, 9 Jul 2013 20:59:13 +0000
Message-ID: <D38E8E86660E514AB505863C19C9287C73E6145D@ORSMSX102.amr.corp.intel.com>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
 <D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
 <20130709170242.GA14112@amd.pavel.ucw.cz>
 <1373390146.4286.1.camel@ppwaskie-mobl2>
 <20130709204854.GA21438@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6912 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887Ab3GIU7P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 16:59:15 -0400
In-Reply-To: <20130709204854.GA21438@amd.pavel.ucw.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So are you saying the HW isn't generating an interrupt?  Clearly it is as the driver is taking action on it.  I went and looked at the first mail I saw (the one I first responded to) but maybe you are talking about another email that I (we) didn't get.  I don't see any of what you point to in this email (below).  So I still don't think we know what you are asking.  Is it that you think an interrupt isn't processed because of the interrupts being shared and the packets get processed on the next interrupt?

Cheers,
John


> -----Original Message-----
> From: Pavel Machek [mailto:pavel@ucw.cz]
> Sent: Tuesday, July 09, 2013 1:49 PM
> To: Waskiewicz Jr, Peter P
> Cc: Ronciak, John; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce
> W; Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V; Duyck,
> Alexander H; Dave, Tushar N; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org
> Subject: Re: e1000e on thinkpad x60: interrupt problem
> 
> On Tue 2013-07-09 17:15:48, Waskiewicz Jr, Peter P wrote:
> > On Tue, 2013-07-09 at 19:02 +0200, Pavel Machek wrote:
> > > Hi!
> > >
> > > > Nothing appears to be wrong.  If the system is seeing ping
> packets
> > > >at all means that device is generating interrupts and that they
> are
> > > >being processed.  If you are looking at performance then sharing
> > >
> > > No, that's not true. There is other interrupt load, and e1000e has
> > > big enough buffers; that means that packets eventually get
> > > processed. I strongly suspect e1000e generates little or no
> > > interrupts and packets only get processed when other devices on
> > > shared interrupt line generate interrupt.
> >
> > If the interrupt is shared, e1000e checks if it's the hardware that
> > generated it before processing packets.  Consuming an interrupt that
> > isn't meant for this device will throw major warnings in the kernel
> > about bad interrupt routing, etc.  Here's the code from the interrupt
> > handler (note the last part of the pasted code):
> 
> Yeah, of course you need to ask e1000e if it generated the interrupt.
> That part works. The part that actually generates the interrupt does
> not. Take a look at original mail...
> 
> packet comes
> e1000e sets E1000_ICR_INT_ASSERTED bit
> e1000e tries to generate an interrupt and fails 50msec passes AHCI
> generates interrupt all the handlers are called
>     AHCI processes its interrupt, handles disk read
>     e1000_intr notices E1000_ICR_INT_ASSERTED bit, delivers the packet.
> 
> Network still works, only slowly. Ping goes lower when I use the disk.
> That matches what I see.
> 
> Do you have other explanation?
> 									Pavel
> 
> > /**
> >  * e1000_intr - Interrupt Handler
> >  * @irq: interrupt number
> >  * @data: pointer to a network interface device structure  **/ static
> > irqreturn_t e1000_intr(int __always_unused irq, void *data) {
> >         struct net_device *netdev = data;
> >         struct e1000_adapter *adapter = netdev_priv(netdev);
> >         struct e1000_hw *hw = &adapter->hw;
> >         u32 rctl, icr = er32(ICR);
> >
> >         if (!icr || test_bit(__E1000_DOWN, &adapter->state))
> >                 return IRQ_NONE;  /* Not our interrupt */
> >
> >         /* IMS will not auto-mask if INT_ASSERTED is not set, and if
> > it is
> >          * not set, then the adapter didn't send an interrupt
> >          */
> >         if (!(icr & E1000_ICR_INT_ASSERTED))
> >                 return IRQ_NONE;
> >
> > Cheers,
> > -PJ
> 
> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures)
> http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
