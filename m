From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: 08 Sep 2004 03:47:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094629677.1089.155.camel@jzny.localdomain>
References: <20040908065152.GC27886@wotan.suse.de>
	 <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	 <20040908072408.GI27886@wotan.suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040908072408.GI27886@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-08 at 03:24, Andi Kleen wrote:
> On Wed, Sep 08, 2004 at 05:07:56PM +1000, Herbert Xu wrote:
> > Andi Kleen <ak@suse.de> wrote:
> > >
> > >> 1: means packet was not put on the ring. i.e if you return
> > >> 1, the toplayer will retry later with the same skb. 
> > >> [of course If you stash it on the ring, the danger is tx complete will
> > >> try to free it later while the toplayer code is still referencing it. A
> > >> good oops].
> > > 
> > > Actually when you return 1 then the kernel prints an ugly 
> > > message and it is considered a bug.  Here -1 is legal.

Is this an effect of  your code? This is not so in existing code.

> > 1 is legal in contexts where queueing occurs.  See for example
> > qdisc_restart().
> 
> I agree my sentence was misleading. 
> 
> Basically the distinction here is:
> 
> 1 is for flow control 
> -1 is for lock contention
> 
> I think it's better to separate them because it minimizes the risk
> of breaking old drivers.
> 

Dont see how its going to break old drivers since they wont be making
this kind of call anyways.

In both cases it is semantically a flow control i.e "transmit path is
busy"

cheers,
jamal
