From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: initialise the itag variable in __mkroute_input
Date: Thu, 22 May 2014 11:13:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405221111190.8647@dtop>
References: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com> <CAADnVQ+bvNGhrEqC3P3DqApjcXM3OUUHqTWJ+iwVmC3f4PguEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: roy.qing.li@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:47733 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbaEVSNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 14:13:25 -0400
In-Reply-To: <CAADnVQ+bvNGhrEqC3P3DqApjcXM3OUUHqTWJ+iwVmC3f4PguEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 22 May 2014, Alexei Starovoitov wrote:

> On Thu, May 22, 2014 at 1:36 AM,  <roy.qing.li@gmail.com> wrote:
> > From: Li RongQing <roy.qing.li@gmail.com>
> >
> > the value of itag is a random value from stack, and may not be initiated by
> > fib_validate_source, which called fib_combine_itag if CONFIG_IP_ROUTE_CLASSID
> > is not set
> >
> > This will make the cached dst uncertainty
> >
> > Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>
> Nice catch. Indeed. I think it's needed for stable.
>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Dormando,
> can you check whether your config has CONFIG_IP_ROUTE_CLASSID or not?
> The way I'm reading the code, it shouldn't be causing your failures,
> but that part
> of code is hairy..

CONFIG_IP_ROUTE_CLASSID=y

There're a lot of negatives in that description, but if this patch only
affects you if CONFIG_IP_ROUTE_CLASSID=n?

> > ---
> >  net/ipv4/route.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 50e1e0f..4154eb7 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1526,7 +1526,7 @@ static int __mkroute_input(struct sk_buff *skb,
> >         struct in_device *out_dev;
> >         unsigned int flags = 0;
> >         bool do_cache;
> > -       u32 itag;
> > +       u32 itag = 0;
> >
> >         /* get a working reference to the output device */
> >         out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
> > --
> > 1.7.10.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
