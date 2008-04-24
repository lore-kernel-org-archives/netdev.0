From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [patch 10/15] m68k: Some network drivers do not check the platform
Date: Thu, 24 Apr 2008 20:51:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804242045510.21224@anakin>
References: <20080424182940.424312704@mail.of.borg> <20080424183242.943446357@mail.of.borg>
 <20080424184256.GA8531@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wilson.telenet-ops.be ([195.130.132.42]:51248 "EHLO
	wilson.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbYDXSvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 14:51:19 -0400
In-Reply-To: <20080424184256.GA8531@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Apr 2008, Christoph Hellwig wrote:
> On Thu, Apr 24, 2008 at 08:29:50PM +0200, Geert Uytterhoeven wrote:
> > +++ b/drivers/net/macmace.c
> > @@ -781,6 +781,9 @@ static int __init mac_mace_init_module(v
> >  {
> >  	int err;
> >  
> > +	if (!MACH_IS_MAC)
> > +		return -ENODEV;
> > +
> >  	if ((err = platform_driver_register(&mac_mace_driver))) {
> >  		printk(KERN_ERR "Driver registration failed\n");
> >  		return err;
> 
> This is rather odd.  The whole point of the platform_driver
> infrastructure is that the arch code only registers it if it's present
> and then the driver can match for it.  So the right fix here is to move
> the platform_driver_register(&mac_mace_driver) into the mac arch setup

I suppose you mean platform_*device*_register(), not
platform_*driver*_register()?

> code.  A quick grep shows this is a quite common pattern for m68k
> drivers.

I know. That's work in progress.

All these drivers predate the platform device framework and have been converted
to this framework a while ago, without separating the actual platform drivers
and platform devices.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
