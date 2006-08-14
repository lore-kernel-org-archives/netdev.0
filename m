From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 17:19:19 +0400
Message-ID: <20060814131919.GA13064@ms2.inr.ac.ru>
References: <20060808.163915.03600382.davem@davemloft.net> <20060811140019.GA8611@ms2.inr.ac.ru> <20060811.172730.34542868.davem@davemloft.net> <20060813130431.GA14138@ms2.inr.ac.ru> <20060814080120.GA20053@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:43137 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751275AbWHNNTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 09:19:49 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060814080120.GA20053@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> e1000 will setup head/data/tail pointers to point to the area in the
> first sg page.

Maybe.

But I still hope this is not necessary, the driver should be able to do
at least primitive header splitting, in that case the header could
be inlined to skb.

Alternatively, header can be copied with skb_pull(). Not good, but
it is at least a regula procedure, which f.e. allows to keep the pages
in highmem.


> What if we will store array of pages and in shared info
> just like we have right now. So there will only one destructor.

Seems, this is not enough. Actually, I was asking for your experience
with aio.

The simplest situation, which confuses me, translated to aio language:
two senders send two pages. Those pages are to be recycled, when we
are done. We have to notify both. And we have to merge both those pages
in one segment.

The second half of that mail suggested three different solutions,
all of them creepy. :-)

Alexey
