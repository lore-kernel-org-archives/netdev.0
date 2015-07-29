From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] gianfar: Fix warnings when built on 64-bit
Date: Wed, 29 Jul 2015 23:04:46 +0200
Message-ID: <2331012.mZ9bDLS4JC@wuerfel>
References: <1438147477-393-1-git-send-email-scottwood@freescale.com> <4498062.4y369pLSmO@wuerfel> <1438185761.2993.333.camel@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:57206 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbbG2VFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:05:00 -0400
In-Reply-To: <1438185761.2993.333.camel@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 29 July 2015 11:02:41 Scott Wood wrote:
> On Wed, 2015-07-29 at 10:02 +0200, Arnd Bergmann wrote:
> > On Wednesday 29 July 2015 00:24:37 Scott Wood wrote:
> > > +#ifdef CONFIG_PM
> > >  static void lock_tx_qs(struct gfar_private *priv)
> > >  {
> > >     int i;
> > > @@ -580,6 +581,7 @@ static void unlock_tx_qs(struct gfar_private *priv)
> > >     for (i = 0; i < priv->num_tx_queues; i++)
> > >             spin_unlock(&priv->tx_queue[i]->txlock);
> > >  }
> > > +#endif
> > >  
> > 
> > This seems unrelated and should probably be a separate fix.
> 
> It's related in that it fixes a warning -- the 64-bit build didn't have 
> CONFIG_PM -- though I should have been clearer about that in the changelog.

Yes, that's what I meant: you can easily have a 32-bit build without
CONFIG_PM of course, and that would have the same problem.

> > 
> > You are fixing two problems here: the warning about a size cast, and
> > the fact that the driver is using the wrong pointer. I'd suggest
> > explaining it in the changelog.
> > 
> > Note that we normally rely on void pointer arithmetic in the kernel, so
> > I'd write it without the uintptr_t casts as 
> > 
> >       bdp_dma = lower_32_bits(rx_queue->rx_bd_dma_base + (base - bdp));
> 
> But those aren't void pointers, and rx_bd_dma_base isn't a pointer, so you'd 
> get the wrong answer doing that.

Ah, right.

	Arnd
