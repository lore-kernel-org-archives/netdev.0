From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: problems with e1000 and jumboframes
Date: Sat, 5 Aug 2006 14:41:36 +0400
Message-ID: <20060805104136.GA32598@2ka.mipt.ru>
References: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com> <E1G8sif-0003oY-00@gondolin.me.apana.org.au> <20060804061513.GB413@2ka.mipt.ru> <41b516cb0608040834o1d433f23v2f2ba1a1b05ccbc6@mail.gmail.com> <20060804194209.GA25167@2ka.mipt.ru> <4807377b0608041402p10149bfbrd9e5f3b8849d3f56@mail.gmail.com> <20060805095846.GA17867@2ka.mipt.ru> <20060805100954.GB20939@gondor.apana.org.au> <20060805102435.GA15740@2ka.mipt.ru> <20060805103307.GB21184@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Chris Leech <chris.leech@gmail.com>, arnd@arndnet.de,
	olel@ans.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43744 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751417AbWHEKlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 06:41:55 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060805103307.GB21184@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 08:33:07PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Sat, Aug 05, 2006 at 02:24:36PM +0400, Evgeniy Polyakov wrote:
> >
> > > If we had a flag to indicate writability we could also have a flag to
> > > indicate that the memory comes from kmalloc rather than alloc_page.
> > 
> > Yes, that would be good, but who will give us a bit in the struct page?
> > Can we recreate frag_list elements to be a bitmasks and steal couple
> > of them there, so we would not increase fragment's structure size?
> 
> I wasn't thinking of a bit in struct page, but rather a bit in skb_frag_t.

Actually we can look into struct page, namely into page->lru.next,
PG_slab bit or page->private (for combined pages), which are pointers to 
the appropriate cache, if given page was obtained through kmalloc.
Or we can create bitmaks in fragments.

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
	Evgeniy Polyakov
