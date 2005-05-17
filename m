From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 08:11:01 +1000
Message-ID: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au>
References: <20050517.104947.112621738.davem@davemloft.net>
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050517.104947.112621738.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
>
> Decreasing ipfrag_time is also not an option, because then

Here is a possible solution to this:

Instead of measuring the distance using time, let's measure it
in terms of packet counts.  So every time we receive a fragmented
packet, we find all waiting fragments with the same src/dst pair.
If the id is identical we perform reassembly, if it isn't we increase
a counter in that fragment.  If the counter exceeds a threshold,
we drop the fragment.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
