From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Wed, 08 Sep 2004 17:07:56 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
References: <20040908065152.GC27886@wotan.suse.de>
Cc: hadi@cyberus.ca, ak@suse.de, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de (Andi Kleen)
In-Reply-To: <20040908065152.GC27886@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> wrote:
>
>> 1: means packet was not put on the ring. i.e if you return
>> 1, the toplayer will retry later with the same skb. 
>> [of course If you stash it on the ring, the danger is tx complete will
>> try to free it later while the toplayer code is still referencing it. A
>> good oops].
> 
> Actually when you return 1 then the kernel prints an ugly 
> message and it is considered a bug.  Here -1 is legal.

1 is legal in contexts where queueing occurs.  See for example
qdisc_restart().

It's only illegal here because this is the direct xmit path without
queueing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
