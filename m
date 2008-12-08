From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Mon, 08 Dec 2008 15:17:53 +0000
Message-ID: <1228749474.3177.10.camel@achroite>
References: <49394379.9000501@simtec.co.uk>
	 <1228499870.3520.66.camel@achroite>  <1228734318.19000.84.camel@petitemort>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsilvers@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:41619 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754238AbYLHPR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 10:17:57 -0500
In-Reply-To: <1228734318.19000.84.camel@petitemort>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-08 at 11:05 +0000, Daniel Silverstone wrote:
[...]
> > > +static inline struct ks8695_priv *
> > > +ks8695_get_priv(struct net_device *ndev)
> > Don't use ndev->priv, use netdev_priv(ndev).  Which makes this function
> > redundant, except for the implicit pointer conversion.
> 
> Aah, I didn't know about that one, updated.

Until recently they have been equivalent by default; direct access to
priv is now deprecated and it will be removed.

[...]
> > > +                       /* Free the packet from the ring */
> > > +                       ksp->tx_ring[buff_n].data_ptr = 0;
> > Clearing data_ptr seems redundant.  The TDES_OWN flag indicates whether
> > the descriptor is pending and the skb pointer indicates whether a buffer
> > needs to be freed.
> 
> This was simply me being neat. If you feel that it is an overly
> expensive thing to do then I shall elide it.

It's hardly expensive, but the comment is inaccurate because this field
does not indicate whether the descriptor is free or not.

[...]
> > > +               buff_n = (buff_n + 1) % MAX_RX_DESC;
> > That's another expensive division.
> 
> I was expecting the compiler to go "aaha! mod <powerof2> => bitwise
> mask".

It can only do this if it knows the dividend is non-negative.

I wrote "another" in reference to my comment further down which I
actually wrote earlier.

[...]
> > > +static int
> > > +ks8695_init_net(struct ks8695_priv *ksp)
> 
> > The RX and TX IRQ handlers need to be released in case the TX or link
> > IRQ setup fails.
> 
> The only time that this might fail, I.E. initial device open, we check
> the return value of ks8695_init_net and call ks86985_shutdown if needed
> which will release the IRQs.
> 
> It seemed daft to replicate the cleanup code in two places. If however
> that is the accepted style then I shall add the cleanups to
> ks8695_init_net() -- Is my method acceptable or should I change?

Local cleanup is normal but I think this is OK.

[...]
> > > +               dev_info(ksp->dev, "ks8695 ethernet (%s) MAC: %s\n",
> > > +                        ks8695_port_type(ksp), print_mac(mac, ndev->dev_addr));
> > Use %pM to format a MAC address instead of %s and print_mac().
> 
> I believe this must be new since 2.6.27 so I'll get that as I move to
> net-next-2.6, thanks for the info.

Yes, the %p<modifier> formats are a recent invention.

[...]
> Thank you very much for your comments. Once this pull of net-next-2.6 is
> complete and I can do my forward-porting, I'll issue a new patch. Can I
> ask what the magic runes are which I need in subject / precis to
> actually request that my driver be merged rather than just reviewed?

Unless you add [RFC] to the subject it's implicit that you want the
patch merged.  You can check the patch status at
<http://patchwork.ozlabs.org/project/netdev/list/>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

