From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Wed, 8 Sep 2004 09:24:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908072408.GI27886@wotan.suse.de>
References: <20040908065152.GC27886@wotan.suse.de> <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, hadi@cyberus.ca, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2004 at 05:07:56PM +1000, Herbert Xu wrote:
> Andi Kleen <ak@suse.de> wrote:
> >
> >> 1: means packet was not put on the ring. i.e if you return
> >> 1, the toplayer will retry later with the same skb. 
> >> [of course If you stash it on the ring, the danger is tx complete will
> >> try to free it later while the toplayer code is still referencing it. A
> >> good oops].
> > 
> > Actually when you return 1 then the kernel prints an ugly 
> > message and it is considered a bug.  Here -1 is legal.
> 
> 1 is legal in contexts where queueing occurs.  See for example
> qdisc_restart().

I agree my sentence was misleading. 

Basically the distinction here is:

1 is for flow control 
-1 is for lock contention

I think it's better to separate them because it minimizes the risk
of breaking old drivers.

> 
> It's only illegal here because this is the direct xmit path without
> queueing.

You are thinking of the wrong patch. This patch is changing qdisc_restart

-Andi
