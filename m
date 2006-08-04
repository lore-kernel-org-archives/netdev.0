From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 4 Aug 2006 10:15:13 +0400
Message-ID: <20060804061513.GB413@2ka.mipt.ru>
References: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com> <E1G8sif-0003oY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Chris Leech <chris.leech@gmail.com>, arnd@arndnet.de, olel@ans.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20403 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751251AbWHDGPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 02:15:46 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G8sif-0003oY-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 03:59:37PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Chris Leech <chris.leech@gmail.com> wrote:
> > 
> > We could try and only use page allocations for older e1000 devices,
> > putting headers and payload into skb->frags and copying the headers
> > out into the skb->data area as needed for processing.  That would do
> > away with large allocations, but in Jesse's experiments calling
> > alloc_page() is slower than kmalloc(), so there can actually be a
> > performance hit from trying to use page allocations all the time.
> 
> Interesting.  Could you guys post figures on alloc_page speed vs. kmalloc?

They probalby measured kmalloc cache access, which only falls to
alloc_pages when cache is refilled, so it will be faster for some short
period of time, but in general (especially for such big-sized
allocations) it is essencially the same.

> Also, getting memory slower is better than not getting them at all :)

Sure.

> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
	Evgeniy Polyakov
