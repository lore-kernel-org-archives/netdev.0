From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Wed, 8 Sep 2004 13:47:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908134713.1bcd46d3.davem@davemloft.net>
References: <20040908065152.GC27886@wotan.suse.de>
	<E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	<20040908072408.GI27886@wotan.suse.de>
	<1094629677.1089.155.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1094629677.1089.155.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 08 Sep 2004 03:47:57 -0400
jamal <hadi@cyberus.ca> wrote:

> On Wed, 2004-09-08 at 03:24, Andi Kleen wrote:
> > On Wed, Sep 08, 2004 at 05:07:56PM +1000, Herbert Xu wrote:
> > > Andi Kleen <ak@suse.de> wrote:
> > > >
> > > >> 1: means packet was not put on the ring. i.e if you return
> > > >> 1, the toplayer will retry later with the same skb. 
> > > >> [of course If you stash it on the ring, the danger is tx complete will
> > > >> try to free it later while the toplayer code is still referencing it. A
> > > >> good oops].
> > > > 
> > > > Actually when you return 1 then the kernel prints an ugly 
> > > > message and it is considered a bug.  Here -1 is legal.
> 
> Is this an effect of  your code? This is not so in existing code.

We are merely moving the sch_generic.c locking logic into the
drivers.  The behavior is entirely equivalent except that one
level of unnecessary locking has been removed.

I think his change is valid, will not break existing drivers (as
you mentioned as well Jamal), and works well for the cases he has
shown patches of.  So I'm going to apply his patch.

BTW, if we are really concerned about some existing driver returning
-1 from hard_start_xmit() without the new feature flag being enabled,
we can test for that and log a debugging message if it happens.
