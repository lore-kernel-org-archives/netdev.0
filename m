From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in ipv6_ifa_notify?
Date: Mon, 8 Nov 2004 18:34:42 +1100
Message-ID: <20041108073441.GA2200@gondor.apana.org.au>
References: <20041108061529.GA1774@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041108061529.GA1774@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 08, 2004 at 05:15:29PM +1100, herbert wrote:
> 
> Now the question is is it possible to get dupliate RTM_NEWADDR
> notifications?

Actually, it's easier than that.

RTM_DELADDR will call ip6_del_rt which will free the rt using
dst_free.  Since it is still referenced it gets put on the gc
list.  The next RTM_NEWADDR will put it back in the table.
>From this point onwards anything that gets linked after it will
be on the gc list!

Jeff/Arnaldo, could you please try shutting down an interface with
IPv6 addresses and bringing it back up a few times? This might be
the trigger we are looking for.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
