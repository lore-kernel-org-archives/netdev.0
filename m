From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Tue, 5 Jun 2007 00:53:03 +0200
Message-ID: <20070604225303.GG2711@elf.ucw.cz>
References: <200706031237.36773.rjw@sisk.pl> <20070604111112.GP4363@elf.ucw.cz> <200706041549.11277.rjw@sisk.pl> <1180991794.4356.31.camel@nigel.suspend2.net> <20070604224146.GE2711@elf.ucw.cz> <1180997344.4356.74.camel@nigel.suspend2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>, Peer Chen <peer.chen@uli.com.tw>
To: Nigel Cunningham <nigel@nigel.suspend2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:38381 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758475AbXFDWxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 18:53:13 -0400
Content-Disposition: inline
In-Reply-To: <1180997344.4356.74.camel@nigel.suspend2.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 2007-06-05 08:49:04, Nigel Cunningham wrote:
> Hi.
> 
> On Tue, 2007-06-05 at 00:41 +0200, Pavel Machek wrote:
> > Hi!
> > 
> > > > > > +#endif /* CONFIG_PM */
> > > > > 
> > > > > > @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver 
> > > > > >  	.id_table	= uli526x_pci_tbl,
> > > > > >  	.probe		= uli526x_init_one,
> > > > > >  	.remove		= __devexit_p(uli526x_remove_one),
> > > > > > +#ifdef CONFIG_PM
> > > > > > +	.suspend	= uli526x_suspend,
> > > > > > +	.resume		= uli526x_resume,
> > > > > > +#endif
> > > > > 
> > > > > ...so that this ifdef is not needed?
> > > > 
> > > > OK, why not.
> > > 
> > > Because it's uglier and #ifdef is the established way of doing things?
> > 
> > Actually the way I suggested is nicer, IIRC akpm invented it. It keeps
> > ifdefs localized around the block that _needs_ to be ifdefed.
> 
> The localised point is true. I'll also admit that 'nicer'/'uglier' is a
> matter of aesthetics and therefore personal opinion.
> 
> I guess that leaves the question, "What's the precedent to follow?" or
> "Is there a driver that's already got this new format?".

for example net/ne.c ...

pavel@amd:/data/l/linux/drivers$ grep "_suspend NULL" */*.c
leds/leds-ams-delta.c:#define ams_delta_led_suspend NULL
leds/leds-net48xx.c:#define net48xx_led_suspend NULL
leds/leds-s3c24xx.c:#define s3c24xx_led_suspend NULL
leds/leds-tosa.c:#define tosaled_suspend NULL
leds/leds-wrap.c:#define wrap_led_suspend NULL
misc/tifm_7xx1.c:#define tifm_7xx1_suspend NULL
misc/tifm_core.c:#define tifm_device_suspend NULL
net/3c509.c:#define el3_suspend NULL
net/forcedeth.c:#define nv_suspend NULL
net/ne.c:#define ne_drv_suspend NULL
parport/parport_ax88796.c:#define parport_ax88796_suspend NULL
rtc/rtc-at91rm9200.c:#define at91_rtc_suspend NULL
rtc/rtc-omap.c:#define omap_rtc_suspend NULL
rtc/rtc-s3c.c:#define s3c_rtc_suspend NULL
serial/8250_pnp.c:#define serial_pnp_suspend NULL
serial/atmel_serial.c:#define atmel_serial_suspend NULL
serial/s3c2410.c:#define s3c24xx_serial_suspend NULL
spi/pxa2xx_spi.c:#define pxa2xx_spi_suspend NULL
spi/spi_bfin5xx.c:#define bfin5xx_spi_suspend NULL
spi/spi_imx.c:#define spi_imx_suspend NULL
spi/spi_s3c24xx.c:#define s3c24xx_spi_suspend NULL
spi/spi_s3c24xx_gpio.c:#define s3c2410_spigpio_suspend NULL
video/arkfb.c:#define ark_pci_suspend NULL
video/au1100fb.c:#define au1100fb_drv_suspend NULL
video/s3c2410fb.c:#define s3c2410fb_suspend NULL
video/skeletonfb.c:#define xxxfb_suspend NULL
video/skeletonfb.c:#define xxxfb_suspend NULL
video/sm501fb.c:#define sm501fb_suspend NULL

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
