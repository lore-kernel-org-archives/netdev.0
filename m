From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC] [PATCH 2/7] crypto: authenc - convert to ahash
Date: Mon, 20 Jul 2009 08:26:43 +0200
Message-ID: <20090720062643.GA20288@secunet.com>
References: <20090716111548.GP20288@secunet.com> <20090716111747.GR20288@secunet.com> <20090717.100334.160030992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090717.100334.160030992.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 17, 2009 at 10:03:34AM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 16 Jul 2009 13:17:47 +0200
> 
> > +	/* 
> > +	 * head must be a scatterlist with two entries.
> > +	 * We remove a potentially set termination bit
> > +	 * on the first enty.
> > +	 */
> > +	head->page_link &= ~0x02;
> > +
> >  	if (chain) {
> >  		head->length += sg->length;
> 
> Isn't there some interface to do this, rather than revealing the
> implementation details of how the scatter list marking works?

We have sg_mark_end() which sets the termination bit on a sg list entry,
but we don't have an interface to remove the termination bit from a sg
list entry. 

> 
> If not, such an interface should be created and used here.  Otherwise
> any change in that implementation will break this code.

A grep over the kernel tree showed that just the block and the
crypto-layer doing this to chain sg lists. So we could create
sg_unmark_end() and use it there. If desired, I would do it.
