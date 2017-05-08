From: Julia Lawall <julia.lawall@lip6.fr>
Subject: RE: [PATCH] net: dsa: loop: Check for memory allocation failure
Date: Mon, 8 May 2017 20:32:23 +0800 (SGT)
Message-ID: <alpine.DEB.2.20.1705082031280.3440@hadrien>
References: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr> <063D6719AE5E284EB5DD2968C1650D6DCFFE715E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: 'Christophe JAILLET' <christophe.jaillet@wanadoo.fr>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:51259
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750853AbdEHMcb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 08:32:31 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFE715E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 8 May 2017, David Laight wrote:

> From: Christophe JAILLET
> > Sent: 06 May 2017 06:30
> > If 'devm_kzalloc' fails, a NULL pointer will be dereferenced.
> > Return -ENOMEM instead, as done for some other memory allocation just a
> > few lines above.
> ...
> > --- a/drivers/net/dsa/dsa_loop.c
> > +++ b/drivers/net/dsa/dsa_loop.c
> > @@ -256,6 +256,9 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
> >  		return -ENOMEM;
> >
> >  	ps = devm_kzalloc(&mdiodev->dev, sizeof(*ps), GFP_KERNEL);
> > +	if (!ps)
> > +		return -ENOMEM;
> > +
> >  	ps->netdev = dev_get_by_name(&init_net, pdata->netdev);
> >  	if (!ps->netdev)
> >  		return -EPROBE_DEFER;
>
> On the face if it this code leaks like a sieve.

I don't think so.  The allocations (dsa_switch_alloc and devm_kzalloc) use
devm functions.

julia
