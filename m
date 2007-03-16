From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/6] IrDA: IrLAP raw mode
Date: Fri, 16 Mar 2007 22:06:59 +0200
Message-ID: <20070316200659.GA19314@sortiz.org>
References: <20070314192331.GD3397@sortiz.org>
	<200703161102.06417.netdev@axxeo.de>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Ingo Oeser <netdev-BkyiQQGWkgE@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200703161102.06417.netdev-BkyiQQGWkgE@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

On Fri, Mar 16, 2007 at 11:02:04AM +0100, Ingo Oeser wrote:
> > --- /dev/null
> > +++ b/include/net/irda/irlap_raw.h
> > @@ -0,0 +1,27 @@
> > +/*
> > + * Copyright (C) 2007 Samuel Ortiz (samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org)
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License as
> > + * published by the Free Software Foundation, version 2.
> > + *
> > + */
> > +
> > +#ifndef _IRLAP_RAW_H
> > +#define _IRLAP_RAW_H
> > +
> > +#ifdef CONFIG_IRDA_RAW
> > +
> > +int irlap_raw_recv_frame(struct sk_buff *skb, struct net_device *dev);
> > +int irlap_raw_register_device(struct net_device * dev);
> > +int irlap_raw_unregister_device(struct net_device * dev);
> > +
> > +#else
> > +
> > +#define irlap_raw_recv_frame(skbuff, netdev)
> > +#define irlap_raw_register_device(netdev)
> > +#define irlap_raw_unregister_device(netdev)
> 
> This stuff is usually done this way (functions, which just check arguments and do nothing):

Since those are exported symbols, I think it makes sense to do these checks.

> 
> I would suggest a small helper function here, which compiles into a constant, 
> if raw_mode is not compiled in.
> 
> like
This would prevent us from adding #ifdefs in the core IrDA code: I'll go for
it.

Thanks for the comments.

Cheers,
Samuel.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
