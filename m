From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 3/3] [LLC]: zero station mac source address
Date: Tue, 25 Mar 2008 14:18:38 +0900
Message-ID: <b25c3fa70803242218u672e0f14xbf4d6e5848a94e33@mail.gmail.com>
References: <47e76799.1cef600a.7b83.6fea@mx.google.com>
	 <20080324171924.GA22421@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:50601 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656AbYCYFSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 01:18:38 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1654605rvb.1
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 22:18:38 -0700 (PDT)
In-Reply-To: <20080324171924.GA22421@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/3/25, Arnaldo Carvalho de Melo <acme@redhat.com>:
> Em Mon, Mar 24, 2008 at 05:34:30PM +0900, joonwpark81@gmail.com escreveu:
> > From: Joonwoo Park <joonwpark81@gmail.com>
> >
> > The right next device of the lo can have zero dev_addr. e.g. bonding.
> >
> > Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> > ---
> >  net/llc/llc_core.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> >
> > diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
> > index 248b590..b871e10 100644
> > --- a/net/llc/llc_core.c
> > +++ b/net/llc/llc_core.c
> > @@ -19,6 +19,7 @@
> >  #include <linux/slab.h>
> >  #include <linux/string.h>
> >  #include <linux/init.h>
> > +#include <linux/etherdevice.h>
> >  #include <net/net_namespace.h>
> >  #include <net/llc.h>
> >
> > @@ -164,8 +165,9 @@ static int __init llc_init(void)
> >       struct net_device *dev;
> >
> >       dev = first_net_device(&init_net);
> > -     if (dev != NULL)
> > +     do {
> >               dev = next_net_device(dev);
> > +     } while (dev && is_zero_ether_addr(dev->dev_addr));
> >
> >       if (dev != NULL)
> >               memcpy(llc_station_mac_sa, dev->dev_addr, ETH_ALEN);
>
> Looks ok, but I think this is an area for further work, using just
> the first device in the list always was wrong, I was too lazy to fix it,
> but since you are working on it, please consider fixing this for good
> :-)
>
> - Arnaldo
>

Arnaldo,
Please give me more hints :-)

First off, I wondered 'we need llc_station_mac_sa?'
IMHO, dev->dev_addr of egress interface for llc sa would be fine.
Do you happen to think this?

Thanks,
Joonwoo
