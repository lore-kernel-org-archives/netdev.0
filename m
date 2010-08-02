From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH v2 2/2] macvtap: Implement multiqueue macvtap driver
Date: Mon, 2 Aug 2010 21:58:35 +0530
Message-ID: <OFE0F15F8D.2C34C2AD-ON65257773.00579311-65257773.005A60A9@in.ibm.com>
References: <20100802143304.1517.42494.sendpatchset@krkumar2.in.ibm.com> <20100802143310.1517.55824.sendpatchset@krkumar2.in.ibm.com> <201008021752.28475.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bhutchings@solarflare.com, davem@davemloft.net, mst@redhat.com,
	netdev@vger.kernel.org, therbert@google.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:43837 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355Ab0HBQ1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 12:27:15 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id o72GRCgt032087
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 21:57:12 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o72GRBKB3268624
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 21:57:11 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o72GRBSS000788
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 02:27:11 +1000
In-Reply-To: <201008021752.28475.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

Thanks for your comments. The declaration was in the 2nd patch
since the function was not used outside net/core/dev.c after the
1st patch is applied, but now I think you are right.

Regarding min/min_t, I had tried both and got this error:

"include/linux/if_macvlan.h:57: error: braced-group within expression
	allowed only inside a function"
Please let me know if there is any alternative (curly braces cannot be
used outside of functions). Otherwise one change required is to add:

#ifndef MIN
#endif

I will wait for a few hours and resubmit the patches.

thanks,

- KK

Arnd Bergmann <arnd@arndb.de> wrote on 08/02/2010 09:22:28 PM:

> Arnd Bergmann <arnd@arndb.de>
> 08/02/2010 09:22 PM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN
>
> cc
>
> davem@davemloft.net, bhutchings@solarflare.com,
> netdev@vger.kernel.org, mst@redhat.com, therbert@google.com
>
> Subject
>
> Re: [PATCH v2 2/2] macvtap: Implement multiqueue macvtap driver
>
> On Monday 02 August 2010, Krishna Kumar wrote:
> > Implement multiqueue facility for macvtap driver. The idea is that
> > a macvtap device can be opened multiple times and the fd's can be
> > used to register eg, as backend for vhost.
> >
> > Please review.
>
> Only two very minor points from my side:
>
> > diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
> > --- org/include/linux/netdevice.h   2010-07-25 16:57:07.000000000 +0530
> > +++ new/include/linux/netdevice.h   2010-08-02 16:05:57.000000000 +0530
> > @@ -2253,6 +2253,7 @@ static inline const char *netdev_name(co
> >     return dev->name;
> >  }
> >
> > +extern int skb_calculate_flow(struct net_device *dev, struct sk_buff
*skb);
> >  extern int netdev_printk(const char *level, const struct net_device
*dev,
> >            const char *format, ...)
> >     __attribute__ ((format (printf, 3, 4)));
>
> This logically belongs into the first patch.
>
> > diff -ruNp org/include/linux/if_macvlan.h
new/include/linux/if_macvlan.h
> > --- org/include/linux/if_macvlan.h   2010-08-02 15:32:33.000000000
+0530
> > +++ new/include/linux/if_macvlan.h   2010-08-02 15:32:33.000000000
+0530
> > @@ -40,6 +40,14 @@ struct macvlan_rx_stats {
> >     unsigned long      rx_errors;
> >  };
> >
> > +#define MIN(x, y)      (((x) < (y)) ? (x) : (y))
> > +
> > +/*
> > + * Maximum times a macvtap device can be opened. This can be used to
> > + * configure the number of receive queue, e.g. for multiqueue virtio.
> > + */
> > +#define MAX_MACVTAP_QUEUES   MIN(16, NR_CPUS)
> > +
>
> Please use the existing min() or min_t() macro instead of providing your
own.
>
>    Arnd

