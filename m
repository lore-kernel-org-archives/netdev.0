From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in
 restart()
Date: Thu, 19 Jun 2008 22:20:42 +0400
Message-ID: <20080619222042.2910e284@vitb.ru.mvista.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>
	<8496f91a0806181145w62d57a7fua767c8036f2261aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Laurent Pinchart" <laurentp@cse-semaphore.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:23327 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753897AbYFSSUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:20:38 -0400
In-Reply-To: <8496f91a0806181145w62d57a7fua767c8036f2261aa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jun 2008 22:45:57 +0400
"Matvejchikov Ilya" <matvejchikov@gmail.com> wrote:

> I'm glad that you have corrected it. Half a year ago I pointed out
> that there was such a mistake:
> http://patchwork.ozlabs.org/linuxppc/patch?id=10700
> 
You've used -embedded ML, and patch wasn't noticed... I can add your S-O-B line if that will make you fill better :) 

-Vitaly
> Thanks.
> 
> 2008/6/18 Laurent Pinchart <laurentp@cse-semaphore.com>:
> > The restart() function is called when the link state changes and resets
> > multicast and promiscous settings. This patch restores those settings at the
> > end of restart().
> >
> > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > ---
> >  drivers/net/fs_enet/mac-fcc.c     |    3 +++
> >  2 files changed, 4 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
> > index ce40cf9..1a95cf1 100644
> > --- a/drivers/net/fs_enet/mac-fcc.c
> > +++ b/drivers/net/fs_enet/mac-fcc.c
> > @@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
> >                C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
> >
> >        S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
> > +
> > +       /* Restore multicast and promiscous settings */
> > +       set_multicast_list(dev);
> >  }
> >
> >  static void stop(struct net_device *dev)
> > --
> > 1.5.0
> >
> > --
> > Laurent Pinchart
> > CSE Semaphore Belgium
> >
> > Chaussee de Bruxelles, 732A
> > B-1410 Waterloo
> > Belgium
> >
> > T +32 (2) 387 42 59
> > F +32 (2) 387 42 75
> >


-- 
Sincerely, 
Vitaly
