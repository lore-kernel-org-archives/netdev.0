From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] rhashtable: fix for resize events during table walk
Date: Mon, 6 Jul 2015 15:52:30 +0200
Message-ID: <20150706135230.GC15324@orbit.nwl.cc>
References: <1436184102-19175-1-git-send-email-phil@nwl.cc>
 <20150706133040.GA22723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, daniel@iogearbox.net, geert@linux-m68k.org,
	mroos@linux.ee
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150706133040.GA22723@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 06, 2015 at 09:30:40PM +0800, Herbert Xu wrote:
> On Mon, Jul 06, 2015 at 02:01:42PM +0200, Phil Sutter wrote:
> > diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> > index a60a6d3..e36b94b 100644
> > --- a/lib/rhashtable.c
> > +++ b/lib/rhashtable.c
> > @@ -585,6 +585,7 @@ void *rhashtable_walk_next(struct rhashtable_iter *iter)
> >  	struct bucket_table *tbl = iter->walker->tbl;
> >  	struct rhashtable *ht = iter->ht;
> >  	struct rhash_head *p = iter->p;
> > +	void *rc = NULL;
> >  
> >  	if (p) {
> >  		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
> > @@ -617,12 +618,12 @@ next:
> >  	if (iter->walker->tbl) {
> >  		iter->slot = 0;
> >  		iter->skip = 0;
> > -		return ERR_PTR(-EAGAIN);
> > +		rc = ERR_PTR(-EAGAIN);
> >  	}
> >  
> >  	iter->p = NULL;
> 
> I think a simpler fix would be to move "iter->p = NULL" before
> the if statement.

Done. Thanks for the review!

Cheers, Phil
