From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: design for TSO performance fix
Date: Fri, 28 Jan 2005 12:31:53 +1100
Message-ID: <E1CuKzJ-0001mY-00@gondolin.me.apana.org.au>
References: <20050127163146.33b01e95.davem@davemloft.net>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050127163146.33b01e95.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> Ok, here is the best idea I've been able to come up with
> so far.

It sounds great!

> 2) As a result of #1, all the pcount crap goes away.
>   The need for two MSS state variables (mss_cache,
>   and mss_cache_std) and assosciated complexity is
>   eliminated as well.

Does this mean that we'll start counting bytes instead
of packets?

If not then please let me know on how you plan to do the
packet counting.
 
> static struct sk_buff *tcp_tso_build(struct sk_buff *head, int mss, int num)
> {
>        struct sk_buff *skb;
>        struct sock *sk;
>        int err;
> 
>        sk = head->sk;
>        skb = alloc_skb(sk->sk_prot->max_header, GFP_ATOMIC);

The other good thing about this is that if we do this for all
packets including non-TSO ones, then the TCP stack doesn't have
to own the TCP/IP headers at all.  Then we can stop worrying
about the TSO/COW mangling.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
