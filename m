From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] de2104x: remove BUG_ON() when changing media type
Date: Wed, 26 Mar 2008 19:29:56 +0100
Message-ID: <200803261929.59013.linux@rainbow-software.org>
References: <200801262158.12016.linux@rainbow-software.org> <200803250002.21718.linux@rainbow-software.org> <20080326155957.GA24944@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atlantis.sk ([80.94.52.35]:59448 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbYCZSaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 14:30:12 -0400
In-Reply-To: <20080326155957.GA24944@colo.lackof.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 March 2008 16:59:57 Grant Grundler wrote:
> On Tue, Mar 25, 2008 at 12:02:19AM +0100, Ondrej Zary wrote:
> ....
>
> > > Jeff,
> > > The above patch was applied and fixes the 'panic' part of the problme.
> > > Can you take a look at this patch to fix the "chip is still running"
> > > part of this bug?
> >
> > I'll test it but I doubt that it fixes the problem. IIRC, I tried
> > something like that.
>
> Thanks (in advance) for testing!
>
> This patch fixed the same symptom for tulip driver many years ago.
> It's been validated already and should be applied to de2104x driver too.
>
> If it doesn't fix the problem, that just means something else
> is going wrong as well.

As I expected, it did not fix the problem. This time, I used only BNC cable. 
Let ping run, disconnect the cable, change the media type a couple of times 
and it dies. When "timeout expired stopping DMA" appears, the card is dead 
until the module is reloaded.

de2104x PCI Ethernet driver v0.7 (Mar 17, 2004)
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
ACPI: PCI Interrupt 0000:00:12.0[A] -> Link [LNKC] -> GSI 11 (level, low) -> 
IRQ 11
de0: SROM leaf offset 30, default media 10baseT auto
de0:   media block #0: BNC
de0:   media block #1: AUI
de0:   media block #2: 10baseT-FD
de0:   media block #3: 10baseT-HD
eth1: 21041 at 0xd1084000, 00:80:48:ea:eb:0a, IRQ 11
eth1: enabling interface
eth1: set link 10baseT auto
eth1:    mode 0x7ffc0040, sia 0x10c4,0xffffef01,0xffffffff,0xffff0008
eth1:    set mode 0x7ffc0040, set sia 0xef01,0xffff,0x8
eth1: set link AUI
eth1:    mode 0x7ffc0000, sia 0x10c4,0xffffef09,0xfffff7fd,0xffff000e
eth1:    set mode 0x7ffc0000, set sia 0xef09,0xf7fd,0xe
eth1: link up, media AUI
eth1: link down
eth1: set link 10baseT auto
eth1:    mode 0x7ffc0000, sia 0x10c4,0xffffef01,0xffffffff,0xffff0008
eth1:    set mode 0x7ffc0000, set sia 0xef01,0xffff,0x8
eth1: set link AUI
eth1:    mode 0x7ffc0000, sia 0x10c4,0xffffef09,0xfffff7fd,0xffff000e
eth1:    set mode 0x7ffc0000, set sia 0xef09,0xf7fd,0xe
eth1: link up, media AUI
eth1: link down
eth1: timeout expired stopping DMA
eth1: chip is running while changing media!
eth1: set link 10baseT auto
eth1:    mode 0x7ffc0000, sia 0x10c4,0xffffef01,0xffffffff,0xffff0008
eth1:    set mode 0x7ffc0000, set sia 0xef01,0xffff,0x8
eth1: timeout expired stopping DMA
eth1: chip is running while changing media!
eth1: set link AUI
eth1:    mode 0x7ffc0000, sia 0x11c4,0xffffef09,0xfffff7fd,0xffff000e
eth1:    set mode 0x7ffc0000, set sia 0xef09,0xf7fd,0xe
eth1: set link BNC
eth1:    mode 0x7ffc0000, sia 0x10c4,0xffffef09,0xfffff7fd,0xffff0006
eth1:    set mode 0x7ffc0000, set sia 0xef09,0xf7fd,0x6
eth1: link up, media BNC
eth1: link down
eth1: set link AUI
eth1:    mode 0x7ffc0000, sia 0x10c4,0xffffef09,0xfffff7fd,0xffff000e
eth1:    set mode 0x7ffc0000, set sia 0xef09,0xf7fd,0xe

>
> > Even tried resetting the chip multiple times when this problem
> > appears but everything failed.
>
> Can you print the last value from dr32(MacStatus)?
> (just append the output to the "stopping DMA" printk)
>
> If resetting the chip isn't working, my guess is the PCI bus is
> out to lunch. Getting ~0 back on the MMIO read would be evidence
> of that. But resetting the chip isn't trivial and all sorts of
> things could go wrong with that.
>
> thanks,
> grant
>
> > > BTW, I inherited a bug report for the same symptom:
> > >     http://bugzilla.kernel.org/show_bug.cgi?id=3156
> > >
> > > thanks,
> > > grant
> > >
> > > Signed-off-by: Grant Grundler
> > >
> > > --- linux-2.6.23/drivers/net/tulip/de2104x.c	2007-10-09
> > > 13:31:38.000000000 -0700 +++
> > > linux-2.6.23/drivers/net/tulip/de2104x.c-ggg	2007-11-02
> > > 23:24:46.000000000 -0700 @@ -842,7 +842,7 @@
> > >  static void de_stop_rxtx (struct de_private *de)
> > >  {
> > >  	u32 macmode;
> > > -	unsigned int work = 1000;
> > > +	unsigned int i = 1300/100;
> > >
> > >  	macmode = dr32(MacMode);
> > >  	if (macmode & RxTx) {
> > > @@ -850,10 +850,14 @@
> > >  		dr32(MacMode);
> > >  	}
> > >
> > > -	while (--work > 0) {
> > > +	/* wait until in-flight frame completes.
> > > +	 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
> > > +	 * Typically expect this loop to end in < 50 us on 100BT.
> > > +	 */
> > > +	while (--i) {
> > >  		if (!de_is_running(de))
> > >  			return;
> > > -		cpu_relax();
> > > +		udelay(100);
> > >  	}
> > >
> > >  	printk(KERN_WARNING "%s: timeout expired stopping DMA\n",
> > > de->dev->name);
> >
> > --
> > Ondrej Zary



-- 
Ondrej Zary
