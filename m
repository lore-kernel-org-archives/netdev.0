From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 09:28:54 -0700
Message-ID: <20050907162854.GB24735@netnation.com>
References: <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17182.64751.340488.996748@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 04:45:03PM +0200, Robert Olsson wrote:

>  Packet processing happens in RX_SOFIRQ. NAPI or non-NAPI is no difference
>  with RCU deferred delete this should happen by the RCU-tasklet when 
>  tasklets are run after the real SOFTIRQ's.
> 
>  There is a limit for RCU work... maxbatch it's set to 10  you could back 
>  out the patch and try increase it 1000/10000 so we know this not prevent 
>  the freeing of entries. 

Yes, setting maxbatch to 10000 also results in working gc, though routing
throughput is about 5.7% higher when just calling dst_free directly.

>  Also RCU clearly states that is should be used in read-mostly situations
>  rDoS is outside this scope. Anyway it would be interesting to understand 
>  what's going on.

There was discussion about this before (recycling of existing entries is
also now impossible, as compared with 2.4).  It's a shame that this win
for the normal case also hurts the DoS case...and it really hurts when
the when the DoS case is the normal case.

Simon-
