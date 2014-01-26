From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2] net: add and use skb_gso_transport_seglen()
Date: Sun, 26 Jan 2014 10:19:48 +0100
Message-ID: <20140126091948.GE24041@breakpoint.cc>
References: <1390690127-559-1-git-send-email-fw@strlen.de>
 <1390690127-559-2-git-send-email-fw@strlen.de>
 <1390699688.27806.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34115 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750987AbaAZJTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 04:19:52 -0500
Content-Disposition: inline
In-Reply-To: <1390699688.27806.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2014-01-25 at 23:48 +0100, Florian Westphal wrote:
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -45,6 +45,7 @@
> >  #include <linux/mm.h>
> >  #include <linux/interrupt.h>
> >  #include <linux/in.h>
> > +#include <linux/tcp.h>
> >  #include <linux/inet.h>
> >  #include <linux/slab.h>
> >  #include <linux/netdevice.h>
> > @@ -71,6 +72,8 @@
> >  #include <trace/events/skb.h>
> >  #include <linux/highmem.h>
> >  
> > +#include <uapi/linux/udp.h>
> 
> 
> Normally you should not use uapi/

I added this include to ensure sizeof(struct udphdr) works.
I'll change it to linux/udp.h

> > diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> > index 887e672..837a61b 100644
> > --- a/net/sched/sch_tbf.c
> > +++ b/net/sched/sch_tbf.c
> 
> It seems you forgot to remove from this file this include :
> 
> #include <net/tcp.h>

Indeed, thanks for spotting this.

> Otherwise, this seems good, thanks !

Thanks for reviewing Eric!
