From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Tue, 25 Mar 2008 21:55:55 +0100
Message-ID: <200803252155.56082.florian.fainelli@telecomint.eu>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803192217.25860.florian.fainelli@telecomint.eu> <20080319215535.GB24710@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:57281 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbYCYUuY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 16:50:24 -0400
In-Reply-To: <20080319215535.GB24710@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Francois,

Le mercredi 19 mars 2008, Francois Romieu a =E9crit=A0:
>                      ^ space before tab

=46ixed.

> If the allocation fails, the driver will have to handle a shorter
> than expected ring (it is probably ok, I have not checked it). You
> may consider initializing the link field for each descriptor if
> possible. See epic_init_ring() for some inspiration.

That is why I use the i variable such that if a break in the loop happe=
ns, the=20
ring and last/first decscriptors are properly set.

> The irqs will be disabled for whatever device shares them...
>
> [...]
>
> > +	free_irq(lp->rx_irq, dev);
> > +	free_irq(lp->tx_irq, dev);
> > +	free_irq(lp->ovr_irq, dev);
> > +	free_irq(lp->und_irq, dev);
>
> ... and they will not be enabled again.
>
> You should avoid disable_irq here and disable the irq with some
> korina register write prior to free_irq instead.

Ethernet MAC datasheet does not seem to mention a way to disable IRQ un=
less=20
reseting the ethernet logic itself. Since this MAC is used in an embedd=
ed=20
system, closing the ethernet driver usually mean shutting down the devi=
ce as=20
well. I will try to work around this.

> It will work as is but you could merge both of those in a single
> variable (name it 'rc' and the consequences will appear directly
> in the diff between this patch and the next version).

=46ixed, must have been particularly braindead not to realize that befo=
re.
