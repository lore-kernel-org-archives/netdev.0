From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Tue, 7 Jun 2005 09:14:05 +1000
Message-ID: <20050606231405.GA7385@gondor.apana.org.au>
References: <20050606124043.GA625@gondor.apana.org.au> <20050606.154653.64001264.davem@davemloft.net> <20050606230437.GA7172@gondor.apana.org.au> <20050606.160947.75190168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050606.160947.75190168.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 04:09:47PM -0700, David S. Miller wrote:
> 
> So you want to use this area as a sort-of temporary
> scratch pad for something other than scatterlist
> information?  That's interesting if so...

There are two possibilities:

1) We use it directly as a scratch buffer for now since the
frags are always linearised currently.

2) We have a list of lists of which this is simply a member.
The meta-list itself can then be stored on the stack since
each member is only 4 bytes.

We can go with 1) for now.  When it becomes possible for us
to not flatten the frags, we can switch to 2).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
