From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Sun, 19 Sep 2004 20:17:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919201735.3d9e1d6d.davem@davemloft.net>
References: <1095640781.1047.168.camel@jzny.localdomain>
	<E1C9Edi-00033O-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C9Edi-00033O-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 13:14:54 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> jamal <hadi@cyberus.ca> wrote:
> > 
> > --- a/net/ipv4/fib_hash.c       2004/09/20 00:35:16     1.1
> > +++ b/net/ipv4/fib_hash.c       2004/09/20 00:36:16
> > @@ -915,7 +915,7 @@
> >             iter->zone = iter->zone->fz_next) {
> >                int maxslot;
> > 
> > -               if (!iter->zone->fz_next)
> > +               if (!iter->zone->fz_nent)
> >                        continue;
> 
> Good catch.  There seems to be another problem with the seq_file
> conversion.  Why is this check only in fib_get_first(), but not
> in fib_get_next()?
> 
> Either it's needed in fib_get_next() as well, or it can be removed here.

It's an optimization, the hash list traversal will find no entries
even if we don't do this test.

It does belong in fib_get_next(), so I'll happily add it there.
Thanks.
