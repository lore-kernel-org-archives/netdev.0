From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 11:15:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927111520.4f495b17.davem@davemloft.net>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBtzd-0000zI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBtzd-0000zI-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 21:48:33 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > -	if (tbl->entries > (tbl->hash_mask + 1))
> > +	if (tbl->entries > (tbl->hash_mask + 1)) {
> > +		write_lock_bh(&tbl->lock);
> >  		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
> > +		write_unlock_bh(&tbl->lock);
> > +	}
> 
> The locking should be outside the if block as otherwise you may grow
> unnecessarily or grow into the same size :)

I'm not going to do that, because then we're grabbing that lock
twice on every neigh create operation and I was trying hard
to avoid that overhead.
