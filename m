From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [5/6]: Dynamic neigh hash table growth
Date: Mon, 27 Sep 2004 12:11:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121120.56511b32.davem@davemloft.net>
References: <20040923225127.10b0ef68.davem@davemloft.net>
	<E1CBtl8-0000w8-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBtl8-0000w8-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 21:33:34 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David S. Miller <davem@davemloft.net> wrote:
> >
> > +static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
> > +{
> > +       struct neighbour **new_hash, **old_hash;
> > +       unsigned int i, new_hash_mask, old_entries;
> > +
> > +       BUG_ON(new_entries & (new_entries - 1));
> > +       new_hash = neigh_hash_alloc(new_entries);
> 
> Perhaps it'd be better to bound it based on MAX_ORDER rather than waiting
> for neigh_hash_alloc() to fail?

After reading this email I was about to add the check,
but then again, __get_free_pages() handles this case
not all that suboptimally.

I don't think it'll be a problem in practice.
