From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Sat, 15 Jan 2005 16:45:47 +1100
Message-ID: <20050115054547.GA15860@gondor.apana.org.au>
References: <20050114120322.GA28449@gondor.apana.org.au> <20050114110352.23c94ab9.davem@davemloft.net> <20050114203452.GA1277@gondor.apana.org.au> <20050114132757.4ca3153a.davem@davemloft.net> <20050114213829.GA12454@gondor.apana.org.au> <20050114133611.69ff0bb2.davem@davemloft.net> <20050114215504.GA12569@gondor.apana.org.au> <20050114140426.5cf06f0c.davem@davemloft.net> <20050114224745.GA13180@gondor.apana.org.au> <20050114205543.5acb0d68.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114205543.5acb0d68.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2005 at 08:55:43PM -0800, David S. Miller wrote:
> 
> Doing the adjustments at tcp_write_xmit() time also runs into the
> problem you mentioned where we're just blindly subtracting from
> sk_forward_alloc.

Not really because what we're doing there is increasing sk_forward_alloc,
just as we do in tcp_trim_head.

Anyway, I'm not terribly attached to that idea since we're doing
a page's worth of data each time around the loop anyway so it's
not too bad.
 
> Here's a patch against current BK that tries to do that.  See any
> holes? :-)

Just one little problem :)

> +		if (sk->sk_forward_alloc < copy &&
> +		    !sk_stream_mem_schedule(sk, copy, 0))

You want to have sk->sk_allocation here instead of 0.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
