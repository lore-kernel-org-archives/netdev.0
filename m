From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf 2/2] netfilter: nf_tables: add clone interface to
 expression operations
Date: Tue, 10 Nov 2015 18:58:05 +0000
Message-ID: <20151110185804.GG25929@macbook.localdomain>
References: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
 <1447173390-2993-3-git-send-email-pablo@netfilter.org>
 <20151110183034.GE25929@macbook.localdomain>
 <20151110183905.GA1656@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151110183905.GA1656@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.11, Pablo Neira Ayuso wrote:
> On Tue, Nov 10, 2015 at 06:30:34PM +0000, Patrick McHardy wrote:
> > >  	__module_get(src->ops->type->owner);
> > > -	memcpy(dst, src, src->ops->size);
> > > +	if (src->ops->clone) {
> > > +		memcpy(dst, src, sizeof(*src));
> > 
> > Why copy if we clone? The function should do a full initialization if it is
> > present I would say.
> 
> This is not copying the variable length data area of the expression,
> just the expression head.

Ah right. But that is only ->ops. We can set this directly, should generate
better code and be easier to understand.

> 
> > > +		err = src->ops->clone(dst, src);
> > > +		if (err < 0)
> > > +			return err;
> > > +	} else {
> > > +		memcpy(dst, src, src->ops->size);
> > > +	}
> > > +	return 0;
> > >  }
> > >  
> 
