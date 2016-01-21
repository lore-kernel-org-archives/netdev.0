From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 26/28] dsa: Convert mv88e6xxx into a library allowing
 driver modules
Date: Thu, 21 Jan 2016 22:54:09 +0100
Message-ID: <20160121215409.GM9991@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-27-git-send-email-andrew@lunn.ch>
 <567DB98B.1070709@gmail.com>
 <87twm639kc.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40566 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbcAUVyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 16:54:12 -0500
Content-Disposition: inline
In-Reply-To: <87twm639kc.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> -module_platform_driver(mv88e6123_driver);
> >>  
> >> +static int __init mv88e6123_init(void)
> >> +{
> >> +	register_switch_driver(&mv88e6123_switch_driver);
> >> +
> >> +	return platform_driver_register(&mv88e6123_driver);
> >> +}
> >> +
> >> +static void __exit mv88e6123_exit(void)
> >> +{
> >> +	platform_driver_unregister(&mv88e6123_driver);
> >> +	unregister_switch_driver(&mv88e6123_switch_driver);
> >> +}
> >
> > I think Vivien had started something like this, but it could be nice to
> > have a helper function/macro which reduces the boilerplate code, not
> > critical for now though.
> 
> Indeed I did suggest this macro and exporting in the past, without
> success though:
> 
>     https://lkml.org/lkml/2015/5/2/152

My reworked patchset uses macros. I also had to change the order of
some of these patches. Otherwise i had modules with two init and exit
functions!

	Andrew
