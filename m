From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 06/26] netfilter: conntrack: align nf_conn on cacheline
 boundary
Date: Wed, 6 Jul 2016 17:01:25 +0200
Message-ID: <20160706150125.GC2243@breakpoint.cc>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
 <1467815048-2240-7-git-send-email-pablo@netfilter.org>
 <063D6719AE5E284EB5DD2968C1650D6D5F4F18C1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4F18C1@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> wrote:
> From: Pablo Neira Ayuso
> > Sent: 06 July 2016 15:24
> > From: Florian Westphal <fw@strlen.de>
> > 
> > increases struct size by 32 bytes (288 -> 320), but it is the right thing,
> > else any attempt to (re-)arrange nf_conn members by cacheline won't work.
> ...
> >  	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
> >  						sizeof(struct nf_conn), 0,
> > -						SLAB_DESTROY_BY_RCU, NULL);
> > +						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
> 
> What happens on systems with cache lines that are longer than 64 bytes?

Sorry, I don't have a secret decoder ring.

HWCACHE_ALIGN is used for several other net slab caches, including
skbuff, so why is this a problem here?
