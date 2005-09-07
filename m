From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 09:55:28 -0700
Message-ID: <20050907165528.GC24735@netnation.com>
References: <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <20050907011959.GA25725@yakov.inr.ac.ru> <17183.309.317160.103056@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17183.309.317160.103056@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 05:03:17PM +0200, Robert Olsson wrote:

>  It was quite some time since I saw dst cache overflow and we use 2.6 
>  in infrastructure. Anyway I was able to "tune" route cache so I see
>  in our lab system on a SMP box. I think UP and SMP behaves the same 
>  but with UP we could disable the deferred delete as Simon tested.
> 
>  I don't know if anything happen in 2.6.9 I don't think so. But any
>  improvement in drivers or FIB lookup may increase the burden so we get
>  overflows.

I believe what I've been seeing is a _reduction_ in performance in both
the e1000 driver and other parts of the kernel that result in it handling
these packets much more slowly than in 2.4.  The dst cache only overflows
when the thing is completely pegged, so earlier 2.6 versions that were a
little faster (eg: 2.6.11) were only overflowing occasionally depending
on the speed of the input traffic.

I've only been able to send 179 Mbps from one box, so that's what has
been killing it.  On the receiving end, 2.6.13-rc6 with the direct
dst_free now drops a bunch but stays responsive with working GC,
routing through about 69.6 Mbps, while 2.4.27 routes 103 Mbps worth.

If it would be helpful, I can build some scripts to do benchmarks with
different kernel combinations, and run it on a bunch of different kernel
versions.

Simon-
