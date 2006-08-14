From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 12:01:20 +0400
Message-ID: <20060814080120.GA20053@2ka.mipt.ru>
References: <20060808.163915.03600382.davem@davemloft.net> <20060811140019.GA8611@ms2.inr.ac.ru> <20060811.172730.34542868.davem@davemloft.net> <20060813130431.GA14138@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33773 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751919AbWHNICm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 04:02:42 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060813130431.GA14138@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 13, 2006 at 05:04:31PM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> Hello!
> 
> > E1000 wants 16K buffers for jumbo MTU settings.
> > 
> > The reason is that the chip can only handle power-of-2 buffer
> > sizes, and next hop from 9K is 16K.
> 
> Let it use pages. Someone should start. :-)
> 
> High order allocations are disaster in any case.
> 
> 
> > If we store raw kmalloc buffers, we cannot attach them to an arbitrary
> > skb because of skb_shared_info().  This is true even if we
> > purposefully allocate the necessary head room for these kmalloc based
> > buffers.
> 
> I still do not see. For non-SG paths, you have to keep header and data
> together, you just do not need anything clever. And it does not look
> like you can. If you have a fixed space for header, you already have
> a space for refcnt to make skb_shared_info().
> 
> For SG paths, TCP_PAGE() seems to be enough and even better than
> kmalloc()ed buffers.

What if we will store array of pages and in shared info
just like we have right now. So there will only one destructor.

e1000 will setup head/data/tail pointers to point to the area in the
first sg page.

Those drivers which do not have sg support can use head/data pointers
like before, but destructor should be changed in that case.

-- 
	Evgeniy Polyakov
