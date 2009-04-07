From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 7 Apr 2009 17:44:17 -0400
Message-ID: <200904071744.17727.rgetz@blackfin.uclinux.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <200904070716.25846.rgetz@blackfin.uclinux.org> <1239116251.14392.133.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Chris Peterson" <cpeterso@cpeterso.com>
To: "Matt Mackall" <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:53760 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761303AbZDGVmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 17:42:16 -0400
In-Reply-To: <1239116251.14392.133.camel@calx>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 7 Apr 2009 10:57, Matt Mackall pondered:
> On Tue, 2009-04-07 at 07:16 -0400, Robin Getz wrote:
> > On Mon 6 Apr 2009 15:01, Matt Mackall pondered:
> > > On Mon, 2009-04-06 at 14:30 -0400, Robin Getz wrote:
> > > > We have lots of embedded headless systems (no keyboard/mouse, no
> > > > soundcard, no video) systems with *no* sources of entropy - and
> > > > people using SSL. 
> > > 
> > > I'd rather add a random_sample_network call somewhere reasonably
> > > central in the network stack. Then we can use the knowledge that the
> > > sample is network-connected in the random core to decide how to 
> > > measure its entropy. The trouble with IRQF_SAMPLE_RANDOM is that 
> > > many of its users are technically bogus as entropy sources in the
> > > current model. 
> > 
> > OK - that makes more sense.
> > 
> > Does that mean we also shouldn't be using IRQF_SAMPLE_RANDOM on
> > interrupt sources in subsystems which already have add_xxx_randomness()
> > in them? (block devices, and input devices?)
> > 
> > block/blk-core.c -> blk_end_io() -> add_disk_randomness()
> > drivers/input/input.c -> input_event() -> add_input_randomness()
> > 
> >  drivers/block/xen-blkfront.c, line 639
> > 
> >  drivers/input/touchscreen/wm97xx-core.c, line 374
> >  drivers/input/keyboard/gpio_keys.c, line 145
> >  drivers/input/keyboard/bf54x-keys.c, line 255
> >  drivers/input/serio/hp_sdc.c, line 881
>
> Yes. The flag needs to be taken out and shot. 

In general or just for input and block devices?

There are still some in others:

arch/arm/mach-omap1/board-palmz71.c
arch/arm/mach-pxa/lubbock.c
arch/arm/mach-pxa/magician.c
arch/arm/mach-pxa/palmtx.c
arch/arm/mach-pxa/palmz72.c
arch/arm/mach-pxa/trizeps4.c
arch/sparc/kernel/ldc.c
arch/um/drivers/line.c
arch/um/drivers/mconsole_kern.c
arch/um/drivers/port_kern.c
arch/um/drivers/xterm_kern.c
arch/um/kernel/sigio.c
arch/x86/kernel/amd_iommu_init.c
drivers/i2c/busses/i2c-pmcmsp.c
drivers/mfd/tps65010.c
drivers/power/pda_power.c
drivers/serial/bfin_sport_uart.c
drivers/serial/mpc52xx_uart.c
drivers/serial/uartlite.c
drivers/staging/comedi/interrupt.h
drivers/usb/gadget/goku_udc.c
drivers/usb/gadget/omap_udc.c
drivers/usb/gadget/pxa25x_udc.c
drivers/usb/otg/gpio_vbus.c
drivers/usb/otg/isp1301_omap.c

> Everything going into the 
> RNG should be made to go through an add_*_randomness interface only.
> Preferably not at a per-driver level.

Is that "Everything in general, with a few exceptions", or "__Everything__"?

If it is the latter I'll remove the ones that I'm responsible for, and send 
Sam something for checkpatch.pl to warn if this is used in the future.

-Robin
