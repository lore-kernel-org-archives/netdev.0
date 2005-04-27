From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Wed, 27 Apr 2005 22:43:13 +1000
Message-ID: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au>
References: <426EB84C.90307@tpack.net>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tommy.christensen@tpack.net (Tommy Christensen)
In-Reply-To: <426EB84C.90307@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen <tommy.christensen@tpack.net> wrote:
> 
> A while back we had a very long thread about the queueing behavior of
> netdevices in a loss-of-carrier situation. This thread had the poetic
> subject: [patch 4/10] s390: network driver.

I remember that thread :) Thanks for chasing this up.

> The executive summary:

Agreed.

> The best solution seems to be to simply disable the queueing at the qdisc
> layer when this situation arises. That approach has been implemented in
> the patch below. Hasso Tepper <hasso@estpak.ee> reports succesfull testing
> of the patch with Quagga.

The idea is good.  However, the implementation has a problem in it.
You're relying on the watchdog which may not be there.  The watchdog
is only present if tx_timeout is defined.

Also, this still doesn't help us if the driver itself has a TX queue
that is hoarding the packets.  So the driver itself needs to make sure
that when the carrier goes off that its TX queue is flushed too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
