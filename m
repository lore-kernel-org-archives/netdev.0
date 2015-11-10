From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf 2/2] netfilter: nf_tables: add clone interface to
 expression operations
Date: Tue, 10 Nov 2015 19:59:39 +0100
Message-ID: <20151110185939.GA1919@salvia>
References: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
 <1447173390-2993-3-git-send-email-pablo@netfilter.org>
 <20151110183034.GE25929@macbook.localdomain>
 <20151110183905.GA1656@salvia>
 <20151110185804.GG25929@macbook.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151110185804.GG25929@macbook.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 06:58:05PM +0000, Patrick McHardy wrote:
> On 10.11, Pablo Neira Ayuso wrote:
> > On Tue, Nov 10, 2015 at 06:30:34PM +0000, Patrick McHardy wrote:
> > > >  	__module_get(src->ops->type->owner);
> > > > -	memcpy(dst, src, src->ops->size);
> > > > +	if (src->ops->clone) {
> > > > +		memcpy(dst, src, sizeof(*src));
> > > 
> > > Why copy if we clone? The function should do a full initialization if it is
> > > present I would say.
> > 
> > This is not copying the variable length data area of the expression,
> > just the expression head.
> 
> Ah right. But that is only ->ops. We can set this directly, should generate
> better code and be easier to understand.

I left the memcpy just to avoid that we forget in case we ever get
more data there (unlikely). So I'll set the pointer instead.

If no further objections, will make those two changes locally and will
push this upstream.

Thanks!
