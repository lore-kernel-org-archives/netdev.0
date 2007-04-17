From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Get rid of alloc_skb code duplication
Date: Tue, 17 Apr 2007 12:29:55 -0700 (PDT)
Message-ID: <20070417.122955.48397449.davem@davemloft.net>
References: <20070417115746.GA20287@gondor.apana.org.au>
	<20070417130347.GA2632@infradead.org>
	<20070417141743.GA21473@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, netdev@vger.kernel.org, keir@xensource.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031132AbXDQT3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:29:52 -0400
In-Reply-To: <20070417141743.GA21473@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 18 Apr 2007 00:17:43 +1000

> On Tue, Apr 17, 2007 at 02:03:47PM +0100, Christoph Hellwig wrote:
> >
> > It was put in for Xen, but if you as the resident beat the crap out
> > of Xen networking guru don't know about it we should probably just
> > kill it.  Especially as we usually kill dead code pretty fast.
> 
> Heh, I wasn't touching Xen back then.
> 
> That's good news actually.  Xen has now killed their custom alloc_skb
> so this is no longer needed.  Besides, even if they needed it they'll
> have to patch it in anyway since you've already killed the ifdef that
> lets them have a custom alloc_skb :)
> 
> [NET]: Get rid of alloc_skb_from_cache
> 
> Since this was added originally for Xen, and Xen has recently (~2.6.18)
> stopped using this function, we can safely get rid of it.  Good timing
> too since this function has started to bit rot.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.  You missed the arch/x86_64/kernel/functionlist reference
but I took care of that for you :-)

I'm going to push this into 2.6.21 because the sooner this dies
the better, even though it will make for some net-2.6.22 merge
hassles for me.
