From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: r8169: page allocation failure
Date: Sun, 17 Oct 2004 17:47:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CJ5lg-0005eC-00@gondolin.me.apana.org.au>
References: <20041016204848.GB21849@electric-eye.fr.zoreil.com>
Cc: jkillius@arcor.de, netdev@oss.sgi.com, davem@davemloft.net,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com (Francois Romieu)
In-Reply-To: <20041016204848.GB21849@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> wrote:
> 
>> Oct 16 19:27:00 gate [<c022d975>]
>> Oct 16 19:27:00 gate [<c022ddb2>]
> 
> c022d8d0 T tcp_set_skb_tso_segs
> c022d920 t tcp_fragment
> c022dc70 t __pskb_trim_head

Good catch.  tcp_fragment's behaviour is broken when TSO is present.
We can start with a list of n 1-mss fragments and tcp_fragment will
end up allocating a continuous skb of n-1 mss bytes.

It should instead allocate a new skb of 1 mss.  I'll work on it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
