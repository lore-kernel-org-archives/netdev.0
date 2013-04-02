From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Freescale FEC: fall back to random address
Date: Tue, 2 Apr 2013 13:35:32 +0200
Message-ID: <20130402113532.GA8880@amd.pavel.ucw.cz>
References: <20130331210605.GA29191@amd.pavel.ucw.cz>
 <CAHrpEqSVUc1yedCoyOrRoxkjY7=N_pCDB1F7-WvRaP+4UEY68A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	Frank.Li@freescale.com, netdev@vger.kernel.org, davem@davemloft.net
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:42255 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760181Ab3DBLfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 07:35:33 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqSVUc1yedCoyOrRoxkjY7=N_pCDB1F7-WvRaP+4UEY68A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> I think it is okay.

Ok, now... is there someone maintianing Freescale FEC? Or, Dave, can
you merge the patch?

Thanks,
								Pavel


> 2013/4/1 Pavel Machek <pavel@denx.de>:
> > If there's no valid ethernet address, fall back to randomly generated
> > one.
> >
> > (Yes, I need to get newer u-boot for the board, but as the only
> > available one is from 2009... this might be good idea).
> >
> > Signed-off-by: Pavel Machek <pavel@denx.de>
> >
> >
> > index e3f3937..5a7d1e1 100644
> > pp--- a/drivers/net/ethernet/freescale/fec.c
> > +++ b/drivers/net/ethernet/freescale/fec.c
> > @@ -906,6 +914,16 @@ static void fec_get_mac(struct net_device *ndev)
> >                 iap = &tmpaddr[0];
> >         }
> >
> > +       /*
> > +        * 5) random mac address
> > +        */
> > +       if (!is_valid_ether_addr(iap)) {
> > +               /* Report it and use a random ethernet address instead */
> > +               netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
> > +               random_ether_addr(iap);
> > +               netdev_info(ndev, "Using random MAC address: %pM\n", iap);
> > +       }
> > +
> >         memcpy(ndev->dev_addr, iap, ETH_ALEN);
> >
> >         /* Adjust MAC if using macaddr */

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
