From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 20:05:48 +1000
Message-ID: <E1DWAZg-0006aD-00@gondolin.me.apana.org.au>
References: <20050511.223036.39664020.davem@davemloft.net>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050511.223036.39664020.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave:

I've got a number of comments for your patch which I will send once
I've finished reading it all.

David S. Miller <davem@davemloft.net> wrote:
> 
> I don't know, maybe we can do something clever with the
> skb_shinfo(skb)->frag_list pointer.

This was in fact going to be one of my comments :) 

What we could do is get the TSO drivers to all implement NETIF_F_FRAGLIST.
Once they do that, you can simply chain up the skb's and send it off to
them.  The coalescing will need to be done in the drivers.  However, that's
not too bad because coalescing only has to be done at the skb boundaries.

In fact, this is how we can simplify the unwinding stuff in your
skb_append_pages function.  Because the coalescing only needs to occur
between skb's, you only need to check the first frag to know whether it
can be coalesced or not.  This means that the unwinding stuff can mostly
go away.

We'll have to watch out for retransmissions of the frame with a non-null
frag_list pointer.  They will need to be copied if their clone is still
hanging around.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
